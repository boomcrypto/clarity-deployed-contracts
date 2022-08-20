(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token test-token-name-v22 uint)

;; Constants
(define-constant DEPLOYER tx-sender)
(define-constant USER-MINT-LIMIT u5)
(define-constant WALLET_1 'ST2KS2675QXBFSNK2X0HSYS3TEZ0719PFN9Z56N79)

(define-constant ERR-NO-MORE-NFTS u100)
(define-constant ERR-PUBLIC-SALE-DISABLED u102)
(define-constant ERR-NOT-AUTHORIZED u104)
(define-constant ERR-LISTING u106)
(define-constant ERR-WRONG-COMMISSION u107)
(define-constant ERR-NOT-FOUND u108)
(define-constant ERR-PAUSED u109)
(define-constant ERR-MINT-LIMIT u110)
(define-constant ERR-TOKEN-LIMIT u111)
(define-constant ERR-METADATA-FROZEN u112)

;; Internal variables
(define-data-var mint-limit uint u3036) 
(define-data-var last-id uint u1) 
(define-data-var stsw-price uint u1) 
(define-data-var metadata-uri (string-ascii 80) "ipfs://Qmb28DhaDebWKbDHDJWEB2R3bAget4sYQYfLkRpcdAYcYE/") 
(define-data-var mint-paused bool true) 
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false) 

(define-map users-tokens principal uint) 
(define-map markets uint {price: uint, commission: principal}) 

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
    (asserts! (or (is-eq true (var-get sale-enabled)) (is-eq tx-sender DEPLOYER)) (err ERR-PAUSED))
    (mint-many orders)
  )
)

(define-private (mint-many (orders (list 5 bool ))) 
  (let ((last-nft-id (var-get last-id)) 
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (mint-enabled (asserts! (or (is-eq false (var-get mint-paused)) (is-eq tx-sender DEPLOYER)) (err ERR-PAUSED)))
      (id-reached (fold mint-many-iter orders last-nft-id)) 
      (current-balance (get-balance tx-sender)) 
    )
    (asserts! (<= (var-get last-id) (var-get mint-limit) ) (err ERR-MINT-LIMIT))
    (asserts! (or (is-eq tx-sender DEPLOYER) (<= (+ current-balance (len orders)) USER-MINT-LIMIT)) (err ERR-TOKEN-LIMIT))
    (if (is-eq tx-sender DEPLOYER)
      (begin (var-set last-id id-reached)
        (map-set users-tokens tx-sender (+ current-balance (- id-reached last-nft-id)))
      )
      (begin
        (var-set last-id id-reached)
        (map-set users-tokens tx-sender (+ current-balance (- id-reached last-nft-id)))
        (try! (stx-transfer? u80000000 tx-sender WALLET_1)) 
      )
    )
    
    (ok id-reached)))

(define-private (mint-many-iter (ignore bool) (next-id uint)) 
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? test-token-name-v22 next-id tx-sender) next-id)
      (+ next-id u1) 
    )
    next-id)) 


(define-public (toggle-pause)
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
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
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
    (asserts! (< limit (var-get mint-limit)) (err ERR-MINT-LIMIT))
    (ok (var-set mint-limit limit))))

(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
    (var-set metadata-uri new-base-uri)
    (ok true)))

(define-public (freeze-metadata)
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
    (var-set metadata-frozen true)
      (ok true)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? markets id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? test-token-name-v22 token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get metadata-uri) "{id}") ".json"))))

(define-read-only (get-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-mint-limit)
  (ok (var-get mint-limit)))

(define-trait commission-trait
  ((pay (uint uint) (response bool uint))))

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? users-tokens account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? test-token-name-v22 id sender recipient)
    success
      (let (
        (sender-balance (get-balance sender))
        (recipient-balance (get-balance recipient)))
        (map-set users-tokens
          sender
          (- sender-balance u1)
        )
        (map-set users-tokens
          recipient
          (+ recipient-balance u1)
        )
        (ok success)
      )
    error (err error)
  )
)

(define-private (is-sender-owner (id uint))
  (let ((owner (unwrap! (nft-get-owner? test-token-name-v22 id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))
  )
)

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? markets id))


(define-public (list-in-ustx 
    (id uint) 
    (price uint) 
    (comm-trait <commission-trait>)
  )
  (let ((listing  {price: price, commission: (contract-of comm-trait)}))
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-set markets id listing)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)
  )
)

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-delete markets id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-ustx (id uint) (comm-trait <commission-trait>))
  (let ((owner (unwrap! (nft-get-owner? test-token-name-v22 id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? markets id) (err ERR-LISTING)))
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
    (map-delete markets id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)
  )
)


(define-public (claim-stsw)
  (mint-stsw (list true))) 

(define-public (claim-stsw-two)
  (mint-stsw (list true true))) 

(define-public (claim-stsw-three)
  (mint-stsw (list true true true))) 

(define-public (claim-stsw-four)
  (mint-stsw (list true true true true)))

(define-public (claim-stsw-five)
  (mint-stsw (list true true true true true)))

(define-private (mint-stsw (orders (list 5 bool)))
  (begin
    (asserts! (var-get sale-enabled) (err ERR-PUBLIC-SALE-DISABLED))
    (mint-many-stsw orders)
  )
)

(define-private (mint-many-stsw (orders (list 5 bool ))) 
  (let ((last-nft-id (var-get last-id)) 
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (id-reached (fold mint-many-iter orders last-nft-id)) 
      (current-balance (get-balance tx-sender)))
    (asserts! (or (is-eq false (var-get mint-paused)) (is-eq tx-sender DEPLOYER)) (err ERR-PAUSED))
    (asserts! (<= (var-get last-id) (var-get mint-limit) ) (err ERR-MINT-LIMIT))
    (asserts! (or (is-eq tx-sender DEPLOYER) (< (+ current-balance (len orders)) USER-MINT-LIMIT)) (err ERR-TOKEN-LIMIT))
    (if (is-eq tx-sender DEPLOYER)
      (begin (var-set last-id id-reached)
        (map-set users-tokens tx-sender (+ current-balance (- id-reached last-nft-id))))
      (begin (var-set last-id id-reached)
        (map-set users-tokens tx-sender (+ current-balance (- id-reached last-nft-id)))
        (try! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a transfer (var-get stsw-price) tx-sender WALLET_1 (some 0x00))) ))
    (ok true))
    )

(define-public (set-stsw-price (new-price uint))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
    (ok (var-set stsw-price new-price))))