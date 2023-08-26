;; hello-world contract

(define-constant sender 'SP1VG2RCJ5E8R79SG5G7GPZGM30CZQRD8QDJNAZTS)


(define-non-fungible-token soco-nft-2508 uint)
(begin (nft-mint? soco-nft-2508 u1 sender))

(define-read-only (get-token-uri (token-id uint))
  (ok (some "https://ipfs.io/ipfs/bafybeidexzy3wune4rwcx6amypwq52v26gal5luugtmxmtu3p4eqjv7v4i/socomd.json")))