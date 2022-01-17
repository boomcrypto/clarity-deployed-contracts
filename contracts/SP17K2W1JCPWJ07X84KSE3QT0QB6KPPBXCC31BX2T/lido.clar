;; Implement the `ft-trait` trait defined in the `ft-trait` contract
(impl-trait 'SP17K2W1JCPWJ07X84KSE3QT0QB6KPPBXCC31BX2T.ft-trait.ft-trait)

(define-fungible-token lido u21000000000000)
(define-constant err-unauthorized u1)

;; Mint Tokens
(define-constant minter 'SP17K2W1JCPWJ07X84KSE3QT0QB6KPPBXCC31BX2T)
(ft-mint? lido u7000000000000 minter) ;; CryptoDude
(ft-mint? lido u7000000000000 'SP23T3J3W3PTDHD5QV4A0B2DNDEMC3987W5HG0H23) ;; Teke
(ft-mint? lido u7000000000000 'SP16GEW6P7GBGZG0PXRXFJEMR3TJHJEY2HJKBP1P5) ;; Abraham

(define-read-only (get-total-supply)
  (ok (ft-get-supply lido))
)

(define-read-only (get-name)
  (ok "Lido")
)

(define-read-only (get-symbol)
  (ok "LIDO")
)

(define-read-only (get-decimals)
  (ok u0)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance lido account))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (is-eq tx-sender sender)
    (begin
      (try! (ft-transfer? lido amount sender recipient))
      (print memo)
      (ok true)
    )
   (err u4)))

(define-read-only (get-token-uri)
  (ok (some u"https://cryptocracy.io/assets/lido.json"))
)