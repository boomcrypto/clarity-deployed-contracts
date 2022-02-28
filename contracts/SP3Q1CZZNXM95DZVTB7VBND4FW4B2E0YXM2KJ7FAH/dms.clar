(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait commission-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.commission-trait.commission)


(define-non-fungible-token demo-nfts uint)

;; Storage
(define-map token-count principal uint)
(define-map minted principal bool)
(define-map market uint {price: uint, commission: principal})
(define-map token-info uint (string-ascii 200))

;; Define Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-SOLD-OUT (err u300))
(define-constant ERR-WRONG-COMMISSION (err u301))
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-METADATA-FROZEN (err u505))
(define-constant ERR-MINT-ALREADY-SET (err u506))
(define-constant ERR-LISTING (err u507))
(define-constant ERR-NOT-ACTIVE (err u508))
(define-constant ERR-ONE-MINT-PER-WALLET (err u508))
(define-constant ERR-BEFORE-MINT-TIME (err u509))
(define-constant ERR-AFTER-MINT-TIME (err u510))


;; Define Variables
(define-data-var last-id uint u0)
(define-data-var start-block uint u0) ;;set these at time of deployment
(define-data-var end-block uint u45229) ;;set these at time of deployment
(define-data-var metadata-frozen bool false)
(define-data-var active bool true)
(define-data-var stx-cost-per-mint uint u45000000)
(define-data-var commission-1 uint u400)
(define-data-var commission-2 uint u200)
(define-data-var base-uri (string-ascii 100) "ipfs://placeholder/")
(define-data-var contract-uri (string-ascii 100) "ipfs://placeholder")
(define-data-var commission-one-address principal 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
(define-data-var artist-address principal 'ST3ZJP253DENMN3CQFEQSPZWY7DK35EH3SD98HKWK)
(define-data-var wallet-1 principal 'ST3S21WY0A8YQK9MSHVW4E4YYTSE696MSHJZRFEW7)
(define-data-var wallet-2 principal 'ST3GDV2YWE3E4CGZK4NYM2YASZ82G8E4AC7H9EDN5)
(define-data-var wallet-3 principal 'ST1BX0P4MZ5A3A5JCH0E10YNS170QFR2VQ6AM6VZK)
(define-data-var royalty-1 uint u100)
(define-data-var royalty-2 uint u100)
(define-data-var royalty-3 uint u100)
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
  (match (nft-transfer? demo-nfts id sender recipient)
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
  ;; Make sure to replace demo-nfts
  (ok (nft-get-owner? demo-nfts id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
    (ok (var-get last-id))
)

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (token-id uint))
    (ok (map-get? token-info token-id))
)

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-total-royalty)
  (ok (+ (+ (var-get royalty-1) (var-get royalty-2)) (var-get royalty-3)))
)

(define-read-only (get-contract-uri)
  (ok (var-get contract-uri)))

(define-public (mint (new-owner principal) (metadata (string-ascii 200)))
    (let (
        (next-id (+ u1 (var-get last-id)))
    )
      (asserts! (var-get active) ERR-NOT-ACTIVE)
      (match (nft-mint? demo-nfts next-id new-owner)
        success
        (let
        ((current-balance (get-balance new-owner)))
          (begin
            (var-set last-id next-id)
            (map-set token-count
              new-owner
              (+ current-balance u1)
            )
            (map-set minted new-owner true)
            (map-set token-info next-id metadata)
            (ok true)))
        error (err (* error u10000)))))

(define-public (burn (id uint) (owner principal))
    (let (
        (token-owner (unwrap-panic (unwrap-panic (get-owner id))))
    )
    (asserts! (is-eq tx-sender owner) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq tx-sender token-owner) ERR-NOT-AUTHORIZED)
    (match (nft-burn? demo-nfts id owner)
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
  (let ((owner (unwrap! (nft-get-owner? demo-nfts id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? demo-nfts id) ERR-NOT-FOUND))
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
    (asserts! (is-eq tx-sender .demo-nfts-mint) ERR-NOT-AUTHORIZED)
    (asserts! (and (is-none the-mint)
              (map-insert mint-address true tx-sender))
                ERR-MINT-ALREADY-SET)
    (ok tx-sender)))

;; set start time
(define-public (set-start (new-start uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set start-block new-start)
    (ok true)))

;; set end time
(define-public (set-end (new-end uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set end-block new-end)
    (ok true)))

;; set end time
(define-public (flip-active)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set active (not (var-get active)))
    (ok true)))

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

