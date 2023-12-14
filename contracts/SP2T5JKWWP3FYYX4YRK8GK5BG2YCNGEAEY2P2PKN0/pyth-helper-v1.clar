
(define-public (verify-and-update-price (pnau-bytes (buff 8192)))
  (contract-call? .pyth-oracle-v1 verify-and-update-price-feeds
    pnau-bytes 
    {
      pyth-storage-contract: .pyth-store-v1,
      pyth-decoder-contract: .pyth-pnau-decoder-v1,
      wormhole-core-contract: .wormhole-core-v1
    }))

(define-public (read-price (price-feed-id (buff 32)))
  (contract-call? .pyth-oracle-v1 read-price-feed price-feed-id .pyth-store-v1))
