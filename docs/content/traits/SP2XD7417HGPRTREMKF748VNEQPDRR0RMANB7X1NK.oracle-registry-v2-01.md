---
title: "Trait oracle-registry-v2-01"
draft: true
---
```
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-TX-NOT-MINED (err u1002))
(define-constant ERR-TX-NOT-INDEXED (err u1003))
(define-map bitcoin-tx-mined (buff 32768) uint)
(define-map bitcoin-tx-indexed { tx-hash: (buff 32768), output: uint, offset: uint } { tick: (string-utf8 256), amt: uint, from: (buff 128), to: (buff 128) })
(define-map user-balance { user: (buff 128), tick: (string-utf8 256) } { balance: uint, up-to-block: uint })
(define-map tick-decimals (string-utf8 256) uint)
(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .executor-dao) (contract-call? .executor-dao is-extension contract-caller)) ERR-NOT-AUTHORIZED)))
(define-read-only (get-user-balance-or-default (user (buff 128)) (tick (string-utf8 256)))
	(default-to { balance: u0, up-to-block: u0 } (map-get? user-balance { user: user, tick: tick })))
(define-read-only (get-tick-decimals-or-default (tick (string-utf8 256)))
	(default-to u18 (map-get? tick-decimals tick)))
(define-read-only (get-bitcoin-tx-mined-or-fail (tx (buff 32768)))
	(ok (unwrap! (map-get? bitcoin-tx-mined tx) ERR-TX-NOT-MINED)))
(define-read-only (get-bitcoin-tx-indexed-or-fail (bitcoin-tx (buff 32768)) (output uint) (offset uint))
	(ok (unwrap! (map-get? bitcoin-tx-indexed { tx-hash: bitcoin-tx, output: output, offset: offset }) ERR-TX-NOT-INDEXED)))
(define-public (set-tick-decimals (tick (string-utf8 256)) (decimals uint))
	(begin 			
		(try! (is-dao-or-extension))			
		(print { notification: "set-tick-decimals", payload: { tick: tick, decimals: decimals} })
		(ok (map-set tick-decimals tick decimals))))
(define-public (set-user-balance (key { user: (buff 128), tick: (string-utf8 256) }) (value { balance: uint, up-to-block: uint }))
	(begin
		(try! (is-dao-or-extension))		
		(print { notification: "set-user-balance", payload: { key: key, value: value } })
		(ok (map-set user-balance key value))))
(define-public (set-tx-mined (key (buff 32768)) (value uint))
	(begin
		(try! (is-dao-or-extension))		
		(print { notification: "set-tx-mined", payload: { key: key, value: value }})
		(ok (map-set bitcoin-tx-mined key value))))
(define-public (set-tx-indexed (key { tx-hash: (buff 32768), output: uint, offset: uint }) (value { tick: (string-utf8 256), amt: uint, from: (buff 128), to: (buff 128) }))
	(begin
		(try! (is-dao-or-extension))		
		(print { notification: "set-tx-indexed", payload: { key: key, value: value } })
		(ok (map-set bitcoin-tx-indexed key value))))
```
