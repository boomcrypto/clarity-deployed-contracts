(use-trait ft-trait 'SP35Q97MMDQJZG5AQYZK1M9NYCE3CD3V3J7D0E8NC.sip-010-trait-ft-standard.sip-010-trait)
(impl-trait .univ2-fee-to-trait.fee-to-trait)

;; nop
(define-public
  (send-revenue
    (pool      uint)
    (is-token0 bool)
    (amt       uint))

  (ok true) )

;;======================================================================
(define-constant err-check-owner (err u101))
(define-data-var owner principal tx-sender)
(define-read-only (get-owner) (var-get owner))
(define-private (check-owner)
  (ok (asserts! (is-eq tx-sender (get-owner)) err-check-owner)))
(define-public (set-owner (new-owner principal))
  (begin
   (try! (check-owner))
   (ok (var-set owner new-owner)) ))

(define-public (harvest (token <ft-trait>) (amt uint))
  (begin
   (try! (check-owner))
   (contract-call? token transfer amt (as-contract tx-sender) tx-sender none)
   ))

;;; eof