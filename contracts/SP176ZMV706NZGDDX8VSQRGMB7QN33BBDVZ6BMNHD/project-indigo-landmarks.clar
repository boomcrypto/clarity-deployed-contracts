(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait commission-trait .commission-trait.commission)

;; Storage
(define-map token-count principal uint)
(define-map minted principal bool)
(define-map market uint {price: uint, commission: principal})

;; Non Fungible Token, using sip-009
(define-non-fungible-token project-indigo-landmarks uint)

(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-AUCTION-NOT-OVER (err u1001))
(define-constant ERR-AUCTION-OVER (err u1002))
(define-constant ERR-RESERVE-NOT-MET (err u1003))
(define-constant ERR-WRONG-COMMISSION (err u301))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-BID-TOO-LOW (err u1004))
(define-constant ERR-LISTING (err u507))
(define-constant CONTRACT-OWNER tx-sender)

(define-data-var last-id uint u0)
(define-data-var target-block uint u41099)
(define-data-var reserve uint u100000)
(define-data-var random uint u0)
(define-data-var active bool true)
(define-data-var artist-address-1 principal 'SP1EV6DEGJYN4NC4GS94MTXKF8PAQ5ZNA4QHJ2VZ6)
(define-data-var artist-address-2 principal 'SP1AD4C22XFTYTV12G0MCGSPGC1B6KP2H1FBJKHWE)
(define-data-var artist-address-3 principal 'SP1WPW265R43CEDYQSY1NMPE2C2EN73A7HY8PBNDM)
(define-data-var artist-address-4 principal 'SP2H2ZB08EW097TPDQPDPPJ6B73YAZS4V2KNSDC04)
(define-data-var split-1 uint u1000)
(define-data-var split-2 uint u2500)
(define-data-var split-3 uint u3900)
(define-data-var split-4 uint u2600)
(define-data-var wallet-1 principal 'SP1EV6DEGJYN4NC4GS94MTXKF8PAQ5ZNA4QHJ2VZ6)
(define-data-var wallet-2 principal 'SP1AD4C22XFTYTV12G0MCGSPGC1B6KP2H1FBJKHWE)
(define-data-var wallet-3 principal 'SP1WPW265R43CEDYQSY1NMPE2C2EN73A7HY8PBNDM)
(define-data-var wallet-4 principal 'SP2H2ZB08EW097TPDQPDPPJ6B73YAZS4V2KNSDC04)
(define-data-var royalty-1 uint u100)
(define-data-var royalty-2 uint u100)
(define-data-var royalty-3 uint u100)
(define-data-var royalty-4 uint u100)

(define-map metadata uint { uri: (string-ascii 53) })
(define-map bids { item-id: uint } { buyer: principal, offer: uint })
(define-map empty-bid { item-id: uint } { buyer: principal, offer: uint })

(map-set empty-bid { item-id: u0 } { buyer: (var-get artist-address-1), offer: u0 })


;; Token count for account
(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? project-indigo-landmarks id sender recipient)
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

;; SIP009: Transfer token to a specified principal
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? market id)) ERR-LISTING)
    (trnsfr id sender recipient)))

(define-public (bid (amount uint))
    (let (
        (next-id (+ (var-get last-id) u1))
        (name (if (is-some (map-get? bids { item-id: next-id } )) (map-get? bids { item-id: next-id }) (map-get? empty-bid { item-id: u0 }) ))
        (offer (unwrap-panic (get offer name)))
        (target (var-get target-block))
    )
    (asserts! (<= block-height target) ERR-AUCTION-OVER)
    (asserts! (> amount offer) ERR-BID-TOO-LOW)
    (match (stx-transfer? amount tx-sender (as-contract tx-sender))
      success (begin
     (map-set bids { item-id: next-id } { buyer: tx-sender, offer: amount })
     (ok next-id)
    )
    error (err error)
    )
    )
)

(define-read-only (get-bid)
    (let (
        (next-id (+ (var-get last-id) u1))
    )
     (ok (map-get? bids { item-id: next-id } ))
    )
)

(define-public (auction-ended)
    (let (
        (next-id (+ (var-get last-id) u1))
        (name (map-get? bids { item-id: next-id } ))
        (offer (unwrap-panic (get offer name)))
        (buyer (unwrap-panic (get buyer name)))
        (target (var-get target-block))
        (reserve-price (var-get reserve))
        (artist-1 (var-get artist-address-1))
        (artist-2 (var-get artist-address-2))
        (artist-3 (var-get artist-address-3))
        (artist-4 (var-get artist-address-4))
    )
    (asserts! (> block-height target) ERR-AUCTION-NOT-OVER)
    (asserts! (>= offer reserve-price) ERR-RESERVE-NOT-MET)
    (begin
    (try! (as-contract (stx-transfer? (/ (* offer (var-get split-1)) u10000) (as-contract tx-sender) (var-get artist-address-1))))
    (try! (as-contract (stx-transfer? (/ (* offer (var-get split-2)) u10000) (as-contract tx-sender) (var-get artist-address-2))))
    (try! (as-contract (stx-transfer? (/ (* offer (var-get split-3)) u10000) (as-contract tx-sender) (var-get artist-address-3))))
    (try! (as-contract (stx-transfer? (/ (* offer (var-get split-4)) u10000) (as-contract tx-sender) (var-get artist-address-4))))
    (match (nft-mint? project-indigo-landmarks next-id buyer)
        success
        (let
        ((current-balance (get-balance buyer)))
          (begin
            (var-set last-id next-id)
            (map-set token-count
              buyer
              (+ current-balance u1)
            )
            (map-set minted buyer true)
            (map-delete bids { item-id: next-id } )
            (var-set last-id next-id)
            (ok true)))
        error (err (* error u10000)))))
)

(define-public (admin-unbid)
    (let (
        (next-id (+ (var-get last-id) u1))
        (name (map-get? bids { item-id: next-id } ))
        (offer (unwrap-panic (get offer name)))
        (buyer (unwrap-panic (get buyer name)))
    )
    (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (try! (as-contract (stx-transfer? offer (as-contract tx-sender) buyer)))
     (map-delete bids { item-id: next-id } )
     (ok true)
    )
)
)

(define-public (mint-and-burn (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
  (begin
    (try! (nft-mint? project-indigo-landmarks value (as-contract tx-sender)))
    (try! (nft-burn? project-indigo-landmarks value (as-contract tx-sender)))
    (var-set last-id (+ (var-get last-id) u1))
    (ok true)
  )
    ERR-NOT-AUTHORIZED
  )
)

(define-public (burn (value uint))
  (begin
    (try! (nft-burn? project-indigo-landmarks value tx-sender))
    (ok true)
  )
)

(define-private (is-sender-owner (id uint))
  (let ((owner (unwrap! (nft-get-owner? project-indigo-landmarks id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm)}))
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

(define-public (buy-in-ustx (id uint) (comm <commission-trait>))
  (let ((owner (unwrap! (nft-get-owner? project-indigo-landmarks id) ERR-NOT-FOUND))
      (listing (unwrap! (map-get? market id) ERR-LISTING))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (pay-royalty price))
    (try! (contract-call? comm pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))


(define-public (pay-royalty (price uint))
    (let (
        (royalty-one (/ (* price (var-get royalty-1)) u10000))
        (royalty-two (/ (* price (var-get royalty-2)) u10000))
        (royalty-three (/ (* price (var-get royalty-3)) u10000))
        (royalty-four (/ (* price (var-get royalty-4)) u10000))
    )
    (if (> (var-get royalty-1) u0)
        (try! (stx-transfer? royalty-one tx-sender (var-get wallet-1)))
        (print false)
    )
    (if (> (var-get royalty-2) u0)
        (try! (stx-transfer? royalty-two tx-sender (var-get wallet-2)))
        (print false)
    )
    (if (> (var-get royalty-3) u0)
        (try! (stx-transfer? royalty-three tx-sender (var-get wallet-3)))
        (print false)
    )
    (if (> (var-get royalty-4) u0)
        (try! (stx-transfer? royalty-three tx-sender (var-get wallet-4)))
        (print false)
    )
    (ok true)
    )
)

(define-public (admin-mint (receiver principal))
(let (
  (next-id (+ (var-get last-id) u1))
  )
    (begin
      (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
      (match (nft-mint? project-indigo-landmarks next-id receiver)
        success
        (let
        ((current-balance (get-balance receiver)))
          (begin
            (var-set last-id next-id)
            (map-set token-count
              receiver
              (+ current-balance u1)
            )
            (map-set minted receiver true)
            (map-delete bids { item-id: next-id } )
            (var-set last-id next-id)
            (ok true)))
        error (err (* error u10000)))))
)

;; Pick random functionality
(define-map chosen-ids uint uint)
(define-data-var remaining uint u3000)
(define-data-var last-block uint u0)
(define-data-var last-vrf (buff 64) 0x00)

(define-constant BUFF_TO_BYTE (list
    0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x0a 0x0b 0x0c 0x0d 0x0e 0x0f
    0x10 0x11 0x12 0x13 0x14 0x15 0x16 0x17 0x18 0x19 0x1a 0x1b 0x1c 0x1d 0x1e 0x1f 
    0x20 0x21 0x22 0x23 0x24 0x25 0x26 0x27 0x28 0x29 0x2a 0x2b 0x2c 0x2d 0x2e 0x2f
    0x30 0x31 0x32 0x33 0x34 0x35 0x36 0x37 0x38 0x39 0x3a 0x3b 0x3c 0x3d 0x3e 0x3f
    0x40 0x41 0x42 0x43 0x44 0x45 0x46 0x47 0x48 0x49 0x4a 0x4b 0x4c 0x4d 0x4e 0x4f
    0x50 0x51 0x52 0x53 0x54 0x55 0x56 0x57 0x58 0x59 0x5a 0x5b 0x5c 0x5d 0x5e 0x5f 
    0x60 0x61 0x62 0x63 0x64 0x65 0x66 0x67 0x68 0x69 0x6a 0x6b 0x6c 0x6d 0x6e 0x6f
    0x70 0x71 0x72 0x73 0x74 0x75 0x76 0x77 0x78 0x79 0x7a 0x7b 0x7c 0x7d 0x7e 0x7f
    0x80 0x81 0x82 0x83 0x84 0x85 0x86 0x87 0x88 0x89 0x8a 0x8b 0x8c 0x8d 0x8e 0x8f
    0x90 0x91 0x92 0x93 0x94 0x95 0x96 0x97 0x98 0x99 0x9a 0x9b 0x9c 0x9d 0x9e 0x9f
    0xa0 0xa1 0xa2 0xa3 0xa4 0xa5 0xa6 0xa7 0xa8 0xa9 0xaa 0xab 0xac 0xad 0xae 0xaf
    0xb0 0xb1 0xb2 0xb3 0xb4 0xb5 0xb6 0xb7 0xb8 0xb9 0xba 0xbb 0xbc 0xbd 0xbe 0xbf 
    0xc0 0xc1 0xc2 0xc3 0xc4 0xc5 0xc6 0xc7 0xc8 0xc9 0xca 0xcb 0xcc 0xcd 0xce 0xcf 
    0xd0 0xd1 0xd2 0xd3 0xd4 0xd5 0xd6 0xd7 0xd8 0xd9 0xda 0xdb 0xdc 0xdd 0xde 0xdf 
    0xe0 0xe1 0xe2 0xe3 0xe4 0xe5 0xe6 0xe7 0xe8 0xe9 0xea 0xeb 0xec 0xed 0xee 0xef
    0xf0 0xf1 0xf2 0xf3 0xf4 0xf5 0xf6 0xf7 0xf8 0xf9 0xfa 0xfb 0xfc 0xfd 0xfe 0xff
))

(define-data-var b-idx uint u0)

(define-private (set-vrf)
    (var-set last-vrf (sha512 (unwrap-panic (get-block-info? vrf-seed (- block-height u1)))))
)

(define-read-only (rand (byte-idx uint))
    (let ((vrf (var-get last-vrf)) )
        (+ 
            (* (unwrap-panic (index-of BUFF_TO_BYTE (unwrap-panic (element-at vrf byte-idx)))) u256)
            (unwrap-panic (index-of BUFF_TO_BYTE (unwrap-panic (element-at vrf (+ byte-idx u1)))))
        )
    )
)

(define-public (pick-random-id)
    (let (
         (byte-idx (var-get b-idx))
         )
            (begin
                (set-vrf)
                (let (
                    (picked-idx (mod (rand byte-idx) (var-get remaining)))
                    (picked-id (default-to picked-idx (map-get? chosen-ids picked-idx)))
                    )
                    (var-set last-block block-height)
                    (var-set b-idx u2)
                    (print picked-id)
                    (var-set random picked-id)
                    (ok picked-id)
            )
        )
    )
)

(define-public (admin-set-last-id (id uint))
(begin
  (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
  (ok (var-set last-id id))
)
)

;; Transfers stx from contract to contract owner
(define-public (transfer-stx (address principal) (amount uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (as-contract (stx-transfer? amount (as-contract tx-sender) address))
    ERR-NOT-AUTHORIZED
  )
)

(define-public (set-reserve (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set reserve value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-active (value bool))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set active value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-mint-time (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set target-block value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-artist-address (value principal))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set artist-address-1 value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-artist-address-two (value principal))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set artist-address-2 value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-artist-address-three (value principal))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set artist-address-3 value))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; set wallet-1
(define-public (set-wallet-1 (new-wallet principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set wallet-1 new-wallet)
    (ok true)))

;; set wallet-2
(define-public (set-wallet-2 (new-wallet principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set wallet-2 new-wallet)
    (ok true)))

;; set wallet-3
(define-public (set-wallet-3 (new-wallet principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set wallet-3 new-wallet)
    (ok true)))

(define-public (set-wallet-4 (new-wallet principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set wallet-4 new-wallet)
    (ok true)))

;; set wallet-1
(define-public (set-royalty-1 (new-royalty uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set royalty-1 new-royalty)
    (ok true)))

;; set wallet-2
(define-public (set-royalty-2 (new-royalty uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set royalty-2 new-royalty)
    (ok true)))

;; set wallet-3
(define-public (set-royalty-3 (new-royalty uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set royalty-3 new-royalty)
    (ok true)))

;; set wallet-3
(define-public (set-royalty-4 (new-royalty uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set royalty-4 new-royalty)
    (ok true)))

(define-public (add-metadata (meta (string-ascii 53)) (id uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (map-set metadata id {
      uri: meta
      }))
    (err ERR-NOT-AUTHORIZED)
)
)

;; Gets the owner of the specified token ID.
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? project-indigo-landmarks token-id)))

;; Gets artist address
(define-read-only (get-artist-address)
  (ok (var-get artist-address-1)))

;; Gets artist address
(define-read-only (get-artist-address-two)
  (ok (var-get artist-address-2)))

;; Gets artist address
(define-read-only (get-artist-address-three)
  (ok (var-get artist-address-3)))

;; Gets end of auction
(define-read-only (get-auction-end)
  (ok (var-get target-block)))

;; Gets random id
(define-read-only (get-random-id)
  (ok (var-get random)))

;; Gets the owner of the specified token ID.
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (get uri (unwrap-panic (map-get? metadata token-id)))))
)