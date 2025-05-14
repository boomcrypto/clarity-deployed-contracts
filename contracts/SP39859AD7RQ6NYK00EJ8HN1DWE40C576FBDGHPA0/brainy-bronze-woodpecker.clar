;;; SIP010 interface for STX.

(impl-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

(define-public
  (transfer
    (amt  uint)
    (from principal)
    (to   principal)
    (memo (optional (buff 34))))
  (stx-transfer? amt from to) )

(define-read-only (get-name)                   (ok "Wrapped STX"))
(define-read-only (get-symbol)                 (ok "wSTX"))
(define-read-only (get-decimals)               (ok u6)) ;;micro stacks
(define-read-only (get-balance (of principal)) (ok (stx-get-balance of)))
(define-read-only (get-total-supply)           (ok stx-liquid-supply)) ;;XXX
(define-read-only (get-token-uri)              (ok (some u"https://stacks.co")))

;;; eof