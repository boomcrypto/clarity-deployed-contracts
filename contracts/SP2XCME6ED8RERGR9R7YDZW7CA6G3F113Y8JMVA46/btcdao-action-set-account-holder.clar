(impl-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.extension)
(impl-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.action)

(define-constant ERR_UNAUTHORIZED (err u10001))
(define-constant ERR_INVALID_PARAMS (err u10002))

(define-public (callback (sender principal) (memo (buff 34))) (ok true))

(define-public (run (parameters (buff 2048)))
  (let
    (
      (accountHolder (unwrap! (from-consensus-buff? principal parameters) ERR_INVALID_PARAMS))
    )
    (try! (is-dao-or-extension))
    (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.btcdao-bank-account set-account-holder accountHolder)
  )
)

(define-private (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.btcdao-base-dao)
    (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.btcdao-base-dao is-extension contract-caller)) ERR_UNAUTHORIZED
  ))
)