;; @contract Reserve
;; @version 1
;;
;; This contract holds all STX that is not stacking.
;; It also tracks the STX that is currently stacking, 
;; and the STX needed for withdrawals after the current cycle.

(impl-trait .reserve-trait-v1.reserve-trait)

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_SHUTDOWN u17002)
(define-constant ERR_BLOCK_INFO u17003)

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var stx-stacking uint u0)
(define-data-var stx-for-withdrawals uint u0)

;;-------------------------------------
;; Getters 
;;-------------------------------------

;; Amount of STX locked for withdrawals
(define-read-only (get-stx-for-withdrawals)
  (ok (var-get stx-for-withdrawals))
)

;; Amount of STX currently used in stacking
(define-read-only (get-stx-stacking)
  (ok (var-get stx-stacking))
)

;; Amount of STX used in stacking at given block
(define-read-only (get-stx-stacking-at-block (block uint))
  (at-block
    (unwrap! (get-block-info? id-header-hash block) (err ERR_BLOCK_INFO))
    (get-stx-stacking)
  )
)

;; Contract balance
(define-read-only (get-stx-balance)
  (ok (stx-get-balance (as-contract tx-sender)))
)

;; Total STX = contract balance + used in stacking
(define-read-only (get-total-stx)
  (ok (+ (unwrap-panic (get-stx-balance)) (unwrap-panic (get-stx-stacking))))
)

;;-------------------------------------
;; Withdrawals
;;-------------------------------------

(define-public (lock-stx-for-withdrawal (stx-amount uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (var-set stx-for-withdrawals (+ (var-get stx-for-withdrawals) stx-amount))
    (ok stx-amount)
  )
)

(define-public (request-stx-for-withdrawal (requested-stx uint) (receiver principal))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (var-set stx-for-withdrawals (- (var-get stx-for-withdrawals) requested-stx))
    (try! (as-contract (stx-transfer? requested-stx tx-sender receiver)))
    (ok requested-stx)
  )
)

;;-------------------------------------
;; Stacking 
;;-------------------------------------

(define-public (request-stx-to-stack (requested-stx uint))
  (let (
    (receiver contract-caller)
  )
    (try! (contract-call? .dao check-is-protocol contract-caller))
    (try! (contract-call? .dao check-is-enabled))

    (var-set stx-stacking (+ (unwrap-panic (get-stx-stacking)) requested-stx))
    (try! (as-contract (stx-transfer? requested-stx tx-sender receiver)))
    (ok requested-stx)
  )
)

(define-public (return-stx-from-stacking (stx-amount uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))
    (try! (contract-call? .dao check-is-enabled))

    (var-set stx-stacking (- (unwrap-panic (get-stx-stacking)) stx-amount))
    (try! (stx-transfer? stx-amount tx-sender (as-contract tx-sender)))
    (ok stx-amount)
  )
)

;;-------------------------------------
;; Get STX 
;;-------------------------------------

(define-public (get-stx (requested-stx uint) (receiver principal))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (try! (as-contract (stx-transfer? requested-stx tx-sender receiver)))
    (ok requested-stx)
  )
)
