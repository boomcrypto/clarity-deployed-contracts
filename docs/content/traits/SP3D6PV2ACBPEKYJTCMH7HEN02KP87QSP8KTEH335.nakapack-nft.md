---
title: "Trait nakapack-nft"
draft: true
---
```
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

(define-non-fungible-token Nakapack uint)

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-SOLD-OUT (err u300))
(define-constant ERR-WRONG-COMMISSION (err u301))
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-LISTING (err u406))

(define-data-var base-uri (string-ascii 80) "ipfs:://QmXi7zSHKfeFThsWQ1wCjTr5SxEC7ciw5YuKkzcTQQWKcG/{id}.json")
(define-data-var contract-uri (string-ascii 80) "ipfs://QmVoP3jWvULQBWhoixXi85XwiwMogMB1vzcBbQvRTQRQ1H")
(define-data-var last-id uint u0)
(define-data-var max-supply uint u5000)
(define-data-var minter-address principal 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.nakapack-nft-minter)

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})

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
    (let ((owner (unwrap! (nft-get-owner? Nakapack id) ERR-NOT-FOUND))
        (listing (unwrap! (map-get? market id) ERR-LISTING))
        (price (get price listing)))
    (asserts! (is-eq (contract-of comm) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {action: "buy-in-ustx", id: id})
    (ok true)))

(define-public (set-minter-address (new-minter-address principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set minter-address new-minter-address)
        (ok true)))

(define-public (set-max-supply (new-max-supply uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set max-supply new-max-supply)
        (ok true)))

(define-public (mint (new-owner principal))
    (let ((next-id (+ u1 (var-get last-id))))
        (asserts! (called-from-mint) ERR-NOT-AUTHORIZED)
        (asserts! (< (var-get last-id) (var-get max-supply)) ERR-SOLD-OUT)
        (match (nft-mint? Nakapack next-id new-owner)
            success
                (let
                    ((current-balance (get-balance new-owner)))
                    (begin
                        (var-set last-id next-id)
                        (map-set token-count new-owner (+ current-balance u1))
                (ok true)))
            error (err (* error u10000)))))

(define-read-only (get-balance (account principal))
    (default-to u0
        (map-get? token-count account)))

(define-read-only (get-owner (id uint))
    (ok (nft-get-owner? Nakapack id)))

(define-read-only (get-last-token-id)
    (ok (var-get last-id)))

(define-read-only (get-token-uri (id uint))
    (ok (some (var-get base-uri))))

(define-read-only (get-contract-uri)
    (ok (var-get contract-uri)))

(define-read-only (get-listing-in-ustx (id uint))
    (map-get? market id))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
    (match (nft-transfer? Nakapack id sender recipient)
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
    (let ((owner (unwrap! (nft-get-owner? Nakapack id) false)))
        (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-private (called-from-mint)
    (is-eq (var-get minter-address) contract-caller))

```
