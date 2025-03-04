;; traits
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait commission-trait .screenfiends-commission.commission)

;; token definitions
(define-non-fungible-token ScreenFiends uint)

;; constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-SOLD-OUT (err u300))
(define-constant ERR-WRONG-COMMISSION (err u301))
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-LISTING (err u406))

;; data vars
(define-data-var base-uri (string-ascii 80) "ipfs://QmZWqHBTo5nsBSbSe43wH3JZY6fwop5uHNJZ9RTLbhnYtW/{id}.json")
(define-data-var contract-uri (string-ascii 80) "ipfs://bafkreigotvx5wjswq6ppnoscciqyphqmdsygxpu44s5tlkanw6v6rjhgq4")
(define-data-var last-id uint u0)
(define-data-var max-supply uint u5000)

;; data maps
(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})
(define-data-var trusted-contract principal 'SP2892G9YED28VAQWV6B3SRXHC3WY4X1N2YN1X6J3.screenfiends-nft-minter)

;; public functions
(define-public (transfer (id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
        (asserts! (is-none (map-get? market id)) ERR-LISTING)
        (try! (trnsfr id sender recipient))
        (ok true)))

(define-public (set-base-uri (new-base-uri (string-ascii 80)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set base-uri new-base-uri)
        (ok true)))

(define-public (set-contract-uri (new-contract-uri (string-ascii 80)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set contract-uri new-contract-uri)
        (ok true)))

(define-public (list-in-ustx (id uint) (price uint) (comm <commission-trait>))
    (let ((listing  {price: price, commission: (contract-of comm)}))
        (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
        (map-set market id listing)
        (print (merge listing {action: "list-in-ustx", id: id}))
        (ok true)))

(define-public (unlist-in-ustx (id uint))
    (begin
        (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
        (map-delete market id)
        (print {action: "unlist-in-ustx", id: id})
        (ok true)))

(define-public (buy-in-ustx (id uint) (comm <commission-trait>))
    (let ((owner (unwrap! (nft-get-owner? ScreenFiends id) ERR-NOT-FOUND))
        (listing (unwrap! (map-get? market id) ERR-LISTING))
        (price (get price listing)))
    (asserts! (is-eq (contract-of comm) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {action: "buy-in-ustx", id: id})
    (ok true)))


(define-public (set-max-supply (new-supply uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set max-supply new-supply)
    (ok new-supply)))


(define-read-only (get-max-supply)
  (ok (var-get max-supply)))


(define-public (set-trusted-contract (contract principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set trusted-contract contract)
        (ok true)))


(define-public (mint (new-owner principal))
    (let ((next-id (+ u1 (var-get last-id)))
          (total-supply (var-get max-supply)))

        (asserts! (called-from-mint) ERR-NOT-AUTHORIZED)
        (asserts! (< (var-get last-id) total-supply) ERR-SOLD-OUT)
        (match (nft-mint? ScreenFiends next-id new-owner)
            success
                (let ((current-balance (get-balance new-owner)))
                    (begin
                        (var-set last-id next-id)
                        (map-set token-count new-owner (+ current-balance u1))
                        (ok next-id)))
            error (err (* error u10000)))))

;; read only functions
(define-read-only (get-balance (account principal))
    (default-to u0
        (map-get? token-count account)))

(define-read-only (get-owner (id uint))
    (ok (nft-get-owner? ScreenFiends id)))

(define-read-only (get-last-token-id)
    (ok (var-get last-id)))

(define-read-only (get-token-uri (id uint))
    (ok (some (var-get base-uri))))

(define-read-only (get-contract-uri)
    (ok (var-get contract-uri)))

(define-read-only (get-listing-in-ustx (id uint))
    (map-get? market id))

;; private functions
(define-private (trnsfr (id uint) (sender principal) (recipient principal))
    (match (nft-transfer? ScreenFiends id sender recipient)
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
    (let ((owner (unwrap! (nft-get-owner? ScreenFiends id) false)))
        (and
            (is-eq tx-sender contract-caller)
            (is-eq tx-sender owner))))

(define-private (called-from-mint)
    (is-eq (var-get trusted-contract) contract-caller))
