---
title: "Trait agp375"
draft: true
---
```
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places

(define-public (execute (sender principal))
	(begin
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.self-listing-helper-v2-01 approve-request u30 .token-wbaby none))

(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP5V06FFDE7B90X9RTQRCPEM4GN9TKBYBC1641RB))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2N8EM3C6WTZXAR19DPWKV78224EK85HB75Y8M84))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2A6F802MTTNE4P2Z6WG8SXMKBH4JXMX5JR2CZB6))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPBEF7J4B90G7JTBVJ7GERCMX2ZMJXP9KZCTFKV7))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPZH8SKGW4Y87PMV00AC0A5QCZSQ83GSHECB876E))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3SCZYC0ADNGYZ11Q563E5BNWSJE71APF0RRSCSS))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1NGQ6SR9SJA6GN0YBC8ZM3XV6GNVKRTG6PQVTKS))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1GF1NNDBAR7361KNDQDJDPWEJHBNSAZTKJH4WBR))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP13JXVXDKTZ2NPY27V9PZ05AYFNTBT5A94GRD8D8))
		(ok true)))


```
