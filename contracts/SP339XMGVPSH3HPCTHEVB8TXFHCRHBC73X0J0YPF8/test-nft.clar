(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

(define-constant ERR-NO-AUTHORITY u1001)
(define-constant ERR-FROZEN u1002)
(define-constant ERR-LISTING u1003)
(define-constant ERR-WRONG-COMMISSION u1004)
(define-constant ERR-NOT-FOUND u1005)
(define-constant ERR-INVALID-VALUE u1006)
(define-constant ERR-MINT-OUT u1007)
(define-constant ERR-MINT-NOT-OPEN u1008)
(define-constant ERR-STX-UNENOUGH u1009)
(define-constant ERR-INVALID-LIST u1010)

(define-non-fungible-token TestNFT uint)

(define-constant CREATOR tx-sender)
(define-constant MAX-TOKEN-COUNT u1000)

(define-data-var m-collection-data-frozen bool false)
(define-data-var m-collection-attribute (string-utf8 666) u"")
(define-data-var m-collection-icon-data (buff 128000) 0x)
(define-data-var m-token-uri (string-ascii 256) "")

(define-map map-token-data uint (buff 128000))
(define-map map-token-attribute uint (string-utf8 666))
(define-map map-token-count principal uint)

(define-read-only (get-last-token-id)
  (ok MAX-TOKEN-COUNT)
)

(define-read-only (get-token-uri (tokenId uint))
  (ok (some (var-get m-token-uri)))  
)

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? TestNFT id))
)

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq sender tx-sender) (err ERR-NO-AUTHORITY))
    (asserts! (is-none (map-get? map-market id)) (err ERR-LISTING))
    (asserts! (is-none (get name (unwrap! (principal-destruct? tx-sender) (err ERR-NO-AUTHORITY)))) (err ERR-NO-AUTHORITY))
    (trnsfr id sender recipient)
  )
)

(define-read-only (get-collection-attribute)
  (ok (some (var-get m-collection-attribute)))
)

(define-read-only (get-collection-icon-data)
  (ok (some (var-get m-collection-icon-data)))
)

(define-read-only (get-collection-icon-mime-type)
  (ok (some u"image/jpeg"))
)

(define-read-only (get-token-data (id uint))
  (ok (map-get? map-token-data id))
)

(define-read-only (get-token-data-mime-type (id uint))
  (ok (some u"image/jpeg"))
)

(define-read-only (get-token-attribute (id uint))
  (ok (map-get? map-token-attribute id))
)

(define-read-only (get-balance (account principal))
  (default-to u0 (map-get? map-token-count account))
)

(define-public (set-token-uri (uri (string-ascii 256)))
  (ok (and (is-eq contract-caller CREATOR) (var-set m-token-uri uri)))
)

(define-public (set-collection-attribute (value (string-utf8 666)))
  (begin
    (asserts! (not (var-get m-collection-data-frozen)) (err ERR-FROZEN))
    (asserts! (is-eq contract-caller CREATOR) (err ERR-NO-AUTHORITY))
    (ok (var-set m-collection-attribute value))
  )
)

(define-public (set-collection-icon-data (value (buff 128000)))
  (begin
    (asserts! (not (var-get m-collection-data-frozen)) (err ERR-FROZEN))
    (asserts! (is-eq contract-caller CREATOR) (err ERR-NO-AUTHORITY))
    (ok (var-set m-collection-icon-data value))
  )
)

(define-public (set-tokens (values (list 8 { id: uint, data: (buff 128000), attribute: (string-utf8 666) })))
  (begin
    (asserts! (not (var-get m-collection-data-frozen)) (err ERR-FROZEN))
    (asserts! (is-eq contract-caller CREATOR) (err ERR-NO-AUTHORITY))
    (map set-token values)
    (ok true)
  )
)

(define-private (set-token (value { id: uint, data: (buff 128000), attribute: (string-utf8 666) }))
  (and
    (map-set map-token-data (get id value) (get data value))
    (map-set map-token-attribute (get id value) (get attribute value))
  )
)

(define-read-only (is-collection-data-frozen)
  (var-get m-collection-data-frozen)
)

(define-public (freeze-collection-data)
  (ok (and (is-eq contract-caller CREATOR) (var-set m-collection-data-frozen true)))
)

;;; mint
(define-data-var m-mint-price uint u10000)  
(define-data-var m-next-id int 1)
(define-data-var m-available-ids (list 1000 (buff 2)) (list ))
(define-data-var m-minted-ids (list 1000 (buff 2)) (list ))
(define-data-var m-tmp-buff2 (buff 2) 0x)
(define-data-var m-mint-share-percent uint u1000)
(define-constant LIST-10 (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10))

(define-read-only (get-mint-price)
  (var-get m-mint-price)
)

(define-public (set-mint-price (price uint))
  (ok (and (is-eq contract-caller CREATOR) (var-set m-mint-price price)))
)

(define-read-only (get-available-ids)
  (var-get m-available-ids)
)

(define-read-only (get-available-count)
  (len (var-get m-available-ids))
)

(define-read-only (get-minted-ids)
  (var-get m-minted-ids)
)

(define-read-only (get-minted-count)
  (len (var-get m-minted-ids))
)

(define-private (int2buff2 (value int))
  (unwrap-panic (as-max-len? (unwrap-panic (slice? (unwrap-panic (to-consensus-buff? value)) u15 u17)) u2))
)

(define-private (fill-available-ids)
  (begin (map loop1 LIST-10) true)
)

(define-private (loop1 (index uint))
  (begin (map loop2 LIST-10) true)
)

(define-private (loop2 (index uint))
  (begin (map loop3 LIST-10) true)
)

(define-private (loop3 (index uint))
  (and
    (var-set m-available-ids (unwrap-panic (as-max-len? (append (var-get m-available-ids) (int2buff2 (var-get m-next-id))) u1000)))
    (var-set m-next-id (+ (var-get m-next-id) 1))
  )
)

;; fill with (list u1, u2,.. u1000)
(fill-available-ids)
(print (var-get m-available-ids))

(define-public (mint)
  (let
    (
      (available-count (len (var-get m-available-ids)))
      (last-stamp (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))))
      (rand-value (+ (* (/ stx-liquid-supply u100000) u31) (* stacks-block-height u997) (* last-stamp last-stamp u49957)))
      (check_point (asserts! (> available-count u0) (err ERR-MINT-OUT)))
      (rand-index (mod rand-value available-count))
      (rand-buff (unwrap! (element-at (var-get m-available-ids) rand-index) (err ERR-INVALID-VALUE)))
      (rand-id (buff-to-uint-be rand-buff))
      (mint-price (var-get m-mint-price))
      (partner-stx (/ (* mint-price (var-get partner-percent)) u10000))
      (team-stx (/ (* mint-price (var-get royalty-percent)) u10000))
      (share-stx (/ (* mint-price (var-get m-mint-share-percent)) u10000))
    )
    (asserts! (>= last-stamp (var-get mint-open-time)) (err ERR-MINT-NOT-OPEN))
    (unwrap! (stx-transfer? mint-price tx-sender (as-contract tx-sender)) (err ERR-STX-UNENOUGH))
    (as-contract
      (begin
        (and (> partner-stx u0) (unwrap! (stx-transfer? partner-stx tx-sender (var-get partner-address)) (err ERR-STX-UNENOUGH)))
        (and (> team-stx u0) (unwrap! (stx-transfer? team-stx tx-sender (var-get team-address)) (err ERR-STX-UNENOUGH)))
        (and (> share-stx u0) (< available-count MAX-TOKEN-COUNT) (share share-stx))
        (unwrap! (stx-transfer? (- mint-price team-stx partner-stx share-stx) tx-sender (var-get partner-address)) (err ERR-STX-UNENOUGH))
        (and (> (stx-get-balance tx-sender) u0) (unwrap! (stx-transfer? (stx-get-balance tx-sender) tx-sender CREATOR) (err ERR-STX-UNENOUGH)))
      )
    )
    (var-set m-tmp-buff2 rand-buff)
    (var-set m-available-ids (filter not-tmp-id (var-get m-available-ids)))
    (var-set m-minted-ids (unwrap! (as-max-len? (append (var-get m-minted-ids) rand-buff) u1000) (err ERR-INVALID-LIST)))
    (print {a: "mint", rand-buff: rand-buff, rand-id: rand-id })
    (map-set map-token-count tx-sender (+ (get-balance tx-sender) u1))
    (nft-mint? TestNFT rand-id tx-sender)
  )
)

(define-private (not-tmp-id (value (buff 2)))
  (not (is-eq value (var-get m-tmp-buff2)))
)

;;; market
(define-data-var mint-open-time uint u0)
(define-data-var partner-address principal tx-sender)
(define-data-var partner-percent uint u1000)
(define-data-var team-address principal 'SP2E22MH280M0TD2TQ4RJNS4F6Z2R7PSJV2EN8RD3)
(define-data-var royalty-percent uint u200)
(define-map map-market uint {price: uint, commission: principal, royalty: uint})

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? TestNFT id sender recipient)
    success
      (ok 
        (and
          (map-set map-token-count sender (- (get-balance sender) u1))
          (map-set map-token-count recipient (+ (get-balance recipient) u1))
        )
      )
    error (err error)
  )
)

(define-private (is-sender-owner (id uint))
  (is-eq (nft-get-owner? TestNFT id) (some tx-sender))
)

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? map-market id)
)

(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let
    (
      (listing {price: price, commission: (contract-of comm-trait), royalty: (var-get royalty-percent)})
    )
    (asserts! (is-sender-owner id) (err ERR-NO-AUTHORITY))
    (asserts! (and (>= price u10000) (<= price u100000000000000)) (err ERR-INVALID-VALUE)) 
    (map-set map-market id listing)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)
  )
)

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) (err ERR-NO-AUTHORITY))
    (map-delete map-market id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)
  )
)

(define-public (buy-in-ustx (id uint) (comm-trait <commission-trait>))
  (let 
    (
      (listing (unwrap! (map-get? map-market id) (err ERR-LISTING)))
      (owner (unwrap! (nft-get-owner? TestNFT id) (err ERR-NOT-FOUND)))
      (price (get price listing))
      (royalty (get royalty listing))
    )
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
    (try! (stx-transfer? price tx-sender owner))
    (try! (pay-royalty price royalty))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete map-market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)
  )
)

(define-read-only (get-partner-percent)
  (ok (var-get partner-percent))
)

(define-public (set-partner-percent (percent uint))
  (begin
    (asserts! (is-eq tx-sender (var-get partner-address)) (err ERR-NO-AUTHORITY))
    (asserts! (and (>= percent u0) (<= percent u1000)) (err ERR-INVALID-VALUE))
    (ok (var-set partner-percent percent))
  )
)

(define-read-only (get-partner-address)
  (ok (var-get partner-address))
)

(define-public (set-partner-address (address principal))
  (ok (and (is-eq tx-sender (var-get partner-address)) (var-set partner-address address)))
)

(define-read-only (get-royalty-percent)
  (ok (var-get royalty-percent))
)

(define-public (set-royalty-percent (percent uint))
  (begin
    (asserts! (is-eq tx-sender (var-get team-address)) (err ERR-NO-AUTHORITY))
    (asserts! (and (>= percent u0) (<= percent u500)) (err ERR-INVALID-VALUE))
    (ok (var-set royalty-percent percent))
  )
)

(define-read-only (get-team-address)
  (ok (var-get team-address))
)

(define-public (set-team-address (address principal))
  (ok (and (is-eq tx-sender (var-get team-address)) (var-set team-address address)))
)

(define-private (pay-royalty (price uint) (royalty uint))
  (let
    (
      (royalty-amount (/ (* price royalty) u10000))
      (half-amount (/ royalty-amount u2))
    )
    (ok
      (and
        (> half-amount u0) 
        (try! (stx-transfer? half-amount tx-sender (var-get team-address)))
        (share half-amount)
      )
    )
  )
)

(define-private (share (amount uint))
  (let
    (
      (per_holder_award (/ amount u10))
      (last-stamp (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))))
      (rand-value (+ (* (/ stx-liquid-supply u100000) u31) (* stacks-block-height u997) (* last-stamp last-stamp u49957)))
      (step (/ last-stamp u73))
    )
    (fold loop-award LIST-10 { index: rand-value, step: step, award: per_holder_award })
    true
  )
)

(define-private (loop-award (i uint) (ud { index: uint, step: uint, award: uint }))
  (let
    (
      (moded-index (mod (get index ud) (len (var-get m-minted-ids))))
      (id-buff (unwrap! (element-at (var-get m-minted-ids) moded-index) ud))
      (id (buff-to-uint-be id-buff))
      (owner (unwrap! (nft-get-owner? TestNFT id) ud))
    )
    (print {a: "loop-award", id: id})
    (unwrap! (stx-transfer? (get award ud) tx-sender owner) ud)
    (merge ud {
      index: (+ (get index ud) (get step ud)),
    })
  )
)
