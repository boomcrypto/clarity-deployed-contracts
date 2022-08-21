;; Moons
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait commission-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.commission-trait.commission)

(define-non-fungible-token Moons uint)

;; Constants
(define-constant DEPLOYER tx-sender)

(define-constant ERR-NO-MORE-NFTS u100)
(define-constant ERR-NOT-AUTHORIZED u104)
(define-constant ERR-INVALID-USER u105)
(define-constant ERR-LISTING u106)
(define-constant ERR-WRONG-COMMISSION u107)
(define-constant ERR-NOT-FOUND u108)
(define-constant ERR-PAUSED u109)
(define-constant ERR-METADATA-FROZEN u111)
(define-constant ERR-NO-MORE-MINTS u113)

;; Internal variables
(define-data-var mint-limit uint u644)
(define-data-var mint-contract principal DEPLOYER)
(define-data-var last-id uint u1)
(define-data-var artist-address principal 'SP8F65F85PMRZK043DTME3E1TQ4EM5R3VS8TSJC7)
(define-data-var ipfs-root (string-ascii 80) "ipfs://bafybeidyvegx3xasilgbqe5zvcqitshmcc25xqvl3grgfk46yiqvrxnknu/")
(define-data-var metadata-frozen bool false)
;; ;; passed id -> actual order id.
;; (define-map mint-order uint uint) ;; TODO: remove me. 

(define-public (mint (principal principal) (id uint))  
  (let 
    (
      (last-nft-id (var-get last-id))
    )
    (asserts! (is-eq contract-caller (var-get mint-contract)) (err ERR-NOT-AUTHORIZED))
    (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS))
    (try! (nft-mint? Moons id principal))
    (map-set token-count principal
      (+ (default-to u0 (map-get? token-count principal)) u1))
    (var-set last-id (+ (var-get last-id) u1))
    (ok last-nft-id)
    )    
  )

(define-public (burn (token-id uint))
  (begin 
    (asserts! (is-owner token-id tx-sender) (err ERR-NOT-AUTHORIZED))
    (nft-burn? Moons token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? Moons token-id) false)))

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
  (ok (nft-get-owner? Moons token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (if (<= token-id (var-get mint-limit))
    (ok none)
    (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))
  )

;; Mint
(define-public (set-mint (new-mint principal))
  (begin
    (print {a: DEPLOYER, b: (var-get mint-contract), c: new-mint})
    (asserts! (is-eq DEPLOYER (var-get mint-contract)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set mint-contract new-mint)))
)

;; Non-custodial marketplace extras
(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? Moons id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? Moons id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? Moons id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))