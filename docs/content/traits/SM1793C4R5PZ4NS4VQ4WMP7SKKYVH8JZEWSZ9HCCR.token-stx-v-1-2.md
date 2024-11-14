---
title: "Trait token-stx-v-1-2"
draft: true
---
```

;; token-stx-v-1-2

;; Implement SIP 010 trait
(impl-trait .sip-010-trait-ft-standard-v-1-1.sip-010-trait)

;; Error constants
(define-constant ERR_NOT_AUTHORIZED_SIP_010 (err u4))
(define-constant ERR_INVALID_PRINCIPAL_SIP_010 (err u5))
(define-constant ERR_NOT_AUTHORIZED (err u5001))
(define-constant ERR_INVALID_AMOUNT (err u5002))
(define-constant ERR_INVALID_PRINCIPAL (err u5003))
(define-constant ERR_INVALID_TOKEN_URI (err u5004))

;; Uri for this token 
(define-data-var token-uri (string-utf8 256) u"")

;; Contract owner defined as a var
(define-data-var contract-owner principal tx-sender)

;; SIP 010 function to get token name
(define-read-only (get-name)
    (ok "Stacks")
)

;; SIP 010 function to get token symbol
(define-read-only (get-symbol)
    (ok "STX")
)

;; SIP 010 function to get token decimals
(define-read-only (get-decimals)
    (ok u6)
)

;; SIP 010 function to get total token supply
(define-read-only (get-total-supply)
    (ok stx-liquid-supply)
)

;; SIP 010 function to get token balance for an address
(define-read-only (get-balance (address principal))
    (ok (stx-get-balance address))
)

;; Get current token uri
(define-read-only (get-token-uri)
    (ok (some (var-get token-uri)))
)

;; Get current contract owner
(define-read-only (get-contract-owner)
    (ok (var-get contract-owner))
)

;; Set token uri
(define-public (set-token-uri (uri (string-utf8 256)))
    (let (
    (caller tx-sender)
    )
    (begin
        ;; Assert that caller is contract-owner and uri length is greater than 0
        (asserts! (is-eq caller (var-get contract-owner)) ERR_NOT_AUTHORIZED)
        (asserts! (> (len uri) u0) ERR_INVALID_TOKEN_URI)
        (var-set token-uri uri)

        ;; Print function data and return true
        (print {action: "set-token-uri", caller: caller, data: {uri: uri}})
        (ok true)
    )
    )
)

;; Set contract owner
(define-public (set-contract-owner (address principal))
    (let (
    (caller tx-sender)
    )
    (begin
        ;; Assert that caller is contract-owner
        (asserts! (is-eq caller (var-get contract-owner)) ERR_NOT_AUTHORIZED)
        (asserts! (is-standard address) ERR_INVALID_PRINCIPAL)
        (var-set contract-owner address)

        ;; Print function data and return true
        (print {action: "set-contract-owner", caller: caller, data: {address: address}})
        (ok true)
    )
    )
)

;; SIP 010 transfer function that transfers native STX tokens
(define-public (transfer 
    (amount uint)
    (sender principal) (recipient principal)
    (memo (optional (buff 34)))
    )
    (let (
    (caller tx-sender)
    )
    (begin
        ;; Assert that caller is sender and addresses are standard principals
        (asserts! (is-eq caller sender) ERR_NOT_AUTHORIZED_SIP_010)
        (asserts! (is-standard sender) ERR_INVALID_PRINCIPAL_SIP_010)
        (asserts! (is-standard recipient) ERR_INVALID_PRINCIPAL_SIP_010)
        
        ;; Try performing a STX token transfer and print memo
        (try! (stx-transfer? amount sender recipient))
        (match memo to-print (print to-print) 0x)

        ;; Print function data and return true
        (print {
        action: "transfer",
        caller: caller,
        data: {
            sender: sender,
            recipient: recipient,
            amount: amount,
            memo: memo
        }
        })
        (ok true)
    )
    )
)
```
