;; @contract Staking Trait
;; @version 1

(define-trait staking-trait
  (

    ;; @desc - Get the current USDh per sUSDh ratio
    ;; @return - uint: ratio with 8 decimal precision
    (get-usdh-per-susdh () (response uint uint))

    ;; @desc - Stake USDh to mint sUSDh
    ;; @param - amount: USDh to stake (10**8)
    ;; @return - (ok bool) on success, (err uint) on failure
    (stake (uint (optional (buff 64))) (response bool uint))

    ;; @desc - Create a claim to unstake sUSDh (with cooldown period)
    ;; @param - amount: sUSDh to unstake (10**8)
    ;; @return - (ok uint) on success, (err uint) on failure
    (unstake (uint) (response uint uint))

  )
)