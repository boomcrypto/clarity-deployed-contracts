(define-public (join-pool (recipient { to: principal, ustx: uint }))
    (stx-transfer? (get ustx recipient) tx-sender (get to recipient))
)