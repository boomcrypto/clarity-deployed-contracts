;; Implement the `ft-trait` trait defined in the `ft-trait` contract
(impl-trait .ft-trait.sip-010-trait)

(define-fungible-token albondigas-token)

;; get the token balance of owner
(define-read-only (get-balance (owner principal))
  (begin
    (ok (ft-get-balance albondigas-token owner))))

;; returns the total number of tokens
(define-read-only (get-total-supply)
  (ok (ft-get-supply albondigas-token)))

;; returns the token name
(define-read-only (get-name)
  (ok "Albondigas Token"))

;; the symbol or "ticker" for this token
(define-read-only (get-symbol)
  (ok "ALBONDIGAS"))

;; the number of decimals used
(define-read-only (get-decimals)
  (ok u8))

;; Transfers tokens to a recipient
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (is-eq tx-sender sender)
    (begin
      (try! (ft-transfer? albondigas-token amount sender recipient))
      (print memo)
      (ok true)
    )
    (err u4)))

(define-public (get-token-uri)
  (ok (some u"https://cafe-society.news/albondigas")))

;; Mint this token to a few people when deployed
(ft-mint? albondigas-token u1000000000000 'SP2A82Q7YZJBKKT6BHD5JXPVZZ9WDRA9AAFTNZGE1)
