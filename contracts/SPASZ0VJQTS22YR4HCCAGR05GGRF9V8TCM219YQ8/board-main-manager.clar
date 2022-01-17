
;; variables
(define-data-var contract-owner principal tx-sender)

;; constants
(define-constant ERR-NOT-AUTHORIZED (err u20501))


;; 
;; Admin
;; 

(define-public (set-contract-owner (address principal))
  (begin
    (asserts! (is-eq (var-get contract-owner) tx-sender) ERR-NOT-AUTHORIZED)
    (var-set contract-owner address)
    (ok true)
  )
)

(define-public (change-contract (name (string-ascii 256)) (address principal) (qualified-name principal) (can-mint bool) (can-burn bool))
  (begin
    (asserts! (is-eq (var-get contract-owner) tx-sender) ERR-NOT-AUTHORIZED)

    (if (not (is-eq name ""))
      (begin
        (try! (contract-call? .board-main change-contract name address qualified-name can-mint can-burn))
        (ok true)
      )
      (ok false)
    )
  )
)
