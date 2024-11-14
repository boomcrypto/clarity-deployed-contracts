;; title: treasury
;; version: 0.1.0
;; summary: Treasury contract for managing fees
(define-map contract-managers principal bool)

(define-constant ERR-PERMISSION-DENIED (err u1000))
(define-constant ERR-INSUFFICIENT-FUND (err u1001))
(define-constant ERR-PRECONDITION (err u1002))

(define-data-var treasury-balance uint u0)

(define-map comission uint uint)

(define-map fee uint uint)

(define-read-only (get-treasury-balance)
    (var-get treasury-balance))

(define-read-only (get-comission (c-id uint))
    (default-to u0 
        (map-get? comission c-id)
    ))

(define-read-only (get-fee (fee-id uint))
    (default-to u0 
        (map-get? fee fee-id)
    ))

(define-read-only (is-contract-manager)
	(default-to false (map-get? contract-managers tx-sender)))

(define-public (add-contract-manager (contract principal))
    (begin 
        (asserts! (is-contract-manager) ERR-PERMISSION-DENIED)
        (map-set contract-managers contract true)
        (ok true)
    ))

(define-public (remove-contract-manager (contract principal))
    (begin 
        (asserts! (is-contract-manager) ERR-PERMISSION-DENIED)
        (map-delete contract-managers contract)
        (ok true)
    ))

(define-public (update-comission (c-id uint) (value uint))
    (begin 
        (asserts! (is-contract-manager) ERR-PERMISSION-DENIED)
        (map-set comission c-id value)
        (ok true)
    ))

(define-public (update-fee (fee-id uint) (value uint))
    (begin 
        (asserts! (is-contract-manager) ERR-PERMISSION-DENIED)
        (map-set fee fee-id value)
        (ok true)
    ))

(define-public (deposit-fund (amount uint))
    (begin 
        (asserts! (> amount u0) ERR-PRECONDITION)
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (ok true)))


(define-public (withdraw-deposit-fund (amount uint) (recipient principal) (fee-id uint) )
    (begin 
        (asserts! (> amount u0) ERR-PRECONDITION)
        (asserts! (is-contract-manager) ERR-PERMISSION-DENIED)
        (let (
                (fee-s (get-comission fee-id))
                (tax (/ (* amount fee-s) u100))
                (amount-to-send (- amount tax))
            )
            (try! (as-contract (stx-transfer? amount-to-send tx-sender recipient)))
            (var-set treasury-balance (+ (var-get treasury-balance) tax))
            (ok amount-to-send)
        )))

(define-public (pay-tax (fee-id uint))
        (let (
                (tax (get-fee fee-id))
            )
            (if (> tax u0)
                (begin
                    (try! (stx-transfer? tax tx-sender (as-contract tx-sender)))
                    (var-set treasury-balance (+ (var-get treasury-balance) tax))
                    (ok tax)
                    )
                (ok u0)
                )
        ))

(define-public (collect-treasure (amount uint) (recipient principal))
    (begin 
        (asserts! (> amount u0) ERR-PRECONDITION)
        (asserts! (is-contract-manager) ERR-PERMISSION-DENIED)
        (let (
                (balance (var-get treasury-balance))
            )
            (asserts! (>= balance amount) ERR-INSUFFICIENT-FUND)
            (try! (as-contract (stx-transfer? amount tx-sender recipient)))
            (var-set treasury-balance (- balance amount))
            (ok true)
        )))

(map-set contract-managers .auction-store true)
(map-set contract-managers .promoter-rank true)
(map-set contract-managers tx-sender true)

(map-set comission u0 u5)
(map-set comission u1 u0)

(map-set fee u0 u1000000)
(map-set fee u1 u2000000)
(map-set fee u2 u5000000)
(map-set fee u3 u1500000)
(map-set fee u4 u4000000)
(map-set fee u5 u6000000)