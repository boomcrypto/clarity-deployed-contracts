;; StacksBridge - Satoshibles

(use-trait nft-trait .nft-trait.nft-trait)
(use-trait ft-trait .ft-trait.ft-trait)

;; Define Constants
(define-constant NFT-CONTRACT .satoshibles)

(define-constant CONTRACT-DEPLOYER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-BRIDGE-CLOSED (err u503))

(define-data-var contract-owner principal tx-sender)
(define-data-var contract-worker principal tx-sender)
(define-data-var bridge-closed bool false)

(define-public (lock (id uint) (address (string-ascii 42)))
    (let (
        (nft-owner (unwrap-panic (unwrap! (contract-call? .satoshibles get-owner id) ERR-NOT-FOUND)))
        )
        (asserts! (not (var-get bridge-closed)) ERR-BRIDGE-CLOSED)
        (asserts! (is-eq tx-sender nft-owner) ERR-NOT-AUTHORIZED)
        (try! (contract-call? .satoshibles transfer id tx-sender (as-contract tx-sender)))
        (print {action: "lock", id: id, address: address})
        (ok true)
    )
)

(define-public (release (id uint) (address principal))
    (begin
        (asserts! (not (var-get bridge-closed)) ERR-BRIDGE-CLOSED)
        (asserts! (is-eq tx-sender (var-get contract-worker)) ERR-NOT-AUTHORIZED)
        (try! (as-contract (contract-call? .satoshibles transfer id tx-sender address)))
        (print {action: "release", id: id, address: address})
        (ok true)
    )
)

;; Lock Many
(define-public (lock-many (nfts-to-lock (list 50 { id: uint, address: (string-ascii 42) })))
  (fold check-err
    (map receive-token nfts-to-lock)
    (ok true)
  )
)
(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result
               err-value (err err-value)
  )
)
(define-private (receive-token (nft-to-lock { id: uint, address: (string-ascii 42) }))
  (lock-token (get id nft-to-lock) (get address nft-to-lock))
)
(define-private (lock-token (id uint) (address (string-ascii 42)))
  (let
    (
      (lockOk (try! (lock id address)))
    )
    (ok lockOk)
  )
)

;; Release Many
(define-public (release-many (nfts-to-release (list 50 { id: uint, address: principal })))
  (fold check-err
    (map send-token nfts-to-release)
    (ok true)
  )
)
(define-private (send-token (nft-to-release { id: uint, address: principal }))
  (release-token (get id nft-to-release) (get address nft-to-release))
)
(define-private (release-token (id uint) (address principal))
  (let
    (
      (releaseOk (try! (release id address)))
    )
    (ok releaseOk)
  )
)

;; Bridge Maintenance
(define-public (set-bridge-closed (state bool))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (var-set bridge-closed state)
    (ok true)))

;; Safety functions
(define-public (transfer-stx (address principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (unwrap-panic (as-contract (stx-transfer? amount (as-contract tx-sender) address)))
    (ok true))
)

(define-public (transfer-ft-token (address principal) (amount uint) (token <ft-trait>))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (try! (as-contract (contract-call? token transfer amount tx-sender address none)))
    (ok true))
)

(define-public (transfer-nft-token (address principal) (id uint) (token <nft-trait>))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (try! (as-contract (contract-call? token transfer id tx-sender address)))
    (ok true))
)

(define-public (set-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (var-set contract-owner new-owner)
    (ok true))
)

(define-public (set-worker (new-worker principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (var-set contract-worker new-worker)
    (ok true))
)