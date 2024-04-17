---
title: "Trait rebase-strategy-trait-v1-01"
draft: true
---
```

;; SPDX-License-Identifier: BUSL-1.1

(define-trait rebase-strategy-trait
	(
		(rebase () (response uint uint))
		(finalize-mint (uint) (response bool uint))
		(finalize-burn (uint) (response bool uint))
		(request-burn (uint) (response { request-id: uint, status: (buff 1) } uint))
	)
)


```
