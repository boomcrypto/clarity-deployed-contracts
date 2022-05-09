;;live (impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token Sponges uint)

;; Storage
(define-map token-count principal uint)

;; Const
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u301))
(define-constant ERR-NOT-FOUND (err u404))


;; Vars
(define-data-var last-id uint u0)
(define-data-var base-uri (string-ascii 80) "")
(define-constant contract-uri "")

;; Token count for account
(define-read-only (get-balance (account principal))
 (default-to u0
  (map-get? token-count account)))



;; SIP009 Transfers token to a specfied principal
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
    
    (trnsfr id sender recipient)
  )
)


(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? Sponges id sender recipient)
    success
      (let 
        (
          (sender-balance (get-balance sender))
          (recipient-balance (get-balance recipient))
        )

        (map-set token-count sender (- sender-balance u1))
        (map-set token-count recipient (+ recipient-balance u1))
        (ok success)
      )
      error 
      (err error)
))


;; SIP009: Get The owner of the specified token ID

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? Sponges id) )
)

;; Get the last ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id))
)

(define-read-only (get-token-uri (id uint))
  (ok (some (var-get base-uri)))

)

(define-read-only (get-contract-uri)
  (ok contract-uri)
)


(define-public (mint (new-owner principal))
  (let
    (
      (next-id (+ u1 (var-get last-id)))
    )
    (match (nft-mint? Sponges next-id new-owner)
      success
      (let
        (
          (current-balance (get-balance new-owner))
        )
        (begin
          (var-set last-id next-id)
          (map-set token-count
            new-owner
            (+ current-balance u1)
          )
          (ok true)
        )
      )
      error (err (* error u10000))
    )
  )
)