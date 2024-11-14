---
title: "Trait meta-bridge-registry-v2-03"
draft: true
---
```
(define-constant err-unauthorised (err u1000))
(define-constant err-invalid-amount (err u1001))

(define-map liquidity-balances { from: (buff 128), token-x: principal, token-y: principal, factor: uint, chain-id: uint } uint)
(define-map approved-fulfill-address (buff 128) bool)

;; read-only calls

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao) (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao is-extension contract-caller)) err-unauthorised)))

(define-read-only (get-request-nonce)
	(contract-call? .meta-bridge-registry-v2-02 get-request-nonce))

(define-read-only (get-request-revoke-grace-period)
	(contract-call? .meta-bridge-registry-v2-02 get-request-revoke-grace-period))

(define-read-only (get-request-claim-grace-period)
	(contract-call? .meta-bridge-registry-v2-02 get-request-claim-grace-period))

(define-read-only (is-peg-in-address-approved (address (buff 128)))
	(contract-call? .meta-bridge-registry-v2-02 is-peg-in-address-approved address))

(define-read-only (get-request-or-fail (request-id uint))
	(contract-call? .meta-bridge-registry-v2-02 get-request-or-fail request-id))

(define-read-only (get-peg-in-sent-or-default (bitcoin-tx (buff 32768)) (output uint) (offset uint))
	(contract-call? .meta-bridge-registry-v2-02 get-peg-in-sent-or-default bitcoin-tx output offset))

(define-read-only (get-pair-details-or-fail (pair { token: principal, chain-id: uint }))
	(contract-call? .meta-bridge-registry-v2-02 get-pair-details-or-fail pair))

(define-read-only (is-approved-pair (pair { token: principal, chain-id: uint }))
	(contract-call? .meta-bridge-registry-v2-02 is-approved-pair pair))

(define-read-only (get-tick-to-pair-or-fail (tick (string-utf8 256)))
	(contract-call? .meta-bridge-registry-v2-02 get-tick-to-pair-or-fail tick))

(define-read-only (is-fulfill-address-approved (address (buff 128)))
	(default-to false (map-get? approved-fulfill-address address)))

(define-read-only (get-liquidity-balance-or-default (key { from: (buff 128), token-x: principal, token-y: principal, factor: uint, chain-id: uint }))
	(default-to u0 (map-get? liquidity-balances key)))

;; governance functions

(define-public (set-request-revoke-grace-period (grace-period uint))
	(begin
		(try! (is-dao-or-extension))
		(contract-call? .meta-bridge-registry-v2-02 set-request-revoke-grace-period grace-period)))

(define-public (set-request-claim-grace-period (grace-period uint))
	(begin
		(try! (is-dao-or-extension))	
		(contract-call? .meta-bridge-registry-v2-02 set-request-claim-grace-period grace-period)))

(define-public (approve-peg-in-address (address (buff 128)) (approved bool))
	(begin
		(try! (is-dao-or-extension))
		(contract-call? .meta-bridge-registry-v2-02 approve-peg-in-address address approved)))

(define-public (set-approved-chain (the-chain-id uint) (chain-name (string-utf8 256)))
	(begin
		(try! (is-dao-or-extension))
		(contract-call? .meta-bridge-registry-v2-02 set-approved-chain the-chain-id chain-name)))

(define-public (pause-peg-in (pair { token: principal, chain-id: uint }) (paused bool))
	(begin 
		(try! (is-dao-or-extension))
		(contract-call? .meta-bridge-registry-v2-02 pause-peg-in pair paused)))

(define-public (pause-peg-out (pair { token: principal, chain-id: uint }) (paused bool))
	(begin
		(try! (is-dao-or-extension))
		(contract-call? .meta-bridge-registry-v2-02 pause-peg-out pair paused)))

(define-public (set-peg-in-fee (pair { token: principal, chain-id: uint }) (new-peg-in-fee uint))
	(begin
		(try! (is-dao-or-extension))
		(contract-call? .meta-bridge-registry-v2-02 set-peg-in-fee pair new-peg-in-fee)))

(define-public (set-peg-out-fee (pair { token: principal, chain-id: uint }) (new-peg-out-fee uint))
	(begin
		(try! (is-dao-or-extension))
		(contract-call? .meta-bridge-registry-v2-02 set-peg-out-fee pair new-peg-out-fee)))

(define-public (set-peg-out-gas-fee (pair { token: principal, chain-id: uint }) (new-peg-out-gas-fee uint))
	(begin
		(try! (is-dao-or-extension))
		(contract-call? .meta-bridge-registry-v2-02 set-peg-out-gas-fee pair new-peg-out-gas-fee)))

(define-public (set-token-no-burn (pair { token: principal, chain-id: uint }) (no-burn bool))
	(begin
		(try! (is-dao-or-extension))
		(contract-call? .meta-bridge-registry-v2-02 set-token-no-burn pair no-burn)))

(define-public (approve-pair (pair { token: principal, chain-id: uint }) (tick (string-utf8 256)) (approved bool) )
	(begin
		(try! (is-dao-or-extension))
		(contract-call? .meta-bridge-registry-v2-02 approve-pair pair tick approved)))

(define-public (approve-fulfill-address (address (buff 128)) (approved bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set approved-fulfill-address address approved))))

;; priviledged functions

(define-public (set-peg-in-sent (peg-in-tx { tx: (buff 32768), output: uint, offset: uint }) (sent bool))
	(begin
		(try! (is-dao-or-extension))
		(contract-call? .meta-bridge-registry-v2-02 set-peg-in-sent peg-in-tx sent)))

(define-public (set-request (request-id uint) (details { requested-by: principal, peg-out-address: (buff 128), tick: (string-utf8 256), token: principal, amount-net: uint, fee: uint, gas-fee: uint, claimed: uint, claimed-by: principal, fulfilled-by: (buff 128), revoked: bool, finalized: bool, requested-at: uint, requested-at-burn-height: uint}))
	(begin
		(try! (is-dao-or-extension))
		(contract-call? .meta-bridge-registry-v2-02 set-request request-id details)))

(define-public (add-liquidity (key { from: (buff 128), token-x: principal, token-y: principal, factor: uint, chain-id: uint }) (amount uint))
	(let (
			(token-id (get pool-id (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details (get token-x key) (get token-y key) (get factor key)))))) 
		(try! (is-dao-or-extension))
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 transfer-fixed token-id amount tx-sender (as-contract tx-sender)))
		(ok (map-set liquidity-balances key (+ (get-liquidity-balance-or-default key) amount)))))

(define-public (remove-liquidity (key { from: (buff 128), token-x: principal, token-y: principal, factor: uint, chain-id: uint }) (amount uint))
	(let (
			(sender tx-sender)
			(token-id (get pool-id (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details (get token-x key) (get token-y key) (get factor key)))))
			(balance (get-liquidity-balance-or-default key))) 
		(try! (is-dao-or-extension))
		(asserts! (<= amount balance) err-invalid-amount)
		(as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 transfer-fixed token-id amount tx-sender sender)))
		(ok (map-set liquidity-balances key (- balance amount)))))
		
		
;; internal functions



```
