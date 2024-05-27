(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant updated-reserve-asset-1 .wstx)
(define-constant updated-reserve-asset-2 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
(define-constant updated-reserve-asset-3 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)

(define-constant asset-1_v0 .zwstx)
(define-constant asset-1_v1-0 .zwstx-v1)
(define-constant asset-1_v_error .zwstx-v1-2)
(define-constant asset-1_v1-2 .zwstx-v1-2-1)

(define-public (run-update)
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read updated-reserve-asset-1)))
  )
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))
    (print reserve-data-1)

    (try!
      (contract-call? .pool-borrow-v1-2 set-reserve updated-reserve-asset-1
        (merge reserve-data-1 { a-token-address: asset-1_v1-2 })
      )
    )

    ;; STX UPGRADE
    ;; give permission for burn/mint of previous versions to new version
    (try! (contract-call? .zwstx-v1 set-approved-contract asset-1_v1-2 true))
    (try! (contract-call? .zwstx set-approved-contract asset-1_v1-2 true))
    ;; revoke permissions to error version
    (try! (contract-call? .zwstx-v1 set-approved-contract asset-1_v_error false))
    (try! (contract-call? .zwstx set-approved-contract asset-1_v_error false))
    ;; give permissions to new set to v1-2
    (try! (contract-call? .zwstx-v1-2-1 set-approved-contract .pool-borrow-v1-2 true))
    (try! (contract-call? .zwstx-v1-2-1 set-approved-contract .liquidation-manager-v1-2 true))
    (try! (contract-call? .zwstx-v1-2-1 set-approved-contract .pool-0-reserve-v1-2 true))
    ;; revoke permissions to error version
    (try! (contract-call? .zwstx-v1-2 set-approved-contract .pool-borrow-v1-2 false))
    (try! (contract-call? .zwstx-v1-2 set-approved-contract .liquidation-manager-v1-2 false))
    (try! (contract-call? .zwstx-v1-2 set-approved-contract .pool-0-reserve-v1-2 false))

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
  )
    (print reserve-data-1)
    {
      stx: (print (merge reserve-data-1 { a-token-address: asset-1_v1-2 }))
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
