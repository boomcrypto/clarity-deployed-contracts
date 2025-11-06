(define-constant err-swap-preconditions (err u110))
(define-constant err-last-swap-failed (err u111))
(define-constant err-no-profit (err u112))

(define-public (swap-x-for-y (in uint))
  ;; Velar Swap USD -> STX
  ;; Bitflow Swap STX -> USD
  (let (
      (pool (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core
        do-get-pool u6
      ))
      (swap-data (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core
        calc-swap in (get swap-fee pool) (get protocol-fee pool)
        (get share-fee pool)
      ))
      (adjusted-in (get amt-in-adjusted swap-data))
      (reserve0 (get reserve0 pool))
      (reserve1 (get reserve1 pool))
      (k (* reserve0 reserve1))
      (effective-out (/ (* adjusted-in reserve1) (+ reserve0 adjusted-in)))
    )
    (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core swap u6
      'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
      'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
      'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to in
      effective-out
    ))
    ;; Bitflow Swap uSTX -> AEUSDC
    (let ((result (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2
        swap-y-for-x
        'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-stx-aeusdc-v-1-2
        'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
        'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc effective-out
        u1
      )))
      (match result
        out (if (> out in)
          (ok true)
          err-no-profit
        )
        swap-error (err swap-error)
      )
    )
  )
)

(define-public (swap-y-for-x (in uint))
  ;; Bitflow Swap USD -> STX
  ;; Velar Swap STX -> USD 
  (let (
      (stx (unwrap-panic (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2
        swap-x-for-y
        'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-stx-aeusdc-v-1-2
        'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
        'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc in u1
      )))
      (pool (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core
        do-get-pool u6
      ))
      (swap-data (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core
        calc-swap stx (get swap-fee pool) (get protocol-fee pool)
        (get share-fee pool)
      ))
      (adjusted-in (get amt-in-adjusted swap-data))
      (reserve0 (get reserve0 pool))
      (reserve1 (get reserve1 pool))
      (k (* reserve0 reserve1))
      (effective-out (/ (* adjusted-in reserve1) (+ reserve0 adjusted-in)))
      (result (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core swap
        u6 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
        'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to in
        effective-out
      ))
    )
    (match result
      swap-event (let ((out (get amt-out swap-event)))
        (if (> out in)
          (ok true)
          err-no-profit
        )
      )
      swap-error (err swap-error)
    )
  )
)
