;; use the SIP090 interface (testnet)
;;live (impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;test (impl-trait 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE.nft-trait.nft-trait)
(impl-trait .nft-trait.nft-trait)
(use-trait commission-trait .commission-trait.commission)

(define-non-fungible-token Shafts-of-Light-Townsfolk uint)

;; Storage
(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})

;; Define Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-SOLD-OUT (err u300))
(define-constant ERR-WRONG-COMMISSION (err u301))
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-METADATA-FROZEN (err u505))
(define-constant ERR-MINT-ALREADY-SET (err u506))
(define-constant ERR-LISTING (err u507))
(define-constant NFT-LIMIT u2000)

;; Withdraw wallets
;; Wallet 1 45%
(define-constant WALLET_1 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1)
;; Wallet 2 45%
(define-constant WALLET_2 'SP2D0885M8ZC9D2JPDJ3SV41W5SRFHF487ZNGGRX4)
;; Wallet 3 5%
(define-constant WALLET_3 'SP2MJC01HV090N8NKC4J5E1W9A19V7HE9VEKD2ZQT)
;; Wallet 4 5%
(define-constant WALLET_4 'SP3CSB5QPAMHFAQV5PPQCGFA9BETXN1BHTKT0N9KW)

;; Define Variables
(define-data-var last-id uint u0)
(define-data-var mintpass-sale-active bool false)
(define-data-var metadata-frozen bool false)
(define-data-var base-uri (string-ascii 80) "ipfs://QmQMMrqBet3tQ1EqjDgsYxk23rr8bpAhbguxkojQvvUevA/{id}.json")
(define-constant contract-uri "ipfs://QmRBDCMCsUtyLTuZ7VXjGM9mMESouQNVVuzraYfwyb7rkh")
(define-constant proof-hash "A84AA9CC6744AEA7838681BE5E8A6B9D80D0D5C47546868B4F5F18890F500115")
(define-map mint-address bool principal)

;; Token count for account
(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? Shafts-of-Light-Townsfolk id sender recipient)
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

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (id uint))
  ;; Make sure to replace Shafts-of-Light-Townsfolk
  (ok (nft-get-owner? Shafts-of-Light-Townsfolk id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (id uint))
  (ok (some (var-get base-uri))))

(define-read-only (get-contract-uri)
  (ok contract-uri))

;; Mint new NFT
;; can only be called from the Mint
(define-public (mint (new-owner principal))
    (let ((next-id (+ u1 (var-get last-id))))
      (asserts! (called-from-mint) ERR-NOT-AUTHORIZED)
      (asserts! (< (var-get last-id) NFT-LIMIT) ERR-SOLD-OUT)
      (match (nft-mint? Shafts-of-Light-Townsfolk next-id new-owner)
        success
        (let
        ((current-balance (get-balance new-owner)))
          (begin
            (try! (stx-transfer? u31500000 tx-sender WALLET_1))
            (try! (stx-transfer? u31500000 tx-sender WALLET_2))
            (try! (stx-transfer? u3500000 tx-sender WALLET_3))
            (try! (stx-transfer? u3500000 tx-sender WALLET_4))
            (var-set last-id next-id)
            (map-set token-count
              new-owner
              (+ current-balance u1)
            )
            (ok true)))
        error (err (* error u10000)))))

(define-private (is-sender-owner (id uint))
  (let ((owner (unwrap! (nft-get-owner? Shafts-of-Light-Townsfolk id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? Shafts-of-Light-Townsfolk id) ERR-NOT-FOUND))
      (listing (unwrap! (map-get? market id) ERR-LISTING))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))

;; Set base uri
(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (not (var-get metadata-frozen)) ERR-METADATA-FROZEN)
    (var-set base-uri new-base-uri)
    (ok true)))

;; Freeze metadata
(define-public (freeze-metadata)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set metadata-frozen true)
    (ok true)))

;; Manage the Mint
(define-private (called-from-mint)
  (let ((the-mint
          (unwrap! (map-get? mint-address true)
                    false)))
    (is-eq contract-caller the-mint)))

;; can only be called once
(define-public (set-mint-address)
  (let ((the-mint (map-get? mint-address true)))
    (asserts! (and (is-none the-mint)
              (map-insert mint-address true tx-sender))
                ERR-MINT-ALREADY-SET)
    (ok tx-sender)))