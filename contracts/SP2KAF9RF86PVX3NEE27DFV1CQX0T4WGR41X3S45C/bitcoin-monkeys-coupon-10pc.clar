(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait commission-trait .commission-trait.commission)

;; Name of the contract
(define-non-fungible-token bitcoin-monkeys-coupon-10pc uint)

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
(define-constant ERR-LISTING (err u507))

;; Define Variables
(define-data-var last-id uint u0)
(define-data-var base-uri (string-ascii 100) "ipfs://placeholder/")
(define-data-var contract-uri (string-ascii 100) "ipfs://placeholder")
(define-data-var admin-address principal 'SP3B6T2P3C0XEH4RRFP9A4N1RAEWFNNVYFDHE538Y)
(define-data-var wallet-1 principal 'SP2C51WENENTF44Z6F56BJT1F42S3BSDR7R5QCBHE)
(define-data-var wallet-2 principal 'SP3ZJP253DENMN3CQFEQSPZWY7DK35EH3SEH0J8PK)
(define-data-var wallet-3 principal 'SP3GDV2YWE3E4CGZK4NYM2YASZ82G8E4AC7C9CFQT)
(define-data-var royalty-1 uint u650)
(define-data-var royalty-2 uint u100)
(define-data-var royalty-3 uint u0)

;; Token count for account
(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? bitcoin-monkeys-coupon-10pc id sender recipient)
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
  ;; Make sure to replace bitcoin-monkeys-coupon-10pc
  (ok (nft-get-owner? bitcoin-monkeys-coupon-10pc id)))

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

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-total-royalty)
  (ok (+ (+ (var-get royalty-1) (var-get royalty-2)) (var-get royalty-3)))
)

(define-read-only (get-contract-uri)
  (ok (var-get contract-uri)))

;; Mint new NFT
(define-public (mint (new-owner principal))
    (let (
        (next-id (+ u1 (var-get last-id)))
    )
      (asserts! (or (is-eq tx-sender CONTRACT-OWNER) (is-eq tx-sender (var-get admin-address))) ERR-NOT-AUTHORIZED)
      (match (nft-mint? bitcoin-monkeys-coupon-10pc next-id new-owner)
        success
        (let
        ((current-balance (get-balance new-owner)))
          (begin
            (var-set last-id next-id)
            (map-set token-count new-owner (+ current-balance u1))
            (ok true)))
        error (err (* error u10000)))))

(define-public (burn (id uint) (owner principal))
    (let (
        (token-owner (unwrap-panic (unwrap-panic (get-owner id))))
    )
    (asserts! (is-eq tx-sender owner) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq tx-sender token-owner) ERR-NOT-AUTHORIZED)
    (match (nft-burn? bitcoin-monkeys-coupon-10pc id owner)
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
  (let ((owner (unwrap! (nft-get-owner? bitcoin-monkeys-coupon-10pc id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? bitcoin-monkeys-coupon-10pc id) ERR-NOT-FOUND))
      (listing (unwrap! (map-get? market id) ERR-LISTING))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (pay-royalty price))
    (try! (contract-call? comm pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))


(define-private (pay-royalty (price uint))
    (let (
        (royalty-one (/ (* price (var-get royalty-1)) u10000))
        (royalty-two (/ (* price (var-get royalty-2)) u10000))
        (royalty-three (/ (* price (var-get royalty-3)) u10000))
    )
    (if (> (var-get royalty-1) u0)
        (try! (stx-transfer? royalty-one tx-sender (var-get wallet-1)))
        (print false)
    )
    (if (> (var-get royalty-2) u0)
        (try! (stx-transfer? royalty-two tx-sender (var-get wallet-2)))
        (print false)
    )
    (if (> (var-get royalty-3) u0)
        (try! (stx-transfer? royalty-three tx-sender (var-get wallet-3)))
        (print false)
    )
    (ok true)
    )
)

;; Set base uri
(define-public (set-base-uri (new-base-uri (string-ascii 100)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set base-uri new-base-uri)
    (ok true)))

;; Set contract uri
(define-public (set-contract-uri (new-contract-uri (string-ascii 100)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set contract-uri new-contract-uri)
    (ok true))
)

;; Update admin address
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (or (is-eq tx-sender CONTRACT-OWNER) (is-eq tx-sender (var-get admin-address))) ERR-NOT-AUTHORIZED)
    (var-set admin-address new-admin)
    (ok true))
)

;; set wallet-1
(define-public (set-wallet-1 (new-wallet principal))
  (begin
    (asserts! (is-eq tx-sender (var-get wallet-1)) ERR-NOT-AUTHORIZED)
    (var-set wallet-1 new-wallet)
    (ok true)))

;; set wallet-2
(define-public (set-wallet-2 (new-wallet principal))
  (begin
    (asserts! (is-eq tx-sender (var-get wallet-2)) ERR-NOT-AUTHORIZED)
    (var-set wallet-2 new-wallet)
    (ok true)))

;; set wallet-3
(define-public (set-wallet-3 (new-wallet principal))
  (begin
    (asserts! (is-eq tx-sender (var-get wallet-3)) ERR-NOT-AUTHORIZED)
    (var-set wallet-3 new-wallet)
    (ok true)))

;; set wallet-1
(define-public (set-royalty-1 (new-royalty uint))
  (begin
    (asserts! (is-eq tx-sender (var-get wallet-1)) ERR-NOT-AUTHORIZED)
    (var-set royalty-1 new-royalty)
    (ok true)))

;; set wallet-2
(define-public (set-royalty-2 (new-royalty uint))
  (begin
    (asserts! (is-eq tx-sender (var-get wallet-2)) ERR-NOT-AUTHORIZED)
    (var-set royalty-2 new-royalty)
    (ok true)))

;; set wallet-3
(define-public (set-royalty-3 (new-royalty uint))
  (begin
    (asserts! (is-eq tx-sender (var-get wallet-3)) ERR-NOT-AUTHORIZED)
    (var-set royalty-3 new-royalty)
    (ok true)))
