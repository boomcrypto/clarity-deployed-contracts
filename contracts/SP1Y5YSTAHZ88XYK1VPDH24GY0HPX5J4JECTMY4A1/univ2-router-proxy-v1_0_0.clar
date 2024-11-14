(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

(use-trait pool-trait     .univ2-pool-trait_v1_0_0.univ2-pool-trait)
(use-trait lp-token-trait .univ2-lp-token-trait_v1_0_0.univ2-lp-token-trait)
(use-trait fees-trait     .univ2-fees-trait_v1_0_0.univ2-fees-trait)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-trait registry-trait (
  (register (<ft-trait> <ft-trait> <lp-token-trait> <pool-trait> <fees-trait>)
  (response
    {
      symbol:       (string-ascii 32),
      token0:       principal,
      token1:       principal,
      lp-token:     principal,
      fees: principal,
      reserve0:     uint,
      reserve1:     uint,
      block-height: uint,
      burn-block-height: uint,
    }
    uint))
))

(define-trait initial-lp-proxy-trait
  (
  (send     (<ft-trait> <ft-trait> uint uint) (response bool uint))
  (retrieve (<ft-trait> <ft-trait>)           (response { user: principal, amt0: uint, amt1: uint } uint))
))

(define-trait distributor-trait
  (
   (set-reward-token  (principal) (response bool uint))
  ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-constant err-router-preconditions  (err u200))
(define-constant err-router-postconditions (err u201))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; requires sender == owner of both contracts
(define-public
  (init-initial-lp
    (registry         <registry-trait>)
    (token0           <ft-trait>)
    (token1           <ft-trait>)
    (lp-token         <lp-token-trait>)
    (pool             <pool-trait>)
    (fees             <fees-trait>)
    (initial-lp-proxy <initial-lp-proxy-trait>)
    )

    (let ((na       (try! (contract-call? registry register token0 token1 lp-token pool fees)))
          (initial  (try! (contract-call? initial-lp-proxy retrieve token0 token1)))
          (amt0     (get amt0 initial))
          (amt1     (get amt1 initial))
          (lp       (try! (as-contract (contract-call? pool mint token0 token1 lp-token amt0 amt1))))
          )

      (try! (as-contract (contract-call?
                          lp-token
                          transfer
                          (get liquidity lp)
                          (as-contract tx-sender)
                          (get user initial)
                          none)))
      (ok true)
    ))

;;; eof
