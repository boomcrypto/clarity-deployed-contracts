(use-trait sip10 .creatures-core.sip010-transferable-trait)

(define-constant err-unauthorized (err u100))
(define-constant err-nothing-to-tap (err u101))

(define-map total-tapped-energy {creature-id: uint, owner: principal} uint)
(define-map stored-energy {creature-id: uint, owner: principal} uint)
(define-map last-update {creature-id: uint, owner: principal} uint)

;; store energy and summon creatures
(define-public (recruit (amount uint) (sip10-contract <sip10>))
    (let
        (
            (stored-out (try! (store sip10-contract)))
        )
        (try! (contract-call? .creatures-core summon amount sip10-contract))
        (ok stored-out)
    )
)

;; store energy and unsummon creatures
(define-public (dismiss (amount uint) (sip10-contract <sip10>))
    (let
        (
            (stored-out (try! (store sip10-contract)))
        )
        (try! (contract-call? .creatures-core unsummon amount sip10-contract))
        (ok stored-out)
    )
)

;; tap creatures energy
(define-public (tap (creature-id uint))
    (let
        (
            (untapped-energy (unwrap-panic (get-untapped-amount creature-id tx-sender)))
            (creature-amount (unwrap-panic (contract-call? .creatures-core get-balance creature-id tx-sender)))
            (previous-total-tapped-energy (get-total-tapped-energy creature-id tx-sender))
            (new-total-tapped-energy (+ previous-total-tapped-energy untapped-energy))
            (tapped-out {type: "tap-energy", creature-id: creature-id, creature-amount: creature-amount, ENERGY: untapped-energy})
        )
        (map-set stored-energy {creature-id: creature-id, owner: tx-sender} u0)
        (map-set last-update {creature-id: creature-id, owner: tx-sender} block-height)
        (map-set total-tapped-energy {creature-id: creature-id, owner: tx-sender} new-total-tapped-energy)
        (print tapped-out)
        (ok tapped-out)
    )
)
;; store creatures energy
(define-public (store (sip10-contract <sip10>))
    (let
        (
            (creature-id (try! (contract-call? .creatures-core get-or-create-creature-id sip10-contract)))
            (tapped-out (unwrap-panic (tap creature-id)))
            (ENERGY (get ENERGY tapped-out))
            (stored-out {type: "store-energy", creature-id: creature-id, owner: tx-sender, stored-energy: ENERGY})
        )
        (map-set stored-energy {creature-id: creature-id, owner: tx-sender} ENERGY)
        (print stored-out)
        (ok stored-out)
    )
)

;; get stored energy default to 0
(define-read-only (get-stored-energy (creature-id uint) (user principal))
    (default-to u0 (map-get? stored-energy {creature-id: creature-id, owner: user}))
)

;; get untapped amount
(define-read-only (get-untapped-amount (creature-id uint) (user principal))
    (let
        (
            (new-energy (get-new-energy creature-id user))
            (previous-stored-energy (get-stored-energy creature-id user))
            (untapped-energy (+ new-energy previous-stored-energy))
        )
        (ok untapped-energy)
    )
)

;; get new energy
(define-read-only (get-new-energy (creature-id uint) (user principal))
    (let
        (
            (energy-per-block (get-energy-per-block creature-id user))
            (blocks-since-last-update (get-blocks-since-last-update creature-id user))
        )
        (* blocks-since-last-update energy-per-block)
    )
)

;; get energy per block
(define-read-only (get-energy-per-block (creature-id uint) (user principal))
    (let
        (
            (users-creatures (unwrap-panic (contract-call? .creatures-core get-balance creature-id user)))
            (creatures-power (contract-call? .creatures-core get-creature-power creature-id))
        )
        (* users-creatures creatures-power)
    )
)

;; get blocks since last update
(define-read-only (get-blocks-since-last-update (creature-id uint) (user principal))
    (let
        (
            (last-update-block (get-user-last-update creature-id user))
        )
        (- block-height last-update-block)
    )
)

;; get user last update block
(define-read-only (get-user-last-update (creature-id uint) (user principal))
    (default-to block-height (map-get? last-update {creature-id: creature-id, owner: user}))
)

;; get total tapped energy
(define-read-only (get-total-tapped-energy (creature-id uint) (user principal))
    (default-to u0 (map-get? total-tapped-energy {creature-id: creature-id, owner: user}))
)

;; get blocks remaining to reach target energy
(define-read-only (blocks-to-target-energy (creature-id uint) (user principal) (target-energy uint))
    (let
        (
            (current-energy (unwrap-panic (get-untapped-amount creature-id user)))
            (energy-per-block (get-energy-per-block creature-id user))
        )
        (if (>= current-energy target-energy)
            u0
            (/ (- target-energy current-energy) energy-per-block)
        )
    )
)

;; extension callback
(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)