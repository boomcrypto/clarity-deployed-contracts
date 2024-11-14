;; bunnyOrd
;; contractType: continuous

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;(impl-trait .nft-trait.nft-trait)

(define-non-fungible-token bunnyOrd uint)

(define-constant DEPLOYER tx-sender)
(define-data-var BASE_URI (string-ascii 95) "https://ordinals.com/content/aa9eeecf49a5dd4a600540d15120d1436af0013dd5a2b7cee139a469d62f9deei0")
(define-constant ERR-NOT-AUTHORIZED u101)
(define-constant ERR-INVALID-USER u102)
(define-constant ERR-LISTING u103)
(define-constant ERR-WRONG-COMMISSION u104)
(define-constant ERR-NOT-FOUND u105)
(define-constant ERR-NFT-MINT u106)
(define-constant ERR-CONTRACT-LOCKED u107)
(define-constant ERR-METADATA-FROZEN u111)
(define-constant ERR-INVALID-PERCENTAGE u114)

(define-data-var last-id uint u0)
(define-data-var artist-address principal 'SP313FW47A0XR7HCBFQ0ZZHS47Q265AEBMPK1GD4N)
(define-data-var locked bool false)
(define-data-var metadata-frozen bool false)

(define-map cids uint (string-ascii 64))

(define-public (lock-contract)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set locked true)
    (ok true)))

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal, royalty: uint})

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? bunnyOrd id sender recipient)
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

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? bunnyOrd token-id) false)))

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? bunnyOrd token-id)))

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (var-get BASE_URI)))
)


(define-private (mint-many (uris (list 25 (string-ascii 64))))
  (let 
    (
      (token-id (+ (var-get last-id) u1))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter uris token-id))
      (current-balance (get-balance tx-sender))
    )
    (asserts! (or (is-eq tx-sender DEPLOYER) (is-eq tx-sender art-addr)) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (var-get locked) false) (err ERR-CONTRACT-LOCKED))
    (var-set last-id (- id-reached u1))
    (map-set token-count tx-sender (+ current-balance (- id-reached token-id)))    
    (ok id-reached)))

(define-private (mint-many-iter (hash (string-ascii 64)) (next-id uint))
  (begin
    (unwrap! (nft-mint? bunnyOrd next-id tx-sender) next-id)
    (map-set cids next-id hash)      
    (+ next-id u1)))


(try! (nft-mint? bunnyOrd u1 'SP313FW47A0XR7HCBFQ0ZZHS47Q265AEBMPK1GD4N))
(try! (nft-mint? bunnyOrd u2 'SP313FW47A0XR7HCBFQ0ZZHS47Q265AEBMPK1GD4N))
(try! (nft-mint? bunnyOrd u3 'SP313FW47A0XR7HCBFQ0ZZHS47Q265AEBMPK1GD4N))
(try! (nft-mint? bunnyOrd u4 'SP313FW47A0XR7HCBFQ0ZZHS47Q265AEBMPK1GD4N))
(try! (nft-mint? bunnyOrd u5 'SP313FW47A0XR7HCBFQ0ZZHS47Q265AEBMPK1GD4N))