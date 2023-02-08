(define-constant sender 'SP16MYYYH4Z51EAS76K55JMJ182629JNWSHK5NWM)
(define-constant recipient 'SP1VG2RCJ5E8R79SG5G7GPZGM30CZQRD8QDJNAZTS)

(define-non-fungible-token soconftstacks5 uint)
(begin (nft-mint? soconftstacks5 u1 sender))
(begin (nft-mint? soconftstacks5 u2 sender))
(begin (nft-transfer? soconftstacks5 u1 sender recipient))

(define-read-only (get-token-uri (token-id uint))
  (ok (some "https://ipfs.io/ipfs/bafybeicvnaqeyxqkqf7vuih3222hk6pcd5poo2qew7gsni52curv7ccpce/soco1.json")))