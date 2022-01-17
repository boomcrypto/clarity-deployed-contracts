;; stacculents

;; (impl-trait .nft-trait.nft-trait)
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token stacculents uint)

;; Constants
(define-constant err-no-more-nfts u300)
(define-constant err-invalid-user u500)

(define-constant commission-address tx-sender)

;; Internal variables
(define-data-var mint-limit uint u550)
(define-data-var last-id uint u0)
(define-data-var commission uint u500)
(define-data-var total-price uint u15000000)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmNm8SPqjmbrjm1JWmim3z5JRkmaavTEw6trT4pyw2kj8z/")

(define-data-var primary-artist-address principal 'SP3CXP82SP2M920C5XX42RMAJ3Y6FS0KS5ZK1N1BC) ;; FB
(define-data-var second-artist-address principal 'SP2KD44XNHAXEPY4WXDQDCM596DNM68N29EGWJJ52) ;; MT
(define-data-var third-artist-address principal 'SP1N1PV6KA878YDS1V6081TZZ7MY4XTG4KC0P3PC8) ;; TC
(define-data-var fourth-artist-address principal 'SP1YDMQEPC655TQJQGGK37Z8DHHEMGAAN2RC533WB) ;; LC

;; private functions
(define-private (mint (new-owner principal))
  (let ((next-id (+ u1 (var-get last-id)))  
        (count (var-get last-id)))
      (asserts! (< count (var-get mint-limit)) (err err-no-more-nfts))
    (let
      ((total-commission (/ (* (var-get total-price) (var-get commission)) u10000))
       (total-artist (- (var-get total-price) (* u4 total-commission))))
      (if (is-eq tx-sender (var-get primary-artist-address))
        (mint-helper new-owner next-id)
        (if (is-eq tx-sender commission-address)
          (begin
            (mint-helper new-owner next-id))
          (begin
            (try! (stx-transfer? total-artist tx-sender (var-get primary-artist-address)))
            (try! (stx-transfer? total-commission tx-sender commission-address))
            (try! (stx-transfer? total-commission tx-sender (var-get second-artist-address)))
            (try! (stx-transfer? total-commission tx-sender (var-get third-artist-address)))
            (try! (stx-transfer? total-commission tx-sender (var-get fourth-artist-address)))
            (mint-helper new-owner next-id))))
    )
  )
)

(define-private (mint-helper (new-owner principal) (next-id uint))
    (match (nft-mint? stacculents next-id new-owner)
            success
              (begin
                (var-set last-id next-id)
                (ok true))
            error (err error)))

;; public functions
(define-public (claim)
  (mint tx-sender))

(define-public (claim-five)
 (begin 
  (try! (mint tx-sender))
  (try! (mint tx-sender))
  (try! (mint tx-sender))
  (try! (mint tx-sender))
  (try! (mint tx-sender))
  (ok true)
 )
)

(define-public (set-artist-address (address principal))
  (if (is-eq tx-sender commission-address)
    (begin 
      (var-set primary-artist-address address)
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

(define-public (set-mint-limit (new-mint-limit uint))
  (if (is-eq tx-sender commission-address)
    (begin 
      (var-set mint-limit new-mint-limit)
      (ok true)
    )
    (err err-invalid-user)))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      (match (nft-transfer? stacculents token-id sender recipient)
        success (ok success)
        error (err error))
      (err err-invalid-user)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? stacculents token-id)))

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
    (ok (some (concat (concat (var-get ipfs-root) "$TOKEN_ID") ".json"))))

