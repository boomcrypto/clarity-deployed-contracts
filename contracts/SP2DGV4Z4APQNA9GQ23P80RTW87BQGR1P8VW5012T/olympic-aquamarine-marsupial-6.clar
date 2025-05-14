(use-trait ft 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.ft-trait.ft-trait)
(use-trait ft-mint-trait 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.ft-mint-trait.ft-mint-trait)
(use-trait a-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.a-token-trait.a-token-trait)
(use-trait flash-loan 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.flash-loan-trait.flash-loan-trait)
(use-trait oracle-trait 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.oracle-trait.oracle-trait)
(use-trait redeemeable-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.redeemeable-trait-v1-2.redeemeable-trait)
(use-trait incentives-trait 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.incentives-trait-v2-1.incentives-trait)

(define-constant ERR_UNAUTHORIZED (err u1000000000000))
(define-constant ERR_REWARDS_CONTRACT (err u1000000000001))
(define-constant ERR_NO_REWARDS (err u1000000000003))

(define-constant max-value u340282366920938463463374607431768211455)

(define-read-only (is-rewards-contract (contract principal))
  (is-eq contract (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.rewards-data get-rewards-contract-read)))

(define-public (supply
  (lp <redeemeable-token>)
  (pool-reserve principal)
  (asset <ft>)
  (amount uint)
  (owner principal)
  (referral (optional principal))
  (incentives <incentives-trait>)
  )
  (let ((asset-principal (contract-of asset)))

    (asserts! (is-eq tx-sender contract-caller) ERR_UNAUTHORIZED)
    (asserts! (is-rewards-contract (contract-of incentives)) ERR_REWARDS_CONTRACT)
    (try! (contract-call? incentives claim-rewards-to-vault lp asset owner))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-1 supply lp pool-reserve asset amount owner))

    (print { type: "supply-call", payload: { key: owner, data: {
      reserve-state: (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-reserve-state asset-principal)),
      user-reserve-state: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-reserve-data owner asset-principal),
      user-index: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-index owner asset-principal),
      user-assets: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-assets owner),
      asset: asset,
      amount: amount,
      new-balance: (try! (contract-call? lp get-balance owner)),
      referral: referral,
    }}})
    (ok true)
  )
)

(define-public (supply-all
  (ststx-amount uint)
  (aeusdc-amount uint)
  (wstx-amount uint)
  (diko-amount uint)
  (usdh-amount uint)
  (susdt-amount uint)
  (usda-amount uint)
  (sbtc-amount uint)
  (ststxbtc-amount uint)
  (alex-amount uint)
  (pool-reserve principal)
  (owner principal)
  (referral (optional principal))
  (incentives <incentives-trait>)
  )
  (begin
    (asserts! (is-eq tx-sender contract-caller) ERR_UNAUTHORIZED)

    (if (> ststx-amount u0)
      (begin
        (try! (supply
          'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-v2-0
          pool-reserve
          'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
          ststx-amount
          owner
          referral
          incentives
          ))
      )
      false
    )

    (if (> aeusdc-amount u0)
      (begin
        (try! (supply
          'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zaeusdc-v2-0
          pool-reserve
          'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
          aeusdc-amount
          owner
          referral
          incentives
          ))
      )
      false
    )

    (if (> wstx-amount u0)
      (begin
        (try! (supply
          'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zwstx-v2-0
          pool-reserve
          'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.wstx
          wstx-amount
          owner
          referral
          incentives
          ))
      )
      false
    )

    (if (> diko-amount u0)
      (begin
        (try! (supply
          'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zdiko-v2-0
          pool-reserve
          'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
          diko-amount
          owner
          referral
          incentives
          ))
      )
      false
    )

    (if (> usdh-amount u0)
      (begin
        (try! (supply
          'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusdh-v2-0
          pool-reserve
          'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1
          usdh-amount
          owner
          referral
          incentives
          ))
      )
      false
    )

    (if (> susdt-amount u0)
      (begin
        (try! (supply
          'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsusdt-v2-0
          pool-reserve
          'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt
          susdt-amount
          owner
          referral
          incentives
          ))
      )
      false
    )

    (if (> usda-amount u0)
      (begin
        (try! (supply
          'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusda-v2-0
          pool-reserve
          'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
          usda-amount
          owner
          referral
          incentives
          ))
      )
      false
    )

    (if (> sbtc-amount u0)
      (begin
        (try! (supply
          'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsbtc-v2-0
          pool-reserve
          'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
          sbtc-amount
          owner
          referral
          incentives
          ))
      )
      false
    )

    ;; (if (> ststxbtc-amount u0)
    ;;   (begin
    ;;     (try! (supply
    ;;       'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststxbtc-v2-0
    ;;       pool-reserve
    ;;       'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token
    ;;       ststxbtc-amount
    ;;       owner
    ;;       referral
    ;;       incentives
    ;;       ))
    ;;   )
    ;;   false
    ;; )

    ;; (if (> alex-amount u0)
    ;;   (begin
    ;;     (try! (supply
    ;;       'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zalex-v2-0
    ;;       pool-reserve
    ;;       'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
    ;;       alex-amount
    ;;       owner
    ;;       referral
    ;;       incentives
    ;;       ))
    ;;   )
    ;;   false
    ;; )

    (ok true)
  )
)

(define-public (borrow
  (pool-reserve principal)
  (oracle <oracle-trait>)
  (asset-to-borrow <ft>)
  (lp <ft>)
  (assets (list 100 { asset: <ft>, lp-token: <ft>, oracle: <oracle-trait> }))
  (amount-to-be-borrowed uint)
  (fee-calculator principal)
  (interest-rate-mode uint)
  (owner principal)
  (price-feed-bytes (optional (buff 8192)))
  )
  (let ((asset-principal (contract-of asset-to-borrow)))

    (asserts! (is-eq tx-sender contract-caller) ERR_UNAUTHORIZED)
    (try! (write-feed price-feed-bytes))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-1 borrow pool-reserve oracle asset-to-borrow lp assets amount-to-be-borrowed fee-calculator interest-rate-mode owner))

    (print { type: "borrow-call", payload: { key: owner, data: {
        reserve-state: (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-reserve-state asset-principal)),
        user-reserve-state: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-reserve-data owner asset-principal),
        user-index: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-index owner asset-principal),
        user-assets: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-assets owner),
        asset: asset-to-borrow,
        amount: amount-to-be-borrowed,
        new-borrow-balance: (get compounded-balance (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-borrow-balance owner asset-to-borrow))),
      }}})
    (ok true)
  )
)

(define-public (repay
  (asset <ft>)
  (amount-to-repay uint)
  (on-behalf-of principal)
  (payer principal)
  )
  (let (
    (asset-principal (contract-of asset))
    (check-ok (asserts! (is-eq tx-sender contract-caller) ERR_UNAUTHORIZED))
    (payback-amount (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-1 repay asset amount-to-repay on-behalf-of payer)))
    )

    (print { type: "repay-call", payload: { key: on-behalf-of, data: {
        reserve-state: (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-reserve-state asset-principal)),
        user-reserve-state: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-reserve-data on-behalf-of asset-principal),
        user-index: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-index on-behalf-of asset-principal),
        user-assets: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-assets on-behalf-of),
        asset: asset,
        amount: payback-amount,
        on-behalf-of: on-behalf-of,
        payer: payer,
        new-borrow-balance: (get compounded-balance (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-borrow-balance on-behalf-of asset))),
      }}})
    (ok true)
  )
)

(define-public (set-user-use-reserve-as-collateral
  (who principal)
  (lp-token <ft>)
  (asset <ft>)
  (enable-as-collateral bool)
  (oracle <oracle-trait>)
  (assets-to-calculate (list 100 { asset: <ft>, lp-token: <ft>, oracle: <oracle-trait> }))
  (price-feed-bytes (optional (buff 8192)))
  )
  (let (
    (asset-principal (contract-of asset))
    (reserve-state (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-reserve-state asset-principal)))
    )

    (asserts! (is-eq tx-sender contract-caller) ERR_UNAUTHORIZED)
    (try! (write-feed price-feed-bytes))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-1 set-user-use-reserve-as-collateral who lp-token asset enable-as-collateral oracle assets-to-calculate))

    (print { type: "set-user-use-reserve-as-collateral-call", payload: { key: who, data: {
        reserve-state: (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-reserve-state asset-principal)),
        user-reserve-state: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-reserve-data who asset-principal),
        user-index: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-index who asset-principal),
        user-assets: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-assets who),
        asset: asset,
      }}})
    (ok true)
  )
)

(define-public (withdraw
  (lp <redeemeable-token>)
  (pool-reserve principal)
  (asset <ft>)
  (oracle <oracle-trait>)
  (amount uint)
  (owner principal)
  (assets (list 100 { asset: <ft>, lp-token: <ft-mint-trait>, oracle: <oracle-trait> }))
  (incentives <incentives-trait>)
  (price-feed-bytes (optional (buff 8192)))
  )
  (let (
    (asset-principal (contract-of asset))
    (check-ok (asserts! (is-eq tx-sender contract-caller) ERR_UNAUTHORIZED))
    (check-on-rewards (asserts! (is-rewards-contract (contract-of incentives)) ERR_REWARDS_CONTRACT))
    (price-ok (try! (write-feed price-feed-bytes)))
    (result-claim (try! (contract-call? incentives claim-rewards-to-vault lp asset owner)))
    (withdraw-res (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-1 withdraw pool-reserve asset lp oracle assets amount owner)))
    )

    (print { type: "withdraw-call", payload: { key: owner, data: {
        reserve-state: (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-reserve-state asset-principal)),
        user-reserve-state: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-reserve-data owner asset-principal),
        user-index: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-index owner asset-principal),
        user-assets: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-assets owner),
        asset: asset,
        withdrawn-amount: withdraw-res,
        balance: (try! (contract-call? lp get-balance owner)),
      }}})
    (ok true)
  )
)


(define-public (claim-rewards
  (lp <redeemeable-token>)
  (pool-reserve principal)
  (asset <ft>)
  (oracle <oracle-trait>)
  (owner principal)
  (assets (list 100 { asset: <ft>, lp-token: <ft-mint-trait>, oracle: <oracle-trait> }))
  (reward-asset <ft>)
  (incentives <incentives-trait>)
  (price-feed-bytes (optional (buff 8192)))
  )
  (begin
    (asserts! (is-eq tx-sender contract-caller) ERR_UNAUTHORIZED)
    (asserts! (is-rewards-contract (contract-of incentives)) ERR_REWARDS_CONTRACT)

    (asserts! (> (try! (contract-call? incentives claim-rewards lp asset owner)) u0) ERR_NO_REWARDS)

    (ok true)
  )
)

(define-public (liquidation-call
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
    (debt-asset-principal (contract-of debt-asset))
    (collateral-asset-principal (contract-of collateral-to-liquidate))
    (liquidator tx-sender)
    )

    (asserts! (is-eq liquidator contract-caller) ERR_UNAUTHORIZED)
    (try! (write-feed price-feed-bytes))

    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-1 liquidation-call
      assets
      collateral-lp
      collateral-to-liquidate
      debt-asset
      collateral-oracle
      debt-oracle
      liquidated-user
      debt-amount
      to-receive-atoken)
    )
    (print { type: "liquidation-call", payload: { key: liquidated-user, data: {
        debt-reserve-state: (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-reserve-state debt-asset-principal)),
        collateral-reserve-state: (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-reserve-state debt-asset-principal)),
        
        liquidator-debt-reserve-state: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-reserve-data liquidator debt-asset-principal),
        liquidator-debt-index: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-index liquidator debt-asset-principal),
        liquidator-collateral-reserve-state: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-reserve-data liquidator collateral-asset-principal),
        liquidator-collateral-index: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-index liquidator collateral-asset-principal),
        liquidator-user-assets: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-assets liquidator),

        liquidated-user-debt-reserve-state: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-reserve-data liquidated-user debt-asset-principal),
        liquidated-user-debt-index: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-index liquidated-user debt-asset-principal),
        liquidated-user-collateral-reserve-state: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-reserve-data liquidated-user collateral-asset-principal),
        liquidated-user-collateral-index: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-index liquidated-user collateral-asset-principal),
        liquidated-user-assets: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-user-assets liquidated-user),

        collateral-to-liquidate: collateral-to-liquidate,
        debt-asset: debt-asset-principal,
        debt-amount: debt-amount,
      }}})
    (ok u0)
  )
)

(define-public (set-e-mode
  (user principal)
  (assets (list 100 { asset: <ft>, lp-token: <ft>, oracle: <oracle-trait> }))
  (new-e-mode-type (buff 1))
  (price-feed-bytes (optional (buff 8192)))
  )
  (begin
    (asserts! (is-eq tx-sender contract-caller) ERR_UNAUTHORIZED)
    (try! (write-feed price-feed-bytes))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-1 set-e-mode user assets new-e-mode-type))

    (print { type: "set-e-mode-call", payload: { key: user, data: {
        user-e-mode: (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data-2 get-user-e-mode-read user),
      }}})
    (ok true)
  )
)

(define-public (flashloan
  (receiver principal)
  (asset <ft>)
  (amount uint)
  (flashloan-script <flash-loan>))
  (begin
    (asserts! (is-eq tx-sender contract-caller) ERR_UNAUTHORIZED)

    (try! 
      (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-1 flashloan
        receiver
        asset
        amount
        flashloan-script))

    (print { type: "flashloan-call", payload: { key: receiver, data: {
      reserve-state: (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 get-reserve-state (contract-of asset))),
    }}})
    (ok u0)
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
