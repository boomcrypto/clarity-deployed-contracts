(use-trait sip010 .dao-traits-v2.sip010-ft-trait)

;; Helper function to pay the burn
(define-private (burn-fee (amount uint))
  (contract-call? .liquid-staked-charisma deflate amount)
)

;; Wrapper for tap function
(define-public (tap (land-id uint))
  (begin
    (try! (burn-fee u1000000))
    (contract-call? .lands tap land-id)
  )
)

;; Wrapper for wrap function
(define-public (wrap (amount uint) (sip010-asset <sip010>))
  (begin
    (try! (burn-fee u1000000))
    (contract-call? .lands wrap amount sip010-asset)
  )
)

;; Wrapper for unwrap function
(define-public (unwrap (amount uint) (sip010-asset <sip010>))
  (begin
    (try! (burn-fee u1000000))
    (contract-call? .lands unwrap amount sip010-asset)
  )
)