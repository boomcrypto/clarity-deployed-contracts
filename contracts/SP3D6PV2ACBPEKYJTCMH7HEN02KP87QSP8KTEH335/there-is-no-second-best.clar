(impl-trait .nft-trait.nft-trait)
(use-trait commission-trait .commission-trait.commission)

(define-non-fungible-token There-is-No-Second-Best uint)

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-LISTING (err u507))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-WRONG-COMMISSION (err u301))

(define-map token-count principal uint)
(define-map mint-count principal uint)
(define-map market uint {price: uint, commission: principal})

(define-data-var last-id uint u0)
(define-data-var last-mintable-id uint u0)
(define-data-var contract-uri (string-ascii 80) "")
(define-data-var base-uri (string-ascii 80) "")
(define-data-var sale-active bool false)

(define-read-only (get-balance (account principal))
    (default-to u0
        (map-get? token-count account)))

(define-read-only (get-last-token-id)
    (ok (var-get last-id)))

(define-read-only (get-owner (id uint))
    (ok (nft-get-owner? There-is-No-Second-Best id)))

(define-read-only (get-contract-uri)
    (ok (some (var-get contract-uri))))

(define-read-only (get-token-uri (id uint))
    (ok (some (var-get base-uri))))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
    (match (nft-transfer? There-is-No-Second-Best id sender recipient)
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
        (trnsfr id sender recipient)))

(define-private (called-by-operator (id uint))
    (let ((owner (unwrap! (nft-get-owner? There-is-No-Second-Best id) false)))
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
    (let ((owner (unwrap! (nft-get-owner? There-is-No-Second-Best id) ERR-NOT-FOUND))
        (listing (unwrap! (map-get? market id) ERR-LISTING))
        (price (get price listing)))
        (asserts! (is-eq (contract-of comm) (get commission listing)) ERR-WRONG-COMMISSION)
        (try! (stx-transfer? price tx-sender owner))
        (try! (contract-call? comm pay id price))
        (try! (trnsfr id owner tx-sender))
        (map-delete market id)
        (print {action: "buy-in-ustx", id: id})
        (ok true)))

(define-public (set-base-uri (new-base-uri (string-ascii 80)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set base-uri new-base-uri)
        (ok true)))

(define-read-only (mint-permitted (sender principal))
    (and (> (contract-call? .megapont-ape-club-nft get-balance sender) u0)
        (is-none (map-get? mint-count sender))))

(define-public (set-sale-active (new-base-uri (string-ascii 80)) (new-active bool) (new-last-mintable-id uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set base-uri new-base-uri)
        (var-set sale-active new-active)
        (var-set last-mintable-id new-last-mintable-id)
        (ok true)))

(define-public (claim)
    (let
        ((sender tx-sender)
        (next-id (+ u1 (var-get last-id))))
        (asserts! (is-eq (mint-permitted sender) true) ERR-NOT-AUTHORIZED)
        (asserts! (is-eq (var-get sale-active) true) ERR-NOT-AUTHORIZED)
        (asserts! (<= next-id (var-get last-mintable-id)) ERR-NOT-AUTHORIZED)
        (match (nft-mint? There-is-No-Second-Best next-id sender)
            success
                (begin
                    (map-set token-count
              sender
              (+ (get-balance sender) u1)
            )
                    (map-set mint-count sender u1)
                    (var-set last-id next-id)
                    (ok success))
            error (err (* error u10000)))))

(define-read-only (get-passes (caller principal))
    (if (is-eq (mint-permitted caller) true) u1 u0))

(define-read-only (get-premint-enabled)
    (ok (var-get sale-active)))

(nft-mint? There-is-No-Second-Best (+ u1 (var-get last-id)) 'SP1C39PEYB976REP9B19QMFDJHHF27A63WANDGTX4)
(map-set token-count 'SP1C39PEYB976REP9B19QMFDJHHF27A63WANDGTX4
    (+ (get-balance 'SP1C39PEYB976REP9B19QMFDJHHF27A63WANDGTX4) u1))
(map-set mint-count 'SP1C39PEYB976REP9B19QMFDJHHF27A63WANDGTX4 u1)
(var-set last-id (+ u1 (var-get last-id)))
