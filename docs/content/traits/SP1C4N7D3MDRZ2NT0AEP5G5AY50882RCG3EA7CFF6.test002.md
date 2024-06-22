---
title: "Trait test002"
draft: true
---
```
;; A read-only function that returns a message
(define-read-only (say-hi)
  (ok "Hello World")
)

;; A read-only function that returns an input number
(define-read-only (echo-number (val int))
  (ok val)
)

;; A public function that conditionally returns an ok or an error
(define-public (check-it (flag bool))
  (if flag (ok 1) (err u100))
)

(define-public (transferstx (sender principal) (recipient principal)
  (memo (optional (buff 34)))
)
  (begin
    ;; (try! (stx-transfer? amount sender recipient))
    (unwrap! (stx-transfer? u50  tx-sender recipient) (err "err-transferring-token-x"))
    ;; (try! (as-contract (stx-transfer? u60 sender recipient)) );; Returns (ok true)
    ;; (try! (contract-call? mainToken transfer amount sender recipient memo))
    (match memo to-print (print to-print) 0x)
    (ok true)
  )
)
```
