;; (impl-trait .nft-trait.nft-trait)
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(define-non-fungible-token PLATES uint)

;; ERRORS
(define-constant ERR-NOT-CONTRACT-OWNER (err u100))
(define-constant ERR-NOT-TOKEN-OWNER (err u101))
(define-constant ERR-ALL-MINTED (err u102))
(define-constant ERR-INSUFFICENT-FUNDS (err u103))
(define-constant ERR-STX-TRANSFER (err u104))
(define-constant ERR-NFT-MINT (err u105))
(define-constant ERR-NO-PLATE-FOUND (err u106))
(define-constant ERR-TOKEN-BY-IMAGE (err u107))
(define-constant ERR-TOKEN-BY-INDEX (err u108))
(define-constant ERR-IMAGE-BY-TOKEN (err u109))
(define-constant ERR-INDEX-BY-TOKEN (err u110))
(define-constant ERR-INVALID-IMAGE (err u111))

;; CONSTANTS
(define-constant CONTRACT-OWNER tx-sender)
(define-constant TOKEN-LIMIT u10000)
(define-constant URI-CID "Qmd4zgFFhe85roe9e9zDVzP5GquaRAgbV7KaS524mMVQaz/")
(define-constant IMAGE-KEY (list "F8FBFC" "060606" "F90F1B" "FF6620" "FDC22D" "42421F" "303649" "3075A3" "B5E3FC" "5CC9C8"))

;; VARS
(define-data-var last-token-id uint u0)
(define-data-var mint-price uint u1000000)

;; MAPS
(define-map token-by-image (string-ascii 441) uint)
(define-map token-by-index (string-ascii 4) uint)
(define-map image-by-token uint (string-ascii 441))
(define-map index-by-token uint (string-ascii 4))

;; READ-ONLY
(define-read-only (get-last-token-id) 
    (ok (var-get last-token-id))
)

(define-read-only (get-owner (token-id uint)) 
    (ok (nft-get-owner? PLATES token-id))
)

(define-read-only (get-token-uri (token-id uint)) 
    (ok (some (concat (concat (concat "ipfs://" URI-CID) (unwrap-panic (map-get? index-by-token token-id))) ".json")))
)

(define-read-only (get-image-by-token (token-id uint))
    (ok (map-get? image-by-token token-id))
)

(define-read-only (get-index-by-token (token-id uint))
    (ok (unwrap-panic (map-get? index-by-token token-id)))
)

(define-read-only (get-token-by-image (image (string-ascii 441)))
    (ok (map-get? token-by-image image))
)

(define-read-only (get-token-by-index (index (string-ascii 4)))
    (ok (map-get? token-by-index index))
)

(define-read-only (get-mint-price)
    (ok (var-get mint-price))
)

(define-read-only (get-image-hex (index uint))
    (ok (element-at IMAGE-KEY index))
)

;; PUBLIC
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin 
        (asserts! (is-eq tx-sender sender) ERR-NOT-TOKEN-OWNER)
        (nft-transfer? PLATES token-id sender recipient)
    )
)

(define-public (transfer-stx (address principal) (amount uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-CONTRACT-OWNER))
        (unwrap! (as-contract (stx-transfer? amount (as-contract tx-sender) address)) (err ERR-STX-TRANSFER))
        (ok amount)
    )
)

(define-public (set-mint-price (value uint))
    (if (is-eq tx-sender CONTRACT-OWNER)
        (ok (var-set mint-price value))
        (err ERR-NOT-CONTRACT-OWNER)
    )
)

(define-public (burn (token-id uint))
    (begin 
        (asserts! (is-owner token-id tx-sender) ERR-NOT-TOKEN-OWNER)
        (nft-burn? PLATES token-id tx-sender)
    )
)

(define-public (claim (image (string-ascii 441)) (index (string-ascii 4)))
    (mint tx-sender image index)
)

;; PRIVATE
(define-private (mint (recipient principal) (image (string-ascii 441)) (index (string-ascii 4)))
    (let 
        (
            (token-id (+ (var-get last-token-id) u1))
            (price (var-get mint-price))
        )
        (asserts! (<= token-id TOKEN-LIMIT) (err ERR-ALL-MINTED))
        (asserts! (is-eq (len image) u441) (err ERR-INVALID-IMAGE))
        (asserts! (map-insert index-by-token token-id index) (err ERR-INDEX-BY-TOKEN))
        (asserts! (map-insert image-by-token token-id image) (err ERR-IMAGE-BY-TOKEN))
        (asserts! (map-insert token-by-index index token-id) (err ERR-TOKEN-BY-INDEX))
        (asserts! (map-insert token-by-image image token-id) (err ERR-TOKEN-BY-IMAGE))
        (unwrap! (stx-transfer? price tx-sender (as-contract tx-sender)) (err ERR-STX-TRANSFER))
        (unwrap! (nft-mint? PLATES token-id recipient) (err ERR-NFT-MINT))
        (var-set last-token-id token-id)
        (ok token-id)
    )
)

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? PLATES token-id) false))
)

(print "Each plate is represented on-chain as a 21x21 grid of pixels (drawn left-to-right, top-to-bottom). To get the pixel hex values for a token, get the string from image-by-token for that token. Each number in the string represents an index in the image-key list.")