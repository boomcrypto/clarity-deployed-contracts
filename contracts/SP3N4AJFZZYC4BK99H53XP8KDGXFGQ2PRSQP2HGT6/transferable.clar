(define-trait transferable
    (
        ;; Transfer from the sender to a new principal
        ;; must return `(ok true)` on success, never `(ok false)`
        ;; @param id-or-amount; identifier of NFT or amount of FTs
        ;; @param sender: owner of asset
        ;; @param recipient: new owner of asset after tx
        (transfer (uint principal principal) (response bool uint))

        ;; Transfer from the sender to a new principal
        ;; must return `(ok true)` on success, never `(ok false)`
        ;; must emit an event with `memo`
        ;; @param id-or-amount; identifier of NFT or amount of FTs
        ;; @param sender: owner of asset
        ;; @param recipient: new owner of asset after tx
        ;; @param memo: message attached to the transfer
        (transfer-memo (uint principal principal (buff 34)) (response bool uint))
    )
)
