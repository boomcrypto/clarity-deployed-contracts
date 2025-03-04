(define-public (get-pupb-v1 (h uint))
    (ok (try! (get-upb-v1 h)))
)

(define-public (get-pupb-v2 (h uint))
    (ok (try! (get-upb-v2 h)))
)

(define-read-only (get-upb-v1 (h uint))
    (let
        (
            (id (unwrap! (get-stacks-block-info? id-header-hash h) (err u100)))
        )
        (at-block id
            (let
                (
                    (usd-per-stx (unwrap!
                        (contract-call?
                            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01
                            get-price
                            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
                            'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt
                            u100000000
                        )
                        (err u101)
                    ))
                    (btc-per-stx (unwrap!
                        (contract-call?
                            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01
                            get-price
                            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
                            'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc
                            u100000000
                        )
                        (err u101)
                    ))
                )
                (ok {
                    usd-per-stx: usd-per-stx,
                    btc-per-stx: btc-per-stx,
                    usd-per-btc: (/ usd-per-stx btc-per-stx)
                })
            )
        )
    )
)

(define-read-only (get-upb-v2 (h uint))
    (let
        (
            (id (unwrap! (get-stacks-block-info? id-header-hash h) (err u100)))
        )
        (at-block id
            (ok (unwrap!
                (contract-call?
                    'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01
                    get-helper-a
                    'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc
                    'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
                    'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt
                    u100000000
                    u100000000
                    u1
                )
                (err u101)
            ))
        )
    )
)