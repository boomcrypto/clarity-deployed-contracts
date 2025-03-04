
;; title: playground
;; version:
;; summary:
;; description:

(define-read-only (get-heights (height uint))
    (let
        (
            (id (unwrap! (get-stacks-block-info? id-header-hash height) (err u100)))
        )
        (at-block id
            (ok { burn-block-height: burn-block-height, stacks-block-height: stacks-block-height })
        )
    )
)

(define-read-only (get-usd-per-btc (height uint))
    (let
        (
            (id (unwrap! (get-stacks-block-info? id-header-hash height) (err u100)))
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
