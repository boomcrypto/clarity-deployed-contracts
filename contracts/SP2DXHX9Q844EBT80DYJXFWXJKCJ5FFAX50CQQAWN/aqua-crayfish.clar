
(use-trait ft-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait) 

(define-constant ONE_6 u1000000)
(define-constant ONE_8 u100000000)
(define-constant ERR-NO-PRF (err u400))

(define-read-only (six-to-eight (n uint))
    (/ (* n ONE_8) ONE_6)
)

(define-read-only (eight-to-six (n uint))
    (/ (* n ONE_6) ONE_8)
)


(define-public (dcwd123d (spend uint) (min-receive uint))
    (begin 
        (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token spend u0))
        (let 
            (
                (balance-before (stx-get-balance tx-sender))
                (swapped (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)))
            )
            (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-01 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx (six-to-eight swapped) none))
            (let 
                (
                    (balance-after (stx-get-balance tx-sender))
                    (recevied (- balance-after balance-before))
                )
                (ok (asserts! (>= recevied min-receive) ERR-NO-PRF))
            )
        )
    )
)

(define-public (k1sd83m (spend uint) (min-receive uint))
    (begin 
        (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token spend u0))
        (let 
            (
                (balance-before (stx-get-balance tx-sender))
                (swapped (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)))
            )
            (try! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l swapped u0))
            (let 
                (
                    (balance-after (stx-get-balance tx-sender))
                    (recevied (- balance-after balance-before))
                )
                (ok (asserts! (>= recevied min-receive) ERR-NO-PRF))
            )
        )
    )
)

(define-public (alo3dkfh (spend uint) (min-receive uint))
    (begin 
        (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-01 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda (six-to-eight spend) none))
        (let 
            (
                (balance-before (stx-get-balance tx-sender))
                (swapped (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)))
            )            
            (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token swapped u0))
            (let 
                (
                    (balance-after (stx-get-balance tx-sender))
                    (recevied (- balance-after balance-before))
                )
                (ok (asserts! (>= recevied min-receive) ERR-NO-PRF))
            ) 
        )
    )
)

(define-public (xc11llfh0 (spend uint) (min-receive uint))
    (begin 
        (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-01 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda (six-to-eight spend) none))
        (let 
            (
                (balance-before (stx-get-balance tx-sender))
                (swapped (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)))
            )            
            (try! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l swapped u0))
            (let 
                (
                    (balance-after (stx-get-balance tx-sender))
                    (recevied (- balance-after balance-before))
                )
                (ok (asserts! (>= recevied min-receive) ERR-NO-PRF))
            ) 
        )
    )
)

(define-public (pd2wklld8 (spend uint) (min-receive uint))
    (begin 
        (try! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l spend u0))
        (let 
            (
                (balance-before (stx-get-balance tx-sender))
                (swapped (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)))
            )            
            (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-01 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx (six-to-eight swapped) none))
            (let 
                (
                    (balance-after (stx-get-balance tx-sender))
                    (recevied (- balance-after balance-before))
                )
                (ok (asserts! (>= recevied min-receive) ERR-NO-PRF))
            ) 
        )
    )
)

(define-public (hqv3ar21 (spend uint) (min-receive uint))
    (begin 
        (try! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l spend u0))
        (let 
            (
                (balance-before (stx-get-balance tx-sender))
                (swapped (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)))
            )            
            (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token swapped u0))
            (let 
                (
                    (balance-after (stx-get-balance tx-sender))
                    (recevied (- balance-after balance-before))
                )
                (ok (asserts! (>= recevied min-receive) ERR-NO-PRF))
            ) 
        )
    )
)

