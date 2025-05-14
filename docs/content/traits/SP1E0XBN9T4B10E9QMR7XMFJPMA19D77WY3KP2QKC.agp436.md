---
title: "Trait agp436"
draft: true
---
```
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .alex-launchpad-v2-03 add-approved-operator 'SP17JDRQ402PC603JJK5YH9N0XRP9RBRGQ91RJHA3))

(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3MYF6B973WD1ZZ26FKTS0YCN79JCRC6C0BQ0JNQ))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP39936RS0CKWG3GRA9S7N1SK95SBPKAS7H99D1BB))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPDW3PJV6C69FES10HY97Y1RC2PZ4PWDF3958DTB))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2CF731GXSH0QTAS21STJE8KGRFRW87QDZ7KECNC))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2FWHBQJVS1P3HGVVM4DXRMXRVXTYNQNCGX48QZW))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1JPXYVHY7AW8XVT11XPK41XFNGSC8VSM4ZATVY4))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPQD9DRJJSSFR7TVQB51GFYR0BE461MZXR6NCT25))
		(ok true)))

```
