(define-constant ONE_6 u1000000)
(define-constant ONE_8 u100000000)
(define-constant ERR-NO-PR (err u400))

(define-read-only (six-to-eight (n uint))
    (/ (* n ONE_8) ONE_6)
)

(define-public (balancer1_i (in uint) (mrc uint))
    (begin 
        (try! (contract-call? 
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-a 
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex 
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wleo 
            u100000000 u100000000 (six-to-eight in) none))
        (let 
            (
                (bb (stx-get-balance tx-sender))
            )            
            (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens  
                u28 
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
                'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token   
                'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token  
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx  
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to  
                (unwrap-panic (contract-call? 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token get-balance tx-sender)) 
                u1
            ))
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

(define-public (balancer2_i (in uint) (mout uint))
    (begin
        (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens  
                u28 
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx  
                'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
                'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
                in 
                u1
            ))
        (let
            (
                (bb (stx-get-balance tx-sender))
            )
            (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-a 
                'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wleo  
                'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
                'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2   
                u100000000 u100000000  
                (six-to-eight (unwrap-panic (contract-call? 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token get-balance tx-sender)))
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