(impl-trait .treasury-trait.treasury-trait)
(use-trait ft-trait .ft-trait.ft-trait)
(use-trait nft-trait .nft-trait.nft-trait)

;; errors
(define-constant err-insufficient-balance u1)
(define-constant err-failed-to-transfer-stx u300)
(define-constant err-failed-to-transfer-ft u301)
(define-constant err-failed-to-transfer-nft u302)
(define-constant err-nice-try u401)

;; constants
(define-constant contract-address (as-contract tx-sender))

;; variables
(define-data-var stackerdao principal .stackerdao-dao)

;; public functions

(define-public (deposit-stx (amount uint))
  (begin 
    (unwrap! (stx-transfer? amount tx-sender contract-address) (err err-failed-to-transfer-stx))
    (ok true)
  )
)

(define-public (deposit-ft (ft <ft-trait>) (amount uint))
  (begin
    (unwrap! (contract-call? ft transfer amount tx-sender contract-address (some 0x11)) (err err-failed-to-transfer-ft))
    (ok true)
  )
)

(define-public (deposit-nft (nft <nft-trait>) (id uint))
  (begin
    (unwrap! (contract-call? nft transfer id tx-sender contract-address) (err err-failed-to-transfer-nft))
    (ok true)
  )
)

(define-public (move-stx (amount uint) (recipient principal))
  (begin
    (asserts! (is-from-dao) (err err-nice-try))
    (try! (as-contract (stx-transfer? amount contract-address recipient)))
    (ok true)
  )
)

(define-public (move-ft (ft <ft-trait>) (amount uint) (recipient principal))
  (begin
    (asserts! (is-from-dao) (err err-nice-try))
    (try! (as-contract (contract-call? ft transfer amount contract-address recipient (some 0x11))))
    (ok true)
  )
)

(define-public (move-nft (nft <nft-trait>) (id uint) (recipient principal))
  (begin
    (asserts! (is-from-dao) (err err-nice-try))
    (try! (as-contract (contract-call? nft transfer id contract-address recipient)))
    (ok true)
  )
)

;; private functions

(define-private (is-from-dao)
  (if (is-eq contract-caller (var-get stackerdao))
    true
    false
  )
)