(impl-trait .proposal-trait.proposal-trait)

(define-constant DEPLOYER tx-sender)

(define-public (execute (sender principal))
  (begin
    ;; Enable genesis extensions
    (try! (contract-call? .bnsx-extensions set-extensions
      (list
        { extension: .wrapper-migrator-v2, enabled: true }
      )
    ))

    (ok true)
  )
)