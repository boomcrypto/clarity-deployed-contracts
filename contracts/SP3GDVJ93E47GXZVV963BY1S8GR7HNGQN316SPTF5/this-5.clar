;; constants
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant CONTRACT-OWNER tx-sender)


;;;;;;;;;;;;;;



(define-public (get-vault (vault-id uint))
  (let ((vault (get-vault-by-id vault-id)))
  (ok (get debt vault)))
)

(define-read-only (get-debt-for-vault (vault-id uint))
  (let ((vault (get-vault-by-id vault-id))) 
    (ok (get debt vault))
  )
)

(define-read-only (get-vault-by-id (vault-id uint))
  (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-vault-data-v1-1 get-vault-by-id vault-id)
)

