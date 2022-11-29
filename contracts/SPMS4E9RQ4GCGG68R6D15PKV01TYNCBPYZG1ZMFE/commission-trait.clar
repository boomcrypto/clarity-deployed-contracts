
(define-trait commission
    (
        ;; additional action after a sale happened
        ;; must return `(ok true)` on success, never `(ok false)`
        ;; @param id; identifier of NFT
        ;; @param price: of sale in micro STX
        (pay (uint uint) (response bool uint))
    )
)