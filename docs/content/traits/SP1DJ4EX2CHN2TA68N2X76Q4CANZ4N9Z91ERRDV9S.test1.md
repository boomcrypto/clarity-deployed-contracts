---
title: "Trait test1"
draft: true
---
```
(define-constant owner tx-sender)
(define-constant ERR-NOT-OWNER u444)
(define-constant decimal_8 u100000000) 

(define-public (a1 (in uint))
    (begin 
        (let
            (
                (aa (stx-get-balance tx-sender))

                (b1 (try! (contract-call? 
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router 
                swap-exact-tokens-for-tokens 
                u6 
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 
                'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc 
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 
                'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc 
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to 
                in 
                u1)))

                (b2 (try! (contract-call?
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-1 
                swap-y-for-x 
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-stx-aeusdc-v-1-1 
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-1 
                'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc 
                (unwrap-panic (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-balance tx-sender)) 
                u1
                )))

                (ab (stx-get-balance tx-sender))

            )

            (asserts! (>= ab aa) (err (- aa ab)))
            (ok (- ab aa))
        )
    )
)


(define-public (a2 (in uint))
    (begin 
        (let
            (
                (aa (stx-get-balance tx-sender))

                (b1 (try! (contract-call? 
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-1 
                swap-x-for-y 
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-stx-aeusdc-v-1-1 
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-1 
                'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc 
                in u1)))

                (b2 (try! (contract-call?
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router 
                swap-exact-tokens-for-tokens 
                u6
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 
                'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc 
                'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc 
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to 
                (unwrap-panic (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-balance tx-sender)) 
                u1
                )))

                (ab (stx-get-balance tx-sender))

            )

            (asserts! (>= ab aa) (err (- aa ab)))
            (ok (- ab aa))
        )
    )
)



(define-public (ABCD (amount uint) (out uint))
    (let ((a (list (a1 amount) (a2 amount)))) (and (> (stx-get-balance tx-sender) out) (try! (stx-transfer? (- (stx-get-balance tx-sender) out) tx-sender 'SP2HM9F89Y24KRM6WE4NJ6QN5G929KP3WMJSGESQ4))) (ok a)))
```
