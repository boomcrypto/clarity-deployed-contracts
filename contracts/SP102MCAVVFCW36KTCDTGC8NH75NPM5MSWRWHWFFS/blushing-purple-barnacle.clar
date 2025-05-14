
(define-constant stx-den u1000000)

(define-read-only (convert-stx-to-ststx-read (stx-price uint))
  (let (
    (total-stx-amount (unwrap-panic (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.reserve-v1 get-total-stx)))
    (ststxbtc-supply (unwrap-panic (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token get-total-supply)))
    (stx-for-ststx (- total-stx-amount ststxbtc-supply))
    (ratio (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.data-core-v2 get-stx-per-ststx-helper stx-for-ststx))
  )
    (ok (/ (* stx-price ratio) stx-den))
  )
)