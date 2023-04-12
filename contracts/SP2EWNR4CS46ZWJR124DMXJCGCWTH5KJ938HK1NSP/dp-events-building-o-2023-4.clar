(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token building-on-bitcoin uint)

(define-constant public-key 0x02673473f73e6f38c2a4263fb4d63720713f8422c4dd5a66202cb6ea117e41828a)

(define-data-var last-id uint u0)

(define-constant err-untransferable (err u1000))
(define-constant err-invalid-signature (err u1001))
(define-constant err-unauthorized (err u1002))

(define-public
  (mint
    (message (buff 32))
    (signature (buff 65))
    (recipient principal)
  )
  (let 
    (
      (id (+ (var-get last-id) u1))
      (key (unwrap! (secp256k1-recover? message signature) err-invalid-signature))
    )
    (asserts! (is-eq key public-key) err-unauthorized)
    (try! (nft-mint? building-on-bitcoin id recipient))
    (ok (var-set last-id id))
  )
)

(define-public
  (transfer
    (id uint)
    (sender principal)
    (recipient principal)
  )
  err-untransferable
)

(define-read-only (get-last-token-id) 
  (ok (var-get last-id))
)

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? building-on-bitcoin id))
)

(define-read-only (get-token-uri (id uint)) 
  (ok (some "ipfs://bafkreibv3xyy33ei45a5nyaidufdtk5vo4tmg6sscrcnxxnkfv6anm3jma"))
)
