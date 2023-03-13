
;; title: counter
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

;; data maps
;;
(define-map counters principal uint)

;; public functions
;;
(define-public (count-up)
    (begin
        (map-set counters tx-sender (+ (get-count tx-sender) u1))
        (ok true)
    )
)

;; read only functions
;;
(define-read-only (get-count (who principal))
    (default-to u0 (map-get? counters who))
)

;; private functions
;;

