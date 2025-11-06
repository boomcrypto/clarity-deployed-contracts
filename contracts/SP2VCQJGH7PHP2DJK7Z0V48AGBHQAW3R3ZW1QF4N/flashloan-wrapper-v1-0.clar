(use-trait ft .ft-trait.ft-trait)
(use-trait ft-mint-trait .ft-mint-trait.ft-mint-trait)
(use-trait a-token .a-token-trait.a-token-trait)
(use-trait flash-loan .flash-loan-trait.flash-loan-trait)
(use-trait oracle-trait .oracle-trait.oracle-trait)
(use-trait redeemeable-token .redeemeable-trait-v1-2.redeemeable-trait)

(define-constant ERR_UNAUTHORIZED (err u1000000000000))
(define-constant ERR_REWARDS_CONTRACT (err u1000000000001))
(define-constant ERR_NO_REWARDS (err u1000000000003))
(define-constant ERR_NOT_ENOUGH_FUNDS_RECEIVED (err u1000000000023))

(define-read-only (is-approved-sender (sender principal))
  (default-to false (contract-call? .flashloan-data get-approved-sender-read sender)))

(define-public (flashloan-liquidate
  (receiver principal)
  (asset <ft>)
  (amount uint)
  (flashloan-script <flash-loan>)
  (assets (list 100 { asset: <ft>, lp-token: <ft>, oracle: <oracle-trait> }))
  (collateral-lp <a-token>)
  (collateral-to-liquidate <ft>)
  (debt-asset <ft>)
  (collateral-oracle <oracle-trait>)
  (debt-oracle <oracle-trait>)
  (liquidated-user principal)
  (debt-amount uint)
  (to-receive-atoken bool)
  (price-feed-bytes (optional (buff 8192)))
  )
  (let (
    (is-approved-ok (asserts! (is-approved-sender tx-sender) ERR_UNAUTHORIZED))
    (balance-before (try! (contract-call? asset get-balance receiver)))
  )

    (try! (write-feed price-feed-bytes))
    (try!
      (contract-call? .pool-borrow-v2-2 flashloan-liquidation-step-1
        receiver
        asset
        amount
        flashloan-script))

    (match (contract-call? .pool-borrow-v2-2 liquidation-call
        assets
        collateral-lp
        collateral-to-liquidate
        debt-asset
        collateral-oracle
        debt-oracle
        liquidated-user
        debt-amount
        to-receive-atoken)
        liquidation-result
          (begin
            (try! (contract-call? flashloan-script execute
                asset
                receiver
                (get collateral-to-liquidator liquidation-result)))
            (asserts!
              (>= 
                (-
                  (try! (contract-call? asset get-balance receiver))
                  balance-before
                )
                (+ amount (try! (get-protocol-fees asset amount)))
              )
              ERR_NOT_ENOUGH_FUNDS_RECEIVED
            )
            (try!
              (contract-call? .pool-borrow-v2-2 flashloan-liquidation-step-2
                receiver
                asset
                amount
                flashloan-script))
            (print { type: "flashloan-call", payload: { key: receiver, data: {
              reserve-state: (try! (contract-call? .pool-0-reserve-v2-0 get-reserve-state (contract-of asset))) }}})
            (ok u0)
          )
        err-code (err err-code)
    )
  )
)


(define-read-only (get-protocol-fees (asset <ft>) (amount uint))
  (let (
    (total-fee-bps (try! (contract-call? .pool-0-reserve-v2-0 get-flashloan-fee-total (contract-of asset))))
    (protocol-fee-bps (try! (contract-call? .pool-0-reserve-v2-0 get-flashloan-fee-protocol (contract-of asset))))
    (amount-fee (/ (* amount total-fee-bps) u10000))
    (protocol-fee (/ (* amount-fee protocol-fee-bps) u10000))
    (reserve-data (try! (contract-call? .pool-0-reserve-v2-0 get-reserve-state (contract-of asset))))
  )
  (ok amount-fee)
  )
)

(define-private (write-feed (price-feed-bytes (optional (buff 8192))))
  (match price-feed-bytes
    bytes (begin
      (try! 
        (contract-call? 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-oracle-v3 verify-and-update-price-feeds
          bytes
          {
            pyth-storage-contract: 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-storage-v3,
            pyth-decoder-contract: 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-pnau-decoder-v2,
            wormhole-core-contract: 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.wormhole-core-v3,
          }
        )
      )
      (ok true)
    )
    (begin
      (print "no-feed-update")
      ;; do nothing if none
      (ok true)
    )
  )
)
