(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait commission-trait .commission-trait.commission)

(define-non-fungible-token bitcoin-monkeys-labs uint)

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
(define-constant BANANA-MINT-LIMIT u5000)
(define-constant STX-MINT-LIMIT u3500)


;; Define Variables
(define-data-var last-id uint u0)
(define-data-var iterator uint STX-MINT-LIMIT)
(define-data-var start-block uint u0) ;;set these at time of deployment
(define-data-var end-block uint u45229) ;;set these at time of deployment
(define-data-var metadata-frozen bool false)
(define-data-var stx-cost-per-mint uint u45000000)
(define-data-var banana-cost-per-mint uint u500000000)
(define-data-var banana-burn-rate uint u0)
(define-data-var banana-vault-address principal .banana-vault)
(define-data-var banana-sales uint u0)
(define-data-var banana-volume uint u0)
(define-data-var banana-burns uint u0)
(define-data-var commission-1 uint u400)
(define-data-var commission-2 uint u200)
(define-data-var base-uri (string-ascii 100) "ipfs://placeholder/")
(define-data-var contract-uri (string-ascii 100) "ipfs://placeholder")
(define-data-var commission-one-address principal 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C)
(define-data-var commission-two-address principal 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S)
(define-data-var artist-address principal 'SP1RS2VFY0K4A2Z006QBJDYHE2RJ6F63KV0JSSXFE)
(define-data-var wallet-1 principal 'SP2C51WENENTF44Z6F56BJT1F42S3BSDR7R5QCBHE)
(define-data-var wallet-2 principal 'SP3ZJP253DENMN3CQFEQSPZWY7DK35EH3SEH0J8PK)
(define-data-var wallet-3 principal 'SP3GDV2YWE3E4CGZK4NYM2YASZ82G8E4AC7C9CFQT)
(define-data-var royalty-1 uint u650)
(define-data-var royalty-2 uint u100)
(define-data-var royalty-3 uint u0)
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
  (match (nft-transfer? bitcoin-monkeys-labs id sender recipient)
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
  ;; Make sure to replace bitcoin-monkeys-labs
  (ok (nft-get-owner? bitcoin-monkeys-labs id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (if (< (var-get last-id) STX-MINT-LIMIT)
    (ok (var-get last-id))
    (ok (var-get iterator))
  )
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

(define-read-only (get-last-m1)
    (ok (var-get last-id))
)

(define-read-only (get-last-m2)
    (ok (var-get iterator))
)

(define-read-only (get-stats)
    (list (var-get banana-sales) (var-get banana-volume) (var-get banana-burns))
)

(define-read-only (get-contract-uri)
  (ok (var-get contract-uri)))

;; Mint new NFT
;; can only be called from the Mint
(define-public (banana-mint (new-owner principal))
    (let (
        (next-id (+ u1 (var-get iterator)))
        (to-burn (/ (* (var-get banana-cost-per-mint) (var-get banana-burn-rate)) u10000))
        (to-vault (- (var-get banana-cost-per-mint) to-burn))
    )
    (begin
      (asserts! (called-from-mint) ERR-NOT-AUTHORIZED)
      (asserts! (< (var-get iterator) BANANA-MINT-LIMIT) ERR-SOLD-OUT)
      (match (nft-mint? bitcoin-monkeys-labs next-id new-owner)
        success
        (let
        ((current-balance (get-balance new-owner)))
          (begin
            (if (> to-burn u0)
              (begin
                (try! (contract-call? .btc-monkeys-bananas burn to-burn))
                (try! (contract-call? .btc-monkeys-bananas transfer to-vault tx-sender (var-get banana-vault-address) (some 0x00)))
              )
              (try! (contract-call? .btc-monkeys-bananas transfer to-vault tx-sender (var-get banana-vault-address) (some 0x00)))
            )
            (var-set iterator next-id)
            (var-set banana-sales (+ (var-get banana-sales) u1))
            (var-set banana-volume (+ (var-get banana-volume) (var-get banana-cost-per-mint)))
            (var-set banana-burns (+ (var-get banana-burns) to-burn))
            (print to-burn)
            (print to-vault)
            (print (var-get banana-cost-per-mint))
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
        (commission-two (/ (* price (var-get commission-2)) u10000))
        (payout (- price (+ commission-one commission-two)))
    )
      (asserts! (called-from-mint) ERR-NOT-AUTHORIZED)
      (asserts! (< (var-get last-id) STX-MINT-LIMIT) ERR-SOLD-OUT)
      (match (nft-mint? bitcoin-monkeys-labs next-id new-owner)
        success
        (let
        ((current-balance (get-balance new-owner)))
          (begin
            (print "mint in stx")
            (try! (stx-transfer? commission-one tx-sender (var-get commission-one-address)))
            (try! (stx-transfer? commission-two tx-sender (var-get commission-two-address)))
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
    (asserts! (is-eq tx-sender owner) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq tx-sender token-owner) ERR-NOT-AUTHORIZED)
    (match (nft-burn? bitcoin-monkeys-labs id owner)
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
  (let ((owner (unwrap! (nft-get-owner? bitcoin-monkeys-labs id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? bitcoin-monkeys-labs id) ERR-NOT-FOUND))
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

(define-public (set-vault-address (address principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set banana-vault-address address)
    (ok true)))

;; set end time
(define-public (set-burn-rate (burn-rate uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set banana-burn-rate burn-rate)
    (ok true)))

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

(define-public (admin-airdrop (addresses (list 52 principal)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (print (map airdrop addresses))
    (ok true)
  )
)

(define-public (airdrop (address principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (try! (nft-mint? bitcoin-monkeys-labs (+ (var-get last-id) u1) address))
    (var-set last-id (+ (var-get last-id) u1))
    (ok (var-get last-id))
  )
)