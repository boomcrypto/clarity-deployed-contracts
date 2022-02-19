;; Storage
(define-map bitcoin-monkeys-presale-count principal uint)
(define-map partner-presale-count principal uint)

;; Define Constants
(define-constant mint-price u45000000)
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-SALE-NOT-ACTIVE (err u500))
(define-constant ERR-NO-MINTPASS-REMAINING (err u501))

;; Define Variables
(define-data-var bitcoin-monkeys-mintpass-sale-active bool false)
(define-data-var partner-mintpass-sale-active bool false)
(define-data-var sale-active bool false)
(define-data-var banana-mint-active bool false)
(define-data-var sale-stage uint u0)

;; Presale balance
(define-read-only (get-bitcoin-monkeys-presale-balance (account principal))
  (default-to u0
    (map-get? bitcoin-monkeys-presale-count account)))

(define-read-only (get-partner-presale-balance (account principal))
  (default-to u0
    (map-get? partner-presale-count account)))

;; Claim a new NFT
(define-public (claim)
  (if (var-get sale-active)
    (public-mint tx-sender)
    (if (var-get bitcoin-monkeys-mintpass-sale-active)
      (bitcoin-monkeys-mintpass-mint tx-sender)
      (if (var-get partner-mintpass-sale-active)
        (partner-mintpass-mint tx-sender)
        (not-live)
      )
    )
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

(define-public (claim-with-bananas)
  (banana-mint tx-sender)
)

;; Internal - Mint NFT using Mintpass mechanism
(define-private (bitcoin-monkeys-mintpass-mint (new-owner principal))
  (let ((presale-balance (get-bitcoin-monkeys-presale-balance new-owner)))
    (asserts! (var-get bitcoin-monkeys-mintpass-sale-active) ERR-SALE-NOT-ACTIVE)
    (asserts! (> presale-balance u0) ERR-NO-MINTPASS-REMAINING)
    (map-set bitcoin-monkeys-presale-count
              new-owner
              (- presale-balance u1))
  (contract-call? .bitcoin-monkeys-labs stx-mint new-owner)))

;; Internal - Mint NFT using Mintpass mechanism
(define-private (partner-mintpass-mint (new-owner principal))
  (let ((presale-balance (+ (get-bitcoin-monkeys-presale-balance new-owner) (get-partner-presale-balance new-owner))))
    (asserts! (var-get partner-mintpass-sale-active) ERR-SALE-NOT-ACTIVE)
    (asserts! (> presale-balance u0) ERR-NO-MINTPASS-REMAINING)
    (map-set bitcoin-monkeys-presale-count
              new-owner
              u0)
    (map-set partner-presale-count
              new-owner
              (- presale-balance u1))
  (contract-call? .bitcoin-monkeys-labs stx-mint new-owner))
)

;; Internal - Mint public sale NFT
(define-private (public-mint (new-owner principal))
  (begin
    (asserts! (var-get sale-active) ERR-SALE-NOT-ACTIVE)
    (contract-call? .bitcoin-monkeys-labs stx-mint new-owner)))

(define-private (not-live)
  (begin
    (asserts! (var-get sale-active) ERR-SALE-NOT-ACTIVE)
    (asserts! (var-get bitcoin-monkeys-mintpass-sale-active) ERR-SALE-NOT-ACTIVE)
    (asserts! (var-get partner-mintpass-sale-active) ERR-SALE-NOT-ACTIVE)
    (ok false)
  )
)

;; Internal - Mint public sale NFT
(define-private (banana-mint (new-owner principal))
  (begin
    (asserts! (var-get banana-mint-active) ERR-SALE-NOT-ACTIVE)
    (contract-call? .bitcoin-monkeys-labs banana-mint new-owner)))

;; Set public sale flag
(define-public (flip-bitcoin-monkeys-sale)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER)  ERR-NOT-AUTHORIZED)
    ;; Disable the Public sale
    (var-set sale-active false)
    (var-set partner-mintpass-sale-active false)
    (var-set bitcoin-monkeys-mintpass-sale-active (not (var-get bitcoin-monkeys-mintpass-sale-active)))
    (ok (var-get bitcoin-monkeys-mintpass-sale-active))))

;; Set public sale flag
(define-public (flip-partner-sale)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER)  ERR-NOT-AUTHORIZED)
    ;; Disable the Public sale
    (var-set sale-active false)
    (var-set bitcoin-monkeys-mintpass-sale-active false)
    (var-set partner-mintpass-sale-active (not (var-get partner-mintpass-sale-active)))
    (ok (var-get partner-mintpass-sale-active))))

;; Set public sale flag
(define-public (flip-sale)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set bitcoin-monkeys-mintpass-sale-active false)
    (var-set partner-mintpass-sale-active false)
    (var-set sale-active (not (var-get sale-active)))
    (ok (var-get sale-active))))

(define-public (flip-banana-sale)
  (begin
    (var-set banana-mint-active (not (var-get banana-mint-active)))
    (ok (var-get banana-mint-active))
  )
)

(define-read-only (get-sale-status)
  (list (var-get bitcoin-monkeys-mintpass-sale-active) (var-get partner-mintpass-sale-active) (var-get sale-active))
)

(as-contract (contract-call? .bitcoin-monkeys-labs set-mint-address))


(define-public (set-bm-wl (address principal) (limit uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set bitcoin-monkeys-presale-count address limit)
    (ok true)
  )
)

(define-public (bulk-add-bm (addresses (list 1000 principal)) (limits (list 1000 uint)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (print (map set-bm-wl addresses limits))
    (ok true)
  )
)

(define-public (set-partner-wl (address principal) (limit uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set partner-presale-count address limit)
    (ok true)
  )
)

(define-public (bulk-add-partner (addresses (list 1000 principal)) (limits (list 1000 uint)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (print (map set-partner-wl addresses limits))
    (ok true)
  )
)