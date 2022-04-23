(impl-trait 'SP26RS42R5ZH10VWWG4HFYPRJRC3JJ3FKWY4V58CW.sip-010-trait.sip-010-trait)

;; define TRAKLIST UTILITY COIN
(define-fungible-token TRAKLIST-UTILITY-COIN)

;; read only functions
(define-read-only (get-balance (owner principal))
  (begin
    (ok (ft-get-balance TRAKLIST-UTILITY-COIN owner))))

(define-read-only (get-total-supply)
  (ok (ft-get-supply TRAKLIST-UTILITY-COIN)))

(define-read-only (get-name)
  (ok "TRAKLIST UTILITY COIN"))

(define-read-only (get-symbol)
  (ok "TUC"))

(define-read-only (get-decimals)
  (ok u8))

;; public functions
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (is-eq tx-sender sender)
    (begin
      (try! (ft-transfer? TRAKLIST-UTILITY-COIN amount sender recipient))
      (print memo)
      (ok true)
    )
    (err u4)))

(define-public (get-token-uri)
  (ok (some u"https://tsb.media/economy/traklist-utility-coin")))


;; TRAKLIST UTILITY COIN mint
(ft-mint? TRAKLIST-UTILITY-COIN u333333333333333 'SP26RS42R5ZH10VWWG4HFYPRJRC3JJ3FKWY4V58CW)