(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token json-tester uint)

;; Constants
(define-constant err-no-more-nfts u300)
(define-constant err-invalid-user u500)
(define-constant commission-address-master tx-sender)
(define-constant mint-limit u420)

;; Internal variables
(define-data-var last-id uint u0)
(define-data-var commission-master uint u500)
(define-data-var commission uint u500)
(define-data-var total-price uint u1000)
(define-data-var artist-address principal 'SPFRGJ8117Y5H9Y6SYBF75H6RSB1FMJQYA27RST9)
(define-data-var commission-address principal 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S)
(define-data-var ipfs-root (string-ascii 80) "https://stacksdegens.com/testing-json-capabilities-test/")

;; private functions
(define-private (mint (new-owner principal))
  (let ((next-id (+ u1 (var-get last-id)))  
        (count (var-get last-id)))
      (asserts! (< count mint-limit) (err err-no-more-nfts))
    (let
      ((total-commission-master (/ (* (var-get total-price) (var-get commission-master)) u10000))
       (total-commission (/ (* (var-get total-price) (var-get commission)) u10000))
       (total-artist (- (- (var-get total-price) total-commission-master) total-commission))
      )
      (if (is-eq tx-sender (var-get artist-address))
        (mint-helper new-owner next-id)
        (if (is-eq tx-sender commission-address-master)
          (begin
            (mint-helper new-owner next-id))
          (if (is-eq tx-sender (var-get commission-address))
            (begin
              (try! (stx-transfer? total-commission-master tx-sender commission-address-master))
              (try! (stx-transfer? total-artist tx-sender (var-get artist-address)))
              (mint-helper new-owner next-id))
            (begin
              (try! (stx-transfer? total-commission-master tx-sender commission-address-master))
              (try! (stx-transfer? total-commission tx-sender (var-get commission-address)))
              (try! (stx-transfer? total-artist tx-sender (var-get artist-address)))
              (mint-helper new-owner next-id))
          )
        )
      )
    )
  )
)

(define-private (mint-helper (new-owner principal) (next-id uint))
    (match (nft-mint? json-tester next-id new-owner)
            success
              (begin
                (var-set last-id next-id)
                (ok true))
            error (err error)))

;; public functions
(define-public (claim)
  (mint tx-sender))

(define-public (set-artist-address (address principal))
  (if (is-eq tx-sender commission-address-master)
    (begin 
      (var-set artist-address address)
      (ok true)
    )
    (err err-invalid-user)))

(define-public (set-commission-address (address principal))
  (if (is-eq tx-sender commission-address-master)
    (begin 
      (var-set commission-address address)
      (ok true)
    )
    (err err-invalid-user)))

(define-public (set-price (price uint))
  (if (is-eq tx-sender commission-address-master)
    (begin 
      (var-set total-price price)
      (ok true)
    )
    (err err-invalid-user)))

(define-public (set-commission-master (new-commission-master uint))
  (if (is-eq tx-sender commission-address-master)
    (begin
      (var-set commission-master new-commission-master)
      (ok true)
    )
    (err err-invalid-user)))
    
(define-public (set-commission (new-commission uint))
  (if (is-eq tx-sender commission-address-master)
    (begin
      (var-set commission new-commission)
      (ok true)
    )
    (err err-invalid-user)))

(define-public (set-ipfs-root (new-ipfs-root (string-ascii 80)))
  (if (is-eq tx-sender commission-address-master)
    (begin 
      (var-set ipfs-root new-ipfs-root)
      (ok true)
    )
    (err err-invalid-user)))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      (match (nft-transfer? json-tester token-id sender recipient)
        success (ok success)
        error (err error))
      (err err-invalid-user)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? json-tester token-id)))

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
    (ok (some (concat (concat (var-get ipfs-root) "$TOKEN_ID") ".json"))))
  
(define-read-only (get-price)
  (ok (var-get total-price)))

(define-read-only (get-artist-address)
  (ok (var-get artist-address)))

(define-read-only (get-commission-address)
  (ok (var-get commission-address)))

(define-read-only (get-commission-master)
  (ok (var-get commission-master)))

(define-read-only (get-commission)
  (ok (var-get commission)))

(define-read-only (get-base-uri)
  (ok (var-get ipfs-root)))