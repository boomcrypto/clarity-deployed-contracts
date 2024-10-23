;; Blacksmiths produce 10x times more iron ingots than other creature types in the iron forge

(define-constant err-unauthorized (err u401))

(define-constant blacksmiths u2)
(define-constant contract tx-sender)

(define-data-var factor uint u1)
(define-data-var blocks-per-epoch uint u100)
(define-data-var supply-per-epoch uint u10000000)
(define-data-var iron-supply-remaining uint u10000000)
(define-data-var last-reset-block uint u0)
(define-data-var current-epoch uint u1)

;; --- Authorization check
(define-private (is-dao-or-extension)
    (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller))
)

(define-read-only (is-authorized)
    (ok (asserts! (is-dao-or-extension) err-unauthorized))
)

;; Helper functions to check if an epoch has passed
(define-read-only (get-blocks-since-last-reset)
    (- block-height (var-get last-reset-block))
)

(define-read-only (epoch-passed)
    (> (get-blocks-since-last-reset) (var-get blocks-per-epoch))
)

;; Reset the epoch supply if an epoch has passed
(define-private (try-reset-epoch-supply)
    (if (epoch-passed)
        (begin
            (var-set iron-supply-remaining (var-get supply-per-epoch))
            (var-set current-epoch (+ (var-get current-epoch) u1))
            (var-set last-reset-block block-height)
            true
        )
        false
    )
)

;; Only a limited amount of iron ingots can be created per epoch
(define-public (forge (creature-id uint))
    (let
        (
            (tapped-out (unwrap-panic (contract-call? .creatures-kit tap creature-id)))
            (ENERGY (get ENERGY tapped-out))
            (ingot-amount (* ENERGY (get-factor)))
            (CLAIM (if (is-eq creature-id blacksmiths) (* ingot-amount u10) ingot-amount))
            (original-sender tx-sender)
            (is-reset (try-reset-epoch-supply))
            (supply-remaining (get-iron-supply-remaining))
            (TOKENS (if (> CLAIM supply-remaining) supply-remaining CLAIM))
        )
        (var-set iron-supply-remaining (- supply-remaining TOKENS))
        (as-contract (contract-call? .iron-ingots transfer TOKENS tx-sender original-sender none))
    )
)

(define-read-only (get-claimable-amount (creature-id uint))
    (let
        (
            (untapped-energy (unwrap-panic (contract-call? .creatures-kit get-untapped-amount creature-id tx-sender)))
            (ingot-amount (* untapped-energy (get-factor)))
            (tokens-amount (if (is-eq creature-id blacksmiths) (* ingot-amount u10) ingot-amount))
            (supply-remaining (get-iron-supply-remaining))
        )
        (if (> tokens-amount supply-remaining) supply-remaining tokens-amount)
    )
)

;; Getters
(define-read-only (get-factor)
    (var-get factor)
)

(define-read-only (get-blocks-per-epoch)
    (var-get blocks-per-epoch)
)

(define-read-only (get-supply-per-epoch)
    (var-get supply-per-epoch)
)

(define-read-only (get-iron-supply-remaining)
    (var-get iron-supply-remaining)
)

(define-read-only (get-last-reset-block)
    (var-get last-reset-block)
)

(define-read-only (get-current-epoch)
    (var-get current-epoch)
)

;; Setters
(define-public (set-factor (new-factor uint))
    (begin
        (try! (is-authorized))
        (ok (var-set factor new-factor))
    )
)

(define-public (set-blocks-per-epoch (new-blocks-per-epoch uint))
    (begin
        (try! (is-authorized))
        (ok (var-set blocks-per-epoch new-blocks-per-epoch))
    )
)

(define-public (set-supply-per-epoch (new-supply-per-epoch uint))
    (begin
        (try! (is-authorized))
        (ok (var-set supply-per-epoch new-supply-per-epoch))
    )
)

;; Utility functions

(define-read-only (get-epoch-ended)
    (let
        (
            (blocks-since-last-reset (get-blocks-since-last-reset))
            (blocks-in-current-epoch (mod blocks-since-last-reset (var-get blocks-per-epoch)))
        )
        (- (var-get blocks-per-epoch) blocks-in-current-epoch)
    )
)

(define-read-only (get-epoch-progress)
    (let
        (
            (blocks-since-last-reset (get-blocks-since-last-reset))
            (blocks-in-current-epoch (mod blocks-since-last-reset (var-get blocks-per-epoch)))
        )
        (/ (* blocks-in-current-epoch u100) (var-get blocks-per-epoch))
    )
)

(define-read-only (get-supply-utilization)
    (let
        (
            (supply-remaining (var-get iron-supply-remaining))
            (total-supply (var-get supply-per-epoch))
        )
        (- u100 (/ (* supply-remaining u100) total-supply))
    )
)