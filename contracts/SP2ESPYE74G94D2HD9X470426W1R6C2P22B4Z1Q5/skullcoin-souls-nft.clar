;; Traits
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait commission-trait .commission-trait.commission)

;; Define NFT token
(define-non-fungible-token skullcoin-souls uint)

;; Storage
(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})
(define-map mint-address bool principal)

;; Constants and Errors
(define-constant CONTRACT-OWNER tx-sender)
(define-constant WALLET 'SP224YKZ55F25SBYVR8HZXQ7G89CC8WYKAGMZHQ0A)
(define-constant ERR-SOLD-OUT (err u200))
(define-constant ERR-WRONG-COMMISSION (err u201))
(define-constant ERR-NOT-AUTHORIZED (err u202))
(define-constant ERR-NOT-FOUND (err u203))
(define-constant ERR-METADATA-FROZEN (err u204))
(define-constant ERR-MINT-ALREADY-SET (err u205))
(define-constant ERR-LISTING (err u206))
(define-constant ERR-MINT-LIMIT (err u207))

;; Variables
(define-data-var last-id uint u0)
(define-data-var mint-limit uint u2000)
(define-data-var mint-price uint u0)
(define-data-var mintpass-sale-active bool false)
(define-data-var metadata-frozen bool false)
(define-data-var base-uri (string-ascii 80) "ipfs://QmTWYeomfdFNArmxqH5woVJtfw5CqVZCYdQ2xtB8Z9zutm/")

;; Get balance
(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

;; Transfer token to a specified principal
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? market id)) ERR-LISTING)
    (trnsfr id sender recipient)))

;; Get the owner of the specified token ID
(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? skullcoin-souls id)))

;; Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

;; Get the token URI
(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get base-uri) "{id}") ".json"))))

;; Get the mint limit
(define-read-only (get-mint-limit)
  (ok (var-get mint-limit)))

;; Get the mint price
(define-read-only (get-mint-price)
  (ok (var-get mint-price)))

;; Change the base uri (only contract owner)
(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (not (var-get metadata-frozen)) ERR-METADATA-FROZEN)
    (var-set base-uri new-base-uri)
    (ok true)))

;; Set mint limit (only contract owner)
(define-public (set-mint-limit (limit uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (< (var-get mint-limit) limit) ERR-MINT-LIMIT)
    (var-set mint-limit limit)
    (ok true)))

;; Set mint price in uSTX (only contract owner)
(define-public (set-mint-price-in-ustx (price uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set mint-price price)
    (ok (var-get mint-price))))

;; Freeze metadata
(define-public (freeze-metadata)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set metadata-frozen true)
    (ok true)))

;; Manage the Mint
(define-private (called-from-mint)
  (let ((the-mint
          (unwrap! (map-get? mint-address true)
                    false)))
    (is-eq contract-caller the-mint)))

;; Set mint address
(define-public (set-mint-address)
  (let ((the-mint (map-get? mint-address true)))
    (asserts! (and (is-none the-mint)
              (map-insert mint-address true tx-sender))
                ERR-MINT-ALREADY-SET)
    (ok tx-sender)))

;; U2FsdGVkX1+OyqzoAhgrAM+CG53VlXSygOGlx/g0ifrOi47xgS7r7lPbwi23lsri

;; Mint new NFT (called from mint contract)
(define-public (mint (new-owner principal))
    (let ((next-id (+ u1 (var-get last-id))))
      (asserts! (called-from-mint) ERR-NOT-AUTHORIZED)
      (asserts! (< (var-get last-id) (var-get mint-limit)) ERR-SOLD-OUT)
      (match (nft-mint? skullcoin-souls next-id new-owner)
        success
        (let
        ((current-balance (get-balance new-owner)))
          (begin
            (try! (stx-transfer? (var-get mint-price) tx-sender WALLET))
            (var-set last-id next-id)
            (map-set token-count
              new-owner
              (+ current-balance u1)
            )
            (ok true)))
        error (err (* error u10002)))))

;; Non-custodial marketplace
(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? skullcoin-souls id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? skullcoin-souls id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm)}))
    (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
    (map-set market id listing)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)))

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
    (map-delete market id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)))
	
(define-public (buy-in-ustx (id uint) (comm <commission-trait>))
  (let ((owner (unwrap! (nft-get-owner? skullcoin-souls id) ERR-NOT-FOUND))
      (listing (unwrap! (map-get? market id) ERR-LISTING))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))