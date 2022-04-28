(use-trait ft-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait) 

(define-constant ONE_6 u1000000)
(define-constant ONE_8 u100000000)

(define-read-only (six-to-eight (n uint))
    (/ (* n ONE_8) ONE_6)
)

(define-read-only (eight-to-six (n uint))
    (/ (* n ONE_6) ONE_8)
)

(define-constant O tx-sender)

(define-private (dcwd123d (dd uint) (mr uint))
    (begin 
        (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token dd u0))
        (let 
            (
                (bb (stx-get-balance tx-sender))
                (swa (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)))
            )
            (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-01 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx (six-to-eight swa) none))
            (let 
                (
                    (ba (stx-get-balance tx-sender))
                    (rr (- ba bb))
                )
                (print {klr: "dcwd123d"})
                (ok (>= rr mr))
            )
        )
    )
)

(define-private (alo3dkfh (dd uint) (mr uint))
    (begin 
        (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-01 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda (six-to-eight dd) none))
        (let 
            (
                (bb (stx-get-balance tx-sender))
                (swa (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)))
            )            
            (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token swa u0))
            (let 
                (
                    (ba (stx-get-balance tx-sender))
                    (rr (- ba bb))
                )
                (print {klr: "alo3dkfh"})
                (ok (asserts! (>= rr mr) (err u400)))
            ) 
        )
    )
)

(define-public (k0iq113 (dd uint) (mr uint))
    (begin 
        (asserts! (> dd u0) (err u100))
        (asserts! (> mr u0) (err u200))
        (asserts! (is-eq O tx-sender) (err u300))
        (and (unwrap-panic (dcwd123d dd mr)) (unwrap-panic (alo3dkfh dd mr)))
        (ok u1)
    )
)
