;; 90STX Mini Raffle 20
;; 90STX.XYZ PLATFORM

;; Traits
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Define NFT token
(define-non-fungible-token ticket-90stx-mini-raffle-20 uint)

;; Storage
(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})

;; Constants and Errors
(define-constant CONTRACT-OWNER tx-sender)
(define-constant WALLET 'SP2QM7P3NPYE21TEESBPPVGGA0CD2KYBBPCPFERTG)
(define-constant ERR-SOLD-OUT (err u100))
(define-constant ERR-WRONG-COMMISSION (err u101))
(define-constant ERR-NOT-AUTHORIZED (err u102))
(define-constant ERR-NOT-FOUND (err u103))
(define-constant ERR-LISTING (err u104))
(define-constant ERR-SALE-NOT-ACTIVE (err u105))
(define-constant REACHED-BLOCK-PICK-LIMIT (err u106))

;; Variables
(define-data-var cost uint u0)
(define-data-var last-id uint u0)
(define-data-var mint-limit uint u0)
(define-data-var sale-active bool false)
(define-data-var base-uri (string-ascii 80) "ipfs://CID/")

;; Get balance
(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

;; Transfer token to a specified principal
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? market id)) ERR-LISTING)
    (trnsfr id sender recipient)))

;; Get the owner of the specified token ID
(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? ticket-90stx-mini-raffle-20 id)))

;; Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

;; Get the token URI
(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get base-uri) "{id}") ".json"))))

;; Get the mint limit
(define-read-only (get-mint-limit)
  (ok (var-get mint-limit)))

;; Check public sales active
(define-read-only (sale-enabled)
  (ok (var-get sale-active)))

;; Get a price
(define-read-only (get-price-in-banana)
  (ok (var-get cost)))

;; Change the base uri (only contract owner)
(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set base-uri new-base-uri)
    (ok true)))

;; Set sale flag (only contract owner)
(define-public (flip-sale)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set sale-active (not (var-get sale-active)))
    (ok (var-get sale-active))))

;; Set price (only contract owner)
(define-public (set-price-in-banana (new-price uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set cost new-price)
    (ok true)))

;; Set mint limit (only contract owner)
(define-public (set-mint-limit (limit uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set mint-limit limit)
    (ok true)))

;; Claim ticket
(define-public (claim)
  (mint tx-sender))

;; Claim 3 tickets
(define-public (claim-three)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

;; Claim 5 tickets
(define-public (claim-five)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

;; Claim 10 tickets
(define-public (claim-ten)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

;; Mint new NFT
(define-private (mint (new-owner principal))
    (let ((next-id (+ u1 (var-get last-id))))
      (asserts! (var-get sale-active) ERR-SALE-NOT-ACTIVE)
      (asserts! (< (var-get last-id) (var-get mint-limit)) ERR-SOLD-OUT)
      (match (nft-mint? ticket-90stx-mini-raffle-20 next-id new-owner)
        success
        (let
        ((current-balance (get-balance new-owner)))
          (begin
            (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-bananas transfer (var-get cost) tx-sender WALLET none))
            (var-set last-id next-id)
            (map-set token-count
              new-owner
              (+ current-balance u1)
            )
            (ok true)))
        error (err (* error u10001)))))

;; Burn NFT
(define-public (burn (id uint))
  (let
    ((owner (unwrap! (nft-get-owner? ticket-90stx-mini-raffle-20 id) ERR-NOT-FOUND))
    (owner-balance (get-balance owner)))
    (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
    (begin
        (try! (nft-burn? ticket-90stx-mini-raffle-20 id owner))
        (map-set token-count
        owner
        (- owner-balance u1))
    (ok true))))

;; Non-custodial marketplace

(define-trait commission-trait
  ((pay (uint uint) (response bool uint))))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? ticket-90stx-mini-raffle-20 id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? ticket-90stx-mini-raffle-20 id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm)}))
    (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
    (map-set market id listing)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)))

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
    (map-delete market id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)))
	
(define-public (buy-in-ustx (id uint) (comm <commission-trait>))
  (let ((owner (unwrap! (nft-get-owner? ticket-90stx-mini-raffle-20 id) ERR-NOT-FOUND))
      (listing (unwrap! (map-get? market id) ERR-LISTING))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))

;; Pick winner in mini raffle

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

(define-data-var win-ticket uint u0)
(define-data-var limit-tickets uint u0)
(define-data-var last-block uint u0)
(define-data-var last-vrf (buff 64) 0x00)
(define-data-var b-idx uint u0)

(define-map chosen-ids uint uint)

(define-public (pick-win-raffle-ticket)
    (let ((byte-idx (var-get b-idx)))
            (begin
                (set-vrf)
                (asserts! (< byte-idx u62) REACHED-BLOCK-PICK-LIMIT)
                (let ((picked-idx (mod (rand byte-idx) (var-get limit-tickets)))
                    (picked-id (default-to picked-idx (map-get? chosen-ids picked-idx))))
                    (var-set last-block block-height)
                    (var-set b-idx (+ (var-get b-idx) u2))
                    (print picked-id)
                    (var-set win-ticket picked-id)
                    (ok picked-id)))))

(define-public (set-raffle-limit (limit uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set limit-tickets limit)
    (ok true)))

(define-private (set-vrf)
    (var-set last-vrf (sha512 (unwrap-panic (get-block-info? vrf-seed (- block-height u1))))))

(define-private (rand (byte-idx uint))
    (let ((vrf (var-get last-vrf)) )
        (+ 
            (* (unwrap-panic (index-of BUFF_TO_BYTE (unwrap-panic (element-at vrf byte-idx)))) u256)
            (unwrap-panic (index-of BUFF_TO_BYTE (unwrap-panic (element-at vrf (+ byte-idx u1)))))
        )))

(define-read-only (get-win-ticket-id)
  (ok (var-get win-ticket)))

(define-read-only (get-raffle-limit)
  (ok (var-get limit-tickets)))