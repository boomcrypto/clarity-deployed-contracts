;; Implementation of fixed fees of 1% for the service
;; by the charging-ctr. Only that contract can call the public functions.

(define-constant fee-receiver tx-sender)

(define-private (is-called-by-charging-ctr)
  (or (is-eq contract-caller .usda-nft-swap-v1)
    (is-eq contract-caller .usda-ft-swap-v1)))


(define-private (calc-fees (usda uint))
  (/ usda u100))

;; For information only.
(define-read-only (get-fees (usda uint))
  (ok (calc-fees usda)))

;; helper function to transfer usda to a principal with memo
(define-private (usda-transfer-to (amount uint) (to principal) (memo (buff 34)))
  (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token  
    transfer amount tx-sender to (some memo)))

;; Hold fees for the given amount in escrow.
(define-public (hold-fees (usda uint))
  (let ((fees (calc-fees usda)))
    (asserts! (is-called-by-charging-ctr) ERR_NOT_AUTH)
    (if (> fees u0)
      (usda-transfer-to fees (as-contract tx-sender) 0x636174616d6172616e2073776170)
      (ok true))))

;; Release fees for the given amount if swap was canceled.
;; It relies on the logic of the charging-ctr that this contract.
(define-public (release-fees (usda uint))
  (let ((user tx-sender)
        (fees (calc-fees usda)))
    (asserts! (is-called-by-charging-ctr) ERR_NOT_AUTH)
    (if (> fees u0)
      (as-contract (usda-transfer-to fees user 0x636174616d6172616e2073776170))
      (ok true))))

;; Pay fee for the given amount if swap was executed.
(define-public (pay-fees (usda uint))
  (let ((fees (calc-fees usda)))
    (asserts! (is-called-by-charging-ctr) ERR_NOT_AUTH)
    (if (> fees u0)
      (as-contract (usda-transfer-to fees fee-receiver 0x636174616d6172616e2073776170))
      (ok true))))

(define-constant ERR_NOT_AUTH (err u404))
