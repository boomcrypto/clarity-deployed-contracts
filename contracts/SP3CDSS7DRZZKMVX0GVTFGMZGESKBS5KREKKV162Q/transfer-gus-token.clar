;; ---------------------------------------------------------
;; Constants/Variables
;; ---------------------------------------------------------
(define-data-var amount uint u0)
(define-constant contract-owner tx-sender)

;; ---------------------------------------------------------
;; Errors
;; ---------------------------------------------------------
(define-constant ERR_UNAUTHORIZED (err u100))

;; ---------------------------------------------------------
;; Utility Functions
;; ---------------------------------------------------------
(define-public (set-transfer-amount (value uint))
  (if (is-eq tx-sender contract-owner)
    (ok (var-set amount value))
    (err ERR_UNAUTHORIZED)
  )
)

(define-public (bulk-transfer-gus (receivers (list 1000 principal)))
    (begin
        (print (map transfer receivers))
        (ok true)
    )
)

(define-read-only (get-transfer-amount)
    (ok (var-get amount))
)

(define-private (transfer (receiver principal))
    (contract-call? 'SP1JFFSYTSH7VBM54K29ZFS9H4SVB67EA8VT2MYJ9.gus-token transfer (var-get amount) tx-sender receiver none)
)