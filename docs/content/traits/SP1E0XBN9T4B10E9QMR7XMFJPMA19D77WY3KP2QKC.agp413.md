---
title: "Trait agp413"
draft: true
---
```
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places

(define-public (execute (sender principal))
	(begin

(try! (contract-call? .self-listing-helper-v2-03 approve-token-x 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wpomboo true (* u40587174 ONE_8)))
(try! (contract-call? .self-listing-helper-v2-03 approve-token-x .token-wsbtc true u1000000))
(try! (contract-call? .self-listing-helper-v2-03 approve-token-y .token-wsbtc true))

(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3VWZ73BVGCY503QB71AGN27Y8DQRDXBM56BHHZE))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP16JVMRMK0ZNRMMRMQ1CFD08P5XCYB44VJ74GJKP))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3GBCZAYVMYVAC5GN5MJXTK1PJ3XVYKYD25R0FJJ))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3H4MX3H4M6QQGWGXJT9HYGSNWP8N7XWBDS3Q7WE))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2JCF3ME5QC779DQ2X1CM9S62VNJF44GC23MKQXK))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPR7SM8DPEK2KVTQACBNWXGWJFP81YEENJ9E4ECF))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP9CMJ7S8XR25H6ZKAJXT4M7KSPQ1B8PPVSYJRTC))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPV3BHCB2HVVQ17FKPX142SY1F05W8EEHF4XZ6DH))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2S54H2J6F6WK0RQ30PGRE3W1VMFXBABZ9Z3X348))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3XP7QWBMFBBVPBAAAW6KRGRHFCSAP57227V2CA9))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP347N5EHEQRT691QDZ64Y453QR84VWXJNACGEMS))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2P6T9D3PNKB0BEJ54YAW8KJ38VW77W6WKW7XP54))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3YMYDEHRY5SQZEMF49PBKE3TQ1P2ZTZDSBWJ3G5))

		(ok true)))


```
