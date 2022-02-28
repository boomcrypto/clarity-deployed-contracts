;; Implementation of fixed fees of 1% for the service
;; by the charging-ctr. Only that contract can call the public functions.

(define-constant fee-receiver tx-sender)

(define-private (is-called-by-charging-ctr)
  (or (is-eq contract-caller .satoshible-nft-swap-v1)
    (is-eq contract-caller .satoshible-ft-swap-v1)))

(define-private (calc-fees (nft-id uint))
  u5000000)

;; For information only.
(define-read-only (get-fees (nft-id uint))
  (ok (calc-fees nft-id)))

;; helper function to transfer banana from tx-sender to a principal with memo
(define-private (asset-transfer-to (nft-id uint) (to principal) (memo (buff 34)))
  (begin
    (try! (stx-transfer? (calc-fees nft-id) tx-sender to))
    (print memo)
    (ok true)))

;; Hold fees for the given amount in escrow.
(define-public (hold-fees (nft-id uint))
  (let ((fees (calc-fees nft-id)))
    (asserts! (is-called-by-charging-ctr) ERR_NOT_AUTH)
    (if (> fees u0)
      (asset-transfer-to fees (as-contract tx-sender) 0x636174616d6172616e2073776170)
      (ok true))))

;; Release fees for the given amount if swap was canceled.
;; It relies on the logic of the charging-ctr that this contract.
(define-public (release-fees (nft-id uint))
  (let ((user tx-sender)
        (fees (calc-fees nft-id)))
    (asserts! (is-called-by-charging-ctr) ERR_NOT_AUTH)
    (if (> fees u0)
      (as-contract (asset-transfer-to fees user 0x636174616d6172616e2073776170))
      (ok true))))

;; Pay fee for the given amount if swap was executed.
(define-public (pay-fees (nft-id uint))
  (let ((fees (calc-fees nft-id)))
    (asserts! (is-called-by-charging-ctr) ERR_NOT_AUTH)
    (if (> fees u0)
      (as-contract (asset-transfer-to fees fee-receiver 0x636174616d6172616e2073776170))
      (ok true))))

(define-constant ERR_NOT_AUTH (err u404))
