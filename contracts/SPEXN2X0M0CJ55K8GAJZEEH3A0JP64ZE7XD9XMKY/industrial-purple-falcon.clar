;; contract that calculates the estimated output for a swap via:
;; SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1

(define-read-only (get-dy (token-x principal) (token-y principal) (dx uint))
  (let (
    (pair-external (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-pair-details token-x token-y) (err "err-pair-external")))
    (balance-x (unwrap! (get balance-x pair-external) (err "err-balance-x")))
    (balance-y (unwrap! (get balance-y pair-external) (err "err-balance-y")))
    (dx-with-fees (/ (* u997 dx) u1000))
    (dy (/ (* balance-y dx-with-fees) (+ balance-x dx-with-fees)))
  )
    (ok dy)
  )
)

(define-read-only (get-dx (token-x principal) (token-y principal) (dy uint))
  (let (
    (pair-external (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-pair-details token-x token-y) (err "err-pair-external")))
    (balance-x (unwrap! (get balance-x pair-external) (err "err-balance-x")))
    (balance-y (unwrap! (get balance-y pair-external) (err "err-balance-y")))
    (dy-with-fees (/ (* u997 dy) u1000))
    (dx (/ (* balance-x dy-with-fees) (+ balance-y dy-with-fees)))
  )
    (ok dx)
  )
)