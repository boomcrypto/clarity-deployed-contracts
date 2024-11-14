---
title: "Trait agp362"
draft: true
---
```
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant recipients (list
	{ amount: (* u1000000 ONE_8), recipient: 'SPZN0SK6Y4JP96S342KR3HA108RGJBJJGE266CC0 }
))

(define-public (execute (sender principal))
	(begin
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.self-listing-helper-v2-01 approve-request u15 .token-wcatstacks none))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.self-listing-helper-v2-01 approve-request u16 .token-wgort none))

(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP319Q8EHM832CGNKDVJ0S9KB58Y7MKRGRYKK9C01))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1SPXH8M9CDE83Z3ATPXAJFJR3T5NMBQXWM9FCX4))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPJ1D6HYRZ66E6X0CJZMPK0JJ6JEBXGECMY9G1J8))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3R1KX6EKR3R58BGQ3KRS2XNB93TPMEXGMBV5N2))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2DYBJ8Q2P0TCACE12CPMH9CG5KPNGGW94MY1X71))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2V655KJ5MV324VAD1DMQX1PMP4QQ8FPZFKQHFHJ))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2F8ZMEPAN43EDHGN1X7SFRJWSSQ48THCJNEF0DR))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2866QG8B5P9YM14X71HYTPYZ7DTJ0ZW6Z17YDJW))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1S9FRC77Q6P7MFABWF88S712K7RY5Q7C2YKE85M))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP34F0JG6E5S8A8S3MYTP881W321HDDDR0ZYKG14P))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1FRA7JBZVE22EYR6W2VQDHJKZJRAEWAEN5XVWAW))

(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex edg-mint-many recipients))
		(ok true)))


```
