;; cc-sip010-stx-v1
;;  wrap the native STX token into an SRC20 compatible token to be usable along other tokens
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
;;(impl-trait 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.sip-010-trait.sip-010-trait)

;; constants
(define-constant ERR_INSUFFICIENT_FUNDS u101)
(define-constant ERR_PERMISSION_DENIED u109)

;; public functions
;;

;; get the token balance of owner
(define-read-only (get-balance (owner principal))
  (begin
    (ok (print (stx-get-balance owner)))
  )
)

(define-read-only (get-total-supply)
  (ok stx-liquid-supply)
)

;; returns the token name
(define-read-only (get-name)
  (ok "Stacks")
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

;; Transfers tokens to a recipient
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (>= (stx-get-balance sender) amount)
    (begin
      (asserts! (is-eq tx-sender sender) (err ERR_PERMISSION_DENIED))
      (if (is-some memo)
          (print memo)
          none
      )
      (try! (stx-transfer? amount sender recipient))
      (ok true)
    )
  (err ERR_INSUFFICIENT_FUNDS))
)

;; readonly functions
;;
;; all the data relevant to the stx token owned
(define-read-only (get-data (owner principal))
  (ok {
    name: (unwrap-panic (get-name)),
    symbol: (unwrap-panic (get-symbol)),
    decimals: (unwrap-panic (get-decimals)),
    uri: (unwrap-panic (get-token-uri)),
    supply: (unwrap-panic (get-total-supply)),
    balance: (unwrap-panic (get-balance owner))
  })
)