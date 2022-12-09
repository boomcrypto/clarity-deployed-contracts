;; testnet
;;(use-trait nft-trait .nft-trait.nft-trait)
;; mainnet
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token blockify uint)

(define-constant DEPLOYER tx-sender)

(define-constant ERR-NOT-AUTHORIZED u101)
(define-constant ERR-INVALID-USER u102)
(define-constant ERR-LISTING u103)
(define-constant ERR-WRONG-COMMISSION u104)
(define-constant ERR-NOT-FOUND u105)
(define-constant ERR-NFT-MINT u106)
(define-constant ERR-CONTRACT-LOCKED u107)
(define-constant ERR-NOT-OWNER u108)
(define-constant ERR-CONTRACT-NOT-VERIFIED u109)

(define-data-var last-id uint u0)
;; (define-data-var artist-address principal 'STNHKEPYEPJ8ET55ZZ0M5A34J0R3N5FM2CMMMAZ6)
(define-data-var artist-address principal 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8)
;;(define-data-var artist-address principal 'ST2MGXXTN1V4E1N07X2MRZ6CTNFV5ZV9VGNGB9SMQ)
(define-data-var locked bool false)
(define-data-var total-price uint u25000000)

(define-map ipfs-cids uint (string-ascii 64))
(define-map metadata-params uint (string-ascii 300))
(define-map verified-contracts { gate-contract: principal } {verified: bool, price: uint})

(define-public (lock-contract)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set locked true)
    (ok true)))

(define-public (set-artist-address (address principal))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set artist-address address))))

(define-public (burn (token-id uint))
  (begin 
    (asserts! (is-owner token-id tx-sender) (err ERR-NOT-AUTHORIZED))
    (nft-burn? blockify token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? blockify token-id) false)))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-INVALID-USER))
    (nft-transfer? blockify token-id sender recipient)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? blockify token-id)))

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat "ipfs://ipfs/" (unwrap-panic (map-get? ipfs-cids token-id))))))

(define-read-only (get-price (gate-contract <nft-trait>))
  (let
    (
      (verified-contract (unwrap! (map-get? verified-contracts {gate-contract: (contract-of gate-contract)}) (err ERR-CONTRACT-NOT-VERIFIED)))
    )
    (ok (get price verified-contract))))

(define-read-only (get-params (token-id uint))
  (ok (map-get? metadata-params token-id)))

(define-public (add-contract (gate-contract <nft-trait>) (price uint))
  (begin 
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED)) 
    (ok (map-set verified-contracts {gate-contract: (contract-of gate-contract)} {verified: true, price: price}))))

(define-public (remove-contract (gate-contract <nft-trait>))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
    (ok (map-delete verified-contracts {gate-contract: (contract-of gate-contract)}))))

(define-public (mint (hash (string-ascii 64)) (params (string-ascii 300)) (nft-contract <nft-trait>) (nft-token-id uint) (gate-contract <nft-trait>) (gate-token-id uint))
  (let 
    (
      (token-id (+ (var-get last-id) u1))
      (nft-owner (unwrap! (try! (as-contract (contract-call? nft-contract get-owner nft-token-id))) (err ERR-NOT-OWNER)))
      (gate-owner (unwrap! (try! (as-contract (contract-call? gate-contract get-owner gate-token-id))) (err ERR-NOT-OWNER)))
      (contract (contract-of gate-contract))
      (verified-contract (unwrap! (map-get? verified-contracts {gate-contract: (contract-of gate-contract)}) (err ERR-CONTRACT-NOT-VERIFIED)))
      (price (get price verified-contract))
    )
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (var-get locked) false) (err ERR-CONTRACT-LOCKED))
    (asserts! (is-eq tx-sender nft-owner) (err ERR-NOT-OWNER))
    (asserts! (is-eq tx-sender gate-owner) (err ERR-NOT-OWNER))
    (asserts! (is-eq true (get verified verified-contract)) (err ERR-CONTRACT-NOT-VERIFIED))
    (unwrap! (nft-mint? blockify token-id tx-sender) (err ERR-NFT-MINT))
    (try! (stx-transfer? price tx-sender (var-get artist-address)))
    (map-set ipfs-cids token-id hash)
    (var-set last-id token-id)
    (ok token-id)))