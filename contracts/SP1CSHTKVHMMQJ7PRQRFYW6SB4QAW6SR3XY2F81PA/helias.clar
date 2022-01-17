;; testnet
;; (impl-trait .nft-trait.nft-trait)
;; mainnet
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token helias uint)

;; ERRORS
(define-constant ERR-NOT-CONTRACT-OWNER (err u100))
(define-constant ERR-NOT-TOKEN-OWNER (err u101))
(define-constant ERR-ALL-MINTED (err u102))
(define-constant ERR-INSUFFICENT-FUNDS (err u103))
(define-constant ERR-STX-TRANSFER (err u104))
(define-constant ERR-NFT-MINT (err u105))

;; CONSTANTS
(define-constant CONTRACT-OWNER tx-sender)
(define-constant TOKEN-LIMIT u500)
(define-constant URI-CID "QmWyiwndtXbifxU3VJLbb1pmwd34wLsT3tbicAoTEDCcYJ/")

;; VARS
(define-data-var last-token-id uint u0)
(define-data-var mint-price uint u30000000)

;; testnet
;; (define-data-var artist-address principal 'ST1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XZ54PKG7)
;; mainnet
(define-data-var artist-address principal 'SP36ADRBVM8J00ZWR5QXC8V65WTJNCD1BF4EJ93ZZ)

;; testnet
;; (define-data-var helper-address principal 'ST1B9MPJCA78KRFP2M312N8KFFGZR33HB6CZ6HJ0X)
;; mainnet
(define-data-var helper-address principal 'SP1B9MPJCA78KRFP2M312N8KFFGZR33HB6EJH1NHQ)

;; READ-ONLY
(define-read-only (get-last-token-id) 
    (ok (var-get last-token-id))
)

(define-read-only (get-owner (token-id uint)) 
    (ok (nft-get-owner? helias token-id))
)

(define-read-only (get-token-uri (token-id uint)) 
    ;; (ok (some (concat (concat (concat "ipfs://" URI-CID) (unwrap-panic (element-at LOOKUP token-id))) ".json")))
    (ok (some (concat (concat (concat "ipfs://" URI-CID) (uint-to-string token-id)) ".json")))
)

(define-read-only (get-mint-price)
    (ok (var-get mint-price))
)

;; PUBLIC
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin 
        (asserts! (is-eq tx-sender sender) ERR-NOT-TOKEN-OWNER)
        (nft-transfer? helias token-id sender recipient)
    )
)

(define-public (burn (token-id uint))
    (begin 
        (asserts! (is-owner token-id tx-sender) ERR-NOT-TOKEN-OWNER)
        (nft-burn? helias token-id tx-sender)
    )
)

(define-public (claim)
    (mint tx-sender)
)

;; PRIVATE
(define-private (mint (recipient principal))
    (let 
        (
            (token-id (+ (var-get last-token-id) u1))
            (price (var-get mint-price))
        )
        (asserts! (<= token-id TOKEN-LIMIT) (err ERR-ALL-MINTED))
        (unwrap! (stx-transfer? u27000000 tx-sender (var-get artist-address)) (err ERR-STX-TRANSFER))
        (unwrap! (stx-transfer? u3000000 tx-sender (var-get helper-address)) (err ERR-STX-TRANSFER))
        (unwrap! (nft-mint? helias token-id recipient) (err ERR-NFT-MINT))
        (var-set last-token-id token-id)
        (ok token-id)
    )
)

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? helias token-id) false))
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