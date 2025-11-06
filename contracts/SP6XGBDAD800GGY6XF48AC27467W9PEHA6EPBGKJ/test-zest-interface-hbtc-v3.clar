;; @contract Zest Interface
;; @version 0.1

(use-trait borrow-helper .test-zest-borrow-helper-trait-v1.zest-borrow-helper-trait)

(use-trait ft 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.ft-trait.ft-trait)
(use-trait ft-mint 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.ft-mint-trait.ft-mint-trait)
(use-trait oracle 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.oracle-trait.oracle-trait)
(use-trait redeemable-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.redeemeable-trait-v1-2.redeemeable-trait)
(use-trait incentives 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.incentives-trait-v2-1.incentives-trait)

(define-constant ERR_INVALID_AMOUNT (err u111001))
(define-constant ERR_INSUFFICIENT_BALANCE (err u111002))

(define-constant this-contract (as-contract tx-sender))
(define-constant reserve .test-reserve-hbtc-v3)

;;-------------------------------------
;; Trader
;;-------------------------------------

(define-public (zest-supply
  (borrow-helper-trait <borrow-helper>)
  (lp-trait <redeemable-token>)
  (pool-reserve principal)
  (asset-trait <ft>)
  (amount uint) 
  (referral (optional principal))
  (incentives-trait <incentives>)) 
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v3 check-trading-auth (contract-of borrow-helper-trait) none (some (contract-of asset-trait)) none))
    (try! (contract-call? .test-reserve-hbtc-v3 transfer asset-trait amount this-contract))
    (try! (as-contract (contract-call? borrow-helper-trait supply lp-trait pool-reserve asset-trait amount this-contract referral incentives-trait)))
    (print { action: "zest-supply", user: contract-caller, data: { borrow-helper: borrow-helper-trait, asset: asset-trait, amount: amount, referral: referral } })
    (ok true)
  )
)

(define-public (zest-withdraw
  (borrow-helper-trait <borrow-helper>)
  (lp-trait <redeemable-token>)
  (pool-reserve principal)
  (asset-trait <ft>)
  (oracle-trait <oracle>)
  (amount uint)
  (assets (list 100 { asset: <ft>, lp-token: <ft-mint>, oracle: <oracle> }))
  (incentives-trait <incentives>)
  (price-feed-1 (optional (buff 8192)))
  (price-feed-2 (optional (buff 8192))))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v3 check-trading-auth (contract-of borrow-helper-trait) none (some (contract-of asset-trait)) none))
    (try! (write-feed price-feed-1))
    (try! (write-feed price-feed-2))
    (try! (as-contract (contract-call? borrow-helper-trait withdraw lp-trait pool-reserve asset-trait oracle-trait amount this-contract assets incentives-trait none)))
    (try! (as-contract (contract-call? asset-trait transfer amount this-contract reserve none)))
    (print { action: "zest-withdraw", user: contract-caller, data: { borrow-helper: borrow-helper-trait, asset: asset-trait, amount: amount } })
    (ok true)
  )
)

(define-public (zest-borrow
  (borrow-helper-trait <borrow-helper>)
  (pool-reserve principal)
  (oracle-trait <oracle>)
  (asset-to-borrow-trait <ft>)
  (lp-trait <ft>)
  (assets (list 100 { asset: <ft>, lp-token: <ft-mint>, oracle: <oracle> }))
  (amount-to-be-borrowed uint)
  (fee-calculator principal)
  (interest-rate-mode uint)
  (price-feed-1 (optional (buff 8192)))
  (price-feed-2 (optional (buff 8192))))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v3 check-trading-auth (contract-of borrow-helper-trait) none (some (contract-of asset-to-borrow-trait)) none))
    (try! (write-feed price-feed-1))
    (try! (write-feed price-feed-2))
    (try! (as-contract (contract-call? borrow-helper-trait borrow pool-reserve oracle-trait asset-to-borrow-trait lp-trait assets amount-to-be-borrowed fee-calculator interest-rate-mode this-contract none)))
    (try! (as-contract (contract-call? asset-to-borrow-trait transfer amount-to-be-borrowed this-contract reserve none)))
    (print { action: "zest-borrow", user: contract-caller, data: { borrow-helper: borrow-helper-trait, asset-to-borrow: asset-to-borrow-trait, amount-to-be-borrowed: amount-to-be-borrowed, interest-rate-mode: interest-rate-mode } })
    (ok true)
  )
)

(define-public (zest-repay
  (borrow-helper-trait <borrow-helper>)
  (asset-trait <ft>) 
  (amount-to-repay uint) 
  (payer principal))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v3 check-trading-auth (contract-of borrow-helper-trait) none (some (contract-of asset-trait)) none))
    (try! (contract-call? .test-reserve-hbtc-v3 transfer asset-trait amount-to-repay this-contract))
    (try! (as-contract (contract-call? borrow-helper-trait repay asset-trait amount-to-repay this-contract payer)))
    (print { action: "zest-repay", user: contract-caller, data: { borrow-helper: borrow-helper-trait, asset: asset-trait, amount-to-repay: amount-to-repay, payer: payer } })
    (ok true)
  )
)

;; claims STX incentives paid out by Zest
(define-public (zest-claim-rewards
  (borrow-helper-trait <borrow-helper>)
  (lp-trait <redeemable-token>)
  (pool-reserve principal)
  (asset-trait <ft>)
  (oracle-trait <oracle>)
  (assets (list 100 { asset: <ft>, lp-token: <ft-mint>, oracle: <oracle> }))
  (reward-asset-trait <ft>)
  (incentives-trait <incentives>)
  (price-feed-1 (optional (buff 8192)))
  (price-feed-2 (optional (buff 8192))))
  (let (
    (balance-before (unwrap-panic (contract-call? reward-asset-trait get-balance this-contract)))
  )
    (try! (contract-call? .test-hq-vaults-v3 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v3 check-trading-auth (contract-of borrow-helper-trait) none (some (contract-of asset-trait)) (some (contract-of reward-asset-trait))))
    (try! (write-feed price-feed-1))
    (try! (write-feed price-feed-2))
    (try! (as-contract (contract-call? borrow-helper-trait claim-rewards lp-trait pool-reserve asset-trait oracle-trait this-contract assets reward-asset-trait incentives-trait none)))
    (let (
      (balance-after (unwrap-panic (contract-call? reward-asset-trait get-balance this-contract)))
      (reward-balance (- balance-after balance-before)))

      (try! (as-contract (contract-call? reward-asset-trait transfer reward-balance this-contract reserve none)))
      (print { action: "zest-claim-rewards", user: contract-caller, data: { borrow-helper: borrow-helper-trait, asset: asset-trait, reward-asset: reward-asset-trait, reward-balance: reward-balance } })
    )
    (ok true)
  )
)

;;-------------------------------------
;; Admin
;;-------------------------------------

;; @desc - sweeps any leftover tokens from interface contract to reserve
;; @param - asset-trait: the token to sweep
;; @param - amount: the amount to sweep
(define-public (sweep (asset-trait <ft>) (amount uint))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v3 check-is-asset (contract-of asset-trait)))
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (<= amount (unwrap-panic (contract-call? asset-trait get-balance this-contract))) ERR_INSUFFICIENT_BALANCE)
    (try! (as-contract (contract-call? asset-trait transfer amount this-contract reserve none)))
    (print { action: "sweep", user: contract-caller, data: { asset: asset-trait, amount: amount, sender: this-contract, recipient: reserve } })
    (ok amount)
  )
)

;;-------------------------------------
;; Helper
;;-------------------------------------

(define-private (write-feed (price-feed (optional (buff 8192))))
  (match price-feed bytes 
    (begin
      (try! (contract-call? 'SP1CGXWEAMG6P6FT04W66NVGJ7PQWMDAC19R7PJ0Y.pyth-oracle-v4 verify-and-update-price-feeds
        bytes
        {
          pyth-storage-contract: 'SP1CGXWEAMG6P6FT04W66NVGJ7PQWMDAC19R7PJ0Y.pyth-storage-v4,
          pyth-decoder-contract: 'SP1CGXWEAMG6P6FT04W66NVGJ7PQWMDAC19R7PJ0Y.pyth-pnau-decoder-v3,
          wormhole-core-contract: 'SP1CGXWEAMG6P6FT04W66NVGJ7PQWMDAC19R7PJ0Y.wormhole-core-v4,
        }
      ))
      (ok true)
    )
    ;; do nothing if none
    (ok true)
  )
)