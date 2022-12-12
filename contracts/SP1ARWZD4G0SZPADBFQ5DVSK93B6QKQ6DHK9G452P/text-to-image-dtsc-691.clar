(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)


(define-non-fungible-token nft-text-to-image-691 uint)

;; Define constants 
(define-constant ERR-NO-MORE-NFTS u100)
(define-constant ERR-NOT-AUTHORIZED u104)
(define-constant ERR-WRONG-COMMISSION u107)
(define-constant ERR-NOT-FOUND u108)


(define-constant ERR-LISTING u106)
(define-constant ERR-ONE-PER-WALLET u1)

(define-map prompt-data principal { token-id: uint, url: (string-ascii 456) })

;; Define Variables
(define-data-var base-uri (string-ascii 200) "https://arweave.net/{id}")


(define-data-var last-cards-id uint u0)
(define-data-var deployer principal tx-sender)
;; (define-data-var pack-mint-price uint u6000000)
(define-data-var mint-limit uint u100)
(define-data-var nft-price uint u50000000)

(define-map token-count principal uint)

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

;; SIP009: Transfer token to a specified principal
;; #[allow(unchecked_data)]
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))
;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? nft-text-to-image-691 id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-cards-id)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (id uint))
  (ok (some (var-get base-uri))))

;; Default Minting
;; #[allow(unchecked_data)]
(define-public (mint (recipient principal) (image-url (string-ascii 456)))
    (let
        (
            (token-id (+ (var-get last-cards-id) u1))
            (current-balance (get-balance tx-sender))
        )
        (asserts! (is-none (map-get? prompt-data recipient)) (err ERR-ONE-PER-WALLET))
        (try! (nft-mint? nft-text-to-image-691 token-id recipient))
        (var-set last-cards-id token-id)
        (map-insert prompt-data recipient {token-id: token-id, url: image-url})
        (map-set token-count recipient (+ current-balance u1))
        (ok token-id)
    )
)

(define-read-only (check-map (token-holder principal)) 
(ok (map-get? prompt-data token-holder))
)


;; Non-custodial marketplace extras

(define-map market uint {price: uint, commission: principal})

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? nft-text-to-image-691 id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? nft-text-to-image-691 id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm-trait)}))
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

(define-public (buy-in-ustx (id uint) (comm-trait <commission-trait>))
  (let ((owner (unwrap! (nft-get-owner? nft-text-to-image-691 id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))

;; #[allow(unchecked_data)]
(define-public (change-uri (set-image-uri (string-ascii 200))) 
(begin 
  (asserts! (is-eq tx-sender (var-get deployer)) (err ERR-NOT-AUTHORIZED))
  (var-set base-uri set-image-uri)
  (ok true)
)
)