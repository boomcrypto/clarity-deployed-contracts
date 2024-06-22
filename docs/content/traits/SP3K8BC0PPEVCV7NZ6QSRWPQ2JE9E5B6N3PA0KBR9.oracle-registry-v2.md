---
title: "Trait oracle-registry-v2"
draft: true
---
```
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-PAUSED (err u1001))
(define-constant ERR-TX-NOT-MINED (err u1002))
(define-constant ERR-TX-NOT-INDEXED (err u1003))
(define-data-var contract-owner principal tx-sender)
(define-data-var is-paused bool true)
(define-map bitcoin-tx-indexed { tx-hash: (buff 8192), output: uint, offset: uint } { tick: (string-utf8 256), amt: uint, from: (buff 128), to: (buff 128) })
(define-map user-balance { user: (buff 128), tick: (string-utf8 256) } { balance: uint, up-to-block: uint })
(define-map tick-decimals (string-utf8 256) uint)
(define-public (set-paused (paused bool))
	(begin
		(try! (check-is-owner))
		(ok (var-set is-paused paused))))
(define-public (approve-operator (operator principal) (approved bool))
	(begin
		(try! (check-is-owner))
		(as-contract (contract-call? .oracle-registry-v1-02 approve-operator operator approved))))
(define-public (set-contract-owner (owner principal))
	(begin
		(try! (check-is-owner))
		(ok (var-set contract-owner owner))))
(define-public (set-paused-legacy (paused bool))
	(begin
		(try! (check-is-owner))
		(as-contract (contract-call? .oracle-registry-v1-02 set-paused paused))))
(define-public (set-contract-owner-legacy (owner principal))
	(begin
		(try! (check-is-owner))
		(as-contract (contract-call? .oracle-registry-v1-02 set-contract-owner owner))))
(define-read-only (get-contract-owner)
	(var-get contract-owner))
(define-read-only (get-paused)
	(var-get is-paused))
(define-read-only (get-approved-operator-or-default (operator principal))
	(contract-call? .oracle-registry-v1-02 get-approved-operator-or-default operator))
(define-read-only (get-user-balance-or-default (user (buff 128)) (tick (string-utf8 256)))
	(match (as-max-len? tick u4)
		some-value (contract-call? .oracle-registry-v1-02 get-user-balance-or-default user some-value)
		(default-to { balance: u0, up-to-block: u0 } (map-get? user-balance { user: user, tick: tick }))))
(define-read-only (get-tick-decimals-or-default (tick (string-utf8 256)))
	(match (as-max-len? tick u4)
		some-value (contract-call? .oracle-registry-v1-02 get-tick-decimals-or-default some-value)
		(default-to u18 (map-get? tick-decimals tick))))
(define-read-only (get-bitcoin-tx-mined-or-fail (tx (buff 8192)))
	(contract-call? .oracle-registry-v1-02 get-bitcoin-tx-mined-or-fail tx))	
(define-read-only (get-bitcoin-tx-indexed-or-fail (bitcoin-tx (buff 8192)) (output uint) (offset uint))
	(contract-call? .oracle-registry-v1-02 get-bitcoin-tx-indexed-or-fail bitcoin-tx output offset))
(define-public (set-tick-decimals (tick (string-utf8 256)) (decimals uint))
	(match (as-max-len? tick u4)
		some-value
		(begin
			(asserts! (not (var-get is-paused)) ERR-PAUSED)
			(print { notification: "set-tick-decimals", payload: { tick: some-value, decimals: decimals} })
			(contract-call? .oracle-registry-v1-02 set-tick-decimals some-value decimals))
		(begin 
			(asserts! (not (var-get is-paused)) ERR-PAUSED)
			(try! (check-is-approved))			
			(print { notification: "set-tick-decimals", payload: { tick: tick, decimals: decimals} })
			(ok (map-set tick-decimals tick decimals)))))
(define-public (set-user-balance (key { user: (buff 128), tick: (string-utf8 256) }) (value { balance: uint, up-to-block: uint }))
	(match (as-max-len? (get tick key) u4)
		some-value
		(begin
			(asserts! (not (var-get is-paused)) ERR-PAUSED)
			(print { notification: "set-user-balance", payload: { key: { user: (get user key), tick: some-value }, value: value }})
			(contract-call? .oracle-registry-v1-02 set-user-balance { user: (get user key), tick: some-value } value))		
		(begin
			(asserts! (not (var-get is-paused)) ERR-PAUSED)
			(try! (check-is-approved))		
			(print { notification: "set-user-balance", payload: { key: key, value: value } })
			(ok (map-set user-balance key value)))))
(define-public (set-tx-mined (key (buff 8192)) (value uint))
	(begin
		(asserts! (not (var-get is-paused)) ERR-PAUSED)
		(print { notification: "set-tx-mined", payload: { key: key, value: value }})
		(contract-call? .oracle-registry-v1-02 set-tx-mined key value)))
(define-public (set-tx-indexed (key { tx-hash: (buff 8192), output: uint, offset: uint }) (value { tick: (string-utf8 256), amt: uint, from: (buff 128), to: (buff 128) }))
	(match (as-max-len? (get tick value) u4)
		some-value
		(begin
			(asserts! (not (var-get is-paused)) ERR-PAUSED)
			(print { notification: "set-tx-indexed", payload: { key: key, value: (merge value { tick: some-value }) } })	
			(contract-call? .oracle-registry-v1-02 set-tx-indexed key (merge value { tick: some-value })))
		(begin
			(asserts! (not (var-get is-paused)) ERR-PAUSED)
			(print { notification: "set-tx-indexed", payload: { key: key, value: value } })
			(ok (map-set bitcoin-tx-indexed key value)))))
(define-private (check-is-approved)
	(ok (asserts! (or (get-approved-operator-or-default tx-sender) (is-ok (check-is-owner))) ERR-NOT-AUTHORIZED)))
(define-private (check-is-owner)
	(ok (asserts! (is-eq (var-get contract-owner) tx-sender) ERR-NOT-AUTHORIZED)))
```
