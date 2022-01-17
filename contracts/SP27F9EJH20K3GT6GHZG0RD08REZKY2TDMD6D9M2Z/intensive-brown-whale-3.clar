;; badger-mint-test
;; this contract tests admin minting directly into another contract, then "minting" through a transfer

;; start constants/errors, variables & sequences
(define-constant owner tx-sender)
(define-constant test-owner 'SP1N35KMK3EX3SXRAEZ89J2YX23Q1F7P9J640QHX4)
(define-constant NOT-OWNER (err u101))
(define-constant STX-TRNSF-ERR (err u102))
(define-constant BDGR-TRNSF-ERR (err u103))

(define-data-var test-last-id uint u686)

;; admin mint to this contract / aka create a mint "listing"
(define-public (test-mint-to-contract)
  (begin
    ;; checks tx-sender is principal that deployed contract
    (asserts! (is-eq tx-sender owner) NOT-OWNER)
    ;; admin mint drop directly to this contract
    (ok (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop (as-contract tx-sender) u686)))
  )
)

;; public "mint" function that's a purchase & transfer
(define-public (test-mint-purchase)
  (let (
    (next-id (+ u1 (var-get test-last-id)))
    )
    ;; checks tx-sender is admin cli account
    (asserts! (is-eq tx-sender test-owner) NOT-OWNER)
    ;; transfers stx as a "mint purchase"
    (unwrap! (stx-transfer? u100000 tx-sender owner) STX-TRNSF-ERR)
    ;; transfer badger v2 of last-id from this contract to purchaser as a successful "mint purchase"
    (unwrap! (as-contract (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 transfer (var-get test-last-id) (as-contract tx-sender) tx-sender)) BDGR-TRNSF-ERR)
    (ok (var-set test-last-id next-id))
  )
)
