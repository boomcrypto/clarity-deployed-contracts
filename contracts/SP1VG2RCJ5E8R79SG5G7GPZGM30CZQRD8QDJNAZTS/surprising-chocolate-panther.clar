;; hello-world contract

(define-constant sender 'SP1VG2RCJ5E8R79SG5G7GPZGM30CZQRD8QDJNAZTS)


(define-non-fungible-token soco-nft-250823 uint)
(begin (nft-mint? soco-nft-250823 u1 sender))

(define-read-only (get-token-uri (token-id uint))
  (ok (some "https://ipfs.io/ipfs/bafybeia4qzsomjdgtmdm2hdziorccytiagyw2my45elc25lz7onbeqwqva/nftmetadata.json")))