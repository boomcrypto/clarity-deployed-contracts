---
title: "Trait lip006"
draft: true
---
```
(impl-trait 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(let ((unminted-lqstx u230680068478))
		(try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.token-lqstx dao-mint unminted-lqstx 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.treasury))
		(try! (contract-call? 'SM3KNVZS30WM7F89SXKVVFY4SN9RMPZZ9FX929N0V.lqstx-mint-endpoint-v2-01 rebase))
		(ok true)
	)
)
```
