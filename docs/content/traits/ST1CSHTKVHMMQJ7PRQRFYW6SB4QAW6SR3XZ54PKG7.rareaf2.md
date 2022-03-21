---
title: "Trait rareaf2"
draft: true
---
```
;; testnet
(impl-trait .nft-trait.nft-trait)
;; mainnet
;; (impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token rareaf-nft uint)

;; testnet
(define-data-var rareaf-address principal 'ST1B9MPJCA78KRFP2M312N8KFFGZR33HB6CZ6HJ0X)
;; mainnet
;; (define-data-var helper-address principal 'SP1B9MPJCA78KRFP2M312N8KFFGZR33HB6EJH1NHQ)

;; errors
(define-constant err-not-contract-owner (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-stx-transfer (err u104))
(define-constant err-nft-mint (err u105))

;; constants
(define-constant contract-owner tx-sender)

;; vars
(define-data-var last-token-id uint u0)
(define-data-var mint-price uint u0)

;; maps
(define-map hash-map uint (string-ascii 64))

(define-read-only (get-last-token-id) 
    (ok (var-get last-token-id))
)

(define-read-only (get-owner (token-id uint)) 
    (ok (nft-get-owner? rareaf-nft token-id))
)

(define-read-only (get-token-uri (token-id uint)) 
    ;; (ok (some (concat (concat (concat "ipfs://" URI-CID) (unwrap-panic (element-at LOOKUP token-id))) ".json")))
    (ok (some (concat (concat (concat "ipfs://" (unwrap-panic (map-get? hash-map token-id))) (uint-to-string token-id)) ".json")))
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin 
        (asserts! (is-eq tx-sender sender) err-not-token-owner)
        (nft-transfer? rareaf-nft token-id sender recipient)
    )
)

(define-read-only (get-mint-price)
    (ok (var-get mint-price))
)

(define-public (set-mint-price (new-price uint))
    (ok (var-set mint-price new-price))
)

(define-public (mint (hash (string-ascii 64)))
    (let 
        (
            (token-id (+ (var-get last-token-id) u1))
            (price (var-get mint-price))
        )
        ;; (unwrap! (stx-transfer? price tx-sender (var-get rareaf-address)) (err err-stx-transfer))
        (unwrap! (nft-mint? rareaf-nft token-id tx-sender) (err err-nft-mint))
        (map-set hash-map token-id hash)
        (var-set last-token-id token-id)
        (ok token-id)
    )
)

(define-public (burn (token-id uint))
    (begin 
        (asserts! (is-owner token-id tx-sender) err-not-token-owner)
        (nft-burn? rareaf-nft token-id tx-sender)
    )
)

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? rareaf-nft token-id) false))
)

;; CODE FOR UINT -> STRING

(define-constant FOLDS_3 (list true true true))

(define-constant NUM_TO_CHAR (list    
    "0" "1" "2" "3" "4" "5" "6" "7" "8" "9"
))

(define-private (concat-uint (ignore bool) (input { dec: uint, data: (string-ascii 3) }))
    (let 
        (            
            (last-val (get dec input))        
        )        
        (if (is-eq last-val u0)            
            {                
                dec: last-val,                
                data: (get data input)            
            }            
            (if (< last-val u10)                
                {                    
                    dec: u0,                    
                    data: (concat-num-to-string last-val (get data input))                
                }                
                {                    
                    dec: (/ last-val u10),                    
                    data: (concat-num-to-string (mod last-val u10) (get data input))                
                }            
            )        
        )    
    )
)

(define-private (concat-num-to-string (num uint) (right (string-ascii 3)))    
    (unwrap-panic (as-max-len? (concat (unwrap-panic (element-at NUM_TO_CHAR num)) right) u3))
)

(define-private (uint-to-string (num uint))    
    (if (is-eq num u0)        
        (unwrap-panic (as-max-len? "0" u3))        
        (get data (fold concat-uint FOLDS_3 { dec: num, data: ""}))    
    )
)
```
