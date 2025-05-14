(define-data-var contract-admin (optional principal) none)

(define-read-only (get-admin)
     (var-get contract-admin)
)

(define-public (set-admin )
(begin
    (asserts! (is-eq tx-sender contract-caller) (err "mismatch caller"))
    (asserts! (is-eq (var-get contract-admin) none) (err "admin already set"))
    (var-set contract-admin (some tx-sender))
    (ok true)
)
)


(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)


(define-private (transfer-ft (token-contract <ft-trait>) (amount uint) (sender principal) (recipient principal))
    (contract-call? token-contract transfer amount sender recipient none)
)

;; to add the trait clarinet requirements add SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard

(define-constant sbtc-token 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)


(define-private (transfer-sbtc-to-user (user {amount:uint, address:principal}))
    (transfer-ft sbtc-token (get amount user) (as-contract tx-sender) (get address user))
)

;;expiration here is wrong TODO FIX
(define-public (distribuite (users (list 1000 {amount:uint, address:principal})) )
    (begin 
    (map transfer-sbtc-to-user users)
    (is-eq (var-get contract-admin) (some tx-sender))
    (ok true)
    )
)
