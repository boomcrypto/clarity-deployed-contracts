(define-fungible-token magic-beans)

(define-constant contract-owner tx-sender)

(define-constant err-owner-only (err u100))

(define-constant err-no-mint-zero (err u101))

(define-constant err-no-zero-amount (err u102))

;; mint

(define-public (mint (amount uint) (who principal))
    (begin 
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (> amount u0) err-no-mint-zero)
        ;; #[allow(unchecked_data)]
        (ft-mint? magic-beans amount who)     
     )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal))   
    (begin 
        (print "allo")
        (asserts! (is-eq tx-sender sender) err-owner-only)
        (asserts! (> amount u0) err-no-zero-amount )
        
        (ft-transfer? magic-beans amount sender recipient)
    )
    )

;; get token number
(define-read-only (get-balance (who principal))
    (ft-get-balance magic-beans who)
)
