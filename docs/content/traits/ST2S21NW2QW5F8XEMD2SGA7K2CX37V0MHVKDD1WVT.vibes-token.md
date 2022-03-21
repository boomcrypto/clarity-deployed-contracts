---
title: "Trait vibes-token"
draft: true
---
```
(define-fungible-token vibes-token)
(define-constant ERR-UNAUTHORIZED u1)
(define-constant ERR-NON-SUFFICIENT-FUNDS u2)
(define-constant ERR-INVALID-SPENDER u10)
(define-constant ERR-ZERO-VALUE u11)
(define-constant contract-owner tx-sender)
;; Storage
(define-data-var token-uri (optional (string-utf8 256)) none)
(define-data-var total-supply uint u0)
(define-map allowances {spender: principal, owner: principal} {allowance: uint})
(impl-trait .sip-010-trait.sip-010-trait)


(define-read-only (get-name)
    (ok "Hirevibes"))

(define-read-only (get-symbol)
    (ok "VIBES"))

(define-read-only (get-decimals)
    (ok u8))

(define-read-only (get-total-supply)
    (ok (ft-get-supply vibes-token)))

(define-read-only (get-balance (owner principal))
    (ok (get-balance-of owner)))

(define-read-only (get-token-uri)
    (ok (var-get token-uri)))

(define-read-only (get-contract-owner)
    (ok contract-owner)
)

;; PRIVATE FUNCTIONS

;; check if the tx sender is the owner
(define-private (is-owner)
    (is-eq contract-owner tx-sender)
)

(define-private (allowance-of (spender principal) (owner principal))
    (default-to u0
        (get allowance (map-get? allowances {spender: spender, owner: owner}))))

;; Increase-Allowance
(define-private (increase-allowance (amount uint) (spender principal) (owner principal))
    (let ((allowance (allowance-of spender owner)))
        (begin 
            (asserts! ( <= amount u0) (err ERR-ZERO-VALUE))
            (map-set allowances {spender: spender, owner: owner}
            {allowance:  (+ allowance amount)})
            (ok true)
        )
    )
)

;; Decrease-Allowance
(define-private (decrease-allowance (amount uint) (spender principal) (owner principal))
    (let ((allowance (allowance-of spender owner)))
        (if (or (> amount allowance) (<= amount u0))
            true
            (begin 
                (map-set allowances
                    {spender: spender, owner: owner}
                    {allowance: ( - allowance amount)}
                )
                true
            )
        )
    )
)

;; Get Balance

(define-private (get-balance-of (owner principal))
    (ft-get-balance vibes-token owner)
)
;; PUBLIC FUNCTIONS

(define-public (donate (amount uint)) 
    (stx-transfer? amount tx-sender contract-owner))


(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (asserts! ( > amount u0) (err ERR-ZERO-VALUE))
        (asserts! (is-eq sender tx-sender) (err ERR-UNAUTHORIZED))
        (try! (ft-transfer? vibes-token amount sender recipient))
        (print memo)
        (ok true)
    )
)

(define-public (set-token-uri (value (string-utf8 256)))
    (begin
        (asserts! (is-owner) (err ERR-UNAUTHORIZED))
        (ok (var-set token-uri (some value)))
    )
)

(define-public (burn (amount uint) (sender principal))
    (begin 
         (asserts! (is-eq tx-sender sender) (err ERR-UNAUTHORIZED))
         (let ((balance (get-balance-of sender)))
            (asserts! (>= balance amount) (err ERR-NON-SUFFICIENT-FUNDS))
            (ft-burn? vibes-token amount sender)
         )
    )
)

;; approve
(define-public (approve (amount uint) (spender principal))
    (begin 
        (asserts! (is-eq tx-sender spender) (err ERR-INVALID-SPENDER))
        (asserts! ( > amount u0) (err ERR-NON-SUFFICIENT-FUNDS))
        (print (increase-allowance amount spender tx-sender))
        
    )
)

;; mint
(define-public (mint (amount uint) (recipient principal))
    (begin 
        (asserts! ( > amount u0) (err ERR-ZERO-VALUE))
        (var-set total-supply (+ (var-get total-supply) amount))
        (ft-mint? vibes-token amount recipient)
    )
)

(mint u35000000000000000 'ST2S21NW2QW5F8XEMD2SGA7K2CX37V0MHVKDD1WVT)
```
