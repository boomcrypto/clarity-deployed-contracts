;; sf-continuous
;; contractType: continuous-sb


;; checklist when deploying for a new collection change the following
;;  1. set comission contract that implemented comission-trait
;;  2. replace nft-asset-class with meaningful name e.g. megapont-ap
;;  3. set appropriate artist-address
;;  4. set the approriate royalties

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-trait commission-trait
    (
      (pay (uint uint) (response bool uint))
    )
)

(define-non-fungible-token nft-asset-class uint)

(define-constant DEPLOYER tx-sender)

(define-constant ERR-NOT-AUTHORIZED u101)
(define-constant ERR-INVALID-USER u102)
(define-constant ERR-LISTING u103)
(define-constant ERR-WRONG-COMMISSION u104)
(define-constant ERR-NOT-FOUND u105)
(define-constant ERR-NFT-MINT u106)
(define-constant ERR-CONTRACT-LOCKED u107)
(define-constant ERR-METADATA-FROZEN u111)
(define-constant ERR-INVALID-PERCENTAGE u114)
(define-constant ERR-MINTPASS-LISTED u115)

(define-data-var last-id uint u0)
(define-data-var artist-address principal tx-sender)
(define-data-var locked bool false)
(define-data-var metadata-frozen bool false)

(define-map cids uint (string-ascii 256))
(define-map mint-passes uint (string-ascii 256))


(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal, royalty: uint})


(define-public (lock-contract)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set locked true)
    (ok true)))

;; #[allow(unchecked_data)]
(define-public (set-artist-address (address principal))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set artist-address address))))

(define-public (burn (token-id uint))
   (match (map-get? mint-passes token-id)
      uri (begin 
          (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
          (match (map-get? market token-id)
              item (err ERR-MINTPASS-LISTED)
              (begin 
                (map-delete mint-passes token-id)
                (print {method: "burn", tokenId: token-id})
                (ok true)
              ))
      )
      (begin 
        (asserts! (is-owner token-id tx-sender) (err ERR-NOT-AUTHORIZED))
        (print {method: "burn", tokenId: token-id})
        (nft-burn? nft-asset-class token-id tx-sender))
    )
)

(define-private (is-owner (token-id uint) (user principal))
  (is-eq user (unwrap! (nft-get-owner? nft-asset-class token-id) false)))
 
;; #[allow(unchecked_data)]
(define-public (set-token-uri (uri (string-ascii 256)) (token-id uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
    (match (map-get? mint-passes token-id)
      old-uri (map-set mint-passes token-id uri)
      (map-set cids token-id uri)
    )
    (ok true)
  )
)

(define-public (freeze-metadata)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set metadata-frozen true)
    (ok true)))

;; #[allow(unchecked_data)]
(define-public (transfer (mint-pass uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-INVALID-USER))
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (match (trnsfr mint-pass sender recipient)
      token-id (ok true)
      err (err err)
    )
  )
)

(define-read-only (get-owner (token-id uint))
  (match (nft-get-owner? nft-asset-class token-id)
    owner (ok (some owner))
    (match (map-get? mint-passes token-id)
      uri (ok (some DEPLOYER))
      (err ERR-NOT-FOUND)
    )
  )
)

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
  (match (map-get? cids token-id)
    uri (ok (some uri))
    (match (map-get? mint-passes token-id)
      uri (ok (some uri))
      (err ERR-NOT-FOUND)
    )
  )
)

;; #[allow(unchecked_data)]
(define-public (create-mint-passes (uris (list 25 (string-ascii 256))))
  (let 
    (
      (art-addr (var-get artist-address))
      (pass-ids (map create-mint-pass uris))
    )
    (asserts! (or (is-eq tx-sender DEPLOYER) (is-eq tx-sender art-addr)) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (var-get locked) false) (err ERR-CONTRACT-LOCKED))
    (print {
      mintPasses: pass-ids,
      uris: uris
    })
    (ok pass-ids)))

(define-private (create-mint-pass (uri (string-ascii 256)))
  (let 
    (
      (pass-id (+ (var-get last-id) u1))
    )
    (map-set mint-passes pass-id uri)
    (var-set last-id pass-id)
    pass-id
  )
)

;; NON-CUSTODIAL FUNCTIONS START
(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (mint-pass uint) (sender principal) (recipient principal))
  (let 
    (
      (uri (unwrap! (map-get? mint-passes mint-pass) (err ERR-NOT-FOUND)))
      (recipient-balance (get-balance recipient))
    ) 
    (try! (nft-mint? nft-asset-class mint-pass recipient))
    (map-delete mint-passes mint-pass)
    (map-delete market mint-pass)
    (map-set cids mint-pass uri)      
    (map-set token-count
            recipient
            (+ recipient-balance u1))
    (ok mint-pass)
  )
)

(define-private (is-sender-owner (mint-pass uint))
  (begin
    (unwrap! (map-get? mint-passes mint-pass) false)
    (or (is-eq tx-sender DEPLOYER) (is-eq tx-sender (var-get artist-address)))
  )
)

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (mint-pass uint) (price uint) (comm-trait <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm-trait), royalty: (var-get royalty-percent)}))
    (asserts! (is-sender-owner mint-pass) (err ERR-NOT-AUTHORIZED))
    (map-set market mint-pass listing)
    (print (merge listing {a: "list-in-ustx", mint-pass: mint-pass}))
    (ok true)))

(define-public (unlist-in-ustx (mint-pass uint))
  (begin
    (asserts! (is-sender-owner mint-pass) (err ERR-NOT-AUTHORIZED))
    (map-delete market mint-pass)
    (print {a: "unlist-in-ustx", mint-pass: mint-pass})
    (ok true)))

;; (define-public (buy-in-ustx (mint-pass uint) (comm-trait <commission-trait>))
;;   (let ((owner DEPLOYER)
;;       (listing (unwrap! (map-get? market mint-pass) (err ERR-LISTING)))
;;       (price (get price listing))
;;       (royalty (get royalty listing)))
;;     (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
;;     (try! (stx-transfer? price tx-sender owner))
;;     (try! (pay-royalty price royalty))
;;     (try! (contract-call? comm-trait pay mint-pass price))
;;     (print {a: "buy-in-ustx", mint-pass: mint-pass})
;;     (trnsfr mint-pass owner tx-sender)
;;   )
;; )
    
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

;; NON-CUSTODIAL FUNCTIONS END