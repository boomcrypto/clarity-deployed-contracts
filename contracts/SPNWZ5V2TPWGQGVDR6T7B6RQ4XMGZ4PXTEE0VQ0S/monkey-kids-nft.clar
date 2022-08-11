;; (use-trait commission-trait .commission-trait.commission)
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

(define-non-fungible-token mktc uint)

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
(define-data-var base-uri (string-ascii 100) "http://mktc.link/{id}")
(define-data-var admins (list 1000 principal) (list 'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6))
(define-data-var wallets (list 1000 principal) (list 'SPF1426KV10TKZ55BPCBDQFM6X4EJZMMF3JMKVY6 'SP2597NW8VYYVV4C22WQF3DK0WGQS8TAVDDPXQ5H8 'SP1GPNZB0JSC9RXJTXVBAMSPQE29WM1SE8V39R6K2))
(define-data-var royalties (list 1000 uint) (list u500 u100 u100))
(define-map mint-address bool principal)
(define-data-var slime-burn-amount uint u100000000)

;; Token count for account
(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

;; Get minted
(define-read-only (get-minted (account principal))
  (default-to false
    (map-get? minted account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? mktc id sender recipient)
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
    (asserts! (is-none (index-of (contract-call? .mktc-staking-v1 get-staked-nfts tx-sender .monkey-kids-nft) id)) ERR-MONKEY-STAKED)
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? market id)) ERR-LISTING)
    (trnsfr id sender recipient)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (id uint))
  ;; Make sure to replace mktc
  (ok (nft-get-owner? mktc id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
    (ok (var-get last-id))
)

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (token-id uint))
  (ok (some (var-get base-uri)))
)

(define-read-only (get-total-royalty)
  (fold + (var-get royalties) u0)
)

(define-public (mint (egg-id uint) (incubator-id uint))
    (let (
        (new-owner tx-sender)
    )
      (asserts! (is-eq (unwrap-panic (unwrap-panic (contract-call? .bitcoin-monkeys-eggs-collection get-owner egg-id))) tx-sender) ERR-NOT-AUTHORIZED)
      (asserts! (is-eq (unwrap-panic (unwrap-panic (contract-call? .bitcoin-monkeys-incubators get-owner incubator-id))) tx-sender) ERR-NOT-AUTHORIZED)
      (asserts! (< (var-get last-id) MINT-LIMIT) ERR-SOLD-OUT)
      (match (nft-mint? mktc egg-id new-owner)
        success
        (let
        ((current-balance (get-balance new-owner)))
          (begin
            (try! (contract-call? .bitcoin-monkeys-eggs-collection burn egg-id))
            (try! (contract-call? .bitcoin-monkeys-incubators burn incubator-id))
;;          (try! (contract-call? .slime burn (var-get slime-burn-amount)))
            (try! (contract-call? 'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7.slime-token burn (var-get slime-burn-amount)))
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
      (asserts! (< (var-get last-id) MINT-LIMIT) ERR-SOLD-OUT)
      (asserts! (is-some (index-of (var-get admins) tx-sender)) ERR-NOT-AUTHORIZED)
      (match (nft-mint? mktc id new-owner)
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

(define-public (burn (id uint))
    (let (
        (token-owner (unwrap-panic (unwrap-panic (get-owner id))))
    )
    (asserts! (is-eq tx-sender token-owner) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? market id)) ERR-LISTING)
    (asserts! (not (is-some (index-of (contract-call? .mktc-staking-v1 get-staked-nfts tx-sender .monkey-kids-nft) id))) ERR-MONKEY-STAKED)
    (match (nft-burn? mktc id token-owner)
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
  (let ((owner (unwrap! (nft-get-owner? mktc id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm)}))
    (asserts! (not (is-some (index-of (contract-call? .mktc-staking-v1 get-staked-nfts tx-sender .monkey-kids-nft) id))) ERR-MONKEY-STAKED)
    (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
    (try! (contract-call? .mktc-staking-v1 set-listed .monkey-kids-nft id))
    (map-set market id listing)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)))

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
    (try! (contract-call? .mktc-staking-v1 set-unlisted .monkey-kids-nft id))
    (map-delete market id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-ustx (id uint) (comm <commission-trait>))
  (let 
      (
        (owner (unwrap! (nft-get-owner? mktc id) ERR-NOT-FOUND))
        (listing (unwrap! (map-get? market id) ERR-LISTING))
        (price (get price listing))
        (paid (pay-royalties (var-get wallets) price))
      )
    (asserts! (is-eq (contract-of comm) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (contract-call? .mktc-staking-v1 set-unlisted .monkey-kids-nft id))
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
    (print amounts)
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

(define-public (set-slime-burn-amount (new-slime-burn-amount uint))
  (begin
    (asserts! (is-some (index-of (var-get admins) tx-sender)) ERR-NOT-AUTHORIZED)
    (var-set slime-burn-amount new-slime-burn-amount)
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