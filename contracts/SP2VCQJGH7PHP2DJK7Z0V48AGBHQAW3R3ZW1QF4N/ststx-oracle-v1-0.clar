(impl-trait .oracle-trait.oracle-trait)
(use-trait ft .ft-trait.ft-trait)

(define-read-only (from-fixed-to-precision (a uint) (decimals-a uint))
  (contract-call? .math from-fixed-to-precision a decimals-a)
)

;; prices are fixed to 8 decimals
(define-public (get-asset-price (token <ft>))
  (let (
    (oracle-data (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-oracle-v2-2
      get-price
      "STX"
    ))
    (stx-ststx (try! (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.stacking-dao-core-v1
      get-stx-per-ststx
      'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.reserve-v1))
    )
  )
    ;; convert to fixed precision
    (ok (from-fixed-to-precision (/ (* stx-ststx (get last-price oracle-data)) u1000000) (get decimals oracle-data)))
  )
)
