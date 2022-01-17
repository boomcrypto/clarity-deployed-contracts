;; rangoli

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token rangoli uint)

;; Constants
(define-constant err-no-more-nfts u300)
(define-constant err-invalid-user u500)

(define-constant mint-limit u600)
(define-constant commission-address tx-sender)

;; Internal variables
(define-data-var last-id uint u0)
(define-data-var commission uint u500)
(define-data-var total-price uint u33000000)
(define-data-var artist-address principal 'SP1W1KE3GGR07YB576P8KMA83TTKWPV8K9DJX01H1)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmetX2ASKG9vTjE3EGPpwvvMdrSQguov7LFvFzwPYoruL2/")

;; private functions
(define-private (mint (new-owner principal))
  (let ((next-id (+ u1 (var-get last-id)))  
        (count (var-get last-id)))
      (asserts! (< count mint-limit) (err err-no-more-nfts))
    (let
      ((total-commission (/ (* (var-get total-price) (var-get commission)) u10000))
       (total-artist (- (var-get total-price) total-commission)))
      (if (is-eq tx-sender (var-get artist-address))
        (mint-helper new-owner next-id)
        (if (is-eq tx-sender commission-address)
          (begin
            (mint-helper new-owner next-id))
          (begin
            (try! (stx-transfer? total-commission tx-sender commission-address))
            (try! (stx-transfer? total-artist tx-sender (var-get artist-address)))
            (mint-helper new-owner next-id))))
    )
  )
)

(define-private (mint-helper (new-owner principal) (next-id uint))
    (match (nft-mint? rangoli next-id new-owner)
            success
              (begin
                (var-set last-id next-id)
                (ok true))
            error (err error)))

;; public functions
(define-public (claim)
  (mint tx-sender))

(define-public (set-artist-address (address principal))
  (if (is-eq tx-sender commission-address)
    (begin 
      (var-set artist-address address)
      (ok true)
    )
    (err err-invalid-user)))

(define-public (set-price (price uint))
  (if (is-eq tx-sender commission-address)
    (begin 
      (var-set total-price price)
      (ok true)
    )
    (err err-invalid-user)))

(define-public (set-ipfs-root (new-ipfs-root (string-ascii 80)))
  (if (is-eq tx-sender commission-address)
    (begin 
      (var-set ipfs-root new-ipfs-root)
      (ok true)
    )
    (err err-invalid-user)))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      (match (nft-transfer? rangoli token-id sender recipient)
        success (ok success)
        error (err error))
      (err err-invalid-user)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? rangoli token-id)))

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
    (ok (some (concat (concat (var-get ipfs-root) "$TOKEN_ID") ".json"))))

