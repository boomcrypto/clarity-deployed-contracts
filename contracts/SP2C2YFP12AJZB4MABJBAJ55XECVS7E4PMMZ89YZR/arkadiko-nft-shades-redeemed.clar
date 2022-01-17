;; use the SIP090 interace
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Error constants
(define-constant ERR-NOT-AUTHORIZED u504001)
(define-constant ERR-METADATA-FROZEN u504002)

;; define a new NFT.
(define-non-fungible-token arkadiko-shades-redeemed uint)

;; Store the last issues token ID
(define-data-var last-id uint u0)

;; Base URI for token URI
(define-data-var token-uri (string-ascii 256) "ipfs://QmRgg1oio1PuJSmnBDVd3Pi5VMEzGAS2SUzEBimnC5XsC2")

;; Indicates whether IPFS metadata has been frozen
(define-data-var metadata-frozen bool false)

;; Tokens by user
(define-map user-tokens { user: principal } { ids: (list 501 uint) })

;; Contract owner
(define-data-var owner-address principal tx-sender)

;; Original NFT mappping
(define-map original-token
  { token-id: uint }
  { original-token-id: uint }
)

;; Keep which token user wants to transfer
;; Needed to filter list
(define-map transfering-token
  { user: principal }
  { token-id: uint }
)

;; ---------------------------------------------------------
;; SIP009 functions
;; ---------------------------------------------------------

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id))
)

;; SIP009: Get the token URI
(define-read-only (get-token-uri (token-id uint))  
  (ok (some (var-get token-uri)))
)

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? arkadiko-shades-redeemed token-id))
)

;; SIP009: Transfer token to a specified principal
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))

    (remove-token-from-user-list sender token-id)
    (add-token-to-user-list recipient token-id)
    (match (nft-transfer? arkadiko-shades-redeemed token-id sender recipient) success (ok success) error (err error))
  )
)

;; ---------------------------------------------------------
;; Admin
;; ---------------------------------------------------------

(define-public (set-owner-address (address principal))
  (let (
    (wallet (var-get owner-address))
  )
    (asserts! (is-eq wallet tx-sender) (err ERR-NOT-AUTHORIZED))
    (var-set owner-address address)
    (ok true)
  )
)

(define-public (set-token-uri (new-uri (string-ascii 256)))
  (begin
    (asserts! (is-eq (var-get owner-address) tx-sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))

    (var-set token-uri new-uri)
    (ok true)
  )
)

(define-public (freeze-metadata)
  (begin
    (asserts! (is-eq (var-get owner-address) tx-sender) (err ERR-NOT-AUTHORIZED))
    (var-set metadata-frozen true)
    (ok true)
  )
)

;; ---------------------------------------------------------
;; Mint functions
;; ---------------------------------------------------------

(define-public (mint (token-id uint) (owner principal))
  (begin
    (asserts! (is-eq contract-caller .arkadiko-nft-shades) (err ERR-NOT-AUTHORIZED))
    (add-token-to-user-list owner (var-get last-id))
    (map-set original-token { token-id: (var-get last-id) } { original-token-id: token-id })
    (mint-for-owner owner)
  )
)

(define-private (mint-for-owner (new-owner principal))
  (let (
    (next-id (+ u1 (var-get last-id)))
  )
    (match (nft-mint? arkadiko-shades-redeemed (var-get last-id) new-owner)
      success
        (begin
          (var-set last-id next-id)
          (ok true)
        )
      error 
        (err error)
    )
  )
)

;; ---------------------------------------------------------
;; User token list
;; ---------------------------------------------------------

(define-read-only (get-user-tokens (user principal))
  (unwrap! (map-get? user-tokens { user: user }) (tuple (ids (list u9999) )))
)

(define-read-only (token-id-to-original-token-id (token-id uint))
  (get original-token-id (map-get? original-token { token-id: token-id }))
)

(define-read-only (get-user-original-tokens (user principal))
  (let (
    (current-user-tokens (get ids (get-user-tokens user)))
  )
    (map token-id-to-original-token-id current-user-tokens)
  )
)

(define-private (add-token-to-user-list (user principal) (token-id uint))
  (let (
    (current-user-tokens (get ids (get-user-tokens user)))
  )
    (map-set user-tokens { user: user } { ids: (unwrap-panic (as-max-len? (append current-user-tokens token-id) u501)) })
  )
)

(define-private (remove-token-from-user-list (user principal) (token-id uint))
  (let (
    (token-ids (get ids (get-user-tokens user)))
  )
    (map-set transfering-token { user: user } { token-id: token-id })
    (map-set user-tokens { user: user } { ids: (filter remove-user-token token-ids) })
  )
)

(define-private (remove-user-token (token-id uint))
  (let (
    (current-token (unwrap-panic (map-get? transfering-token { user: tx-sender })))
  )
    (if (is-eq token-id (get token-id current-token))
      false
      true
    )
  )
)
