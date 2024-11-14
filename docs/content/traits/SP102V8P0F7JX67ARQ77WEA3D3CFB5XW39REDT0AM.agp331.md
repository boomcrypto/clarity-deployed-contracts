---
title: "Trait agp331"
draft: true
---
```
(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 u100000000)
(define-public (execute (sender principal))
	(begin
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP3CKA4G83GN1YW34GEFBKD608CHN6XJ9ZT16M0Z))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SPD0VFPKA445QDQGX9DVZ1K1HJZDFP5PY1N5EAHW))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP20JNPQ5GN5SH1Q1AM8PA48B145N0FH8AGS2X822))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP2TW47X5MVTCAQ1DEMCJE81XKGS9RTE322VNX20Q))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP3ANMQ34BE5C5E1KB11KCJTCK7FV7P7AE6YF1WQ))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SPSTK8JDFRY02PWSV1J9ZYHD8ZH30W5EPWB9WQ5Y))
(ok true)))
```
