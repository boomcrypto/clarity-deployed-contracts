(use-trait ft-trait .trait-sip-010.sip-010-trait)
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-UNKNOWN-PAIR (err u1005))
(define-constant ERR-INVALID-AMOUNT (err u1019))
(define-constant MAX_UINT u340282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)
(define-data-var contract-owner principal tx-sender)
(define-map accrued-fee principal uint)
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
(define-read-only (get-contract-owner)
  (var-get contract-owner))
(define-read-only (get-accrued-fee-or-default (token principal))
  (match (contract-call? .cross-bridge-registry-v1-03 get-approved-token-id-or-fail token)
    ok-value (contract-call? .cross-bridge-registry-v1-03 get-accrued-fee-or-default ok-value)
    err-value (default-to u0 (map-get? accrued-fee token))))
(define-read-only (get-approved-pair-or-fail (pair { token: principal, chain-id: uint }))
  (ok (unwrap! (map-get? approved-pairs pair) ERR-UNKNOWN-PAIR)))
(define-read-only (is-approved-operator-or-default (operator principal))
  (contract-call? .cross-bridge-registry-v1-03 is-approved-operator-or-default operator))
(define-read-only (is-approved-relayer-or-default (relayer principal))
  (contract-call? .cross-bridge-registry-v1-03 is-approved-relayer-or-default relayer))
(define-read-only (is-order-sent-or-default (order-hash (buff 32)))
  (contract-call? .cross-bridge-registry-v1-03 is-order-sent-or-default order-hash))
(define-read-only (is-order-validated-by-or-default (order-hash (buff 32)) (validator principal))
  (contract-call? .cross-bridge-registry-v1-03 is-order-validated-by-or-default order-hash validator))
(define-read-only (get-validator-id (validator principal))
	(contract-call? .cross-bridge-registry-v1-03 get-validator-id validator))
(define-read-only (get-validator-id-or-fail (validator principal))
	(contract-call? .cross-bridge-registry-v1-03 get-validator-id-or-fail validator))
(define-read-only (validator-from-id (id uint))
	(contract-call? .cross-bridge-registry-v1-03 validator-from-id id))
(define-read-only (validator-from-id-or-fail (id uint))
	(contract-call? .cross-bridge-registry-v1-03 validator-from-id-or-fail id))
  
(define-read-only (get-required-validators)
  (contract-call? .cross-bridge-registry-v1-03 get-required-validators))
(define-read-only (get-approved-chain-or-fail (the-chain-id uint))
  (contract-call? .cross-bridge-registry-v1-03 get-approved-chain-or-fail the-chain-id))
(define-read-only (get-token-reserve-or-default (pair { token: principal, chain-id: uint }))
  (match (contract-call? .cross-bridge-registry-v1-03 get-approved-token-id-or-fail (get token pair))
    ok-value (contract-call? .cross-bridge-registry-v1-03 get-token-reserve-or-default ok-value (get chain-id pair))
    err-value (match (map-get? approved-pairs pair) some-value (get reserve some-value) u0)))
(define-read-only (get-min-fee-or-default (pair { token: principal, chain-id: uint }))
  (match (contract-call? .cross-bridge-registry-v1-03 get-approved-token-id-or-fail (get token pair))
    ok-value (contract-call? .cross-bridge-registry-v1-03 get-min-fee-or-default ok-value (get chain-id pair))
    err-value (match (map-get? approved-pairs pair) some-value (get min-fee some-value) MAX_UINT)))
(define-public (set-contract-owner-legacy (new-contract-owner principal))
  (begin 
    (try! (check-is-owner))
    (as-contract (contract-call? .cross-bridge-registry-v1-03 set-contract-owner new-contract-owner))))
(define-public (approve-operator (operator principal) (approved bool))
  (begin 
    (try! (check-is-owner))
    (as-contract (contract-call? .cross-bridge-registry-v1-03 approve-operator operator approved))))
(define-public (add-validator (validator-pubkey (buff 33)) (validator principal))
  (begin 
    (try! (check-is-owner))
    (as-contract (contract-call? .cross-bridge-registry-v1-03 add-validator validator-pubkey validator))))
(define-public (remove-validator (validator principal))
  (begin
    (try! (check-is-owner))
    (as-contract (contract-call? .cross-bridge-registry-v1-03 remove-validator validator))))
(define-public (approve-relayer (relayer principal) (approved bool))
  (begin
    (try! (check-is-owner))
    (as-contract (contract-call? .cross-bridge-registry-v1-03 approve-relayer relayer approved))))
(define-public (set-required-validators (new-required-validators uint))
  (begin
    (try! (check-is-owner))
    (as-contract (contract-call? .cross-bridge-registry-v1-03 set-required-validators new-required-validators))))
(define-public (set-approved-chain (the-chain-id uint) (chain-details { name: (string-utf8 256), buff-length: uint }))
  (begin
    (try! (check-is-owner))    
    (as-contract (contract-call? .cross-bridge-registry-v1-03 set-approved-chain the-chain-id chain-details))))
(define-public (collect-accrued-fee (token-trait <ft-trait>))
  (begin
    (try! (check-is-owner))
    (if (is-ok (contract-call? .cross-bridge-registry-v1-03 get-approved-token-id-or-fail (contract-of token-trait)))
      (as-contract (contract-call? .cross-bridge-registry-v1-03 collect-accrued-fee token-trait))
      (let (
          (fee (get-accrued-fee-or-default (contract-of token-trait))))        
        (and (> fee u0) (as-contract (try! (contract-call? token-trait transfer-fixed fee tx-sender (var-get contract-owner) none))))
        (ok (map-set accrued-fee (contract-of token-trait) u0))))))
(define-public (set-contract-owner (owner principal))
  (begin
    (try! (check-is-owner))
    (ok (var-set contract-owner owner))))
(define-public (transfer-all-to (new-owner principal) (token-trait <ft-trait>))
	(let (
			(balance (try! (contract-call? token-trait get-balance-fixed (as-contract tx-sender)))))
		(try! (check-is-owner))
		(and (> balance u0) (as-contract (try! (contract-call? token-trait transfer-fixed balance tx-sender new-owner none))))
		(ok true)))
(define-public (transfer-all-to-many (new-owner principal) (token-traits (list 10 <ft-trait>)))
	(ok (map transfer-all-to 
		(list new-owner new-owner new-owner new-owner new-owner new-owner new-owner new-owner new-owner new-owner)
		token-traits)))
(define-public (transfer-fixed (token-trait <ft-trait>) (amount uint) (recipient principal))
  (begin 
    (try! (check-is-approved))
    (as-contract (contract-call? token-trait transfer-fixed amount tx-sender recipient none))))
(define-public (set-token-reserve (pair { token: principal, chain-id: uint }) (new-reserve uint))
  (match (contract-call? .cross-bridge-registry-v1-03 get-approved-token-id-or-fail (get token pair))
    ok-value (contract-call? .cross-bridge-registry-v1-03 set-token-reserve { token-id: ok-value, chain-id: (get chain-id pair) } new-reserve)
    err-value 
    (begin 
      (try! (check-is-approved))
      (ok (map-set approved-pairs pair (merge (try! (get-approved-pair-or-fail pair)) { reserve: new-reserve }))))))
(define-public (add-token-reserve (pair { token: principal, chain-id: uint }) (reserve-to-add uint))
  (set-token-reserve pair (+ (get-token-reserve-or-default pair) reserve-to-add)))
(define-public (remove-token-reserve (pair { token: principal, chain-id: uint }) (reserve-to-remove uint))
  (let (
      (reserve-before (get-token-reserve-or-default pair))
      (reserve-ok (asserts! (<= reserve-to-remove reserve-before) ERR-INVALID-AMOUNT)))
    (set-token-reserve pair (- reserve-before reserve-to-remove))))
(define-public (set-accrued-fee (token principal) (new-accrued-fee uint))
  (match (contract-call? .cross-bridge-registry-v1-03 get-approved-token-id-or-fail token)
    ok-value (contract-call? .cross-bridge-registry-v1-03 set-accrued-fee ok-value new-accrued-fee)
    err-value
    (begin 
      (try! (check-is-approved))
      (ok (map-set accrued-fee token new-accrued-fee)))))
(define-public (add-accrued-fee (token principal) (fee-to-add uint))
  (set-accrued-fee token (+ (get-accrued-fee-or-default token) fee-to-add)))
(define-public (remove-accrued-fee (token principal) (fee-to-remove uint))
  (let (
      (fee-before (get-accrued-fee-or-default token))
      (fee-ok (asserts! (<= fee-to-remove fee-before) ERR-INVALID-AMOUNT)))
    (set-accrued-fee token (- fee-before fee-to-remove))))
(define-public (set-approved-pair (pair { token: principal, chain-id: uint }) (details { approved: bool, burnable: bool, fee: uint, min-fee: uint, min-amount: uint, max-amount: uint }))
  (begin
    (try! (check-is-approved))
    (ok (map-set approved-pairs pair (merge details { reserve: (get-token-reserve-or-default pair) })))))
(define-public (set-order-sent (order-hash (buff 32)) (sent bool))
  (contract-call? .cross-bridge-registry-v1-03 set-order-sent order-hash sent))
(define-public (set-order-sent-many (order-hashes (list 1000 (buff 32))) (sents (list 1000 bool)))
  (contract-call? .cross-bridge-registry-v1-03 set-order-sent-many order-hashes sents))
(define-public (set-order-validated-by (order-tuple { order-hash: (buff 32), validator: principal }) (validated bool))
  (contract-call? .cross-bridge-registry-v1-03 set-order-validated-by order-tuple validated))
(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)))
(define-private (check-is-approved)
  (ok (asserts! (or (is-approved-operator-or-default tx-sender) (is-ok (check-is-owner))) ERR-NOT-AUTHORIZED)))
(define-private (mul-down (a uint) (b uint))
    (/ (* a b) ONE_8))
(define-private (div-down (a uint) (b uint))
    (if (is-eq a u0) u0 (/ (* a ONE_8) b)))
(define-private (max (a uint) (b uint))
  (if (<= a b) b a))