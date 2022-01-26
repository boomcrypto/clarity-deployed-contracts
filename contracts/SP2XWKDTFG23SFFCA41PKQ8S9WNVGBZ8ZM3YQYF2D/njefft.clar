
;; njefft
;; Jeff NFT collection

;; constants
(define-constant contract-owner tx-sender)

(define-constant err-owner-only (err u100))
(define-constant err-mint-limit (err u101))
(define-constant err-mint-disabled (err u102))
(define-constant err-invalid-input (err u103))
(define-constant err-not-found (err u104))
(define-constant err-listing (err u105))
(define-constant err-wrong-commission (err u106))

(impl-trait .njefft-trait.njefft-trait)

(define-trait commission-trait
    ((pay (uint uint) (response bool uint))))

;; data maps and vars
;;
;; limit number of tokens
(define-data-var mint-limit uint u6)
;; Store the last issues token ID
(define-data-var last-id uint u0)
;; price of new tokens
(define-data-var mint-price uint u1000000)
;; creator address
(define-data-var creator-address principal 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)
;; metadata ipfs root cid
(define-data-var ipfs-cid (string-ascii 80) "QmXbkRfwnC3yZ7zJQxicX6pu71vWErs2yx5eLmsfehV6bd")
;; minting paused
(define-data-var mint-enabled bool false)
;; listing map
(define-map market uint {price: uint, commission: principal})

;; private functions
;;
;; Internal - Mint new NFT
(define-private (mint (new-owner principal))
    (let
      (
        (next-id (+ u1 (var-get last-id)))
      )
      (asserts! (<= next-id (var-get mint-limit)) err-mint-limit)
      (asserts! (is-eq true (var-get mint-enabled)) err-mint-disabled)
      (if (is-eq tx-sender contract-owner)
        ;; contract owner no fee minting
        true
        (begin
          ;; transfer stx
          (try! (stx-transfer? (var-get mint-price) tx-sender (var-get creator-address)))
        )
      )
      (var-set last-id next-id)
      (nft-mint? njefft next-id new-owner)))

;; define a new NFT.
(define-non-fungible-token njefft uint)

;; public functions
;;
;; Claim a new NFT
(define-public (claim)
  (mint tx-sender))

;; SIP009: Transfer token to a specified principal
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
     (asserts! (is-eq tx-sender sender) err-owner-only)
     (asserts! (is-none (map-get? market token-id)) err-listing)
     ;; token-id and recipient are untrusted but nft-transfer will error out
     ;; #[allow(unchecked_data)]
     (nft-transfer? njefft token-id sender recipient)))

(define-public (transfer-memo (token-id uint) (sender principal) (recipient principal) (memo (buff 34)))
  (begin 
    (try! (transfer token-id sender recipient))
    (print memo)
    (ok true)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? njefft token-id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat "ipfs://ipfs/" (var-get ipfs-cid)) "/njefft-{id}-metadata.json"))))

(define-public (set-creator-address (address principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (< u0 (stx-get-balance address)) err-invalid-input) ;; how to validate a principal?
    (ok (var-set creator-address address))))

(define-public (set-mint-price (new-price uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (< u0 new-price) err-invalid-input) ;; uint cant be negative anyway
    (ok (var-set mint-price new-price))))

(define-public (toggle-enabled)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (var-set mint-enabled (not (var-get mint-enabled))))))

(define-public (set-mint-limit (limit uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> limit (var-get last-id)) err-mint-limit)
    (ok (var-set mint-limit limit))))

(define-public (set-ipfs-cid (cid (string-ascii 80)))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (<= u1 (len cid)) err-invalid-input)
    (ok (var-set ipfs-cid cid))))
  
(define-read-only (get-mint-enabled)
  (ok (var-get mint-enabled)))

(define-read-only (get-mint-price)
  (ok (var-get mint-price)))

(define-read-only (get-mint-limit)
  (ok (var-get mint-limit)))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (list-price uint) (comm <commission-trait>))
  (let (
      (listing  {price: list-price, commission: (contract-of comm)})
      (owner (unwrap! (nft-get-owner? njefft id) err-not-found))
    )
    (asserts! (is-eq tx-sender owner) err-owner-only)
    (map-set market id listing)
    (print (merge listing {action: "list-in-ustx", id: id}))
    (ok true)))

(define-public (unlist-in-ustx (id uint))
  (let (
      (owner (unwrap! (nft-get-owner? njefft id) err-not-found))
    )
    (asserts! (is-eq tx-sender owner) err-owner-only)
    (map-delete market id)
    (print {action: "unlist-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-ustx (id uint) (comm <commission-trait>))
  (let (
      (owner (unwrap! (nft-get-owner? njefft id) err-not-found))
      (listing (unwrap! (map-get? market id) err-listing))
      (list-price (get price listing))
    )
    (asserts! (is-eq (contract-of comm) (get commission listing)) err-wrong-commission)
    (try! (stx-transfer? list-price tx-sender owner))
    (if (is-eq (as-contract tx-sender) (contract-of comm))
      (try! (pay id list-price))
      (try! (contract-call? comm pay id list-price))
    )
    (try! (nft-transfer? njefft id owner tx-sender))
    (map-delete market id)
    (print {action: "buy-in-ustx", id: id})
    (ok true)))

(define-public (pay (id uint) (price uint))
  (begin
    (try! (stx-transfer? (/ price u50) tx-sender (var-get creator-address)))
    (ok true)))
