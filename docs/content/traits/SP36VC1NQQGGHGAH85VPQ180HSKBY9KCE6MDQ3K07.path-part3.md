---
title: "Trait path-part3"
draft: true
---
```
;; Contract Management & Configuration
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-invalid-amount (err u102))
(define-constant err-swap-failed (err u103))
(define-constant err-insufficient-profit (err u104))
(define-constant err-postconditions (err u105))

;; Token decimal constants
(define-constant decimal-6 u1000000)     ;; 6 decimals for most tokens
(define-constant decimal-8 u100000000)   ;; 8 decimals for ORDI

;; Profit tracking
(define-data-var total-profit uint u0)

;; Define data variables for swap amounts - Welsh Route 1
(define-data-var strw1-amt-in uint decimal-6)
(define-data-var strw1-amt-out-min uint decimal-6)

;; Define data variables for swap amounts - Welsh Route 2
(define-data-var strw2-amt-in uint decimal-6)
(define-data-var strw2-amt-out-min uint decimal-6)

;; Define data variables for swap amounts - Roo Route 1
(define-data-var strr1-amt-in uint decimal-6)
(define-data-var strr1-amt-out-min uint decimal-6)

;; Define data variables for swap amounts - Roo Route 2
(define-data-var strr2-amt-in uint decimal-6)
(define-data-var strr2-amt-out-min uint decimal-6)

;; Authorization map
(define-map authorized-users principal bool)

;; Authorization check
(define-private (is-authorized)
  (or
    (is-eq tx-sender contract-owner)
    (default-to false (map-get? authorized-users tx-sender))))

;; User management
(define-public (add-authorized-user (user principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set authorized-users user true))))

(define-public (remove-authorized-user (user principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-delete authorized-users user))))

;; Profit tracking
(define-private (update-profit (amount uint))
  (var-set total-profit (+ (var-get total-profit) amount)))

;; Getter functions for amounts
(define-read-only (get-strw1-amounts)
  (ok {amt-in: (var-get strw1-amt-in), amt-out-min: (var-get strw1-amt-out-min)}))

(define-read-only (get-strw2-amounts)
  (ok {amt-in: (var-get strw2-amt-in), amt-out-min: (var-get strw2-amt-out-min)}))

(define-read-only (get-strr1-amounts)
  (ok {amt-in: (var-get strr1-amt-in), amt-out-min: (var-get strr1-amt-out-min)}))

(define-read-only (get-strr2-amounts)
  (ok {amt-in: (var-get strr2-amt-in), amt-out-min: (var-get strr2-amt-out-min)}))

(define-read-only (get-total-profit)
  (var-get total-profit))

;; Amount setter function for all routes
(define-public (set-all-route-amounts
    (w1-in uint) (w1-min uint)
    (w2-in uint) (w2-min uint)
    (r1-in uint) (r1-min uint)
    (r2-in uint) (r2-min uint))
  (begin
    (asserts! (is-authorized) err-not-authorized)
    ;; Set Welsh Route 1 amounts
    (var-set strw1-amt-in w1-in)
    (var-set strw1-amt-out-min w1-min)
    ;; Set Welsh Route 2 amounts
    (var-set strw2-amt-in w2-in)
    (var-set strw2-amt-out-min w2-min)
    ;; Set Roo Route 1 amounts
    (var-set strr1-amt-in r1-in)
    (var-set strr1-amt-out-min r1-min)
    ;; Set Roo Route 2 amounts
    (var-set strr2-amt-in r2-in)
    (var-set strr2-amt-out-min r2-min)
    (ok true)))
  ;; Swap strategies

;; Welsh Route Strategy 1: CHA -> WSTX -> WELSH -> CHA
(define-public (strw1)
  (begin
    (asserts! (is-authorized) err-not-authorized)
    (let (
        (amt-in (var-get strw1-amt-in))
        (swap1 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 do-swap amt-in
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wstx
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to)))
        (swap2 (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 do-swap (get amt-out swap1)
                      'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
                      'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
                      'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to)))
        (swap3 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 do-swap (get amt-out swap2)
                      'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to)))
        (profit (- (get amt-out swap3) amt-in))
        )
      (asserts! (> profit u0) err-postconditions)
      (update-profit profit)
      (ok profit))))

;; Welsh Route Strategy 2: CHA -> WELSH -> WSTX -> CHA
(define-public (strw2)
  (begin
    (asserts! (is-authorized) err-not-authorized)
    (let (
        (amt-in (var-get strw2-amt-in))
        (swap1 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 do-swap amt-in
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                      'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to)))
        (swap2 (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 do-swap (get amt-out swap1)
                      'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
                      'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
                      'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to)))
        (swap3 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 do-swap (get amt-out swap2)
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wstx
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to)))
        (profit (- (get amt-out swap3) amt-in))
        )
      (asserts! (> profit u0) err-postconditions)
      (update-profit profit)
      (ok profit))))

;; Roo Route Strategy 1: CHA -> WSTX -> ROO -> CHA
(define-public (strr1)
  (begin
    (asserts! (is-authorized) err-not-authorized)
    (let (
        (amt-in (var-get strr1-amt-in))
        (swap1 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 do-swap amt-in
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wstx
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to)))
        (swap2 (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 do-swap (get amt-out swap1)
                      'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
                      'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo
                      'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to)))
        (swap3 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 do-swap (get amt-out swap2)
                      'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to)))
        (profit (- (get amt-out swap3) amt-in))
        )
      (asserts! (> profit u0) err-postconditions)
      (update-profit profit)
      (ok profit))))

;; Roo Route Strategy 2: CHA -> ROO -> WSTX -> CHA
(define-public (strr2)
  (begin
    (asserts! (is-authorized) err-not-authorized)
    (let (
        (amt-in (var-get strr2-amt-in))
        (swap1 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 do-swap amt-in
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                      'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to)))
        (swap2 (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 do-swap (get amt-out swap1)
                      'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo
                      'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
                      'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to)))
        (swap3 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 do-swap (get amt-out swap2)
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wstx
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to)))
        (profit (- (get amt-out swap3) amt-in))
        )
      (asserts! (> profit u0) err-postconditions)
      (update-profit profit)
      (ok profit))))

;; Execute all strategies
(define-public (execute-all-strategies)
  (begin
    (asserts! (is-authorized) err-not-authorized)
    (try! (strw1))
    (try! (strw2))
    (try! (strr1))
    (try! (strr2))
    (ok (var-get total-profit))))
```
