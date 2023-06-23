;; stacks-3ridge-seoul-meetup-2023

(impl-trait .nft-trait.nft-trait)

(define-non-fungible-token stacks-3ridge-seoul-meetup-2023 uint)

;; Constants
(define-constant DEPLOYER tx-sender)
(define-constant COMM u1000)
(define-constant COMM-ADDR 'SPBGN2NDFZ1PT6TFV6127F53KCP9HHHEB8JHYS34)

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

;; Internal variables
(define-data-var mint-limit uint u200)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0000000)
(define-data-var artist-address principal 'SPBGN2NDFZ1PT6TFV6127F53KCP9HHHEB8JHYS34)
(define-data-var ipfs-root (string-ascii 80) "ipfs://Qmegbw6yrxx412hfTgPmHXNoUo1YjWvXSXAb4FahScdrRF/")

(define-data-var mint-paused bool true)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u1)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)

;; Pre mint for transfer rewards to 3ridge event participants
(define-public (pre-mint) 
  (begin
    (try! (mint (list true true true true true true true true true true true true true true true)))
    (try! (trnsfr u1 DEPLOYER 'SP1997REHPBDBRRWRHCTF693SHS0TDEA6V84TKYZV))
    (try! (trnsfr u2 DEPLOYER 'SP3B12KNF2WWXPMTY5GK3S9D8HG2W6ZG9H84NB6T4))
    (try! (trnsfr u3 DEPLOYER 'SP1ZJHN74VH26SPHHJB4YP6NSEYVKFZD1W0ZK5K9H))
    (try! (trnsfr u4 DEPLOYER 'SP20KFMW5NAQATXXG8MMB8ESGB33XYAEK1TBTR8J8))
    (try! (trnsfr u5 DEPLOYER 'SP31A0B5K60KHWM3S3JD0B47TG3R43PT1KRV7V53B))
    (try! (trnsfr u6 DEPLOYER 'SP2FYNJVHG0CJDMYCCVK4AB0WBD561TW0YP7M4PVA))
    (try! (trnsfr u7 DEPLOYER 'SPA5RK3DBP26GHD5Z462JRME33GQWXWAVX359FAJ))
    (try! (trnsfr u8 DEPLOYER 'SP2TSP9H8877HZX69B9JQ2EM2JP97XJNZEKJTE2ZT))
    (try! (trnsfr u9 DEPLOYER 'SP3D4C9J5GX7WN3Z4X1SXE3A88MJYKM41YS7GHEDY))
    (try! (trnsfr u10 DEPLOYER 'SPJ9J39D9FDFXM3FC31Z5QGC31FAEMRJ13WPXJMY))
    (try! (trnsfr u11 DEPLOYER 'SP1VEQYSMWF1J3XV35XVCFXY8YW2E92QMPG2VT5WR))
    (try! (trnsfr u12 DEPLOYER 'SP2YXPVMEVPGT5ZP071CCA2ZZC68EYQ72J5ES0R19))
    (try! (trnsfr u13 DEPLOYER 'SP1CD4CH173PM3STX545S40GFNGTVQAJ85BTQEMEN))
    (try! (trnsfr u14 DEPLOYER 'SP1BH6PQFJ69BNKM6A2MQ10V7J6PFT7JXHNDYF0WQ))
    (try! (trnsfr u15 DEPLOYER 'SP1NGMS9Z48PRXFAG2MKBSP0PWERF07C0KV9SPJ66))
    (ok true)))

(define-public (claim) 
  (mint (list true)))

;; Default Minting
(define-public (mint (orders (list 25 bool)))
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
      (unwrap! (nft-mint? stacks-3ridge-seoul-meetup-2023 next-id tx-sender) next-id)
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

(define-public (set-mint-cap (cap uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set mint-cap cap))))

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
    (nft-burn? stacks-3ridge-seoul-meetup-2023 token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? stacks-3ridge-seoul-meetup-2023 token-id) false)))

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
  (ok (nft-get-owner? stacks-3ridge-seoul-meetup-2023 token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get ipfs-root) "metadata") ".json"))))

(define-read-only (get-mint-cap)
  (ok (var-get mint-cap)))

(define-read-only (get-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-price)
  (ok (var-get total-price)))

(define-read-only (get-mints (caller principal))
  (default-to u0 (map-get? mints-per-user caller)))

(define-read-only (get-mint-limit)
  (ok (var-get mint-limit)))

;; Non-custodial marketplace extras
(define-trait commission-trait
  ((pay (uint uint) (response bool uint))))

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? stacks-3ridge-seoul-meetup-2023 id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? stacks-3ridge-seoul-meetup-2023 id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm-trait)}))
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
  (let ((owner (unwrap! (nft-get-owner? stacks-3ridge-seoul-meetup-2023 id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))

;; Utils to convert an uint to string
;; Clarity doesn't support uint-to-string natively for now
;; Code for uint to string
(define-constant LIST_40 (list
  true true true true true true true true true true
  true true true true true true true true true true
  true true true true true true true true true true
  true true true true true true true true true true
))

(define-read-only (uint-to-string (value uint))
  (get return (fold uint-to-string-clojure LIST_40 {value: value, return: ""}))
)

(define-read-only (uint-to-string-clojure (i bool) (data {value: uint, return: (string-ascii 40)}))
  (if (> (get value data) u0)
    {
      value: (/ (get value data) u10),
      return: (unwrap-panic (as-max-len? (concat (unwrap-panic (element-at "0123456789" (mod (get value data) u10))) (get return data)) u40))
    }
    data
  )
)