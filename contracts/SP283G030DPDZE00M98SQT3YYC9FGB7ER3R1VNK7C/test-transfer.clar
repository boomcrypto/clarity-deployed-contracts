(define-public (send-test)
    (stx-transfer? u1 tx-sender 'SP2KS2675QXBFSNK2X0HSYS3TEZ0719PFN86WAANQ)
)

(define-public (send-test-to (to principal))
    (stx-transfer? u1 tx-sender to)
)