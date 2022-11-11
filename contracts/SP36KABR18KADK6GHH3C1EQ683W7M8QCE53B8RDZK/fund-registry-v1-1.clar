(impl-trait .fund-registry-trait-v1-1.fund-registry-trait)

;; 
;; Constants
;; 

(define-constant ERR_FUND_EXISTS (err u10001))

;; 
;; Vars
;; 

(define-data-var fund-count uint u0)

;; 
;; Maps
;; 

;; Address is not encoded
(define-map fund-address-by-id uint (buff 33))
(define-map fund-id-by-address (buff 33) uint)

;; 
;; Getters
;; 

(define-read-only (get-fund-count)
  (ok (var-get fund-count))
)

(define-read-only (get-fund-address-by-id (fund-id uint))
  (ok (map-get? fund-address-by-id fund-id))
)

(define-read-only (get-fund-id-by-address (address (buff 33)))
  (ok (map-get? fund-id-by-address address))
)

(define-read-only (is-fund-registered (address (buff 33)))
  (ok (not (is-none (map-get? fund-id-by-address address))))
)

;; 
;; Register
;; 

(define-public (register-fund (address (buff 33)))
  (let (
    (fund-id (var-get fund-count))
  )
    (try! (contract-call? .main check-is-enabled))
    (asserts! (map-insert fund-id-by-address address fund-id) ERR_FUND_EXISTS)

    (map-set fund-address-by-id fund-id address)
    (var-set fund-count (+ fund-id u1))
    (ok fund-id)
  )
)
