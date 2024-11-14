(impl-trait .sip-010-trait.sip-010-trait)

;; Defines the sUSDh token according to the SIP010 Standard
(define-fungible-token susdh)

(define-constant ERR_NOT_AUTHORIZED u1501)
(define-constant ERR_ONLY_PROTOCOL u1502)

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var token-uri (string-utf8 256) u"")

(define-data-var blacklist-enabled bool false)
(define-data-var only-protocol bool false)
(define-data-var counter uint u0)

;;-------------------------------------
;; SIP-010 
;;-------------------------------------

(define-read-only (get-total-supply)
  (ok (ft-get-supply susdh))
)

(define-read-only (get-name)
  (ok "Hermetica sUSDh Token")
)

(define-read-only (get-symbol)
  (ok "sUSDh")
)

(define-read-only (get-decimals)
  (ok u8)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance susdh account))
)

(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

(define-read-only (get-blacklist-enabled)
  (var-get blacklist-enabled)
)

(define-read-only (get-only-protocol)
  (var-get only-protocol)
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR_NOT_AUTHORIZED))

    (if (var-get only-protocol) 
      (asserts! (or (contract-call? .test-hq get-contract-active sender) (contract-call? .test-hq get-contract-active recipient)) (err ERR_ONLY_PROTOCOL))
      true
    )

    (if (var-get blacklist-enabled)
      (try! (contract-call? .test-blacklist-susdh check-is-not-full-blacklist-two sender recipient))
      true
    )

    (match (ft-transfer? susdh amount sender recipient)
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

(define-public (enable-blacklist)
  (begin
    (try! (contract-call? .test-hq check-is-protocol tx-sender))
    (asserts! (< (var-get counter) u1) (err ERR_NOT_AUTHORIZED))
    (var-set counter u1)
    (ok (var-set blacklist-enabled true))
  )
)

(define-public (disable-blacklist)
  (begin
    (try! (contract-call? .test-hq check-is-protocol tx-sender))
    (asserts! (< (var-get counter) u2) (err ERR_NOT_AUTHORIZED))
    (var-set counter u2)
    (ok (var-set blacklist-enabled false))
  )
)

(define-public (set-only-protocol (value bool))
  (begin
    (try! (contract-call? .test-hq check-is-protocol tx-sender))
    (ok (var-set only-protocol value))
  )
)

;;-------------------------------------
;; Mint / Burn
;;-------------------------------------

;; Mint method
(define-public (mint-for-protocol (amount uint) (recipient principal))
  (begin
    (try! (contract-call? .test-hq check-is-minting-contract contract-caller))
    (ft-mint? susdh amount recipient)
  )
)

;; Burn method
(define-public (burn-for-protocol (amount uint) (sender principal))
  (begin
    (try! (contract-call? .test-hq check-is-minting-contract contract-caller))
    (ft-burn? susdh amount sender)
  )
)