(impl-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.extension)
(impl-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.action)

(define-constant ERR_UNAUTHORIZED (err u10001))
(define-constant ERR_INVALID_PARAMS (err u10002))

(define-public (callback (sender principal) (memo (buff 34))) (ok true))

(define-public (run (parameters (buff 2048)))
  (let
    (
      (resourceName (unwrap! (from-consensus-buff? (string-utf8 50) parameters) ERR_INVALID_PARAMS))
    )
    (try! (is-dao-or-extension))
    (contract-call? 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.fun-payments-invoices toggle-resource-by-name resourceName)
  )
)

(define-private (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.fun-base-dao)
    (contract-call? 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.fun-base-dao is-extension contract-caller)) ERR_UNAUTHORIZED
  ))
)
