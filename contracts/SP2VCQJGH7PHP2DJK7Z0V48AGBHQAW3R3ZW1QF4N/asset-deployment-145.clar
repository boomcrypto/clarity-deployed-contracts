(define-data-var executed bool false)
(define-constant deployer tx-sender)


(define-constant ststxbtc-address 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token)
(define-constant ststx-address 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
(define-constant wstx-address 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.wstx)
(define-constant sbtc-address 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)

(define-constant one-8 u100000000)

(define-constant debt-ceiling {
  ststxbtc: (* u1000000 one-8),
  ststx: (* u1000000 one-8),
  wstx: (* u3000000 one-8),
  sbtc: (* u2000000 one-8),
})

(define-public (run-update)
  (let (
    (reserve-data-ststxbtc (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read ststxbtc-address)))
    (reserve-data-ststx (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read ststx-address)))
    (reserve-data-wstx (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read wstx-address)))
    (reserve-data-sbtc (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read sbtc-address)))
  )
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (print reserve-data-ststxbtc)
    (print reserve-data-ststx)
    (print reserve-data-wstx)
    (print reserve-data-sbtc)
    (try!
      (contract-call? .pool-borrow-v2-1 set-reserve ststxbtc-address
        (merge reserve-data-ststxbtc { debt-ceiling: (get ststxbtc debt-ceiling) })
      )
    )

    (try!
      (contract-call? .pool-borrow-v2-1 set-reserve ststx-address
        (merge reserve-data-ststx { debt-ceiling: (get ststx debt-ceiling) })
      )
    )

    (try!
      (contract-call? .pool-borrow-v2-1 set-reserve wstx-address
        (merge reserve-data-wstx { debt-ceiling: (get wstx debt-ceiling) })
      )
    )

    (try!
      (contract-call? .pool-borrow-v2-1 set-reserve sbtc-address
        (merge reserve-data-sbtc { debt-ceiling: (get sbtc debt-ceiling) })
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