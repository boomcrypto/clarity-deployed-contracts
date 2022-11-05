(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant contract-owner tx-sender)

(define-constant uri "ipfs://Qmc2wp4vQp9mjRkZNwd7dkcUy2YxdX8wXtJomJK4XSV93N")
(define-constant max-supply u25)
(define-non-fungible-token CrashPunks-Geisha-TShirt uint)

(define-data-var last-id uint u0)

(define-constant err-sender-only (err u100))
(define-constant err-contract-owner-only (err u101))
(define-constant err-max-supply-reached (err u200))

(define-read-only 
  (get-token-uri
    (id uint)
  )
  (ok (some uri))
)

(define-read-only 
  (get-last-token-id)
  (ok (var-get last-id))
)

(define-read-only 
  (get-owner
    (id uint)
  )
  (ok (nft-get-owner? CrashPunks-Geisha-TShirt id))
)

(define-public 
  (transfer
    (id uint)
    (sender principal)
    (recipient principal)
  )
  (begin
    (asserts! (is-eq tx-sender sender) err-sender-only)
    (nft-transfer? CrashPunks-Geisha-TShirt id sender recipient)
  )
)

(define-public 
  (burn
    (id uint)
    (sender principal)
  )
  (begin 
    (asserts! (is-eq tx-sender sender) err-sender-only)
    (nft-burn? CrashPunks-Geisha-TShirt id sender)
  )
)

(define-public 
  (mint
    (recipient principal)
  )
  (let
    (
      (id (+ (var-get last-id) u1))
    )
    (asserts! (is-eq tx-sender contract-owner) err-contract-owner-only)
    (asserts! (<= id max-supply) err-max-supply-reached)
    (try! (nft-mint? CrashPunks-Geisha-TShirt id recipient))
    (ok (var-set last-id id))
  )
)

(define-public
  (mint-many
    (recipients (list 25 principal))
  )
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-contract-owner-only)
    (asserts! (>= max-supply (+ (len recipients) (var-get last-id))) err-max-supply-reached)
    (fold mint-many-iter recipients (ok true))
  )
)

(define-private 
  (mint-many-iter
    (recipient principal)
    (previous (response bool uint))
  )
  (match
    previous
    ok-value
      (begin
        (try! (nft-mint? CrashPunks-Geisha-TShirt (var-get last-id) recipient))
        (ok (var-set last-id (+ (var-get last-id) u1)))
      )
    err-value (err err-value)
  )
)
