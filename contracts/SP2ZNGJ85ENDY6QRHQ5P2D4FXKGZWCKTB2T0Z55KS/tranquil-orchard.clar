(define-constant farmers u1)

;; farmers produce two times more energy than other creature types in the tranquil orchard
(define-public (harvest (creature-id uint))
    (let
        (
            (tapped-out (unwrap-panic (contract-call? .creatures-energy tap creature-id)))
            (ENERGY (get ENERGY tapped-out))
            (TOKENS (if (is-eq creature-id farmers) (* ENERGY u2) ENERGY))
			(original-sender tx-sender)
        )
        (as-contract (contract-call? .fuji-apples transfer TOKENS tx-sender original-sender none))
    )
)