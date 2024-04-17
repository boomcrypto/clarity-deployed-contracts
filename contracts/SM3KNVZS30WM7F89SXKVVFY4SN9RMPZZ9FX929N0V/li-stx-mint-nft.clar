;; li-stx-mint
;; contractType: public

;; __IF_MAINNET__
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;; (impl-trait .nft-trait.nft-trait)
;; __ENDIF__

(define-non-fungible-token li-stx-mint uint)

;; Constants
(define-constant err-not-authorized (err u8000))
(define-constant err-listing (err u8001))
(define-constant err-wrong-commission (err u8002))
(define-constant err-not-found (err u8003))
(define-constant err-metadata-frozen (err u8004))

(define-constant err-unauthorised (err u3000))

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lisa-dao) (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lisa-dao is-extension contract-caller)) err-unauthorised))
)

;; Internal variables
(define-data-var last-id uint u0)
(define-data-var ipfs-root (string-ascii 80) "")
(define-data-var metadata-frozen bool false)

(define-read-only (max (a uint) (b uint)) (if (> a b) a b))

(define-public (mint (id uint) (amount uint) (recipient principal))
    (let ((current-balance (get-balance recipient)))
        (try! (is-dao-or-extension))
        (var-set last-id (max id (var-get last-id)))
        (map-set token-count recipient (+ current-balance u1))
        (nft-mint? li-stx-mint id recipient)))

(define-public (burn (token-id uint))
  (let ((owner (unwrap! (nft-get-owner? li-stx-mint token-id) err-not-found))
      (current-balance (get-balance owner)))
    (try! (is-dao-or-extension))
    (asserts! (is-none (map-get? market token-id)) err-listing)
    (try! (nft-burn? li-stx-mint token-id owner))
    (map-set token-count owner (- current-balance u1))
    (ok true)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? li-stx-mint token-id) false)))

;; governance calls

(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (try! (is-dao-or-extension))
    (asserts! (not (var-get metadata-frozen)) err-metadata-frozen)
    (print { notification: "token-metadata-update", payload: { token-class: "nft", contract-id: (as-contract tx-sender) }})
    (var-set ipfs-root new-base-uri)
    (ok true)))

(define-public (freeze-metadata)
  (begin
    (try! (is-dao-or-extension))
    (var-set metadata-frozen true)
    (ok true)))

;; Non-custodial SIP-009 transfer function
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) err-not-authorized)
    (asserts! (is-none (map-get? market id)) err-listing)
    (trnsfr id sender recipient)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? li-stx-mint token-id)))

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))

;; Non-custodial marketplace extras
;; __IF_MAINNET__
(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)
;; (use-trait commission-trait .commission-trait.commission)
;; __ENDIF__


(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal, royalty: uint})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? li-stx-mint id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? li-stx-mint id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm-trait), royalty: u0}))
    (asserts! (is-sender-owner id) err-not-authorized)
    (map-set market id listing)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)))

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) err-not-authorized)
    (map-delete market id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-ustx (id uint) (comm-trait <commission-trait>))
  (let ((owner (unwrap! (nft-get-owner? li-stx-mint id) err-not-found))
      (listing (unwrap! (map-get? market id) err-listing))
      (price (get price listing))
      (royalty (get royalty listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) err-wrong-commission)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))

