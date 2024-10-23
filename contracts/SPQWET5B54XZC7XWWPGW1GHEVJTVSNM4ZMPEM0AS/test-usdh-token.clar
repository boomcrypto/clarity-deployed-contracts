(impl-trait .sip-010-trait.sip-010-trait)

;; Defines the USDh token according to the SIP010 Standard
(define-fungible-token usdh)

(define-constant ERR_NOT_AUTHORIZED u1401)

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var token-uri (string-utf8 256) u"")

;;-------------------------------------
;; SIP-010 
;;-------------------------------------

(define-read-only (get-total-supply)
  (ok (ft-get-supply usdh))
)

(define-read-only (get-name)
  (ok "Hermetica USDh Token")
)

(define-read-only (get-symbol)
  (ok "USDh")
)

(define-read-only (get-decimals)
  (ok u8)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance usdh account))
)

(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR_NOT_AUTHORIZED))

    (match (ft-transfer? usdh amount sender recipient)
      response (begin
        (print memo)
        (print { action: "transfer", data: { sender: tx-sender, recipient: recipient, amount: amount, block-height: block-height } })
        (ok response)
      )
      error (err error)
    )
  )
)

;;-------------------------------------
;; Admin
;;-------------------------------------

(define-public (set-token-uri (value (string-utf8 256)))
  (begin
    (try! (contract-call? .test-hq check-is-admin tx-sender))
    (ok (var-set token-uri value))
  )
)

;;-------------------------------------
;; Mint / Burn
;;-------------------------------------

;; Mint method
(define-public (mint-for-protocol (amount uint) (recipient principal))
  (begin
    (try! (contract-call? .test-hq check-is-minting-contract contract-caller))
    (ft-mint? usdh amount recipient)
  )
)

;; Burn method
(define-public (burn-for-protocol (amount uint) (sender principal))
  (begin
    (try! (contract-call? .test-hq check-is-minting-contract contract-caller))
    (ft-burn? usdh amount sender)
  )
)

;; Burn external
(define-public (burn (amount uint))
  (ft-burn? usdh amount tx-sender)
)