---
title: "Trait cross-peg-in-v2-04-swap"
draft: true
---
```
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.extension-trait.extension-trait)

(use-trait ft-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.trait-sip-010.sip-010-trait)

(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-TOKEN-NOT-AUTHORIZED (err u1001))
(define-constant ERR-DUPLICATE-SIGNATURE (err u1009))
(define-constant ERR-ORDER-HASH-MISMATCH (err u1010))
(define-constant ERR-INVALID-SIGNATURE (err u1011))
(define-constant ERR-UKNOWN-RELAYER (err u1012))
(define-constant ERR-REQUIRED-VALIDATORS (err u1013))
(define-constant ERR-ORDER-ALREADY-SENT (err u1014))
(define-constant ERR-PAUSED (err u1015))
(define-constant ERR-INVALID-VALIDATOR (err u1016))
(define-constant ERR-INVALID-INPUT (err u1020))
(define-constant ERR-NOT-IN-WHITELIST (err u1021))
(define-constant ERR-INVALID-TOKEN (err u1022))
(define-constant ERR-SLIPPAGE (err u1023))

(define-constant MAX_UINT u340282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-constant structured-data-prefix 0x534950303138)
;; const domainHash = structuredDataHash(
;;   tupleCV({
;;     name: stringAsciiCV('XLink Bridge'),
;;     version: stringAsciiCV('0.0.2'),
;;     'chain-id': uintCV(new StacksMainnet().chainId) | uintCV(new StacksMocknet().chainId),
;;   }),
;; );
(define-constant message-domain-main 0x89a7c46bfde2bbffaf08240dd538c0da498e3645d938655e214bd9d67437747a) ;;mainnet
(define-constant message-domain-test 0xe104d090220bc57abaadbad4b9349d344954fe4de833e73df2013d5236a2b9ec) ;; testnet

(define-data-var is-paused bool true)

(define-data-var use-whitelist bool false)
(define-map whitelisted-users principal bool)

(define-data-var peg-out-fee uint u0)
(define-data-var peg-out-gas-fee uint u0)

;; public calls

;; read-only calls

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao) (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao is-extension contract-caller)) ERR-NOT-AUTHORIZED)))

(define-read-only (message-domain)
  (if (is-eq chain-id u1) message-domain-main message-domain-test))

(define-read-only (get-use-whitelist)
  (var-get use-whitelist))

(define-read-only (is-whitelisted (user principal))
  (default-to false (map-get? whitelisted-users user)))

(define-read-only (get-paused)
  (var-get is-paused))

(define-read-only (get-peg-out-fee)
  (var-get peg-out-fee))

(define-read-only (get-peg-out-gas-fee)
  (var-get peg-out-gas-fee))

(define-read-only (is-approved-relayer-or-default (relayer principal))
  (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 is-approved-relayer-or-default relayer))

(define-read-only (get-validator-or-fail (validator principal))
  (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-validator-or-fail validator))

(define-read-only (get-required-validators)
  (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-required-validators))

(define-read-only (get-approved-chain-or-fail (src-chain-id uint))
  (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-approved-chain-or-fail src-chain-id))

(define-read-only (get-token-reserve-or-default (pair { token: principal, chain-id: uint }))
  (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-token-reserve-or-default pair))

(define-read-only (get-min-fee-or-default (pair { token: principal, chain-id: uint }))
  (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-min-fee-or-default pair))

(define-read-only (get-approved-pair-or-fail (pair { token: principal, chain-id: uint }))
  (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-approved-pair-or-fail pair))

(define-read-only (is-order-sent-or-default (order-hash (buff 32)))
  (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 is-order-sent-or-default order-hash))

(define-read-only (is-order-validated-by-or-default (order-hash (buff 32)) (validator principal))
  (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 is-order-validated-by-or-default order-hash validator))

(define-read-only (create-cross-swap-order (order { from: (buff 128), to: (buff 128), amount-in-fixed: uint, token-in: principal, routing-tokens: (list 5 principal), routing-factors: (list 4 uint), token-out: principal, min-amount-out-fixed: (optional uint), src-chain-id: uint, dest-chain-id: (optional uint), salt: (buff 256) } ))
  (ok (unwrap! (to-consensus-buff? order) ERR-INVALID-INPUT)))

(define-read-only (decode-cross-swap-order (order-buff (buff 128)))
  (ok (unwrap! (from-consensus-buff? { from: (buff 128), to: (buff 128), amount-in-fixed: uint, token-in: principal, routing-tokens: (list 5 principal), routing-factors: (list 4 uint), token-out: principal, min-amount-out-fixed: (optional uint), src-chain-id: uint, dest-chain-id: (optional uint), salt: (buff 256) } order-buff) ERR-INVALID-INPUT)))

(define-read-only (hash-cross-swap-order (order { from: (buff 128), to: (buff 128), amount-in-fixed: uint, token-in: principal, routing-tokens: (list 5 principal), routing-factors: (list 4 uint), token-out: principal, min-amount-out-fixed: (optional uint), src-chain-id: uint, dest-chain-id: (optional uint), salt: (buff 256) } ))
  (ok (sha256 (try! (create-cross-swap-order order)))))
    
(define-read-only (validate-cross-swap-order 
  (order { from: (buff 128), to: (buff 128), amount-in-fixed: uint, token-in: principal, routing-tokens: (list 5 principal), routing-factors: (list 4 uint), token-out: principal, min-amount-out-fixed: (optional uint), src-chain-id: uint, dest-chain-id: (optional uint), salt: (buff 256) } )
  (token-in-trait <ft-trait>) (routing-traits (list 5 <ft-trait>)) (token-out-trait <ft-trait>))
  (let (
      (routing-token-0 (unwrap-panic (element-at? (get routing-tokens order) u0)))) 
    (asserts! (is-eq (len routing-traits) (len (get routing-tokens order))) ERR-INVALID-TOKEN)
    (asserts! (is-ok (fold check-err (map check-trait routing-traits (get routing-tokens order)) (ok true))) ERR-TOKEN-NOT-AUTHORIZED)
    (try! (check-trait token-in-trait (get token-in order)))
    (try! (check-trait token-out-trait (get token-out order)))
    (asserts! (or (is-eq (get token-in order) routing-token-0) (is-eq (try! (contract-call? .cross-router-v2-03 get-approved-wrapped-or-fail (get token-in order))) routing-token-0)) ERR-INVALID-TOKEN)
    (contract-call? .cross-router-v2-03 validate-route (get amount-in-fixed order) (get routing-tokens order) (get routing-factors order) (get token-out order) (get min-amount-out-fixed order) { address: (get to order), chain-id: (get dest-chain-id order) })))

(define-read-only (get-default-peg-out-fee (pair-tuple { token: principal, chain-id: uint }))
  (if (is-eq (get chain-id pair-tuple) u0)
    (ok { peg-out-fee: (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 get-peg-out-fee), peg-out-gas-fee: (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 get-peg-out-min-fee) })
    (if (or (is-eq (get chain-id pair-tuple) u1001) (is-eq (get chain-id pair-tuple) u1002)) ;; brc20 or runes
      (let (
        (pair-details (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 get-pair-details-or-fail pair-tuple))))
				(ok { peg-out-fee: (get peg-out-fee pair-details), peg-out-gas-fee: (get peg-out-gas-fee pair-details) }))
      (let (
        (pair-details (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-approved-pair-or-fail pair-tuple))))
				(ok { peg-out-fee: (get fee pair-details), peg-out-gas-fee: (get min-fee pair-details) })))))

;; governance calls

(define-public (set-paused (paused bool))
  (begin
    (try! (is-dao-or-extension))
    (ok (var-set is-paused paused))))

(define-public (apply-whitelist (new-use-whitelist bool))
  (begin
    (try! (is-dao-or-extension))
    (ok (var-set use-whitelist new-use-whitelist))))

(define-public (whitelist (user principal) (whitelisted bool))
  (begin
    (try! (is-dao-or-extension))
    (ok (map-set whitelisted-users user whitelisted))))

(define-public (whitelist-many (users (list 2000 principal)) (whitelisted (list 2000 bool)))
  (ok (map whitelist users whitelisted)))

(define-public (set-peg-out-fee (new-peg-out-fee uint))
  (begin
    (try! (is-dao-or-extension))
    (ok (var-set peg-out-fee new-peg-out-fee))))

(define-public (set-peg-out-gas-fee (new-peg-out-gas-fee uint))
  (begin
    (try! (is-dao-or-extension))
    (ok (var-set peg-out-gas-fee new-peg-out-gas-fee))))

(define-public (callback (sender principal) (payload (buff 2048)))
  (ok true))

;; privileged calls

(define-public (transfer-to-cross-swap
    (order { from: (buff 128), to: (buff 128), amount-in-fixed: uint, token-in: principal, routing-tokens: (list 5 principal), routing-factors: (list 4 uint), token-out: principal, min-amount-out-fixed: (optional uint), src-chain-id: uint, dest-chain-id: (optional uint), salt: (buff 256) })
    (token-in-trait <ft-trait>) (routing-traits (list 5 <ft-trait>)) (token-out-trait <ft-trait>)
    (signature-packs (list 100 { signer: principal, order-hash: (buff 32), signature: (buff 65)})))
    (let (
        (order-hash (try! (hash-cross-swap-order order)))
        (common-data (try! (transfer-common order-hash (get token-in order) (get src-chain-id order) signature-packs)))
        (token-details (get token-details common-data))
        (pair-tuple { token: (get token-out order), chain-id: (unwrap-panic (get dest-chain-id order)) })
        (print-msg (merge order { object: "cross-bridge-endpoint", action: "transfer-to-cross-swap" }))
        (default-fee-tuple (try! (get-default-peg-out-fee pair-tuple))))
      (if (get burnable token-details) 
        (as-contract (try! (contract-call? token-in-trait mint-fixed (get amount-in-fixed order) tx-sender)))
        (as-contract (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 transfer-fixed token-in-trait (get amount-in-fixed order) tx-sender))))
      (as-contract (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 add-token-reserve { token: (get token-in order), chain-id: (get src-chain-id order) } (get amount-in-fixed order))))
      (as-contract (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-order-sent order-hash true)))
      ;; @dev TODO peg-out-gas-fee is hard-coded to zero, without deducting upfront, for now.
      (and (is-some (get dest-chain-id order)) (try! (update-peg-out-fee pair-tuple (var-get peg-out-fee) u0)))
      (match (validate-cross-swap-order order token-in-trait routing-traits token-out-trait)
        ok-value
        (begin          
          (as-contract (try! (contract-call? .cross-router-v2-03 route (get amount-in-fixed order) routing-traits (get routing-factors order) token-out-trait (get min-amount-out-fixed order) { address: (get to order), chain-id: (get dest-chain-id order) })))          
          (and (is-some (get dest-chain-id order)) (try! (update-peg-out-fee pair-tuple (get peg-out-fee default-fee-tuple) (get peg-out-gas-fee default-fee-tuple))))
          (print (merge print-msg { success: true }))
          (ok true))
        err-value
        (begin
          (as-contract (try! (refund (get amount-in-fixed order) (get from order) token-in-trait (get src-chain-id order))))                    
          (and (is-some (get dest-chain-id order)) (try! (update-peg-out-fee pair-tuple (get peg-out-fee default-fee-tuple) (get peg-out-gas-fee default-fee-tuple))))
          (print (merge print-msg { success: false, err: err-value }))
          (ok false)))))

;; internal functions

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value)))

(define-private (check-trait (token-trait <ft-trait>) (token principal))
  (ok (asserts! (is-eq (contract-of token-trait) token) ERR-INVALID-TOKEN)))
  
(define-private (transfer-common (order-hash (buff 32)) (token principal) (src-chain-id uint) (signature-packs (list 100 { signer: principal, order-hash: (buff 32), signature: (buff 65)})))
  (let (
      (token-details (try! (get-approved-pair-or-fail { token: token, chain-id: src-chain-id })))
      (chain-details (try! (get-approved-chain-or-fail src-chain-id))))
    (asserts! (not (get-paused)) ERR-PAUSED)
    (asserts! (is-approved-relayer-or-default tx-sender) ERR-UKNOWN-RELAYER)
    (asserts! (>= (len signature-packs) (get-required-validators)) ERR-REQUIRED-VALIDATORS)
    (asserts! (not (is-order-sent-or-default order-hash)) ERR-ORDER-ALREADY-SENT)
    (try! (fold validate-signature-iter signature-packs (ok { order-hash: order-hash, src-chain-id: src-chain-id })))
    (ok { token-details: token-details, chain-details: chain-details })))

(define-private (validate-order (order-hash (buff 32)) (src-chain-id uint) (signature-pack { signer: principal, order-hash: (buff 32), signature: (buff 65)}))
  (let (
      (validator (try! (get-validator-or-fail (get signer signature-pack)))))
    (asserts! (not (is-order-validated-by-or-default order-hash (get signer signature-pack))) ERR-DUPLICATE-SIGNATURE)
    (asserts! (is-eq order-hash (get order-hash signature-pack)) ERR-ORDER-HASH-MISMATCH)
    (asserts! (is-eq src-chain-id (get chain-id validator)) ERR-INVALID-VALIDATOR)
    (asserts! (is-eq (secp256k1-recover? (sha256 (concat structured-data-prefix (concat (message-domain) order-hash))) (get signature signature-pack)) (ok (get pubkey validator))) ERR-INVALID-SIGNATURE)
    (as-contract (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-order-validated-by { order-hash: order-hash, validator: (get signer signature-pack) } true)))
    (ok { order-hash: order-hash, src-chain-id: src-chain-id })))

(define-private (validate-signature-iter (signature-pack { signer: principal, order-hash: (buff 32), signature: (buff 65)}) (previous-response (response { order-hash: (buff 32), src-chain-id: uint } uint)))
  (match previous-response prev-ok (validate-order (get order-hash prev-ok) (get src-chain-id prev-ok) signature-pack) prev-err previous-response))

(define-private (refund (amount uint) (from (buff 128)) (token-trait <ft-trait>) (the-chain-id uint))
  (let (
		  (pair-details { token: (contract-of token-trait), chain-id: the-chain-id })
		  (token-details (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-approved-pair-or-fail pair-details)))
		  (no-fee { approved: (get approved token-details), burnable: (get burnable token-details), min-amount: (get min-amount token-details), max-amount: (get max-amount token-details), fee: u0, min-fee: u0 }))
    (ok (and (> amount u0) (begin
		  (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair pair-details no-fee))
      (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-peg-out-endpoint-v2-01 transfer-to-unwrap token-trait amount the-chain-id from))	
      (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair pair-details (merge no-fee { fee: (get fee token-details), min-fee: (get min-fee token-details) })))
      true)))))

(define-private (update-peg-out-fee (pair-tuple { token: principal, chain-id: uint }) (the-peg-out-fee uint) (the-peg-out-gas-fee uint))
  (if (is-eq (get chain-id pair-tuple) u0)
    (begin
      (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-fee the-peg-out-fee))
      (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-min-fee the-peg-out-gas-fee))
      (ok true))
    (if (or (is-eq (get chain-id pair-tuple) u1001) (is-eq (get chain-id pair-tuple) u1002))
      (begin
				(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 set-peg-out-fee pair-tuple the-peg-out-fee))
				(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 set-peg-out-gas-fee pair-tuple the-peg-out-gas-fee))
        (ok true))
			(let (
				(pair-details (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-approved-pair-or-fail pair-tuple))))
				(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair pair-tuple { fee: the-peg-out-fee, min-fee: the-peg-out-gas-fee, approved: (get approved pair-details), burnable: (get burnable pair-details), max-amount: (get max-amount pair-details), min-amount: (get min-amount pair-details) }))
        (ok true)))))

(define-private (mul-down (a uint) (b uint))
  (/ (* a b) ONE_8))

(define-private (div-down (a uint) (b uint))
  (if (is-eq a u0) u0 (/ (* a ONE_8) b)))

(define-private (max (a uint) (b uint))
  (if (<= a b) b a))

```
