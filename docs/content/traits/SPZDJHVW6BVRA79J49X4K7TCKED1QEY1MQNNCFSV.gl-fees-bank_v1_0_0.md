---
title: "Trait gl-fees-bank_v1_0_0"
draft: true
---
```
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; traits
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; errors
(define-constant err-permissions            (err u600))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; permissions
(define-data-var fee-collector principal tx-sender)
(define-read-only (get-fee-collector) (var-get fee-collector))
(define-public (set-fee-collector (new-recipient principal))
  (begin
   (try! (FEE-COLLECTOR))
   (ok (var-set fee-collector new-recipient)) ))
(define-private
 (FEE-COLLECTOR)
  (ok (asserts! (is-eq contract-caller (get-fee-collector)) err-permissions)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; storage

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; receive

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; collect
(define-public
  (collect (token <ft-trait>))

  (let ((user      tx-sender)
        (protocol (as-contract tx-sender))
        (amt      (unwrap-panic (contract-call? token get-balance protocol))))

    ;; Pre-conditions
    (try! (FEE-COLLECTOR))

    ;; Update global state
    (try! (if (> amt u0)
           (as-contract (contract-call? token transfer amt protocol user none))
           (ok false)) )

    ;; Return
    (let ((event
          {op   : "collect",
           user : user,
           token: token,
           amt  : amt,
          }))
      (print event)
      (ok event) )))

;;; eof
```
