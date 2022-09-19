(impl-trait .nft-trait.nft-trait)
(use-trait commission-trait .commission-trait.commission)

(define-non-fungible-token Megapont-Bomber uint)

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-LISTING (err u507))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-WRONG-COMMISSION (err u301))
(define-constant JACKET-LIMIT u300)
(define-constant WALLET_1 'SP2J9XB6CNJX9C36D5SY4J85SA0P1MQX7R5VFKZZX)

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})
;; 1 = XS
;; 2 = S
;; 3 = M
;; 4 = L
;; 5 = XL
;; 6 = XXL
;; 7 = XXXL
(define-map metadata-uri uint (string-ascii 256))
(define-map token-sizes uint uint)
(define-map redeemed uint bool)

(define-data-var last-id uint u0)
(define-data-var contract-uri (string-ascii 80) "ipfs://QmVf6KTZd5Qb3YtBecuAn6YosjyXWtjaQmq8cnNjRHEoGm/contract.json")
(define-data-var sale-active bool false)
(define-data-var redemption-active bool false)
(define-data-var sale-price uint u600000000)

;; Set metadata uri for sizes
(map-set metadata-uri u1 "ipfs://QmVf6KTZd5Qb3YtBecuAn6YosjyXWtjaQmq8cnNjRHEoGm/1.json")
(map-set metadata-uri u2 "ipfs://QmVf6KTZd5Qb3YtBecuAn6YosjyXWtjaQmq8cnNjRHEoGm/2.json")
(map-set metadata-uri u3 "ipfs://QmVf6KTZd5Qb3YtBecuAn6YosjyXWtjaQmq8cnNjRHEoGm/3.json")
(map-set metadata-uri u4 "ipfs://QmVf6KTZd5Qb3YtBecuAn6YosjyXWtjaQmq8cnNjRHEoGm/4.json")
(map-set metadata-uri u5 "ipfs://QmVf6KTZd5Qb3YtBecuAn6YosjyXWtjaQmq8cnNjRHEoGm/5.json")
(map-set metadata-uri u6 "ipfs://QmVf6KTZd5Qb3YtBecuAn6YosjyXWtjaQmq8cnNjRHEoGm/6.json")
(map-set metadata-uri u7 "ipfs://QmVf6KTZd5Qb3YtBecuAn6YosjyXWtjaQmq8cnNjRHEoGm/7.json")

;; Token count for account
(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? Megapont-Bomber id)))

(define-read-only (get-token-uri (id uint))
    (ok (some (unwrap! (map-get? metadata-uri (unwrap! (map-get? token-sizes id) ERR-NOT-FOUND)) ERR-NOT-FOUND))))

(define-read-only (get-contract-uri)
  (ok (some (var-get contract-uri))))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? Megapont-Bomber id sender recipient)
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

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (called-by-operator id) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? market id)) ERR-LISTING)
    (asserts! (is-eq (default-to  false (map-get? redeemed id)) false) ERR-NOT-AUTHORIZED)
    (trnsfr id sender recipient)))

(define-private (called-by-operator (id uint))
  (let ((owner (unwrap! (nft-get-owner? Megapont-Bomber id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm)}))
    (asserts! (called-by-operator id) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (default-to  false (map-get? redeemed id)) false) ERR-NOT-AUTHORIZED)
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
  (let ((owner (unwrap! (nft-get-owner? Megapont-Bomber id) ERR-NOT-FOUND))
      (listing (unwrap! (map-get? market id) ERR-LISTING))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {action: "buy-in-ustx", id: id})
    (ok true)))

(define-public (set-base-uri (size uint) (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set metadata-uri size new-base-uri)
    (ok true)))

(define-public (set-sale-price (new-price uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set sale-price new-price)
    (ok true)))

(define-public (set-sale-active (new-active bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set sale-active new-active)
    (ok true)))

(define-public (set-redemption-active (new-active bool))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set redemption-active new-active)
        (ok true)))

(define-public (redeem (id uint))
  (begin
    (asserts! (var-get redemption-active) ERR-NOT-AUTHORIZED)
    (asserts! (called-by-operator id) ERR-NOT-AUTHORIZED)
    (map-delete market id)
    (map-set redeemed id true)
    (ok true)))

(define-read-only (mint-permitted (sender principal))
    (or (> (contract-call? .megapont-ape-club-nft get-balance sender) u0)
        (> (unwrap! (contract-call? .mega get-balance sender) false) u0)))

(define-public (mint (size uint))
    (let ((next-id (+ u1 (var-get last-id))))
        (asserts! (var-get sale-active) ERR-NOT-AUTHORIZED)
        (asserts! (mint-permitted tx-sender) ERR-NOT-AUTHORIZED)
        (asserts! (< (var-get last-id) JACKET-LIMIT) ERR-NOT-AUTHORIZED)
        (match (nft-mint? Megapont-Bomber next-id tx-sender)
            success
            (let
                ((current-balance (get-balance tx-sender)))
                (begin
                    (try! (stx-transfer? (var-get sale-price) tx-sender WALLET_1))
                    (map-set token-sizes next-id size)
                    (var-set last-id next-id)
                    (map-set token-count
                        tx-sender
                        (+ current-balance u1)
                    )
                    (ok true)))
            error (err (* error u10000)))))
