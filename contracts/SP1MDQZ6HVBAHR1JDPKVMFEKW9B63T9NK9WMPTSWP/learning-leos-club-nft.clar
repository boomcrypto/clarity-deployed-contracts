
;; learning-leos-club-nft
;; LEOS (stage1) : NFT reward after completion of course at leos.guru

;; SIP009 NFT trait on mainnet
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; constants
(define-constant contract-owner tx-sender)

;; errors
(define-constant err-invalid-price (err u400))
(define-constant err-not-authorized (err u401))
(define-constant err-forbidden (err u403))
(define-constant err-non-transferable (err u405))
(define-constant err-already-minted (err u410))
(define-constant err-invalid-uri (err u411))

;; data maps and vars
(define-non-fungible-token learning-leos-club uint)
(define-data-var token-uri (string-ascii 256) "ipfs://QmdxqVHbZs7c26VLWwrAFHA9uA1FnTqwAA9XySLu5pnpZe")
(define-data-var last-token-id uint u0)
(define-map minted principal bool)
(define-data-var mint-price uint u0)
(define-map mint-authorities principal bool)

;; private functions
(define-private (is-caller-authorized)
    (default-to false (map-get? mint-authorities contract-caller))
)

;; public functions

(define-read-only (get-last-token-id)
    (ok (var-get last-token-id))
)

(define-read-only (get-token-uri (token-id uint))
    (ok (some (var-get token-uri)))
)

(define-read-only (get-owner (token-id uint))
    (ok (nft-get-owner? learning-leos-club token-id))
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender sender) err-not-authorized)
        (asserts! false err-non-transferable)
        err-non-transferable
    )
)

(define-read-only (get-mint-price)
    (var-get mint-price)
)

(define-public (set-mint-price (price uint))
    (begin
        (asserts! (or (is-caller-authorized) (is-eq tx-sender contract-owner)) err-not-authorized)
        (asserts! (> price u0) err-invalid-price)
        (ok (var-set mint-price price))
    )
)

(define-public (set-mint-authority (address principal) (allowed bool))
    (begin
        (asserts! (is-caller-authorized) err-not-authorized)
        (asserts! (not (and (not allowed) (is-eq address contract-owner))) err-forbidden)
        (print {mint-authority: address, enabled: allowed})
        (ok (map-set mint-authorities address allowed))
    )
)

(define-public (set-token-uri (uri (string-ascii 256)))
    (begin
        (asserts! (is-caller-authorized) err-not-authorized)
        (asserts! (> (len uri) u0) err-invalid-uri)
        (ok (var-set token-uri uri))
    )
)

(define-public (mint (subject principal) (course-name (string-ascii 256)))
    (let
        (
            (token-id (+ (var-get last-token-id) u1))
            (already-minted (default-to false (map-get? minted subject)))
            (price (var-get mint-price))
        )
        (asserts! (is-caller-authorized) err-not-authorized)
        (asserts! (not already-minted) err-already-minted)
        (try! (nft-mint? learning-leos-club token-id subject))
        (map-set minted subject true)
        (var-set last-token-id token-id)
        (print {
            issuer: contract-caller,
            credentialSubject: { 
                id: subject, 
                degree: { 
                    type: "course",
                    name: course-name
                }  
            }})
        (ok token-id)
    )
)

(map-set mint-authorities contract-owner true)
