(impl-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.proposal)

(define-constant DAO_MANIFEST "Helping supply chains reach maximum efficiency on the planet Earth")

(define-public (execute (sender principal))
  (begin  
    ;; set initial dao extensions list
    (try! (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.supply-base-dao set-extensions
      (list
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.supply-action-proposals, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.supply-bank-account, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.supply-core-proposals, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.supply-onchain-messaging, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.supply-payments-invoices, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.supply-token-owner, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.supply-treasury, enabled: true}
      )
    ))
    ;; set initial action proposals list
    (try! (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.supply-base-dao set-extensions
      (list
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.supply-action-add-resource, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.supply-action-allow-asset, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.supply-action-send-message, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.supply-action-set-account-holder, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.supply-action-set-withdrawal-amount, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.supply-action-set-withdrawal-period, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.supply-action-toggle-resource, enabled: true}
      )
    ))
    ;; send DAO manifest as onchain message
    (try! (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.supply-onchain-messaging send DAO_MANIFEST true))
    ;; allow assets in treasury
    (try! (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.supply-treasury allow-asset 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.supply-faktory true))
    ;; print manifest
    (print DAO_MANIFEST)
    (ok true)
  )
)

(define-read-only (get-dao-manifest)
  DAO_MANIFEST
)
