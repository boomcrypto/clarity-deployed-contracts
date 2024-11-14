;; Charisma - Aura
;;
;; Purpose:
;; This contract, named Aura, manages incentive scores for tokens or contracts 
;; within the Charisma ecosystem. It embodies the concept of an aura, representing 
;; the influential presence or charm of different tokens in the protocol. The contract 
;; provides a mechanism to set and retrieve incentive scores for different principals, 
;; which is used to scale the energy production of staked tokens up or down.
;;
;; Key Features:
;; 1. Incentive Score Management: Maintains an incentive score for each token principal 
;;    ranging from 0 to 1,000,000 (representing 0% to 10,000%, or 100x).
;;    - A score of 10,000 represents 100% (1x)
;;    - The maximum score of 1,000,000 represents 10,000% (100x)
;;    - The default score is 10,000 (100%)
;;
;; 2. DAO Governance: This contract is governed by a DAO system, where actions can be performed
;;    by either the DAO contract itself or authorized extensions.
;;
;; Usage:
;; - The DAO or its authorized extensions can set and update incentive scores for various principals.
;; - Other contracts or users can query this contract to read the current incentive scores.
;; - These scores can be used in calculations for reward distribution, voting power, 
;;   or other mechanisms within the Charisma ecosystem.

;; Constants
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_SCORE (err u101))
(define-constant MAX_SCORE u1000000)  ;; Represents 10,000% or 100x
(define-constant DEFAULT_SCORE u10000)  ;; Represents 100% or 1x

;; Maps
(define-map incentive-scores principal uint)

;; Read-only functions

(define-read-only (get-incentive-score (token principal))
  (default-to DEFAULT_SCORE (map-get? incentive-scores token))
)

;; DAO authorization check
(define-read-only (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) ERR_UNAUTHORIZED))
)

;; Public functions

(define-public (set-incentive-score (token principal) (score uint))
  (begin
    (try! (is-dao-or-extension))
    (asserts! (<= score MAX_SCORE) ERR_INVALID_SCORE)
    (ok (map-set incentive-scores token score))
  )
)