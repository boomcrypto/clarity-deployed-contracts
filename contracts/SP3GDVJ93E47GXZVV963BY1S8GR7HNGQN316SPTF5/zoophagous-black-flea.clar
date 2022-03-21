;; constants
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant CONTRACT-OWNER tx-sender)

(define-data-var total-supply uint u0)


;;;;;;;;;;;;;;

(define-read-only (get-balance-this (vault-id principal))
  (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance vault-id)
)

(var-set total-supply (+ (var-get total-supply) (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance 'SP374RMXRCP8SZCWYT21KX7ETY3V2WSQPNGEZ7GF8))))
(var-set total-supply (+ (var-get total-supply) (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance 'SP2G4SF22876WJWMKZPJ95D1R98V2KX1HA8F6REQF))))
(var-set total-supply (+ (var-get total-supply) (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance 'SP2SWNHT2Z548J90EY7M5QCW1GXSZ0PH0CR954SXB))))
(var-set total-supply (+ (var-get total-supply) (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance 'SP2R58JQ881P7QSBXQBF1H2N5CEYX8P06H4DS9B3))))
(var-set total-supply (+ (var-get total-supply) (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance 'SP2SWNHT2Z548J90EY7M5QCW1GXSZ0PH0CR954SXB))))
(var-set total-supply (+ (var-get total-supply) (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance 'SP3RY185H0R8TNX4PGRYFZ07AV001N23N1FJX9MEE))))

(print (var-get total-supply))
