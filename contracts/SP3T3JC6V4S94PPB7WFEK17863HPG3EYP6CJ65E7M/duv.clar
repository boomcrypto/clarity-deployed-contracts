;; Implement the `ft-trait` trait defined in the `ft-trait` contract
(impl-trait 'SP17K2W1JCPWJ07X84KSE3QT0QB6KPPBXCC31BX2T.ft-trait.ft-trait)

(define-fungible-token duv u21000000000000)
(define-constant err-unauthorized u1)

;; Mint Tokens
(define-constant minter 'SP3T3JC6V4S94PPB7WFEK17863HPG3EYP6CJ65E7M)
(ft-mint? duv u21000000000000 minter) ;; Derupt

(define-read-only (get-total-supply)
  (ok (ft-get-supply duv))
)

(define-read-only (get-name)
  (ok "DUV")
)

(define-read-only (get-symbol)
  (ok "DUV")
)

(define-read-only (get-decimals)
  (ok u0)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance duv account))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (is-eq tx-sender sender)
    (begin
      (try! (ft-transfer? duv amount sender recipient))
      (print memo)
      (ok true)
    )
   (err u4)))

(define-read-only (get-token-uri)
  (ok (some u"https://cryptocracy.io/assets/duv.json"))
)