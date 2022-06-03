(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;; (impl-trait .nft-trait.nft-trait)
(use-trait commission-trait .commission-trait.commission)

(define-non-fungible-token mythical uint)

;; Storage
(define-map token-count principal uint)
(define-map minted principal bool)
(define-map market uint {price: uint, commission: principal})

;; Define Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-SOLD-OUT (err u300))
(define-constant ERR-WRONG-COMMISSION (err u301))
(define-constant ERR-INSUFFICIENT-FUNDS (err u400))
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-METADATA-FROZEN (err u505))
(define-constant ERR-MINT-ALREADY-SET (err u506))
(define-constant ERR-LISTING (err u507))
(define-constant ERR-ONE-MINT-PER-WALLET (err u508))
(define-constant ERR-BEFORE-MINT-TIME (err u509))
(define-constant ERR-AFTER-MINT-TIME (err u510))
(define-constant MINT-LIMIT u2500)

;; Define Variables
(define-data-var last-id uint u0)
(define-data-var metadata-frozen bool false)
(define-data-var stx-cost-per-mint uint u60000000)
(define-data-var base-uri (string-ascii 100) "ipfs://placeholder_hash/")
(define-data-var contract-uri (string-ascii 100) "ipfs://placeholder")

(define-data-var commission-percentage uint u1000)  
(define-data-var commission-address principal 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C)
;; (define-data-var commission-address principal 'ST3PF13W7Z0RRM42A8VZRVFQ75SV1K26RXEP8YGKJ)
(define-data-var royalty (list 1000 uint) (list u9000))
(define-data-var artist-address (list 1000 principal) (list 'SP23S6MAB11EVBRE04SFBF53ZV39S757PJY53VN53)) 
;; (define-data-var artist-address (list 1000 principal) (list 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)) 
(define-data-var admin principal 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C)
;; (define-data-var admin principal 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

(define-map mint-address bool principal)

;; Get mint limit
(define-read-only (get-mint-limit)
  MINT-LIMIT
)

;; Token count for account
(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

;; Get minted
(define-read-only (get-minted (account principal))
  (default-to false
    (map-get? minted account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? mythical id sender recipient)
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
  ;; Make sure to replace mythical
  (ok (nft-get-owner? mythical id)))

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
(define-public (mint (new-owner principal))
    (let (
        (next-id (+ u1 (var-get last-id)))
    )
      (asserts! (called-from-mint) ERR-NOT-AUTHORIZED)
      (asserts! (< (var-get last-id) MINT-LIMIT) ERR-SOLD-OUT)
      (match (nft-mint? mythical next-id new-owner)
        success
        (let
        ((current-balance (get-balance new-owner)))
          (begin
            ;; (print payout)
            (try! (payout))
            (var-set last-id next-id)
            (map-set token-count
              new-owner
              (+ current-balance u1)
            )
            (ok true)))
        error (err (* error u10000)))))

(define-private (payout)
  (let (
    (price (var-get stx-cost-per-mint))
    (commission-amount (/ (* price (var-get commission-percentage)) u10000))
    (price-list (contract-call? .uint-lists lookup price (len (var-get royalty))))
    (divider-list (contract-call? .uint-lists lookup u10000 (len (var-get royalty))))
    (royalty-amounts (map * (var-get royalty) price-list))
    (payout-amounts (map / royalty-amounts divider-list))
  )
    (asserts! (>= (stx-get-balance tx-sender) price) ERR-INSUFFICIENT-FUNDS)
    (try! (stx-transfer? commission-amount tx-sender (var-get commission-address)))
    (map pay (var-get artist-address) payout-amounts)
    (ok payout-amounts)
  )
)

(define-private (pay (receiver principal) (amount uint))
  (stx-transfer? amount tx-sender receiver)
)

(define-public (admin-mint (new-owner principal))
    (let (
        (next-id (+ u1 (var-get last-id)))
    )
      (asserts! (or (is-some (index-of (var-get artist-address) tx-sender)) (is-eq tx-sender (var-get admin))) ERR-NOT-AUTHORIZED)
      (asserts! (< (var-get last-id) MINT-LIMIT) ERR-SOLD-OUT)
      (match (nft-mint? mythical next-id new-owner)
        success
        (let
        ((current-balance (get-balance new-owner)))
          (begin
            (var-set last-id next-id)
            (map-set token-count
              new-owner
              (+ current-balance u1)
            )
            (ok true)))
        error (err (* error u10000)))))

(define-public (burn (id uint) (owner principal))
    (let (
        (token-owner (unwrap-panic (unwrap-panic (get-owner id))))
    )
    (asserts! (is-none (map-get? market id)) ERR-LISTING)
    (asserts! (is-eq tx-sender owner) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq tx-sender token-owner) ERR-NOT-AUTHORIZED)
    (match (nft-burn? mythical id owner)
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
  (let ((owner (unwrap! (nft-get-owner? mythical id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? mythical id) ERR-NOT-FOUND))
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

(define-public (set-stx-cost (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set stx-cost-per-mint amount)
    (ok true)))
  
;; ###### BEGIN: banana fungible token code ##################################################
(define-data-var banana-cost-per-mint uint u85000000)

(define-public (banana-mint (new-owner principal))
    (let (
        (next-id (+ u1 (var-get last-id)))
    )
      (asserts! (called-from-mint) ERR-NOT-AUTHORIZED)
      (asserts! (< (var-get last-id) MINT-LIMIT) ERR-SOLD-OUT)
      (match (nft-mint? mythical next-id new-owner)
        success
        (let
        ((current-balance (get-balance new-owner)))
          (begin
            ;; (print payout)
            (try! (banana-payout))
            (var-set last-id next-id)
            (map-set token-count
              new-owner
              (+ current-balance u1)
            )
            (ok true)))
        error (err (* error u10000)))))

(define-private (banana-payout)
  (let (
    (price (var-get banana-cost-per-mint))
    (commission-amount (/ (* price (var-get commission-percentage)) u10000))
    (price-list (contract-call? .uint-lists lookup price (len (var-get royalty))))
    (divider-list (contract-call? .uint-lists lookup u10000 (len (var-get royalty))))
    (royalty-amounts (map * (var-get royalty) price-list))
    (payout-amounts (map / royalty-amounts divider-list))
  )
    (asserts! (>= (unwrap-panic (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-bananas get-balance tx-sender)) price) ERR-INSUFFICIENT-FUNDS)
    (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-bananas transfer commission-amount tx-sender (var-get commission-address) (some 0x00)))
    (map banana-pay (var-get artist-address) payout-amounts)
    (ok payout-amounts)
  )
)

(define-private (banana-pay (receiver principal) (amount uint))
  (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-bananas transfer amount tx-sender receiver (some 0x00))
)

(define-public (set-banana-cost (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set banana-cost-per-mint amount)
    (ok true)))
;; ###### END: banana fungible token mint template code ##################################################

;; ###### BEGIN: slime-token fungible token code ##################################################
(define-data-var slime-cost-per-mint uint u150000000)

(define-public (slime-mint (new-owner principal))
    (let (
        (next-id (+ u1 (var-get last-id)))
    )
      (asserts! (called-from-mint) ERR-NOT-AUTHORIZED)
      (asserts! (< (var-get last-id) MINT-LIMIT) ERR-SOLD-OUT)
      (match (nft-mint? mythical next-id new-owner)
        success
        (let
        ((current-balance (get-balance new-owner)))
          (begin
            ;; (print payout)
            (try! (slime-payout))
            (var-set last-id next-id)
            (map-set token-count
              new-owner
              (+ current-balance u1)
            )
            (ok true)))
        error (err (* error u10000)))))

(define-private (slime-payout)
  (let (
    (price (var-get slime-cost-per-mint))
    (commission-amount (/ (* price (var-get commission-percentage)) u10000))
    (price-list (contract-call? .uint-lists lookup price (len (var-get royalty))))
    (divider-list (contract-call? .uint-lists lookup u10000 (len (var-get royalty))))
    (royalty-amounts (map * (var-get royalty) price-list))
    (payout-amounts (map / royalty-amounts divider-list))
  )
    (asserts! (>= (unwrap-panic (contract-call? 'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7.slime-token get-balance tx-sender)) price) ERR-INSUFFICIENT-FUNDS)
    (map slime-pay (var-get artist-address) payout-amounts)
    (try! (contract-call? 'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7.slime-token transfer commission-amount tx-sender (var-get commission-address) (some 0x00)))
    (ok payout-amounts)
  )
)

(define-private (slime-pay (receiver principal) (amount uint))
  (contract-call? 'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7.slime-token transfer amount tx-sender receiver (some 0x00))
)

(define-public (set-slime-cost (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set slime-cost-per-mint amount)
    (ok true)))
;; ###### END: slime-token fungible token mint template code ##################################################