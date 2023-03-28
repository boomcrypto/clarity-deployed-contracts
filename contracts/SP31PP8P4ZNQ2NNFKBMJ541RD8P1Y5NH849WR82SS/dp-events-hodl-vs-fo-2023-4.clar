(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token droplinked-events-attendance uint)

(define-constant public-key 0x02ba68bdbd0c67701f62908d01d08c887d90eccb791ac2e028f475b58f8a76e472)

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
    (try! (nft-mint? droplinked-events-attendance id recipient))
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
  (ok (nft-get-owner? droplinked-events-attendance id))
)

(define-read-only (get-token-uri (id uint)) 
  (ok (some "ipfs://QmUc9PMoYcbSC7qM574eYdiXL2G5Zz21xY2By4qeg1V8C9"))
)