;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))

;; Define data maps
(define-map authorized-users principal bool)
(define-map farm-records
  { address: principal }
  { start-block: uint, amount: uint, price: uint }
)

;; Define functions
(define-public (add-authorized-user (user principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set authorized-users user true))
  )
)

(define-public (remove-authorized-user (user principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-delete authorized-users user))
  )
)

(define-read-only (is-authorized (user principal))
  (default-to false (map-get? authorized-users user))
)

(define-public (start-farm (address principal) (start-block uint) (amount uint) (price uint))
  (begin
    (asserts! (is-authorized tx-sender) err-not-authorized)
    (ok (map-set farm-records { address: address } { start-block: start-block, amount: amount, price: price }))
  )
)

(define-read-only (get-farm-record (address principal))
  (map-get? farm-records { address: address })
)