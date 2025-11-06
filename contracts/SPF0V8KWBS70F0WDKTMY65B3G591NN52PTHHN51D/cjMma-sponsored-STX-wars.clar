

;; ==============================
;; Stacks Wars - Sponsored Pool Contract
;; ==============================
;; author: flames.stx
;; summary: Sponsored pool using STX

;; ----------------------
;; CONSTANTS
;; ----------------------

(define-constant STACKS_WARS_FEE_WALLET 'SP299MBHT7FPPP2SKEY73V4DHW67467SED87A4HH4)
(define-constant TRUSTED_PUBLIC_KEY 0x02cec878c505b9626fac2363f8566c9fb256e53a78bd3d6ed1297f9399d67c89fb)
(define-constant FEE_PERCENTAGE u2)
(define-constant DEPLOYER 'SPF0V8KWBS70F0WDKTMY65B3G591NN52PTHHN51D)
(define-constant POOL_SIZE u25000000)

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
(define-constant ERR_REENTRANCY u13)
(define-constant ERR_NOT_JOINED u14)
(define-constant ERR_NOT_SPONSORED u15)
(define-constant ERR_POOL_NOT_EMPTY u16)
(define-constant ERR_UNAUTHORIZED u17)

;; ----------------------
;; DATA VARIABLES
;; ----------------------

(define-data-var total-players uint u0)
(define-data-var pool-funded bool false)
(define-map players {player: principal} {joined-at: uint, is-sponsor: bool})
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

        (if (is-eq tx-sender DEPLOYER)
            ;; Deployer joining funds the pool
            (begin
                ;; Ensure pool isn't already funded
                (asserts! (not (var-get pool-funded)) (err ERR_ALREADY_JOINED))

                (match (stx-transfer? POOL_SIZE tx-sender (as-contract tx-sender))
                    success
                    (begin
                        (map-set players {player: tx-sender} {joined-at: stacks-block-height, is-sponsor: true})
                        (var-set total-players (+ (var-get total-players) u1))
                        (var-set pool-funded true)
                        (ok true)
                    )
                    error (err ERR_TRANSFER_FAILED)
                )
            )
            ;; Regular player joining
            (begin
                ;; Ensure pool is funded
                (asserts! (var-get pool-funded) (err ERR_NOT_SPONSORED))

                (map-set players {player: tx-sender} {joined-at: stacks-block-height, is-sponsor: false})
                (var-set total-players (+ (var-get total-players) u1))
                (ok true)
            )
        )
    )
)

(define-public (leave (signature (buff 65)))
    (begin
        (let ((player-data (unwrap! (map-get? players {player: tx-sender}) (err ERR_NOT_JOINED))))
            (if (get is-sponsor player-data)
                (begin
                    (asserts! (is-eq (var-get total-players) u1) (err ERR_POOL_NOT_EMPTY))

                    ;; Verify signature for pool size amount
                    (let (
                        (msg-hash (try! (construct-message-hash POOL_SIZE)))
                        (balance (stx-get-balance (as-contract tx-sender)))
                    )
                        (asserts! (secp256k1-verify msg-hash signature TRUSTED_PUBLIC_KEY) (err ERR_INVALID_SIGNATURE))
                        (match (as-contract (stx-transfer? balance tx-sender DEPLOYER))
                            success
                            (begin
                                (map-delete players {player: tx-sender})
                                (var-set total-players (- (var-get total-players) u1))
                                (var-set pool-funded false)
                                (ok true)
                            )
                            error (err ERR_TRANSFER_FAILED)
                        )
                    )
                )

                (begin
                    (let ((msg-hash (try! (construct-message-hash u0))))
                        (asserts! (secp256k1-verify msg-hash signature TRUSTED_PUBLIC_KEY) (err ERR_INVALID_SIGNATURE))

                        (map-delete players {player: tx-sender})
                        (var-set total-players (- (var-get total-players) u1))
                        (ok true)
                    )
                )
            )
        )
    )
)

(define-public (claim-reward (amount uint) (signature (buff 65)))
    (begin
        (asserts! (is-some (map-get? players {player: tx-sender})) (err ERR_NOT_JOINED))
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

            (let ((fee-result
                (if (not has-paid-fee)
                    (match (as-contract (stx-transfer? fee tx-sender STACKS_WARS_FEE_WALLET))
                        fee-success
                        (begin
                            (map-set collected-fees {player: tx-sender} {paid: true})
                            (ok true)
                        )
                        fee-error (begin
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
                    reward-error (err ERR_TRANSFER_FAILED)
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

        (let ((player-data (unwrap! (map-get? players {player: player-to-kick}) (err ERR_NOT_JOINED))))
            (begin
                (map-delete players {player: player-to-kick})
                (var-set total-players (- (var-get total-players) u1))

                (ok true)
            )
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

(define-read-only (is-pool-sponsored)
    (var-get pool-funded)
)

(define-read-only (has-claimed-reward (player principal))
    (default-to false (get claimed (map-get? claimed-rewards {player: player})))
)

(define-read-only (has-paid-entry-fee (player principal))
    (default-to false (get paid (map-get? collected-fees {player: player})))
)

