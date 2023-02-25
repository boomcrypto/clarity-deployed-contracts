
;; creature-racer-reward-pool
;; Stores funds from payments

;;
;; =========
;; CONSTANTS
;; =========
;;
(define-constant contract-owner tx-sender)
(define-constant cycle-period u7)

;; Error definitions
;; -----------------

(define-constant err-not-found (err u404))
(define-constant err-insufficient-funds (err u2002))
(define-constant err-invalid-withdrawal-count (err u6001))
(define-constant err-invalid-amount (err u6002))
;;
;; ==================
;; DATA MAPS AND VARS
;; ==================
;;
(define-map withdrawal-counters principal uint)
(define-map cycles uint uint)
(define-data-var current-cycle uint u0)
(define-map cycle-balance uint uint)


;;
;; =================
;; PRIVATE FUNCTIONS
;; =================
;;


;;
;; ================
;; PUBLIC FUNCTIONS
;; ================
;;

;; Accept funds to pool
(define-public (receive-funds (amount-ustx uint))
    (let 
        (
         (cycle (var-get current-cycle))
         (cycle-amount (default-to u0 (map-get? cycles cycle)))
         (balance (default-to u0 (map-get? cycle-balance cycle)))
         )
      (asserts! (> amount-ustx u0) err-invalid-amount)
      (try! (stx-transfer? amount-ustx
                           tx-sender
                           .creature-racer-reward-pool-v2))
      (map-set cycles cycle (+ cycle-amount amount-ustx))
      (map-set cycle-balance cycle (+ balance amount-ustx))
      (ok true)
      )
  )

;; Withdraw assets from pool
(define-public (withdraw (operator-sig (buff 65))
                         (sender-pk (buff 33))
                         (amount uint)
                         (withdrawal-count uint)
                         (cycle uint))
    (let (
          (sender tx-sender)
          (balance (unwrap-panic (get-balance)))
          (cycle-amount (default-to u0 (map-get? cycles cycle)))
          (expected-withdrawal-count
           (+ (default-to u0 (map-get? withdrawal-counters
                                       sender)) u1))
          )
      (try! (contract-call? .creature-racer-admin-v2
                            verify-signature
                            operator-sig
                            sender-pk
                            (list amount withdrawal-count cycle)))
      (asserts! (>= balance amount) err-insufficient-funds)
      (asserts! (is-eq withdrawal-count
                        expected-withdrawal-count)
                err-invalid-withdrawal-count)
      (asserts! (>= cycle-amount amount)
                err-insufficient-funds)
      (try! (as-contract
             (stx-transfer? amount tx-sender sender)))
      (map-set withdrawal-counters sender 
               expected-withdrawal-count)
      (map-set cycles cycle (- cycle-amount amount))
      (ok true)
      )
  )

;; get number of withdrawals of given user
(define-read-only (get-withdrawal-count (user principal))
    (match (map-get? withdrawal-counters user)
           v (ok v)
           err-not-found))


;; get balance of the pool
(define-read-only (get-balance)
    (ok (as-contract (stx-get-balance tx-sender))))


;; Start new cycle
(define-public (open-new-cycle)
    (let (
          (cycle (var-get current-cycle))
          (next-cycle (+ cycle u1))
          )
      (try!
       (contract-call?
        .creature-racer-admin-v2
        assert-invoked-by-operator))
      (var-set current-cycle next-cycle)
      (if (>= next-cycle cycle-period)
          (let (
                (prev (- next-cycle cycle-period))
                )
            (map-set cycles next-cycle
                     (default-to u0
                         (map-get? cycles prev)))
            (map-set cycles prev u0)
            ) true)
      (ok true)
      )
  )

;; Gets current cycle number
(define-read-only (get-current-cycle)
    (ok (var-get current-cycle)))


;; Get cycle balance
(define-read-only (get-cycle-balance (cycle uint))
    (match (map-get? cycles cycle)
           v (ok v)
           (ok u0)))

;; Get collected balance in cycle
(define-read-only (get-collected-balance (cycle uint))
    (match (map-get? cycle-balance cycle)
           v (ok v)
           (ok u0)))
