(use-trait sip010-trait .trait-sip-010.sip-010-trait)
(define-public (register-stxdx-and-request-peg-in (pub-key (buff 33)) (token principal) (amount uint) (memo (string-ascii 256)))
    (begin 
        (try! (contract-call? .stxdx-registry register-user pub-key))
        (register-and-request-peg-in token amount memo)
    )
)
(define-public (register-and-request-peg-in (token principal) (amount uint) (memo (string-ascii 256)))
    (begin 
        (try! (contract-call? .b20-bridge-endpoint register-user-by-tx-sender))
        (contract-call? .b20-bridge-endpoint request-peg-in token amount memo)
    )
)
(define-public (register-and-request-peg-out (token-trait <sip010-trait>) (amount uint) (peg-out-address (string-ascii 62)))
    (begin 
        (try! (contract-call? .b20-bridge-endpoint register-user-by-tx-sender))
        (contract-call? .b20-bridge-endpoint request-peg-out token-trait amount peg-out-address)
    )
)