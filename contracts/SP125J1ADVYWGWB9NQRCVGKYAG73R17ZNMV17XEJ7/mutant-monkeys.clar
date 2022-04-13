(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait commission-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.commission-trait.commission)
(use-trait staking-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.staking-trait.staking)
(use-trait lookup-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.lookup-trait.lookup-trait)

(define-non-fungible-token mutant-monkeys uint)

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
(define-constant ERR-LISTING (err u507))
(define-constant ERR-MONKEY-STAKED (err u508))
(define-constant ERR-NOT-ENOUGH-STX (err u509))
(define-constant MINT-LIMIT u5000)


;; Define Variables
(define-data-var last-id uint u0)
(define-data-var metadata-frozen bool false)
(define-data-var base-uri (string-ascii 100) "ipfs://placeholder/")
(define-data-var contract-uri (string-ascii 100) "ipfs://placeholder")
(define-data-var artist-address principal 'SP1RS2VFY0K4A2Z006QBJDYHE2RJ6F63KV0JSSXFE)
(define-data-var admins (list 1000 principal) (list 'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7 'SPM8EYQKX80FFNVRV7F877TEAYZVYJX0WQ2Z4PJN 'SPGCBABRBWZ3EQNXP94VBNQMJYW1QN0RN0054VKF 'SP1PTRJMNEBVJDJ29W3DKWDEMQ29D3AFAKGSYBXFZ 'SP7VK7V27R0H2C7WRR378457WX8VX1Q32RCZRV6H 'SP4RPAM72DWTCXFQXTQ35PTSEC0CDAW4QB5Z5QZR))
(define-data-var wallets (list 1000 principal) (list 'SPM8EYQKX80FFNVRV7F877TEAYZVYJX0WQ2Z4PJN 'SP3ZJP253DENMN3CQFEQSPZWY7DK35EH3SEH0J8PK 'SP3GDV2YWE3E4CGZK4NYM2YASZ82G8E4AC7C9CFQT))
(define-data-var royalties (list 1000 uint) (list u500 u100 u0))
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
  (match (nft-transfer? mutant-monkeys id sender recipient)
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
    (asserts! (is-none (index-of (contract-call? .mutant-staking get-staked-nfts tx-sender .mutant-monkeys) id)) ERR-MONKEY-STAKED)
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? market id)) ERR-LISTING)
    (trnsfr id sender recipient)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (id uint))
  ;; Make sure to replace mutant-monkeys
  (ok (nft-get-owner? mutant-monkeys id)))

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

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-total-royalty)
  (fold + (var-get royalties) u0)
)

(define-read-only (get-contract-uri)
  (ok (var-get contract-uri)))

(define-public (mint (id uint))
    (let (
        (new-owner tx-sender)
    )
      (asserts! (is-eq (unwrap-panic (unwrap-panic (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-monkeys-labs get-owner id))) tx-sender) ERR-NOT-AUTHORIZED)
      (asserts! (< (var-get last-id) MINT-LIMIT) ERR-SOLD-OUT)
      (match (nft-mint? mutant-monkeys id new-owner)
        success
        (let
        ((current-balance (get-balance new-owner)))
          (begin
            (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-monkeys-labs burn id new-owner))
            (var-set last-id (+ u1 (var-get last-id)))
            (map-set token-count
              new-owner
              (+ current-balance u1)
            )
            (map-set minted new-owner true)
            (ok true)))
        error (err (* error u10000)))))

(define-public (admin-mint (id uint))
    (let (
        (new-owner tx-sender)
    )
      (asserts! (is-eq (unwrap-panic (unwrap-panic (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-monkeys-labs get-owner id))) tx-sender) ERR-NOT-AUTHORIZED)
      (asserts! (< (var-get last-id) MINT-LIMIT) ERR-SOLD-OUT)
      (asserts! (is-some (index-of (var-get admins) tx-sender)) ERR-NOT-AUTHORIZED)
      (match (nft-mint? mutant-monkeys id new-owner)
        success
        (let
        ((current-balance (get-balance new-owner)))
          (begin
            (var-set last-id (+ u1 (var-get last-id)))
            (map-set token-count
              new-owner
              (+ current-balance u1)
            )
            (map-set minted new-owner true)
            (ok true)))
        error (err (* error u10000)))))

(define-private (mint-many-iter (id uint) (new-owner principal))
    (begin
      (asserts! (is-eq (unwrap-panic (unwrap-panic (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-monkeys-labs get-owner id))) tx-sender) ERR-NOT-AUTHORIZED)
      (asserts! (< (var-get last-id) MINT-LIMIT) ERR-SOLD-OUT)
      (match (nft-mint? mutant-monkeys id new-owner)
        success
        (let
        ((current-balance (get-balance new-owner)))
          (begin
            (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-monkeys-labs burn id new-owner))
            (var-set last-id (+ u1 (var-get last-id)))
            (map-set token-count
              new-owner
              (+ current-balance u1)
            )
            (map-set minted new-owner true)
            (ok true)))
        error (err (* error u10000)))
    )
)

(define-public (mint-many (ids (list 50 uint)))
  (let (
    (indexer (- (len ids) u1))
    (addresses (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.principal-lists lookup tx-sender indexer))
  )
   (print (map mint-many-iter ids addresses))
   (ok true)
  )
)

(define-public (burn (id uint))
    (let (
        (token-owner (unwrap-panic (unwrap-panic (get-owner id))))
    )
    (asserts! (is-eq tx-sender token-owner) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? market id)) ERR-LISTING)
    (asserts! (not (is-some (index-of (contract-call? .mutant-staking get-staked-nfts tx-sender .mutant-monkeys) id))) ERR-MONKEY-STAKED)
    (match (nft-burn? mutant-monkeys id token-owner)
        success
        (let
        ((current-balance (get-balance token-owner)))
          (begin
            (map-set token-count
              token-owner
              (- current-balance u1)
            )
            (ok true)))
        error (err (* error u10000)))
    )
)

(define-private (is-sender-owner (id uint))
  (let ((owner (unwrap! (nft-get-owner? mutant-monkeys id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm)}))
    (asserts! (not (is-some (index-of (contract-call? .mutant-staking get-staked-nfts tx-sender .mutant-monkeys) id))) ERR-MONKEY-STAKED)
    (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
    (try! (contract-call? .mutant-staking set-listed .mutant-monkeys id))
    (map-set market id listing)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)))

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
    (try! (contract-call? .mutant-staking set-unlisted .mutant-monkeys id))
    (map-delete market id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-ustx (id uint) (comm <commission-trait>))
  (let 
      (
        (owner (unwrap! (nft-get-owner? mutant-monkeys id) ERR-NOT-FOUND))
        (listing (unwrap! (map-get? market id) ERR-LISTING))
        (price (get price listing))
        (paid (pay-royalties (var-get wallets) price))
      )
    (asserts! (is-eq (contract-of comm) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (contract-call? .mutant-staking set-unlisted .mutant-monkeys id))
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)
    )
)

(define-read-only (calculate-royalties (amount uint))
  (let (
    (indexer (- (len (var-get royalties)) u1))
    (transformer (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.lists lookup amount indexer))
    (dividers (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.lists lookup u10000 indexer))
    (amounts (map * transformer (var-get royalties)))
    (royalty-amounts (map / amounts dividers))
  )
    royalty-amounts
  )
)

(define-public (pay-royalties (addresses (list 1000 principal)) (amount uint))
  (let (
    (amounts (calculate-royalties amount))
    (total-royalties (fold + amounts u0))
    (total (+ total-royalties amount))
  )
    (asserts! (>= (stx-get-balance tx-sender) total) (err ERR-NOT-ENOUGH-STX))
    (print (map pay addresses amounts))
    (ok true)
  )
)

(define-public (pay (address principal) (amount uint))
  (begin
    (if (> amount u0)
     (begin
      (try! (stx-transfer? amount tx-sender address))
      (ok true)
     )
     (begin
      (ok true)
     )
    )
  )
)

;; Set base uri
(define-public (set-base-uri (new-base-uri (string-ascii 100)))
  (begin
    (asserts! (is-some (index-of (var-get admins) tx-sender)) ERR-NOT-AUTHORIZED)
    (asserts! (not (var-get metadata-frozen)) ERR-METADATA-FROZEN)
    (var-set base-uri new-base-uri)
    (ok true)))

;; Set contract uri
(define-public (set-contract-uri (new-contract-uri (string-ascii 100)))
  (begin
    (asserts! (is-some (index-of (var-get admins) tx-sender)) ERR-NOT-AUTHORIZED)
    (asserts! (not (var-get metadata-frozen)) ERR-METADATA-FROZEN)
    (var-set contract-uri new-contract-uri)
    (ok true))
)

;; Freeze metadata
(define-public (freeze-metadata)
  (begin
    (asserts! (is-some (index-of (var-get admins) tx-sender)) ERR-NOT-AUTHORIZED)
    (var-set metadata-frozen true)
    (ok true)))

(define-public (royalty-change (amounts (list 1000 uint)))
  (if (is-some (index-of (var-get admins) tx-sender))
    (ok (var-set royalties amounts))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (admin-change (addresses (list 1000 principal)))
  (if (is-some (index-of (var-get admins) tx-sender))
    (ok (var-set admins addresses))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (payout-addresses-change (addresses (list 1000 principal)))
  (if (is-some (index-of (var-get admins) tx-sender))
    (ok (var-set wallets addresses))
    (err ERR-NOT-AUTHORIZED)
  )
)