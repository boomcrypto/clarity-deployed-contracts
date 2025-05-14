---
title: "Trait xip108"
draft: true
---
```
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.trait-sip-010.sip-010-trait)

(define-constant err-request-already-revoked (err u10000))
(define-constant err-request-already-finalized (err u10001))

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin
(try! (revoke-request u1251))
(try! (revoke-request u1252))
(try! (revoke-request u1253))
(try! (revoke-request u1254))
(try! (revoke-request u1255))
(try! (revoke-request u1256))
(try! (revoke-request u1257))
(try! (revoke-request u1258))
(try! (revoke-request u1259))
(try! (revoke-request u1260))
(try! (revoke-request u1261))
(try! (revoke-request u1262))
(try! (revoke-request u1263))
(try! (revoke-request u1264))
(try! (revoke-request u1265))
(try! (revoke-request u1266))
(try! (revoke-request u1267))
(try! (revoke-request u1268))
(try! (revoke-request u1269))
(try! (revoke-request u1270))
(try! (revoke-request u1271))
(try! (revoke-request u1272))
(try! (revoke-request u1273))
(try! (revoke-request u1274))
(try! (revoke-request u1275))
(try! (revoke-request u1276))
(try! (revoke-request u1277))
(try! (revoke-request u1278))
(try! (revoke-request u1279))
(try! (revoke-request u1280))
(try! (revoke-request u1282))
(try! (revoke-request u1283))
(try! (revoke-request u1284))
(try! (revoke-request u1285))
(try! (revoke-request u1286))
(try! (revoke-request u1287))
(try! (revoke-request u1289))

(ok true)))

(define-private (revoke-request (request-id uint))
	(let (
			(request (try! (contract-call? .meta-bridge-registry-v2-04 get-request-or-fail request-id)))
			(gross-amount (+ (get amount-net request) (get fee request) (get gas-fee request)))
			(updated-request (merge request { revoked: true })))			
			(asserts! (not (get revoked request)) err-request-already-revoked)
			(asserts! (not (get finalized request)) err-request-already-finalized)			
		(print { action: "revoke-request", request-id: request-id, updated-request: updated-request })
		(contract-call? .meta-bridge-registry-v2-04 set-request request-id updated-request)))

```
