;; Trustless Token Faucet Contract
;; A fully decentralized faucet with streak-based rewards
;; No admin controls - trustless operation once deployed

;; === ERRORS ===
(define-constant err-cooldown-active (err u101))
(define-constant err-insufficient-faucet-balance (err u102))
(define-constant err-invalid-user (err u103))
(define-constant err-transfer-failed (err u104))
(define-constant err-invalid-deposit (err u105))

;; === CONSTANTS ===
(define-constant CONTRACT (as-contract tx-sender))
(define-constant COOLDOWN-BLOCKS u17280) ;; ~24 hours at 5 seconds per block
(define-constant STREAK-WINDOW u34560) ;; ~48 hours for streak maintenance
(define-constant TIER-1-REWARD u50000000) ;; 50M tokens (days 1-3)
(define-constant TIER-2-REWARD u75000000) ;; 75M tokens (days 4-7)
(define-constant TIER-3-REWARD u100000000) ;; 100M tokens (days 8-14)
(define-constant TIER-4-REWARD u125000000) ;; 125M tokens (days 15+)

;; === DATA MAPS ===
;; Track user claim data
(define-map user-claims
  principal
  {
    last-claim-block: uint,
    streak-count: uint,
    total-claims: uint,
    total-claimed: uint,
  }
)

;; Global statistics
(define-data-var total-distributed uint u0)

;; === PRIVATE FUNCTIONS ===

;; Calculate reward based on streak count
(define-private (calculate-reward (streak uint))
  (if (>= streak u15)
    TIER-4-REWARD
    (if (>= streak u8)
      TIER-3-REWARD
      (if (>= streak u4)
        TIER-2-REWARD
        TIER-1-REWARD
      )
    )
  )
)

;; Check if user can claim now
(define-private (is-valid-claim (user principal))
  (let (
      (current-block stacks-block-height)
      (user-data (default-to {
        last-claim-block: u0,
        streak-count: u0,
        total-claims: u0,
        total-claimed: u0,
      }
        (map-get? user-claims user)
      ))
    )
    (let (
        (last-claim-block (get last-claim-block user-data))
        (time-since-last (- current-block last-claim-block))
      )
      ;; Must wait for cooldown period
      (>= time-since-last COOLDOWN-BLOCKS)
    )
  )
)

;; Update user data after successful claim
(define-private (update-user-data
    (user principal)
    (reward-amount uint)
  )
  (let (
      (current-block stacks-block-height)
      (user-data (default-to {
        last-claim-block: u0,
        streak-count: u0,
        total-claims: u0,
        total-claimed: u0,
      }
        (map-get? user-claims user)
      ))
    )
    (let (
        (last-claim-block (get last-claim-block user-data))
        (current-streak (get streak-count user-data))
        (time-since-last (- current-block last-claim-block))
      )
      ;; Calculate new streak: increment if within window, reset to 1 if expired
      (let ((new-streak (if (or
            (is-eq last-claim-block u0)
            (> time-since-last STREAK-WINDOW)
          )
          u1 ;; Reset streak if first claim or window expired
          (+ current-streak u1)
        )))
        ;; Increment streak
        ;; Update user data
        (map-set user-claims user {
          last-claim-block: current-block,
          streak-count: new-streak,
          total-claims: (+ (get total-claims user-data) u1),
          total-claimed: (+ (get total-claimed user-data) reward-amount),
        })
        ;; Update global statistics
        (var-set total-distributed (+ (var-get total-distributed) reward-amount))
        ;; Log claim event for off-chain analytics
        (print {
          event: "claim",
          user: user,
          amount: reward-amount,
          streak: new-streak,
          block: current-block,
          total-claims: (+ (get total-claims user-data) u1),
        })
        new-streak
      )
    )
  )
)

;; === PUBLIC FUNCTIONS ===

;; Main claim function
(define-public (claim-tokens)
  (let ((claimer tx-sender))
    ;; Validate user can claim
    (asserts! (is-valid-claim claimer) err-cooldown-active)
    ;; Get user data to calculate reward
    (let ((user-data (default-to {
        last-claim-block: u0,
        streak-count: u0,
        total-claims: u0,
        total-claimed: u0,
      }
        (map-get? user-claims claimer)
      )))
      (let (
          (current-streak (get streak-count user-data))
          (last-claim-block (get last-claim-block user-data))
          (time-since-last (- stacks-block-height last-claim-block))
        )
        ;; Calculate new streak for reward calculation
        (let ((reward-streak (if (or
              (is-eq last-claim-block u0)
              (> time-since-last STREAK-WINDOW)
            )
            u1 ;; First claim or streak reset
            (+ current-streak u1)
          )))
          ;; Streak continues
          (let ((reward-amount (calculate-reward reward-streak)))
            ;; Check faucet has enough balance
            (let ((faucet-balance (unwrap-panic (contract-call? .tropical-blue-bonobo get-balance CONTRACT))))
              (asserts! (>= faucet-balance reward-amount)
                err-insufficient-faucet-balance
              )
              ;; Transfer tokens from faucet to claimer
              (match (as-contract (contract-call? .tropical-blue-bonobo transfer reward-amount tx-sender claimer
                none
              ))
                success (begin
                  ;; Update user data and log event
                  (update-user-data claimer reward-amount)
                  ;; Log streak milestone if applicable
                  (if (or
                      (is-eq reward-streak u4)
                      (is-eq reward-streak u8)
                      (is-eq reward-streak u15)
                    )
                    (print {
                      event: "streak_milestone",
                      user: claimer,
                      streak: reward-streak,
                      tier: (if (>= reward-streak u15)
                        u4
                        (if (>= reward-streak u8)
                          u3
                          (if (>= reward-streak u4)
                            u2
                            u1
                          )
                        )
                      ),
                    })
                    (print {
                      event: "streak_milestone",
                      user: claimer,
                      streak: reward-streak,
                      tier: u0,
                    })
                  )
                  (ok reward-amount)
                )
                error
                err-transfer-failed
              )
            )
          )
        )
      )
    )
  )
)

;; Deposit tokens to the faucet (anyone can contribute)
(define-public (deposit-tokens (amount uint))
  (begin
    (asserts! (>= amount u1) err-invalid-deposit)
    ;; Transfer tokens from sender to faucet contract
    (match (contract-call? .tropical-blue-bonobo transfer amount tx-sender CONTRACT none)
      success (begin
        ;; Log deposit event for off-chain analytics
        (print {
          event: "deposit",
          depositor: tx-sender,
          amount: amount,
          block: stacks-block-height,
        })
        (ok amount)
      )
      error
      err-transfer-failed
    )
  )
)

;; === READ-ONLY FUNCTIONS ===

;; Get user's claim data
(define-read-only (get-claim-data (user principal))
  (let (
      (user-data (default-to {
        last-claim-block: u0,
        streak-count: u0,
        total-claims: u0,
        total-claimed: u0,
      }
        (map-get? user-claims user)
      ))
      (current-block stacks-block-height)
    )
    (let (
        (last-claim-block (get last-claim-block user-data))
        (time-since-last (- current-block last-claim-block))
        (can-claim (is-valid-claim user))
        (time-until-next (if can-claim
          u0
          (- COOLDOWN-BLOCKS time-since-last)
        ))
      )
      (merge user-data {
        can-claim-now: can-claim,
        time-until-next-claim: time-until-next,
        next-claim-block: (+ last-claim-block COOLDOWN-BLOCKS),
        current-reward: (calculate-reward (get streak-count user-data)),
      })
    )
  )
)

;; Check if user can claim right now
(define-read-only (can-claim-now (user principal))
  (is-valid-claim user)
)

;; Get current reward amount for user
(define-read-only (get-current-reward (user principal))
  (let ((user-data (default-to {
      last-claim-block: u0,
      streak-count: u0,
      total-claims: u0,
      total-claimed: u0,
    }
      (map-get? user-claims user)
    )))
    (calculate-reward (get streak-count user-data))
  )
)

;; Get reward amount for specific streak count
(define-read-only (get-reward-for-streak (streak uint))
  (calculate-reward streak)
)

;; Get when user can claim next (block height)
(define-read-only (get-next-claim-block (user principal))
  (let ((user-data (default-to {
      last-claim-block: u0,
      streak-count: u0,
      total-claims: u0,
      total-claimed: u0,
    }
      (map-get? user-claims user)
    )))
    (+ (get last-claim-block user-data) COOLDOWN-BLOCKS)
  )
)

;; Get faucet balance
(define-read-only (get-faucet-balance)
  (unwrap-panic (contract-call? .tropical-blue-bonobo get-balance CONTRACT))
)

;; Get global faucet statistics
(define-read-only (get-faucet-stats)
  {
    total-distributed: (var-get total-distributed),
    current-balance: (get-faucet-balance),
    cooldown-blocks: COOLDOWN-BLOCKS,
    streak-window-blocks: STREAK-WINDOW,
    current-block: stacks-block-height,
    tier-1-reward: TIER-1-REWARD,
    tier-2-reward: TIER-2-REWARD,
    tier-3-reward: TIER-3-REWARD,
    tier-4-reward: TIER-4-REWARD,
  }
)
