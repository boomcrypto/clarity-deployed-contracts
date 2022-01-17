(define-public (check-get-owner (id uint))
    (ok (asserts! (is-eq tx-sender (unwrap-panic (unwrap-panic (contract-call? 'SP38FN88VZ97GWV0E8THXRM6Z5VMFPHFY4J1JEC5S.btc-badgers get-owner id)))) (err u101)))
)