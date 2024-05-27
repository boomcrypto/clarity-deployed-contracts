(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant updated-reserve-asset-1 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
(define-constant updated-reserve-asset-2 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)
(define-constant updated-reserve-asset-3 .wstx)

(define-public (run-update)
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read updated-reserve-asset-1)))
    (reserve-data-2 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read updated-reserve-asset-2)))
    (reserve-data-3 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read updated-reserve-asset-3)))
  )
    (asserts! (not (var-get executed)) (err u10))
    (print reserve-data-1)
    (print reserve-data-2)
    (print reserve-data-3)
    (try!
      (contract-call? .pool-borrow-v1-2
        set-reserve
        updated-reserve-asset-1
        (merge reserve-data-1 { is-frozen: false, last-updated-block: burn-block-height })
      )
    )
    (try!
      (contract-call? .pool-borrow-v1-2
        set-reserve
        updated-reserve-asset-2
        (merge reserve-data-2 { is-frozen: false, last-updated-block: burn-block-height })
      )
    )
    (try!
      (contract-call? .pool-borrow-v1-2
        set-reserve
        updated-reserve-asset-3
        (merge reserve-data-3 { is-frozen: false, last-updated-block: burn-block-height })
      )
    )

    (try! (contract-call? .pool-borrow-v1-2 set-freeze-end-block updated-reserve-asset-1 burn-block-height))
    (try! (contract-call? .pool-borrow-v1-2 set-freeze-end-block updated-reserve-asset-2 burn-block-height))
    (try! (contract-call? .pool-borrow-v1-2 set-freeze-end-block updated-reserve-asset-3 burn-block-height))

    (var-set executed true)
    (ok true)
  )
)

(define-read-only (preview-update)
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read updated-reserve-asset-1)))
    (reserve-data-2 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read updated-reserve-asset-2)))
    (reserve-data-3 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read updated-reserve-asset-3)))
  )
    {
      ststx: (print (merge reserve-data-1 { is-frozen: false, last-updated-block: burn-block-height })),
      aeusdc: (print (merge reserve-data-2 { is-frozen: false, last-updated-block: burn-block-height })),
      stx: (print (merge reserve-data-3 { is-frozen: false, last-updated-block: burn-block-height }))
    }
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
