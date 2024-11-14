---
title: "Trait lip015"
draft: true
---
```

;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin
    (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3-registry set-shares-to-tokens-per-cycle u205 ONE_8))
    (try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.auto-alex-v3-endpoint-v2-02 finalize-redeem u12))
    (try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.auto-alex-v3-endpoint-v2-02 finalize-redeem u6))
		(ok true)))
```
