;; Dungeon Crawler Contract
;;
;; This contract serves as the primary interface for user interactions within the Charisma protocol.
;; It acts as a central hub for executing actions across various interaction contracts, enabling
;; users to engage with multiple protocol components in a single transaction.
;;
;; Key Responsibilities:
;; 1. Action Execution: Coordinates the execution of actions on interaction contracts.
;; 2. Multi-Interaction Support: Allows users to execute up to eight different interactions in one transaction.
;; 3. Error Handling: Implements a "best-effort" approach, attempting all interactions even if some fail.
;;
;; Core Components:
;; - Interaction Execution: Provides functions to execute single or multiple interactions.
;; - Error Clobbering: Continues execution of subsequent interactions even if earlier ones fail.
;;
;; Integration with Charisma Ecosystem:
;; - Interaction Contracts: Executes actions on various protocol components through standardized interfaces.
;; - Dungeon Keeper: Relies on for interaction verification and privileged operations (indirectly through interactions).
;; - Token Contracts: Interacts with Experience, Energy, DMG, and Charisma token contracts indirectly through verified interactions.
;;
;; Key Functions:
;; - interact: Executes a single interaction with the specified action.
;; - explore: Executes up to eight different interactions in a single transaction.
;;
;; Security Features:
;; - Interaction Isolation: Each interaction is executed independently, preventing cascading failures.
;; - Non-Privileged Execution: The Dungeon Crawler itself does not perform sensitive operations, relying on properly verified interaction contracts.
;;
;; Error Handling Philosophy:
;; The Dungeon Crawler implements a "best-effort" approach to interaction execution:
;; - In single interactions, errors are propagated to the caller for handling.
;; - In multi-interaction calls, the contract attempts to execute all provided interactions, regardless of individual failures.
;; - This approach ensures maximum utility from each transaction while isolating failures.
;;
;; This contract is crucial for enabling flexible and robust user engagement with the Charisma protocol.
;; It provides a streamlined interface for executing complex sequences of interactions while maintaining
;; system integrity. The architecture supports the protocol's innovative approach to multi-faceted
;; blockchain interactions, allowing for complex operations to be performed in a single transaction.

(use-trait interaction-trait .dao-traits-v7.interaction-trait)

(define-public (interact (interaction <interaction-trait>) (action (string-ascii 32)))
  (contract-call? interaction execute action))

(define-public (explore
  (interaction-1 (optional <interaction-trait>)) (action-1 (optional (string-ascii 32)))
  (interaction-2 (optional <interaction-trait>)) (action-2 (optional (string-ascii 32)))
  (interaction-3 (optional <interaction-trait>)) (action-3 (optional (string-ascii 32)))
  (interaction-4 (optional <interaction-trait>)) (action-4 (optional (string-ascii 32)))
  (interaction-5 (optional <interaction-trait>)) (action-5 (optional (string-ascii 32)))
  (interaction-6 (optional <interaction-trait>)) (action-6 (optional (string-ascii 32)))
  (interaction-7 (optional <interaction-trait>)) (action-7 (optional (string-ascii 32)))
  (interaction-8 (optional <interaction-trait>)) (action-8 (optional (string-ascii 32))))
  (let (
    (response-1 (if (is-some action-1) (unwrap-panic (interact (unwrap-panic interaction-1) (unwrap-panic action-1))) ""))
    (response-2 (if (is-some action-2) (unwrap-panic (interact (unwrap-panic interaction-2) (unwrap-panic action-2))) ""))
    (response-3 (if (is-some action-3) (unwrap-panic (interact (unwrap-panic interaction-3) (unwrap-panic action-3))) ""))
    (response-4 (if (is-some action-4) (unwrap-panic (interact (unwrap-panic interaction-4) (unwrap-panic action-4))) ""))
    (response-5 (if (is-some action-5) (unwrap-panic (interact (unwrap-panic interaction-5) (unwrap-panic action-5))) ""))
    (response-6 (if (is-some action-6) (unwrap-panic (interact (unwrap-panic interaction-6) (unwrap-panic action-6))) ""))
    (response-7 (if (is-some action-7) (unwrap-panic (interact (unwrap-panic interaction-7) (unwrap-panic action-7))) ""))
    (response-8 (if (is-some action-8) (unwrap-panic (interact (unwrap-panic interaction-8) (unwrap-panic action-8))) ""))
    (output {
      i1: interaction-1, r1: response-1,
      i2: interaction-2, r2: response-2,
      i3: interaction-3, r3: response-3,
      i4: interaction-4, r4: response-4,
      i5: interaction-5, r5: response-5,
      i6: interaction-6, r6: response-6,
      i7: interaction-7, r7: response-7,
      i8: interaction-8, r8: response-8
    }))
    (print output)
    (ok output)))