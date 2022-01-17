(impl-trait .nft-trait.nft-trait)
(use-trait commission-trait .commission-trait.commission)

(define-non-fungible-token Megapont-Robot-Component uint)
(define-map groups uint uint)

;; Storage
(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})

;; Define Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-WRONG-COMMISSION (err u301))
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-METADATA-FROZEN (err u505))
(define-constant ERR-LISTING (err u507))
(define-constant ERR-INTERACTING (err u510))

;; Define Variables
(define-data-var last-id uint u0)
(define-data-var metadata-frozen bool false)
(define-data-var base-uri (string-ascii 80) "https://api.megapont.com/components/{id}")
(define-constant contract-uri "ipfs://QmaSFU43Zy9ApVu85P9Z2k8rmP4W1vUgCkefJatL8xLrD3")
;; Mint counters for both Ape components and bought components
(define-data-var claim-count uint u0)
(define-map approved-minters principal bool)

;; Token count for account
(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? Megapont-Robot-Component id sender recipient)
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
    (asserts! (called-by-operator id) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? market id)) ERR-LISTING)
    (trnsfr id sender recipient)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? Megapont-Robot-Component id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (id uint))
  (ok (some (var-get base-uri))))

(define-read-only (get-contract-uri)
  (ok contract-uri))

(define-public (mnt (new-owner principal))
    (let ((next-id (+ u1 (var-get last-id))))
      (asserts! (called-from-approved-minter contract-caller) ERR-NOT-AUTHORIZED)
      (match (nft-mint? Megapont-Robot-Component next-id new-owner)
        success
        (let
        ((current-balance (get-balance new-owner)))
          (begin
            (var-set last-id next-id)
            (map-set token-count
              new-owner
              (+ current-balance u1)
            )
            (ok true)))
        error (err (* error u10000)))))

(define-public (mint (new-owner principal))
  (mnt new-owner))

(define-private (called-by-operator (id uint))
  (let ((owner (unwrap! (nft-get-owner? Megapont-Robot-Component id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm)}))
    (asserts! (called-by-operator id) ERR-NOT-AUTHORIZED)
    (map-set market id listing)
    (print (merge listing {action: "list-in-ustx", id: id}))
    (ok true)))

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (called-by-operator id) ERR-NOT-AUTHORIZED)
    (map-delete market id)
    (print {action: "unlist-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-ustx (id uint) (comm <commission-trait>))
  (let ((owner (unwrap! (nft-get-owner? Megapont-Robot-Component id) ERR-NOT-FOUND))
      (listing (unwrap! (map-get? market id) ERR-LISTING))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {action: "buy-in-ustx", id: id})
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

(define-public (approve-minter)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-insert approved-minters contract-caller true)
    (ok true)))

(define-public (revoke-minter (minter principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-delete approved-minters minter)
    (ok true)))

(define-private (called-from-approved-minter (minter principal))
  (let ((the-mint
    (unwrap! (map-get? approved-minters minter) false)))
    (is-eq true the-mint)))

(let
  ((last-minted-id (unwrap! (contract-call? .megapont-robot-component-nft get-last-token-id) ERR-INTERACTING)))
  (var-set last-id last-minted-id))
