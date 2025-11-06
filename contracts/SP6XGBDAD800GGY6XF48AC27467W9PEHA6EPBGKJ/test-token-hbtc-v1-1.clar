(impl-trait .sip-010-trait.sip-010-trait)

;; Defines the test hBTC token according to the SIP010 Standard
(define-fungible-token test-hBTC-v1-1)

(define-constant ERR_NOT_AUTHORIZED (err u100001))
(define-constant token-decimals u8)

;;-------------------------------------
;; Const and vars
;;-------------------------------------

(define-data-var token-uri (string-utf8 256) u"")
(define-data-var token-name (string-ascii 32) "Test Hermetica hBTC v1.1")
(define-data-var token-symbol (string-ascii 32) "test-hBTC-v1-1")

;;-------------------------------------
;; SIP-010
;;-------------------------------------

(define-read-only (get-total-supply)
  (ok (ft-get-supply test-hBTC-v1-1))
)

(define-read-only (get-name)
  (ok (var-get token-name))
)

(define-read-only (get-symbol)
  (ok (var-get token-symbol))
)

(define-read-only (get-decimals)
  (ok token-decimals)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance test-hBTC-v1-1 account))
)

(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (or (is-eq sender tx-sender) (is-eq sender contract-caller)) ERR_NOT_AUTHORIZED)

    (match (ft-transfer? test-hBTC-v1-1 amount sender recipient)
      response (begin
        (print memo)
        (print { action: "transfer", data: { sender: tx-sender, recipient: recipient, amount: amount, block-height: burn-block-height } })
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
    (try! (contract-call? .test-hq-vaults-v1-1 check-is-owner tx-sender))
    (ok (var-set token-uri value))
  )
)

(define-public (set-token-name (name (string-ascii 32)))
  (begin
    (try! (contract-call? .test-hq-vaults-v1-1 check-is-owner tx-sender))
    (ok (var-set token-name name))
  )
)

;;-------------------------------------
;; Mint / Burn
;;-------------------------------------

;; Mint method
(define-public (mint-for-protocol (amount uint) (recipient principal))
  (begin
    (try! (contract-call? .test-hq-vaults-v1-1 check-is-vault contract-caller))
    (ft-mint? test-hBTC-v1-1 amount recipient)
  )
)

;; Burn method
(define-public (burn-for-protocol (amount uint) (sender principal))
  (begin
    (try! (contract-call? .test-hq-vaults-v1-1 check-is-vault contract-caller))
    (ft-burn? test-hBTC-v1-1 amount sender)
  )
)

;; Burn external
(define-public (burn (amount uint))
  (ft-burn? test-hBTC-v1-1 amount tx-sender)
)
