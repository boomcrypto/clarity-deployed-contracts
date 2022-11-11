
;; 
;; Constants
;; 

(define-constant ERR_BTC_EXISTS (err u30001))

;; 
;; Maps
;; 

(define-map btc-to-stx (buff 33) principal)
(define-map stx-to-btc principal (buff 33))

;; 
;; Getters
;; 

(define-read-only (get-btc-to-stx (address (buff 33)))
  (map-get? btc-to-stx address)
)

(define-read-only (get-stx-to-btc (address principal))
  (map-get? stx-to-btc address)
)

(define-read-only (is-btc-registered (address (buff 33)))
  (not (is-none (map-get? btc-to-stx address)))
)

(define-read-only (is-stx-registered (address principal))
  (not (is-none (map-get? stx-to-btc address)))
)

;; 
;; Register
;; 

(define-public (register-user (user principal) (address (buff 33)))
  (begin
    (asserts! (map-insert btc-to-stx address tx-sender) ERR_BTC_EXISTS)
    (try! (contract-call? .main check-is-enabled))
    (map-set stx-to-btc user address)    
    (ok true)
  )
)
