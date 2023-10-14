(define-map socoval
    uint
    {
        value1: (string-ascii 37),
         value2: (string-ascii 5),
          value3: (string-ascii 3),
           value4: (string-ascii 5)
     
    }
)

(define-constant sender 'SP3EHJB8X5SKPMV8K7C7A15YJ7YNS94C8DS0Z0QG9)

(define-non-fungible-token soco-nft-beta uint)
(begin (nft-mint? soco-nft-beta u1 sender))

(define-read-only (get-socoval (soco-id uint))
    (map-get? socoval soco-id)
)

(define-public (save-socoval (soco-id uint))
    (begin
        (ok (map-set socoval soco-id {value1: "25.10.USA.MA.01.GIS.AMZN.1A3590EH1EFA",value2: "25.10",value3: "252",value4: "25110" }))
    )
)

(define-read-only (get-token-uri (token-id uint))
  (ok (some "https://ipfs.io/ipfs/bafybeia4qzsomjdgtmdm2hdziorccytiagyw2my45elc25lz7onbeqwqva/nftmetadata.json")))