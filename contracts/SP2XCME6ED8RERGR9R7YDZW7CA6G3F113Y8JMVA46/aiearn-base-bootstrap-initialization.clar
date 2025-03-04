(impl-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.proposal)

(define-constant DAO_MANIFEST "To create an AI DAO that deploys AI agents to assist users in generating income, inspired by successful models like @griffaindotcom.")

(define-public (execute (sender principal))
  (begin  
    ;; set initial dao extensions list
    (try! (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aiearn-base-dao set-extensions
      (list
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aiearn-action-proposals, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aiearn-bank-account, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aiearn-core-proposals, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aiearn-onchain-messaging, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aiearn-payments-invoices, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aiearn-token-owner, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aiearn-treasury, enabled: true}
      )
    ))
    ;; set initial action proposals list
    (try! (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aiearn-base-dao set-extensions
      (list
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aiearn-action-add-resource, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aiearn-action-allow-asset, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aiearn-action-send-message, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aiearn-action-set-account-holder, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aiearn-action-set-withdrawal-amount, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aiearn-action-set-withdrawal-period, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aiearn-action-toggle-resource, enabled: true}
      )
    ))
    ;; send DAO manifest as onchain message
    (try! (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aiearn-onchain-messaging send DAO_MANIFEST true))
    ;; allow assets in treasury
    (try! (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aiearn-treasury allow-asset 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aiearn-stxcity true))
    ;; print manifest
    (print DAO_MANIFEST)
    (ok true)
  )
)

(define-read-only (get-dao-manifest)
  DAO_MANIFEST
)
