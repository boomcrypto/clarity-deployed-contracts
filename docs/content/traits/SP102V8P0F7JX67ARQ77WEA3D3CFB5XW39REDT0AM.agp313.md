---
title: "Trait agp313"
draft: true
---
```
(impl-trait .proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(let (
(claim-details (contract-call? .claim-recovered get-claim-or-default 'SPFP4YRN8XZCZ34YKB9NJT5NCZCE5ST5AVGJMH7B))
(vesting-details (try! (contract-call? .treasury-grant get-vesting-or-fail 'SPFP4YRN8XZCZ34YKB9NJT5NCZCE5ST5AVGJMH7B)))
(set-claim (try! (contract-call? .claim-recovered set-claim-many (list { recipient: 'SPFP4YRN8XZCZ34YKB9NJT5NCZCE5ST5AVGJMH7B, details: (merge claim-details { amt-token-wvibes: u0 }) }))))
(set-vesting (try! (contract-call? .treasury-grant set-vesting-many (list { participant: 'SPFP4YRN8XZCZ34YKB9NJT5NCZCE5ST5AVGJMH7B, details: (merge vesting-details { alex: u0 }) }))))
(amt-token-alex-token-wvibes (get supply (try! (contract-call? .amm-pool-v2-01 create-pool .token-alex .token-wvibes u100000000 .executor-dao u4491676397280 u378877874675838))))
(approve-token-alex (try! (contract-call? .amm-vault-v2-01 set-approved-token .token-alex true)))
(approve-token-wvibes (try! (contract-call? .amm-vault-v2-01 set-approved-token .token-wvibes true)))
(oracle-enabled-0 (try! (contract-call? .amm-registry-v2-01 set-oracle-enabled .token-alex .token-wvibes u100000000 true)))
(fee-rate-x-0 (try! (contract-call? .amm-registry-v2-01 set-fee-rate-x .token-alex .token-wvibes u100000000 u500000)))
(fee-rate-y-0 (try! (contract-call? .amm-registry-v2-01 set-fee-rate-y .token-alex .token-wvibes u100000000 u500000)))
(max-in-ratio-0 (try! (contract-call? .amm-registry-v2-01 set-max-in-ratio .token-alex .token-wvibes u100000000 u60000000)))
(max-out-ratio-0 (try! (contract-call? .amm-registry-v2-01 set-max-out-ratio .token-alex .token-wvibes u100000000 u60000000)))
(oracle-average-0 (try! (contract-call? .amm-registry-v2-01 set-oracle-average .token-alex .token-wvibes u100000000 u99000000)))
(fee-rebate-0 (try! (contract-call? .amm-registry-v2-01 set-fee-rebate .token-alex .token-wvibes u100000000 u50000000)))
(start-block-0 (try! (contract-call? .amm-registry-v2-01 set-start-block .token-alex .token-wvibes u100000000 u0)))
(amt-token-alex-token-wleo (get supply (try! (contract-call? .amm-pool-v2-01 create-pool .token-alex .token-wleo u100000000 .executor-dao u111762264553700 u36869253403930400))))
(approve-token-wleo (try! (contract-call? .amm-vault-v2-01 set-approved-token .token-wleo true)))
(oracle-enabled-1 (try! (contract-call? .amm-registry-v2-01 set-oracle-enabled .token-alex .token-wleo u100000000 true)))
(fee-rate-x-1 (try! (contract-call? .amm-registry-v2-01 set-fee-rate-x .token-alex .token-wleo u100000000 u500000)))
(fee-rate-y-1 (try! (contract-call? .amm-registry-v2-01 set-fee-rate-y .token-alex .token-wleo u100000000 u500000)))
(max-in-ratio-1 (try! (contract-call? .amm-registry-v2-01 set-max-in-ratio .token-alex .token-wleo u100000000 u60000000)))
(max-out-ratio-1 (try! (contract-call? .amm-registry-v2-01 set-max-out-ratio .token-alex .token-wleo u100000000 u60000000)))
(oracle-average-1 (try! (contract-call? .amm-registry-v2-01 set-oracle-average .token-alex .token-wleo u100000000 u99000000)))
(fee-rebate-1 (try! (contract-call? .amm-registry-v2-01 set-fee-rebate .token-alex .token-wleo u100000000 u50000000)))
(start-block-1 (try! (contract-call? .amm-registry-v2-01 set-start-block .token-alex .token-wleo u100000000 u0))))
(ok true)))
```
