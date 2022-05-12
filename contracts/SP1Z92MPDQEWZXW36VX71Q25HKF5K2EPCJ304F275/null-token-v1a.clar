;; wrap the native STX token into an SRC20 compatible token to be usable along other tokens
(impl-trait .sip-010-v1a.sip-010-trait)

;; STSW_TOKEN ERRORS 4226~4229
(define-constant PERMISSION_DENIED_ERROR u4225)

(define-data-var deployer-principal principal tx-sender)

;; get the token balance of owner
(define-read-only (get-balance (owner principal))
  (begin
    (ok u0)
  )
)

(define-read-only (get-total-supply)
  (ok u0)
)

;; returns the token name
(define-read-only (get-name)
  (ok "NULL")
)

(define-read-only (get-symbol)
  (ok "NULL")
)

;; the number of decimals used
(define-read-only (get-decimals)
  (ok u6)
)

;; Variable for URI storage
(define-data-var uri (string-utf8 256) u"")

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

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (match memo to-print (print to-print) 0x)
    (err u0)
  )
)