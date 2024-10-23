;; by the charging-ctr. Only that contract can call the public functions.

(define-data-var fee-receiver principal tx-sender)
(define-data-var fee-amount uint u210000000) ;; Initial fee amount

(define-private (is-called-by-charging-ctr)
    (is-eq contract-caller .invaders-neon)) ;; fees reserved to invaders-neon

;; Function to change the fee receiver
(define-public (set-fee-receiver (new-receiver principal))
  (begin
    (asserts! (is-eq tx-sender (var-get fee-receiver)) ERR_NOT_AUTH)
    (ok (var-set fee-receiver new-receiver))))

;; Function to change the fee amount
(define-public (set-fee-amount (new-amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get fee-receiver)) ERR_NOT_AUTH)
    (ok (var-set fee-amount new-amount))))

(define-private (calc-fees (nft-id uint))
  (var-get fee-amount))

;; For information only.
(define-read-only (get-fees (nft-id uint))
  (ok (calc-fees nft-id)))

;; helper function to transfer  from tx-sender to a principal with memo
(define-private (asset-transfer-to (nft-id uint) (to principal) (memo (buff 34)))
  (begin
    (try! (contract-call? 'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo transfer (calc-fees nft-id) tx-sender to (some memo)))
    (ok true))) 
        
    ;; 'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE

;; Hold fees for the given amount in escrow.
(define-public (hold-fees (nft-id uint))
  (let ((fees (calc-fees nft-id)))
    (asserts! (is-called-by-charging-ctr) ERR_NOT_AUTH)
    (if (> fees u0)
      (asset-transfer-to nft-id (as-contract tx-sender) 0x636174616d6172616e2073776170)
      (ok true))))

;; Release fees for the given amount if swap was canceled.
;; It relies on the logic of the charging-ctr that this contract.
(define-public (release-fees (nft-id uint))
  (let ((user tx-sender)
        (fees (calc-fees nft-id)))
    (asserts! (is-called-by-charging-ctr) ERR_NOT_AUTH)
    (if (> fees u0)
      (as-contract (asset-transfer-to nft-id user 0x636174616d6172616e2073776170));; this only releases fees not the invader
      (ok true))))

;; Pay fee for the given amount if swap was executed.
(define-public (pay-fees (nft-id uint))
  (let ((fees (calc-fees nft-id)))
    (asserts! (is-called-by-charging-ctr) ERR_NOT_AUTH)
    (if (> fees u0)
      (as-contract (asset-transfer-to nft-id (var-get fee-receiver) 0x636174616d6172616e2073776170))
      (ok true))))

(define-constant ERR_NOT_AUTH (err u404))
