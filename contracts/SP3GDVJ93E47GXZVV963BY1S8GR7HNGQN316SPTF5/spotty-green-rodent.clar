;; constants
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant CONTRACT-OWNER tx-sender)

(define-data-var total-supply uint u0)


;;;;;;;;;;;;;;

(define-read-only (get-balance (vault-id principal))
  (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance vault-id)
)


;;(var-set total-supply (+ (var-get total-supply) (get-balance 'SP2T5YZ2YPPTRJFNP1KSSD7GN14SATEA89NANJ8N0)))


;;(print (var-get total-supply))
(print (get-balance 'SP2T5YZ2YPPTRJFNP1KSSD7GN14SATEA89NANJ8N0))