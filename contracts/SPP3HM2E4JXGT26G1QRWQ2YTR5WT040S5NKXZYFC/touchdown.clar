(define-constant fee-receiver tx-sender)
(define-constant charging-ctr .creatures-neon)
(define-constant fixed-fee u2500000) ;; 2,500,000 uSTX 

;; For information only.
(define-public (get-fees (ustx uint))
  (ok (calc-fees ustx)))

(define-private (airport-fee (ustx uint))
  (if (> ustx u37500000000) 
    (/ ustx u133)           ;; 0.75% 
    (if (> ustx u12500000000) 
      (/ ustx u80)            ;; 1.25% 
      (/ ustx u40))))         ;; 2.5%

(define-private (calc-fees (ustx uint))
  (let 
    (
      (fee-result (airport-fee ustx))
    )
    (if (> fixed-fee fee-result) fixed-fee fee-result)
  )
)

;; Hold fees for the given amount in escrow.
(define-public (hold-fees (ustx uint))
  (begin
    (asserts! (is-eq contract-caller charging-ctr) ERR_NOT_AUTH)
    (stx-transfer? (calc-fees ustx) tx-sender (as-contract tx-sender))))

;; Release fees for the given amount if swap was canceled by its creator
(define-public (release-fees (ustx uint))
  (let ((user tx-sender))
    (asserts! (is-eq contract-caller charging-ctr) ERR_NOT_AUTH)
    (as-contract (stx-transfer? (calc-fees ustx) tx-sender user)))) 

;; Pay fee for the given amount if swap was executed.
(define-public (pay-fees (ustx uint))
  (let ((fee (calc-fees ustx)))
    (asserts! (is-eq contract-caller charging-ctr) ERR_NOT_AUTH)
    (if (> fee u0)
      (as-contract (stx-transfer? fee tx-sender fee-receiver))
      (ok true))))

(define-constant ERR_NOT_AUTH (err u404))