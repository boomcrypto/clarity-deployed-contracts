---
title: "Trait agp417"
draft: true
---
```
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

;; TODO
(define-constant WHITELISTED (list u115 u116 u117 u118 u119 u120 u121 u122 u123 u124))

(define-public (execute (sender principal))
	(let (
			(whitelisted-v2-01 (contract-call? .farming-campaign-v2-01 get-whitelisted-pools)))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao set-extensions (list 
	{ extension: .farming-campaign-v2-02, enabled: true } )))			
(try! (contract-call? .farming-campaign-v2-02 set-campaign-nonce u1))
(try! (contract-call? .farming-campaign-v2-02 set-revoke-enabled false))
(try! (contract-call? .farming-campaign-v2-02 whitelist-pools (unwrap-panic (as-max-len? (concat whitelisted-v2-01 WHITELISTED) u1000))))
(try! (contract-call? .farming-campaign-v2-02 create-campaign u1735783200 u1736820000 u1736820000 u1739239200 (* u2000000 ONE_8) MAX_UINT))
(try! (contract-call? .farming-campaign-v2-02 set-project-reward-ignore-list (list 'SP3N7Y3K01Y24G9JC1XXA13RQXXCY721WAVBMMD38)))

(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1RWED16ENYSGG5H5CJBGXNWN7QWPS73YA8QJBKY))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1TJSFJXSPBMQCFCHSTSGE7VYGJQKX8HGWSP7FY0))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2HZ863THS9FG4WMZPVZN82V20K9JAQ36WPHQYGE))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP37G8PKNBGTCR5442694RERVJGP5YC816J1R10DF))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1QZWEY4AKGAM5YDBYNTJ4848RQPRM63SD8K3VPM))

		(ok true)))


```
