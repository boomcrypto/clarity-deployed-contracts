;; sf-editions-sb
;; checklist when deploying for a new collection change the following
;;  1. set comission contract that implemented comission-trait
;;  2. replace nft-asset-class with meaningful name e.g. megapont-ap
;;  3. set appropriate artist-address
;;  4. set COMM percentage (currently it is 10% = 1000)
;;  5. set COMM-ADDR
;;  6. set metadata-uri
;;  7. set mint-limit to how many tokens can be minted - total supply
;;  8. (optional) set mint-cap if tokens per user need to be capped.

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;; (use-trait commission-trait .commission-trait.commission)

(define-trait commission-trait
    (
      (pay (uint uint) (response bool uint))
    )
)


;; (impl-trait 'ST3R40A4Q12JWFX6PAGRNA408EWMAQ96F4YJMFTAJ.sf-v3-nft-trait.nft-trait)
;; (use-trait commission-trait 'ST3R40A4Q12JWFX6PAGRNA408EWMAQ96F4YJMFTAJ.sf-v3-commission-trait.commission)


(define-non-fungible-token nft-asset-class uint)

;; Constants
(define-constant DEPLOYER tx-sender)
(define-constant COMM u10)
(define-constant COMM-ADDR tx-sender)

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
(define-constant ERR-NO-MORE-MINTS u113)
(define-constant ERR-INVALID-PERCENTAGE u114)
(define-constant ERR-CONTRACT-LOCKED u115)

;; Internal variables
(define-data-var mint-limit uint u100)
(define-data-var last-id uint u1)
(define-data-var total-price uint u1000000)
(define-data-var artist-address principal tx-sender)
(define-data-var metadata-uri (string-ascii 256) "ipfs://QmTB5MJsqA8qEBHztsZwQ2pNs1fngSJQF5VwL1z3uCY8nn")
(define-data-var mint-paused bool true)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var mint-cap uint u10)
(define-data-var locked bool false)

(define-map mints-per-user principal uint)

(define-public (lock-contract)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set locked true)
    (ok true)))

(define-public (claim) 
  (mint (list true)))

;; Claim Many
;; #[allow(unchecked_data)]
(define-public (claim-many (orders (list 25 bool)))
  (mint-many orders))

;; Default Minting
(define-private (mint (orders (list 25 bool)))
  (mint-many orders))

;; #[allow(unchecked_data)]
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
      (unwrap! (nft-mint? nft-asset-class next-id tx-sender) next-id)
      (unwrap! (nft-transfer? nft-asset-class next-id tx-sender recipient) next-id)
      (map-set token-count recipient (+ (get-balance recipient) u1))      
      (+ next-id u1)
    )
    next-id))

;; other than DEPOYER cannot mint using this method.
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
      (unwrap! (nft-mint? nft-asset-class next-id tx-sender) next-id)
      (+ next-id u1)    
    )
    next-id))

;; #[allow(unchecked_data)]
(define-public (set-artist-address (address principal))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set artist-address address))))

;; #[allow(unchecked_data)]
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
        (nft-burn? nft-asset-class token-id tx-sender))
)


(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? nft-asset-class token-id) false)))

;; #[allow(unchecked_data)]
(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
    (var-set metadata-uri new-base-uri)
    (ok true)))

(define-public (freeze-metadata)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set metadata-frozen true)
    (ok true)))

;; ;; Non-custodial SIP-009 transfer function

;; ;; #[allow(unchecked_data)]
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-INVALID-USER))
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (match (trnsfr token-id sender recipient)
      id (ok true)
      err (err err)
    )
  )
)
;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? nft-asset-class token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (var-get metadata-uri))))

(define-read-only (get-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-price)
  (ok (var-get total-price)))

(define-read-only (get-mints (caller principal))
  (default-to u0 (map-get? mints-per-user caller)))

(define-read-only (get-mint-limit)
  (ok (var-get mint-limit)))

(define-read-only (get-mint-cap)
  (ok (var-get mint-cap)))

;; Non-custodial marketplace extras


(define-map token-count principal uint)
;; (define-map market uint {price: uint, commission: principal, royalty: uint})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

;; #[allow(unchecked_data)]
(define-private (trnsfr (token-id uint) (sender principal) (recipient principal))
  (let 
    (
      (recipient-balance (get-balance recipient))
    ) 
    (try! (nft-mint? nft-asset-class token-id tx-sender))
    (map-set token-count
            recipient
            (+ recipient-balance u1))
    (ok token-id)
  )
)
(begin
  (print {
    totalNfts: (var-get mint-limit),
    lastId: (var-get last-id),
    metadataUri: (var-get metadata-uri),
    price: (var-get total-price)
  })
)