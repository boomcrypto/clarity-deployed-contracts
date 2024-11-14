---
title: "Trait cryptocash-core-trait"
draft: true
---
```
;; CryptoCash Core Trait

(define-trait cryptocash-core
  (

    (mine-tokens (uint (optional (buff 34)))
      (response bool uint)
    )

    (claim-mining-reward (uint)
      (response bool uint)
    )

    (stack (uint uint)
      (response bool uint)
    )

    (claim-stacking-reward (uint)
      (response bool uint)
    )

    (set-foundation-wallet (principal)
      (response bool uint)
    )   

  )
)
```
