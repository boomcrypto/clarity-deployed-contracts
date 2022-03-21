(use-trait tradables-trait .tradable-trait.tradables-trait)
(use-trait commission-trait .commission-trait.commission)
(use-trait nft-trait .nft-trait.nft-trait)

(define-trait sn-marketplace
    (
        (list-asset (<tradables-trait> uint uint uint) (response bool uint))

        (unlist-asset (<tradables-trait> uint) (response bool uint))

        (purchase-asset (<tradables-trait> uint) (response bool uint))
    )
)

(define-trait byz-marketplace
    (
        (list-item (<nft-trait> (string-ascii 256) uint uint) (response bool uint))

        (unlist-item (<nft-trait> (string-ascii 256) uint) (response bool uint))

        (buy-item (<nft-trait> (string-ascii 256) uint) (response bool uint))
    )
)

(define-trait sa-marketplace
    (
        (list-item (<nft-trait> uint uint uint) (response bool uint))

        (unlist-item (<nft-trait> uint uint) (response bool uint))

        (buy-item (<nft-trait> uint uint) (response bool uint))
    )
)