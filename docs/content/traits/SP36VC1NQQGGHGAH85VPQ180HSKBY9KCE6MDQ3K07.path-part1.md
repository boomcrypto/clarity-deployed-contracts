---
title: "Trait path-part1"
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

;; Define data variables for buy amounts
(define-data-var kangaroo-amount uint u1000000)     ;; KANGAROO -> CHA
(define-data-var welsh-amount uint u6000000)        ;; WELSH -> CHA
(define-data-var synthetic-amount uint u9500000)    ;; SYNTHETIC-WELSH -> CHA
(define-data-var updog-amount uint u4000000)        ;; UP-DOG -> CHA
(define-data-var wstx-amount uint u5000000)         ;; WSTX -> CHA
(define-data-var ordi-amount uint u100000000)       ;; ORDI -> CHA (8 decimals)

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

;; Getter functions for buy amounts
(define-read-only (get-kangaroo-amount) (var-get kangaroo-amount))
(define-read-only (get-welsh-amount) (var-get welsh-amount))
(define-read-only (get-synthetic-amount) (var-get synthetic-amount))
(define-read-only (get-updog-amount) (var-get updog-amount))
(define-read-only (get-wstx-amount) (var-get wstx-amount))
(define-read-only (get-ordi-amount) (var-get ordi-amount))

;; Single function to set all buy amounts
(define-public (set-all-buy-amounts 
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
    (var-set kangaroo-amount amount1)
    (var-set welsh-amount amount2)
    (var-set synthetic-amount amount3)
    (var-set updog-amount amount4)
    (var-set wstx-amount amount5)
    (var-set ordi-amount amount6)
    (ok true)))

;; Private helper function for swap validation
(define-private (validate-swap-params (amount uint))
  (begin
    (asserts! (is-authorized tx-sender) err-not-authorized)
    (asserts! (not (var-get contract-paused)) err-contract-paused)
    (asserts! (> amount u0) err-invalid-amount)
    (ok true)))
;; Main buy function for CHA with all operations
(define-public (buy-cha)
  (begin
    (asserts! (not (var-get contract-paused)) err-contract-paused)
    
    ;; Buy 1: KANGAROO -> CHA
    (try! (validate-swap-params (var-get kangaroo-amount)))
    (let ((swap1 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 
                       do-swap (var-get kangaroo-amount)
                       'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to))))
      (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core mint u7 
                         'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.cha-roo 
                         (var-get kangaroo-amount) 
                         (get amt-out swap1))))

    ;; Buy 2: WELSH -> CHA
    (try! (validate-swap-params (var-get welsh-amount)))
    (let ((swap2 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 
                       do-swap (var-get welsh-amount)
                       'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to))))
      (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core mint u3
                         'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.cha-welsh 
                         (var-get welsh-amount) 
                         (get amt-out swap2))))

    ;; Buy 3: SYNTHETIC-WELSH -> CHA
    (try! (validate-swap-params (var-get synthetic-amount)))
    (let ((swap3 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 
                       do-swap (var-get synthetic-amount)
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.synthetic-welsh
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to))))
      (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core mint u5
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.synthetic-welsh
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.cha-iouwelsh 
                         (var-get synthetic-amount) 
                         (get amt-out swap3))))

    ;; Buy 4: UP-DOG -> CHA
    (try! (validate-swap-params (var-get updog-amount)))
    (let ((swap4 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 
                       do-swap (var-get updog-amount)
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.up-dog
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to))))
      (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core mint u9
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.up-dog
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.cha-updog 
                         (var-get updog-amount) 
                         (get amt-out swap4))))

    ;; Buy 5: WSTX -> CHA
    (try! (validate-swap-params (var-get wstx-amount)))
    (let ((swap5 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 
                       do-swap (var-get wstx-amount)
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wstx
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to))))
      (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core mint u4
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wstx
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wstx-cha 
                         (var-get wstx-amount) 
                         (get amt-out swap5))))

    ;; Buy 6: ORDI -> CHA
    (try! (validate-swap-params (var-get ordi-amount)))
    (let ((swap6 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 
                       do-swap (var-get ordi-amount)
                       'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ordi
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                       'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to))))
      (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core mint u6
                         'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ordi
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.cha-ordi 
                         (var-get ordi-amount) 
                         (get amt-out swap6))))
    (ok true)))

;; Read-only function to check if a user is authorized
(define-read-only (check-authorization (user principal))
  (is-authorized user))
```
