(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token Phryge)

(define-constant contract-sender tx-sender)

(define-map receiver-users principal bool)

(define-read-only (get-balance (address principal))
  (ok (ft-get-balance Phryge address)))

(define-read-only (get-total-supply)
  (ok (ft-get-supply Phryge)))

(define-read-only (get-name)
  (ok "Olympic Phryge"))

(define-read-only (get-symbol)
  (ok "Phryge"))

(define-read-only (get-decimals)
  (ok u6))

(define-read-only (get-token-uri)
  (ok (some u"https://ipfs.io/ipfs/QmXhvRVBUnerdxd1cBTThivcY9aazQ899bQDyhWRz7UMeR")))

(define-public (transfer (amount uint) (sender principal) (receiver principal) (memo (optional (buff 34))))
  (begin
        (asserts! (is-eq tx-sender sender) (err u101))
        (asserts! (is-eq (default-to false (map-get? receiver-users sender)) true) (err u101))
        (try! (ft-transfer? Phryge amount sender receiver))
        (match memo to-print (print to-print) 0x)
        (ok true)
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
    (ft-burn? Phryge count tx-sender))

(begin
  (map-set receiver-users tx-sender true)
  (try! (ft-mint? Phryge u69420000000000000 tx-sender))
)