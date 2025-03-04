(define-constant err-unauthorized (err u100))
(define-constant err-invalid-principal (err u101))

(define-data-var contract-owner principal tx-sender)
(define-data-var temp-contract-owner principal tx-sender)


(define-data-var claim-address principal tx-sender)


(define-public (lock-tokens (amount uint) (recipient (string-utf8 128)))
    (begin
        (try! (contract-call? .FROG transfer amount tx-sender (as-contract tx-sender) none))
        (ok true)
    )
)

(define-public (claim-tokens (amount uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) err-unauthorized)
        (as-contract (try! (contract-call? .FROG transfer amount tx-sender (var-get claim-address) none)))
        (ok true)
    )
)

(define-public (send-tokens (amount uint) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) err-unauthorized)
        (as-contract (try! (contract-call? .FROG transfer amount tx-sender recipient none)))
        (ok true)
    )
)

(define-public (init-set-contract-owner (new-owner principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) err-unauthorized)
        (asserts! (is-standard new-owner) err-invalid-principal)
        (var-set temp-contract-owner new-owner)
        (ok true)
    )
)

(define-public (confirm-set-contract-owner)
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) err-unauthorized)
        (var-set contract-owner (var-get temp-contract-owner))
        (ok true)
    )
)

(define-public (set-claim-address (new-claim-address principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) err-unauthorized)
        (var-set claim-address new-claim-address)
        (ok true)
    )
)
