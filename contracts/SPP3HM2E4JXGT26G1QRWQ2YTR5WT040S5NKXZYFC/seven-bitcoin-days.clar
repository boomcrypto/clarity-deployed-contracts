;; seven-bitcoin-days

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token seven-bitcoin-days uint)

;; Constants
(define-constant DEPLOYER tx-sender)
(define-constant COMM u1000)
(define-constant COMM-ADDR 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S)

(define-constant ERR-NOT-AUTHORIZED u104)
(define-constant ERR-INVALID-USER u105)
(define-constant ERR-LISTING u106)
(define-constant ERR-WRONG-COMMISSION u107)
(define-constant ERR-NOT-FOUND u108)
(define-constant ERR-METADATA-FROZEN u111)

;; Internal variables
(define-data-var last-id uint u1)
(define-data-var artist-address principal 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmWYr3ghvHozMj36NJm1xPZbQGY6qT1FSrABAXomEZsdWj/json/")
(define-data-var metadata-frozen bool false)

(define-public (set-artist-address (address principal))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set artist-address address))))

(define-public (burn (token-id uint))
  (begin 
    (asserts! (is-owner token-id tx-sender) (err ERR-NOT-AUTHORIZED))
    (nft-burn? seven-bitcoin-days token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? seven-bitcoin-days token-id) false)))

(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
    (var-set ipfs-root new-base-uri)
    (ok true)))

(define-public (freeze-metadata)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set metadata-frozen true)
    (ok true)))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-INVALID-USER))
    (nft-transfer? seven-bitcoin-days token-id sender recipient)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? seven-bitcoin-days token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))

(define-trait commission-trait
  ((pay (uint uint) (response bool uint))))

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? seven-bitcoin-days id sender recipient)
    success
      (let
        ((sender-balance (get-balance sender))
        (recipient-balance (get-balance recipient)))
          (map-set token-count
            sender
            (- sender-balance u1))
          (map-set token-count
            recipient
            (+ recipient-balance u1))
          (ok success))
    error (err error)))

(define-private (is-sender-owner (id uint))
  (let ((owner (unwrap! (nft-get-owner? seven-bitcoin-days id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm-trait)}))
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-set market id listing)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)))

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-delete market id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-ustx (id uint) (comm-trait <commission-trait>))
  (let ((owner (unwrap! (nft-get-owner? seven-bitcoin-days id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))

(try! (nft-mint? seven-bitcoin-days (+ (var-get last-id) u0) 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC))
(map-set token-count 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC (+ (get-balance 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC) u1))
(try! (nft-mint? seven-bitcoin-days (+ (var-get last-id) u1) 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC))
(map-set token-count 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC (+ (get-balance 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC) u1))
(try! (nft-mint? seven-bitcoin-days (+ (var-get last-id) u2) 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC))
(map-set token-count 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC (+ (get-balance 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC) u1))
(try! (nft-mint? seven-bitcoin-days (+ (var-get last-id) u3) 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC))
(map-set token-count 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC (+ (get-balance 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC) u1))
(try! (nft-mint? seven-bitcoin-days (+ (var-get last-id) u4) 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC))
(map-set token-count 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC (+ (get-balance 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC) u1))
(try! (nft-mint? seven-bitcoin-days (+ (var-get last-id) u5) 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC))
(map-set token-count 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC (+ (get-balance 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC) u1))
(try! (nft-mint? seven-bitcoin-days (+ (var-get last-id) u6) 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC))
(map-set token-count 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC (+ (get-balance 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC) u1))
(var-set last-id u8)