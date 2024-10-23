
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
(define-map active-addresses principal bool)

;;
;; ================
;; PUBLIC FUNCTIONS
;; ================
;;
(define-public (activate-address)
    (ok (map-set active-addresses tx-sender true))
  )

(define-public (deactivate-address (address principal))
    (begin
     (try! (contract-call? .sys-admin assert-invoked-by-operator))
     (ok (map-set active-addresses address false))
     )
  )

;;
;; ===================
;; READ ONLY FUNCTIONS
;; ===================
;;
(define-read-only (is-active (address principal))
    (default-to false (map-get? active-addresses address)))
