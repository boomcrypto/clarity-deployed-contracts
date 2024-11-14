(use-trait fungible-token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-data-var fee-receiver principal tx-sender)
(define-data-var fee-percentage uint u10)

(define-private (is-called-by-charging-ctr)
    (is-eq contract-caller .sub100neon-invader))

(define-public (set-fee-receiver (new-receiver principal))
  (begin
    (asserts! (is-eq tx-sender (var-get fee-receiver)) ERR_NOT_AUTH)
    (ok (var-set fee-receiver new-receiver))))

(define-public (set-fee-percentage (new-percentage uint))
  (begin
    (asserts! (is-eq tx-sender (var-get fee-receiver)) ERR_NOT_AUTH)
    (asserts! (<= new-percentage u100) ERR_INVALID_PERCENTAGE) 
    (ok (var-set fee-percentage new-percentage))))

(define-private (calc-fees (amount uint) (ft-decimals uint) (ft <fungible-token>))
  (let 
    (
      (percentage-fee (/ (* amount (var-get fee-percentage)) u100))
      (fixed-fee (* u210 (pow u10 ft-decimals)))
    )
    (if (> percentage-fee fixed-fee) percentage-fee fixed-fee)
  )
)

(define-read-only (get-fees (amount uint) (ft-decimals uint) (ft <fungible-token>))
  (ok (calc-fees amount ft-decimals ft))
)

(define-private (asset-transfer-to (amount uint) (ft <fungible-token>) (to principal) (memo (buff 34)))
  (contract-call? ft transfer amount tx-sender to (some memo)))

(define-public (hold-fees (amount uint) (ft-decimals uint) (ft <fungible-token>))
  (let ((fees (calc-fees amount ft-decimals ft)))
    (asserts! (is-called-by-charging-ctr) ERR_NOT_AUTH)
    (if (> fees u0)
      (asset-transfer-to fees ft (as-contract tx-sender) 0x666565)
      (ok true))))

(define-public (release-fees (amount uint) (ft-decimals uint) (ft <fungible-token>))
  (let ((user tx-sender)
        (fees (calc-fees amount ft-decimals ft)))
    (asserts! (is-called-by-charging-ctr) ERR_NOT_AUTH)
    (if (> fees u0)
      (as-contract (asset-transfer-to fees ft user 0x666565))
      (ok true))))

(define-public (pay-fees (amount uint) (ft-decimals uint) (ft <fungible-token>))
  (let ((fees (calc-fees amount ft-decimals ft)))
    (asserts! (is-called-by-charging-ctr) ERR_NOT_AUTH)
    (if (> fees u0)
      (as-contract (asset-transfer-to fees ft (var-get fee-receiver) 0x666565))
      (ok true))))

(define-constant ERR_NOT_AUTH (err u404))
(define-constant ERR_INVALID_PERCENTAGE (err u405))
(define-constant ERR_FT_FAILURE (err u406))