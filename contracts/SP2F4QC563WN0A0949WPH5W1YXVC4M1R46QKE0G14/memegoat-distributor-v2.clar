(use-trait ft-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait)

;; ERRS
(define-constant ERR-NOT-AUTHORIZED (err u5000))
(define-constant ERR-INSUFFICIENT-AMOUNT (err u6001))
(define-constant ERR-DISTRIBUTION-AMOUNT-EXCEEDED (err u6002))
(define-constant ERR-VAULT-NOT-FUNDED (err u6003))

;; DATA MAPS, VARS AND CONSTANTS
(define-constant ONE_8 u100000000)
(define-constant ONE_6 u1000000)
(define-constant DISTRIBUTION-POOL u500000000000000)

;; set caller as contract owner
(define-data-var contract-owner principal tx-sender)

(define-data-var total-amount-sent uint u0)
(define-data-var vault-funded bool true)

;; READ ONLY CALLS
(define-read-only (get-amount-distributed) 
  (ok (var-get total-amount-sent))
)

;; MANAGEMENT CALLS
(define-public (set-contract-owner (owner principal))
  (begin
    (try! (check-is-owner)) 
    (ok (var-set contract-owner owner))
  )
)

(define-public (fund-vault) 
  (begin
    (try! (check-is-owner)) 
    (try! (contract-call? .memegoatstx transfer-fixed (decimals-to-fixed DISTRIBUTION-POOL) tx-sender .memegoat-vault-v1 none))
    (var-set vault-funded true)
    (ok true)
  )
)

;; PUBLIC CALLS
(define-public (send-tokens (input (list 200 principal)) (amount uint))
	(begin
    (try! (check-is-owner)) 
    (asserts! (var-get vault-funded) ERR-VAULT-NOT-FUNDED)
    (asserts! (> amount u0) ERR-INSUFFICIENT-AMOUNT)
    (asserts! (<= (var-get total-amount-sent) DISTRIBUTION-POOL) ERR-DISTRIBUTION-AMOUNT-EXCEEDED)
		(fold transfer-many-iter input amount)
		(ok true)
	)
)

;; PRIVATE CALLS
(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)

(define-private (decimals-to-fixed (amount uint)) 
  (/ (* amount ONE_8) ONE_6)
)

(define-private (transfer-many-iter (recipient principal) (amount uint))
	(begin
    ;; transfer token from vault
    (unwrap-panic (as-contract (contract-call? .memegoat-vault-v1 transfer-ft .memegoatstx (decimals-to-fixed amount) recipient)))    
    (var-set total-amount-sent (+ (var-get total-amount-sent) amount))
    amount 
	)
)