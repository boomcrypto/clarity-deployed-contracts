;; @contract Wrapped STX Helpers
;; @version 1

(use-trait ft-trait .sip-010-trait-ft-standard.sip-010-trait)
(use-trait treasury-trait .treasury-trait-v1-1.treasury-trait)
(use-trait staking-distributor-trait .staking-distributor-trait-v1-1.staking-distributor-trait)
(use-trait staking-trait .staking-trait-v1-1.staking-trait)
(use-trait bond-teller-trait .bond-teller-trait-v1-1.bond-teller-trait)
(use-trait value-calculator-trait .value-calculator-trait-v1-1.value-calculator-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant ERR-WRONG-TOKEN u3602002)

;; ------------------------------------------
;; Deposit
;; ------------------------------------------

(define-public (deposit 
  (bond-teller <bond-teller-trait>) 
  (value-calculator <value-calculator-trait>) 
  (distributor <staking-distributor-trait>) 
  (treasury <treasury-trait>) 
  (staking <staking-trait>) 
  (token <ft-trait>) 
  (bond-id uint) 
  (amount uint) 
  (max-price uint)
  )
  (begin
    (asserts! (is-eq (contract-of token) .wrapped-stacks-token) (err ERR-WRONG-TOKEN))

    ;; Wrap STX
    (try! (contract-call? .wrapped-stacks-token wrap amount))

    ;; Deposit
    (contract-call? .bond-depository-v1-1 deposit
      bond-teller
      value-calculator
      distributor
      treasury
      staking
      token
      bond-id
      amount
      max-price
    )
  )
)

