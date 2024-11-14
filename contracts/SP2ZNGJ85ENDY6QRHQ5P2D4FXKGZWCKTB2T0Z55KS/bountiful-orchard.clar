;; Farmers produce two times more energy than other creature types in the tranquil orchard

(define-constant farmers u1)
(define-constant factor u100000000)

(define-public (harvest (creature-id uint))
    (let
        (
            (tapped-out (unwrap-panic (contract-call? .creatures-energy tap creature-id)))
            (ENERGY (get ENERGY tapped-out))
            (apple-amount (* ENERGY factor))
            (TOKENS (if (is-eq creature-id farmers) (* apple-amount u2) apple-amount))
			      (original-sender tx-sender)
        )
        (as-contract (contract-call? .fuji-apples transfer TOKENS tx-sender original-sender none))
    )
)

(define-read-only (get-claimable-amount (creature-id uint))
    (let
        (
            (untapped-energy (unwrap-panic (contract-call? .creatures-energy get-untapped-amount creature-id tx-sender)))
            (apple-amount (* untapped-energy factor))
        )
        (if (is-eq creature-id farmers) (* apple-amount u2) apple-amount)
    )
)