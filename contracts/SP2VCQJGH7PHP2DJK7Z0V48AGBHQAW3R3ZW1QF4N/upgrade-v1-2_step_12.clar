(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant updated-reserve-asset-1 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)

(define-public (run-update)
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read updated-reserve-asset-1)))
  )
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))
    (try!
      (contract-call? .pool-borrow-v1-2 set-reserve updated-reserve-asset-1
        (merge reserve-data-1 { last-updated-block: burn-block-height })
      )
    )

    (try! (contract-call? .zaeusdc-v1-2 cumulate-balance 'SP3X6G145Z6DV5H49MN0P0RK9SXY83ZN4ACM3RPMA))

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
