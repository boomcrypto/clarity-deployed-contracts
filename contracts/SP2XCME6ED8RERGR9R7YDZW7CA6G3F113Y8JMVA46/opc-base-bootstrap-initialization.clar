(impl-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.proposal)

(define-constant DAO_MANIFEST "Promote the idea that every original idea, whether big or small, is valuable and has the potential to be worth millions. Focus on encouraging creativity and originality.")

(define-public (execute (sender principal))
  (begin  
    ;; set initial dao extensions list
    (try! (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.opc-base-dao set-extensions
      (list
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.opc-action-proposals, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.opc-bank-account, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.opc-core-proposals, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.opc-onchain-messaging, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.opc-payments-invoices, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.opc-token-owner, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.opc-treasury, enabled: true}
      )
    ))
    ;; set initial action proposals list
    (try! (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.opc-base-dao set-extensions
      (list
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.opc-action-add-resource, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.opc-action-allow-asset, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.opc-action-send-message, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.opc-action-set-account-holder, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.opc-action-set-withdrawal-amount, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.opc-action-set-withdrawal-period, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.opc-action-toggle-resource, enabled: true}
      )
    ))
    ;; send DAO manifest as onchain message
    (try! (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.opc-onchain-messaging send DAO_MANIFEST true))
    ;; allow assets in treasury
    (try! (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.opc-treasury allow-asset 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.opc-stxcity true))
    ;; print manifest
    (print DAO_MANIFEST)
    (ok true)
  )
)

(define-read-only (get-dao-manifest)
  DAO_MANIFEST
)
