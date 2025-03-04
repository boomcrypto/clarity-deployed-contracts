;; Split swaps across multiple DEXs

(define-public (buy-cha (amt-in uint))
  (begin
    (unwrap! (contract-call? .alex-wrapper-v0 swap-stx-for-cha amt-in) (err "ALEX_FAILED"))
    (unwrap! (contract-call? .charisma-wrapper-v0 swap-stx-for-cha amt-in) (err "CHARISMA_FAILED"))
    (ok true)))

(define-public (sell-cha (amt-in uint))
  (begin 
    (unwrap! (contract-call? .alex-wrapper-v0 swap-cha-for-stx amt-in) (err "ALEX_FAILED"))
    (unwrap! (contract-call? .charisma-wrapper-v0 swap-cha-for-stx amt-in) (err "CHARISMA_FAILED"))
    (ok true)))