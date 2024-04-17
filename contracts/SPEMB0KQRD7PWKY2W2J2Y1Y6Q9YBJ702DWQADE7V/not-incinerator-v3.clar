;; Constants ;;
(define-constant ERR-ERROR-UNWRAP u400)
(define-constant ERR-ERROR-TRANSFER u401)
(define-constant ERR-YOU-POOR u402)  ;; for the culture
(define-constant CONTRACT_OWNER tx-sender)

;; Public variables ;;
(define-data-var tot-burned-amount uint u0)
(define-data-var tot-burns uint u0)
(define-map burns-list uint {maker: principal, amount: uint})


;; Functions ;;
(define-read-only (get-burned-amount) 
    (ok (var-get tot-burned-amount)))

(define-read-only (get-tot-burns) 
    (ok (var-get tot-burns)))

(define-read-only (get-burns-list (index uint))
    (ok (map-get? burns-list index)))   

(define-private (increase-burned-amount (amount uint))
    (var-set tot-burned-amount (+ (var-get tot-burned-amount) amount)))

(define-private (increase-tot-burns)
    (var-set tot-burns (+ (var-get tot-burns) u1)))


(define-public (burn-nothing (amount uint))
    (begin 
        (asserts! (> amount u0) (err ERR-YOU-POOR))
        (unwrap! (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope unwrap amount) (err ERR-ERROR-UNWRAP))
        (unwrap! (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.micro-nthng transfer (as-contract tx-sender) amount) (err ERR-ERROR-TRANSFER))
        (map-insert burns-list (var-get tot-burns) {maker: tx-sender, amount: amount})
        (increase-burned-amount amount)
        (increase-tot-burns)
        (ok true)))