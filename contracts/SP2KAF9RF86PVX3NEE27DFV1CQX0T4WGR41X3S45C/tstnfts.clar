(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait commission-trait .commission-trait.commission)

(define-non-fungible-token testnfts uint)

;; Storage
(define-map token-count principal uint)
(define-map minted principal bool)
(define-map market uint {price: uint, commission: principal})

;; Define Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-SOLD-OUT (err u300))
(define-constant ERR-WRONG-COMMISSION (err u301))
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-METADATA-FROZEN (err u505))
(define-constant ERR-MINT-ALREADY-SET (err u506))
(define-constant ERR-LISTING (err u507))
(define-constant ERR-ONE-MINT-PER-WALLET (err u508))
(define-constant ERR-BEFORE-MINT-TIME (err u509))
(define-constant ERR-AFTER-MINT-TIME (err u510))
(define-constant STX-MINT-LIMIT u100)


;; Define Variables
(define-data-var last-id uint u0)
(define-data-var metadata-frozen bool false)
(define-data-var stx-cost-per-mint uint u10000)
(define-data-var banana-cost-per-mint uint u10000)
(define-data-var commission-1 uint u1000)
(define-data-var base-uri (string-ascii 100) "ipfs://placeholder/")
(define-data-var contract-uri (string-ascii 100) "ipfs://placeholder")
(define-data-var commission-one-address principal 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C)
(define-data-var artist-address principal 'SPJ6EME4DQ8242ZDR56VAVB7R9PAY0ZBV1640EQX)
(define-map mint-address bool principal)

;; Token count for account
(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

;; Get minted
(define-read-only (get-minted (account principal))
  (default-to false
    (map-get? minted account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? testnfts id sender recipient)
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

;; SIP009: Transfer token to a specified principal
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? market id)) ERR-LISTING)
    (trnsfr id sender recipient)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (id uint))
  ;; Make sure to replace testnfts
  (ok (nft-get-owner? testnfts id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
    (ok (var-get last-id))
)

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (token-id uint))
  (if (< token-id u5001)
    (ok (some (concat (concat (var-get base-uri) (unwrap-panic (contract-call? .conversion lookup token-id))) ".json")))
    (ok (some (concat (concat (var-get base-uri) (unwrap-panic (contract-call? .conversion-v2 lookup (- token-id u5001)))) ".json")))
    )
)

(define-read-only (get-contract-uri)
  (ok (var-get contract-uri)))

;; Mint new NFT
;; can only be called from the Mint
(define-public (banana-mint (new-owner principal))
    (let (
        (next-id (+ u1 (var-get last-id)))
        (price (var-get banana-cost-per-mint))
        (commission-one (/ (* price (var-get commission-1)) u10000))
        (payout (- price commission-one))
    )
    (begin
      (asserts! (called-from-mint) ERR-NOT-AUTHORIZED)
      (asserts! (< (var-get last-id) STX-MINT-LIMIT) ERR-SOLD-OUT)
      (match (nft-mint? testnfts next-id new-owner)
        success
        (let
        ((current-balance (get-balance new-owner)))
          (begin
            (try! (contract-call? .bananas transfer commission-one tx-sender (var-get commission-one-address) (some 0x00)))
            (try! (contract-call? .bananas transfer payout tx-sender (var-get artist-address) (some 0x00)))
            (var-set last-id next-id)
            (map-set token-count
              new-owner
              (+ current-balance u1)
            )
            (map-set minted new-owner true)
            (ok true)))
        error (err (* error u10000)))
    )
  )
)

(define-public (stx-mint (new-owner principal))
    (let (
        (next-id (+ u1 (var-get last-id)))
        (price (var-get stx-cost-per-mint))
        (commission-one (/ (* price (var-get commission-1)) u10000))
        (payout (- price commission-one))
    )
      (asserts! (called-from-mint) ERR-NOT-AUTHORIZED)
      (asserts! (< (var-get last-id) STX-MINT-LIMIT) ERR-SOLD-OUT)
      (match (nft-mint? testnfts next-id new-owner)
        success
        (let
        ((current-balance (get-balance new-owner)))
          (begin
            (print "mint in stx")
            (try! (stx-transfer? commission-one tx-sender (var-get commission-one-address)))
            (try! (stx-transfer? payout tx-sender (var-get artist-address)))
            (var-set last-id next-id)
            (map-set token-count
              new-owner
              (+ current-balance u1)
            )
            (map-set minted new-owner true)
            (ok true)))
        error (err (* error u10000)))))

(define-public (burn (id uint) (owner principal))
    (let (
        (token-owner (unwrap-panic (unwrap-panic (get-owner id))))
    )
    (asserts! (is-none (map-get? market id)) ERR-LISTING)
    (asserts! (is-eq tx-sender owner) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq tx-sender token-owner) ERR-NOT-AUTHORIZED)
    (match (nft-burn? testnfts id owner)
        success
        (let
        ((current-balance (get-balance owner)))
          (begin
            (map-set token-count
              owner
              (- current-balance u1)
            )
            (ok true)))
        error (err (* error u10000)))
    )
)

(define-private (is-sender-owner (id uint))
  (let ((owner (unwrap! (nft-get-owner? testnfts id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? testnfts id) ERR-NOT-FOUND))
      (listing (unwrap! (map-get? market id) ERR-LISTING))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))

;; Set base uri
(define-public (set-base-uri (new-base-uri (string-ascii 100)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (not (var-get metadata-frozen)) ERR-METADATA-FROZEN)
    (var-set base-uri new-base-uri)
    (ok true)))

;; Set contract uri
(define-public (set-contract-uri (new-contract-uri (string-ascii 100)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (not (var-get metadata-frozen)) ERR-METADATA-FROZEN)
    (var-set contract-uri new-contract-uri)
    (ok true))
)

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

;; can only be called once
(define-public (set-mint-address)
  (let ((the-mint (map-get? mint-address true)))
    (asserts! (and (is-none the-mint)
              (map-insert mint-address true tx-sender))
                ERR-MINT-ALREADY-SET)
    (ok tx-sender)))

;; set end time
(define-public (set-banana-cost (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set banana-cost-per-mint amount)
    (ok true)))

(define-public (set-stx-cost (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set stx-cost-per-mint amount)
    (ok true)))

(define-public (set-artist-address (address principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set artist-address address)
    (ok true)))