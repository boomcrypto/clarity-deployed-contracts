;; Marbling nft 
;; by KCV DAO 2022

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait) 
(use-trait commission-trait .commission-trait.commission) ;; commission
(use-trait sip010-token .sip010-ft-trait.sip010-ft-trait) ;; sip-010

(define-non-fungible-token Marbling uint)

(define-constant NYC-COIN-CONTRACT 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2)  ;; NYC-v2
(define-constant MIA-COIN-CONTRACT 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-core-v2)        ;; MIA-v2
;; (define-constant NYC-COIN-CONTRACT 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token)
;; (define-constant MIA-COIN-CONTRACT 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token)
(define-constant BAN-COIN-CONTRACT 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-bananas)

;; Constants 
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-SOLD-OUT (err u300))
(define-constant ERR-WRONG-COMMISSION (err u301))
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-FORBIDDEN (err u403))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-TOO-MANY-ATTEMPTS (err u429))
(define-constant ERR-LISTING (err u507))
(define-constant ERR-INVALID-TOKEN (err u100))
(define-constant ERR-CITY-MINT-INVALID (err u101))
(define-constant MINT-LIMIT u2500)   

;; Maps
(define-map token-count principal uint)
(define-map token-id-list principal (list 512 uint))    ;; a single wallet can own up to 512 nfts
(define-map market uint {price: uint, commission: principal})
(define-map token-mint-price principal uint)

;; Initialize Stuff & Store the last issues token ID 
(define-data-var is-public-mint bool false)
(define-data-var is-minting-ready bool false)
(define-data-var last-id uint u0)
(define-data-var mint-remainings uint u25)  
(define-data-var mint-price-wl  uint u65000000)  ;; 65 STX
(define-data-var mint-price-pub uint u75000000)  ;; 75 STX
(define-data-var WALLET-1 principal 'SP3K4WR0ZR787R6AAB5HCD595Y8BXSH65CNQW2VP2) 
(define-data-var base-uri (string-ascii 80) "ipfs://QmPsuVwA3ThzjayT5RiPBMRMCV4eFXx4ipPAMqYJJPGg14/")
(define-data-var mint-principal principal tx-sender)
(define-data-var token-compare uint u0)
(define-data-var b-idx uint u0)
(define-data-var is-citymint-active bool true)

;; Random Number Generation For Mint
(define-map minted-ids uint uint)
(define-data-var last-block uint block-height)
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

;; Constant for conversion purpose
(define-constant LIST_40 (list
  true true true true true true true true true true true true true true true true true true true true
  true true true true true true true true true true true true true true true true true true true true
))

;; Read-only functions
(define-read-only (get-token-mint-price (send-token <sip010-token>))
  (default-to u0 (map-get? token-mint-price (contract-of send-token))))

(define-read-only (get-token-balance (account principal))
  (default-to u0 (map-get? token-count account)))

(define-read-only (get-token-id-list (account principal))  
  (default-to (list ) (map-get? token-id-list account)))

(define-read-only (get-owner (token-id uint)) ;; SIP-009 
  (ok (nft-get-owner? Marbling token-id)))

(define-read-only (get-last-token-id) ;; SIP-009 
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint)) ;; SIP-009 
  (ok (some (concat (var-get base-uri) (uint-to-string token-id)))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-read-only (get-mint-ready)
  (ok (var-get is-minting-ready)))

(define-read-only (get-pubsale)
  (ok (var-get is-public-mint)))

(define-read-only (get-citymint-active)
  (ok (var-get is-citymint-active)))

;; Public functions
(define-public (set-citymint-active (new-flag bool))
  (begin
    (asserts! (is-authorized) ERR-NOT-AUTHORIZED)    
    (ok (var-set is-citymint-active new-flag))))

(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (is-authorized) ERR-NOT-AUTHORIZED)    
    (var-set base-uri new-base-uri)
    (ok true)))

(define-public (set-mint-price (new-price-wl uint) (new-price-pub uint))
  (begin
    (asserts! (is-authorized) ERR-NOT-AUTHORIZED)    
    (var-set mint-price-wl new-price-wl)
    (var-set mint-price-pub new-price-pub)
    (ok true)))

(define-public (set-wallets (new-wallet-1 principal))
  (begin
    (asserts! (is-authorized) ERR-NOT-AUTHORIZED)    
    (var-set WALLET-1 new-wallet-1)
    (ok true)))

(define-public (init-mint (NYC uint) (MIA uint) (BAN uint))  
    (begin               
        (asserts! (or (is-eq (var-get mint-principal) CONTRACT-OWNER) (is-eq tx-sender CONTRACT-OWNER)) ERR-NOT-AUTHORIZED)
        (var-set mint-principal tx-sender)
        (var-set is-minting-ready true)        
        (set-token-mint-price NYC MIA BAN)
        (ok tx-sender)))

(define-public (set-pubsale (flag bool))
    (begin    
        (asserts! (called-from-mint) ERR-NOT-AUTHORIZED)
        (var-set is-public-mint flag)
        (ok true)))

(define-public (change-token-mint-prices (NYC uint) (MIA uint) (BAN uint))
  (begin    
    (asserts! (is-authorized) ERR-NOT-AUTHORIZED)   
    (set-token-mint-price NYC MIA BAN)
    (ok true)))

;; Internal - Mint new NFT
(define-public (mint-with-stx (target-wallet principal))
    (begin
        (asserts! (var-get is-minting-ready) ERR-FORBIDDEN)
        (asserts! (called-from-mint) ERR-NOT-AUTHORIZED)
        (asserts! (< (var-get last-id) MINT-LIMIT) ERR-SOLD-OUT)   
        (let ((next-id (+ u1 (var-get last-id)))
            (target-mint-id (unwrap-panic (cycle-random-id (var-get mint-remainings)))))              
            (match (nft-mint? Marbling target-mint-id target-wallet)
                success
                    (let ((mint-price (if (var-get is-public-mint) (var-get mint-price-pub) (var-get mint-price-wl)))                
                    (new-total-balance (get-token-balance target-wallet))
                    (new-token-id-list (get-token-id-list target-wallet)))
                    (begin
                        (try! (stx-transfer? mint-price target-wallet (var-get WALLET-1)))                                        
                        (var-set last-id next-id)
                        (map-set token-count target-wallet (+ new-total-balance u1))
                        (map-set token-id-list target-wallet (default-to (list ) (as-max-len? (append new-token-id-list target-mint-id) u512)))                                        
                        (ok true)))
                error (err error)))))

(define-public (mint-with-token (target-wallet principal) (send-token <sip010-token>))
    (begin
        (asserts! (var-get is-minting-ready) ERR-FORBIDDEN)
        (asserts! (called-from-mint) ERR-NOT-AUTHORIZED)
        (asserts! (< (var-get last-id) MINT-LIMIT) ERR-SOLD-OUT)
        (asserts! 
          (or (is-eq (contract-of send-token) MIA-COIN-CONTRACT)
              (is-eq (contract-of send-token) NYC-COIN-CONTRACT)
              (is-eq (contract-of send-token) BAN-COIN-CONTRACT)) ERR-INVALID-TOKEN)
        (asserts!           
          (not (and (is-eq (var-get is-citymint-active) false)
                    (or (is-eq (contract-of send-token) MIA-COIN-CONTRACT) 
                        (is-eq (contract-of send-token) NYC-COIN-CONTRACT)))) ERR-CITY-MINT-INVALID) 
        (let ((next-id (+ u1 (var-get last-id)))
            (target-mint-id (unwrap-panic (cycle-random-id (var-get mint-remainings)))))              
            (match (nft-mint? Marbling target-mint-id target-wallet)
                success
                    (let ((mint-price (default-to u1000000000 (map-get? token-mint-price (contract-of send-token))))
                    (new-total-balance (get-token-balance target-wallet))
                    (new-token-id-list (get-token-id-list target-wallet)))
                    (begin                        
                        (try! (contract-call? send-token transfer mint-price target-wallet (var-get WALLET-1) none))
                        (var-set last-id next-id)
                        (map-set token-count target-wallet (+ new-total-balance u1))
                        (map-set token-id-list target-wallet (default-to (list ) (as-max-len? (append new-token-id-list target-mint-id) u512)))                                        
                        (ok true)))
                error (err error)))))

(define-public (mint-for-supporter (target-wallet principal))
    (begin 
        (asserts! (var-get is-minting-ready) ERR-FORBIDDEN)
        (asserts! (called-from-mint) ERR-NOT-AUTHORIZED)
        (asserts! (< (var-get last-id) MINT-LIMIT) ERR-SOLD-OUT)        
        (let ((next-id (+ u1 (var-get last-id)))
            (target-mint-id (unwrap-panic (cycle-random-id (var-get mint-remainings)))))
            (match (nft-mint? Marbling target-mint-id target-wallet)
                success 
                    (let ((mint-price (if (var-get is-public-mint) (var-get mint-price-pub) (var-get mint-price-wl)))                
                    (new-total-balance (get-token-balance target-wallet))
                    (new-token-id-list (get-token-id-list target-wallet)))
                    (begin
                        (var-set last-id next-id)
                        (map-set token-count target-wallet (+ new-total-balance u1))
                        (map-set token-id-list target-wallet (default-to (list ) (as-max-len? (append new-token-id-list target-mint-id) u512)))                    
                        (ok true)))
                error (err error)))))

(define-public (transfer (id uint) (sender principal) (recipient principal))  
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)    
    (transferNFT id sender recipient)))

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
  (let ((owner (unwrap! (nft-get-owner? Marbling id) ERR-NOT-FOUND))
      (listing (unwrap! (map-get? market id) ERR-LISTING))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm pay id price))
    (try! (transferNFT id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))

;; Util funcs
(define-read-only (uint-to-string (value uint))
  (get return (fold uint-to-string-clojure LIST_40 {value: value, return: ""})))

(define-private (transferNFT (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? Marbling id sender recipient)
        success
          (let
            ((sender-balance (get-token-balance sender))
             (recipient-balance (get-token-balance recipient)))
            (map-set token-count sender (- sender-balance u1))
            (map-set token-count recipient (+ recipient-balance u1))
            (remove-token-from-list id sender)            
            (map-set token-id-list recipient (default-to (list ) (as-max-len? (append (get-token-id-list recipient) id) u512)))            
            (ok success))
        error 
            (err error)))

(define-private (set-token-mint-price (NYC uint) (MIA uint) (BAN uint))
  (begin    
    (map-set token-mint-price NYC-COIN-CONTRACT NYC)    
    (map-set token-mint-price MIA-COIN-CONTRACT MIA)
    (map-set token-mint-price BAN-COIN-CONTRACT BAN)
    ))

(define-private (remove-token-from-list (target-token uint) (target-wallet principal))    
    (begin
        (var-set token-compare target-token)   
        (map-set token-id-list target-wallet (filter remove-token (get-token-id-list target-wallet)))))   

(define-private (remove-token (target-token-list uint)) 
    (if (is-eq (var-get token-compare) target-token-list) false true))    

(define-private (uint-to-string-clojure (i bool) (data {value: uint, return: (string-ascii 40)}))
  (if (> (get value data) u0)
    {
      value: (/ (get value data) u10),
      return: (unwrap-panic (as-max-len? (concat (unwrap-panic (element-at "0123456789" (mod (get value data) u10))) (get return data)) u40))
    }
    data ))

(define-private (is-authorized)
    (or (is-eq tx-sender CONTRACT-OWNER) (is-eq tx-sender (var-get mint-principal))))

(define-private (is-sender-owner (id uint))
  (let ((owner (unwrap! (nft-get-owner? Marbling id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-private (called-from-mint)
    (is-eq contract-caller (var-get mint-principal)))

;; Random Number Generation For Mint 
(define-private (set-vrf)
    (let ((seed (unwrap-panic (get-block-info? vrf-seed (- block-height u1)))))
         (var-set last-vrf (sha512 seed))))

(define-private (rand (byte-idx uint))
    (let ((vrf (var-get last-vrf)))
         (+ (* (unwrap-panic (index-of BUFF_TO_BYTE (unwrap-panic (element-at vrf byte-idx)))) u256)
            (unwrap-panic (index-of BUFF_TO_BYTE (unwrap-panic (element-at vrf (+ byte-idx u1))))))))

(define-private (swap-container (id uint) (idx uint) (ids-remaining uint))
    (let ((top (- ids-remaining u1))
          (top-id (default-to top (map-get? minted-ids top))))
         (map-set minted-ids top id)
         (map-set minted-ids idx top-id)
         (var-set mint-remainings top)))

(define-private (cycle-random-id (remaining-ids uint))
    (let ((byte-idx (var-get b-idx)))
         (if (is-eq (var-get last-block) block-height)
             (begin
                (asserts! (< byte-idx u102) ERR-TOO-MANY-ATTEMPTS) ;; 50 Max Mint per Block 
                (let ((picked-idx (mod (rand byte-idx) remaining-ids))
                      (picked-id (default-to picked-idx (map-get? minted-ids picked-idx))))                   
                     (swap-container picked-id picked-idx remaining-ids)
                     (var-set b-idx (+ byte-idx u2))
                     (let ((mint-id (+ picked-id u1)))
                          (ok mint-id))))
             (begin
                (set-vrf)
                (let ((picked-idx (mod (rand byte-idx) remaining-ids))
                      (picked-id (default-to picked-idx (map-get? minted-ids picked-idx))))
                     (var-set last-block block-height)
                     (swap-container picked-id picked-idx remaining-ids)
                     (var-set b-idx u2) 
                     (let ((mint-id (+ picked-id u1)))
                          (ok mint-id)))))))
