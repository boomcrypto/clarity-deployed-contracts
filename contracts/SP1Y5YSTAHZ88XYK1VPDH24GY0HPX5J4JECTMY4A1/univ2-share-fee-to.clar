(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(impl-trait .univ2-share-fee-to-trait.share-fee-to-trait)

;; nop
(define-public
  (receive
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
