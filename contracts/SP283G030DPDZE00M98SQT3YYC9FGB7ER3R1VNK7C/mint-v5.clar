(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token test-token-name-v5 uint)

;; Constants
(define-constant DEPLOYER tx-sender)
(define-constant COMM u1000)
(define-constant COMM-ADDR 'SP1XR5G30X40AFDC234FJYVCF7BJ5ASH90ZRTHXTW)
(define-constant USER-MINT-LIMIT u5)
(define-constant TOKEN-PRICE u1)
(define-constant WALLET_1 'SP283G030DPDZE00M98SQT3YYC9FGB7ER3R1VNK7C)

(define-constant ERR-NO-MORE-NFTS u100)
(define-constant ERR-PUBLIC-SALE-DISABLED u102)
(define-constant ERR-NOT-AUTHORIZED u104)
(define-constant ERR-INVALID-USER u105)
(define-constant ERR-LISTING u106)
(define-constant ERR-WRONG-COMMISSION u107)
(define-constant ERR-NOT-FOUND u108)
(define-constant ERR-PAUSED u109)
(define-constant ERR-MINT-LIMIT u110)
(define-constant ERR-TOKEN-LIMIT u111)
(define-constant ERR-METADATA-FROZEN u112)

;; Internal variables
(define-data-var mint-limit uint u3030) 
(define-data-var last-id uint u1) 
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/Qmc6LKWswvPUB2RV1TFzPvenxSt62DDSPgC4ib24m2csqV/") 
(define-data-var mint-paused bool false) 
(define-data-var sale-enabled bool true)
(define-data-var metadata-frozen bool false) 

(define-map token-count principal uint) 
(define-map market uint {price: uint, commission: principal}) 

(define-public (claim)
  (mint (list true))) 

(define-public (claim-two)
  (mint (list true true))) 

(define-public (claim-three)
  (mint (list true true true)))

(define-public (claim-four)
  (mint (list true true true true)))

(define-public (claim-five)
  (mint (list true true true true true)))
  
(define-private (mint (orders (list 5 bool)))
  (begin
    ;; (asserts! (var-get sale-enabled) (err ERR-PUBLIC-SALE-DISABLED))
    (mint-many orders)
  )
)

(define-private (mint-many (orders (list 5 bool ))) 
  (let ((last-nft-id (var-get last-id)) 
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (id-reached (fold mint-many-iter orders last-nft-id)) 
      (current-balance (get-balance tx-sender)) 
    )
    (asserts! (or (is-eq false (var-get mint-paused)) (is-eq tx-sender DEPLOYER)) (err ERR-PAUSED))
    (asserts! (<= (var-get last-id) (var-get mint-limit) ) (err ERR-MINT-LIMIT))
    (asserts! (or (is-eq tx-sender DEPLOYER) (<= (+ current-balance (len orders)) USER-MINT-LIMIT)) (err ERR-TOKEN-LIMIT))
    (if (is-eq tx-sender DEPLOYER)
      (begin (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
        (try! (stx-transfer? u10 tx-sender 'SP283G030DPDZE00M98SQT3YYC9FGB7ER3R1VNK7C)) 
      )
      (begin
        (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
        (try! (stx-transfer? u10 tx-sender 'SP283G030DPDZE00M98SQT3YYC9FGB7ER3R1VNK7C)) 
        ;; (try! (stx-transfer? (* u5 (- id-reached last-nft-id)) tx-sender WALLET_1)) 
        ;; (try! (stx-transfer? (* u1 (- id-reached last-nft-id)) tx-sender COMM-ADDR)) 
      )
    )
    
    (ok (+ id-reached u2000))))

(define-private (mint-many-iter (ignore bool) (next-id uint)) 
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? test-token-name-v5 next-id tx-sender) next-id)
      (+ next-id u1) 
    )
    next-id)) 


(define-public (toggle-pause)
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
    (ok (var-set mint-paused (not (var-get mint-paused))))))

(define-public (toggle-sale-state)
  (let 
    (
      (sale (not (var-get sale-enabled)))
    )
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
    (var-set sale-enabled sale)
    (ok true)))

(define-public (set-mint-limit (limit uint))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
    (asserts! (< limit (var-get mint-limit)) (err ERR-MINT-LIMIT))
    (ok (var-set mint-limit limit))))

(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
    (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
    (var-set ipfs-root new-base-uri)
    (ok true)))

(define-public (freeze-metadata)
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
    (var-set metadata-frozen true)
      (ok true)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? test-token-name-v5 token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))

(define-read-only (get-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-mint-limit)
  (ok (var-get mint-limit)))

(define-trait commission-trait
  ((pay (uint uint) (response bool uint))))

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? test-token-name-v5 id sender recipient)
    success
      (let (
        (sender-balance (get-balance sender))
        (recipient-balance (get-balance recipient)))
        (map-set token-count
          sender
          (- sender-balance u1)
        )
        (map-set token-count
          recipient
          (+ recipient-balance u1)
        )
        (ok success)
      )
    error (err error)
  )
)

(define-private (is-sender-owner (id uint))
  (let ((owner (unwrap! (nft-get-owner? test-token-name-v5 id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))
  )
)

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))


(define-public (list-in-ustx 
    (id uint) 
    (price uint) 
    (comm-trait <commission-trait>)
  )
  (let ((listing  {price: price, commission: (contract-of comm-trait)}))
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-set market id listing)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)
  )
)

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-delete market id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-ustx (id uint) (comm-trait <commission-trait>))
  (let ((owner (unwrap! (nft-get-owner? test-token-name-v5 id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
      (price (get price listing)))
    (asserts! 
      (is-eq 
          (contract-of comm-trait) 
          (get commission listing)
      ) 
      (err ERR-WRONG-COMMISSION)
    )
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)
  )
)