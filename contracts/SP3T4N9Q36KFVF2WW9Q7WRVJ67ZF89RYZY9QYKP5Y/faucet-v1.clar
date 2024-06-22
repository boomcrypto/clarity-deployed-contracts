;; Define the contract owner
(define-constant CONTRACT-OWNER tx-sender)

;; Define errors
(define-constant ERR-NOT-AUTHORIZED (err u403))
(define-constant ERR_STX_TRANSFER (err u100))
(define-constant ERR-DEPOSIT-FAILED (err u1001))

;; Define variables
(define-data-var send-amount uint u10) ;; Default send amount is 10 STX
(define-data-var total-calls uint u0) ;; Total number of calls to the request function
(define-data-var total-sent uint u0) ;; Total STX sent
;;(define-data-var contact-address principal 'ST3T4N9Q36KFVF2WW9Q7WRVJ67ZF89RYZYBCZKHDC.faucet-controller-v5) ;;

;; Ensure only the contract owner can call certain functions
(define-read-only (is-owner (caller principal))
  (is-eq caller CONTRACT-OWNER))

(define-public (deposit (amount uint))
  (begin
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (ok amount)))

(define-public (send (amount uint) (recipient principal))
   (begin
        (asserts! (is-owner tx-sender) ERR-NOT-AUTHORIZED)
        (try! (as-contract (stx-transfer? amount tx-sender recipient)))
        (ok amount)
   )
)

(define-public (request (recipient principal))
  (begin
    (asserts! (is-owner tx-sender) ERR-NOT-AUTHORIZED)
    
    (let ((amount (var-get send-amount)))
      (try! (as-contract (stx-transfer? amount tx-sender recipient)))
      ;; Update statistics
      (var-set total-calls (+ (var-get total-calls) u1))
      (var-set total-sent (+ (var-get total-sent) amount))
      (ok true))))

;; Function to change the send amount
(define-public (change-send-amount (new-amount uint))
  (begin
    (asserts! (is-owner tx-sender) ERR-NOT-AUTHORIZED)
    (var-set send-amount new-amount)
    (ok true)))

;; Function to view statistics
(define-read-only (get-statistics)
  (ok (tuple (total-calls (var-get total-calls)) (total-sent (var-get total-sent)))))

;; Function to view the current send amount
(define-read-only (get-send-amount)
  (ok (var-get send-amount)))

;; Function to display the current balance of the contract
(define-read-only (get-contract-balance)
  (ok (stx-get-balance (as-contract tx-sender)))
)