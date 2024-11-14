---
title: "Trait path-part0"
draft: true
---
```
;; Contract Management & Configuration
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-invalid-amount (err u102))
(define-constant err-swap-failed (err u103))
(define-constant err-contract-paused (err u104))

;; Token decimal constants
(define-constant decimal-6 u1000000)     ;; 6 decimals for most tokens
(define-constant decimal-8 u100000000)   ;; 8 decimals for ORDI

;; Contract control
(define-data-var contract-paused bool false)

;; Define data variables for swap amounts
(define-data-var swap1-amount uint u1000000)  ;; CHA -> KANGAROO
(define-data-var swap2-amount uint u6000000)  ;; CHA -> WELSH
(define-data-var swap3-amount uint u9500000)  ;; CHA -> SYNTHETIC-WELSH
(define-data-var swap4-amount uint u4000000)  ;; CHA -> UP-DOG
(define-data-var swap5-amount uint u5000000)  ;; CHA -> WSTX
(define-data-var swap6-amount uint u100000000) ;; CHA -> ORDI (8 decimals)

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
(define-read-only (get-swap4-amount) (var-get swap4-amount))
(define-read-only (get-swap5-amount) (var-get swap5-amount))
(define-read-only (get-swap6-amount) (var-get swap6-amount))

;; Single function to set all swap amounts
(define-public (set-all-swap-amounts 
    (amount1 uint) 
    (amount2 uint) 
    (amount3 uint) 
    (amount4 uint) 
    (amount5 uint) 
    (amount6 uint))
  (begin
    (asserts! (is-authorized tx-sender) err-not-authorized)
    (asserts! (not (var-get contract-paused)) err-contract-paused)
    ;; Validate amounts
    (asserts! (and 
      (> amount1 u0) 
      (> amount2 u0) 
      (> amount3 u0) 
      (> amount4 u0) 
      (> amount5 u0)
      (> amount6 u0)) 
      err-invalid-amount)
    
    ;; Set all amounts
    (var-set swap1-amount amount1)
    (var-set swap2-amount amount2)
    (var-set swap3-amount amount3)
    (var-set swap4-amount amount4)
    (var-set swap5-amount amount5)
    (var-set swap6-amount amount6)
    (ok true)))

;; Private helper function for swap validation
(define-private (validate-swap-params (amount uint))
  (begin
    (asserts! (is-authorized tx-sender) err-not-authorized)
    (asserts! (not (var-get contract-paused)) err-contract-paused)
    (asserts! (> amount u0) err-invalid-amount)
    (ok true)))
  
;; Main swap function with all operations
(define-public (swap-3)
  (begin
    (asserts! (not (var-get contract-paused)) err-contract-paused)
    
    ;; Swap 1: CHA -> KANGAROO
    (try! (validate-swap-params (var-get swap1-amount)))
    (let ((swap1 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 
                       do-swap (var-get swap1-amount) 
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token 
                       'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo 
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to))))
      (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core mint u7 
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token 
                         'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo 
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.cha-roo 
                         (var-get swap1-amount) 
                         (get amt-out swap1))))

    ;; Swap 2: CHA -> WELSH
    (try! (validate-swap-params (var-get swap2-amount)))
    (let ((swap2 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 
                       do-swap (var-get swap2-amount) 
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token 
                       'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token  
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to))))
      (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core mint u3
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token 
                         'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.cha-welsh 
                         (var-get swap2-amount) 
                         (get amt-out swap2))))

    ;; Swap 3: CHA -> SYNTHETIC-WELSH
    (try! (validate-swap-params (var-get swap3-amount)))
    (let ((swap3 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 
                       do-swap (var-get swap3-amount) 
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token 
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.synthetic-welsh
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to))))
      (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core mint u5
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token 
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.synthetic-welsh
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.cha-iouwelsh 
                         (var-get swap3-amount) 
                         (get amt-out swap3))))

    ;; Swap 4: CHA -> UP-DOG
    (try! (validate-swap-params (var-get swap4-amount)))
    (let ((swap4 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 
                       do-swap (var-get swap4-amount) 
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token 
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.up-dog
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to))))
      (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core mint u9
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token 
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.up-dog 
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.cha-updog 
                         (var-get swap4-amount) 
                         (get amt-out swap4))))

    ;; Swap 5: CHA -> WSTX
    (try! (validate-swap-params (var-get swap5-amount)))
    (let ((swap5 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 
                       do-swap (var-get swap5-amount) 
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token 
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wstx
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to))))
      (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core mint u4
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wstx 
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wstx-cha 
                         (var-get swap5-amount) 
                         (get amt-out swap5))))

    ;; Swap 6: CHA -> ORDI (8 decimals)
    (try! (validate-swap-params (var-get swap6-amount)))
    (let ((swap6 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 
                       do-swap (var-get swap6-amount) 
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token 
                       'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ordi
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to))))
      (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core mint u6
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token 
                         'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ordi
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.cha-ordi 
                         (var-get swap6-amount) 
                         (get amt-out swap6))))
    (ok true)))

;; Read-only function to check if a user is authorized
(define-read-only (check-authorization (user principal))
  (is-authorized user))
```
