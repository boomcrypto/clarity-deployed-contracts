(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait commission-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.commission-trait.commission)

;; Name of the contract
(define-non-fungible-token test uint)

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
(define-constant MINT-NOT-LIVE (err u508))
(define-constant ERR-MINTED-OUT (err u509))
(define-constant MINT-LIMIT u100)

;; Define Variables
(define-data-var last-id uint u0)
(define-data-var base-uri (string-ascii 100) "ipfs://placeholder/")
(define-data-var contract-uri (string-ascii 100) "ipfs://placeholder")
(define-data-var mint-price uint u50000000)
(define-data-var commission-percent uint u800)
(define-data-var payout-one uint u4000)
(define-data-var payout-two uint u200)
(define-data-var payout-three uint u4000)
(define-data-var admin-address principal 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C)
(define-data-var commission-address principal 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C)
(define-data-var wallet-1 principal 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C)
(define-data-var wallet-2 principal 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C)
(define-data-var wallet-3 principal 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C)
(define-data-var mint-live bool false)


(define-public (claim)
    (begin
        (try! (mint tx-sender))
        (ok true)
    )
)

(define-public (claim-two)
    (begin
        (try! (mint tx-sender))
        (try! (mint tx-sender))
        (ok true)
    )
)

(define-public (claim-three)
    (begin
        (try! (mint tx-sender))
        (try! (mint tx-sender))
        (try! (mint tx-sender))
        (ok true)
    )
)

(define-public (claim-four)
    (begin
        (try! (mint tx-sender))
        (try! (mint tx-sender))
        (try! (mint tx-sender))
        (try! (mint tx-sender))
        (ok true)
    )
)

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

;; Token count for account
(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? test id sender recipient)
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
  ;; Make sure to replace test
  (ok (nft-get-owner? test id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id))
)

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (token-id uint))
  (if (< token-id u5001)
    (ok (some (concat (concat (var-get base-uri) (unwrap-panic (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.conversion lookup token-id))) ".json")))
    (ok (some (concat (concat (var-get base-uri) (unwrap-panic (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.conversion-v2 lookup (- token-id u5001)))) ".json")))
    )
)

(define-read-only (get-contract-uri)
  (ok (var-get contract-uri)))

;; Mint new NFT
(define-private (mint (new-owner principal))
    (let (
        (next-id (+ u1 (var-get last-id)))
        (price (var-get mint-price))
        (comm (/ (* price (var-get commission-percent)) u10000))
        (payout-1 (/ (* price (var-get payout-one)) u10000))
        (payout-2 (/ (* price (var-get payout-two)) u10000))
        (payout-3 (/ (* price (var-get payout-three)) u10000))
    )
      (asserts! (is-eq (var-get mint-live) true) MINT-NOT-LIVE)
      (asserts! (< (var-get last-id) MINT-LIMIT) ERR-MINTED-OUT)
      (match (nft-mint? test next-id new-owner)
        success
        (let
        ((current-balance (get-balance new-owner)))
          (begin
            (try! (stx-transfer? comm tx-sender (var-get commission-address)))
            (try! (stx-transfer? payout-1 tx-sender (var-get wallet-1)))
            (try! (stx-transfer? payout-2 tx-sender (var-get wallet-2)))
            (try! (stx-transfer? payout-3 tx-sender (var-get wallet-3)))
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
    (match (nft-burn? test id owner)
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
  (let ((owner (unwrap! (nft-get-owner? test id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? test id) ERR-NOT-FOUND))
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

;; Flip live
(define-public (set-mint (status bool))
  (begin
    (asserts! (or (is-eq tx-sender CONTRACT-OWNER) (is-eq tx-sender (var-get admin-address))) ERR-NOT-AUTHORIZED)
    (var-set mint-live status)
    (ok true)
  )
)

;; Change mint price
(define-public (set-mint-price (amount uint))
  (begin
    (asserts! (or (is-eq tx-sender CONTRACT-OWNER) (is-eq tx-sender (var-get admin-address))) ERR-NOT-AUTHORIZED)
    (var-set mint-price amount)
    (ok true)
  )
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

(define-public (set-comm-1 (amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get wallet-1)) ERR-NOT-AUTHORIZED)
    (var-set payout-one amount)
    (ok true)))

;; set wallet-2
(define-public (set-comm-2 (amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get wallet-2)) ERR-NOT-AUTHORIZED)
    (var-set payout-two amount)
    (ok true)))

;; set wallet-3
(define-public (set-comm-3 (amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get wallet-3)) ERR-NOT-AUTHORIZED)
    (var-set payout-three amount)
    (ok true)))