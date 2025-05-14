---
title: "Trait aimkt-token-owner"
draft: true
---
```
;; title: aibtcdev-token-owner
;; version: 1.0.0
;; summary: An extension that provides management functions for the dao token

;; traits
;;
(impl-trait 'SPTWD9SPRQVD3P733V89SV0P8RZRZNQADJHHPME1.aibtcdev-dao-traits-v1.extension)
(impl-trait 'SPTWD9SPRQVD3P733V89SV0P8RZRZNQADJHHPME1.aibtcdev-dao-traits-v1.token-owner)

;; constants
;;

(define-constant ERR_UNAUTHORIZED (err u401))

;; public functions
;;

(define-public (callback (sender principal) (memo (buff 34)))
  (ok true)
)

(define-public (set-token-uri (value (string-utf8 256)))
  (begin
    ;; check if caller is authorized
    (try! (is-dao-or-extension))
    ;; update token uri
    (try! (as-contract (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aimkt-stxcity set-token-uri value)))
    (ok true)
  )
)

(define-public (transfer-ownership (new-owner principal))
  (begin
    ;; check if caller is authorized
    (try! (is-dao-or-extension))
    ;; transfer ownership
    (try! (as-contract (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aimkt-stxcity transfer-ownership new-owner)))
    (ok true)
  )
)

;; private functions
;;

(define-private (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aimkt-base-dao)
    (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aimkt-base-dao is-extension contract-caller)) ERR_UNAUTHORIZED
  ))
)

```
