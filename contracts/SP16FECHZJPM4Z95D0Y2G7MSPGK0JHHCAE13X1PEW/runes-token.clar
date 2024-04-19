
;; title: runes-token

;; ---------------------------------------------------------
;; SIP-10 Fungible Token Contract
;; ---------------------------------------------------------
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token runes)
(define-constant contract-owner tx-sender)

;; ---------------------------------------------------------
;; Constants/Variables
;; ---------------------------------------------------------
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://bafybeib7zxxvcrgpgbnhrevpoqqddwfuyynrmwyuoi424qeywztemi5ape.ipfs.nftstorage.link"))

;; ---------------------------------------------------------
;; Errors
;; ---------------------------------------------------------
(define-constant ERR_UNAUTHORIZED (err u100))

;; ---------------------------------------------------------
;; SIP-10 Functions
;; ---------------------------------------------------------
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) ERR_UNAUTHORIZED)
    (try! (ft-transfer? runes amount sender recipient))
    (match memo to-print (print to-print) 0x)
    (ok true)
  )
)

(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance runes owner))
)

(define-read-only (get-name)
  (ok "Runes")
)

(define-read-only (get-symbol)
  (ok "RUNES")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply runes))
)

(define-read-only (get-token-uri)
    (ok (var-get token-uri)
    )
)

(define-public (set-token-uri (value (string-utf8 256)))
  (if (is-eq tx-sender contract-owner)
    (ok (var-set token-uri (some value)))
    (err ERR_UNAUTHORIZED)
  )
)

;; ---------------------------------------------------------
;; Utility Functions
;; ---------------------------------------------------------
(define-public (send-many (recipients (list 1000 { to: principal, amount: uint, memo: (optional (buff 34)) })))
  (fold check-err (map send-token recipients) (ok true))
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

(define-private (send-token (recipient { to: principal, amount: uint, memo: (optional (buff 34)) }))
  (send-token-with-memo (get amount recipient) (get to recipient) (get memo recipient))
)

(define-private (send-token-with-memo (amount uint) (to principal) (memo (optional (buff 34))))
  (let ((transferOk (try! (transfer amount tx-sender to memo))))
    (ok transferOk)
  )
)

;; ---------------------------------------------------------
;; Mint
;; ---------------------------------------------------------
(begin
  (try! (ft-mint? runes u5000000000000000 'SP2BY7VA98TKRANS3BG7MSZMJYTVYY5HP8E5JN5X6))
  (try! (ft-mint? runes u4500000000000000 'SP28K5CWHAXR096XJ6ZS25717SXS8175FRQXY77DM))
  (try! (ft-mint? runes u500000000000000 'SP2FE6FQ3GK9DCXTP5QFFJC5GH979NMFEF4JTMBKH))
)
