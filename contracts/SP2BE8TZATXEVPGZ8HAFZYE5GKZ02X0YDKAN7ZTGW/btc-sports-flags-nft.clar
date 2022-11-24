;; btc-sports-flags
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token btc-sports-flags uint)

;; Constants
(define-constant DEPLOYER tx-sender)
(define-constant COMM u500)
(define-constant COMM-ADDR 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S)

(define-constant ERR-NO-MORE-NFTS u100)
(define-constant ERR-NOT-ENOUGH-PASSES u101)
(define-constant ERR-PUBLIC-SALE-DISABLED u102)
(define-constant ERR-CONTRACT-INITIALIZED u103)
(define-constant ERR-NOT-AUTHORIZED u104)
(define-constant ERR-INVALID-USER u105)
(define-constant ERR-LISTING u106)
(define-constant ERR-WRONG-COMMISSION u107)
(define-constant ERR-NOT-FOUND u108)
(define-constant ERR-PAUSED u109)
(define-constant ERR-MINT-LIMIT u110)
(define-constant ERR-METADATA-FROZEN u111)
(define-constant ERR-AIRDROP-CALLED u112)
(define-constant ERR-NO-MORE-MINTS u113)
(define-constant ERR-INVALID-PERCENTAGE u114)
(define-constant ERR-STAKED u115)

;; Internal variables
(define-data-var mint-limit uint u2000)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0)
(define-data-var artist-address principal 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T)
(define-data-var ipfs-root (string-ascii 256) "ipfs://ipfs/QmeQDJWzk2h95krBN2zdZRM4ysGGh1QovWNpw6PwMxgaLb/")
(define-data-var mint-paused bool true)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u0)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)

(define-map sponsor-map uint (string-ascii 80))
(define-map points-map uint (string-ascii 80))
(define-map country-map uint (string-ascii 80))

(define-map sponsor-royalty-map (string-ascii 80) principal)

(define-public (mint-one (recipient principal) (sponsor (string-ascii 80)) (points (string-ascii 80)) (country (string-ascii 80)))
  (let
    (
      (next-id (var-get last-id))
    )
    (asserts! (<= next-id (var-get mint-limit)) (err ERR-MINT-LIMIT))
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (unwrap! (nft-mint? btc-sports-flags next-id tx-sender) (err next-id))
    (unwrap! (nft-transfer? btc-sports-flags next-id tx-sender recipient) (err next-id))
    (map-set sponsor-map next-id sponsor)
    (map-set points-map next-id points)
    (map-set country-map next-id country)
    (map-set token-count recipient (+ (get-balance recipient) u1))
    (+ next-id u1)
    (var-set last-id (+ next-id u1))
    (ok (var-get last-id))
  )
)

(define-public (set-artist-address (address principal))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set artist-address address))))

(define-public (set-price (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set total-price price))))

(define-public (toggle-pause)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set mint-paused (not (var-get mint-paused))))))

(define-public (set-mint-limit (limit uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set mint-limit limit))))

(define-public (burn (token-id uint))
  (begin
    (asserts! (is-owner token-id tx-sender) (err ERR-NOT-AUTHORIZED))
    (nft-burn? btc-sports-flags token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? btc-sports-flags token-id) false)))

(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
    (var-set ipfs-root new-base-uri)
    (ok true)))

(define-public (set-flag (token-id uint) (sponsor (string-ascii 80)) (points (string-ascii 80)) (country (string-ascii 80)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (map-set sponsor-map token-id sponsor)
    (map-set points-map token-id points)
    (map-set country-map token-id country)
    (ok true)
  )
)

(define-public (freeze-metadata)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set metadata-frozen true)
    (ok true)))

;; Non-custodial SIP-009 transfer function
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? btc-sports-flags token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (let (
    (country (unwrap! (map-get? country-map token-id) (err ERR-NOT-FOUND)))
    (points  (unwrap! (map-get? points-map token-id) (err ERR-NOT-FOUND)))
    (sponsor (unwrap! (map-get? sponsor-map token-id) (err ERR-NOT-FOUND)))
    (sa (concat (var-get ipfs-root) sponsor))
    (sb (concat sa "/"))
    (sc (concat sb points))
    (sd (concat sc "/"))
    (se (concat sd country))
    (sf (concat se ".json"))
  )
    (ok (some (unwrap-panic (as-max-len? sf u256))))
  )
)

(define-read-only (get-mint-limit)
  (ok (var-get mint-limit)))

;; Non-custodial marketplace extras
(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal, royalty: uint})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? btc-sports-flags id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? btc-sports-flags id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm-trait), royalty: (var-get royalty-percent)}))
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
  (let ((owner (unwrap! (nft-get-owner? btc-sports-flags id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
      (price (get price listing))
      (royalty (get royalty listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
    (try! (stx-transfer? price tx-sender owner))
    (try! (pay-royalty price royalty id))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))

(define-data-var royalty-percent uint u2000)

(define-read-only (get-royalty-percent)
  (ok (var-get royalty-percent)))

(define-public (set-royalty-percent (royalty uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set royalty-percent royalty))))

(define-public (set-sponsor-royalty-address (sponsor (string-ascii 80)) (address principal))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (map-set sponsor-royalty-map sponsor address))))

(define-private (pay-royalty (price uint) (royalty uint) (token-id uint))
  (let (
    (total-royalty-amount (/ (* price royalty) u10000))
    (btc-sports-royalty-amount (/ (* total-royalty-amount u4000) u10000))
    (btc-sports-dao-royalty-amount (/ (* total-royalty-amount u500) u10000))
    (btc-sports-team-royalty-amount (/ (* total-royalty-amount u500) u10000))
    (sponsor-royalty-amount (/ (* total-royalty-amount u5000) u10000))
    (sponsor-name (default-to "BTC%20Sports" (map-get? sponsor-map token-id)))
    (sponsor-address (default-to 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (map-get? sponsor-royalty-map sponsor-name)))
  )
  (if (> total-royalty-amount u0)
    (begin
      (try! (stx-transfer? btc-sports-royalty-amount 
                tx-sender 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (try! (stx-transfer? btc-sports-dao-royalty-amount 
                tx-sender 'SPEJ66Q0Q6JRY9YB4GBKPB6FXT8W4N7R1Q5SPTPS))
      (try! (stx-transfer? btc-sports-team-royalty-amount 
                tx-sender 'SP2F0M4PGG50F7H6NN6WK15HJCCWW1ZQBBRFHXEPH))
      (try! (stx-transfer? sponsor-royalty-amount 
                tx-sender sponsor-address))
    )
    (print false)
  )
  (ok true)))

(set-sponsor-royalty-address "Bitcoin%20Monkey" 'SPT1BS3PV5Z16S3V6ZEVWHVQS4RTJXS849R19KVC)
(set-sponsor-royalty-address "Curator" 'SP1FJN5P7V9W2K96VN7YWGH7VP36RB5K5JW1R9HF7)
(set-sponsor-royalty-address "GMRH" 'SP3MQWSKAESKY7JFBS88GFQ47AZDKC3XH3ZHTWWYT)
(set-sponsor-royalty-address "Jungle%20Force" 'SP4D5X7MNXVGVC344KPBQ20T1EK5MGHA56TZ7NHT)
(set-sponsor-royalty-address "Madstar" 'SP2M63YGBZCTWBWBCG77RET0RMP42C08T73MKAPNP)
(set-sponsor-royalty-address "Megapont" 'SP2J9XB6CNJX9C36D5SY4J85SA0P1MQX7R5VFKZZX)
(set-sponsor-royalty-address "Nonnish" 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1)
(set-sponsor-royalty-address "Spaghetti%20Punk" 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH)
(set-sponsor-royalty-address "Stacks%20Parrots" 'SP467VFDYHV185JSQ98V9VTA7JS3PFJ3DM8PXD20)
(set-sponsor-royalty-address "The%20Guests" 'SP3SC5PSKQM9ABTYPNYDV1J7SBGHA08VRW1DKTJK6)
(set-sponsor-royalty-address "This%20is%20%231" 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3)