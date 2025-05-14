---
title: "Trait wBTC"
draft: true
---
```
;; wBTC SIP-010 Fungible Token Contract

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TOKEN METADATA CONSTANTS
(define-constant token-name    "wBTC")
(define-constant token-symbol  "wBTC")
(define-constant token-decimals u8)

;; DYNAMIC TOKEN URI: defaults to none (empty)
(define-data-var token-uri (optional (string-utf8 256)) none)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; STATE VARIABLES
(define-data-var total-supply uint u0)
(define-map balances {account: principal} uint)
;; Operator map for minting (and metadata update) authorization.
(define-map operators {operator: principal} bool)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ERROR CODES
(define-constant err-insufficient-balance u100)
(define-constant err-unauthorized           u101)
(define-constant err-mint-unauthorized      u102)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CONTRACT OWNER
(define-constant contract-owner 'SP3PMNSRKWYJ48XZXPZC8KCH01Z2TK7MB03BD3SNV)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; HELPER FUNCTIONS

;; Check if caller is an approved operator or the contract owner.
(define-read-only (can-mint (caller principal))
  (or (is-eq caller contract-owner)
      (default-to false (map-get? operators {operator: caller})))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SIP-010 FUNCTIONS

;; TRANSFER FUNCTION
(define-public (transfer (sender principal) (recipient principal) (amount uint))
  (if (is-eq tx-sender sender)
      (let ((sender-balance (default-to u0 (map-get? balances {account: sender}))))
        (if (>= sender-balance amount)
            (begin
              ;; Deduct from sender.
              (map-set balances {account: sender} (- sender-balance amount))
              ;; Credit to recipient.
              (let ((recipient-balance (default-to u0 (map-get? balances {account: recipient}))))
                (map-set balances {account: recipient} (+ recipient-balance amount))
              )
              (print {event: "transfer", sender: sender, recipient: recipient, amount: amount})
              (ok true)
            )
            (err err-insufficient-balance)
        )
      )
      (err err-unauthorized)
  )
)

;; GET-BALANCE FUNCTION
(define-read-only (get-balance (account principal))
  (default-to u0 (map-get? balances {account: account}))
)

;; GET-TOTAL-SUPPLY FUNCTION
(define-read-only (get-total-supply)
  (var-get total-supply)
)

;; GET-METADATA FUNCTION
(define-read-only (get-metadata)
  (ok {
    name: token-name,
    symbol: token-symbol,
    decimals: token-decimals,
    token-uri: (var-get token-uri)
  })
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; OPERATOR MANAGEMENT FUNCTIONS

;; add-operator: Only the contract owner can add an operator.
(define-public (add-operator (operator principal))
  (if (is-eq tx-sender contract-owner)
      (begin
        (map-set operators {operator: operator} true)
        (print {event: "add-operator", operator: operator})
        (ok {operator: operator, added: true})
      )
      (err err-unauthorized)
  )
)

;; remove-operator: Only the contract owner can remove an operator.
(define-public (remove-operator (operator principal))
  (if (is-eq tx-sender contract-owner)
      (begin
        (map-delete operators {operator: operator})
        (print {event: "remove-operator", operator: operator})
        (ok {operator: operator, removed: true})
      )
      (err err-unauthorized)
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MINT FUNCTION

;; mint: Only the contract owner or an approved operator can mint new tokens.
(define-public (mint (recipient principal) (amount uint))
  (if (can-mint tx-sender)
      (begin
        (let ((current-balance (default-to u0 (map-get? balances {account: recipient}))))
          (map-set balances {account: recipient} (+ current-balance amount))
        )
        (var-set total-supply (+ (var-get total-supply) amount))
        (print {event: "mint", minter: tx-sender, recipient: recipient, amount: amount})
        (ok true)
      )
      (err err-mint-unauthorized)
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SET-TOKEN-URI FUNCTION

;; set-token-uri: Allows authorized operators to update the token URI.
(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
  (if (can-mint tx-sender)
      (begin
        (var-set token-uri new-uri)
        (print {event: "set-token-uri", setter: tx-sender, new-uri: new-uri})
        (ok new-uri)
      )
      (err err-unauthorized)
  )
)

```
