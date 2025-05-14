---
title: "Trait agp456"
draft: true
---
```
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

(define-constant REGISTRATION_CUTOFF u1741053600)
(define-constant VOTING_CUTOFF u1741658400)
(define-constant STAKE_CUTOFF u1741658400)
(define-constant STAKE_END u1743991200)
(define-constant REWARD_AMOUNT (* u1000000 ONE_8))

(define-public (execute (sender principal))
	(begin
(try! (contract-call? .self-listing-helper-v2-04 approve-request u42 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wplay none))
(try! (contract-call? .farming-campaign-v2-03 whitelist-pools (list u128 u129 u130 u131 u132 u133 u134)))

(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP310XS9BXB2K384QBSW22XK5FQQRR913CB2BFEKA))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2GPSRRW1MXYM5N1011W17EZ8HWPYXMDY1X9Z00Z))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1TSPWWFXRMQATZ5VW6HMA7NE7QHFATQ2JJYJC22))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP8J65V6Q6KQHK05W06ZQD2NY2XNG8BPG5M9YZFP))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPRWAG56YDCCY1HXDVH9K66AJKN1EWPM5F9Y28A6))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1RBJAB5F3CPM78QQ7KVTM0Z0Y04VBYVP4KHRN82))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPZAA0C4P258YJ11ZHRJ986KN8V8X2JAQ0K7J1EF))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPCZCNW5MCZD42FWKWGGH9FH06TSC1CCYSF1959P))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP161T05N1EWJ52XDVSE1SY16N80PSVDPZRSG3MEM))
		(ok true)))


```
