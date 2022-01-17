;; cc-sip010-stx
;;  wrap the native STX token into an SRC20 compatible token to be usable along other tokens
;; Use https://explorer.stacks.co/txid/SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait.sip-010-trait)

;; constants
(define-constant ERR_INSUFFICIENT_FUNDS u1)
(define-constant ERR_PERMISSION_DENIED u9)

;; get the token balance of owner
(define-read-only (balance-of (owner principal))
  (begin
    (ok (print (stx-get-balance owner)))
  )
)

(define-read-only (total-supply)
  (ok stx-liquid-supply)
)

;; returns the token name
(define-read-only (name)
  (ok "Stacks")
)

(define-read-only (symbol)
  (ok "STX")
)

;; the number of decimals used
(define-read-only (decimals)
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

;; Transfers tokens to a recipient
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (>= (stx-get-balance sender) amount)
    (begin
      (asserts! (is-eq tx-sender sender) (err ERR_PERMISSION_DENIED))
      (if (is-some memo)
          (print memo)
          none
      )
      (stx-transfer? amount sender recipient))
  (err ERR_INSUFFICIENT_FUNDS))
)

;;
;; all the data relevant to the stx token owned
(define-read-only (get-data (owner principal))
  (ok {
    name: (unwrap-panic (name)),
    symbol: (unwrap-panic (symbol)),
    decimals: (unwrap-panic (decimals)),
    uri: (unwrap-panic (get-token-uri)),
    supply: (unwrap-panic (total-supply)),
    balance: (unwrap-panic (balance-of owner))
  })
)