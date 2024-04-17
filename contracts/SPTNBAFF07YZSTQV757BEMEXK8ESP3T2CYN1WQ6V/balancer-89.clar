(define-constant ONE_6 u1000000)
(define-constant ONE_8 u100000000)
(define-constant ERR-NO-PR (err u400))

(define-read-only (six-to-eight (n uint))
    (/ (* n ONE_8) ONE_6)
)

(define-public (balancer17_i (in uint) (mout uint))
    (begin
        (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens  
                u6 
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx  
                'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc  
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 
                'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc  
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to 
                in 
                u1
            ))
        (let
            (
                (bb (stx-get-balance tx-sender))
            )
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

(define-public (balancer17 (dd uint) (mr uint) (ta uint))
    (let (
            (r (list 
                (balancer17_i dd mr)
            ))
        )
        (and (> (stx-get-balance tx-sender) ta) (try! (stx-transfer? (- (stx-get-balance tx-sender) ta) tx-sender 'SPTNBAFF07YZSTQV757BEMEXK8ESP3T2CYN1WQ6V)))
        (ok r)
    )
)

(define-public (balancer18_i (in uint) (mout uint))
    (begin
        (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens  
                u3 
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc 
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc  
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to 
                in 
                u1
            ))
        (let
            (
                (bb (stx-get-balance tx-sender))
            )
            (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 
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

(define-public (balancer18 (dd uint) (mr uint) (ta uint))
    (let (
            (r (list 
                (balancer18_i dd mr)
            ))
        )
        (and (> (stx-get-balance tx-sender) ta) (try! (stx-transfer? (- (stx-get-balance tx-sender) ta) tx-sender 'SPTNBAFF07YZSTQV757BEMEXK8ESP3T2CYN1WQ6V)))
        (ok r)
    )
)

(define-public (balancer19_i (in uint) (mout uint))
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
            (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens  
                u6 
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 
                'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc 
                'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc 
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to 
                (unwrap-panic (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-balance tx-sender))
                u1
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

(define-public (balancer19 (dd uint) (mr uint) (ta uint))
    (let (
            (r (list 
                (balancer19_i dd mr)
            ))
        )
        (and (> (stx-get-balance tx-sender) ta) (try! (stx-transfer? (- (stx-get-balance tx-sender) ta) tx-sender 'SPTNBAFF07YZSTQV757BEMEXK8ESP3T2CYN1WQ6V)))
        (ok r)
    )
)

(define-public (balancer20_i (in uint) (mout uint))
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
            (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens  
                u3  
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc 
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to 
                (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc get-balance tx-sender)) 
                u1
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

(define-public (balancer20 (dd uint) (mr uint) (ta uint))
    (let (
            (r (list 
                (balancer20_i dd mr)
            ))
        )
        (and (> (stx-get-balance tx-sender) ta) (try! (stx-transfer? (- (stx-get-balance tx-sender) ta) tx-sender 'SPTNBAFF07YZSTQV757BEMEXK8ESP3T2CYN1WQ6V)))
        (ok r)
    )
)