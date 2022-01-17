(impl-trait .nft-trait.nft-trait)
(use-trait commission-trait .commission-trait.commission)

(define-non-fungible-token Megapont-Robot uint)

;; Storage
(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})
(define-map robot-names uint (string-ascii 80))
(define-map robot-sequence uint {mouth: uint, jewellery: uint, head: uint, eyes: uint, ears: uint, body: uint, background: uint})

;; Define Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-SOLD-OUT (err u300))
(define-constant ERR-WRONG-COMMISSION (err u301))
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-METADATA-FROZEN (err u505))
(define-constant ERR-MINT-ALREADY-SET (err u506))
(define-constant ERR-LISTING (err u507))
(define-constant ROBOT-LIMIT u2500)

;; Define Variables
(define-data-var last-id uint u0)
(define-data-var metadata-frozen bool false)
(define-data-var base-uri (string-ascii 80) "https://api.megapont.com/robots/{id}")
(define-constant contract-uri "ipfs://QmaSFU43Zy9ApVu85P9Z2k8rmP4W1vUgCkefJatL8xLrD3")
(define-map mint-address bool principal)

;; Token count for account
(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

;; Gets the component sequence for the token
(define-read-only (get-sequence (id uint))
  (default-to {mouth: u0, jewellery: u0, head: u0, eyes: u0, ears: u0, body: u0, background: u0}
    (map-get? robot-sequence id)))

;; Gets the Robot name
(define-read-only (get-name (id uint))
  (default-to ""
    (map-get? robot-names id)))

;; Updates the robot-sequence mapping
(define-private (update-robot-sequence
    (id uint) (mouth uint) (jewellery uint) (head uint) (eyes uint) (ears uint)
    (body uint) (background uint))
  (map-set robot-sequence id {
      mouth: mouth,
      jewellery: jewellery,
      head: head,
      eyes: eyes,
      ears: ears,
      body: body,
      background: background
      }))

;; upgrade-robot-sequence
(define-public (upgrade (id uint) (mouth uint) (jewellery uint) (head uint) (eyes uint) (ears uint) (body uint) (background uint) (name (string-ascii 80)))
(let ((sequence-mapping (get-sequence id)))
(begin
    (asserts! (called-by-operator id) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? market id)) ERR-LISTING)
    (try! (contract-call? .megapont-robot-component-nft valid-sequence mouth jewellery head eyes ears body background))
    (and (not (is-eq (get mouth sequence-mapping) mouth)) (> mouth u0) (try! (contract-call? .megapont-robot-component-nft burn mouth tx-sender)))
    (and (not (is-eq (get jewellery sequence-mapping) jewellery)) (> jewellery u0) (try! (contract-call? .megapont-robot-component-nft burn jewellery tx-sender)))
    (and (not (is-eq (get head sequence-mapping) head)) (> head u0) (try! (contract-call? .megapont-robot-component-nft burn head tx-sender)))
    (and (not (is-eq (get eyes sequence-mapping) eyes)) (> eyes u0) (try! (contract-call? .megapont-robot-component-nft burn eyes tx-sender)))
    (and (not (is-eq (get ears sequence-mapping) ears)) (> ears u0) (try! (contract-call? .megapont-robot-component-nft burn ears tx-sender)))
    (and (not (is-eq (get body sequence-mapping) body)) (> body u0) (try! (contract-call? .megapont-robot-component-nft burn body tx-sender)))
    (and (not (is-eq (get background sequence-mapping) background)) (> background u0) (try! (contract-call? .megapont-robot-component-nft burn background tx-sender)))
    (update-robot-sequence id mouth jewellery head eyes ears body background)
    (and (not (is-eq (get-name id) name)) (map-set robot-names id name))
    (ok true))))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? Megapont-Robot id sender recipient)
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
  (ok (nft-get-owner? Megapont-Robot id)))

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
      (asserts! (< (var-get last-id) ROBOT-LIMIT) ERR-SOLD-OUT)
      (match (nft-mint? Megapont-Robot next-id new-owner)
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

(define-private (called-by-operator (id uint))
  (let ((owner (unwrap! (nft-get-owner? Megapont-Robot id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? Megapont-Robot id) ERR-NOT-FOUND))
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

;; Used to rename robots that might have otherwise offensive names
;; Not particulary web3, but required to avoid abuse
(define-public (override-name (id uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set robot-names id "MALFUNCTION")
    (ok true)))

;; Used to override the robot sequence this is may never be required
;; but in the event something goes wrong we want to be able to fix
;; the sequence.
(define-public (override-sequence (id uint) (mouth uint) (jewellery uint) (head uint) (eyes uint) (ears uint) (body uint) (background uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (update-robot-sequence id mouth jewellery head eyes ears body background)
    (ok true)))

;; set the robot contract as the burner for components
(as-contract (contract-call? .megapont-robot-component-nft set-burner-address))
