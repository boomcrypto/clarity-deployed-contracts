;; wrap the native STX token into an SRC20 compatible token to be usable along other tokens
(impl-trait 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.sip-010-v0a.ft-trait)


(define-constant PERMISSION_DENIED_ERROR u403)

(define-data-var deployer-principal principal tx-sender)

;; get the token balance of owner
(define-read-only (get-balance-of (owner principal))
  (begin
    (ok (print (stx-get-balance owner)))
  )
)

(define-read-only (get-total-supply)
  (ok stx-liquid-supply)
)

;; returns the token name
(define-read-only (get-name)
  (ok "wSTX")
)

(define-read-only (get-symbol)
  (ok "wSTX")
)

;; the number of decimals used
(define-read-only (get-decimals)
  (ok u6)
)

;; Variable for URI storage
(define-data-var uri (string-utf8 256) u"https://swapr.finance/tokens/stx.json")

;; Public getter for the URI
(define-read-only (get-token-uri)
  (ok (some (var-get uri))))


;; Setter for the URI - only the owner can set it
(define-public (set-token-uri (updated-uri (string-utf8 256)))
  (begin
    (asserts! (is-eq tx-sender (var-get deployer-principal)) (err PERMISSION_DENIED_ERROR))
    ;; Print the action for any off chain watchers
    (print { action: "set-token-uri", updated-uri: updated-uri })
    (ok (var-set uri updated-uri))))


;; Transfers tokens to a recipient
(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err u255)) ;; too strict?
    (stx-transfer? amount tx-sender recipient)
  )
)
