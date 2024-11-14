---
title: "Trait charisma-client-rc5"
draft: true
---
```
;; Charisma Interaction Client
;;
;; Purpose:
;; This contract serves as the primary entry point and orchestrator for the Charisma protocol,
;; implementing the core energy generation, interaction, and reward mechanisms described in 
;; the Charisma white paper. It acts as a central hub, connecting various components of the 
;; ecosystem to provide a seamless and flexible user experience.
;;
;; Key Features:
;; 1. Energy Generation: Facilitates the calculation and minting of energy based on users' 
;;    token balance history, leveraging approved energy generator contracts.
;;
;; 2. Interaction Management: Enables two types of actions within the ecosystem:
;;    a) Standard Actions: Require energy generation and can access both standard and free interactions.
;;    b) Free Actions: Can be performed without energy generation but still incur a burn fee.
;;
;; 3. Dynamic Fee System: Implements a burn fee mechanism with reductions based on Raven NFT 
;;    ownership, balancing ecosystem sustainability with user incentives.
;;
;; 4. Modular Design: Maintains separate whitelists for energy generators and interactions,
;;    allowing for flexible ecosystem expansion and governance.
;;
;; 5. Energy Efficiency: Manages unused energy, including special provisions for Memobot NFT holders,
;;    encouraging efficient use of generated energy.
;;
;; 6. Governance Integration: Enables DAO-controlled management of system parameters and whitelists,
;;    ensuring adaptability and community-driven evolution of the protocol.
;;
;; This contract embodies the Charisma protocol's innovative approach to token staking and 
;; ecosystem interaction. It eliminates the need for traditional staking pools, allowing users 
;; to retain control of their tokens while earning and utilizing protocol rewards through energy 
;; generation and strategic actions.
;;
;; The underlying energy calculation mechanism, implemented in separate generator contracts,
;; uses integral calculus to compute staking output retroactively. This approach ensures a 
;; fair, time-weighted representation of users' token holdings, incentivizing long-term 
;; participation in the ecosystem.
;;
;; By serving as a flexible foundation for various applications in DeFi, GameFi, and beyond,
;; this contract opens up a wide range of possibilities for developers to build upon the 
;; Charisma protocol, creating a rich and diverse ecosystem of interconnected applications 
;; and services.

;; Traits
(use-trait sip10-trait .dao-traits-v4.sip010-ft-trait)
(define-trait interaction-trait
  (
    (get-interaction-uri () (response (optional (string-utf8 256)) uint))
    (take-action ((string-ascii 32)) (response bool uint))
  )
)
(define-trait generator-trait
  (
    (tap () (response uint uint))
  )
)

;; Constants
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INSUFFICIENT_DMG (err u101))
(define-constant ERR_INVALID_GENERATOR (err u102))
(define-constant ERR_INVALID_INTERACTION (err u103))

(define-constant FEE-SCALE u1000000) ;; 1 DMG (with 6 decimal places)

;; Data Variables
(define-data-var dmg-burn-fee uint u1000000) ;; 1 DMG initially

;; Maps
(define-map enabled-generators principal bool)
(define-map enabled-standard-interactions principal bool)
(define-map enabled-free-interactions principal bool)

;; Authorization checks
(define-private (is-dao-or-extension)
    (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller))
)

;; Public functions
(define-public (standard-action (generator <generator-trait>) (interaction <interaction-trait>) (action (string-ascii 32)))
    (let
        (
            (generator-contract (contract-of generator))
            (interaction-contract (contract-of interaction))
            (tapped-out (unwrap-panic (contract-call? generator tap)))
            (action-result (unwrap-panic (free-action interaction action)))
        )
        (asserts! (is-enabled-generator generator-contract) ERR_INVALID_GENERATOR)
        (asserts! (is-enabled-standard-interaction interaction-contract) ERR_INVALID_INTERACTION)
        (try! (contract-call? .energy-overflow handle-overflow))
        (print {tapped-out: tapped-out})
        (ok action-result)
    )
)

(define-public (free-action (interaction <interaction-trait>) (action (string-ascii 32)))
    (let
        (
            (interaction-contract (contract-of interaction))
            (burn-amount (calculate-burn-fee tx-sender))
            (action-result (unwrap-panic (contract-call? interaction take-action action)))
        )
        (asserts! (is-enabled-free-interaction interaction-contract) ERR_INVALID_INTERACTION)
        (try! (burn-protocol-fee burn-amount))
        (print {action-result: action-result})
        (ok action-result)
    )
)

(define-public (set-burn-fee (new-fee uint))
    (begin
        (asserts! (is-dao-or-extension) ERR_UNAUTHORIZED)
        (ok (var-set dmg-burn-fee new-fee))
    )
)

(define-public (add-generator (generator principal))
    (begin
        (asserts! (is-dao-or-extension) ERR_UNAUTHORIZED)
        (ok (map-set enabled-generators generator true))
    )
)

(define-public (remove-generator (generator principal))
    (begin
        (asserts! (is-dao-or-extension) ERR_UNAUTHORIZED)
        (ok (map-delete enabled-generators generator))
    )
)

(define-public (add-standard-interaction (interaction principal))
    (begin
        (asserts! (is-dao-or-extension) ERR_UNAUTHORIZED)
        (ok (map-set enabled-standard-interactions interaction true))
    )
)

(define-public (remove-standard-interaction (interaction principal))
    (begin
        (asserts! (is-dao-or-extension) ERR_UNAUTHORIZED)
        (ok (map-delete enabled-standard-interactions interaction))
    )
)

(define-public (add-free-interaction (interaction principal))
    (begin
        (asserts! (is-dao-or-extension) ERR_UNAUTHORIZED)
        (ok (map-set enabled-free-interactions interaction true))
    )
)

(define-public (remove-free-interaction (interaction principal))
    (begin
        (asserts! (is-dao-or-extension) ERR_UNAUTHORIZED)
        (ok (map-delete enabled-free-interactions interaction))
    )
)

;; Read-only functions
(define-read-only (get-burn-fee)
    (var-get dmg-burn-fee)
)

(define-read-only (is-enabled-generator (generator principal))
    (default-to false (map-get? enabled-generators generator))
)

(define-read-only (is-enabled-standard-interaction (interaction principal))
    (or 
        (default-to false (map-get? enabled-standard-interactions interaction))
        (default-to false (map-get? enabled-free-interactions interaction))
    )
)

(define-read-only (is-enabled-free-interaction (interaction principal))
    (default-to false (map-get? enabled-free-interactions interaction))
)

;; Private functions
(define-private (calculate-burn-fee (user principal))
  (let
    (
      (base-fee (var-get dmg-burn-fee))
      (burn-reduction (contract-call? .raven-reduction get-burn-reduction user))
    )
    (- base-fee (/ (* base-fee burn-reduction) FEE-SCALE))
  )
)

(define-private (burn-protocol-fee (amount uint))
  (if (> amount u0)
      (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-burn amount tx-sender)
      (ok true)
  )
)
```
