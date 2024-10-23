;; Keeper's Challenge - Interaction Contract

;; Backstory:
;; In the world of Charisma, The Dungeon Keeper is an enigmatic entity that oversees
;; the distribution of Governance Tokens. These tokens grant holders influence over
;; Charisma's future development. The Keeper's Challenge is part of the Interaction
;; Protocol, designed to test the dedication and strategy of participants seeking to
;; shape the world.

;; Game Theory and Incentives:
;; This contract implements a multi-tiered challenge system with varying risk-reward profiles:

;; 1. Petition (Low Risk, Low Reward):
;;    - Lowest energy cost and DMG reward
;;    - Guaranteed success
;;    - Incentivizes regular, low-stakes participation
;;    - Helps new players accumulate resources gradually

;; 2. Challenge (Medium Risk, Medium Reward):
;;    - Higher energy cost and base DMG reward than Petition
;;    - Reward scales with player's experience (EXP) and challenge streak
;;    - Cooldown period between challenges
;;    - Incentivizes consistent participation and EXP accumulation
;;    - Rewards skilled players who can maintain streaks

;; 3. Heist (High Risk, High Reward):
;;    - Highest energy cost and potential DMG reward
;;    - 50% chance of success
;;    - Requires minimum EXP to attempt
;;    - On failure, player loses energy and some EXP
;;    - Incentivizes risk-taking for experienced players
;;    - Creates tension and excitement through randomness

;; Key Incentive Mechanisms:
;; - Energy as a Scarce Resource: All actions require energy, forcing players to strategize
;;   their interactions and potentially invest in energy generation.
;; - Experience (EXP) Boost: Higher EXP increases rewards, encouraging long-term engagement.
;; - Challenge Streak: Consecutive successful challenges increase rewards, promoting regular participation.
;; - Risk-Reward Balance: Players must choose between safe, consistent gains and risky, potentially
;;   higher rewards.
;; - Cooldowns: Prevent excessive farming of high-reward actions, balancing the economy.

;; These mechanics create a dynamic ecosystem where players must balance risk, resource management,
;; and long-term strategy to maximize their influence in the world of Charisma.

(impl-trait .dao-traits-v6.interaction-trait)

;; Constants
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_INVALID_ACTION (err u402))
(define-constant ERR_INSUFFICIENT_ENERGY (err u403))
(define-constant ERR_INSUFFICIENT_EXP (err u404))
(define-constant ERR_COOLDOWN_ACTIVE (err u405))
(define-constant ERR_INVALID_CALLER (err u406))

;; Configuration
(define-data-var contract-owner principal tx-sender)
(define-data-var contract-uri (optional (string-utf8 256)) (some u"https://charisma.rocks/explore/keepers-challenge"))
(define-data-var base-dmg-reward uint u1000000) ;; 1 DMG (6 decimals)
(define-data-var energy-cost-petition uint u500000) ;; 0.5 Energy
(define-data-var energy-cost-challenge uint u2000000) ;; 2 Energy
(define-data-var energy-cost-heist uint u5000000) ;; 5 Energy
(define-data-var exp-boost-factor uint u10) ;; 1% boost per 1000 EXP
(define-data-var challenge-cooldown uint u10) ;; 10 blocks

;; Data Maps
(define-map user-last-challenge principal uint)
(define-map user-challenge-streak principal uint)

;; Read-only functions

(define-read-only (get-interaction-uri)
  (ok (var-get contract-uri))
)

(define-read-only (get-actions)
  (ok (list "PETITION" "CHALLENGE" "HEIST"))
)

(define-private (min (a uint) (b uint)) (if (<= a b) a b))

;; Public functions

(define-public (execute (action (string-ascii 32)))
  (begin
    (asserts! (or (is-eq contract-caller .dungeon-crawler-rc1) (is-eq contract-caller .dungeon-crawler-rc2)) ERR_INVALID_CALLER)
    (if (is-eq action "PETITION")
      (petition)
      (if (is-eq action "CHALLENGE")
        (challenge)
        (if (is-eq action "HEIST")
          (heist)
          ERR_INVALID_ACTION)))))

(define-private (petition)
  (let
    (
      (user-energy (unwrap! (contract-call? .energy get-balance tx-sender) (err u500)))
      (energy-to-spend (var-get energy-cost-petition))
      (base-reward (/ (var-get base-dmg-reward) u2)) ;; Half of base reward
    )
    (asserts! (>= user-energy energy-to-spend) ERR_INSUFFICIENT_ENERGY)
    (try! (contract-call? .dungeon-keeper-rc1 burn-energy tx-sender energy-to-spend))
    (try! (contract-call? .dungeon-keeper-rc1 mint-exp tx-sender u500000)) ;; 0.5 EXP
    (try! (contract-call? .dungeon-keeper-rc1 transfer-dmg (var-get contract-owner) tx-sender base-reward))
    (ok true)
  )
)

(define-private (challenge)
  (let
    (
      (user-energy (unwrap! (contract-call? .energy get-balance tx-sender) (err u500)))
      (user-exp (unwrap! (contract-call? .experience get-balance tx-sender) (err u501)))
      (energy-to-spend (var-get energy-cost-challenge))
      (base-reward (var-get base-dmg-reward))
      (exp-boost (/ (* user-exp (var-get exp-boost-factor)) u1000000))
      (boosted-reward (+ base-reward (/ (* base-reward exp-boost) u100)))
      (last-challenge-block (default-to u0 (map-get? user-last-challenge tx-sender)))
      (current-streak (default-to u0 (map-get? user-challenge-streak tx-sender)))
    )
    (asserts! (>= user-energy energy-to-spend) ERR_INSUFFICIENT_ENERGY)
    (asserts! (>= user-exp u1000000) ERR_INSUFFICIENT_EXP) ;; Require at least 1 EXP
    (asserts! (> block-height (+ last-challenge-block (var-get challenge-cooldown))) ERR_COOLDOWN_ACTIVE)
    
    (try! (contract-call? .dungeon-keeper-rc1 burn-energy tx-sender energy-to-spend))
    (try! (contract-call? .dungeon-keeper-rc1 mint-exp tx-sender u2000000)) ;; 2 EXP
    
    (if (< (- block-height last-challenge-block) (* (var-get challenge-cooldown) u2))
      (map-set user-challenge-streak tx-sender (+ current-streak u1))
      (map-set user-challenge-streak tx-sender u1)
    )
    
    (let
      (
        (streak-bonus (min u5 current-streak)) ;; Max 5x bonus
        (final-reward (* boosted-reward (+ u1 streak-bonus)))
      )
      (try! (contract-call? .dungeon-keeper-rc1 transfer-dmg (var-get contract-owner) tx-sender final-reward))
      (map-set user-last-challenge tx-sender block-height)
      (ok true)
    )
  )
)

(define-private (heist)
  (let
    (
      (user-energy (unwrap! (contract-call? .energy get-balance tx-sender) (err u500)))
      (user-exp (unwrap! (contract-call? .experience get-balance tx-sender) (err u501)))
      (energy-to-spend (var-get energy-cost-heist))
      (base-reward (* (var-get base-dmg-reward) u5)) ;; 5x base reward
      (exp-boost (/ (* user-exp (var-get exp-boost-factor)) u1000000))
      (boosted-reward (+ base-reward (/ (* base-reward exp-boost) u100)))
      (random-seed (unwrap-panic (contract-call? .charisma-randomizer-rc1 get-random-seed)))
      (success-rate (/ (mod random-seed u100) u100))
    )
    (asserts! (>= user-energy energy-to-spend) ERR_INSUFFICIENT_ENERGY)
    (asserts! (>= user-exp u5000000) ERR_INSUFFICIENT_EXP) ;; Require at least 5 EXP
    
    (try! (contract-call? .dungeon-keeper-rc1 burn-energy tx-sender energy-to-spend))
    
    (if (< success-rate u50) ;; 50% chance of success
      (begin
        (try! (contract-call? .dungeon-keeper-rc1 burn-exp tx-sender u1000000)) ;; Burn 1 EXP on failure
        (try! (contract-call? .dungeon-keeper-rc1 transfer-dmg tx-sender (var-get contract-owner) boosted-reward))
        (ok false)
      )
      (begin
        (try! (contract-call? .dungeon-keeper-rc1 mint-exp tx-sender u5000000)) ;; 5 EXP on success
        (try! (contract-call? .dungeon-keeper-rc1 transfer-dmg (var-get contract-owner) tx-sender boosted-reward))
        (ok true)
      )
    )
  )
)

;; Admin functions

(define-public (set-contract-uri (new-uri (optional (string-utf8 256))))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (ok (var-set contract-uri new-uri))
  )
)

(define-public (set-base-dmg-reward (new-reward uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (ok (var-set base-dmg-reward new-reward))
  )
)

(define-public (set-energy-costs (new-petition uint) (new-challenge uint) (new-heist uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (var-set energy-cost-petition new-petition)
    (var-set energy-cost-challenge new-challenge)
    (var-set energy-cost-heist new-heist)
    (ok true)
  )
)

(define-public (set-exp-boost-factor (new-factor uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (ok (var-set exp-boost-factor new-factor))
  )
)

(define-public (set-challenge-cooldown (new-cooldown uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (ok (var-set challenge-cooldown new-cooldown))
  )
)