;;;;;;;;;;;;;;;;;;;;; SIP 010 ;;;;;;;;;;;;;;;;;;;;;;
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(impl-trait .admin-token-traits.admin-token-trait)

;; Defines the StacksOcean Coin according to the SIP-010 Standard
(define-fungible-token stacksocean-coin u1000000000000000)

(define-data-var token-uri (string-utf8 256) u"")
(define-constant contract-owner tx-sender)

;; errors
(define-constant ERR-NOT-AUTHORIZED u14401)

;; ---------------------------------------------------------
;; SIP-10 Functions
;; ---------------------------------------------------------

(define-read-only (get-total-supply)
  (ok (ft-get-supply stacksocean-coin))
)

(define-read-only (get-name)
  (ok "StacksOcean Coin")
)

(define-read-only (get-symbol)
  (ok "STO")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance stacksocean-coin account))
)

(define-public (set-token-uri (value (string-utf8 256)))
  (if (is-eq tx-sender contract-owner)
    (ok (var-set token-uri value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))

    (match (ft-transfer? stacksocean-coin amount sender recipient)
      response (begin
        (print memo)
        (ok response)
      )
      error (err error)
    )
  )
)

;;Mint
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (or (is-eq contract-caller contract-owner) (is-eq contract-caller (as-contract tx-sender))) (err ERR-NOT-AUTHORIZED))
    (ft-mint? stacksocean-coin amount recipient)
  )
)

;; Burn external 
(define-public (burn (amount uint) (sender principal))
  (begin
      (asserts! (is-eq contract-caller contract-owner) (err ERR-NOT-AUTHORIZED))
      (ft-burn? stacksocean-coin amount sender)
    )
)