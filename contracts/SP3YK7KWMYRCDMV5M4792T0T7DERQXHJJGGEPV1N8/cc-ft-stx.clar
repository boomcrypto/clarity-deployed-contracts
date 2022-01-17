;; cc-ft-stx
;;  wrap the native STX token into an SRC20 compatible token to be usable along other tokens
;; Use https://explorer.stacks.co/txid/SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-10-ft-standard
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-10-ft-standard.ft-trait)

;; constants
;;

;; data maps and vars
;;

;; private functions
;;

;; public functions
;;

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
  (ok "STX")
)

(define-read-only (get-symbol)
  (ok "STX")
)

;; the number of decimals used
(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-token-uri)
  (ok (some u"https://swapr.finance/tokens/stx.json"))
)

;; {
;;   "name":"STX",
;;   "description":"STX token, as a SIP-010 compatible token",
;;   "image":"https://swapr.finance/tokens/stx.png",
;;   "vector":"https://swapr.finance/tokens/stx.svg"
;; }

;; update: per https://github.com/stacksgov/sips/pull/25
;; (transfer ((amount uint) (from principal) (to principal) (memo (optional (buff 34)))) (response bool uint))

;; Transfers tokens to a recipient
(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (if (>= (stx-get-balance sender) amount)
    (begin
      (asserts! (is-eq tx-sender sender) (err u255)) ;; too strict?
      (stx-transfer? amount sender recipient))
    (err u0))
)
