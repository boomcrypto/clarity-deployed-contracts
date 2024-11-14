---
title: "Trait sys-investment"
draft: true
---
```

;; title: sys-investor
;; version:
;; summary:
;; description:

;; traits
;;

;; token definitions
;; 

;; constants
;;

;; data vars
;;

;;
;; =========
;; DATA MAPS
;; =========
;;
(define-map active-addresses principal uint)

;;
;; ================
;; PUBLIC FUNCTIONS
;; ================
;;
(define-public (activate-address (address principal))
    (begin
     (try! (contract-call? .sys-admin assert-invoked-by-operator))
     (ok (map-set active-addresses address block-height))
     )
  )

(define-public (deactivate-address (address principal))
    (begin
     (try! (contract-call? .sys-admin assert-invoked-by-operator))
     (ok (map-delete active-addresses address))
     )
  )

;;
;; ===================
;; READ ONLY FUNCTIONS
;; ===================
;;
(define-read-only (is-active (address principal))
    (match (map-get? active-addresses address)
           h (>= block-height h)
           false)
  )

```
