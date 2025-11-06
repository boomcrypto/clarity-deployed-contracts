;; @contract BitflowTraits
;; @version 1.0
;; @description Trait contracts for bitflow core swap functionality (stableswap, XYK, and helper functions)

(use-trait ft 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.sip-010-trait-ft-standard-v-1-1.sip-010-trait)
(use-trait stableswap-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-trait-v-1-2.stableswap-pool-trait)
(use-trait xyk-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-trait-v-1-2.xyk-pool-trait)

;;-------------------------------------
;; Stableswap Core Trait
;;-------------------------------------

(define-trait stableswap-core-trait
  (
    ;;-------------------------------------
    ;; Stableswap Swap Functions
    ;;-------------------------------------

    ;; @desc - Swap x token for y token via a stableswap pool
    ;; @param - pool-trait: stableswap pool trait for the trading pool
    ;; @param - x-token-trait: SIP-010 trait of the input token
    ;; @param - y-token-trait: SIP-010 trait of the output token
    ;; @param - x-amount: amount of x tokens to swap
    ;; @param - min-dy: minimum amount of y tokens to receive
    ;; @return - (ok uint) amount of y tokens received on success, (err uint) on failure
    (swap-x-for-y
      (
        <stableswap-pool-trait>
        <ft>
        <ft>
        uint
        uint
      )
      (response uint uint)
    )

    ;; @desc - Swap y token for x token via a stableswap pool
    ;; @param - pool-trait: stableswap pool trait for the trading pool
    ;; @param - x-token-trait: SIP-010 trait of the output token
    ;; @param - y-token-trait: SIP-010 trait of the input token
    ;; @param - y-amount: amount of y tokens to swap
    ;; @param - min-dx: minimum amount of x tokens to receive
    ;; @return - (ok uint) amount of x tokens received on success, (err uint) on failure
    (swap-y-for-x
      (
        <stableswap-pool-trait>
        <ft>
        <ft>
        uint
        uint
      )
      (response uint uint)
    )
  )
)

;;-------------------------------------
;; XYK Core Trait
;;-------------------------------------

(define-trait xyk-core-trait
  (
    ;;-------------------------------------
    ;; XYK Swap Functions
    ;;-------------------------------------

    ;; @desc - Swap x token for y token via an XYK pool
    ;; @param - pool-trait: XYK pool trait for the trading pool
    ;; @param - x-token-trait: SIP-010 trait of the input token
    ;; @param - y-token-trait: SIP-010 trait of the output token
    ;; @param - x-amount: amount of x tokens to swap
    ;; @param - min-dy: minimum amount of y tokens to receive
    ;; @return - (ok uint) amount of y tokens received on success, (err uint) on failure
    (swap-x-for-y
      (
        <xyk-pool-trait>
        <ft>
        <ft>
        uint
        uint
      )
      (response uint uint)
    )

    ;; @desc - Swap y token for x token via an XYK pool
    ;; @param - pool-trait: XYK pool trait for the trading pool
    ;; @param - x-token-trait: SIP-010 trait of the output token
    ;; @param - y-token-trait: SIP-010 trait of the input token
    ;; @param - y-amount: amount of y tokens to swap
    ;; @param - min-dx: minimum amount of x tokens to receive
    ;; @return - (ok uint) amount of x tokens received on success, (err uint) on failure
    (swap-y-for-x
      (
        <xyk-pool-trait>
        <ft>
        <ft>
        uint
        uint
      )
      (response uint uint)
    )
  )
)

;;-------------------------------------
;; Bitflow Helper Trait
;;-------------------------------------

(define-trait swap-helper-trait
  (
    ;;-------------------------------------
    ;; Multi-Pool Swap Helper Functions
    ;;-------------------------------------

    ;; @desc - Swap via 1 XYK pool with aggregator fees
    ;; @param - amount: amount of input tokens to swap
    ;; @param - min-received: minimum amount of output tokens to receive
    ;; @param - provider: optional provider address for fee collection
    ;; @param - xyk-tokens: tuple containing (a b) token traits for the swap path
    ;; @param - xyk-pools: tuple containing (a) pool trait for the swap
    ;; @return - (ok uint) amount of output tokens received on success, (err uint) on failure
    (swap-helper-a
      (
        uint
        uint
        (optional principal)
        (tuple (a <ft>) (b <ft>))
        (tuple (a <xyk-pool-trait>))
      )
      (response uint uint)
    )

    ;; @desc - Swap via 2 XYK pools with aggregator fees
    ;; @param - amount: amount of input tokens to swap
    ;; @param - min-received: minimum amount of output tokens to receive
    ;; @param - provider: optional provider address for fee collection
    ;; @param - xyk-tokens: tuple containing (a b c d) token traits for the swap path
    ;; @param - xyk-pools: tuple containing (a b) pool traits for the swaps
    ;; @return - (ok uint) amount of output tokens received on success, (err uint) on failure
    (swap-helper-b
      (
        uint
        uint
        (optional principal)
        (tuple (a <ft>) (b <ft>) (c <ft>) (d <ft>))
        (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>))
      )
      (response uint uint)
    )
  )
)