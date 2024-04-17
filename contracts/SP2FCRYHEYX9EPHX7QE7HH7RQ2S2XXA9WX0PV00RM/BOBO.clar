
;; title: bobo
;; version:
;; summary:
;; description:

;; traits
;;
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)


;; token definitions
;;

;; constants
;;
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://indigo-legal-mule-839.mypinata.cloud/ipfs/QmPFZtg5Z4n8q4xj31oYezHKnBdLGSpg34tiWAKgXUuQB9"))
(define-constant ERR-UNAUTHORIZED (err u401))
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

;; No maximum supply!
(define-fungible-token BOBO u69000000000000)

;; 
;; SIP-10
;; 

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq tx-sender sender) err-not-token-owner)
        (try! (ft-transfer? BOBO amount sender recipient))
        (match memo to-print (print to-print) 0x)
        (ok true)
    )
)

(define-read-only (get-name)
    (ok "BOBO")
)

(define-read-only (get-symbol)
    (ok "BOBO")
)

(define-read-only (get-decimals)
    (ok u0)
)

(define-read-only (get-balance (user principal))
    (ok (ft-get-balance BOBO user)
    )
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply BOBO)
    )
)

(define-public (set-token-uri (value (string-utf8 256)))
    (begin
        (asserts! (is-eq tx-sender contract-owner) ERR-UNAUTHORIZED)
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

(define-read-only (get-token-uri)
    (ok (var-get token-uri)
    )
)

;; read only functions
;;

;; private functions
;;
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

(begin
  (try! (ft-mint? BOBO u69000000000000 contract-owner))
)
