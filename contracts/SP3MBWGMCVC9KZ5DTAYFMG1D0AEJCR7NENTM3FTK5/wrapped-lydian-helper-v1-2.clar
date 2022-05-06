;; @contract Wrapped Lydian Helper
;; @version 1

;; ---------------------------------------------------------
;; LDN to wLDN
;; ---------------------------------------------------------

(define-public (ldn-to-wldn (amount uint))
  (begin
    (try! (contract-call? .staking-v1-1 stake .staking-distributor-v1-1 .treasury-v1-1 amount))
    (contract-call? .wrapped-lydian-creator-v1-1 wrap amount)
  )
)

;; ---------------------------------------------------------
;; Auction
;; ---------------------------------------------------------

(define-public (auction-withdraw-wldn (auction-id uint))
  (let (
    (ldn-amount (unwrap-panic (contract-call? .auction-v1-1 withdraw-tokens auction-id)))
  )
    (ldn-to-wldn ldn-amount)
  )
)

;; ---------------------------------------------------------
;; Bond
;; ---------------------------------------------------------

(define-public (redeem-bond-wldn (bond-type uint) (bond-id uint))
  (let (
    (sldn-amount (unwrap-panic (contract-call? .bond-teller-v1-2 redeem bond-type bond-id)))
  )
    (contract-call? .wrapped-lydian-creator-v1-1 wrap sldn-amount)
  )
)

(define-public (redeem-all-bonds-wldn (bond-type uint))
  (let (
    (sldn-amount (unwrap-panic (contract-call? .bond-teller-v1-2 redeem-all bond-type)))
  )
    (contract-call? .wrapped-lydian-creator-v1-1 wrap sldn-amount)
  )
)

