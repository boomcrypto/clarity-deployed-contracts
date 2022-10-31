;; pumpkin-heads
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token pumpkin-heads uint)

;; Constants
(define-constant DEPLOYER tx-sender)
(define-constant COMM u1000)
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

;; Internal variables
(define-data-var mint-limit uint u500)
(define-data-var last-id uint u1)
(define-data-var total-price uint u9000000)
(define-data-var artist-address principal 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmTX1XHXZ35bLdCBSXheirDp3Dm1uzuZbRKp1BLpYUfGqk/json/")
(define-data-var mint-paused bool false)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u10)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)

(define-public (claim) 
  (mint (list true)))

(define-public (claim-three) (mint (list true true true)))

(define-public (claim-five) (mint (list true true true true true)))

(define-public (claim-ten) (mint (list true true true true true true true true true true)))

(define-public (claim-twenty) (mint (list true true true true true true true true true true true true true true true true true true true true)))

;; Default Minting
(define-private (mint (orders (list 25 bool)))
  (mint-many orders))

(define-private (mint-many (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price) (- id-reached last-nft-id)))
      (total-commission (/ (* price COMM) u10000))
      (current-balance (get-balance tx-sender))
      (total-artist (- price total-commission))
      (capped (> (var-get mint-cap) u0))
      (user-mints (get-mints tx-sender))
    )
    (asserts! (or (is-eq false (var-get mint-paused)) (is-eq tx-sender DEPLOYER)) (err ERR-PAUSED))
    (asserts! (or (not capped) (is-eq tx-sender DEPLOYER) (is-eq tx-sender art-addr) (>= (var-get mint-cap) (+ (len orders) user-mints))) (err ERR-NO-MORE-MINTS))
    (map-set mints-per-user tx-sender (+ (len orders) user-mints))
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender DEPLOYER) (is-eq (var-get total-price) u0000000))
      (begin
        (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
      )
      (begin
        (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
        (try! (stx-transfer? total-artist tx-sender (var-get artist-address)))
        (try! (stx-transfer? total-commission tx-sender COMM-ADDR))
      )    
    )
    (ok id-reached)))

(define-private (mint-many-iter (ignore bool) (next-id uint))
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? pumpkin-heads next-id tx-sender) next-id)
      (+ next-id u1)    
    )
    next-id))

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
    (asserts! (< limit (var-get mint-limit)) (err ERR-MINT-LIMIT))
    (ok (var-set mint-limit limit))))

(define-public (burn (token-id uint))
  (begin 
    (asserts! (is-owner token-id tx-sender) (err ERR-NOT-AUTHORIZED))
    (nft-burn? pumpkin-heads token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? pumpkin-heads token-id) false)))

(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
    (var-set ipfs-root new-base-uri)
    (ok true)))

(define-public (freeze-metadata)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set metadata-frozen true)
    (ok true)))

(define-public (reveal-artwork (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
    (var-set ipfs-root new-base-uri)
    (ok true)))
;; Non-custodial SIP-009 transfer function
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? pumpkin-heads token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))

(define-read-only (get-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-price)
  (ok (var-get total-price)))

(define-read-only (get-mints (caller principal))
  (default-to u0 (map-get? mints-per-user caller)))

(define-read-only (get-mint-limit)
  (ok (var-get mint-limit)))

(define-read-only (get-license-uri)
  (ok "https://arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/4"))
  
(define-read-only (get-license-name)
  (ok "PERSONAL"))

;; Non-custodial marketplace extras
(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal, royalty: uint})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? pumpkin-heads id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? pumpkin-heads id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? pumpkin-heads id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
      (price (get price listing))
      (royalty (get royalty listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
    (try! (stx-transfer? price tx-sender owner))
    (try! (pay-royalty price royalty))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))
    
(define-data-var royalty-percent uint u500)

(define-read-only (get-royalty-percent)
  (ok (var-get royalty-percent)))

(define-public (set-royalty-percent (royalty uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (asserts! (and (>= royalty u0) (<= royalty u1000)) (err ERR-INVALID-PERCENTAGE))
    (ok (var-set royalty-percent royalty))))

(define-private (pay-royalty (price uint) (royalty uint))
  (let (
    (royalty-amount (/ (* price royalty) u10000))
  )
  (if (> royalty-amount u0)
    (try! (stx-transfer? royalty-amount tx-sender (var-get artist-address)))
    (print false)
  )
  (ok true)))
  

;; Alt Minting Default
(define-data-var total-price-xbtc uint u13598)

(define-read-only (get-price-xbtc)
  (ok (var-get total-price-xbtc)))

(define-public (set-price-xbtc (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set total-price-xbtc price))))

(define-public (claim-xbtc)
  (mint-xbtc (list true)))

(define-public (claim-three-xbtc) (mint-xbtc (list true true true)))

(define-public (claim-five-xbtc) (mint-xbtc (list true true true true true)))

(define-public (claim-ten-xbtc) (mint-xbtc (list true true true true true true true true true true)))

(define-public (claim-twenty-xbtc) (mint-xbtc (list true true true true true true true true true true true true true true true true true true true true)))


(define-private (mint-xbtc (orders (list 25 bool)))
  (mint-many-xbtc orders))

(define-private (mint-many-xbtc (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price-xbtc) (- id-reached last-nft-id)))
      (total-commission (/ (* price COMM) u10000))
      (current-balance (get-balance tx-sender))
      (total-artist (- price total-commission))
    )
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender DEPLOYER))
      (begin
        (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
      )
      (begin
        (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
        (try! (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin transfer total-artist tx-sender (var-get artist-address) (some 0x00)))
        (try! (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin transfer total-commission tx-sender COMM-ADDR (some 0x00)))
      )    
    )
    (ok id-reached)))

;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u0) 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C))
      (map-set token-count 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C (+ (get-balance 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u1) 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C))
      (map-set token-count 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C (+ (get-balance 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u2) 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C))
      (map-set token-count 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C (+ (get-balance 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u3) 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C))
      (map-set token-count 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C (+ (get-balance 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u4) 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C))
      (map-set token-count 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C (+ (get-balance 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u5) 'SP2XJJC2T3MGRYQKPJQBBNQJVCV2HHHQ0P32KRNXH))
      (map-set token-count 'SP2XJJC2T3MGRYQKPJQBBNQJVCV2HHHQ0P32KRNXH (+ (get-balance 'SP2XJJC2T3MGRYQKPJQBBNQJVCV2HHHQ0P32KRNXH) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u6) 'SP2XJJC2T3MGRYQKPJQBBNQJVCV2HHHQ0P32KRNXH))
      (map-set token-count 'SP2XJJC2T3MGRYQKPJQBBNQJVCV2HHHQ0P32KRNXH (+ (get-balance 'SP2XJJC2T3MGRYQKPJQBBNQJVCV2HHHQ0P32KRNXH) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u7) 'SP2XJJC2T3MGRYQKPJQBBNQJVCV2HHHQ0P32KRNXH))
      (map-set token-count 'SP2XJJC2T3MGRYQKPJQBBNQJVCV2HHHQ0P32KRNXH (+ (get-balance 'SP2XJJC2T3MGRYQKPJQBBNQJVCV2HHHQ0P32KRNXH) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u8) 'SP2XJJC2T3MGRYQKPJQBBNQJVCV2HHHQ0P32KRNXH))
      (map-set token-count 'SP2XJJC2T3MGRYQKPJQBBNQJVCV2HHHQ0P32KRNXH (+ (get-balance 'SP2XJJC2T3MGRYQKPJQBBNQJVCV2HHHQ0P32KRNXH) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u9) 'SP2XJJC2T3MGRYQKPJQBBNQJVCV2HHHQ0P32KRNXH))
      (map-set token-count 'SP2XJJC2T3MGRYQKPJQBBNQJVCV2HHHQ0P32KRNXH (+ (get-balance 'SP2XJJC2T3MGRYQKPJQBBNQJVCV2HHHQ0P32KRNXH) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u10) 'SP1WKB47VCHNQXA0EMKXQZ41X3KXA79R7VDK54578))
      (map-set token-count 'SP1WKB47VCHNQXA0EMKXQZ41X3KXA79R7VDK54578 (+ (get-balance 'SP1WKB47VCHNQXA0EMKXQZ41X3KXA79R7VDK54578) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u11) 'SP1WKB47VCHNQXA0EMKXQZ41X3KXA79R7VDK54578))
      (map-set token-count 'SP1WKB47VCHNQXA0EMKXQZ41X3KXA79R7VDK54578 (+ (get-balance 'SP1WKB47VCHNQXA0EMKXQZ41X3KXA79R7VDK54578) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u12) 'SP1WKB47VCHNQXA0EMKXQZ41X3KXA79R7VDK54578))
      (map-set token-count 'SP1WKB47VCHNQXA0EMKXQZ41X3KXA79R7VDK54578 (+ (get-balance 'SP1WKB47VCHNQXA0EMKXQZ41X3KXA79R7VDK54578) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u13) 'SP1WKB47VCHNQXA0EMKXQZ41X3KXA79R7VDK54578))
      (map-set token-count 'SP1WKB47VCHNQXA0EMKXQZ41X3KXA79R7VDK54578 (+ (get-balance 'SP1WKB47VCHNQXA0EMKXQZ41X3KXA79R7VDK54578) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u14) 'SP1WKB47VCHNQXA0EMKXQZ41X3KXA79R7VDK54578))
      (map-set token-count 'SP1WKB47VCHNQXA0EMKXQZ41X3KXA79R7VDK54578 (+ (get-balance 'SP1WKB47VCHNQXA0EMKXQZ41X3KXA79R7VDK54578) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u15) 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN))
      (map-set token-count 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN (+ (get-balance 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u16) 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN))
      (map-set token-count 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN (+ (get-balance 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u17) 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN))
      (map-set token-count 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN (+ (get-balance 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u18) 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN))
      (map-set token-count 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN (+ (get-balance 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u19) 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN))
      (map-set token-count 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN (+ (get-balance 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u20) 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN))
      (map-set token-count 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN (+ (get-balance 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u21) 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN))
      (map-set token-count 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN (+ (get-balance 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u22) 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN))
      (map-set token-count 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN (+ (get-balance 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u23) 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN))
      (map-set token-count 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN (+ (get-balance 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u24) 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN))
      (map-set token-count 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN (+ (get-balance 'SP5Q4A3AZ4NYE1PF1CM8C38MH4WPB65281DRTXMN) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u25) 'SP1WATHR3480DE4AY59XYXWM7HD3XZFD7WYVBH0WA))
      (map-set token-count 'SP1WATHR3480DE4AY59XYXWM7HD3XZFD7WYVBH0WA (+ (get-balance 'SP1WATHR3480DE4AY59XYXWM7HD3XZFD7WYVBH0WA) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u26) 'SP1WATHR3480DE4AY59XYXWM7HD3XZFD7WYVBH0WA))
      (map-set token-count 'SP1WATHR3480DE4AY59XYXWM7HD3XZFD7WYVBH0WA (+ (get-balance 'SP1WATHR3480DE4AY59XYXWM7HD3XZFD7WYVBH0WA) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u27) 'SP1WATHR3480DE4AY59XYXWM7HD3XZFD7WYVBH0WA))
      (map-set token-count 'SP1WATHR3480DE4AY59XYXWM7HD3XZFD7WYVBH0WA (+ (get-balance 'SP1WATHR3480DE4AY59XYXWM7HD3XZFD7WYVBH0WA) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u28) 'SP1WATHR3480DE4AY59XYXWM7HD3XZFD7WYVBH0WA))
      (map-set token-count 'SP1WATHR3480DE4AY59XYXWM7HD3XZFD7WYVBH0WA (+ (get-balance 'SP1WATHR3480DE4AY59XYXWM7HD3XZFD7WYVBH0WA) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u29) 'SP1WATHR3480DE4AY59XYXWM7HD3XZFD7WYVBH0WA))
      (map-set token-count 'SP1WATHR3480DE4AY59XYXWM7HD3XZFD7WYVBH0WA (+ (get-balance 'SP1WATHR3480DE4AY59XYXWM7HD3XZFD7WYVBH0WA) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u30) 'SPNKS4MR41GH8PVXAA2R0KVG4S3KYG68Z5TANYW9))
      (map-set token-count 'SPNKS4MR41GH8PVXAA2R0KVG4S3KYG68Z5TANYW9 (+ (get-balance 'SPNKS4MR41GH8PVXAA2R0KVG4S3KYG68Z5TANYW9) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u31) 'SPNKS4MR41GH8PVXAA2R0KVG4S3KYG68Z5TANYW9))
      (map-set token-count 'SPNKS4MR41GH8PVXAA2R0KVG4S3KYG68Z5TANYW9 (+ (get-balance 'SPNKS4MR41GH8PVXAA2R0KVG4S3KYG68Z5TANYW9) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u32) 'SPNKS4MR41GH8PVXAA2R0KVG4S3KYG68Z5TANYW9))
      (map-set token-count 'SPNKS4MR41GH8PVXAA2R0KVG4S3KYG68Z5TANYW9 (+ (get-balance 'SPNKS4MR41GH8PVXAA2R0KVG4S3KYG68Z5TANYW9) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u33) 'SPNKS4MR41GH8PVXAA2R0KVG4S3KYG68Z5TANYW9))
      (map-set token-count 'SPNKS4MR41GH8PVXAA2R0KVG4S3KYG68Z5TANYW9 (+ (get-balance 'SPNKS4MR41GH8PVXAA2R0KVG4S3KYG68Z5TANYW9) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u34) 'SPNKS4MR41GH8PVXAA2R0KVG4S3KYG68Z5TANYW9))
      (map-set token-count 'SPNKS4MR41GH8PVXAA2R0KVG4S3KYG68Z5TANYW9 (+ (get-balance 'SPNKS4MR41GH8PVXAA2R0KVG4S3KYG68Z5TANYW9) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u35) 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5))
      (map-set token-count 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5 (+ (get-balance 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u36) 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5))
      (map-set token-count 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5 (+ (get-balance 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u37) 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5))
      (map-set token-count 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5 (+ (get-balance 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u38) 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5))
      (map-set token-count 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5 (+ (get-balance 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u39) 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5))
      (map-set token-count 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5 (+ (get-balance 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u40) 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5))
      (map-set token-count 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5 (+ (get-balance 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u41) 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5))
      (map-set token-count 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5 (+ (get-balance 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u42) 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5))
      (map-set token-count 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5 (+ (get-balance 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u43) 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5))
      (map-set token-count 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5 (+ (get-balance 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u44) 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5))
      (map-set token-count 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5 (+ (get-balance 'SP330A50TQX6KJZQB71G3HK9TX0S1Y2SACVDYJXQ5) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u45) 'SP2JHPBYCZH4SYCFDDXJHAWDVWMGPSMGM4KKJDVWG))
      (map-set token-count 'SP2JHPBYCZH4SYCFDDXJHAWDVWMGPSMGM4KKJDVWG (+ (get-balance 'SP2JHPBYCZH4SYCFDDXJHAWDVWMGPSMGM4KKJDVWG) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u46) 'SP2JHPBYCZH4SYCFDDXJHAWDVWMGPSMGM4KKJDVWG))
      (map-set token-count 'SP2JHPBYCZH4SYCFDDXJHAWDVWMGPSMGM4KKJDVWG (+ (get-balance 'SP2JHPBYCZH4SYCFDDXJHAWDVWMGPSMGM4KKJDVWG) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u47) 'SP2JHPBYCZH4SYCFDDXJHAWDVWMGPSMGM4KKJDVWG))
      (map-set token-count 'SP2JHPBYCZH4SYCFDDXJHAWDVWMGPSMGM4KKJDVWG (+ (get-balance 'SP2JHPBYCZH4SYCFDDXJHAWDVWMGPSMGM4KKJDVWG) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u48) 'SP2JHPBYCZH4SYCFDDXJHAWDVWMGPSMGM4KKJDVWG))
      (map-set token-count 'SP2JHPBYCZH4SYCFDDXJHAWDVWMGPSMGM4KKJDVWG (+ (get-balance 'SP2JHPBYCZH4SYCFDDXJHAWDVWMGPSMGM4KKJDVWG) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u49) 'SP2JHPBYCZH4SYCFDDXJHAWDVWMGPSMGM4KKJDVWG))
      (map-set token-count 'SP2JHPBYCZH4SYCFDDXJHAWDVWMGPSMGM4KKJDVWG (+ (get-balance 'SP2JHPBYCZH4SYCFDDXJHAWDVWMGPSMGM4KKJDVWG) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u50) 'SP02QAAQPKFQWNQEVEAZCZPSX7KBPD58HH1GWCWX))
      (map-set token-count 'SP02QAAQPKFQWNQEVEAZCZPSX7KBPD58HH1GWCWX (+ (get-balance 'SP02QAAQPKFQWNQEVEAZCZPSX7KBPD58HH1GWCWX) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u51) 'SP02QAAQPKFQWNQEVEAZCZPSX7KBPD58HH1GWCWX))
      (map-set token-count 'SP02QAAQPKFQWNQEVEAZCZPSX7KBPD58HH1GWCWX (+ (get-balance 'SP02QAAQPKFQWNQEVEAZCZPSX7KBPD58HH1GWCWX) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u52) 'SP02QAAQPKFQWNQEVEAZCZPSX7KBPD58HH1GWCWX))
      (map-set token-count 'SP02QAAQPKFQWNQEVEAZCZPSX7KBPD58HH1GWCWX (+ (get-balance 'SP02QAAQPKFQWNQEVEAZCZPSX7KBPD58HH1GWCWX) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u53) 'SP02QAAQPKFQWNQEVEAZCZPSX7KBPD58HH1GWCWX))
      (map-set token-count 'SP02QAAQPKFQWNQEVEAZCZPSX7KBPD58HH1GWCWX (+ (get-balance 'SP02QAAQPKFQWNQEVEAZCZPSX7KBPD58HH1GWCWX) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u54) 'SP02QAAQPKFQWNQEVEAZCZPSX7KBPD58HH1GWCWX))
      (map-set token-count 'SP02QAAQPKFQWNQEVEAZCZPSX7KBPD58HH1GWCWX (+ (get-balance 'SP02QAAQPKFQWNQEVEAZCZPSX7KBPD58HH1GWCWX) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u55) 'SP31K43DZJKYRKJZVT1KR29730TXVCD0GRXFDEF36))
      (map-set token-count 'SP31K43DZJKYRKJZVT1KR29730TXVCD0GRXFDEF36 (+ (get-balance 'SP31K43DZJKYRKJZVT1KR29730TXVCD0GRXFDEF36) u1))
      (try! (nft-mint? pumpkin-heads (+ last-nft-id u56) 'SP31K43DZJKYRKJZVT1KR29730TXVCD0GRXFDEF36))
      (map-set token-count 'SP31K43DZJKYRKJZVT1KR29730TXVCD0GRXFDEF36 (+ (get-balance 'SP31K43DZJKYRKJZVT1KR29730TXVCD0GRXFDEF36) u1))

      (var-set last-id (+ last-nft-id u57))
      (var-set airdrop-called true)
      (ok true))))