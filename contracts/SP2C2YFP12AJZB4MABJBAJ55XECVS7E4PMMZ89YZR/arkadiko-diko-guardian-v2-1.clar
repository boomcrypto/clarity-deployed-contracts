;; @contract DIKO Guardian - Get total staking and vault rewards per block
;; @version 2.1

;; Errors
(define-constant ERR-NOT-AUTHORIZED (err u22401))

;; Constants
(define-constant MIN-STAKING-BLOCK-REWARDS u28000000) ;; 28 DIKO
(define-constant STAKING-REWARDS-FIRST-YEAR u25000000000000) ;; 25m with 6 decimals
(define-constant REWARDS-PER-BLOCK-START u320000000) ;; 

;; Variables

;; First version of diko-guardian was deployed on Bitcoin block 705573 (Stacks block 34239)
;; https://explorer.hiro.so/txid/0xe8309941311ab8a40b9e1d6ad50a6f59f52e5b4ea4f2441d8ddeecceffbf7406?chain=mainnet
(define-data-var contract-start-block uint u705573)

;; ---------------------------------------------------------
;; Staking
;; ---------------------------------------------------------

;; Get currrent staking rewards per block for all pools
;; The yearly rewards are reduced by half every year
;; During the year, the rewards are reduced every 2 weeks
(define-read-only (get-staking-rewards-per-block)
  (let (
    ;; 26 steps per year (2 week interval)
    (steps-per-year u26)
    ;; 144 blocks per day, 14 days
    (blocks-per-step u2016)
    (start-block (var-get contract-start-block))
  )
    (asserts! (>= burn-block-height start-block) u0)

    (let (
      ;; each step is equal to 2 weeks. This calculates the current step we are in, since the start
      (step-number (/ (- burn-block-height start-block) blocks-per-step))

      ;; year we are currently in since start
      (year-number (+ (/ step-number steps-per-year) u1))
      ;; step number in the curent year (instead of since start)
      (step-number-current-year (mod step-number steps-per-year))
      ;; rewards are halved every year because of this devider (1, 2, 4, 8, 16)
      (staking-rewards-divider (pow u2 (- year-number u1)))
      ;; the total rewards to distribute in the current year
      (year-rewards (/ STAKING-REWARDS-FIRST-YEAR staking-rewards-divider))
      ;; avg rewards per step (2 weeks)
      (avg-rewards-per-step (/ year-rewards steps-per-year))

      ;; max-percentage = 1.33333, min-percentage = 0.666666
      ;; used to linearly decrease rewards per step in a given year
      (max-percentage (+ u10000000000 (/ u10000000000 u3)))
      (min-percentage (- u10000000000 (/ u10000000000 u3)))
      (step-percentage-diff (/ (- max-percentage min-percentage) steps-per-year))

      ;; based on the avg rewards per step, and the percentages
      (actual-step-rewards (* avg-rewards-per-step (- max-percentage (* step-number-current-year step-percentage-diff))))
      ;; block rewarrds based on step rewards
      (actual-block-rewards (/ (/ actual-step-rewards blocks-per-step) u10000000000))

      ;; Extra multiplier of 98.5% - makes sure we remain below our targets
      (block-rewards (/ (* actual-block-rewards u9850000000) u10000000000))
    )
      ;; Min 28 DIKO
      (if (>= block-rewards MIN-STAKING-BLOCK-REWARDS)
        block-rewards
        MIN-STAKING-BLOCK-REWARDS
      )
    )
  )
)
