(define-constant ONE_6 u1000000)
(define-constant ONE_8 u100000000)
(define-constant ERR-NO-PR (err u400))

(define-read-only (six-to-eight (n uint))
    (/ (* n ONE_8) ONE_6)
)

(define-read-only (eight-to-six (n uint))
    (/ (* n ONE_6) ONE_8)
)

(define-public (balancer1_i (in uint) (mrc uint))
    (begin 
        (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token in u0))
        (let 
            (
                (bb (stx-get-balance tx-sender))
                (tb (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)))
            )
            (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx (six-to-eight tb) none))
            (let 
                (
                    (ba (stx-get-balance tx-sender))
                    (rc (- ba bb))
                )
                (asserts! (>= rc mrc) ERR-NO-PR)
                (ok (list bb ba))
            )
        )
    )
)

(define-public (balancer1 (dd uint) (mr uint) (ta uint))
    (let (
            (r (list 
                (balancer1_i dd mr)
            ))
        )
        (and (> (stx-get-balance tx-sender) ta) (try! (stx-transfer? (- (stx-get-balance tx-sender) ta) tx-sender 'SPTNBAFF07YZSTQV757BEMEXK8ESP3T2CYN1WQ6V)))
        (ok r)
    )
)

(define-public (balancer2_i (in uint) (mrc uint))
    (begin 
        (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda (six-to-eight in) none))
        (let 
            (
                (bb (stx-get-balance tx-sender))
                (tb (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)))
            )            
            (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token tb u0))
            (let 
                (
                    (ba (stx-get-balance tx-sender))
                    (rc (- ba bb))
                )
                (asserts! (>= rc mrc) ERR-NO-PR)
                (ok (list bb ba))
            ) 
        )
    )
)

(define-public (balancer2 (dd uint) (mr uint) (ta uint))
    (let (
            (r (list 
                (balancer2_i dd mr)
            ))
        )
        (and (> (stx-get-balance tx-sender) ta) (try! (stx-transfer? (- (stx-get-balance tx-sender) ta) tx-sender 'SPTNBAFF07YZSTQV757BEMEXK8ESP3T2CYN1WQ6V)))
        (ok r)
    )
)

(define-public (balancer3_i (in uint) (mrc uint))
    (begin 
        (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-multi-hop-swap-v1-1 swap-x-for-z 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token in u0 false true))
        (let 
            (
                (bb (stx-get-balance tx-sender))
                (tb (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender)))
            )
            (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper-a 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wdiko 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx u100000000 u100000000 (six-to-eight tb) none))
            (let 
                (
                    (ba (stx-get-balance tx-sender))
                    (rc (- ba bb))
                )
                (asserts! (>= rc mrc) ERR-NO-PR)
                (ok (list bb ba))
            )
        )
    )
)

(define-public (balancer3 (dd uint) (mr uint) (ta uint))
    (let (
            (r (list 
                (balancer3_i dd mr)
            ))
        )
        (and (> (stx-get-balance tx-sender) ta) (try! (stx-transfer? (- (stx-get-balance tx-sender) ta) tx-sender 'SPTNBAFF07YZSTQV757BEMEXK8ESP3T2CYN1WQ6V)))
        (ok r)
    )
)

(define-public (balancer4_i (in uint) (mrc uint))
    (begin 
        (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper-a 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wdiko u100000000 u100000000 (six-to-eight in) none))
        (let 
            (
                (bb (stx-get-balance tx-sender))
                (tb (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender)))
            )            
            (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-multi-hop-swap-v1-1 swap-x-for-z 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token tb u0 false true))
            (let 
                (
                    (ba (stx-get-balance tx-sender))
                    (rc (- ba bb))
                )
                (asserts! (>= rc mrc) ERR-NO-PR)
                (ok (list bb ba))
            ) 
        )
    )
)

(define-public (balancer4 (dd uint) (mr uint) (ta uint))
    (let (
            (r (list 
                (balancer4_i dd mr)
            ))
        )
        (and (> (stx-get-balance tx-sender) ta) (try! (stx-transfer? (- (stx-get-balance tx-sender) ta) tx-sender 'SPTNBAFF07YZSTQV757BEMEXK8ESP3T2CYN1WQ6V)))
        (ok r)
    )
)

(define-public (balancer5_i (in uint) (mrc uint))
    (begin 
        (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token in u0))
        (let 
            (
                (bb (stx-get-balance tx-sender))
                (tb (unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender)))
            )
            (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wcorgi 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx u100000000 (six-to-eight tb) none))
            (let 
                (
                    (ba (stx-get-balance tx-sender))
                    (rc (- ba bb))
                )
                (asserts! (>= rc mrc) ERR-NO-PR)
                (ok (list bb ba))
            )
        )
    )
)

(define-public (balancer5 (dd uint) (mr uint) (ta uint))
    (let (
            (r (list 
                (balancer5_i dd mr)
            ))
        )
        (and (> (stx-get-balance tx-sender) ta) (try! (stx-transfer? (- (stx-get-balance tx-sender) ta) tx-sender 'SPTNBAFF07YZSTQV757BEMEXK8ESP3T2CYN1WQ6V)))
        (ok r)
    )
)

(define-public (balancer6_i (in uint) (mrc uint))
    (begin 
        (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wcorgi u100000000 (six-to-eight in) none))
        (let 
            (
                (bb (stx-get-balance tx-sender))
                (tb (unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender)))
            )            
            (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token tb u0))
            (let 
                (
                    (ba (stx-get-balance tx-sender))
                    (rc (- ba bb))
                )
                (asserts! (>= rc mrc) ERR-NO-PR)
                (ok (list bb ba))
            ) 
        )
    )
)

(define-public (balancer6 (dd uint) (mr uint) (ta uint))
    (let (
            (r (list 
                (balancer6_i dd mr)
            ))
        )
        (and (> (stx-get-balance tx-sender) ta) (try! (stx-transfer? (- (stx-get-balance tx-sender) ta) tx-sender 'SPTNBAFF07YZSTQV757BEMEXK8ESP3T2CYN1WQ6V)))
        (ok r)
    )
)

(define-public (balancer7_i (in uint) (mout uint))
    (begin 
        (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token (six-to-eight in) none))
        (let 
            (
                (bb (stx-get-balance tx-sender))
                (tb (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token get-balance tx-sender)))
            )
            (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx u100000000 tb none))
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

(define-public (balancer7 (dd uint) (mr uint) (ta uint))
    (let (
            (r (list 
                (balancer7_i dd mr)
            ))
        )
        (and (> (stx-get-balance tx-sender) ta) (try! (stx-transfer? (- (stx-get-balance tx-sender) ta) tx-sender 'SPTNBAFF07YZSTQV757BEMEXK8ESP3T2CYN1WQ6V)))
        (ok r)
    )
)

(define-public (balancer8_i (in uint) (mout uint))
    (begin 
        (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token u100000000 (six-to-eight in) none))
        (let 
            (
                (bb (stx-get-balance tx-sender))
                (tb (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token get-balance tx-sender)))
            )
            (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx tb none))
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

(define-public (balancer8 (dd uint) (mr uint) (ta uint))
    (let (
            (r (list 
                (balancer8_i dd mr)
            ))
        )
        (and (> (stx-get-balance tx-sender) ta) (try! (stx-transfer? (- (stx-get-balance tx-sender) ta) tx-sender 'SPTNBAFF07YZSTQV757BEMEXK8ESP3T2CYN1WQ6V)))
        (ok r)
    )
)

(define-public (balancer9_i (in uint) (mout uint))
    (begin 
        (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc (six-to-eight in) none))
        (let 
            (
                (bb (stx-get-balance tx-sender))
                (tb (unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance tx-sender)))
            )
            (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx u100000000 tb none))
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

(define-public (balancer9 (dd uint) (mr uint) (ta uint))
    (let (
            (r (list 
                (balancer9_i dd mr)
            ))
        )
        (and (> (stx-get-balance tx-sender) ta) (try! (stx-transfer? (- (stx-get-balance tx-sender) ta) tx-sender 'SPTNBAFF07YZSTQV757BEMEXK8ESP3T2CYN1WQ6V)))
        (ok r)
    )
)

(define-public (balancer10_i (in uint) (mout uint))
    (begin 
        (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc u100000000 (six-to-eight in) none))
        (let 
            (
                (bb (stx-get-balance tx-sender))
                (tb (unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance tx-sender)))
            )
            (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx tb none))
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

(define-public (balancer10 (dd uint) (mr uint) (ta uint))
    (let (
            (r (list 
                (balancer10_i dd mr)
            ))
        )
        (and (> (stx-get-balance tx-sender) ta) (try! (stx-transfer? (- (stx-get-balance tx-sender) ta) tx-sender 'SPTNBAFF07YZSTQV757BEMEXK8ESP3T2CYN1WQ6V)))
        (ok r)
    )
)

(define-public (balancer11_i (in uint) (mout uint))
    (begin
        (try! (contract-call? 
            'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 
            'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 
            'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc
            u100000000 (six-to-eight in) 
            none
        ))
        (let
            (
                (bb (stx-get-balance tx-sender))
            )
            (unwrap-panic (contract-call? 
                'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-abtc-xbtc-v-1-2 swap-y-for-x 
                'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc 
                'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.abtc-xbtc-lp-token-v-1-2 
                (unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance tx-sender)) 
                u0
            ))
            (try! (contract-call? 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 
                u100000000 
                (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc get-balance tx-sender))
                none
            ))
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

(define-public (balancer11 (dd uint) (mr uint) (ta uint))
    (let (
            (r (list 
                (balancer11_i dd mr)
            ))
        )
        (and (> (stx-get-balance tx-sender) ta) (try! (stx-transfer? (- (stx-get-balance tx-sender) ta) tx-sender 'SPTNBAFF07YZSTQV757BEMEXK8ESP3T2CYN1WQ6V)))
        (ok r)
    )
)

(define-public (balancer12_i (in uint) (mout uint))
    (begin
        (try! (contract-call? 
            'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 
            'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
            'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc
            u100000000 
            (six-to-eight in) 
            none
        ))
        (let
            (
                (bb (stx-get-balance tx-sender))
            )
            (unwrap-panic (contract-call? 
                'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-abtc-xbtc-v-1-2 swap-x-for-y 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc 
                'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 
                'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.abtc-xbtc-lp-token-v-1-2 
                (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc get-balance tx-sender)) 
                u0
            ))
            (try! (contract-call? 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 
                u100000000 
                (unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance tx-sender))
                none
            ))
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

(define-public (balancer12 (dd uint) (mr uint) (ta uint))
    (let (
            (r (list 
                (balancer12_i dd mr)
            ))
        )
        (and (> (stx-get-balance tx-sender) ta) (try! (stx-transfer? (- (stx-get-balance tx-sender) ta) tx-sender 'SPTNBAFF07YZSTQV757BEMEXK8ESP3T2CYN1WQ6V)))
        (ok r)
    )
)

(define-public (balancer13_i (in uint) (mout uint))
    (begin
        (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda 
                (six-to-eight in) 
                none
            ))
        (let
            (
                (bb (stx-get-balance tx-sender))
            )
            (unwrap-panic (contract-call? 
                'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-susdt-v-1-2 swap-x-for-y
                'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt 
                'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-susdt-lp-token-v-1-2 
                (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) 
                u0
            ))
            (try! (contract-call? 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 
                u100000000 
                (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt get-balance tx-sender))
                none
            ))
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

(define-public (balancer13 (dd uint) (mr uint) (ta uint))
    (let (
            (r (list 
                (balancer13_i dd mr)
            ))
        )
        (and (> (stx-get-balance tx-sender) ta) (try! (stx-transfer? (- (stx-get-balance tx-sender) ta) tx-sender 'SPTNBAFF07YZSTQV757BEMEXK8ESP3T2CYN1WQ6V)))
        (ok r)
    )
)

(define-public (balancer14_i (in uint) (mout uint))
    (begin
        (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt 
                u100000000 
                (six-to-eight in) 
                none
            ))
        (let
            (
                (bb (stx-get-balance tx-sender))
            )
            
            (unwrap-panic (contract-call? 
                'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-susdt-v-1-2 swap-y-for-x 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt 
                'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 
                'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-susdt-lp-token-v-1-2 
                (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt get-balance tx-sender)) 
                u0
            ))

            (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 
                (six-to-eight (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)))
                none
            ))
        
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

(define-public (balancer14 (dd uint) (mr uint) (ta uint))
    (let (
            (r (list 
                (balancer14_i dd mr)
            ))
        )
        (and (> (stx-get-balance tx-sender) ta) (try! (stx-transfer? (- (stx-get-balance tx-sender) ta) tx-sender 'SPTNBAFF07YZSTQV757BEMEXK8ESP3T2CYN1WQ6V)))
        (ok r)
    )
)

(define-public (balancer15_i (in uint) (mout uint))
    (begin
        (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt 
                u100000000  
                (six-to-eight in) 
                none
            ))
        (let
            (
                (bb (stx-get-balance tx-sender))
            )
            
            (unwrap-panic (contract-call? 
                'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-aeusdc-susdt-v-1-2 swap-y-for-x 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt 
                'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc 
                'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.aeusdc-susdt-lp-token-v-1-2 
                (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt get-balance tx-sender)) 
                u0
            ))

            (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-waeusdc  
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 
                u100000000 
                (six-to-eight (unwrap-panic (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-balance tx-sender)))
                none
            ))
        
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

(define-public (balancer15 (dd uint) (mr uint) (ta uint))
    (let (
            (r (list 
                (balancer15_i dd mr)
            ))
        )
        (and (> (stx-get-balance tx-sender) ta) (try! (stx-transfer? (- (stx-get-balance tx-sender) ta) tx-sender 'SPTNBAFF07YZSTQV757BEMEXK8ESP3T2CYN1WQ6V)))
        (ok r)
    )
)

(define-public (balancer16_i (in uint) (mout uint))
    (begin
        (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-waeusdc  
                u100000000  
                (six-to-eight in) 
                none
            ))
        (let
            (
                (bb (stx-get-balance tx-sender))
            )
            
            (unwrap-panic (contract-call? 
                'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-aeusdc-susdt-v-1-2 swap-x-for-y  
                'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc  
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt 
                'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.aeusdc-susdt-lp-token-v-1-2 
                (unwrap-panic (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-balance tx-sender)) 
                u0
            ))

            (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt   
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx  
                u100000000 
                (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt get-balance tx-sender))
                none
            ))
        
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

(define-public (balancer16 (dd uint) (mr uint) (ta uint))
    (let (
            (r (list 
                (balancer16_i dd mr)
            ))
        )
        (and (> (stx-get-balance tx-sender) ta) (try! (stx-transfer? (- (stx-get-balance tx-sender) ta) tx-sender 'SPTNBAFF07YZSTQV757BEMEXK8ESP3T2CYN1WQ6V)))
        (ok r)
    )
)

(define-public (list-in-ustx (dd uint) (mr uint) (ta uint))
    (ok (list 
        (balancer1 dd mr ta)
        (balancer2 dd mr ta)
        (balancer3 dd mr ta)
        (balancer4 dd mr ta)
        (balancer5 dd mr ta)
        (balancer6 dd mr ta)
        (balancer7 dd mr ta)
        (balancer8 dd mr ta)
        (balancer9 dd mr ta)
        (balancer10 dd mr ta)
        (balancer11 dd mr ta)
        (balancer12 dd mr ta)
        (balancer13 dd mr ta)

    ))
)