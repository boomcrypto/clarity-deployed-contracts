

(define-read-only (get-vault-redeem-data
    (owner principal)
    (debt-payoff uint)
)
    (let (
        (vault 
            (unwrap-panic
                (contract-call?
                    'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-vaults-data-v1-1
                    get-vault 
                    owner
                    'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wstx-token
                )
            )
        )
        (collateral-info 
            (unwrap-panic 
                (contract-call? 
                    'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-vaults-tokens-v1-1
                    get-token
                    'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wstx-token
                )
            )
        )
        (collateral-price 
            (contract-call?
                'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-oracle-v2-3
                get-price
                (get token-name collateral-info)
            )
        )
        (collateral-value (/ (* (get collateral vault) (get last-price collateral-price)) (get decimals collateral-price)))
        (stability-fee (/ (* (/ (* (get stability-fee collateral-info) (get debt vault)) u10000) (- burn-block-height (get last-block vault))) (* u144 u365)))
        (debt-total (+ (get debt vault) stability-fee))
        (debt-payoff-used (if (>= debt-payoff debt-total) debt-total debt-payoff))
        (debt-left (if (>= debt-payoff debt-total) u0 (- debt-total debt-payoff)))
        (fee
            (let (
                (fee-info
                    (contract-call?
                        'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-vaults-manager-v1-1
                        get-redemption-block-last
                        'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wstx-token
                    )
                )
                (fee-diff (- (get redemption-fee-max collateral-info) (get redemption-fee-min collateral-info)))
                (block-diff (- burn-block-height (get block-last fee-info)))
                (fee-change (/ (* fee-diff block-diff) (get redemption-fee-block-interval collateral-info)))
                (current-fee (if (>= fee-change fee-diff)
                    (get redemption-fee-min collateral-info)
                    (- (get redemption-fee-max collateral-info) fee-change)
                ))
            )
                { current-fee: current-fee }
            )
        )
        (collateral-needed (/ (* (get collateral vault) debt-payoff-used) collateral-value))
        (collateral-fee (/ (* collateral-needed (get current-fee fee)) u10000))
        (collateral-received (- collateral-needed collateral-fee))
        (collateral-left (- (get collateral vault) collateral-needed))
    )
        (ok {
            collateral-needed: collateral-needed,
            collateral-fee: collateral-fee,
            collateral-received: collateral-received,
            collateral-left: collateral-left,
        })
    )
)