;; jump-protocol (mainnet)
;; version id: 3.1 (production build)

(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

(define-non-fungible-token jump-protocol uint)

(define-data-var last-id uint u0)
(define-data-var bridge-count uint u0)
(define-data-var contract-owner principal tx-sender)

(define-constant err-not-authorized (err u101))
(define-constant err-transfer (err u102))
(define-constant err-unlock (err u103))
(define-constant err-lock (err u104))
(define-constant err-not-found (err u105))
(define-constant err-listing (err u106))
(define-constant err-wrong-commission (err u107))

(define-map token-count principal uint)
(define-map non-custodial-market uint {price: uint, commission: principal})
(define-map bridged-nfts uint {uri: (string-ascii 1024)})
(define-map contract-workers principal bool)

(define-public (set-contract-owner (address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) err-not-authorized)
    (var-set contract-owner address)
    (ok true)))

(define-public (set-contract-worker (address principal) (status bool))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) err-not-authorized)
    (map-set contract-workers address status)
    (ok true)))

(define-public (unlock-nft (uri (string-ascii 1024)) (address principal))
  (begin
    (asserts! (unwrap! (is-contract-worker tx-sender) err-not-authorized) err-not-authorized)
    (let
      ((id (+ u1 (var-get last-id))))
      (match (nft-mint? jump-protocol id address)
        success
          (begin
            (map-insert bridged-nfts id {uri: uri})
            (map-set token-count address (+ (get-balance address) u1))
            (var-set bridge-count (+ (var-get bridge-count) u1))
            (var-set last-id (+ (var-get last-id) u1))
            (print {action: "unlock-nft", id: id, address: address})
            (ok true))
        error err-unlock))))

(define-public (lock-nft (id uint) (chain (string-ascii 1024)) (address (string-ascii 1024)))
  (begin
    (asserts! (is-owner id tx-sender) err-not-authorized)
    (match (nft-burn? jump-protocol id tx-sender)
      success 
        (begin
          (map-delete bridged-nfts id)
          (map-set token-count tx-sender (- (get-balance tx-sender) u1))
          (var-set bridge-count (- (var-get bridge-count) u1))
          (print {action: "lock-nft", id: id, chain: chain, address: address})
          (ok true))
      error err-lock)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-authorized)
    (asserts! (is-none (map-get? non-custodial-market id)) err-listing)
    (trnsfr id sender recipient)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? jump-protocol id sender recipient)
    success
      (let
        ((sender-balance (get-balance sender))
        (recipient-balance (get-balance recipient)))
        (map-set token-count sender (- sender-balance u1))
        (map-set token-count recipient (+ recipient-balance u1))
        (ok success))
    error (err error)))

(define-public (list-in-ustx (id uint) (price uint) (comm <commission-trait>))
  (let
    ((listing  {price: price, commission: (contract-of comm)}))
    (asserts! (is-owner id tx-sender) err-not-authorized)
    (map-set non-custodial-market id listing)
    (print (merge listing {action: "list-in-ustx", id: id}))
    (ok true)))

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-owner id tx-sender) err-not-authorized)
    (map-delete non-custodial-market id)
    (print {action: "unlist-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-ustx (id uint) (comm <commission-trait>))
  (let 
    ((owner (unwrap! (nft-get-owner? jump-protocol id) err-not-found))
    (listing (unwrap! (map-get? non-custodial-market id) err-listing))
    (price (get price listing)))
    (asserts! (is-eq (contract-of comm) (get commission listing)) err-wrong-commission)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete non-custodial-market id)
    (print {action: "buy-in-ustx", id: id})
    (ok true)))

(define-private (is-owner (id uint) (address principal))
  (is-eq address (unwrap! (nft-get-owner? jump-protocol id) false)))

(define-read-only (is-contract-worker (address principal))
  (ok (default-to false (map-get? contract-workers address))))

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner)))

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? jump-protocol id)))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? non-custodial-market id))

(define-read-only (get-bridge-count)
  (ok (var-get bridge-count)))

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (id uint))
  (ok (get uri (map-get? bridged-nfts id))))

(define-read-only (get-balance (address principal))
  (default-to u0 (map-get? token-count address)))