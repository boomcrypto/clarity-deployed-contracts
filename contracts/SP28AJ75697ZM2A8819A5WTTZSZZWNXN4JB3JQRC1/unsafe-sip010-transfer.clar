(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(define-constant err-invalid-payload (err u500))

(define-public (call (payload (buff 2048)))
    (let ((details (unwrap! (from-consensus-buff? {amount: uint, to: principal, token: principal} payload) err-invalid-payload)))
        (if (is-eq (get token details) 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope)
            (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope transfer (get amount details) tx-sender (get to details) none)
            err-invalid-payload)))