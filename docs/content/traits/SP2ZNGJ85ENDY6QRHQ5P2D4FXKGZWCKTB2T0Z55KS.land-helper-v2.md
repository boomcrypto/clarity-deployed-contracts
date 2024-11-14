---
title: "Trait land-helper-v2"
draft: true
---
```
(use-trait sip010 .dao-traits-v2.sip010-ft-trait)

;; Constants for fee calculation
(define-constant EXPERIENCE-SCALE u1000000000) ;; 1,000 EXP (with 6 decimal places)
(define-constant FEE-SCALE u1000000) ;; 1 sCHA (with 6 decimal places)

;; Helper function to calculate the fee based on experience
(define-private (calculate-fee (experience uint))
  (/ (* experience FEE-SCALE) EXPERIENCE-SCALE)
)

;; Helper function to get user's experience
(define-private (get-user-experience (user principal))
  (unwrap-panic (contract-call? .experience get-balance user))
)

;; Helper function to pay the burn
(define-private (burn-fee (user principal))
  (let
    (
      (experience (get-user-experience user))
      (fee (calculate-fee experience))
    )
    (contract-call? .liquid-staked-charisma deflate (max fee u1))
  )
)

;; Wrapper for tap function
(define-public (tap (land-id uint))
  (begin
    (try! (burn-fee tx-sender))
    (contract-call? .lands tap land-id)
  )
)

;; Wrapper for wrap function
(define-public (wrap (amount uint) (sip010-asset <sip010>))
  (begin
    (try! (burn-fee tx-sender))
    (contract-call? .lands wrap amount sip010-asset)
  )
)

;; Wrapper for unwrap function
(define-public (unwrap (amount uint) (sip010-asset <sip010>))
  (begin
    (try! (burn-fee tx-sender))
    (contract-call? .lands unwrap amount sip010-asset)
  )
)

;; Util functions
(define-private (max (a uint) (b uint))
  (if (> a b) a b)
)
```
