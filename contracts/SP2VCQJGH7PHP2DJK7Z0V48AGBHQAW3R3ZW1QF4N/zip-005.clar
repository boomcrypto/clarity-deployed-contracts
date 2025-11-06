(define-data-var executed bool false)
(define-constant deployer tx-sender)


(define-constant stx-address .wstx)
(define-constant ststx-address 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
(define-constant ststxbtc-address 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token-v2)
(define-constant sbtc-address 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)

(define-constant stx-oracle .stx-btc-oracle-v1-3)
(define-constant ststx-oracle .stx-btc-oracle-v1-3)
(define-constant ststxbtc-oracle .stx-btc-oracle-v1-3)
(define-constant sbtc-oracle .stx-btc-oracle-v1-3)

(define-constant params {
  liquidity-rate: u140000,
  sbtc-price: u10000000000000,
  wstx-price: u70000000,
})

(define-public (execute (sender principal))
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read stx-address)))
    (reserve-data-2 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read ststx-address)))
    (reserve-data-3 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read ststxbtc-address)))
    (reserve-data-4 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read sbtc-address)))
  )
    (asserts! (not (var-get executed)) (err u10))

    ;; permissions
    (try! (contract-call? .pool-borrow-v2-4 set-approved-contract .borrow-helper-v2-1-6 false))
    (try! (contract-call? .pool-borrow-v2-4 set-approved-contract .borrow-helper-v2-1-7 true))

    (try! (contract-call? .incentives-v2-2 set-approved-contract .borrow-helper-v2-1-6 false))
    (try! (contract-call? .incentives-v2-2 set-approved-contract .borrow-helper-v2-1-7 true))

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

    (print reserve-data-1)
    (print reserve-data-2)
    (print reserve-data-3)
    (print reserve-data-4)

    (try!
      (contract-call? .pool-borrow-v2-4 set-reserve stx-address
        (merge reserve-data-1 { oracle: stx-oracle })
      )
    )
    (try!
      (contract-call? .pool-borrow-v2-4 set-reserve ststx-address
        (merge reserve-data-2 { oracle: ststx-oracle })
      )
    )
    (try!
      (contract-call? .pool-borrow-v2-4 set-reserve ststxbtc-address
        (merge reserve-data-3 { oracle: ststxbtc-oracle })
      )
    )
    (try!
      (contract-call? .pool-borrow-v2-4 set-reserve sbtc-address
        (merge reserve-data-4 { oracle: sbtc-oracle })
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
