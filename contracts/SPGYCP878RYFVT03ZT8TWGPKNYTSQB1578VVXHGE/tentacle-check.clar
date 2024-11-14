;; Define the contract

;; Store the contract deployer
(define-data-var contract-owner principal tx-sender)

;; Map to store other authorized addresses
(define-map authorized-addresses principal bool)

;; Add an address to the authorized list
(define-public (add-authorized (address principal))
  (begin
    (asserts! (is-authorized) (err u403))
    (ok (map-set authorized-addresses address true))))

;; Remove an address from the authorized list
(define-public (remove-authorized (address principal))
  (begin
    (asserts! (is-authorized) (err u403))
    (ok (map-delete authorized-addresses address))))

;; Check if an address is authorized
(define-read-only (is-authorized-address (address principal))
  (or 
    (is-eq address (var-get contract-owner))
    (default-to false (map-get? authorized-addresses address))
  ))

;; Check if the contract caller is authorized
(define-read-only (is-authorized)
  (is-authorized-address tx-sender))

;; Get the contract owner
(define-read-only (get-contract-owner)
  (ok (var-get contract-owner)))

;; Transfer ownership (only current owner can do this)
(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (ok (var-set contract-owner new-owner))))