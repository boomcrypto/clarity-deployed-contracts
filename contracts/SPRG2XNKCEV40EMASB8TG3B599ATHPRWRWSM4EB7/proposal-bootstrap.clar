(impl-trait .proposal-trait.proposal-trait)

(define-constant DEPLOYER tx-sender)

(define-public (execute (sender principal))
  (begin
    (try! (add-bootstrap-utils))

    (try! (contract-call? .bnsx-extensions set-extension-roles
      (list
        { extension: .wrapper-migrator, enabled: true, role: "registry" }
      )
    ))

    (ok true)
  )
)

(define-private (add-bootstrap-utils)
  (begin
    (try! (contract-call? .bnsx-extensions set-extensions 
      (list 
        { extension: DEPLOYER, enabled: true }
        { extension: 'SPRG2XNKCEV40EMASB8TG3B599ATHPRWRWSM4EB7.xsafe, enabled: true }
        ;; { extension: .test-utils, enabled: true }
      )
    ))
    (ok true)
  )
)
