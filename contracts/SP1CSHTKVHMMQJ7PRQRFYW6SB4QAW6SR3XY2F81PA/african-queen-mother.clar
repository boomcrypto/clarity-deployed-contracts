;; testnet
;; (impl-trait .nft-trait.nft-trait)
;; mainnet
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token african-queen-mother uint)

;; ERRORS
(define-constant ERR-NOT-CONTRACT-OWNER (err u100))
(define-constant ERR-NOT-TOKEN-OWNER (err u101))
(define-constant ERR-ALL-MINTED (err u102))
(define-constant ERR-INSUFFICENT-FUNDS (err u103))
(define-constant ERR-STX-TRANSFER (err u104))
(define-constant ERR-NFT-MINT (err u105))

;; CONSTANTS
(define-constant CONTRACT-OWNER tx-sender)
(define-constant TOKEN-LIMIT u50)
(define-constant URI-CID "QmVXPMeJtS281pxtSULm1RV52E5H8vZyC26vJN6Z8Gc3vj/")
(define-constant LOOKUP (list "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30" "31" "32" "33" "34" "35" "36" "37" "38" "39" "40" "41" "42" "43" "44" "45" "46" "47" "48" "49" "50"))

;; VARS
(define-data-var last-token-id uint u0)
(define-data-var mint-price uint u75000000)

;; testnet
;; (define-data-var artist-address principal 'ST16W7S76K0A7HAM176B73RQ8MD75E9VJ8RGGTAQR)
;; mainnet
(define-data-var artist-address principal 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T)

;; testnet
;; (define-data-var helper-address principal 'ST1B9MPJCA78KRFP2M312N8KFFGZR33HB6CZ6HJ0X)
;; mainnet
(define-data-var helper-address principal 'SP1B9MPJCA78KRFP2M312N8KFFGZR33HB6EJH1NHQ)

;; READ-ONLY
(define-read-only (get-last-token-id) 
    (ok (var-get last-token-id))
)

(define-read-only (get-owner (token-id uint)) 
    (ok (nft-get-owner? african-queen-mother token-id))
)

(define-read-only (get-token-uri (token-id uint)) 
    (ok (some (concat (concat (concat "ipfs://" URI-CID) (unwrap-panic (element-at LOOKUP token-id))) ".json")))
)

(define-read-only (get-mint-price)
    (ok (var-get mint-price))
)

;; PUBLIC
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin 
        (asserts! (is-eq tx-sender sender) ERR-NOT-TOKEN-OWNER)
        (nft-transfer? african-queen-mother token-id sender recipient)
    )
)

(define-public (burn (token-id uint))
    (begin 
        (asserts! (is-owner token-id tx-sender) ERR-NOT-TOKEN-OWNER)
        (nft-burn? african-queen-mother token-id tx-sender)
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
        (unwrap! (stx-transfer? u73500000 tx-sender (var-get artist-address)) (err ERR-STX-TRANSFER))
        (unwrap! (stx-transfer? u1500000 tx-sender (var-get helper-address)) (err ERR-STX-TRANSFER))
        (unwrap! (nft-mint? african-queen-mother token-id recipient) (err ERR-NFT-MINT))
        (var-set last-token-id token-id)
        (ok token-id)
    )
)

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? african-queen-mother token-id) false))
)