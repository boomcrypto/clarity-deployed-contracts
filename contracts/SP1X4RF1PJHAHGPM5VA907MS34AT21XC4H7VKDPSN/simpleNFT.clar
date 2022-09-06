(define-non-fungible-token simpleNFT uint)

;; storage
(define-map  token-count principal uint)

;; define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))   
(define-constant err-not-token-owner (err u101))
(define-constant err-not-token (err u103))
(define-constant err-metadata-frozen (err u104))
(define-constant err-invalid-user (err u105))


;; define variables
(define-data-var mint-limit uint u2600)
(define-data-var last-token-id uint u0)
(define-data-var metadata-frozon bool false)
(define-data-var token-uri (string-ascii 80) "ipfs://QmcdXo7DJFogWJJnWqCc2z5NNoR7Rnd6isHump9SawHFxe/")
(define-data-var artist-address principal 'SP1X4RF1PJHAHGPM5VA907MS34AT21XC4H7VKDPSN)
(define-data-var total-price uint u0000000)




(define-read-only (get-balance (account principal))
    (default-to u0
        (map-get? token-count account)
    )
)

(define-read-only (get-last-token-id)
    (ok (var-get last-token-id))
)

(define-read-only (get-token-id (token-id uint))
    (ok none)
)

(define-read-only (get-owner (token-id uint))
    (ok (nft-get-owner? simpleNFT token-id))   
)

(define-read-only (get-token-uri (token-id uint))
    (ok (some (concat (concat (var-get token-uri) "{token-id}") ".json")))
)

(define-read-only (get-price)
    (ok (var-get total-price))
)

(define-public (set-artist-address (address principal))
    (begin
       (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender contract-owner)) (err  err-invalid-user))
        (ok (var-set artist-address address))
    )
)

(define-public (set-price (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender contract-owner)) (err  err-invalid-user))
    (ok (var-set total-price price))))

(define-public (set-base-uri (new-base-uri (string-ascii 80)))
    (begin
        (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender contract-owner)) (err err-owner-only))
        (asserts! (not (var-get metadata-frozon)) (err err-metadata-frozen))
        (var-set token-uri new-base-uri)
        (ok true)
    )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq sender tx-sender) err-not-token-owner)
        (nft-transfer? simpleNFT token-id sender recipient)
    )
)  

(define-public (mint (recipent principal)) 
    (let 
        (
            (token-id (+ (var-get last-token-id) u1))
        ) 
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
		(try! (nft-mint? simpleNFT token-id recipent))
		(var-set last-token-id token-id)
		(ok token-id)
    )
)

(define-public (burn (token-id uint))
  (begin 
    (asserts! (is-owner token-id tx-sender) err-owner-only)
    (nft-burn? simpleNFT token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? simpleNFT token-id) false)))

(define-public (freeze-metadata) 
    (begin
        (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender contract-owner)) (err err-owner-only))
        (var-set metadata-frozon true)
        (ok true)
    )
)