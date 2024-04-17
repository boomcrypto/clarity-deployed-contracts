(impl-trait .oracle-trait.oracle-trait)
(use-trait ft .ft-trait.ft-trait)

;; prices are fixed to 8 decimals
(define-public (get-asset-price (token <ft>))
  (let (
    (pyth-entry (try! (contract-call? 'SP2T5JKWWP3FYYX4YRK8GK5BG2YCNGEAEY2P2PKN0.pyth-oracle-v2
      read-price-feed
      0xec7a775f46379b5e943c3526b1c8d54cd49749176b0b98e02dde68d1bd335c17
      'SP2T5JKWWP3FYYX4YRK8GK5BG2YCNGEAEY2P2PKN0.pyth-store-v1
    )))
    (stx-ststx (try! (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.stacking-dao-core-v1
      get-stx-per-ststx
      'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.reserve-v1))
    )
  )
    ;; STX price already comes in 8 decimals
    (ok (/ (* stx-ststx (to-uint (get price pyth-entry))) u1000000))
  )
)
