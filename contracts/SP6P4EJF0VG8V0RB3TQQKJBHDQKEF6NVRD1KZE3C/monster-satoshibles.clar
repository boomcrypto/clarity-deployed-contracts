;; monster-satoshibles::MonsterSatoshibles

(impl-trait .nft-trait.nft-trait)
(use-trait commission-trait .commission-trait.commission)
(use-trait nft-trait .nft-trait.nft-trait)
(use-trait ft-trait .ft-trait.ft-trait)

(define-non-fungible-token MonsterSatoshibles uint)

;; Storage
(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})

;; Define Constants
(define-constant PREMINT-ADDRESS .stacksbridge-monster-satoshibles)
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ONE-DAY u144)
(define-constant ERR-SOLD-OUT (err u300))
(define-constant ERR-WRONG-COMMISSION (err u301))
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-METADATA-FROZEN (err u505))
(define-constant ERR-LISTING (err u507))
(define-constant ERR-INVALID-ID (err u508))
(define-constant MONSTERS-LIMIT u6666)

;; Image Provenance Record - SHA256 File Checksum 
(define-constant provenance "ipfs://QmW7mGepfgB91x8CcxqSQdo3GjpWr5LnVuBSJCeeyANtae")

;; Define Variables
(define-data-var last-id uint u3305)
(define-data-var metadata-frozen bool false)
(define-data-var base-uri (string-ascii 80) "https://api.satoshibles.com/monsters/token/{id}")
(define-data-var contract-uri (string-ascii 80) "ipfs://QmU2kjvsDQj1uLAXekjfPxMpPArPRr9njeMNCQBsSf3A8N")
(define-data-var total-token-count uint u0)
(define-data-var mint-start-height uint u10000000)

;; Token count for account
(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (increment-total-supply)
  (var-set total-token-count (+ (var-get total-token-count) u1))
)
(define-read-only (get-total-token-count)
  (var-get total-token-count)
)

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? MonsterSatoshibles id sender recipient)
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
  (ok (nft-get-owner? MonsterSatoshibles id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (id uint))
  (ok (some (var-get base-uri))))

(define-read-only (get-contract-uri)
  (ok (var-get contract-uri)))

(define-public (mint-id (new-owner principal) (id uint))
  (begin 
    (asserts! (is-eq CONTRACT-OWNER tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (< (var-get last-id) MONSTERS-LIMIT) ERR-SOLD-OUT)
    (asserts! (<= block-height (+ (var-get mint-start-height) u10)) ERR-NOT-AUTHORIZED)
    (try! (nft-mint? MonsterSatoshibles id new-owner))
    (map-set token-count new-owner (+ (get-balance new-owner) u1))
    (increment-total-supply)
    (ok true)
  )
)

(define-public (mint-two-free (new-owner principal) (id uint) (nft-contract <nft-trait>))
  (let (
    (next-id (+ u1 (var-get last-id)))
    (next-next-id (+ u2 (var-get last-id)))

    ;; sent nft-contract is a diamond satoshibles && id has not been used yet && tx-sender owns this nft
    (wl-one-can-claim-diamond (and (and (not (contract-call? .monsters-wl-one-diamond wl-one-diamond-is-minted id)) (is-eq .satoshibles (contract-of nft-contract))) (is-eq (unwrap! (unwrap! (contract-call? nft-contract get-owner id) ERR-INVALID-ID) ERR-INVALID-ID) tx-sender)))

    ;; sent nft-contract is a prime monster && id has not been used yet && tx-sender owns this nft
    (wl-one-can-claim-prime (and (and (not (contract-call? .monsters-wl-one-prime wl-one-prime-is-minted id)) (is-eq (as-contract tx-sender) (contract-of nft-contract))) (is-eq (unwrap! (unwrap! (get-owner id) ERR-INVALID-ID) ERR-INVALID-ID) tx-sender)))
    
    ;; check mint-start-height
    (wl-one-interval (>= block-height (var-get mint-start-height)))
  )
    ;; whitelist checks
    (asserts! (and wl-one-interval (or wl-one-can-claim-diamond wl-one-can-claim-prime)) ERR-NOT-AUTHORIZED)
    (asserts! (< (var-get last-id) MONSTERS-LIMIT) ERR-SOLD-OUT)
    (match (nft-mint? MonsterSatoshibles next-id new-owner)
      success
      (let
      ((current-balance (get-balance new-owner)))
        (begin
          (var-set last-id next-id)
          (map-set token-count
            new-owner
            (+ current-balance u1)
          )
          (increment-total-supply)
          (try! (contract-call? .monsters-wl-one-diamond wl-one-set-minted id))
          (try! (contract-call? .monsters-wl-one-prime wl-one-set-minted id))
        )
      )
      error false)
    (match (nft-mint? MonsterSatoshibles next-next-id new-owner)
      success
      (let
      ((current-balance (get-balance new-owner)))
        (begin
          (var-set last-id next-next-id)
          (map-set token-count
            new-owner
            (+ current-balance u1)
          )
          (increment-total-supply)
          (try! (contract-call? .monsters-wl-one-diamond wl-one-set-minted id))
          (try! (contract-call? .monsters-wl-one-prime wl-one-set-minted id))
          (ok true)
        )
      )
      error (err (* error u10000))
    )
  )
)

(define-public (mint-one-free (new-owner principal) (id uint) (nft-contract <nft-trait>))
  (let (
    (next-id (+ u1 (var-get last-id)))

    ;; all other Satoshibles on Stacks
    (wl-two-can-claim-satoshibles (and (and (not (contract-call? .monsters-wl-two wl-two-satoshibles-is-minted id)) (is-eq .satoshibles (contract-of nft-contract))) (is-eq (unwrap! (unwrap! (contract-call? nft-contract get-owner id) ERR-INVALID-ID) ERR-INVALID-ID) tx-sender)))

    ;; all monsters (that have bridged)
    (wl-two-can-claim-monsters (and (and (not (contract-call? .monsters-wl-two wl-two-monsters-is-minted id)) (is-eq (as-contract tx-sender) (contract-of nft-contract))) (is-eq (unwrap! (unwrap! (get-owner id) ERR-INVALID-ID) ERR-INVALID-ID) tx-sender)))

    ;; after 1st 24 hours
    (wl-two-interval (> block-height (+ (var-get mint-start-height) ONE-DAY)))
  )
    ;; whitelist check
    (asserts! (and wl-two-interval (or wl-two-can-claim-satoshibles wl-two-can-claim-monsters)) ERR-NOT-AUTHORIZED)
    
    (asserts! (< (var-get last-id) MONSTERS-LIMIT) ERR-SOLD-OUT)
    (match (nft-mint? MonsterSatoshibles next-id new-owner)
      success
      (let
      ((current-balance (get-balance new-owner)))
        (begin
          (var-set last-id next-id)
          (map-set token-count
            new-owner
            (+ current-balance u1)
          )
          (increment-total-supply)
          (if (is-eq .satoshibles (contract-of nft-contract))
            (try! (contract-call? .monsters-wl-two wl-two-satoshibles-set-minted id))
            (try! (contract-call? .monsters-wl-two wl-two-monsters-set-minted id))
          )
          (ok true)
        )
      )
      error (err (* error u10000))
    )
  )
)

;; marketplace
(define-private (is-sender-owner (id uint))
  (let ((owner (unwrap! (nft-get-owner? MonsterSatoshibles id) false)))
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
    (print {action: "unlist-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-ustx (id uint) (comm <commission-trait>))
  (let ((owner (unwrap! (nft-get-owner? MonsterSatoshibles id) ERR-NOT-FOUND))
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

(define-public (set-contract-uri (new-contract-uri (string-ascii 80)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (not (var-get metadata-frozen)) ERR-METADATA-FROZEN)
    (var-set contract-uri new-contract-uri)
    (ok true)))

;; Freeze metadata
(define-public (freeze-metadata)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set metadata-frozen true)
    (ok true)))

;; premint many with id
(define-public (premint-many (id (list 1000 uint)))
  (fold check-err
    (map premint id)
    (ok true)
  )
)
(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior 
    ok-value result
    err-value (err err-value)
  )
)
(define-private (premint (id uint))
  (mint-id PREMINT-ADDRESS id)
)

(define-read-only (stx-balance)
  (stx-get-balance (as-contract tx-sender))
)

;; safety functions
(define-public (transfer-stx (address principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (unwrap-panic (as-contract (stx-transfer? amount (as-contract tx-sender) address)))
    (ok true))
)

(define-public (transfer-ft-token (address principal) (amount uint) (token <ft-trait>))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (try! (as-contract (contract-call? token transfer amount tx-sender address none)))
    (ok true))
)

(define-public (transfer-nft-token (address principal) (id uint) (token <nft-trait>))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (try! (as-contract (contract-call? token transfer id tx-sender address)))
    (ok true))
)

(define-read-only (get-mint-start-height)
  (ok (var-get mint-start-height))
)

(define-public (set-mint-start-height (height uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (not (var-get metadata-frozen)) ERR-METADATA-FROZEN)
    (var-set mint-start-height height)
    (ok true)
  )
)