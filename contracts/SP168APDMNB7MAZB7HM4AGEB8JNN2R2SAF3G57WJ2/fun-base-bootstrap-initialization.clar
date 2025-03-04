(impl-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.proposal)

(define-constant DAO_MANIFEST "To keep building no matter the obstacles.")

(define-public (execute (sender principal))
  (begin  
    ;; set initial dao extensions list
    (try! (contract-call? 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.fun-base-dao set-extensions
      (list
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.fun-action-proposals, enabled: true}
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.fun-bank-account, enabled: true}
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.fun-core-proposals, enabled: true}
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.fun-onchain-messaging, enabled: true}
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.fun-payments-invoices, enabled: true}
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.fun-token-owner, enabled: true}
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.fun-treasury, enabled: true}
      )
    ))
    ;; set initial action proposals list
    (try! (contract-call? 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.fun-base-dao set-extensions
      (list
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.fun-action-add-resource, enabled: true}
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.fun-action-allow-asset, enabled: true}
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.fun-action-send-message, enabled: true}
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.fun-action-set-account-holder, enabled: true}
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.fun-action-set-withdrawal-amount, enabled: true}
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.fun-action-set-withdrawal-period, enabled: true}
        {extension: 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.fun-action-toggle-resource, enabled: true}
      )
    ))
    ;; send DAO manifest as onchain message
    (try! (contract-call? 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.fun-onchain-messaging send DAO_MANIFEST true))
    ;; allow assets in treasury
    (try! (contract-call? 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.fun-treasury allow-asset 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.fun-stxcity true))
    ;; print manifest
    (print DAO_MANIFEST)
    (ok true)
  )
)

(define-read-only (get-dao-manifest)
  DAO_MANIFEST
)
