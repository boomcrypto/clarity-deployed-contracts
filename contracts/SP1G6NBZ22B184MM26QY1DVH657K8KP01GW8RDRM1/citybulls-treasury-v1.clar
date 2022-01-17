(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.treasury-trait.treasury-trait)

(use-trait ft-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.ft-trait.ft-trait)
(use-trait nft-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.nft-trait.nft-trait)

(define-constant contract-address (as-contract tx-sender))
(define-constant contract-owner tx-sender)

(define-constant err-failed-to-transfer-stx u300)
(define-constant err-failed-to-transfer-ft u301)
(define-constant err-failed-to-transfer-nft u302)
(define-constant err-nice-try u401)

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
    (asserts! (is-eq tx-sender contract-owner) (err err-nice-try))
    (try! (as-contract (stx-transfer? amount contract-address recipient)))
    (ok true)
  )
)

(define-public (move-ft (ft <ft-trait>) (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-nice-try))
    (try! (as-contract (contract-call? ft transfer amount contract-address recipient (some 0x11))))
    (ok true)
  )
)

(define-public (move-nft (nft <nft-trait>) (id uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-nice-try))
    (try! (as-contract (contract-call? nft transfer id contract-address recipient)))
    (ok true)
  )
)