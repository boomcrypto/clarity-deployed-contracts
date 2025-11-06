;; SPDX-License-Identifier: BUSL-1.1
;; treasury-grant-v4 - Contract for managing treasury grants and token distributions

(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

;; Error codes for various failure scenarios
(define-constant ERR-NOT-AUTHORIZED (err u1000)) ;; When caller is not authorized
(define-constant ERR-TOKEN-MISMATCH (err u1001)) ;; When provided tokens don't match pool tokens
(define-constant ERR-ALREADY-CLAIMED (err u1002)) ;; When balance has already been claimed
(define-constant ERR-UPDATE-PRINCIPAL-MAP-FAILED (err u1003)) ;; When failed to update claim status
(define-constant ERR-INVALID-POOL-ID (err u1004)) ;; When provided pool ID is invalid

;; Constants for decimal handling and maximum values
(define-constant ONE_8 u100000000) ;; 1.0 with 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455) ;; Maximum uint value

;; Snapshot block for balance calculations
;; __IF_MAINNET__				
(define-data-var snapshot-block uint u1509640)
;; (define-data-var snapshot-block uint u26356)
;; __ENDIF__

;; Exchange rates for different tokens (with 8 decimal places)
(define-data-var btc-rate uint u10273463917525) ;; 102,734.64 
(define-data-var stx-rate uint u67721865) ;; 0.67721865
(define-data-var usd-rate uint u100000000) ;; 1.00

;; Percentage of tokens to be lost/held (with 8 decimal places)
(define-data-var btc-pct uint u25000000) ;; 25%
(define-data-var stx-pct uint u100000000) ;; 100%
(define-data-var usd-pct uint u9000000) ;; 9%

;; Map to track which addresses have claimed their balances for specific pools
(define-map claimed { address: principal, pool-id: uint } bool)
(define-map claimed-expired { address: principal, pool-id: uint, cycle: uint } bool)
(define-map claimed-locked { address: principal, pool-id: uint } bool)

;; Check if caller is DAO or extension
(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao) (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao is-extension contract-caller)) ERR-NOT-AUTHORIZED)))

;; Getter functions for data variables
(define-read-only (get-snapshot-block)
	(var-get snapshot-block))

(define-read-only (get-btc-rate)
	(var-get btc-rate))

(define-read-only (get-stx-rate)
	(var-get stx-rate))

(define-read-only (get-usd-rate)
	(var-get usd-rate))

(define-read-only (get-btc-pct)
	(var-get btc-pct))

(define-read-only (get-stx-pct)
	(var-get stx-pct))

(define-read-only (get-usd-pct)
	(var-get usd-pct))

;; Setter functions for data variables (only callable by DAO or extension)
(define-public (set-snapshot-block (new-block uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set snapshot-block new-block))))

(define-public (set-btc-rate (new-rate uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set btc-rate new-rate))))

(define-public (set-stx-rate (new-rate uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set stx-rate new-rate))))

(define-public (set-usd-rate (new-rate uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set usd-rate new-rate))))

(define-public (set-btc-pct (new-pct uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set btc-pct new-pct))))

(define-public (set-stx-pct (new-pct uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set stx-pct new-pct))))

(define-public (set-usd-pct (new-pct uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set usd-pct new-pct))))

;; Get the balance of a specific pool for an address at the snapshot block
(define-read-only (get-pool-balance (pool-id uint) (address principal))
	(let (
			(snapshot-block-id (unwrap-panic (get-stacks-block-info? id-header-hash (var-get snapshot-block))))
			(snapshot-data (at-block snapshot-block-id
				(let (
						(pool-tokens (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details-by-id pool-id)))
						(pool-details (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details (get token-x pool-tokens) (get token-y pool-tokens) (get factor pool-tokens))))
						(total-supply (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 get-total-supply-fixed pool-id)))
						(user-farm-details (match (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming get-user-id 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 pool-id address)
							some-value (let ((reward-cycle (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming get-reward-cycle 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 pool-id tenure-height))))
								(contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming get-staker-at-cycle-or-default 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 pool-id reward-cycle some-value))
							{ amount-staked: u0, to-return: u0 }))
						(user-lp-balance (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 get-balance-fixed pool-id address)))
						(user-surge-balance-1 (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-01 get-campaign-staker-or-default u1 pool-id address))
						(user-surge-balance-2 (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-02 get-campaign-staker-or-default u2 pool-id address))
						(user-surge-balance-3 (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-03 get-campaign-staker-or-default u3 pool-id address))
						(user-surge-balance-4 (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-03 get-campaign-staker-or-default u4 pool-id address))
						(total-lp-balance (+ user-lp-balance (get amount-staked user-farm-details) (get to-return user-farm-details) (if (get claimed user-surge-balance-1) u0 (get amount user-surge-balance-1)) (if (get claimed user-surge-balance-2) u0 (get amount user-surge-balance-2)) (if (get claimed user-surge-balance-3) u0 (get amount user-surge-balance-3)) (if (get claimed user-surge-balance-4) u0 (get amount user-surge-balance-4)))))
					{ total-lp-balance: total-lp-balance, total-supply: total-supply, balance-x: (get balance-x pool-details), balance-y: (get balance-y pool-details), token-x: (get token-x pool-tokens), token-y: (get token-y pool-tokens) })))
		  (distribution-data (calculate-distribution pool-id (get total-lp-balance snapshot-data) (get total-supply snapshot-data) (get balance-x snapshot-data) (get balance-y snapshot-data) (get token-x snapshot-data) (get token-y snapshot-data))))
		distribution-data))

;; Helper function to iterate through pool balances
(define-private (get-pool-balance-iter (pool-id uint) (prior { address: principal, balances: (list 200 { pool-id: uint, total-lp-balance: uint, token-x-bal: uint, token-y-bal: uint, native-x-bal: uint, native-y-bal: uint, usdc-x-bal: uint, usdc-y-bal: uint, usdc-total-bal: uint }) }))
	(let (
			(pool-balance (get-pool-balance pool-id (get address prior)))
			(updated-balances (unwrap-panic (as-max-len? (append (get balances prior) pool-balance) u200))))
		{ address: (get address prior), balances: updated-balances }))

;; Get balances for multiple pools for an address
(define-read-only (get-pool-balance-many (address principal) (pool-ids (list 200 uint)))
	(fold get-pool-balance-iter pool-ids { address: address, balances: (list) }))

(define-read-only (get-locked-balance (pool-id uint) (address principal))
	(let (
			(snapshot-block-id (unwrap-panic (get-stacks-block-info? id-header-hash (var-get snapshot-block))))
			(snapshot-data (at-block snapshot-block-id
				(let (
						(pool-tokens (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details-by-id pool-id)))
						(pool-details (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details (get token-x pool-tokens) (get token-y pool-tokens) (get factor pool-tokens))))
						(total-supply (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 get-total-supply-fixed pool-id)))					
						(locked-balance (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.liquidity-locker get-locked-liquidity-or-default address pool-id)))
					{ total-lp-balance: (get amount locked-balance), total-supply: total-supply, balance-x: (get balance-x pool-details), balance-y: (get balance-y pool-details), token-x: (get token-x pool-tokens), token-y: (get token-y pool-tokens) })))
		  (distribution-data (merge { memo: "locked" } (calculate-distribution pool-id (get total-lp-balance snapshot-data) (get total-supply snapshot-data) (get balance-x snapshot-data) (get balance-y snapshot-data) (get token-x snapshot-data) (get token-y snapshot-data)))))
		distribution-data))		

(define-read-only (get-expired-balance (pool-id uint) (address principal) (target-cycle uint))
	(let (
			(snapshot-block-id (unwrap-panic (get-stacks-block-info? id-header-hash (var-get snapshot-block))))
			(snapshot-data (at-block snapshot-block-id
				(let (
						(pool-tokens (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details-by-id pool-id)))
						(pool-details (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details (get token-x pool-tokens) (get token-y pool-tokens) (get factor pool-tokens))))
						(total-supply (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 get-total-supply-fixed pool-id)))
						(snapshot-cycle (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming get-reward-cycle 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 pool-id tenure-height)))
						(user-farm-details 
							(match (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming get-user-id 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 pool-id address)
								some-value
								(if (< target-cycle snapshot-cycle)
									(contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming get-staker-at-cycle-or-default 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 pool-id target-cycle some-value)
									{ amount-staked: u0, to-return: u0 })
								{ amount-staked: u0, to-return: u0 })))
					{ total-lp-balance: (get to-return user-farm-details), total-supply: total-supply, balance-x: (get balance-x pool-details), balance-y: (get balance-y pool-details), token-x: (get token-x pool-tokens), token-y: (get token-y pool-tokens) })))
		  (distribution-data (merge { cycle: target-cycle } (calculate-distribution pool-id (get total-lp-balance snapshot-data) (get total-supply snapshot-data) (get balance-x snapshot-data) (get balance-y snapshot-data) (get token-x snapshot-data) (get token-y snapshot-data)))))
		distribution-data))			

(define-private (get-expired-balance-iter (pool-cycle { pool-id: uint, cycle: uint }) (prior { address: principal, balances: (list 200 { pool-id: uint, cycle: uint, total-lp-balance: uint, token-x-bal: uint, token-y-bal: uint, native-x-bal: uint, native-y-bal: uint, usdc-x-bal: uint, usdc-y-bal: uint, usdc-total-bal: uint }) }))
	(let (
			(expired-balance (get-expired-balance (get pool-id pool-cycle) (get address prior) (get cycle pool-cycle)))
			(updated-balances (unwrap-panic (as-max-len? (append (get balances prior) expired-balance) u200))))
		{ address: (get address prior), balances: updated-balances }))

;; Get balances for multiple pools for an address
(define-read-only (get-expired-balance-many (address principal) (pool-cycles (list 200 { pool-id: uint, cycle: uint })))
	(fold get-expired-balance-iter pool-cycles { address: address, balances: (list) }))

;; Check if a balance has been claimed
(define-read-only (get-claimed-or-default (address principal) (pool-id uint))
	(or
		(contract-call? .treasury-grant-v4-1 get-claimed-or-default address pool-id)
		(contract-call? .treasury-grant-v4-2 get-claimed-or-default address pool-id)
		(contract-call? .treasury-grant-v4-3 get-claimed-or-default address pool-id)
	(default-to false (map-get? claimed { address: address, pool-id: pool-id }))))

(define-read-only (get-claimed-locked-or-default (address principal) (pool-id uint))
	(default-to false (map-get? claimed-locked { address: address, pool-id: pool-id })))

(define-read-only (get-claimed-expired-or-default (address principal) (pool-id uint) (cycle uint))
	(default-to false (map-get? claimed-expired { address: address, pool-id: pool-id, cycle: cycle })))

(define-public (claim-balance (details { dest: (buff 256), pool-id: uint, token-x-trait: <ft-trait>, token-y-trait: <ft-trait> }))
	(let (
			(pool-id (get pool-id details))
			(pool-tokens (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details-by-id pool-id)))
			(pool-balance (get-pool-balance pool-id tx-sender))
			(locked-balance (get-locked-balance pool-id tx-sender))
			(token-x-trait (get token-x-trait details))
			(token-y-trait (get token-y-trait details))
			(check-token-x (asserts! (is-eq (get token-x pool-tokens) (contract-of token-x-trait)) ERR-TOKEN-MISMATCH))		
			(check-token-y (asserts! (is-eq (get token-y pool-tokens) (contract-of token-y-trait)) ERR-TOKEN-MISMATCH))
			(check-pool-id (asserts! (not (is-eq pool-id u170)) ERR-INVALID-POOL-ID))
			(claimed-pool-balance (if (get-claimed-or-default tx-sender pool-id) 
				false 
				(begin
					(try! (send-native-balances (get native-x-bal pool-balance) (get native-y-bal pool-balance) token-x-trait token-y-trait))
					(asserts! (map-set claimed { address: tx-sender, pool-id: pool-id } true) ERR-UPDATE-PRINCIPAL-MAP-FAILED)
					(print (merge pool-balance { address: tx-sender, dest: (get dest details), claimed: true }))
					true)))
			(claimed-locked-balance (if (get-claimed-locked-or-default tx-sender pool-id) 
				false 
				(begin
					(try! (send-native-balances (get native-x-bal locked-balance) (get native-y-bal locked-balance) token-x-trait token-y-trait))
					(asserts! (map-set claimed-locked { address: tx-sender, pool-id: pool-id } true) ERR-UPDATE-PRINCIPAL-MAP-FAILED)
					(print (merge locked-balance { address: tx-sender, dest: (get dest details), claimed: true }))
					true))))
		(ok { pool-id: pool-id, claim-pool-balance: claimed-pool-balance, claim-locked-balance: claimed-locked-balance })))

(define-private (claim-balance-iter (details { dest: (buff 256), pool-id: uint, token-x-trait: <ft-trait>, token-y-trait: <ft-trait> }) (prior (response (list 200 { pool-id: uint, claim-pool-balance: bool, claim-locked-balance: bool }) uint)))
	(match prior 
		ok-value 
		(ok (unwrap-panic (as-max-len? (append ok-value (try! (claim-balance details))) u200)))
		err-value prior))

(define-public (claim-balance-many (details (list 200 { dest: (buff 256), pool-id: uint, token-x-trait: <ft-trait>, token-y-trait: <ft-trait> })))
	(fold claim-balance-iter details (ok (list))))

(define-public (claim-expired-balance (details { dest: (buff 256), pool-id: uint, cycle: uint, token-x-trait: <ft-trait>, token-y-trait: <ft-trait> }))
	(let (
			(pool-id (get pool-id details))
			(cycle (get cycle details))
			(pool-tokens (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details-by-id pool-id)))
			(expired-balance (get-expired-balance pool-id tx-sender cycle))
			(token-x-trait (get token-x-trait details))
			(token-y-trait (get token-y-trait details))
			(check-token-x (asserts! (is-eq (get token-x pool-tokens) (contract-of token-x-trait)) ERR-TOKEN-MISMATCH))
			(check-token-y (asserts! (is-eq (get token-y pool-tokens) (contract-of token-y-trait)) ERR-TOKEN-MISMATCH))
			(check-pool-id (asserts! (not (is-eq pool-id u170)) ERR-INVALID-POOL-ID))
			(claimed-expired-balance (if (get-claimed-expired-or-default tx-sender pool-id cycle)
				false 
				(begin
					(try! (send-native-balances (get native-x-bal expired-balance) (get native-y-bal expired-balance) token-x-trait token-y-trait))
					(asserts! (map-set claimed-expired { address: tx-sender, pool-id: pool-id, cycle: cycle } true) ERR-UPDATE-PRINCIPAL-MAP-FAILED)
					(print (merge expired-balance { address: tx-sender, dest: (get dest details), claimed: true }))
					true))))
		(ok { pool-id: pool-id, claim-expired-balance: claimed-expired-balance, cycle: cycle })))

(define-private (claim-expired-balance-iter (details { dest: (buff 256), pool-id: uint, cycle: uint, token-x-trait: <ft-trait>, token-y-trait: <ft-trait> }) (prior (response (list 200 { pool-id: uint, claim-expired-balance: bool, cycle: uint }) uint)))
	(match prior 
		ok-value 
		(ok (unwrap-panic (as-max-len? (append ok-value (try! (claim-expired-balance details))) u200)))
		err-value prior))

;; Claim balances from multiple pools
(define-public (claim-expired-balance-many (details (list 200 { dest: (buff 256), pool-id: uint, cycle: uint, token-x-trait: <ft-trait>, token-y-trait: <ft-trait> })))
	(fold claim-expired-balance-iter details (ok (list))))

(define-public (claim-all-balance-many 
	(details (list 200 { dest: (buff 256), pool-id: uint, token-x-trait: <ft-trait>, token-y-trait: <ft-trait> }))
	(expired-details (list 200 { dest: (buff 256), pool-id: uint, cycle: uint, token-x-trait: <ft-trait>, token-y-trait: <ft-trait> })))
	(begin
		(print (try! (claim-balance-many details)))
		(print (try! (claim-expired-balance-many expired-details)))
		(ok true)))

(define-private (send-native-balances (native-x-bal uint) (native-y-bal uint) (token-x-trait <ft-trait>) (token-y-trait <ft-trait>))
	(begin		
		(and
			(> native-x-bal u0)
			(if (is-eq (contract-of token-x-trait) 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc)
				(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-vault-v2-01 transfer-ft 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc native-x-bal tx-sender))
				(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-vault-v2-01 transfer-ft token-x-trait native-x-bal tx-sender))))		
		(and
			(> native-y-bal u0)
			(if (is-eq (contract-of token-y-trait) 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc)
				(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-vault-v2-01 transfer-ft 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc native-y-bal tx-sender))
				(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-vault-v2-01 transfer-ft token-y-trait native-y-bal tx-sender))))
	(ok true)))

(define-private (calculate-distribution (pool-id uint) (total-lp-balance uint) (total-supply uint) (balance-x uint) (balance-y uint) (token-x principal) (token-y principal))
	(let (
		(token-x-bal (if (is-eq total-supply u0) u0 (/ (* (/ (* total-lp-balance ONE_8) total-supply) balance-x) ONE_8)))
		(token-y-bal (if (is-eq total-supply u0) u0 (/ (* (/ (* total-lp-balance ONE_8) total-supply) balance-y) ONE_8)))
		(lost-x-bal (if (or (is-eq token-x 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc) (is-eq token-x 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc)) (mul-down token-x-bal (var-get btc-pct)) (if (is-eq token-x 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2) (mul-down token-x-bal (var-get stx-pct)) (if (is-eq token-x 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt) (mul-down token-x-bal (var-get usd-pct)) u0))))
		(lost-y-bal (if (or (is-eq token-y 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc) (is-eq token-y 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc)) (mul-down token-y-bal (var-get btc-pct)) (if (is-eq token-y 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2) (mul-down token-y-bal (var-get stx-pct)) (if (is-eq token-y 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt) (mul-down token-y-bal (var-get usd-pct)) u0))))
		(native-x-bal (- token-x-bal lost-x-bal))
		(native-y-bal (- token-y-bal lost-y-bal))
		(usdc-x-bal (if (or (is-eq token-x 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc) (is-eq token-x 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc)) (mul-down lost-x-bal (var-get btc-rate)) (if (is-eq token-x 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2) (mul-down lost-x-bal (var-get stx-rate)) (if (is-eq token-x 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt) (mul-down lost-x-bal (var-get usd-rate)) u0))))
		(usdc-y-bal (if (or (is-eq token-y 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc) (is-eq token-y 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc)) (mul-down lost-y-bal (var-get btc-rate)) (if (is-eq token-y 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2) (mul-down lost-y-bal (var-get stx-rate)) (if (is-eq token-y 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt) (mul-down lost-y-bal (var-get usd-rate)) u0)))))
	{ pool-id: pool-id, total-lp-balance: total-lp-balance, token-x-bal: token-x-bal, token-y-bal: token-y-bal, native-x-bal: native-x-bal, native-y-bal: native-y-bal, usdc-x-bal: usdc-x-bal, usdc-y-bal: usdc-y-bal, usdc-total-bal: (+ usdc-x-bal usdc-y-bal) }))


;; Multiply two numbers and divide by ONE_8 to handle decimals
(define-private (mul-down (a uint) (b uint))
	(/ (* a b) ONE_8))

;; Divide two numbers with proper decimal handling
(define-private (div-down (a uint) (b uint))
	(if (is-eq a u0) u0 (/ (* a ONE_8) b)))

;; Get minimum of two numbers
(define-private (min (a uint) (b uint))
	(if (<= a b) a b))

;; Get maximum of two numbers
(define-private (max (a uint) (b uint))
	(if (>= a b) a b))
