(impl-trait .sip-010-v1a.sip-010-trait)

(define-fungible-token lbtc)

(define-data-var token-uri (string-utf8 256) u"https://app.stackswap.org/token/lbtc.json")

(define-data-var is-emergency-stop-not-called bool true)


(define-constant ERR-NOT-AUTHORIZED u14401)
(define-constant ERR-EMERGENCY-STOPPED u14402)

(define-read-only (get-total-supply)
  (ok (ft-get-supply lbtc))
)

(define-read-only (get-name)
  (ok "Lucid BTC")
)

(define-read-only (get-symbol)
  (ok "LBTC")
)

(define-read-only (get-decimals)
  (ok u8)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance lbtc account))
)

(define-read-only (get-emergency-stop)
  (ok (var-get is-emergency-stop-not-called))
)

(define-public (set-token-uri (value (string-utf8 256)))
  (if (is-eq contract-caller (contract-call? .stackswap-dao-v5k get-dao-owner))
    (ok (var-set token-uri value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-emergency-stop (value bool))
  (if (is-eq contract-caller (contract-call? .stackswap-dao-v5k get-dao-owner))
    (ok (var-set is-emergency-stop-not-called value))
    (err ERR-NOT-AUTHORIZED)
  )
)


(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (var-get is-emergency-stop-not-called) (err ERR-EMERGENCY-STOPPED))
    (match (ft-transfer? lbtc amount sender recipient)
      response (begin
        (print memo)
        (ok response)
      )
      error (err error)
    )
  )
)


(define-public (mint-for-dao (amount uint) (recipient principal))
  (begin
    (asserts! 
      (or
        (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "mortgager")))
        (or 
          (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stx-reserve")))
          (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "sip10-reserve")))
        )
       )
     (err ERR-NOT-AUTHORIZED))
    (asserts! (var-get is-emergency-stop-not-called) (err ERR-EMERGENCY-STOPPED))
    (ft-mint? lbtc amount recipient)
  )
)

(define-public (burn-for-dao (amount uint) (sender principal))
  (begin
    (asserts! 
      (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "mortgager")))
      (err ERR-NOT-AUTHORIZED))
    (asserts! (var-get is-emergency-stop-not-called) (err ERR-EMERGENCY-STOPPED))
    (ft-burn? lbtc amount sender)
  )
)

(define-public (revoke-for-dao (amount uint) (sender principal) (recipient principal))
  (begin
    (asserts! 
      (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "lbtc-revoker")))
      (err ERR-NOT-AUTHORIZED))
    (try! (ft-burn? lbtc amount sender))
    (ft-mint? lbtc amount recipient)
  )
)


