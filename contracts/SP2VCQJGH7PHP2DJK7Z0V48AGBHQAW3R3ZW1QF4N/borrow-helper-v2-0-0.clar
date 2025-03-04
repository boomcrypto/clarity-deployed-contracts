(use-trait ft .ft-trait.ft-trait)
(use-trait ft-mint-trait .ft-mint-trait.ft-mint-trait)
(use-trait a-token .a-token-trait.a-token-trait)
(use-trait flash-loan .flash-loan-trait.flash-loan-trait)
(use-trait oracle-trait .oracle-trait.oracle-trait)
(use-trait redeemeable-token .redeemeable-trait-v1-2.redeemeable-trait)


(define-constant ERR_UNAUTHORIZED (err u1000000000000))

(define-public (supply
  (lp <redeemeable-token>)
  (pool-reserve principal)
  (asset <ft>)
  (amount uint)
  (owner principal)
  (referral (optional principal)))
  (let ((asset-principal (contract-of asset)))

    (asserts! (is-eq tx-sender contract-caller) ERR_UNAUTHORIZED)
    (try! (contract-call? .pool-borrow-v2-0 supply lp pool-reserve asset amount owner))

    (print { type: "supply-call", payload: { key: owner, data: {
      reserve-state: (try! (contract-call? .pool-0-reserve-v2-0 get-reserve-state asset-principal)),
      user-reserve-state: (contract-call? .pool-0-reserve-v2-0 get-user-reserve-data owner asset-principal),
      user-index: (contract-call? .pool-0-reserve-v2-0 get-user-index owner asset-principal),
      user-assets: (contract-call? .pool-0-reserve-v2-0 get-user-assets owner),
      asset: asset,
      amount: amount,
      new-balance: (try! (contract-call? lp get-balance owner)),
      referral: referral,
    }}})
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
  (owner principal))
  (let ((asset-principal (contract-of asset-to-borrow)))

    (asserts! (is-eq tx-sender contract-caller) ERR_UNAUTHORIZED)
    (try! (contract-call? .pool-borrow-v2-0 borrow pool-reserve oracle asset-to-borrow lp assets amount-to-be-borrowed fee-calculator interest-rate-mode owner))

    (print { type: "borrow-call", payload: { key: owner, data: {
        reserve-state: (try! (contract-call? .pool-0-reserve-v2-0 get-reserve-state asset-principal)),
        user-reserve-state: (contract-call? .pool-0-reserve-v2-0 get-user-reserve-data owner asset-principal),
        user-index: (contract-call? .pool-0-reserve-v2-0 get-user-index owner asset-principal),
        user-assets: (contract-call? .pool-0-reserve-v2-0 get-user-assets owner),
        asset: asset-to-borrow,
        amount: amount-to-be-borrowed,
        new-borrow-balance: (get compounded-balance (try! (contract-call? .pool-0-reserve-v2-0 get-user-borrow-balance owner asset-to-borrow))),
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
    (payback-amount (try! (contract-call? .pool-borrow-v2-0 repay asset amount-to-repay on-behalf-of payer)))
    )

    (print { type: "repay-call", payload: { key: on-behalf-of, data: {
        reserve-state: (try! (contract-call? .pool-0-reserve-v2-0 get-reserve-state asset-principal)),
        user-reserve-state: (contract-call? .pool-0-reserve-v2-0 get-user-reserve-data on-behalf-of asset-principal),
        user-index: (contract-call? .pool-0-reserve-v2-0 get-user-index on-behalf-of asset-principal),
        user-assets: (contract-call? .pool-0-reserve-v2-0 get-user-assets on-behalf-of),
        asset: asset,
        amount: payback-amount,
        on-behalf-of: on-behalf-of,
        payer: payer,
        new-borrow-balance: (get compounded-balance (try! (contract-call? .pool-0-reserve-v2-0 get-user-borrow-balance on-behalf-of asset))),
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
  (assets-to-calculate (list 100 { asset: <ft>, lp-token: <ft>, oracle: <oracle-trait> })))
  (let (
    (asset-principal (contract-of asset))
    (reserve-state (try! (contract-call? .pool-0-reserve-v2-0 get-reserve-state asset-principal)))
    )

    (asserts! (is-eq tx-sender contract-caller) ERR_UNAUTHORIZED)
    (try! (contract-call? .pool-borrow-v2-0 set-user-use-reserve-as-collateral who lp-token asset enable-as-collateral oracle assets-to-calculate))

    (print { type: "set-user-use-reserve-as-collateral-call", payload: { key: who, data: {
        reserve-state: (try! (contract-call? .pool-0-reserve-v2-0 get-reserve-state asset-principal)),
        user-reserve-state: (contract-call? .pool-0-reserve-v2-0 get-user-reserve-data who asset-principal),
        user-index: (contract-call? .pool-0-reserve-v2-0 get-user-index who asset-principal),
        user-assets: (contract-call? .pool-0-reserve-v2-0 get-user-assets who),
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
  )
  (let (
    (asset-principal (contract-of asset))
    (check-ok (asserts! (is-eq tx-sender contract-caller) ERR_UNAUTHORIZED))
    (withdraw-res (try! (contract-call? .pool-borrow-v2-0 withdraw pool-reserve asset lp oracle assets amount owner)))
    )

    (print { type: "withdraw-call", payload: { key: owner, data: {
        reserve-state: (try! (contract-call? .pool-0-reserve-v2-0 get-reserve-state asset-principal)),
        user-reserve-state: (contract-call? .pool-0-reserve-v2-0 get-user-reserve-data owner asset-principal),
        user-index: (contract-call? .pool-0-reserve-v2-0 get-user-index owner asset-principal),
        user-assets: (contract-call? .pool-0-reserve-v2-0 get-user-assets owner),
        asset: asset,
        withdrawn-amount: withdraw-res,
        balance: (try! (contract-call? lp get-balance owner)),
      }}})
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
  (to-receive-atoken bool))
  (let (
    (debt-asset-principal (contract-of debt-asset))
    (collateral-asset-principal (contract-of collateral-to-liquidate))
    (liquidator tx-sender)
    )

    (asserts! (is-eq liquidator contract-caller) ERR_UNAUTHORIZED)

    (try! (contract-call? .pool-borrow-v2-0 liquidation-call
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
        debt-reserve-state: (try! (contract-call? .pool-0-reserve-v2-0 get-reserve-state debt-asset-principal)),
        collateral-reserve-state: (try! (contract-call? .pool-0-reserve-v2-0 get-reserve-state debt-asset-principal)),
        
        liquidator-debt-reserve-state: (contract-call? .pool-0-reserve-v2-0 get-user-reserve-data liquidator debt-asset-principal),
        liquidator-debt-index: (contract-call? .pool-0-reserve-v2-0 get-user-index liquidator debt-asset-principal),
        liquidator-collateral-reserve-state: (contract-call? .pool-0-reserve-v2-0 get-user-reserve-data liquidator collateral-asset-principal),
        liquidator-collateral-index: (contract-call? .pool-0-reserve-v2-0 get-user-index liquidator collateral-asset-principal),
        liquidator-user-assets: (contract-call? .pool-0-reserve-v2-0 get-user-assets liquidator),

        liquidated-user-debt-reserve-state: (contract-call? .pool-0-reserve-v2-0 get-user-reserve-data liquidated-user debt-asset-principal),
        liquidated-user-debt-index: (contract-call? .pool-0-reserve-v2-0 get-user-index liquidated-user debt-asset-principal),
        liquidated-user-collateral-reserve-state: (contract-call? .pool-0-reserve-v2-0 get-user-reserve-data liquidated-user collateral-asset-principal),
        liquidated-user-collateral-index: (contract-call? .pool-0-reserve-v2-0 get-user-index liquidated-user collateral-asset-principal),
        liquidated-user-assets: (contract-call? .pool-0-reserve-v2-0 get-user-assets liquidated-user),

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
  )
  (begin
    (asserts! (is-eq tx-sender contract-caller) ERR_UNAUTHORIZED)
    (try! (contract-call? .pool-borrow-v2-0 set-e-mode user assets new-e-mode-type))

    (print { type: "set-e-mode-call", payload: { key: user, data: {
        user-e-mode: (contract-call? .pool-reserve-data-2 get-user-e-mode-read user),
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
      (contract-call? .pool-borrow-v2-0 flashloan
        receiver
        asset
        amount
        flashloan-script))

    (print { type: "flashloan-call", payload: { key: receiver, data: {
      reserve-state: (try! (contract-call? .pool-0-reserve-v2-0 get-reserve-state (contract-of asset))),
    }}})
    (ok u0)
  )
)
