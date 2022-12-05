(impl-trait .googlier-swap-trait-v1.swap-trait)

(define-fungible-token wstx-usd)

(define-constant ERR-NOT-AUTHORIZED u21401)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))

    (match (ft-transfer? wstx-usd amount sender recipient)
      response (begin
        (print memo)
        (ok response)
      )
      error (err error)
    )
  )
)

(define-read-only (get-name)
  (ok "googlier V1 wSTX USD LP Token")
)

(define-read-only (get-symbol)
  (ok "ARKV1WSTXUSD")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance wstx-usd owner))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply wstx-usd))
)

(define-read-only (get-token-uri)
  (ok (some u"https://googlier.finance/tokens/wstx-usd-token.json"))
)
;; {
;;   "name":"wSTX-USD",
;;   "description":"wSTX-USD googlier LP token",
;;   "image":"url",
;;   "vector":"url"
;; }

;; one stop function to gather all the data relevant to the LP token in one call
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

;; the extra mint method used when adding liquidity
;; can only be used by googlier swap main contract
(define-public (mint (recipient principal) (amount uint))
  (begin
    (print "googlier-token-swap.mint")
    (print contract-caller)
    (print amount)

    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .googlier-dao get-qualified-name-by-name "swap"))) (err ERR-NOT-AUTHORIZED))
    (ft-mint? wstx-usd amount recipient)
  )
)


;; the extra burn method used when removing liquidity
;; can only be used by googlier swap main contract
(define-public (burn (recipient principal) (amount uint))
  (begin
    (print "googlier-token-swap.burn")
    (print contract-caller)
    (print amount)

    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .googlier-dao get-qualified-name-by-name "swap"))) (err ERR-NOT-AUTHORIZED))
    (ft-burn? wstx-usd amount recipient)
  )
)


;; Test environments
(begin
  ;; TODO: do not do this on testnet or mainnet
  (try! (ft-mint? wstx-usd u100000000 'SP32X8J03KE3FDJAKN2JR9CQZGW8A517AFAYA217))
)
