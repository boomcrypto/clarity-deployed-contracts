;; moon-tide
;; contractType: editions

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token moon-tide uint)

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
(define-constant ERR-CONTRACT-LOCKED u115)

;; Internal variables
(define-data-var mint-limit uint u500)
(define-data-var last-id uint u1)
(define-data-var total-price uint u10000000)
(define-data-var artist-address principal 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmaTihg7viL7i5J2gZ2QJpzabz9Pj3BFoRRG5f1xQ3mWiW/")
(define-data-var mint-paused bool false)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u0)
(define-data-var locked bool false)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)

(define-public (lock-contract)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set locked true)
    (ok true)))

(define-public (claim) 
  (mint (list true)))

(define-public (claim-three) (mint (list true true true)))

(define-public (claim-five) (mint (list true true true true true)))

;; Default Minting
(define-private (mint (orders (list 25 bool)))
  (mint-many orders))

(define-public (mint-for-many (recipients (list 25 principal)))
  (let
    (
      (next-id (var-get last-id))
      (id-reached (fold mint-for-many-iter recipients next-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (var-set last-id id-reached)
      (ok id-reached))))

(define-private (mint-for-many-iter (recipient principal) (next-id uint))
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? moon-tide next-id tx-sender) next-id)
      (unwrap! (nft-transfer? moon-tide next-id tx-sender recipient) next-id)
      (map-set token-count recipient (+ (get-balance recipient) u1))      
      (+ next-id u1)
    )
    next-id))

(define-private (mint-many (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (or (is-eq (var-get mint-limit) u0) (<= last-nft-id (var-get mint-limit))) (err ERR-NO-MORE-NFTS)))
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
    (asserts! (is-eq (var-get locked) false) (err ERR-CONTRACT-LOCKED))
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
  (if (or (is-eq (var-get mint-limit) u0) (<= next-id (var-get mint-limit)))
    (begin
      (unwrap! (nft-mint? moon-tide next-id tx-sender) next-id)
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
    (nft-burn? moon-tide token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? moon-tide token-id) false)))

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

;; Non-custodial SIP-009 transfer function
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? moon-tide token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (var-get ipfs-root))))

(define-read-only (get-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-price)
  (ok (var-get total-price)))

(define-read-only (get-mints (caller principal))
  (default-to u0 (map-get? mints-per-user caller)))

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
  (match (nft-transfer? moon-tide id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? moon-tide id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? moon-tide id) (err ERR-NOT-FOUND)))
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
(define-data-var total-price-xbtc uint u17601)

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
      (try! (nft-mint? moon-tide (+ last-nft-id u0) 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
      (map-set token-count 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 (+ (get-balance 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u1) 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
      (map-set token-count 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 (+ (get-balance 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u2) 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
      (map-set token-count 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 (+ (get-balance 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u3) 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
      (map-set token-count 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 (+ (get-balance 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u4) 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
      (map-set token-count 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 (+ (get-balance 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u5) 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
      (map-set token-count 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 (+ (get-balance 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u6) 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
      (map-set token-count 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 (+ (get-balance 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u7) 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
      (map-set token-count 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 (+ (get-balance 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u8) 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
      (map-set token-count 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 (+ (get-balance 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u9) 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
      (map-set token-count 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 (+ (get-balance 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u10) 'SPGGAEQWA7Y9HRZY5T0XJCEYEZ28J6RKCCC1HP9M))
      (map-set token-count 'SPGGAEQWA7Y9HRZY5T0XJCEYEZ28J6RKCCC1HP9M (+ (get-balance 'SPGGAEQWA7Y9HRZY5T0XJCEYEZ28J6RKCCC1HP9M) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u11) 'SPAH6BRVBE3CBRS3SAV84XS3Q9RRV6C886NE7P69))
      (map-set token-count 'SPAH6BRVBE3CBRS3SAV84XS3Q9RRV6C886NE7P69 (+ (get-balance 'SPAH6BRVBE3CBRS3SAV84XS3Q9RRV6C886NE7P69) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u12) 'SP3YS4Q6P6J2QF8K581V5E3GFAZWZ5YN6CMJY73QK))
      (map-set token-count 'SP3YS4Q6P6J2QF8K581V5E3GFAZWZ5YN6CMJY73QK (+ (get-balance 'SP3YS4Q6P6J2QF8K581V5E3GFAZWZ5YN6CMJY73QK) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u13) 'SP1Z898H687CA3RWMZMTPP5HYBG2EZDXN872WS38K))
      (map-set token-count 'SP1Z898H687CA3RWMZMTPP5HYBG2EZDXN872WS38K (+ (get-balance 'SP1Z898H687CA3RWMZMTPP5HYBG2EZDXN872WS38K) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u14) 'SP3KV7ADQ681XBKVHQWSXXCYPXE81YE73PZQTA6C4))
      (map-set token-count 'SP3KV7ADQ681XBKVHQWSXXCYPXE81YE73PZQTA6C4 (+ (get-balance 'SP3KV7ADQ681XBKVHQWSXXCYPXE81YE73PZQTA6C4) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u15) 'SP3S5BXB186YXQ888KB95DVV78WZ3EF6MT60E2110))
      (map-set token-count 'SP3S5BXB186YXQ888KB95DVV78WZ3EF6MT60E2110 (+ (get-balance 'SP3S5BXB186YXQ888KB95DVV78WZ3EF6MT60E2110) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u16) 'SP2A4AHARKR9PNPNYWCE9RT1EF9BQ7GDPTRJ03EAA))
      (map-set token-count 'SP2A4AHARKR9PNPNYWCE9RT1EF9BQ7GDPTRJ03EAA (+ (get-balance 'SP2A4AHARKR9PNPNYWCE9RT1EF9BQ7GDPTRJ03EAA) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u17) 'SPBBHW86SPQNVRBFMQ6VP0FEKA25599B3CSD047X))
      (map-set token-count 'SPBBHW86SPQNVRBFMQ6VP0FEKA25599B3CSD047X (+ (get-balance 'SPBBHW86SPQNVRBFMQ6VP0FEKA25599B3CSD047X) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u18) 'SPPFYD5Q1XGJV7HVT7D6X3YRMVY9168EVZE1WHZS))
      (map-set token-count 'SPPFYD5Q1XGJV7HVT7D6X3YRMVY9168EVZE1WHZS (+ (get-balance 'SPPFYD5Q1XGJV7HVT7D6X3YRMVY9168EVZE1WHZS) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u19) 'SP27PMQWPBDV1XK9HK259XZNHW8B6XZJJXMNQCV6Y))
      (map-set token-count 'SP27PMQWPBDV1XK9HK259XZNHW8B6XZJJXMNQCV6Y (+ (get-balance 'SP27PMQWPBDV1XK9HK259XZNHW8B6XZJJXMNQCV6Y) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u20) 'SP5DVPNE45JC84TW0MDM28Q692GN608G1FKM7N6J))
      (map-set token-count 'SP5DVPNE45JC84TW0MDM28Q692GN608G1FKM7N6J (+ (get-balance 'SP5DVPNE45JC84TW0MDM28Q692GN608G1FKM7N6J) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u21) 'SP27PMQWPBDV1XK9HK259XZNHW8B6XZJJXMNQCV6Y))
      (map-set token-count 'SP27PMQWPBDV1XK9HK259XZNHW8B6XZJJXMNQCV6Y (+ (get-balance 'SP27PMQWPBDV1XK9HK259XZNHW8B6XZJJXMNQCV6Y) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u22) 'SP27PMQWPBDV1XK9HK259XZNHW8B6XZJJXMNQCV6Y))
      (map-set token-count 'SP27PMQWPBDV1XK9HK259XZNHW8B6XZJJXMNQCV6Y (+ (get-balance 'SP27PMQWPBDV1XK9HK259XZNHW8B6XZJJXMNQCV6Y) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u23) 'SP27PMQWPBDV1XK9HK259XZNHW8B6XZJJXMNQCV6Y))
      (map-set token-count 'SP27PMQWPBDV1XK9HK259XZNHW8B6XZJJXMNQCV6Y (+ (get-balance 'SP27PMQWPBDV1XK9HK259XZNHW8B6XZJJXMNQCV6Y) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u24) 'SP27PMQWPBDV1XK9HK259XZNHW8B6XZJJXMNQCV6Y))
      (map-set token-count 'SP27PMQWPBDV1XK9HK259XZNHW8B6XZJJXMNQCV6Y (+ (get-balance 'SP27PMQWPBDV1XK9HK259XZNHW8B6XZJJXMNQCV6Y) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u25) 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6))
      (map-set token-count 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6 (+ (get-balance 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u26) 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD))
      (map-set token-count 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD (+ (get-balance 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u27) 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD))
      (map-set token-count 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD (+ (get-balance 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u28) 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD))
      (map-set token-count 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD (+ (get-balance 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u29) 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD))
      (map-set token-count 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD (+ (get-balance 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u30) 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC))
      (map-set token-count 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC (+ (get-balance 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u31) 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20))
      (map-set token-count 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20 (+ (get-balance 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u32) 'SP3YSG653BZZNTJVFHFMBSQCTP3GK6NAQEHC82TNK))
      (map-set token-count 'SP3YSG653BZZNTJVFHFMBSQCTP3GK6NAQEHC82TNK (+ (get-balance 'SP3YSG653BZZNTJVFHFMBSQCTP3GK6NAQEHC82TNK) u1))
      (try! (nft-mint? moon-tide (+ last-nft-id u33) 'SP2MS5KKM4CFTC6C6H2QAB7BKYBSNXWZKVCCXBMQG))
      (map-set token-count 'SP2MS5KKM4CFTC6C6H2QAB7BKYBSNXWZKVCCXBMQG (+ (get-balance 'SP2MS5KKM4CFTC6C6H2QAB7BKYBSNXWZKVCCXBMQG) u1))

      (var-set last-id (+ last-nft-id u34))
      (var-set airdrop-called true)
      (ok true))))