;; Dungeon Crawler Contract
;;
;; This contract serves as the primary interface for user interactions within the Charisma protocol.
;; It manages the listing, unlisting, and execution of interactions, as well as coordinating
;; with meme engines for energy generation. The Dungeon Crawler acts as a central hub,
;; orchestrating the flow of actions, rewards, and token operations in the ecosystem.
;;
;; Key Responsibilities:
;; 1. Interaction Management: Handles listing and unlisting of interaction contracts.
;; 2. Action Execution: Coordinates the execution of actions on listed interactions.
;; 3. Energy Generation: Interfaces with meme engines to generate energy based on user actions.
;; 4. Reward Distribution: Manages the minting of experience tokens and payment of royalties.
;; 5. Token Operations: Coordinates burning of energy tokens and transfer of DMG tokens.
;; 6. Charisma Token Wrapping: Attempts to wrap Charisma tokens as an additional reward mechanism.
;;
;; Core Components:
;; - Listed Interactions: Maintains a map of all listed interaction contracts and their parameters.
;; - Tap-Interact Mechanism: Allows users to generate energy through meme engines while interacting.
;; - Verification System: Checks interaction validity and applies appropriate reward logic.
;; - Success-based Rewards: Only distributes rewards for verified and successful interactions.
;;
;; Integration with Charisma Ecosystem:
;; - Dungeon Keeper: Relies on for authorization, parameter checks, and token operations.
;; - Meme Engines: Interfaces with for energy generation during tap-interact actions.
;; - Energy Overload: Manages energy overflow after interactions.
;; - Token Contracts: Coordinates with Experience, Energy, DMG, and Charisma token contracts.
;;
;; Key Functions:
;; - list-interaction: Allows users to list new interaction contracts.
;; - unlist-interaction: Permits owners to remove their listed interactions.
;; - tap-interact: Executes an action while generating energy through a meme engine.
;; - interact: Performs an action on a listed interaction, managing rewards and token operations.
;;
;; Security Features:
;; - Strict checks for interaction listing parameters and authorizations.
;; - Verification of interactions before applying rewards.
;; - Success-based reward distribution to ensure fairness.
;; - Delegation of sensitive operations to the Dungeon Keeper contract.
;;
;; This contract is crucial for enabling user engagement with the Charisma protocol,
;; providing a seamless interface for interactions while ensuring proper energy generation,
;; reward distribution, and ecosystem integrity. It embodies the protocol's innovative
;; approach to stake-less participation, dynamic reward mechanisms, and now includes
;; additional incentives through Charisma token wrapping.

(use-trait interaction-trait .dao-traits-v6.interaction-trait)
(use-trait engine-trait .dao-traits-v6.engine-trait)

;; Error codes
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_PROTOCOL_FROZEN (err u403))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_ALREADY_LISTED (err u409))
(define-constant ERR_INVALID_AMOUNT (err u400))
(define-constant ERR_INTERACTION_FAILED (err u500))
(define-constant ERR_TOKEN_OPERATION_FAILED (err u501))
(define-constant ERR_INVALID_ENGINE (err u502))

;; Maps
(define-map listed-interactions
  principal
  {owner: principal, experience-reward: uint, burn-percentage: uint, royalty-percentage: uint, royalty-address: principal}
)

;; Initialize the listed-interactions map
(map-set listed-interactions .keepers-challange-rc1
  {owner: tx-sender, experience-reward: u10000000, burn-percentage: u100, royalty-percentage: u100, royalty-address: tx-sender}
)

;; Public functions

(define-public (list-interaction (interaction <interaction-trait>) (experience-reward uint) (burn-percentage uint) (royalty-percentage uint) (royalty-address principal))
  (let
    ((interaction-principal (contract-of interaction)))
    (asserts! (not (get listings-frozen (contract-call? .dungeon-keeper-rc1 get-frozen-state))) ERR_PROTOCOL_FROZEN)
    (asserts! (is-none (map-get? listed-interactions interaction-principal)) ERR_ALREADY_LISTED)
    (asserts! (>= burn-percentage (contract-call? .dungeon-keeper-rc1 get-minimum-burn-percentage)) ERR_INVALID_AMOUNT)
    (asserts! (>= experience-reward (contract-call? .dungeon-keeper-rc1 get-minimum-experience-reward)) ERR_INVALID_AMOUNT)
    
    (ok (map-set listed-interactions 
      interaction-principal
      {owner: tx-sender, experience-reward: experience-reward, burn-percentage: burn-percentage, royalty-percentage: royalty-percentage, royalty-address: royalty-address}
    ))
  )
)

(define-public (unlist-interaction (interaction <interaction-trait>))
  (let
    ((interaction-principal (contract-of interaction))
     (listing (unwrap! (map-get? listed-interactions interaction-principal) ERR_NOT_FOUND)))
    (asserts! (not (get unlistings-frozen (contract-call? .dungeon-keeper-rc1 get-frozen-state))) ERR_PROTOCOL_FROZEN)
    (asserts! (is-eq (get owner listing) tx-sender) ERR_UNAUTHORIZED)
    
    (ok (map-delete listed-interactions interaction-principal))
  )
)

(define-public (tap-interact (engine <engine-trait>) (interaction <interaction-trait>) (action (string-ascii 32)))
  (let
    ((engine-contract (contract-of engine))
     (interaction-contract (contract-of interaction))
     (tapped-out (unwrap! (contract-call? engine tap) ERR_INVALID_ENGINE))
     (action-result (unwrap! (interact interaction action) ERR_INTERACTION_FAILED)))
    (asserts! (contract-call? .dungeon-keeper-rc1 is-enabled-engine engine-contract) ERR_INVALID_ENGINE)
    (asserts! (is-some (map-get? listed-interactions interaction-contract)) ERR_NOT_FOUND)
    (try! (contract-call? .energy-overload handle-overflow))
    (print tapped-out)
    (ok action-result)
  )
)

(define-public (interact (interaction <interaction-trait>) (action (string-ascii 32)))
  (let
    ((interaction-contract (contract-of interaction))
     (listing (unwrap! (map-get? listed-interactions interaction-contract) ERR_NOT_FOUND))
     (experience-reward (get experience-reward listing))
     (burn-amount (/ (* experience-reward (get burn-percentage listing)) u10000))
     (royalty-amount (/ (* experience-reward (get royalty-percentage listing)) u10000))
     (royalty-address (get royalty-address listing))
     (is-verified (contract-call? .dungeon-keeper-rc1 is-verified-interaction interaction-contract))
     (is-success (match (contract-call? interaction execute action) success success error false)))
    (asserts! (not (get interactions-frozen (contract-call? .dungeon-keeper-rc1 get-frozen-state))) ERR_PROTOCOL_FROZEN)
    (print {action-success: is-success})
    ;; Burn energy tokens (always burn, regardless of verification)
    (try! (contract-call? .dungeon-keeper-rc1 burn-energy tx-sender burn-amount))
    ;; Only mint experience and transfer royalty if the interaction is verified and successful
    (if (and is-success is-verified)
      (let
        ((max-wrap-amount (unwrap-panic (contract-call? .charisma-token get-max-liquidity-flow))))
        ;; Mint experience tokens to the user
        (try! (contract-call? .dungeon-keeper-rc1 mint-exp tx-sender experience-reward))
        ;; Transfer royalty in DMG tokens (Raven reduction applied)
        (try! (contract-call? .dungeon-keeper-rc1 transfer-dmg tx-sender royalty-address royalty-amount))
        ;; Attempt to win the block reward of wrapping charisma tokens
        (match (contract-call? .charisma-token wrap max-wrap-amount) success true error false)
        (ok is-success)
      )
      (ok is-success)
    )
  )
)

;; Read-only functions

(define-read-only (get-listing (interaction principal))
  (map-get? listed-interactions interaction)
)