;; title: stxdev
;; version: 0.0.1
;; summary: A NFT powering the stxdev.xyz blog membership

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token stxdev-blog-membership uint)

(define-constant base-mint-price u50000) ;; 50_000 microstacks = 0,05 STX
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-data-var last-token-id uint u0)
(define-map token-balance { owner: principal } uint)

(define-read-only (get-last-token-id)
  (ok (var-get last-token-id)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat "https://stxdev.xyz/token/" (int-to-ascii token-id)))))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? stxdev-blog-membership token-id)))

(define-read-only (is-token-owner (owner principal))
  (let
    ((owner-token-balance (default-to u0 (map-get? token-balance { owner: owner }))))
    (ok (> owner-token-balance u0))))

(define-public (transfer (token-id uint) (token-sender principal) (token-recipient principal))
  (let
    ((transfer-fee (get-transfer-fee))
    (fee-recipient contract-owner)
    (sender-balance (default-to u0 (map-get? token-balance {owner: token-sender})))
    (recipient-balance (default-to u0 (map-get? token-balance {owner: token-recipient}))))

    (asserts! (is-eq tx-sender token-sender) err-not-token-owner)
    (try! (stx-transfer? transfer-fee token-sender fee-recipient))
    (try! (nft-transfer? stxdev-blog-membership token-id token-sender token-recipient))
    (map-set token-balance {owner: token-recipient} (+ recipient-balance u1))
    (map-set token-balance {owner: token-sender} (- sender-balance u1))
    (ok true)))

(define-public (mint (token-recipient principal))
  (let
    ((token-id (+ (var-get last-token-id) u1))
    (fee-sender tx-sender)
    (fee-recipient contract-owner)
    (fee (get-mint-fee))
    (current-token-recipient-balance (default-to u0 (map-get? token-balance {owner: token-recipient}))))

    (try! (stx-transfer? fee fee-sender fee-recipient))
    (try! (nft-mint? stxdev-blog-membership token-id token-recipient))
    (map-set token-balance { owner: token-recipient } (+ current-token-recipient-balance u1))
    (var-set last-token-id token-id)
    (ok token-id)))

(define-private (get-mint-fee)
  (let (
    (ratio (/ (var-get last-token-id) u25)))

    (* base-mint-price (pow u10 ratio))))

(define-private (get-transfer-fee) (/ (get-mint-fee) u10))