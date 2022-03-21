;; constants
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant CONTRACT-OWNER tx-sender)

(define-data-var total-supply uint u0)


;;;;;;;;;;;;;;

(define-read-only (get-balance-this (vault-id principal))
  (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance vault-id)
)

(var-set total-supply (+ (var-get total-supply) (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance 'SP374RMXRCP8SZCWYT21KX7ETY3V2WSQPNGEZ7GF8))))

(print (var-get total-supply))
