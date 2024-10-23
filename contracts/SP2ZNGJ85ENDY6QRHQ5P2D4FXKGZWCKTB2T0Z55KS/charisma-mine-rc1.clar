;; Charisma Token Interaction Wrapper
;;
;; This contract serves as a critical interface for the Charisma token within the 
;; Charisma protocol's interaction-based system. It implements the interaction-trait,
;; allowing for seamless integration with the protocol's exploration mechanism.
;;
;; Primary Purpose:
;; The main goal of this contract is to decentralize the wrapping and unwrapping of 
;; Charisma tokens, enabling fair and distributed participation across the ecosystem.
;; By making these actions available as interactions, the contract allows any user to 
;; initiate token wrapping or unwrapping as part of their exploration activities.
;;
;; Key Features:
;; 1. Decentralized Token Wrapping: Enables any user to wrap Charisma tokens during exploration.
;; 2. Decentralized Token Unwrapping: Allows users to unwrap tokens as part of the ecosystem interactions.
;; 3. Integration with Exploration: Can be included in every explore request, distributing wrapping opportunities.
;; 4. Liquidity Flow Control: Utilizes max liquidity flow limits from the Charisma token contract.
;;
;; Actions:
;; - WRAP: Wraps the maximum allowed amount of Charisma tokens.
;; - UNWRAP: Unwraps the maximum allowed amount of Charisma tokens.
;;
;; Integration with Charisma Ecosystem:
;; - Implements the interaction-trait for compatibility with the exploration system.
;; - Interacts directly with the Charisma token contract for wrapping and unwrapping operations.
;; - Can be included in the Dungeon Crawler's explore function for widespread accessibility.
;;
;; Significance in the Ecosystem:
;; 1. Fair Distribution: By allowing wrapping as part of exploration, it prevents centralization of wrapped tokens.
;; 2. Increased Participation: Encourages more users to engage with the wrapped token ecosystem.
;; 3. Dynamic Liquidity: Helps maintain a balanced pool of wrapped and unwrapped tokens.
;; 4. Ecosystem Integration: Seamlessly integrates token wrapping into the core protocol activities.
;;
;; Security and Control:
;; - Utilizes max liquidity flow limits to prevent excessive wrapping or unwrapping.
;; - Admin function for updating the contract URI, controlled by the contract owner.
;;
;; Usage in Exploration:
;; When included in explore requests, this contract allows users to potentially wrap or unwrap 
;; tokens with each exploration action. This mechanism ensures that token wrapping opportunities 
;; are fairly distributed among all active participants in the Charisma ecosystem.
;;
;; By enabling decentralized and fair access to token wrapping and unwrapping, this contract 
;; plays a crucial role in maintaining the health and balance of the Charisma token ecosystem.
;; It embodies the protocol's commitment to distributed participation and equal opportunity 
;; for all users engaging with the Charisma platform.

;; Implement the interaction-trait
(impl-trait .dao-traits-v6.interaction-trait)

;; Constants
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_INVALID_ACTION (err u402))
(define-constant CONTRACT_OWNER tx-sender)

;; Data Variables
(define-data-var contract-uri (optional (string-utf8 256)) (some u"https://charisma.rocks/explore/charisma-mine"))

;; Read-only functions

(define-read-only (get-interaction-uri)
  (ok (var-get contract-uri))
)

(define-read-only (get-actions)
  (ok (list "WRAP" "UNWRAP"))
)

;; Public functions

(define-public (execute (action (string-ascii 32)))
  (let ((sender tx-sender))
    (if (is-eq action "WRAP")
      (wrap-action sender)
      (if (is-eq action "UNWRAP")
        (unwrap-action sender)
        ERR_INVALID_ACTION
      )
    )
  )
)

;; Private functions

(define-private (wrap-action (sender principal))
  (let ((amount (unwrap! (contract-call? .charisma-token get-max-liquidity-flow) ERR_UNAUTHORIZED)))
    (match (contract-call? .charisma-token wrap amount) success true error false)
    (ok true)
  )
)

(define-private (unwrap-action (sender principal))
  (let ((amount (unwrap! (contract-call? .charisma-token get-max-liquidity-flow) ERR_UNAUTHORIZED)))
    (match (contract-call? .charisma-token unwrap amount) success true error false)
    (ok true)
  )
)

;; Admin functions

(define-public (set-contract-uri (new-uri (optional (string-utf8 256))))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (ok (var-set contract-uri new-uri))
  )
)