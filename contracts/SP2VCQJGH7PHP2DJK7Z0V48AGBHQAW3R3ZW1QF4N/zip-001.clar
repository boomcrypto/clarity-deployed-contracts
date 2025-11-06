(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant params {
  liquidity-rate: u3300000,
  sbtc-price: u11000000000000,
  wstx-price: u72000000,
})

(define-public (execute (sender principal))
  (begin
    (asserts! (not (var-get executed)) (err u10))

    (try!
      (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.incentives-v2-2 set-liquidity-rate
        'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
        'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.wstx
        (get liquidity-rate params)
      )
    )

    (try!
      (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.incentives-v2-2 set-price
        'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
        (get sbtc-price params)
      )
    )

    (try!
      (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.incentives-v2-2 set-price
        'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.wstx
        (get wstx-price params)
      )
    )

    (var-set executed true)
    (ok true)
  )
)

(define-public (disable)
  (begin
    (asserts! (is-eq deployer tx-sender) (err u11))
    (ok (var-set executed true))
  )
)

(define-read-only (can-execute)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (ok (not (var-get executed)))
  )
)
