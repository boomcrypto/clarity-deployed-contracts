;; Contract Management & Configuration
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-invalid-amount (err u102))
(define-constant err-swap-failed (err u103))
(define-constant err-contract-paused (err u104))

;; Token decimal constants
(define-constant decimal-6 u1000000)
(define-constant decimal-8 u100000000)

;; Contract control
(define-data-var contract-paused bool false)

;; Define data variables for swap amounts
(define-data-var swap1-amount uint u1000000)
(define-data-var swap2-amount uint u1000000)
(define-data-var swap3-amount uint u1000000)

;; Define authorized users map
(define-map authorized-users principal bool)

;; Authorization functions
(define-private (is-authorized (user principal))
  (or
    (is-eq user contract-owner)
    (default-to false (map-get? authorized-users user))))

;; Contract pause control
(define-public (set-contract-pause (paused bool))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (var-set contract-paused paused))))

;; User management
(define-public (add-authorized-user (user principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set authorized-users user true))))

(define-public (remove-authorized-user (user principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-delete authorized-users user))))

;; Getter functions for swap amounts
(define-read-only (get-swap1-amount) (var-get swap1-amount))
(define-read-only (get-swap2-amount) (var-get swap2-amount))
(define-read-only (get-swap3-amount) (var-get swap3-amount))

;; Single function to set all swap amounts
(define-public (set-all-swap-amounts 
    (amount1 uint) 
    (amount2 uint) 
    (amount3 uint))
  (begin
    (asserts! (is-authorized tx-sender) err-not-authorized)
    (asserts! (not (var-get contract-paused)) err-contract-paused)
    ;; Validate amounts
    (asserts! (and 
      (> amount1 u0) 
      (> amount2 u0) 
      (> amount3 u0)) 
      err-invalid-amount)
    
    ;; Set all amounts
    (var-set swap1-amount amount1)
    (var-set swap2-amount amount2)
    (var-set swap3-amount amount3) 
    (ok true)))

;; Private helper function for swap validation
(define-private (validate-swap-params (amount uint))
  (begin
    (asserts! (is-authorized tx-sender) err-not-authorized)
    (asserts! (not (var-get contract-paused)) err-contract-paused)
    (asserts! (> amount u0) err-invalid-amount)
    (ok true)))
  
;; Main swap function with all operations
(define-public (add-lp)
  (begin
    (asserts! (not (var-get contract-paused)) err-contract-paused) 
    (try! (validate-swap-params (var-get swap1-amount)))
    (let ((swap1 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 
                       do-swap (var-get swap1-amount) 
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token 
                       'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token  
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to))))
      (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core mint u3
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token 
                         'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.cha-welsh 
                         (var-get swap1-amount) 
                         (get amt-out swap1))))

    (try! (validate-swap-params (var-get swap2-amount)))
    (let ((swap2 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 
                       do-swap (var-get swap2-amount) 
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token 
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.synthetic-welsh
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to))))
      (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core mint u5
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token 
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.synthetic-welsh
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.cha-iouwelsh 
                         (var-get swap2-amount) 
                         (get amt-out swap2))))

    (try! (validate-swap-params (var-get swap3-amount)))
    (let ((swap3 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 
                       do-swap (var-get swap3-amount) 
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token 
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.up-dog
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to))))
      (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core mint u9
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token 
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.up-dog 
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.cha-updog 
                         (var-get swap3-amount) 
                         (get amt-out swap3))))
    (ok true)))

;; Read-only function to check if a user is authorized
(define-read-only (check-authorization (user principal))
  (is-authorized user))