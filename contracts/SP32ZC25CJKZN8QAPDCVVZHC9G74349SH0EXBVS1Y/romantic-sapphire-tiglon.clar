(define-constant AEUSDC 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)
(define-constant VELAR-STX 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx)
(define-constant VELAR-FEE 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to)
(define-constant VELAR-POOL 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core)

(define-constant err-swap-preconditions (err u110))

(define-public (swap-x-for-y
    (in uint)
    (expected-out uint)
  )
  (let (
      (pool (contract-call? VELAR-POOL do-get-pool u6))
      (swap-data (contract-call? VELAR-POOL calc-swap in (get swap-fee pool)
        (get protocol-fee pool) (get share-fee pool)
      ))
      (adjusted-in (get amt-in-adjusted swap-data))
      (reserve0 (get reserve0 pool))
      (reserve1 (get reserve1 pool))
      (k (* reserve0 reserve1))
      (effective-out (+ (/ (* reserve0 reserve1) adjusted-in) u1))
    )
    (asserts! (>= effective-out expected-out) err-swap-preconditions)
    (asserts! (>= k (* (- reserve0 effective-out) (+ reserve1 in)))
      err-swap-preconditions
    )
    (try! (contract-call? VELAR-POOL swap u6 AEUSDC VELAR-STX VELAR-FEE in
      effective-out
    ))
    (ok true)
  )
)
