(impl-trait .oracle-trait.oracle-trait)
(use-trait ft .ft-trait.ft-trait)

(define-read-only (to-fixed (a uint) (decimals-a uint))
  (contract-call? .math to-fixed a decimals-a)
)

;; prices are fixed to 8 decimals
(define-public (get-asset-price (token <ft>))
  (let (
    (price (get last-price (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-oracle-v2-3 get-price "STX")))
    (stx-ststx (try! (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.stacking-dao-core-v1 get-stx-per-ststx 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.reserve-v1)))
  )
    ;; convert to fixed precision
    (ok (/ (* stx-ststx price) u10000))
  )
)

(define-read-only (get-price)
  (let (
    (stx-price (get last-price (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-oracle-v2-3 get-price "STX")))
    (stx-amount-in-reserve (unwrap-panic (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.reserve-v1 get-total-stx)))
    (stx-ststx (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.stacking-dao-core-v1 get-stx-per-ststx-helper stx-amount-in-reserve))
  )
    (/ (* stx-ststx stx-price) u10000)
  )
)
