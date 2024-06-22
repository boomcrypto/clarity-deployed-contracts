---
title: "Trait LunrBUZRedemption"
draft: true
---
```
;; Set a Base (EVM) address for a Stacks address. All Lunr tokens sent to this contract are locked and effectively burned.
;; For every 10 Lunr tokens sent to this contract, 1 BUZ token is sent to the mapped Ethereum address on the base network.

(define-map base-addresses principal (optional (buff 20)))

(define-public (set-redemption-address (base-address (buff 20)))
  (begin
    (map-set base-addresses tx-sender (some base-address))
    (ok true)
  )
)

(define-read-only (get-redemption-address (stacks-address principal))
  (map-get? base-addresses stacks-address)
)


```
