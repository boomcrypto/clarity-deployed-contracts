---
title: "Trait lip008"
draft: true
---
```
(impl-trait 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(let (
      (current-cycle (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-staking-v2 get-reward-cycle block-height))))
		(try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lisa-dao set-extensions (list { extension: .auto-alex-v3-endpoint, enabled: true } )))
    (try! (contract-call? .auto-alex-v3-registry set-start-cycle current-cycle))
    (try! (contract-call? .auto-alex-v3-endpoint pause-create false))
    (try! (contract-call? .auto-alex-v3-endpoint pause-redeem false))
		(ok true)))
```
