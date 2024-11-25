;; SPDX-License-Identifier: BUSL-1.1

(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant err-unauthorised (err u1000))
(define-constant err-paused (err u1001))
(define-constant err-peg-in-address-not-found (err u1002))
(define-constant err-invalid-amount (err u1003))
(define-constant err-token-mismatch (err u1004))
(define-constant err-invalid-tx (err u1005))
(define-constant err-already-sent (err u1006))
(define-constant err-address-mismatch (err u1007))
(define-constant err-request-already-revoked (err u1008))
(define-constant err-request-already-finalized (err u1009))
(define-constant err-revoke-grace-period (err u1010))
(define-constant err-request-already-claimed (err u1011))
(define-constant err-invalid-input (err u1012))
(define-constant err-tx-mined-before-request (err u1013))
(define-constant err-commit-tx-mismatch (err u1014))
(define-constant err-invalid-burn-height (err u1003))
(define-constant err-tx-mined-before-start (err u1015))

(define-constant MAX_UINT u340282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-constant burn-height-start burn-block-height)

(define-data-var paused bool true)
(define-data-var fee-to-address principal tx-sender)

;; read-only functions

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao) (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao is-extension contract-caller)) err-unauthorised)))

(define-read-only (is-paused)
	(var-get paused))

(define-read-only (get-fee-to-address)
  (var-get fee-to-address))

(define-read-only (get-pair-details (pair { token: principal, chain-id: uint }))
  (match (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 get-pair-details-or-fail pair)
    ok-value (some ok-value)
    err-value none))

(define-read-only (get-pair-details-many (pairs (list 200 { token: principal, chain-id: uint })))
  (map get-pair-details pairs))

(define-read-only (get-request (request-id uint))
  (match (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 get-request-or-fail request-id)
    ok-value (some ok-value)
    err-value none))

(define-read-only (get-request-many (request-ids (list 200 uint)))
  (map get-request request-ids))

(define-read-only (get-request-revoke-grace-period)
  (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 get-request-revoke-grace-period))

(define-read-only (get-request-claim-grace-period)
  (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 get-request-claim-grace-period))

(define-read-only (is-peg-in-address-approved (address (buff 128)))
  (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 is-peg-in-address-approved address))

(define-read-only (get-pair-details-or-fail (pair { token: principal, chain-id: uint }))
  (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 get-pair-details-or-fail pair))

(define-read-only (get-tick-to-pair-or-fail (tick (string-utf8 256)))
	(contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 get-tick-to-pair-or-fail tick))

(define-read-only (get-peg-in-sent-or-default (bitcoin-tx (buff 32768)) (output uint) (offset uint))
  (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 get-peg-in-sent-or-default bitcoin-tx output offset))

(define-read-only (get-request-or-fail (request-id uint))
  (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 get-request-or-fail request-id))

(define-read-only (validate-peg-out (amount uint) (pair { token: principal, chain-id: uint }))
  (let (
      (token-details (try! (get-pair-details-or-fail pair)))
      (fee (mul-down amount (get peg-out-fee token-details))))
		(asserts! (> amount fee) err-invalid-amount)
    (asserts! (not (get peg-out-paused token-details)) err-paused)    
    (ok { token-details: token-details, fee: fee })))

(define-read-only (is-fulfill-address-approved (address (buff 128)))
  (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 is-fulfill-address-approved address))

;; governance functions

(define-public (pause (new-paused bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set paused new-paused))))

(define-public (set-fee-to-address (new-fee-to-address principal))
  (begin
    (try! (is-dao-or-extension))
    (ok (var-set fee-to-address new-fee-to-address))))

(define-public (transfer-all-to (new-owner principal) (token-trait <ft-trait>))
  (begin 
    (try! (is-dao-or-extension))
    (as-contract (contract-call? token-trait transfer-fixed (unwrap-panic (contract-call? token-trait get-balance-fixed tx-sender)) tx-sender new-owner none))))

(define-public (transfer-all-to-many (new-owner principal) (token-traits (list 10 <ft-trait>)))
  (ok (map transfer-all-to (list new-owner new-owner new-owner new-owner new-owner new-owner new-owner new-owner new-owner new-owner) token-traits)))

;; public functions

;; request peg-out of `tick` of `amount` (net of fee) to `peg-out-address`
;; request escrows the relevant pegged-in token and gas-fee token to the contract until the request is either finalized or revoked.
;;
;; token-trait => the trait of pegged-in token
(define-public (request-peg-out (amount uint) (peg-out-address (buff 128)) (token-trait <ft-trait>) (the-chain-id uint))
  (let (
      (token (contract-of token-trait))
			(validation-data (try! (validate-peg-out amount { token: token, chain-id: the-chain-id })))
      (token-details (get token-details validation-data))
      (fee (get fee validation-data))
      (amount-net (- amount fee))
      (gas-fee (get peg-out-gas-fee token-details))
      (request-details { requested-by: tx-sender, peg-out-address: peg-out-address, tick: (get tick token-details), token: token, amount-net: amount-net, fee: fee, gas-fee: gas-fee, claimed: u0, claimed-by: tx-sender, fulfilled-by: 0x, revoked: false, finalized: false, requested-at: tenure-height, requested-at-burn-height: burn-block-height })
      (request-id (as-contract (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-request u0 request-details)))))
    (try! (contract-call? token-trait transfer-fixed amount tx-sender (as-contract tx-sender) none))
    (and (> gas-fee u0) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc transfer-fixed gas-fee tx-sender (as-contract tx-sender) none)))
    (print (merge request-details { type: "request-peg-out", request-id: request-id }))
    (ok true)))

;; claim peg-out request, so that the claimer can safely process the peg-out (within the grace period)
;;
(define-public (claim-peg-out (request-id uint) (fulfilled-by (buff 128)))
  (let (
      (claimer tx-sender)
      (request-details (try! (get-request-or-fail request-id)))
      (token-details (try! (get-pair-details-or-fail (try! (get-tick-to-pair-or-fail (get tick request-details)))))))
    (asserts! (not (get peg-out-paused token-details)) err-paused)
    (asserts! (< (get claimed request-details) tenure-height) err-request-already-claimed)
    (asserts! (not (get revoked request-details)) err-request-already-revoked)
    (asserts! (not (get finalized request-details)) err-request-already-finalized)

    (as-contract (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-request request-id (merge request-details { claimed: (+ tenure-height (get-request-claim-grace-period)), claimed-by: claimer, fulfilled-by: fulfilled-by }))))

    (print (merge request-details { type: "claim-peg-out", request-id: request-id, claimed: (+ tenure-height (get-request-claim-grace-period)), claimed-by: claimer, fulfilled-by: fulfilled-by }))
    (ok true)
  )
)

;; finalize peg-out request
;; finalize `request-id` with `tx`
;; pays the fee to `fee-to-address` and burn the relevant pegged-in tokens.
;;
;; peg-out finalization can be done by either a peg-in address or a non-peg-in (i.e. 3rd party) address
;; if the latter, then the overall peg-in balance does not change.
;; the claimer sends non-pegged-in BRC20 tokens to the peg-out requester and receives the pegged-in BRC20 tokens (along with gas-fee)
;; if the former, then the overall peg-in balance decreases.
;; the relevant BRC20 tokens are burnt (with fees paid to `fee-to-address`)
(define-public (finalize-peg-out-on-index (request-id uint)
  (tx { bitcoin-tx: (buff 32768), output: uint, offset: uint, tick: (string-utf8 256), amt: uint, from: (buff 128), to: (buff 128), from-bal: uint, to-bal: uint, decimals: uint })
  (block { header: (buff 80), height: uint })
  (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
  (signature-packs (list 10 { signer: principal, tx-hash: (buff 32), signature: (buff 65) }))
  (token-trait <ft-trait>))
  (begin 
    (try! (index-tx tx block proof signature-packs))
    (finalize-peg-out request-id (get bitcoin-tx tx) (get output tx) (get offset tx) token-trait)))

(define-public (finalize-peg-out (request-id uint) (tx (buff 32768)) (output-idx uint) (offset-idx uint) (token-trait <ft-trait>))
  (let (
      (token (contract-of token-trait))
      (request-details (try! (get-request-or-fail request-id)))
      (pair-details (try! (get-tick-to-pair-or-fail (get tick request-details))))
      (token-details (try! (get-pair-details-or-fail pair-details)))
      (tx-idxed (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 get-bitcoin-tx-indexed-or-fail tx output-idx offset-idx)))
      (tx-mined-height (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 get-bitcoin-tx-mined-or-fail tx)))
      (amount-in-decimals (get amt tx-idxed))
      (fulfilled-by (get from tx-idxed))
      (is-fulfilled-by-peg-in (or (is-peg-in-address-approved fulfilled-by) (is-fulfill-address-approved fulfilled-by))))
    (asserts! (not (get peg-out-paused token-details)) err-paused)
		(asserts! (< burn-height-start tx-mined-height) err-tx-mined-before-start)
    (asserts! (is-eq token (get token pair-details)) err-token-mismatch)
    (asserts! (is-eq (get tick request-details) (get tick tx-idxed)) err-token-mismatch)
    (asserts! (is-eq amount-in-decimals (fixed-to-decimals (get amount-net request-details) (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 get-tick-decimals-or-default (get tick tx-idxed)))) err-invalid-amount)
    (asserts! (is-eq (get peg-out-address request-details) (get to tx-idxed)) err-address-mismatch)
    (asserts! (is-eq (get fulfilled-by request-details) fulfilled-by) err-address-mismatch)
    (asserts! (< (get requested-at-burn-height request-details) tx-mined-height) err-tx-mined-before-request)
    (asserts! (not (get-peg-in-sent-or-default tx output-idx offset-idx)) err-already-sent)
    (asserts! (not (get revoked request-details)) err-request-already-revoked)
    (asserts! (not (get finalized request-details)) err-request-already-finalized)

    (as-contract (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-peg-in-sent { tx: tx, output: output-idx, offset: offset-idx } true)))
    (as-contract (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-request request-id (merge request-details { finalized: true }))))

    (and (> (get fee request-details) u0) (as-contract (try! (contract-call? token-trait transfer-fixed (get fee request-details) tx-sender (var-get fee-to-address) none))))
    (and (> (get gas-fee request-details) u0) (as-contract (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc transfer-fixed (get gas-fee request-details) tx-sender (if is-fulfilled-by-peg-in (var-get fee-to-address) (get claimed-by request-details)) none))))

    (if is-fulfilled-by-peg-in
      (and (not (get no-burn token-details)) (as-contract (try! (contract-call? token-trait burn-fixed (get amount-net request-details) tx-sender))))
      (as-contract (try! (contract-call? token-trait transfer-fixed (get amount-net request-details) tx-sender (get claimed-by request-details) none)))
    )

    (print { type: "finalize-peg-out", request-id: request-id, tx: tx })
    (ok true)))

;; revoke peg-out request
;; only after `request-revoke-grace-period` passed
;; returns fee and pegged-in tokens to the requester.
(define-public (revoke-peg-out (request-id uint) (token-trait <ft-trait>))
  (let (
      (token (contract-of token-trait))
      (request-details (try! (get-request-or-fail request-id)))
      (pair-details (try! (get-tick-to-pair-or-fail (get tick request-details))))
      (token-details (try! (get-pair-details-or-fail pair-details))))      
    (asserts! (> tenure-height (+ (get requested-at request-details) (get-request-revoke-grace-period))) err-revoke-grace-period)
    (asserts! (is-eq token (get token pair-details)) err-token-mismatch)
    (asserts! (< (get claimed request-details) tenure-height) err-request-already-claimed)
    (asserts! (not (get revoked request-details)) err-request-already-revoked)
    (asserts! (not (get finalized request-details)) err-request-already-finalized)

    (as-contract (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-request request-id (merge request-details { revoked: true }))))

    (and (> (get fee request-details) u0) (as-contract (try! (contract-call? token-trait transfer-fixed (get fee request-details) tx-sender (get requested-by request-details) none))))
    (and (> (get gas-fee request-details) u0) (as-contract (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc transfer-fixed (get gas-fee request-details) tx-sender (get requested-by request-details) none))))
    (as-contract (try! (contract-call? token-trait transfer-fixed (get amount-net request-details) tx-sender (get requested-by request-details) none)))

    (print { type: "revoke-peg-out", request-id: request-id })
    (ok true)))

;; internal functions

(define-private (index-tx
  (tx { bitcoin-tx: (buff 32768), output: uint, offset: uint, tick: (string-utf8 256), amt: uint, from: (buff 128), to: (buff 128), from-bal: uint, to-bal: uint, decimals: uint })
  (block { header: (buff 80), height: uint })
  (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
  (signature-packs (list 10 { signer: principal, tx-hash: (buff 32), signature: (buff 65) })))
  (begin 
    (and 
      (not (is-ok (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 get-bitcoin-tx-indexed-or-fail (get bitcoin-tx tx) (get output tx) (get offset tx))))
      (as-contract (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 index-tx-many (list { tx: tx, block: block, proof: proof, signature-packs: signature-packs })))))
    (print { type: "indexed-tx", tx: tx, block: block, proof: proof, signature-packs: signature-packs })
    (ok true)))

(define-private (min (a uint) (b uint))
  (if (< a b) a b))

(define-private (mul-down (a uint) (b uint))
  (/ (* a b) ONE_8))

(define-private (div-down (a uint) (b uint))
  (if (is-eq a u0) u0 (/ (* a ONE_8) b)))

(define-private (decimals-to-fixed (amount uint) (decimals uint))
  (/ (* amount ONE_8) (pow u10 decimals)))

(define-private (fixed-to-decimals (amount uint) (decimals uint))
  (/ (* amount (pow u10 decimals)) ONE_8))