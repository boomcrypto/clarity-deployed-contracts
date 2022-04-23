;; Implement the `ft-trait` trait defined in the `ft-trait` contract
(impl-trait 'SP26RS42R5ZH10VWWG4HFYPRJRC3JJ3FKWY4V58CW.sip-010-trait.sip-010-trait)

(define-fungible-token TRAKLIST-UTILITY-COIN-TEST)

;; get the token balance of owner
(define-read-only (get-balance (owner principal))
  (begin
    (ok (ft-get-balance TRAKLIST-UTILITY-COIN-TEST owner))))

;; returns the total number of tokens
(define-read-only (get-total-supply)
  (ok (ft-get-supply TRAKLIST-UTILITY-COIN-TEST)))

;; returns the token name
(define-read-only (get-name)
  (ok "TUCT"))

;; the symbol or "ticker" for this token
(define-read-only (get-symbol)
  (ok "TUCT"))

;; the number of decimals used
(define-read-only (get-decimals)
  (ok u8))

;; Transfers tokens to a recipient
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (is-eq tx-sender sender)
    (begin
      (try! (ft-transfer? TRAKLIST-UTILITY-COIN-TEST amount sender recipient))
      (print memo)
      (ok true)
    )
    (err u4)))

(define-public (get-token-uri)
  (ok (some u"https://example.com")))

;; Mint this token to a few people when deployed
(ft-mint? TRAKLIST-UTILITY-COIN-TEST u333333333333333 'SP26RS42R5ZH10VWWG4HFYPRJRC3JJ3FKWY4V58CW)