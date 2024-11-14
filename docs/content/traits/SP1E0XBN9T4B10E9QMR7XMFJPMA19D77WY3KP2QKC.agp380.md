---
title: "Trait agp380"
draft: true
---
```
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao set-extensions (list 
			{ extension: .self-listing-helper-v2-03, enabled: true } )))
		(try! (contract-call? .self-listing-helper-v2-03 approve-token-x 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc true u10000000))
		(try! (contract-call? .self-listing-helper-v2-03 approve-token-x 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex true u1000000000000))
		(try! (contract-call? .self-listing-helper-v2-03 approve-token-x 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 true u180000000000))
		(try! (contract-call? .self-listing-helper-v2-03 set-fee-rebate u50000000))		

(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1019HHYMH7619HGRZM9PKRJMAG0256EBBC3NZ6E))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3AQS1N9SQQB03YF0HG5KS7A2KPJYB9T81623NHY))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2HF5D9FKA393DCCPCZANZPD4K2FSDBBSSDN2440))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPH2TWXD2HHDQ8YYT174055RJJA0GCE3JWCZMXX4))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2P5X6ND4W2XDREMJPSX6MWZFE4MHH086ZG6P9GP))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3W7H6HASPRV7GN3342T1FXTZ463VJFYW3PXSD6B))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1ZZ49DR88MA4SM608JWPQ0FGTE2J33PHVN55BQF))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1CDHY3TGNZW0XW6J4WRBG5AW5G80YS161KPMS5D))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2C44N3RDN6914QRSKFGDD85GQ2VBVHZ3NN7CB7S))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1DX0FRZ175Q5TM7QD5KGSPPT1R3WKFJHN1AS9FM))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPJEGE8WDSRF414YNKAJ58FDVT9EGS1AHYE6MNVZ))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP375WGGYNW9NGM3XMWT1APH9VFK9NBDXQC2RWD0V))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2RDNYTQHMX6MJB61HFFMC63AS0FSZV5K067PWGF))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1YN0PQQPFBX54VSRRZ89J844C5CWV6DBEW47DYD))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1GWTYCEQPYRAYT5PTAKBH7S2X3S4YHQMWD9M3GY))
		(ok true)))


```
