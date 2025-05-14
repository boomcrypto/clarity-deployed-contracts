---
title: "Trait incentives"
draft: true
---
```
(use-trait ft .ft-trait.ft-trait)
(define-constant err-not-found (err u8000000))
(define-constant ERR_UNAUTHORIZED (err u8000001))

(define-constant one u100000000)

(define-read-only (get-asset-data (asset <ft>))
    (contract-call? .pool-0-reserve-v2-0 get-reserve-state (contract-of asset)))

(define-read-only (get-price (asset <ft>))
    (contract-call? .rewards-data get-price-read (contract-of asset)))

(define-read-only (get-reward-program-income (supplied-asset <ft>) (reward-asset <ft>))
    (contract-call? .rewards-data get-reward-program-income-read (contract-of supplied-asset) (contract-of reward-asset)))

(define-read-only (get-user-program-index (who principal) (asset <ft>) (reward-asset <ft>))
    (contract-call? .rewards-data get-user-program-index-read who (contract-of asset) (contract-of reward-asset)))

(define-read-only (get-precision (asset <ft>))
    (contract-call? .rewards-data get-asset-precision-read (contract-of asset)))

(define-public (initialize-reward-program-data (supplied-asset <ft>) (reward-asset <ft>))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
        (set-reward-program-income supplied-asset reward-asset {
            last-updated-block: stacks-block-height,
            last-liquidity-cumulative-index: one,
            liquidity-rate: u0
        })
    )
)

(define-private (set-reward-program-income (supplied-asset <ft>) (reward-asset <ft>) (new-income {
    last-updated-block: uint,
    last-liquidity-cumulative-index: uint,
    liquidity-rate: uint
}))
    (begin
        (contract-call? .rewards-data set-reward-program-income
            (contract-of supplied-asset)
            (contract-of reward-asset)
            new-income
        )
    )
)

(define-public (set-price (asset <ft>) (new-price uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
        (try!
            (contract-call? .rewards-data set-price
                (contract-of asset)
                new-price
            )
        )
        (ok true)
    )
)

(define-public (set-precision (asset <ft>) (precision uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
        (try!
            (contract-call? .rewards-data set-asset-precision
                (contract-of asset)
                precision
            )
        )
        (ok true)
    )
)

(define-public (set-liquidity-rate (supplied-asset <ft>) (reward-asset <ft>) (rate uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
        (set-reward-program-income supplied-asset reward-asset
            (merge
                (unwrap! (get-reward-program-income supplied-asset reward-asset) err-not-found)
                { liquidity-rate: rate }
            )
        )
    )
)

(define-private (set-user-program-index (who principal) (supplied-asset <ft>) (reward-asset <ft>) (new-user-index uint))
    (contract-call? .rewards-data set-user-program-index who (contract-of supplied-asset) (contract-of reward-asset) new-user-index)
)

(define-public (withdraw-assets (asset <ft>) (amount uint) (who principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
        (as-contract (contract-call? asset transfer amount tx-sender who none)))
)

(define-private (send-rewards (who principal) (reward-asset <ft>) (amount uint))
    (as-contract (contract-call? reward-asset transfer amount tx-sender who none)))

;; can only claim 1 type of reward
(define-public (claim-rewards
    (lp-supplied-asset <ft>)
    (supplied-asset <ft>)
    (who principal)
)
    (begin
        (try! (is-approved-contract contract-caller))
        (if (is-eq (contract-of supplied-asset) 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)
            (begin
                (try!
                    (claim-rewards-priv lp-supplied-asset
                        'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
                        'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.wstx
                        who
                    )
                )
            )
            ;; next check
            false
        )
        (ok true)
    )
)

(define-private (claim-rewards-priv
    (lp-supplied-asset <ft>)
    (supplied-asset <ft>)
    (reward-asset <ft>)
    (who principal)
    )
    (begin
        (try! (update-cumulative-index supplied-asset reward-asset))
        (let (
            ;; gets with interest
            (reward-balance (try! (convert-to supplied-asset reward-asset (try! (contract-call? lp-supplied-asset get-balance who)))))
            (reward-decimals (unwrap! (get-precision reward-asset) err-not-found))
            (reward-program-income-state (unwrap! (get-reward-program-income supplied-asset reward-asset) err-not-found))
            )
            ;; get increase in rewards
            (let (
                (cumulated-balance (try!
                    (calculate-cumulated-balance
                        who
                        lp-supplied-asset
                        supplied-asset
                        reward-asset
                        reward-balance
                        reward-decimals)))
                (balance-increase (- cumulated-balance reward-balance))
                (new-user-index (get-normalized-income
                    (get liquidity-rate reward-program-income-state)
                    (get last-updated-block reward-program-income-state)
                    (get last-liquidity-cumulative-index reward-program-income-state))))
                ;; update income of the rewarded asset to latest
                (try! (set-user-program-index who supplied-asset reward-asset new-user-index))
                (if (> balance-increase u0)
                    (begin
                        (try! (send-rewards who reward-asset balance-increase))
                        (ok true)
                    )
                    ;; do nothing
                    (ok true)
                )
            )
        )
    )
)

;; get the user's last registered liquidity index,
(define-private (get-user-program-index-eval
    (who principal)
    (lp-supplied-asset <ft>)
    (supplied-asset <ft>)
    (reward-asset <ft>)
    )
    (match (get-user-program-index who supplied-asset reward-asset)
        index (ok index)
        (let ((balance (try! (contract-call? lp-supplied-asset get-balance who))))
            (if (> balance u0)
                ;; if had a balance already, receive all income
                (ok one)
                ;; if had no balance, receive the asset's last liquidity index
                (ok (get last-liquidity-cumulative-index (unwrap! (get-reward-program-income supplied-asset reward-asset) err-not-found)))
            )
        )
    )
)

(define-read-only (get-apy
    (supplied-asset <ft>)
    (reward-asset <ft>)
    )
    (let (
        (reward-program-income-state (unwrap! (get-reward-program-income supplied-asset reward-asset) err-not-found))
        (liquidity-rate (get liquidity-rate reward-program-income-state))
    )
    (ok {
        liquidity-rate: liquidity-rate,
        apy-in-reward-asset: (+ one (try! (convert-to supplied-asset reward-asset (- liquidity-rate one))))
        })
    ) 
)

(define-read-only (convert-to
    (from <ft>)
    (to <ft>)
    (from-amount uint))
    (let (
        (from-precision (unwrap! (get-precision from) err-not-found))
        (to-precision (unwrap! (get-precision to) err-not-found))
        (from-price (unwrap! (get-price from) err-not-found))
        (to-price (unwrap! (get-price to) err-not-found))
        (to-amount (get-y-from-x
            from-amount
            from-precision
            to-precision
            from-price
            to-price
        ))
    )
    (ok to-amount)
    )
)

(define-private (calculate-cumulated-balance
  (who principal)
  (lp-supplied-asset <ft>)
  (supplied-asset <ft>)
  (reward-asset <ft>)
  (asset-balance uint)
  (asset-decimals uint))
  (let (
    (rewarded-reserve-data (unwrap! (get-reward-program-income supplied-asset reward-asset) err-not-found))
    (reserve-normalized-income
      (get-normalized-income
        (get liquidity-rate rewarded-reserve-data)
        (get last-updated-block rewarded-reserve-data)
        (get last-liquidity-cumulative-index rewarded-reserve-data))))
      (ok 
        (mul-precision-with-factor
          asset-balance
          asset-decimals
          (div
            reserve-normalized-income
            (unwrap! (get-user-program-index-eval who lp-supplied-asset supplied-asset reward-asset) err-not-found)))
      )
  )
)

(define-private (update-cumulative-index (supplied-asset <ft>) (reward-asset <ft>))
    (let (
        (asset-state (unwrap! (get-reward-program-income supplied-asset reward-asset) err-not-found))
        (cumulated-liquidity-interest
            (calculate-linear-interest
                (get liquidity-rate asset-state)
                (- stacks-block-height (get last-updated-block asset-state))
            )
        )
        (new-last-liquidity-cumulative-index
            (mul
                cumulated-liquidity-interest
                (get last-liquidity-cumulative-index asset-state)
            )
        )
    )
        (unwrap-panic (set-reward-program-income supplied-asset reward-asset {
            last-updated-block: stacks-block-height,
            last-liquidity-cumulative-index: new-last-liquidity-cumulative-index,
            liquidity-rate: (get liquidity-rate asset-state)
        }))
        (ok cumulated-liquidity-interest)
    )
)

(define-private (get-normalized-income
    (current-liquidity-rate uint)
    (last-updated-block uint)
    (last-liquidity-cumulative-index uint))
    (begin
        (contract-call? .pool-0-reserve-v2-0 get-normalized-income
            current-liquidity-rate
            last-updated-block
            last-liquidity-cumulative-index
        )
    )
)

(define-read-only (calculate-linear-interest (rate uint) (time uint))
    (contract-call? .pool-0-reserve-v2-0 calculate-linear-interest rate time))

(define-data-var contract-owner principal tx-sender)
(define-public (set-contract-owner (owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (print { type: "set-contract-owner", payload: owner })
    (ok (var-set contract-owner owner))))

(define-public (get-contract-owner)
  (ok (var-get contract-owner)))
(define-read-only (get-contract-owner-read)
  (var-get contract-owner))

(define-read-only (is-contract-owner (caller principal))
  (is-eq caller (var-get contract-owner)))


;; for helper interface
(define-map approved-contracts principal bool)

(define-public (set-approved-contract (contract principal) (enabled bool))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR_UNAUTHORIZED)
    (ok (map-set approved-contracts contract enabled))
  )
)

(define-read-only (is-approved-contract (contract principal))
  (if (default-to false (map-get? approved-contracts contract))
    (ok true)
    ERR_UNAUTHORIZED))


;; math
(define-read-only (get-y-from-x
  (x uint)
  (x-decimals uint)
  (y-decimals uint)
  (x-price uint)
  (y-price uint))
  (contract-call? .math-v2-0 get-y-from-x x x-decimals y-decimals x-price y-price))

(define-read-only (mul (x uint) (y uint)) (contract-call? .math-v2-0 mul x y))
(define-read-only (div (x uint) (y uint)) (contract-call? .math-v2-0 div x y))
(define-read-only (mul-precision-with-factor (a uint) (decimals-a uint) (b-fixed uint))
  (contract-call? .math-v2-0 mul-precision-with-factor a decimals-a b-fixed))

```
