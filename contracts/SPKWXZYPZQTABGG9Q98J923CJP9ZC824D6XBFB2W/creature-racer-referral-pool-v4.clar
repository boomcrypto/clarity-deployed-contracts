
;; creature-racer-referral-pool
;; Referral pool contract

;;
;; =========
;; CONSTANTS
;; =========
;;
(define-constant contract-owner tx-sender)

;; Error definitions
;; -----------------
(define-constant err-forbidden (err u403))
(define-constant err-user-not-found (err u404))
(define-constant err-insufficient-funds (err u2002))
(define-constant err-invalid-withdrawal-count (err u6001))

;;
;; ==================
;; DATA MAPS AND VARS
;; ==================
;;



(define-map withdrawal-counters principal uint)


;; private functions
;;

;;
;; ================
;; PUBLIC FUNCTIONS
;; ================
;;

;; Get number of withdrawals of given user
(define-read-only (get-withdrawal-count (user principal))
    (let (
          (count (unwrap! (map-get? withdrawal-counters
                                    user)
                          err-user-not-found))
          )
      (ok count)
      )
)


;; get balance of the pool
(define-read-only (get-balance)
    (stx-get-balance (as-contract tx-sender)))


;; Withdraw funds from pool to sender address.
;; amount - amount to withdraw
;; withdrawal-count - checksum for withdrawals
;; *-sig - argument signature issued by backend
;; This function can be called by sender who wants to withdraw 
;; funds from the pool. Signatures issued by operator's private
;; key need to be passed  
(define-public (withdraw (operator-sig (buff 65))
                         (sender-pk (buff 33))
                         (amount uint)
                         (withdrawal-count uint))
    (let (
          (sender tx-sender)
          (balance (get-balance))
          (wcnt (+ (default-to u0 (map-get? withdrawal-counters
                                          sender))
                   u1))
          )
      (try! (contract-call? .creature-racer-admin-v4
                            verify-signature
                            operator-sig
                            sender-pk
                            (list amount withdrawal-count)))
      (asserts! (>= balance amount) err-insufficient-funds)
      (asserts! (is-eq withdrawal-count wcnt)
                err-invalid-withdrawal-count)
      (try! (as-contract (stx-transfer? amount tx-sender sender)))
      (map-set withdrawal-counters sender wcnt)
      (ok true)
    )
  )
