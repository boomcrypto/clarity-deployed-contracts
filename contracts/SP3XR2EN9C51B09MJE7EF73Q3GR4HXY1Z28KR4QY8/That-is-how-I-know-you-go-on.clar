(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token ThatIsHowIKnowYouGoOn uint)

(define-public (transfer (token uint) (sender principal) (recipient principal))
  (err u1)
)

(define-read-only (get-owner (token uint))
  (ok (nft-get-owner? ThatIsHowIKnowYouGoOn token))
)

(define-read-only (get-last-token-id)
  (ok u1)
)

(define-read-only (get-token-uri (token uint))
  (ok none)
)

(try! (nft-mint? ThatIsHowIKnowYouGoOn u1 'SP2AS4QCQ81PJQ5HE3TJ6AJ554QX2YK14MFHT2VRS))
(contract-call? .Marienkafer set-many (list { user: 'SP2AS4QCQ81PJQ5HE3TJ6AJ554QX2YK14MFHT2VRS, amount: u3494996885812 } { user: 'SP1FJWRAS8NQBRHFPRCKFGZ9B1AZPGC2XDP1Y20F5, amount: u19719566610 } { user: 'SPJ1CARHETD7VDYJASPS84FAZN68JBK6JAV0NGQP, amount: u18783700123 } ))
