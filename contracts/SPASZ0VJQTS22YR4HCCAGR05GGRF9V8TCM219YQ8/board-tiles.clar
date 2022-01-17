(impl-trait .nft-trait.nft-trait)
(impl-trait .board-main-nft-trait.board-main-nft-trait)

(define-non-fungible-token tiles uint)

;; variables 
(define-data-var last-id uint u0)
(define-data-var token-uri (string-ascii 256) "")
(define-data-var contract-owner principal tx-sender)

;; constants
(define-constant ERR-TRANSFER (err u1000))
(define-constant ERR-NOT-AUTHORIZED (err u1001))

;; maps
(define-map user-tokens { user: principal } { token-ids: (list 5000 uint) })
(define-map removing-token { user: principal } { token-id: uint })

;; 
;; SIP009
;; 

(define-read-only (get-last-token-id)
  (ok (var-get last-id))
)

(define-read-only (get-token-uri (token-id uint))  
  (ok (some (var-get token-uri)))
)

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? tiles token-id))
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (is-eq tx-sender sender)
    (begin
      (remove-token-from-user-list sender token-id)
      (add-token-to-user-list recipient token-id)
      (match (nft-transfer? tiles token-id sender recipient) success (ok success) error (err error))
    )
    ERR-TRANSFER
  )
)


;; 
;; Admin
;; 

(define-public (set-contract-owner (address principal))
  (begin
    (asserts! (is-eq (var-get contract-owner) tx-sender) ERR-NOT-AUTHORIZED)
    (var-set contract-owner address)
    (ok true)
  )
)

(define-public (set-token-uri (new-uri (string-ascii 256)))
  (begin
    (asserts! (is-eq (var-get contract-owner) tx-sender) ERR-NOT-AUTHORIZED)
    (var-set token-uri new-uri)
    (ok true)
  )
)


;; 
;; User
;; 

(define-read-only (get-user-tokens (user principal))
  (unwrap! (map-get? user-tokens { user: user }) (tuple (token-ids (list))  ))
)

(define-private (add-token-to-user-list (user principal) (token-id uint))
  (let (
    (current-user-tokens (get token-ids (get-user-tokens user)))
    (new-list (as-max-len? (append current-user-tokens token-id) u5000))
  )
    (if (is-none new-list)
      false
      (map-set user-tokens { user: user } { token-ids: (unwrap-panic new-list) })
    )
  )
)

(define-private (remove-token-from-user-list (user principal) (token-id uint))
  (let (
    (token-ids (get token-ids (get-user-tokens user)))
  )
    (map-set removing-token { user: user } { token-id: token-id })
    (map-set user-tokens { user: user } { token-ids: (filter remove-transfered-token token-ids) })
  )
)

(define-private (remove-transfered-token (token-id uint))
  (let (
    (current-token (unwrap-panic (map-get? removing-token { user: tx-sender })))
  )
    (if (is-eq token-id (get token-id current-token))
      false
      true
    )
  )
)


;; 
;; Mint and Burn
;; 

(define-public (main-mint (new-owner principal))
  (let (
    (current-id (var-get last-id))
    (next-id (+ u1 current-id))
  )
    (asserts! (is-eq contract-caller .board-main) ERR-NOT-AUTHORIZED)

    (add-token-to-user-list new-owner current-id)

    (match (nft-mint? tiles current-id new-owner)
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

(define-public (main-burn (token-id uint) (owner principal))
  (begin
    (asserts! (is-eq contract-caller .board-main) ERR-NOT-AUTHORIZED)
    (nft-burn? tiles token-id owner)
  )
)

(define-public (user-burn (token-id uint))
  (begin
    (nft-burn? tiles token-id tx-sender)
  )
)
