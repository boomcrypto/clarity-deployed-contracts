---
title: "Trait cryptocash-token-trait"
draft: true
---
```
;; CryptoCash Token Trait

(define-trait cryptocash-token
  (
    (activate-token (uint)
      (response bool uint)
    )

    (set-token-uri ((optional (string-utf8 256)))
      (response bool uint)
    )

    (mint (uint principal)
      (response bool uint)
    )

    (burn (uint principal)
      (response bool uint)
    )

    (send-many ((list 200 { to: principal, amount: uint, memo: (optional (buff 34)) }))
      (response bool uint)
    )
  )
)

```
