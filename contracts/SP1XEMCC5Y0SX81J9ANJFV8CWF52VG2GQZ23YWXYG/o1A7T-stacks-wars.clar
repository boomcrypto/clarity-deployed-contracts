

;; ==============================
;; Stacks Wars - Pool Contract
;; ==============================
;; author: flames.stx
;; summary: Normal pool using STX

;; ----------------------
;; CONSTANTS
;; ----------------------

(define-constant STACKS_WARS_FEE_WALLET 'SP299MBHT7FPPP2SKEY73V4DHW67467SED87A4HH4)
(define-constant TRUSTED_PUBLIC_KEY 0x02cec878c505b9626fac2363f8566c9fb256e53a78bd3d6ed1297f9399d67c89fb)
(define-constant DEPLOYER 'SP1XEMCC5Y0SX81J9ANJFV8CWF52VG2GQZ23YWXYG)
(define-constant ENTRY_FEE u5000000)
(define-constant FEE_PERCENTAGE u2)

;; ----------------------
;; Error codes
;; ----------------------

(define-constant ERR_ALREADY_JOINED u5)
(define-constant ERR_INSUFFICIENT_FUNDS u6)
(define-constant ERR_TRANSFER_FAILED u7)
(define-constant ERR_FEE_TRANSFER_FAILED u8)
(define-constant ERR_REWARD_ALREADY_CLAIMED u9)
(define-constant ERR_INVALID_SIGNATURE u10)
(define-constant ERR_INVALID_AMOUNT u11)
(define-constant ERR_MAXIMUM_REWARD_EXCEEDED u12)
(define-constant ERR_REENTRANCY u13)
(define-constant ERR_NOT_JOINED u14)
(define-constant ERR_NOT_JOINABLE u15)
(define-constant ERR_UNAUTHORIZED u16)

;; ----------------------
;; DATA VARIABLES
;; ----------------------

(define-data-var total-players uint u0)
(define-map players {player: principal} {joined-at: uint})
(define-map claimed-rewards {player: principal} {claimed: bool, amount: uint})
(define-map collected-fees {player: principal} {paid: bool})

;; ----------------------
;; HELPER FUNCTIONS
;; ----------------------

(define-private (construct-message-hash (amount uint))
    (let ((message {
        amount: amount,
        winner: tx-sender,
        contract: (as-contract tx-sender)
        }))
        (match (to-consensus-buff? message)
            buff (ok (sha256 buff))
            (err ERR_INVALID_AMOUNT)
        )
    )
)

;; ----------------------
;; PUBLIC FUNCTIONS
;; ----------------------

(define-public (join)
    (begin
        (asserts! (not (is-some (map-get? players {player: tx-sender}))) (err ERR_ALREADY_JOINED))

        (asserts! (or
            (not (is-eq (get-total-players) u0))
            (is-eq tx-sender DEPLOYER))
        (err ERR_NOT_JOINABLE))

        ;; Transfer STX from player to contract
        (match (stx-transfer? ENTRY_FEE tx-sender (as-contract tx-sender))
            success
            (begin
                (map-set players {player: tx-sender} {joined-at: stacks-block-height})
                (var-set total-players (+ (var-get total-players) u1))
                (ok true)
            )
            error (err ERR_TRANSFER_FAILED)
        )
    )
)

(define-public (leave (signature (buff 65)))
    (begin
        (asserts! (is-some (map-get? players {player: tx-sender})) (err ERR_NOT_JOINED))

        (asserts! (>= (stx-get-balance (as-contract tx-sender)) ENTRY_FEE) (err ERR_INSUFFICIENT_FUNDS))

        (let (
            (msg-hash (try! (construct-message-hash ENTRY_FEE)))
            (recipient tx-sender)
            )
            (asserts! (secp256k1-verify msg-hash signature TRUSTED_PUBLIC_KEY) (err ERR_INVALID_SIGNATURE))

            (match (as-contract (stx-transfer? ENTRY_FEE tx-sender recipient))
                success
                (begin
                    (map-delete players {player: tx-sender})
                    (var-set total-players (- (var-get total-players) u1))

                    (ok true)
                )
                error (err ERR_TRANSFER_FAILED)
            )
        )
    )
)

(define-public (claim-reward (amount uint) (signature (buff 65)))
    (begin
        (asserts! (not (is-some (map-get? claimed-rewards {player: tx-sender}))) (err ERR_REWARD_ALREADY_CLAIMED))

        (let (
            (msg-hash (try! (construct-message-hash amount)))
            (recipient tx-sender)
            (fee (/ (* amount FEE_PERCENTAGE) u100))
            (net-amount (- amount fee))
            (has-paid-fee (has-paid-entry-fee tx-sender))
        )
            (asserts! (secp256k1-verify msg-hash signature TRUSTED_PUBLIC_KEY) (err ERR_INVALID_SIGNATURE))
            (asserts! (>= (stx-get-balance (as-contract tx-sender)) amount) (err ERR_INSUFFICIENT_FUNDS))

            ;; handle the fee payment
            (let ((fee-result
                (if (not has-paid-fee)
                    (match (as-contract (stx-transfer? fee tx-sender STACKS_WARS_FEE_WALLET))
                        fee-success
                        (begin
                            ;; Mark fee as collected
                            (map-set collected-fees {player: tx-sender} {paid: true})
                            (ok true)
                        )
                        error (begin
                            (err ERR_FEE_TRANSFER_FAILED)
                        )
                    )
                    (ok true)
                )))

                (try! fee-result)

                ;; Transfer reward to player
                (match (as-contract (stx-transfer? net-amount tx-sender recipient))
                    reward-success
                    (begin
                        (map-set claimed-rewards {player: recipient} {claimed: true, amount: amount})
                        (ok true)
                    )
                    error
                    (begin
                        (err ERR_TRANSFER_FAILED)
                    )
                )
            )
        )
    )
)

(define-public (kick (player-to-kick principal))
    (begin
        (asserts! (is-eq tx-sender DEPLOYER) (err ERR_UNAUTHORIZED))

        (asserts! (is-some (map-get? players {player: player-to-kick})) (err ERR_NOT_JOINED))

        (asserts! (not (is-eq player-to-kick DEPLOYER)) (err ERR_UNAUTHORIZED))

        (asserts! (not (has-claimed-reward player-to-kick)) (err ERR_REWARD_ALREADY_CLAIMED))

        (asserts! (>= (stx-get-balance (as-contract tx-sender)) ENTRY_FEE) (err ERR_INSUFFICIENT_FUNDS))

        (match (as-contract (stx-transfer? ENTRY_FEE tx-sender player-to-kick))
            success
            (begin
                (map-delete players {player: player-to-kick})
                (var-set total-players (- (var-get total-players) u1))
                (ok true)
            )
            error (err ERR_TRANSFER_FAILED)
        )
    )
)

;; ----------------------
;; READ-ONLY FUNCTIONS
;; ----------------------

(define-read-only (get-pool-balance)
    (stx-get-balance (as-contract tx-sender))
)

(define-read-only (get-total-players)
    (var-get total-players)
)

(define-read-only (has-player-joined (player principal))
    (is-some (map-get? players {player: player}))
)

(define-read-only (has-claimed-reward (player principal))
    (default-to false (get claimed (map-get? claimed-rewards {player: player})))
)

(define-read-only (has-paid-entry-fee (player principal))
    (default-to false (get paid (map-get? collected-fees {player: player})))
)

