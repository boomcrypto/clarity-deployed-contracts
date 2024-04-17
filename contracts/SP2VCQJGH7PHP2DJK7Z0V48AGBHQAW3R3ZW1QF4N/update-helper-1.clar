(define-data-var executed bool false)

(define-public (run-update)
  (let (
    (tree u0)
  )
    (asserts! (not (var-get executed)) (err u10))

    ;; ststx upgrade
    (try! (contract-call? .zststx-v1-0 set-approved-contract .borrow-helper-v2-2 true))
    (try! (contract-call? .zststx-v1-0 set-approved-contract .borrow-helper-v2-1 false))

    ;; aeusdcs upgrade
    (try! (contract-call? .zaeusdc-v1-0 set-approved-contract .borrow-helper-v2-2 true))
    (try! (contract-call? .zaeusdc-v1-0 set-approved-contract .borrow-helper-v2-1 false))

    ;; stx upgrade
    (try! (contract-call? .zwstx-v1 set-approved-contract .borrow-helper-v2-2 true))
    (try! (contract-call? .zwstx-v1 set-approved-contract .borrow-helper-v2-1 false))

    ;; update for helper caller
    (try! (contract-call? .pool-borrow-v1-1 set-approved-contract .borrow-helper-v2-2 true))
    (try! (contract-call? .pool-borrow-v1-1 set-approved-contract .borrow-helper-v2-1 false))

    ;; give permission for burn/mint of previous version to new version
    (var-set executed true)
    (ok true)
  )
)

(define-read-only (can-execute)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (ok (not (var-get executed)))
  )
)

(run-update)