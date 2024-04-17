(impl-trait 'SP10JN8QXCYEXMPN9S13MGAXKADEJ3MD4P6FP7J60.traits.executor-trait)

(define-read-only (six-to-eight (n uint))
    (/ (* n u100000000) u1000000)
)

(define-public (execute (in uint) (mout uint))
    (begin 
        (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc (six-to-eight in) none))
        (let 
            (
                (bb (stx-get-balance tx-sender))
                (tb (unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance tx-sender)))
            )
            (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx u100000000 (six-to-eight tb) none))
            (let 
                (
                    (ba (stx-get-balance tx-sender))
                    (rc (- ba bb))
                )
                (asserts! (>= rc mout) (err u400))
                (ok (list bb ba))
            ) 
        )
    )
)