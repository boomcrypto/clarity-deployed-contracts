---
title: "Trait agp359"
draft: true
---
```
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places

(define-public (execute (sender principal))
	(begin	
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.self-listing-helper-v2-01 approve-request u13 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wwojak none))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.self-listing-helper-v2-01 approve-request u14 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wpomboo none))

(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3D6V6T2Y14AV8F388Q3C17F1CRV6ZDDW3H3QPS5))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP36KQ8XK86KXAHMG10ET1HYRKQTV64PNF23QP9XG))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP032RKGTT5RYXQXN9SS1DSGQX5WGGG79Y9D88ZC))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP5PPYM6NZWKW00VFQPY2RMDJ1QXXH5ZQCH0YQ83))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPPTF68BKDPJ1DW6A1N30PTHD8F7XV37CJRPB8M9))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3WJD9A8XQXA41SKXK97QA1TYGJ81GQSJ6NW1FKB))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3XFW2QA7NS69W3MC9W4K450HTSPA8ZBFZKMGB2S))
		(ok true)))


```
