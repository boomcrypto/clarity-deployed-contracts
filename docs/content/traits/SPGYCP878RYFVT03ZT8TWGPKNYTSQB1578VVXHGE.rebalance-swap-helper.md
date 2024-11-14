---
title: "Trait rebalance-swap-helper"
draft: true
---
```
;; Define data variables for swap amounts
(define-data-var swap1-amt-in uint u25000000)
(define-data-var swap1-amt-out-min uint u25000000)
(define-data-var swap2-amt-in uint u25000000)
(define-data-var swap2-amt-out-min uint u25000000)

;; Define the contract owner
(define-constant contract-owner tx-sender)

;; Map to store authorized users
(define-map authorized-users principal bool)

;; Check if the caller is the contract owner
(define-private (is-contract-owner)
  (is-eq tx-sender contract-owner))

;; Check if the caller is authorized
(define-private (is-authorized)
  (or (is-contract-owner) (default-to false (map-get? authorized-users tx-sender))))

;; Function to add an authorized user (only callable by contract owner)
(define-public (add-authorized-user (user principal))
  (begin
    (asserts! (is-contract-owner) (err u100))
    (ok (map-set authorized-users user true))))

;; Function to remove an authorized user (only callable by contract owner)
(define-public (remove-authorized-user (user principal))
  (begin
    (asserts! (is-contract-owner) (err u101))
    (ok (map-delete authorized-users user))))

;; Function to update swap amounts (only callable by authorized users)
(define-public (update-swap-amounts (new-swap1-in uint) (new-swap1-out uint) (new-swap2-in uint) (new-swap2-out uint))
  (begin
    (asserts! (is-authorized) (err u102))
    (var-set swap1-amt-in new-swap1-in)
    (var-set swap1-amt-out-min new-swap1-out)
    (var-set swap2-amt-in new-swap2-in)
    (var-set swap2-amt-out-min new-swap2-out)
    (ok true)))

;; First swap function
(define-public (perform-swap-1)
  (begin
    (asserts! (is-authorized) (err u103))
    (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 swap-4
      (var-get swap1-amt-in)
      (var-get swap1-amt-out-min)
      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
      'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.synthetic-welsh
      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to
    )))

;; Second swap function
(define-public (perform-swap-2)
  (begin
    (asserts! (is-authorized) (err u104))
    (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 swap-4
      (var-get swap2-amt-in)
      (var-get swap2-amt-out-min)
      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.synthetic-welsh
      'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to
    )))
```
