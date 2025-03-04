(impl-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.proposal)

(define-constant DAO_MANIFEST "To leverage AI for market analysis and tokenized ownership in global real estate, focusing on high-yield properties, and providing unique diversification and passive income opportunities.")

(define-public (execute (sender principal))
  (begin  
    ;; set initial dao extensions list
    (try! (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aireal-base-dao set-extensions
      (list
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aireal-action-proposals, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aireal-bank-account, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aireal-core-proposals, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aireal-onchain-messaging, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aireal-payments-invoices, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aireal-token-owner, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aireal-treasury, enabled: true}
      )
    ))
    ;; set initial action proposals list
    (try! (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aireal-base-dao set-extensions
      (list
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aireal-action-add-resource, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aireal-action-allow-asset, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aireal-action-send-message, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aireal-action-set-account-holder, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aireal-action-set-withdrawal-amount, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aireal-action-set-withdrawal-period, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aireal-action-toggle-resource, enabled: true}
      )
    ))
    ;; send DAO manifest as onchain message
    (try! (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aireal-onchain-messaging send DAO_MANIFEST true))
    ;; allow assets in treasury
    (try! (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aireal-treasury allow-asset 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aireal-faktory true))
    ;; print manifest
    (print DAO_MANIFEST)
    (ok true)
  )
)

(define-read-only (get-dao-manifest)
  DAO_MANIFEST
)
