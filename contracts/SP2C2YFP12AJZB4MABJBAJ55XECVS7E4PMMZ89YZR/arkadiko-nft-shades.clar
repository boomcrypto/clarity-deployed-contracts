;; use the SIP090 interace
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Constants
(define-constant MAX-NFTS u500)

;; Error constants
(define-constant ERR-NO-TOKENS-LEFT u404001)
(define-constant ERR-NOT-AUTHORIZED u404002)
(define-constant ERR-METADATA-FROZEN u404003)
(define-constant ERR-MINTING-CLOSED u404004)

;; define a new NFT.
(define-non-fungible-token arkadiko-shades uint)

;; Base URI for token URI
(define-data-var token-uri (string-ascii 256) "ipfs://QmZJB1ZBU8Cm8UNq3sEU9WsyLi42jDfxZsvXu9ieSsJDZ5")

;; Start of minting (block height)
(define-data-var minting-block-height uint u40200)

;; Store the last issues token ID
(define-data-var last-id uint u0)

;; Indicates whether IPFS metadata has been frozen
(define-data-var metadata-frozen bool false)

;; Total redeemed
(define-data-var total-redeemed uint u0)

;; Tokens by user
(define-map user-tokens { user: principal } { ids: (list 501 uint) })

;; Contract owner
(define-data-var owner-address principal tx-sender)

;; Keep which token user wants to burn
;; Needed to filter list
(define-map burning-token
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
  (ok (nft-get-owner? arkadiko-shades token-id))
)

;; SIP009: Transfer token to a specified principal
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))

    (remove-token-from-user-list sender token-id)
    (add-token-to-user-list recipient token-id)
    (match (nft-transfer? arkadiko-shades token-id sender recipient) success (ok success) error (err error))
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

(define-read-only (get-tokens-left)
  (let (
    (last-token-id (unwrap-panic (get-last-token-id)))
  )
    (if (>= last-token-id MAX-NFTS)
      (ok u0)
      (ok (- MAX-NFTS last-token-id))
    )
  )
)

(define-read-only (get-next-price)
  (let (
    (last-token-id (unwrap-panic (get-last-token-id)))
  )
    (get-token-price last-token-id)
  )
)

(define-read-only (get-token-price (token-id uint))
  (ok (/ (* (* (+ token-id u1) (+ token-id u1)) u1000000) u4))
)

(define-public (mint-next)
  (let (
    (price (unwrap-panic (get-next-price)))
  )
    (asserts! (<= (var-get minting-block-height) block-height) (err ERR-MINTING-CLOSED))
    (asserts! (not (is-eq (unwrap-panic (get-tokens-left)) u0)) (err ERR-NO-TOKENS-LEFT))
    (try! (contract-call? .arkadiko-token burn price tx-sender))
    (add-token-to-user-list tx-sender (var-get last-id))
    (mint tx-sender)
  )
)

(define-private (mint (new-owner principal))
  (let (
    (next-id (+ u1 (var-get last-id)))
  )
    (match (nft-mint? arkadiko-shades (var-get last-id) new-owner)
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

(define-public (burn-to-redeem (token-id uint))
  (begin
    (var-set total-redeemed (+ (var-get total-redeemed) u1))
    (remove-token-from-user-list tx-sender token-id)
    (try! (contract-call? .arkadiko-nft-shades-redeemed mint token-id tx-sender))
    (nft-burn? arkadiko-shades token-id tx-sender)
  )
)

;; ---------------------------------------------------------
;; User token list
;; ---------------------------------------------------------

(define-read-only (get-user-tokens (user principal))
  (unwrap! (map-get? user-tokens { user: user }) (tuple (ids (list u9999) )))
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
    (map-set burning-token { user: user } { token-id: token-id })
    (map-set user-tokens { user: user } { ids: (filter remove-burned-token token-ids) })
  )
)

(define-private (remove-burned-token (token-id uint))
  (let (
    (current-token (unwrap-panic (map-get? burning-token { user: tx-sender })))
  )
    (if (is-eq token-id (get token-id current-token))
      false
      true
    )
  )
)

;; ---------------------------------------------------------
;; Stats
;; ---------------------------------------------------------

(define-read-only (get-total-redeemed)
  (var-get total-redeemed)
)
