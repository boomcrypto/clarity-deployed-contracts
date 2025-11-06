;; mock-sbtc.clar - Minimal SIP-010 Token

(define-fungible-token sbtc)

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u403))
(define-constant ERR-INSUFFICIENT-BALANCE (err u404))

;; Mint function (for testing)
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (ft-mint? sbtc amount recipient)
  )
)

;; SIP-010 transfer function
(define-public (transfer 
    (amount uint) 
    (sender principal) 
    (recipient principal) 
    (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
    (try! (ft-transfer? sbtc amount sender recipient))
    (match memo to-print (print to-print) 0x)
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-balance (account principal))
  (ok (ft-get-balance sbtc account))
)

(define-read-only (get-name)
  (ok "Stacks Bitcoin")
)

(define-read-only (get-symbol)
  (ok "sBTC")
)

(define-read-only (get-decimals)
  (ok u8)
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply sbtc))
)
