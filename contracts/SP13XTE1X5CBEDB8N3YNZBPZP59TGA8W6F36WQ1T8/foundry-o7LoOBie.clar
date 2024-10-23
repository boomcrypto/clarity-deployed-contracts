;; Deploy with Foundry by Hashhavoc

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(define-constant ERR-UNAUTHORIZED u401)
(define-constant ERR-NOT-OWNER u402)
(define-constant ERR-INVALID-PARAMS u400)
(define-constant ERR-NOT-ENOUGH-FUND u101)
(define-constant MAXSUPPLY u1000000000)
(define-fungible-token TRUST MAXSUPPLY)
(define-data-var contract-owner principal tx-sender)
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://gaia.hiro.so/hub/1CeGshGARobRNQHTVjThpDcWu5UtLNkEG7/53505c57-e122-4dfe-904a-c9de458cf481-metadata.json"))
(define-data-var token-name (string-ascii 32) "Trust Me Bro")
(define-data-var token-symbol (string-ascii 32) "TRUST")
(define-data-var token-decimals uint u6)

(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance TRUST owner))
)

(define-read-only (get-name)
  (ok "Trust Me Bro")
)

(define-read-only (get-symbol)
  (ok "TRUST")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply TRUST))
)

(define-read-only (get-token-uri)
  (ok (var-get token-uri))
)

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq from tx-sender) (err ERR-UNAUTHORIZED))
    (asserts! (> amount u0) (err ERR-INVALID-PARAMS))
    (asserts! (>= (ft-get-balance TRUST from) amount) (err ERR-NOT-ENOUGH-FUND))
    (asserts! (not (is-eq from to)) (err ERR-INVALID-PARAMS))
    (let ((result (ft-transfer? TRUST amount from to)))
      (print
        {
          event: "transfer",
          from: from,
          to: to,
          amount: amount,
          memo: memo
        }
      )
      result
    )
  )
)

(define-public
  (set-metadata
    (uri (optional (string-utf8 256)))
    (name (string-ascii 32))
    (symbol (string-ascii 32))
    (decimals uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-UNAUTHORIZED))
    (asserts!
      (and
        (is-some uri)
        (> (len name) u0)
        (> (len symbol) u0)
        (<= decimals u18))
      (err ERR-INVALID-PARAMS))
    (var-set token-uri uri)
    (var-set token-name name)
    (var-set token-symbol symbol)
    (var-set token-decimals decimals)
    (print
      {
        event: "token-metadata-update",
        uri: uri,
        name: name,
        symbol: symbol,
        decimals: decimals
      }
    )
    (ok true)
  )
)

(define-public (send-many (recipients (list 200 { to: principal, amount: uint, memo: (optional (buff 34)) })))
  (begin
    (asserts! (<= (len recipients) u200) (err ERR-INVALID-PARAMS))
    (fold check-err (map send-token recipients) (ok true))
  )
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

(define-private (send-token (recipient { to: principal, amount: uint, memo: (optional (buff 34)) }))
  (begin
    (asserts! (> (get amount recipient) u0) (err ERR-INVALID-PARAMS))
    (send-token-with-memo (get amount recipient) (get to recipient) (get memo recipient))
  )
)

(define-private (send-token-with-memo (amount uint) (to principal) (memo (optional (buff 34))))
  (let ((transferOk (try! (transfer amount tx-sender to memo))))
    (ok transferOk)
  )
)

(define-private (send-stx (recipient principal) (amount uint))
  (begin
    (asserts! (> amount u0) (err ERR-INVALID-PARAMS))
    (try! (stx-transfer? amount tx-sender (as-contract recipient)))
    (ok true)
  )
)

(define-public (transfer-ownership (new-owner principal))
  (begin
    (if (is-eq tx-sender (var-get contract-owner))
      (begin
        (var-set contract-owner new-owner)
        (ok "transfered ownership"))
      (err ERR-NOT-OWNER)))
)

(begin
  (let ((result (ft-mint? TRUST MAXSUPPLY (var-get contract-owner))))
    (print
      {
        event: "mint",
        to: (var-get contract-owner),
        amount: MAXSUPPLY
      }
    )
    result
  )
)