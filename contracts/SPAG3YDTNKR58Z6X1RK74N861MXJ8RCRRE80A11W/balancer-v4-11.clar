(define-constant ONE_6 u1000000)
(define-constant ONE_8 u100000000)
(define-constant ERR-NO-PR (err u400))

(define-read-only (six-to-eight (n uint))
    (/ (* n ONE_8) ONE_6)
)

;; usda_alex->arkadiko
(define-public (balancer1_i (in uint) (mrc uint))
    (begin 
        (try! (contract-call? 
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-a  
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex 
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda 
            u100000000 u100000000 (six-to-eight in) none))
        (let 
            (
                (bb (stx-get-balance tx-sender))
            )            
            (try! (contract-call? 
                'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
                'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token  
                'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 
                (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) 
                u1))
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
        (and (> (stx-get-balance tx-sender) ta) (try! (stx-transfer? (- (stx-get-balance tx-sender) ta) tx-sender 'SPAG3YDTNKR58Z6X1RK74N861MXJ8RCRRE80A11W)))
        (ok r)
    )
)

;; usda_arkadiko->alex
(define-public (balancer2_i (in uint) (mrc uint))
    (begin 
        (try! (contract-call? 
        'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
        'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token  
        'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token in u1))
        (let 
            (
                (bb (stx-get-balance tx-sender))
            )
            (try! (contract-call? 
                'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-a  
                'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda 
                'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
                'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
                u100000000 u100000000 
                (six-to-eight (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender))) 
                none))
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
        (and (> (stx-get-balance tx-sender) ta) (try! (stx-transfer? (- (stx-get-balance tx-sender) ta) tx-sender 'SPAG3YDTNKR58Z6X1RK74N861MXJ8RCRRE80A11W)))
        (ok r)
    )
)

(define-public (balancer (dd uint) (mr uint) (ta uint))
    (let (
            (r (list 
                (balancer1_i dd mr)
                (balancer2_i dd mr)
            ))
        )
        (and (> (stx-get-balance tx-sender) ta) (try! (stx-transfer? (- (stx-get-balance tx-sender) ta) tx-sender 'SPAG3YDTNKR58Z6X1RK74N861MXJ8RCRRE80A11W)))
        (ok r)
    )
)