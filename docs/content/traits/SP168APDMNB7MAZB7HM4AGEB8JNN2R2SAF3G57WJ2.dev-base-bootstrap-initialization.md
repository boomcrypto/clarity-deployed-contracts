---
title: "Trait dev-base-bootstrap-initialization"
draft: true
---
```
(impl-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.proposal)

(define-constant DAO_MANIFEST "To keep building no matter the obstacles.")

(define-public (execute (sender principal))
  (begin  
    ;; set initial dao extensions list
    (try! (contract-call? 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.dev-base-dao set-extensions
      (list
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.dev-action-proposals, enabled: true}
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.dev-bank-account, enabled: true}
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.dev-core-proposals, enabled: true}
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.dev-onchain-messaging, enabled: true}
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.dev-payments-invoices, enabled: true}
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.dev-token-owner, enabled: true}
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.dev-treasury, enabled: true}
      )
    ))
    ;; set initial action proposals list
    (try! (contract-call? 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.dev-base-dao set-extensions
      (list
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.dev-action-add-resource, enabled: true}
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.dev-action-allow-asset, enabled: true}
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.dev-action-send-message, enabled: true}
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.dev-action-set-account-holder, enabled: true}
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.dev-action-set-withdrawal-amount, enabled: true}
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.dev-action-set-withdrawal-period, enabled: true}
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.dev-action-toggle-resource, enabled: true}
      )
    ))
    ;; send DAO manifest as onchain message
    (try! (contract-call? 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.dev-onchain-messaging send DAO_MANIFEST true))
    ;; allow assets in treasury
    (try! (contract-call? 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.dev-treasury allow-asset 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.dev-stxcity true))
    ;; print manifest
    (print DAO_MANIFEST)
    (ok true)
  )
)

(define-read-only (get-dao-manifest)
  DAO_MANIFEST
)

```
