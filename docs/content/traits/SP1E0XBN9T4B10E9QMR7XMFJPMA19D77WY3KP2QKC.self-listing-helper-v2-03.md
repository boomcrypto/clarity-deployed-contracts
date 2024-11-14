---
title: "Trait self-listing-helper-v2-03"
draft: true
---
```
(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.extension-trait.extension-trait)
(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)
(use-trait ft-trait-standard 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant err-not-authorised (err u1000))
(define-constant err-token-mismatch (err u1001))
(define-constant err-token-not-approved (err u1002))
(define-constant err-insufficient-balance (err u1003))
(define-constant err-request-not-found (err u1004))
(define-constant err-request-not-approved (err u1005))
(define-constant err-request-already-processed (err u1006))
(define-constant err-pool-exists (err u1007))
(define-constant err-no-locked-liquidity (err u1100))
(define-constant err-end-burn-block (err u1101))

(define-constant ONE_8 u100000000)
(define-constant MAX_UINT u340282366920938463463374607431768211455)

(define-constant PENDING 0x00)
(define-constant APPROVED 0x01)
(define-constant REJECTED 0x02)
(define-constant FINALIZED 0x03)

(define-constant LOCK 0x01)
(define-constant BURN 0x02)

(define-map approved-token-x principal { approved: bool, min-x: uint })
(define-map approved-token-y principal bool)

(define-data-var request-nonce uint u0) 
(define-data-var fee-rebate uint u50000000)

(define-map requests uint {
    requested-by: principal, requested-at: uint,
    token-x: principal, token-y: principal, factor: uint,
    bal-x: uint, bal-y: uint,
    fee-rate-x: uint, fee-rate-y: uint,
    max-in-ratio: uint, max-out-ratio: uint,
    threshold-x: uint, threshold-y: uint,
    oracle-enabled: bool, oracle-average: uint,
    start-block: uint,
		bal-y-sent: bool,
    memo: (optional (buff 256)),
    status: (buff 1), status-memo: (optional (buff 256)),
		lock: (buff 1)
})

(define-data-var lock-period uint u26280) ;; c. 6 months
(define-map locked-liquidity { owner: principal, pool-id: uint } { amount: uint, end-burn-block: uint })
(define-map locked-liquidity-owners uint (list 200 principal))
(define-map burnt-liquidity uint uint)

;; read-only calls

(define-read-only (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao) (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao is-extension contract-caller)) err-not-authorised)))

(define-read-only (get-approved-token-x-or-default (token-x principal))
    (default-to { approved: false, min-x: MAX_UINT } (map-get? approved-token-x token-x)))

(define-read-only (get-approved-token-y-or-default (token-y principal))
	(default-to false (map-get? approved-token-y token-y)))

(define-read-only (get-request-or-fail (request-id uint))
    (ok (unwrap! (map-get? requests request-id) err-request-not-found)))

(define-read-only (get-fee-rebate)
	(var-get fee-rebate))

(define-read-only (get-request-nonce)
	(var-get request-nonce))

(define-read-only (get-lock-period)
	(var-get lock-period))

(define-read-only (get-locked-liquidity-or-default (owner principal) (pool-id uint))
	(default-to { amount: u0, end-burn-block: MAX_UINT } (map-get? locked-liquidity { owner: owner, pool-id: pool-id })))

(define-read-only (get-locked-liquidity-for-pool-or-default (pool-id uint))
  (let (
      (owners (default-to (list) (map-get? locked-liquidity-owners pool-id)))
      (initial-state { pool-id: pool-id, result: (list) }))
    (get result (fold accumulate-locked-liquidity owners initial-state))))

(define-read-only (get-burnt-liquidity-or-default (pool-id uint))
	(default-to u0 (map-get? burnt-liquidity pool-id)))

;; public calls

(define-public (request-create
    (request-details {
        token-x: principal, token-y: principal, factor: uint,
        bal-x: uint, bal-y: uint,
        fee-rate-x: uint, fee-rate-y: uint,
        max-in-ratio: uint, max-out-ratio: uint,
        threshold-x: uint, threshold-y: uint,
        oracle-enabled: bool, oracle-average: uint,
        start-block: uint,
        memo: (optional (buff 256)), 
				lock: (buff 1) }) (token-x-trait <ft-trait>))
    (let (
            (next-nonce (+ (var-get request-nonce) u1))
            (token-details (get-approved-token-x-or-default (get token-x request-details)))
            (updated-request-details (merge request-details { requested-by: tx-sender, requested-at: burn-block-height, status: PENDING, status-memo: none, bal-y-sent: false })))
        (asserts! (is-eq (get token-x request-details) (contract-of token-x-trait)) err-token-mismatch)
        (asserts! (get approved token-details) err-token-not-approved)
        (asserts! (>= (get bal-x request-details) (get min-x token-details)) err-insufficient-balance)
        (asserts! (and 
            (is-none (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-exists (get token-x request-details) (get token-y request-details) (get factor request-details)))
            (is-none (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-exists (get token-y request-details) (get token-x request-details) (get factor request-details))))
            err-pool-exists)
        (try! (contract-call? token-x-trait transfer-fixed (get bal-x request-details) tx-sender (as-contract tx-sender) none))				
        (map-set requests next-nonce updated-request-details)
        (var-set request-nonce next-nonce)
        (print { notification: "request-create", payload: updated-request-details })
        (ok next-nonce)))

(define-public (request-create-and-fund
    (request-details {
        token-x: principal, token-y: principal, factor: uint,
        bal-x: uint, bal-y: uint,
        fee-rate-x: uint, fee-rate-y: uint,
        max-in-ratio: uint, max-out-ratio: uint,
        threshold-x: uint, threshold-y: uint,
        oracle-enabled: bool, oracle-average: uint,
        start-block: uint,
        memo: (optional (buff 256)),
				lock: (buff 1) }) (token-x-trait <ft-trait>) (token-y-trait <ft-trait-standard>))
	(let (
			(request-id (try! (request-create request-details token-x-trait))))
		(asserts! (is-eq (get token-y request-details) (contract-of token-y-trait)) err-token-mismatch)
		(try! (contract-call? token-y-trait transfer (/ (* (get bal-y request-details) (pow u10 (unwrap-panic (contract-call? token-y-trait get-decimals)))) ONE_8) tx-sender (as-contract tx-sender) none))
		(map-set requests request-id (merge (try! (get-request-or-fail request-id)) { bal-y-sent: true }))
		(ok request-id)))		

(define-public (request-create-and-finalize
    (request-details {
        token-x: principal, token-y: principal, factor: uint,
        bal-x: uint, bal-y: uint,
        fee-rate-x: uint, fee-rate-y: uint,
        max-in-ratio: uint, max-out-ratio: uint,
        threshold-x: uint, threshold-y: uint,
        oracle-enabled: bool, oracle-average: uint,
        start-block: uint,
        memo: (optional (buff 256)),
				lock: (buff 1) }) (token-x-trait <ft-trait>) (token-y-trait <ft-trait>))
	(let (
			(request-id (try! (request-create-and-fund request-details token-x-trait token-y-trait))))
		(asserts! (get-approved-token-y-or-default (contract-of token-y-trait)) err-token-not-approved)		
		(as-contract (approve-and-finalize-request request-id token-x-trait token-y-trait none))))

(define-public (finalize-request (request-id uint) (token-x-trait <ft-trait>) (token-y-trait <ft-trait>))
    (let (
						(sender tx-sender)
            (request-details (try! (get-request-or-fail request-id)))
            (updated-request-details (merge request-details { status: FINALIZED }))
						(check-authorised (asserts! (or (is-eq tx-sender (get requested-by request-details)) (try! (is-dao-or-extension))) err-not-authorised))
						(check-status (asserts! (is-eq (get status request-details) APPROVED) err-request-not-approved))
						(check-x (asserts! (is-eq (get token-x request-details) (contract-of token-x-trait)) err-token-mismatch))
						(check-y (asserts! (is-eq (get token-y request-details) (contract-of token-y-trait)) err-token-mismatch))
						(transfer-x (and (not (is-eq sender (as-contract tx-sender))) (as-contract (try! (contract-call? token-x-trait transfer-fixed (get bal-x request-details) tx-sender sender none)))))
						(transfer-y (and (not (is-eq sender (as-contract tx-sender))) (get bal-y-sent request-details) (as-contract (try! (contract-call? token-y-trait transfer-fixed (get bal-y request-details) tx-sender sender none)))))
						(supply (get supply (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 create-pool token-x-trait token-y-trait (get factor request-details) (get requested-by request-details) (get bal-x request-details) (get bal-y request-details)))))
						(pool-id (get pool-id (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details (contract-of token-x-trait) (contract-of token-y-trait) (get factor request-details))))))
				(and (is-eq (get lock request-details) LOCK) (try! (lock-liquidity supply pool-id)))
				(and (is-eq (get lock request-details) BURN) (try! (burn-liquidity supply pool-id)))
        (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 set-fee-rate-x (get token-x request-details) (get token-y request-details) (get factor request-details) (get fee-rate-x request-details)))
        (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 set-fee-rate-y (get token-x request-details) (get token-y request-details) (get factor request-details) (get fee-rate-y request-details)))
        (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 set-max-in-ratio (get token-x request-details) (get token-y request-details) (get factor request-details) (get max-in-ratio request-details)))
        (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 set-max-out-ratio (get token-x request-details) (get token-y request-details) (get factor request-details) (get max-out-ratio request-details)))
        (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 set-threshold-x (get token-x request-details) (get token-y request-details) (get factor request-details) (get threshold-x request-details)))
        (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 set-threshold-y (get token-x request-details) (get token-y request-details) (get factor request-details) (get threshold-y request-details)))
        (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 set-oracle-enabled (get token-x request-details) (get token-y request-details) (get factor request-details) (get oracle-enabled request-details)))
        (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 set-oracle-average (get token-x request-details) (get token-y request-details) (get factor request-details) (get oracle-average request-details)))
        (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 set-start-block (get token-x request-details) (get token-y request-details) (get factor request-details) (get start-block request-details)))
				(as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-fee-rebate (get token-x request-details) (get token-y request-details) (get factor request-details) (var-get fee-rebate))))
        (map-set requests request-id updated-request-details)
        (print { notification: "finalize-request", payload: updated-request-details })
        (ok true)))

(define-public (lock-liquidity (amount uint) (pool-id uint))
	(begin
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 transfer-fixed pool-id amount tx-sender (as-contract tx-sender)))
		(map-set locked-liquidity { owner: tx-sender, pool-id: pool-id } { amount: (+ (get amount (get-locked-liquidity-or-default tx-sender pool-id)) amount), end-burn-block: (+ burn-block-height (get-lock-period)) })
		(add-owner-to-locked-liquidity pool-id tx-sender)
		(print { notification: "lock-liquidity", payload: { sender: tx-sender, amount: amount, pool-id: pool-id, end-burn-block: (+ burn-block-height (get-lock-period)) }})
		(ok true)))

(define-public (burn-liquidity (amount uint) (pool-id uint))
 (let (
		(sender tx-sender)
		(current-burnt-amount (default-to u0 (map-get? burnt-liquidity pool-id))))
 	(as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 burn-fixed pool-id amount sender)))
  (map-set burnt-liquidity pool-id (+ current-burnt-amount amount))
	(print { notification: "burn-liquidity", payload: { sender: sender, amount: amount, pool-id: pool-id, total-burnt: (+ current-burnt-amount amount) }})
	(ok true)))

(define-public (claim-liquidity (pool-id uint))
	(let (
			(sender tx-sender)
			(liquidity-details (get-locked-liquidity-or-default sender pool-id)))
		(asserts! (> (get amount liquidity-details) u0) err-no-locked-liquidity)
		(asserts! (> burn-block-height (get end-burn-block liquidity-details)) err-end-burn-block)
		(as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 transfer-fixed pool-id (get amount liquidity-details) tx-sender sender)))
		(map-delete locked-liquidity { owner: sender, pool-id: pool-id })
		(print { notification: "claim-liquidity", payload: liquidity-details, sender: sender, pool-id: pool-id })
		(ok true)))

 ;; priviliged calls

(define-public (reject-request (request-id uint) (token-x-trait <ft-trait>) (memo (optional (buff 256))))
    (let (
            (request-details (try! (get-request-or-fail request-id)))
            (updated-request-details (merge request-details { status: REJECTED, status-memo: memo })))
        (asserts! (or (is-ok (is-dao-or-extension)) (is-eq tx-sender (get requested-by request-details))) err-not-authorised) ;; either requestor or approved operator can reject
        (asserts! (or (is-eq (get status request-details) PENDING) (is-eq (get status request-details) APPROVED)) err-request-already-processed)
        (asserts! (is-eq (get token-x request-details) (contract-of token-x-trait)) err-token-mismatch)
        (as-contract (try! (contract-call? token-x-trait transfer-fixed (get bal-x request-details) tx-sender (get requested-by request-details) none)))
        (map-set requests request-id updated-request-details)
        (print { notification: "reject-request", payload: updated-request-details })
        (ok true)))

;; governance calls

(define-public (approve-and-finalize-request (request-id uint) (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (memo (optional (buff 256))))
	(begin 
		(try! (approve-request request-id (contract-of token-y-trait) memo))
		(finalize-request request-id token-x-trait token-y-trait)))

(define-public (approve-request (request-id uint) (wrapped-token-y principal) (memo (optional (buff 256))))
    (let (
            (request-details (try! (get-request-or-fail request-id)))
            (updated-request-details (merge request-details { token-y: wrapped-token-y, status: APPROVED, status-memo: memo })))
        (try! (is-dao-or-extension))
        (asserts! (is-eq (get status request-details) PENDING) err-request-already-processed)
				(as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-vault-v2-01 set-approved-token wrapped-token-y true)))
        (map-set requests request-id updated-request-details)
        (print { notification: "approve-request", payload: updated-request-details })
        (ok true)))

(define-public (approve-token-y (token-y principal) (approved bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set approved-token-y token-y approved))))

(define-public (approve-token-x (token principal) (approved bool) (min-x uint))
    (begin
        (try! (is-dao-or-extension))
        (ok (map-set approved-token-x token { approved: approved, min-x: min-x }))))

(define-public (set-fee-rebate (new-fee-rebate uint))
	(begin 
		(try! (is-dao-or-extension))
		(ok (var-set fee-rebate new-fee-rebate))))

(define-public (set-lock-period (new-lock-period uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set lock-period new-lock-period))))

(define-public (callback (sender principal) (payload (buff 2048)))
	(ok true))

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao set-extensions (list 
			{ extension: .self-listing-helper-v2-03, enabled: true })))
		(try! (approve-token-x 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc true u10000000))
		(try! (approve-token-x 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex true u1000000000000))
		(try! (approve-token-x 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 true u180000000000))		
		(ok true)))

(define-public (set-burnt-liquidity (updates (list 200 { pool-id: uint, burnt-liquidity: uint })))
  (begin
    (try! (is-dao-or-extension))
    (ok (fold update-burnt-liquidity updates true))))

;; private calls

(define-private (update-burnt-liquidity (entry { pool-id: uint, burnt-liquidity: uint }) (previous-result bool))
  (begin
      (map-set burnt-liquidity (get pool-id entry) (get burnt-liquidity entry))
      (print { notification: "manual-set-burn-liquidity", payload: { amount: (get burnt-liquidity entry), pool-id: (get pool-id entry) }})
      true))

(define-private (add-owner-to-locked-liquidity (pool-id uint) (owner principal))
	(let (
			(current-owners (default-to (list) (map-get? locked-liquidity-owners pool-id))))
		(and (is-none (index-of current-owners owner)) (map-set locked-liquidity-owners pool-id (unwrap-panic (as-max-len? (append current-owners owner) u200))))))

(define-private (accumulate-locked-liquidity (owner principal) (state { pool-id: uint, result: (list 200 { owner: principal, amount: uint, end-burn-block: uint }) }))
  (let (
      (locked-info (get-locked-liquidity-or-default owner (get pool-id state)))
      (amount (get amount locked-info))
      (end-burn-block (get end-burn-block locked-info))
      (new-entry { owner: owner, amount: amount, end-burn-block: end-burn-block }))
    { pool-id: (get pool-id state), result: (unwrap-panic (as-max-len? (append (get result state) new-entry) u200)) }))


```
