---
title: "Trait agp343"
draft: true
---
```
(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-public (execute (sender principal))
	(let (
			(moon-owner 'SP2VGJQAB0T7R2Y9S2PJRNPDEW91CM2YCDYJGGPQS)
			(vesting-details (try! (contract-call? .treasury-grant get-vesting-or-fail moon-owner)))
			(user-stats (try! (contract-call? .treasury-grant get-stats moon-owner)))
			(alex-amt (+ (get available user-stats) (get remaining user-stats))))
		(try! (contract-call? .treasury-grant set-vesting-many (list { participant: moon-owner, details: (merge vesting-details { alex: u0 })})))
		(try! (contract-call? .treasury-grant transfer-fixed .token-alex alex-amt tx-sender))
		(try! (contract-call? .amm-pool-v2-01 create-pool .token-alex .token-wmoon ONE_8 moon-owner alex-amt (* u1000000000 ONE_8)))
		(try! (contract-call? .amm-vault-v2-01 set-approved-token .token-wmoon true))
		(try! (contract-call? .amm-registry-v2-01 set-oracle-enabled .token-alex .token-wmoon ONE_8 true))
		(try! (contract-call? .amm-registry-v2-01 set-fee-rate-x .token-alex .token-wmoon ONE_8 u500000))
		(try! (contract-call? .amm-registry-v2-01 set-fee-rate-y .token-alex .token-wmoon ONE_8 u500000))
		(try! (contract-call? .amm-registry-v2-01 set-max-in-ratio .token-alex .token-wmoon ONE_8 u60000000))
		(try! (contract-call? .amm-registry-v2-01 set-max-out-ratio .token-alex .token-wmoon ONE_8 u60000000))
		(try! (contract-call? .amm-registry-v2-01 set-oracle-average .token-alex .token-wmoon ONE_8 u99000000))
		(try! (contract-call? .amm-registry-v2-01 set-fee-rebate .token-alex .token-wmoon ONE_8 u50000000))
		(try! (contract-call? .amm-registry-v2-01 set-pool-owner .token-alex .token-wfrodo ONE_8 'SM2NJ6ZCXXX3H1QF79MY8663G5FAVCSYM5RVY768B))
		(try! (contract-call? .self-listing-helper-v2-01 approve-request u5 .token-wtremp none))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP3VBE12FYS26JEMGR9P5EXABK0K7ENKPCM5KHRJB))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP3YWSZSDFJ505AZCF3HRE6FQYKSM990SH19DAGWB))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP7S3EY6FS1PJHJN6S3NV71RYQ7CKGABE5SDAT9N))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SPEN20JKMQ63XE225FMDCTVCMCJ3D45MMAV1C3YK))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP2ZDYA6KCDVD7TWDK6HMQFFKRY5PA74R9F33TG40))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP27WZRNZVDBZVH6S97YQJNB4BMPKWHKS5QY41QQB))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP1S15609W7HJWZF0Q247BVNVPXNP3YFNSC8T4A2H))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP1K8BYAQCEDP38J58YYQ4SMPJS8467HFSXZF91KF))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP3J11AV9NXE22JHQ58PGDZVPA7TWY449JG1R844F))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP3C5M7D156MFQM8F703MYAEZJ98T5K2R71HGV5M0))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP3VT4RSGKS16AQE7W7WKM4V3BVRJJ36EHN7M1BYB))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP1WZVCZQ15M6BS5PACHF2RXCG565PX2DM27TGGNN))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP1VJ68V0CWQFJDJZG413DKVKBK66BBKK0TTKBCPG))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP3V49RD5EPQ7DVPH10VX1QABQ7KJBN48B2CGV0HR))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP1PBZQ1W1S49QVCBS4VGM62WMQ6EFZ75Y9G3AGYQ))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP3DW2YR31HWKR70630ZPFM88F1Y5M490AX13QC19))		
(ok true)))
```
