;; Implementation of fixed fees of 1% for the service
;; by the charging-ctr. Only that contract can call the public functions.

(define-constant fee-receiver tx-sender)

(define-private (is-called-by-charging-ctr)
  (or (is-eq contract-caller .xbtc-nft-swap-v1)
    (is-eq contract-caller .xbtc-ft-swap-v1)))


(define-private (calc-fees (xbtc uint))
  (/ xbtc u100))

;; For information only.
(define-read-only (get-fees (xbtc uint))
  (ok (calc-fees xbtc)))

;; helper function to transfer xbtc to a principal with memo
(define-private (xbtc-transfer-to (amount uint) (to principal) (memo (buff 34)))
  (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin  
    transfer amount tx-sender to (some memo)))

;; Hold fees for the given amount in escrow.
(define-public (hold-fees (xbtc uint))
  (let ((fees (calc-fees xbtc)))
    (asserts! (is-called-by-charging-ctr) ERR_NOT_AUTH)
    (if (> fees u0)
      (xbtc-transfer-to fees (as-contract tx-sender) 0x636174616d6172616e2073776170)
      (ok true))))

;; Release fees for the given amount if swap was canceled.
;; It relies on the logic of the charging-ctr that this contract.
(define-public (release-fees (xbtc uint))
  (let ((user tx-sender)
        (fees (calc-fees xbtc)))
    (asserts! (is-called-by-charging-ctr) ERR_NOT_AUTH)
    (if (> fees u0)
      (as-contract (xbtc-transfer-to fees user 0x636174616d6172616e2073776170))
      (ok true))))

;; Pay fee for the given amount if swap was executed.
(define-public (pay-fees (xbtc uint))
  (let ((fees (calc-fees xbtc)))
    (asserts! (is-called-by-charging-ctr) ERR_NOT_AUTH)
    (if (> fees u0)
      (as-contract (xbtc-transfer-to fees fee-receiver 0x636174616d6172616e2073776170))
      (ok true))))

(define-constant ERR_NOT_AUTH (err u404))
