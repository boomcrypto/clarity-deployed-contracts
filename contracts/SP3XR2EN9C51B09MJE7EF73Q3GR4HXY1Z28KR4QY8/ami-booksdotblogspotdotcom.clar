(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token Amigo uint)

(define-public (transfer (token uint) (sender principal) (recipient principal))
  (err u1)
)

(define-read-only (get-owner (token uint))
  (ok (nft-get-owner? Amigo token))
)

(define-read-only (get-last-token-id)
  (ok u1)
)

(define-read-only (get-token-uri (token uint))
  (ok none)
)

(try! (nft-mint? Amigo u1 'SP2AS4QCQ81PJQ5HE3TJ6AJ554QX2YK14MFHT2VRS))