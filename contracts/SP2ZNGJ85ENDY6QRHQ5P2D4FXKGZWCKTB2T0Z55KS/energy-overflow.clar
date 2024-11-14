;; Energy Overflow
;;
;; This contract manages energy storage functionality for the Charisma ecosystem.
;; It determines whether energy should be stored or burned based on user upgrades,
;; such as Memobot ownership.

(use-trait sip10-trait .dao-traits-v4.sip010-ft-trait)

;; Public functions
(define-public (handle-overflow)
    (let
        (
            (energy-balance (get-energy-balance tx-sender))
        )
        (if (or (has-storage-upgrade tx-sender) (is-eq energy-balance u0))
            (ok true)  ;; Energy overflow handled
            (contract-call? .energy burn energy-balance tx-sender)
        )
    )
)

;; Read-only functions
(define-read-only (has-storage-upgrade (user principal))
    (> (unwrap-panic (contract-call? .memobots-guardians-of-the-gigaverse get-balance user)) u0)
)

;; Private functions
(define-private (get-energy-balance (user principal))
    (unwrap-panic (contract-call? .energy get-balance user))
)