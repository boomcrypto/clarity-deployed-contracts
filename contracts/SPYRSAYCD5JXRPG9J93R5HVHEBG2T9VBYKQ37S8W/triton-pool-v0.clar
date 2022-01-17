;; Error codes
(define-constant ERR_INSUFFICIENT_FUNDS 1)
(define-constant ERR_PERMISSION_DENIED 2)
(define-constant ERR_STX_TRANSFER 3)

;; Constants
(define-constant LIQUIDITY_PROVIDER 'SPYRSAYCD5JXRPG9J93R5HVHEBG2T9VBYKQ37S8W)

;; State
(define-map rewards-state
    { stacker: principal }
    { amount-ustx: uint })

;; Private Functions
;;-----------------------------------------------------------------

(define-private (check-caller-allowed)
    (is-some (map-get? rewards-state { stacker: tx-sender })))

;; Public Functions
;;-----------------------------------------------------------------
;; This function will only be called by liquidity provider
(define-public (fill-liquidity-pool (amount-ustx uint))
    ;; validate caller as the liquidity provider
    (begin

        (asserts! (is-eq tx-sender LIQUIDITY_PROVIDER)
                (err ERR_PERMISSION_DENIED))
        
        ;; do transfer from liquidity provider to smart contract address
        (unwrap! (stx-transfer? amount-ustx tx-sender (as-contract tx-sender)) (err ERR_INSUFFICIENT_FUNDS))

        ;; if everything succeeds, return ok
        (ok true))
)

;; This function will only be called by liquidity provider
(define-public (set-rewards (stacker principal) (amount-ustx uint))
    (begin

        ;; validate caller as the liquidity provider
        (asserts! (is-eq tx-sender LIQUIDITY_PROVIDER)
                (err ERR_PERMISSION_DENIED))

        ;; populate rewards-state map with the stacker address and reward amount
        ( ok (map-set rewards-state { stacker: stacker } { amount-ustx: amount-ustx })))
)

;; claim rewards from pool
(define-public (claim-rewards)
    (begin        
      (asserts! (check-caller-allowed)
                (err ERR_PERMISSION_DENIED))
      (let ((amnt (default-to u0 (get amount-ustx (map-get? rewards-state { stacker: tx-sender})))))
                (unwrap! (as-contract (stx-transfer? amnt tx-sender tx-sender)) (err ERR_STX_TRANSFER))
                (map-delete rewards-state { stacker: tx-sender})
                (ok true))))