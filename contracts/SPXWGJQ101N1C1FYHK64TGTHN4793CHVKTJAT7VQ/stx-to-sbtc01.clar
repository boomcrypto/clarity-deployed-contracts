(define-constant ERR-SWAP-FAILED (err u100))
(define-constant ERR-INSUFFICIENT-FUNDS (err u101))

;;swap stx-stone 

(define-public (swap-stx-for-stone (stx-amount uint))
  (begin 
    
    (asserts! (>= (stx-get-balance tx-sender) stx-amount) ERR-INSUFFICIENT-FUNDS)
    (let ((swap-result
           (contract-call? 
             'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router
             swap-exact-tokens-for-tokens
             u79
             'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
             'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
             'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
             'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
             'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
             stx-amount
             u1
           )))
      (asserts! (is-ok swap-result) ERR-SWAP-FAILED)
      (let ((swap-event (unwrap! swap-result ERR-SWAP-FAILED)))
        (ok  swap-event)
      )
    )
  )
)