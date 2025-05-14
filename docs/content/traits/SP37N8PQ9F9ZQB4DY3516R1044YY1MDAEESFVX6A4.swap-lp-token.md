---
title: "Trait swap-lp-token"
draft: true
---
```

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant OWNER tx-sender)
(define-constant MINT-AUTHORITY 'SP37N8PQ9F9ZQB4DY3516R1044YY1MDAEESFVX6A4.swap-core)

(define-constant err-not-contract-owner (err u1001))
(define-constant err-not-token-owner (err u1002))
(define-constant err-not-mint-authority (err u1003))
(define-constant err-get-balance (err u2001))
(define-constant err-get-total-supply (err u2002))
(define-constant err-token-not-enough (err u3001))

(define-data-var token-uri (optional (string-utf8 256)) (some u"https://memefun.s3.ap-northeast-1.amazonaws.com/metadata/6wjvsutz8fqqbeyw8lzwzmf0uej4m0fh.json?"))
(define-map lp-balance-map {pool-id: uint, provider: principal} uint)
(define-map lp-supply-map uint uint)
(define-fungible-token lp-token)


(define-read-only (get-name) (ok "memecrazy-lp-token")) 
(define-read-only (get-symbol) (ok "memecrazy-lp-token"))
(define-read-only (get-decimals) (ok u6))
(define-read-only (get-token-uri)
    (ok (var-get token-uri)))
(define-read-only (lp-get-balance (pool-id uint) (who principal))
	(ok (default-to u0 (map-get? lp-balance-map {pool-id: pool-id, provider: who}))))
(define-read-only (lp-get-total-supply (pool-id uint))
	(ok (default-to u0 (map-get? lp-supply-map pool-id))))

(define-public (set-token-uri (uri (string-utf8 256)))
    (begin
        (asserts! (is-eq tx-sender OWNER) err-not-contract-owner)
        (var-set token-uri (some uri))
        (ok uri)
    )
)

(define-public (lp-transfer (pool-id uint) (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34)))) 
    (let ((sender-balance (unwrap! (lp-get-balance pool-id sender) err-get-balance))
          (recipient-balance (unwrap! (lp-get-balance pool-id recipient) err-get-balance)))
        
        (asserts! (is-eq sender tx-sender) err-not-token-owner)
        (asserts! (>= sender-balance amount) err-token-not-enough)

        (try! (ft-transfer? lp-token amount sender recipient))
        (map-set lp-balance-map {pool-id: pool-id, provider: sender} (- sender-balance amount))
        (map-set lp-balance-map {pool-id: pool-id, provider: recipient} (+ recipient-balance amount))
        (match memo to-print (print to-print) 0x)
        (ok true)
    )
)

(define-public (lp-mint (pool-id uint) (amount uint) (provider principal)) 
    (let ((provider-balance (unwrap! (lp-get-balance pool-id provider) err-get-balance))
          (pool-total-supply (unwrap! (lp-get-total-supply pool-id) err-get-total-supply)))
        
        (asserts! (is-eq tx-sender MINT-AUTHORITY) err-not-mint-authority)
        
        (try! (ft-mint? lp-token amount provider))
        (map-set lp-balance-map {pool-id: pool-id, provider: provider} (+ amount provider-balance))
        (map-set lp-supply-map pool-id (+ amount pool-total-supply))

        (ok true)
    )
)

(define-public (lp-burn (pool-id uint) (amount uint) (provider principal)) 
    (let ((provider-balance (unwrap! (lp-get-balance pool-id provider) err-get-balance))
          (pool-total-supply (unwrap! (lp-get-total-supply pool-id) err-get-total-supply)))
        
        (asserts! (is-eq tx-sender provider) err-not-token-owner)
        (asserts! (>= provider-balance amount) err-token-not-enough)

        (try! (ft-burn? lp-token amount provider))  
        (map-set lp-balance-map {pool-id: pool-id, provider: provider} (- provider-balance amount)) 
        (map-set lp-supply-map pool-id (- pool-total-supply amount)) 

        (ok true)
    )
)


(define-read-only (get-balance (who principal))
    (ok (ft-get-balance lp-token who)))
(define-read-only (get-total-supply)
    (ok (ft-get-supply lp-token)))
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34)))) 
    (begin
        (print "Can't transfer without pool-id! Use lp-transfer instead.")
        (ok true)
    )
)
    
```
