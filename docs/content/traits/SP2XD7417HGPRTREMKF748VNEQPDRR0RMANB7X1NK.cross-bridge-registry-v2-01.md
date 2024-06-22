---
title: "Trait cross-bridge-registry-v2-01"
draft: true
---
```
(use-trait ft-trait .trait-sip-010.sip-010-trait)
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-UNKNOWN-PAIR (err u1005))
(define-constant ERR-UNKNOWN-VALIDATOR (err u1006))
(define-constant ERR-VALIDATOR-ALREADY-REGISTERED (err u1008))
(define-constant ERR-REQUIRED-VALIDATORS (err u1013))
(define-constant ERR-INVALID-INPUT (err u1017))
(define-constant ERR-UNKNOWN-CHAIN-ID (err u1018))
(define-constant ERR-INVALID-AMOUNT (err u1019))
(define-constant MAX_UINT u340282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)
(define-constant MAX_REQUIRED_VALIDATORS u20)
(define-map approved-relayers principal bool)
(define-map validator-registry principal { chain-id: uint, pubkey: (buff 33) })
(define-data-var required-validators uint MAX_UINT)
(define-map accrued-fee principal uint)
(define-data-var fee-to-address principal .executor-dao)
(define-data-var chain-nonce uint u0)
(define-map chain-registry uint { name: (string-utf8 256), buff-length: uint })
(define-map approved-pairs 
  { token: principal, chain-id: uint } 
  { 
    approved: bool, 
    burnable: bool, 
    fee: uint, 
    min-fee: uint, 
    min-amount: uint, 
    max-amount: uint, 
    reserve: uint 
  })
(define-map order-sent (buff 32) bool)
(define-map order-validated-by { order-hash: (buff 32), validator: principal } bool)
(define-data-var order-hash-to-iter (buff 32) 0x)
(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .executor-dao) (contract-call? .executor-dao is-extension contract-caller)) ERR-NOT-AUTHORIZED)))
(define-read-only (get-accrued-fee-or-default (token principal))
  (default-to u0 (map-get? accrued-fee token)))
(define-read-only (get-approved-pair-or-fail (pair { token: principal, chain-id: uint }))
  (ok (unwrap! (map-get? approved-pairs pair) ERR-UNKNOWN-PAIR)))
(define-read-only (is-approved-relayer-or-default (relayer principal))
  (default-to false (map-get? approved-relayers relayer)))
(define-read-only (is-order-sent-or-default (order-hash (buff 32)))
  (default-to false (map-get? order-sent order-hash)))
(define-read-only (is-order-validated-by-or-default (order-hash (buff 32)) (validator principal))
  (default-to false (map-get? order-validated-by {order-hash: order-hash, validator: validator})))
(define-read-only (get-validator-or-fail (validator principal))
  (ok (unwrap! (map-get? validator-registry validator) ERR-UNKNOWN-VALIDATOR)))
(define-read-only (get-required-validators)
  (var-get required-validators))
(define-read-only (get-approved-chain-or-fail (the-chain-id uint))
  (ok (unwrap! (map-get? chain-registry the-chain-id) ERR-UNKNOWN-CHAIN-ID)))
(define-read-only (get-token-reserve-or-default (pair { token: principal, chain-id: uint }))
  (match (map-get? approved-pairs pair) some-value (get reserve some-value) u0))
(define-read-only (get-min-fee-or-default (pair { token: principal, chain-id: uint }))
  (match (map-get? approved-pairs pair)
    some-value (get min-fee some-value) MAX_UINT))
(define-read-only (get-fee-to-address)
  (var-get fee-to-address))
(define-public (set-fee-to-address (new-address principal))
  (begin
    (try! (is-dao-or-extension))
    (ok (var-set fee-to-address new-address))))
(define-public (add-validator (validator principal) (details { chain-id: uint, pubkey: (buff 33) }))
	(begin
    (try! (is-dao-or-extension))
    (ok (asserts! (map-insert validator-registry validator details) ERR-VALIDATOR-ALREADY-REGISTERED))))
(define-public (remove-validator (validator principal))
  (begin
    (try! (is-dao-or-extension))
    (ok (map-delete validator-registry validator))))
(define-public (approve-relayer (relayer principal) (approved bool))
  (begin
    (try! (is-dao-or-extension))
    (ok (map-set approved-relayers relayer approved))))
(define-public (set-required-validators (new-required-validators uint))
  (begin
    (try! (is-dao-or-extension))
    (asserts! (< new-required-validators MAX_REQUIRED_VALIDATORS) ERR-REQUIRED-VALIDATORS)
    (ok (var-set required-validators new-required-validators))))
(define-public (set-approved-chain (the-chain-id uint) (chain-details { name: (string-utf8 256), buff-length: uint }))
  (let (
      (the-chain-id-next (+ (var-get chain-nonce) u1))
      (print-msg (merge chain-details { object: "cross-bridge-registry", action: "set-approved-chain" })))
    (try! (is-dao-or-extension))
    (match (map-get? chain-registry the-chain-id)
      some-value (begin (map-set chain-registry the-chain-id chain-details) (print (merge print-msg { chain-id: the-chain-id })) (ok the-chain-id))
      (begin 
        (var-set chain-nonce the-chain-id-next)
        (map-set chain-registry the-chain-id-next chain-details)
        (print (merge print-msg { chain-id: the-chain-id-next }))
        (ok the-chain-id-next)))))
(define-public (collect-accrued-fee (token-trait <ft-trait>))
  (let (
      (fee (get-accrued-fee-or-default (contract-of token-trait))))
    (try! (is-dao-or-extension))
    (and (> fee u0) (as-contract (try! (contract-call? token-trait transfer-fixed fee tx-sender (var-get fee-to-address) none))))
    (ok (map-set accrued-fee (contract-of token-trait) u0))))
(define-public (transfer-all-to (new-owner principal) (token-trait <ft-trait>))
	(let (
			(balance (try! (contract-call? token-trait get-balance-fixed (as-contract tx-sender)))))
		(try! (is-dao-or-extension))
		(and (> balance u0) (as-contract (try! (contract-call? token-trait transfer-fixed balance tx-sender new-owner none))))
		(ok true)))
(define-public (transfer-all-to-many (new-owner principal) (token-traits (list 10 <ft-trait>)))
	(ok (map transfer-all-to 
		(list new-owner new-owner new-owner new-owner new-owner new-owner new-owner new-owner new-owner new-owner)
		token-traits)))
(define-public (transfer-fixed (token-trait <ft-trait>) (amount uint) (recipient principal))
  (begin 
    (try! (is-dao-or-extension))
    (as-contract (contract-call? token-trait transfer-fixed amount tx-sender recipient none))))
(define-public (set-token-reserve (pair { token: principal, chain-id: uint }) (new-reserve uint))
  (begin 
      (try! (is-dao-or-extension))
      (ok (map-set approved-pairs pair (merge (try! (get-approved-pair-or-fail pair)) { reserve: new-reserve })))))
(define-public (add-token-reserve (pair { token: principal, chain-id: uint }) (reserve-to-add uint))
  (set-token-reserve pair (+ (get-token-reserve-or-default pair) reserve-to-add)))
(define-public (remove-token-reserve (pair { token: principal, chain-id: uint }) (reserve-to-remove uint))
  (let (
      (reserve-before (get-token-reserve-or-default pair))
      (reserve-ok (asserts! (<= reserve-to-remove reserve-before) ERR-INVALID-AMOUNT)))
    (set-token-reserve pair (- reserve-before reserve-to-remove))))
(define-public (set-accrued-fee (token principal) (new-accrued-fee uint))
  (begin 
    (try! (is-dao-or-extension))
    (ok (map-set accrued-fee token new-accrued-fee))))
(define-public (add-accrued-fee (token principal) (fee-to-add uint))
  (set-accrued-fee token (+ (get-accrued-fee-or-default token) fee-to-add)))
(define-public (remove-accrued-fee (token principal) (fee-to-remove uint))
  (let (
      (fee-before (get-accrued-fee-or-default token))
      (fee-ok (asserts! (<= fee-to-remove fee-before) ERR-INVALID-AMOUNT)))
    (set-accrued-fee token (- fee-before fee-to-remove))))
(define-public (set-approved-pair (pair { token: principal, chain-id: uint }) (details { approved: bool, burnable: bool, fee: uint, min-fee: uint, min-amount: uint, max-amount: uint }))
  (begin
    (try! (is-dao-or-extension))
    (print (merge (merge pair details) { object: "cross-bridge-registry", action: "set-approved-pair" }))
    (match (map-get? approved-pairs pair)
      some-value (ok (map-set approved-pairs pair (merge some-value details)))
      (ok (map-set approved-pairs pair (merge details { reserve: u0 }))))))
(define-public (set-order-sent (order-hash (buff 32)) (sent bool))
  (begin 
    (try! (is-dao-or-extension))
    (ok (map-set order-sent order-hash true))))
(define-public (set-order-sent-many (order-hashes (list 1000 (buff 32))) (sents (list 1000 bool)))
  (begin 
    (asserts! (is-eq (len order-hashes) (len sents)) ERR-INVALID-INPUT)
    (ok (map set-order-sent order-hashes sents))))
(define-public (set-order-validated-by (order-tuple { order-hash: (buff 32), validator: principal }) (validated bool))
  (begin 
    (try! (is-dao-or-extension))
    (ok (map-set order-validated-by order-tuple true))))
(define-private (mul-down (a uint) (b uint))
  (/ (* a b) ONE_8))
(define-private (div-down (a uint) (b uint))
  (if (is-eq a u0) u0 (/ (* a ONE_8) b)))
(define-private (max (a uint) (b uint))
  (if (<= a b) b a))
```
