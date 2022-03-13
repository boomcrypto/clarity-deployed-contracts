;; Storage
(define-map presale-count principal uint)

;; Define Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-SALE-NOT-ACTIVE (err u500))
(define-constant ERR-NO-MINTPASS-REMAINING (err u501))

;; Define Variables
(define-data-var mintpass-sale-active bool false)
(define-data-var sale-active bool false)
(define-data-var sale-stage uint u0)

;; Presale balance
(define-read-only (get-presale-balance (account principal))
  (default-to u0
    (map-get? presale-count account)))


;; Claim a new NFT
(define-public (claim)
  (if (var-get sale-active)
    (public-mint tx-sender)
    (mintpass-mint tx-sender)
  )
)

(define-public (claim-two)
  (begin
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-three)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-four)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-five)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-six)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-seven)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-eight)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-nine)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-ten)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true))) 


;; Internal - Mint NFT using Mintpass mechanism
(define-private (mintpass-mint (new-owner principal))
  (let ((presale-balance (get-presale-balance new-owner)))
    (asserts! (var-get mintpass-sale-active) ERR-SALE-NOT-ACTIVE)
    (asserts! (> presale-balance u0) ERR-NO-MINTPASS-REMAINING)
    (map-set presale-count
              new-owner
              (- presale-balance u1))
  (contract-call? .alaska stx-mint new-owner)))

;; Internal - Mint public sale NFT
(define-private (public-mint (new-owner principal))
  (begin
    (asserts! (var-get sale-active) ERR-SALE-NOT-ACTIVE)
    (contract-call? .alaska stx-mint new-owner)))

(define-private (not-live)
  (begin
    (asserts! (var-get sale-active) ERR-SALE-NOT-ACTIVE)
    (asserts! (var-get mintpass-sale-active) ERR-SALE-NOT-ACTIVE)
    (ok false)
  )
)

;; Set public sale flag
(define-public (flip-mintpass-sale)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER)  ERR-NOT-AUTHORIZED)
    ;; Disable the Public sale
    (var-set sale-active false)
    (var-set mintpass-sale-active (not (var-get mintpass-sale-active)))
    (ok (var-get mintpass-sale-active))))

;; Set public sale flag
(define-public (flip-sale)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set mintpass-sale-active false)
    (var-set sale-active (not (var-get sale-active)))
    (ok (var-get sale-active))))

(define-read-only (get-sale-status)
  (list (var-get mintpass-sale-active) (var-get sale-active))
)

(as-contract (contract-call? .alaska set-mint-address))


(define-public (set-wl (address principal) (limit uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set presale-count address limit)
    (ok true)
  )
)

(define-public (bulk-add-wl (addresses (list 1000 principal)) (limits (list 1000 uint)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (print (map set-wl addresses limits))
    (ok true)
  )
)