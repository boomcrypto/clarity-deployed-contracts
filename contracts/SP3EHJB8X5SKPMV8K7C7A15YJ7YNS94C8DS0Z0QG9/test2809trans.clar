;; hello-world contract

(define-constant sender 'SP3EHJB8X5SKPMV8K7C7A15YJ7YNS94C8DS0Z0QG9)


(define-non-fungible-token soco-nft-beta uint)
(begin (nft-mint? soco-nft-beta u1 sender))

(define-read-only (get-token-uri (token-id uint))
  (ok (some "https://ipfs.io/ipfs/bafybeidexzy3wune4rwcx6amypwq52v26gal5luugtmxmtu3p4eqjv7v4i/socomd.json")))