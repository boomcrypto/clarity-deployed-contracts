;; 
;; Constants
;; 

(define-constant ERR_UNAUTHORIZED (err u111001))
(define-constant ERR_DISABLED (err u111002))

;; 
;; Vars
;; 

(define-data-var contracts-owner principal tx-sender)
(define-data-var contracts-enabled bool true)

;; 
;; Getters
;; 

(define-read-only (get-contracts-owner)
  (var-get contracts-owner)
)

(define-read-only (get-contracts-enabled)
  (var-get contracts-enabled)
)

;; 
;; Checks
;; 

(define-public (check-is-owner (sender principal))
  (begin
    (asserts! (is-eq sender (var-get contracts-owner)) ERR_UNAUTHORIZED)
    (ok true)
  )
)

(define-public (check-is-enabled)
  (begin
    (asserts! (var-get contracts-enabled) ERR_DISABLED)
    (ok true)
  )
)

;; 
;; Updates
;; 

(define-public (set-contracts-owner (owner principal))
  (begin
    (try! (check-is-owner tx-sender))
    (var-set contracts-owner owner)
    (ok true)
  )
)

(define-public (set-contracts-enabled (enabled bool))
  (begin
    (try! (check-is-owner tx-sender))
    (var-set contracts-enabled enabled)
    (ok true)
  )
)
