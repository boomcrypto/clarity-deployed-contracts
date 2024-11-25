---
title: "Trait agp401"
draft: true
---
```
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places

(define-constant whitelisted (list u110 u111 u112 u113))

(define-public (execute (sender principal))
	(let (
		(whitelisted-pools (contract-call? .farming-campaign-v1-01 get-whitelisted-pools))
		(updated-pools (unwrap-panic (as-max-len? (concat whitelisted-pools whitelisted) u200))))

(try! (contract-call? .farming-campaign-v1-01 whitelist-pools updated-pools))
(try! (contract-call? .self-listing-helper-v2-04 approve-token-x 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt true u100000000000))
(try! (contract-call? .self-listing-helper-v2-04 approve-token-y .token-wusdh true))	

(try! (contract-call? .self-listing-helper-v2-04 approve-request u8 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-db20 none))
(try! (contract-call? .self-listing-helper-v2-04 approve-request u9 .token-wsleo none))
(try! (contract-call? .self-listing-helper-v2-04 approve-request u11 .token-wststx none))

(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPSFYMC8H6V5KBBHV0WRVG6JJDEKX00Y6EYW6P95))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3RXQ0PJD8DXVEPHKBESB56YAWF8YWDQF4ST19YG))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3HG9PD2HW78TNYMHSQTY1TG0GR95NZZ05EWZV7D))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3TKWN0700JVJ8SW8AK5ERXKJJ0NYN8ZAB12ZQTG))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP36QD97JQ5SAH1ST21G4EY9J01MQXWTFJ5JPX8BH))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2MJ5EDHP6BPZZBC1VDJ3TP5XZJ0J8E5H311QT8S))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3ERB3CKV60Z4SW5R2RZGF6Z0A93AJTN1ATJ3T7P))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1TPXQPD9GTAZW5GB6TV99RDW0SQ7W7RZ4Y2X0GR))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3R2V4GPGK60VHXXCNW7D2W959993F428TJ99V4X))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1GZHT2CYJB2E64PYV6FK30WZR1RV3ZVAPCG0EG6))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPZJJ8KAXJ1PN111ZE2K8GGNJ082RR43Q1RT42JH))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3B2ENWNB3RWNYXGT7520TTHGMT11Q306XSCSSD1))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP896BVQEXXR8CET4N283MXS0AY04BWZR9J9AS3W))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP7MXQ23JZEX0G34AHTAJSW720JM973NC9WZ2Y6N))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP7HHJZ99JDNCG277ZTEWKKJ80FY7WYD1AXQGREF))
		(ok true)))


```
