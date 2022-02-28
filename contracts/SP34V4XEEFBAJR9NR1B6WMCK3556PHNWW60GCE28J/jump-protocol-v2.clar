;; JUMP PROTOCOL by bought.btc
;; VERSION: 2.0 (mainnet)
;; DEPLOY DATE: February 25th, 2022

;; =============================================================================================================
;;      dMMMMMP dMP dMP dMMMMMMMMb  dMMMMb         dMMMMb  dMMMMb  .aMMMb dMMMMMMP .aMMMb  .aMMMb  .aMMMb  dMP 
;;         dMP dMP dMP dMP"dMP"dMP dMP.dMP        dMP.dMP dMP.dMP dMP"dMP   dMP   dMP"dMP dMP"VMP dMP"dMP dMP  
;;        dMP dMP dMP dMP dMP dMP dMMMMP"        dMMMMP" dMMMMK" dMP dMP   dMP   dMP dMP dMP     dMP dMP dMP   
;;   dK .dMP dMP.aMP dMP dMP dMP dMP            dMP     dMP"AMF dMP.aMP   dMP   dMP.aMP dMP.aMP dMP.aMP dMP    
;;   VMMMP"  VMMMP" dMP dMP dMP dMP            dMP     dMP dMP  VMMMP"   dMP    VMMMP"  VMMMP"  VMMMP" dMMMMMP  
;; =============================================================================================================
;;  The Jump Protocol enables the transfer of non-fungible tokens from any blockchain to the Stacks blockchain.                                                         

(define-non-fungible-token Jump-Protocol uint)

(define-data-var LAST-ID uint u0)
(define-data-var BRIDGE-COUNT uint u0)
(define-data-var CONTRACT-OWNER principal tx-sender)

(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-TRANSFER (err u101))
(define-constant ERR-UNLOCK (err u200))
(define-constant ERR-LOCK (err u201))
(define-constant ERR-NOT-FOUND (err u300))
(define-constant ERR-LISTING (err u301))

(define-map TOKEN-COUNT principal uint)
(define-map NON-CUSTODIAL-MARKET uint {price: uint})
(define-map BRIDGED-NFTS uint {uri: (string-ascii 1024)})
(define-map CONTRACT-WORKERS principal bool)

;; Lets the contract owner set a new contract owner
(define-public (set-contract-owner (address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get CONTRACT-OWNER)) ERR-NOT-AUTHORIZED)
    (var-set CONTRACT-OWNER address)
    (ok true)))

;; Lets the contract owner add or remove a contract worker
(define-public (set-contract-worker (address principal) (status bool))
  (begin
    (asserts! (is-eq tx-sender (var-get CONTRACT-OWNER)) ERR-NOT-AUTHORIZED)
    (map-set CONTRACT-WORKERS address status)
    (ok true)))

;; Lets a contract worker mint a NFT
(define-public (unlock-nft (uri (string-ascii 1024)) (address principal))
  (begin
    (asserts! (unwrap! (get-contract-worker tx-sender) ERR-NOT-AUTHORIZED) ERR-NOT-AUTHORIZED)
    (let
      ((id (+ u1 (var-get LAST-ID))))
      (match (nft-mint? Jump-Protocol id address)
        success
          (begin
            (map-insert BRIDGED-NFTS id {uri: uri})
            (map-set TOKEN-COUNT address (+ (get-balance address) u1))
            (var-set BRIDGE-COUNT (+ (var-get BRIDGE-COUNT) u1))
            (var-set LAST-ID (+ (var-get LAST-ID) u1))
            (print {action: "unlock-nft", id: id, address: address})
            (ok true))
        error ERR-UNLOCK))))

;; Lets NFT owner bridge a NFT back to its original chain
(define-public (lock-nft (id uint) (chain (string-ascii 1024)) (address (string-ascii 1024)))
  (begin
    (asserts! (is-owner id tx-sender) ERR-NOT-AUTHORIZED)
    (match (nft-burn? Jump-Protocol id tx-sender)
      success 
        (begin
          (map-delete BRIDGED-NFTS id)
          (map-set TOKEN-COUNT tx-sender (- (get-balance tx-sender) u1))
          (var-set BRIDGE-COUNT (- (var-get BRIDGE-COUNT) u1))
          (print {action: "lock-nft", id: id, chain: chain, address: address})
          (ok true))
      error ERR-LOCK)))

;; Lets NFT owner transfer a NFT they own
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? NON-CUSTODIAL-MARKET id)) ERR-LISTING)
    (trnsfr id sender recipient)))

;; Private function used to transfer a NFT
(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? Jump-Protocol id sender recipient)
    success
      (let
        ((sender-balance (get-balance sender))
        (recipient-balance (get-balance recipient)))
        (map-set TOKEN-COUNT sender (- sender-balance u1))
        (map-set TOKEN-COUNT recipient (+ recipient-balance u1))
        (ok success))
    error (err error)))

;; Lets NFT owner list a NFT on the non-custodial marketplace
(define-public (list-in-ustx (id uint) (price uint))
  (let
    ((listing  {price: price}))
    (asserts! (is-owner id tx-sender) ERR-NOT-AUTHORIZED)
    (map-set NON-CUSTODIAL-MARKET id listing)
    (print (merge listing {action: "list-in-ustx", id: id}))
    (ok true)))

;; Lets NFT owner unlist a NFT from the non-custodial marketplace
(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-owner id tx-sender) ERR-NOT-AUTHORIZED)
    (map-delete NON-CUSTODIAL-MARKET id)
    (print {action: "unlist-in-ustx", id: id})
    (ok true)))

;; Lets user purchase a NFT listed on the non-custodial marketplace
(define-public (buy-in-ustx (id uint))
  (let 
    ((owner (unwrap! (nft-get-owner? Jump-Protocol id) ERR-NOT-FOUND))
    (listing (unwrap! (map-get? NON-CUSTODIAL-MARKET id) ERR-LISTING))
    (price (get price listing)))
    (try! (stx-transfer? price tx-sender owner))
    (try! (trnsfr id owner tx-sender))
    (map-delete NON-CUSTODIAL-MARKET id)
    (print {action: "buy-in-ustx", id: id})
    (ok true)))

;; Checks if an address owns a specific NFT
(define-private (is-owner (id uint) (address principal))
  (is-eq address (unwrap! (nft-get-owner? Jump-Protocol id) false)))

;; Checks if an address is a contract worker
(define-read-only (get-contract-worker (address principal))
  (ok (default-to false (map-get? CONTRACT-WORKERS address))))

;; Returns the contract owner wallet
(define-read-only (get-contract-owner)
  (ok (var-get CONTRACT-OWNER)))

;; Returns the owner of a specific NFT
(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? Jump-Protocol id)))

;; Returns the price of a NFT listed on the non-custodial marketplace
(define-read-only (get-listing-in-ustx (id uint))
  (map-get? NON-CUSTODIAL-MARKET id))

;; Returns the total number of NFTs bridged
(define-read-only (get-bridge-count)
  (ok (var-get BRIDGE-COUNT)))

;; Returns the ID of the last NFT minted
(define-read-only (get-last-token-id)
  (ok (var-get LAST-ID)))

;; Returns the URI for a specific NFT
(define-read-only (get-token-uri (id uint))
  (ok (map-get? BRIDGED-NFTS id)))

;; Returns the number of NFTs an address owns
(define-read-only (get-balance (address principal))
  (default-to u0 (map-get? TOKEN-COUNT address)))