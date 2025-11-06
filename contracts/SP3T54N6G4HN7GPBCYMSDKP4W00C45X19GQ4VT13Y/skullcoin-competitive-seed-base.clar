;; Skullcoin | Competitive | Seed Phrase | v.1.0.0
;; skullco.in

;; Traits
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Constants and Errors
(define-constant CONTRACT-OWNER tx-sender)
(define-constant BURN-WALLET 'SP5EDWN88FN8Q6A1MQ0N7SKKAG0VZ0ZQ9MFZ6RS8)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-SALE-NOT-ACTIVE (err u101))
(define-constant ERR-BURN-NOT-ACTIVE (err u102))
(define-constant ERR-NOT-OWNER (err u103))

;; Variables
(define-data-var sale-active bool false)
(define-data-var burn-active bool false)
(define-data-var token-amount uint u100000000000)

;; Check public sales active
(define-read-only (sale-enabled)
  (ok (var-get sale-active)))

;; Check burn active
(define-read-only (burn-enabled)
  (ok (var-get burn-active)))

;; Set public sale flag (only contract owner)
(define-public (flip-sale)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set sale-active (not (var-get sale-active)))
    (ok (var-get sale-active))))

;; Set burn flag (only contract owner)
(define-public (flip-burn)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set burn-active (not (var-get burn-active)))
    (ok (var-get burn-active))))

;; Deposit SIP-010 tokens in contract (only contract owner)
(define-public (deposit-ft (asset <ft-trait>) (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (try! (contract-call? asset transfer amount tx-sender (as-contract tx-sender) none))
  (ok true)))

;; Withdrawal SIP-010 tokens from contract (only contract owner)
(define-public (withdraw-ft (asset <ft-trait>) (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (try! (as-contract (contract-call? asset transfer amount tx-sender CONTRACT-OWNER none)))
  (ok true)))

;; Withdrawal STX from contract (only contract owner)
(define-public (withdraw-stx (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (try! (as-contract (stx-transfer? amount tx-sender CONTRACT-OWNER)))
  (ok true)))

;; Claim 1 NFT
(define-public (claim-one)
  (begin
    (try! (claim))
  (ok true)))

;; Claim 5 NFT
(define-public (claim-five)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
  (ok true)))

;; Claim 10 NFT
(define-public (claim-ten)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
  (ok true)))

;; Claim 25 NFT
(define-public (claim-twenty-five)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
  (ok true)))

;; Burn 5 NFTs / Phase 1
(define-public (burn-phase-1 (id1 uint) (id2 uint) (id3 uint) (id4 uint) (id5 uint))
  (begin
    (asserts! (var-get burn-active) ERR-BURN-NOT-ACTIVE)
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-seed-phase1 get-owner id1) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-seed-phase1 get-owner id2) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-seed-phase1 get-owner id3) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-seed-phase1 get-owner id4) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-seed-phase1 get-owner id5) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
    (try! (contract-call? .skullcoin-competitive-seed-phase1 transfer id1 tx-sender BURN-WALLET))
    (try! (contract-call? .skullcoin-competitive-seed-phase1 transfer id2 tx-sender BURN-WALLET))
    (try! (contract-call? .skullcoin-competitive-seed-phase1 transfer id3 tx-sender BURN-WALLET))
    (try! (contract-call? .skullcoin-competitive-seed-phase1 transfer id4 tx-sender BURN-WALLET))
    (try! (contract-call? .skullcoin-competitive-seed-phase1 transfer id5 tx-sender BURN-WALLET))
    (try! (contract-call? .skullcoin-competitive-seed-phase2 mint tx-sender))
    (try! (contract-call? .skullcoin-competitive-seed-phase2 mint tx-sender))
    (print {
      result: "nfts successfully burned",
      user: contract-caller,
      nft-1: id1,
      nft-2: id2,
      nft-3: id3,
      nft-4: id4,
      nft-5: id5
    })
  (ok true)))

;; Burn 5 NFTs / Phase 2
(define-public (burn-phase-2 (id1 uint) (id2 uint) (id3 uint) (id4 uint) (id5 uint))
  (begin
    (asserts! (var-get burn-active) ERR-BURN-NOT-ACTIVE)
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-seed-phase2 get-owner id1) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-seed-phase2 get-owner id2) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-seed-phase2 get-owner id3) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-seed-phase2 get-owner id4) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-seed-phase2 get-owner id5) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
    (try! (contract-call? .skullcoin-competitive-seed-phase2 transfer id1 tx-sender BURN-WALLET))
    (try! (contract-call? .skullcoin-competitive-seed-phase2 transfer id2 tx-sender BURN-WALLET))
    (try! (contract-call? .skullcoin-competitive-seed-phase2 transfer id3 tx-sender BURN-WALLET))
    (try! (contract-call? .skullcoin-competitive-seed-phase2 transfer id4 tx-sender BURN-WALLET))
    (try! (contract-call? .skullcoin-competitive-seed-phase2 transfer id5 tx-sender BURN-WALLET))
    (try! (send-ft-to-winner tx-sender))
    (print {
      result: "nfts successfully burned",
      user: contract-caller,
      nft-1: id1,
      nft-2: id2,
      nft-3: id3,
      nft-4: id4,
      nft-5: id5
    })
  (ok true)))

;; Internal - Mint NFT via public
(define-private (claim)
  (begin
    (asserts! (var-get sale-active) ERR-SALE-NOT-ACTIVE)
    (try! (contract-call? .skullcoin-competitive-seed-phase1 mint tx-sender))
  (ok true)))

;; Internal - Send SIP-010 tokens to winner player in claim function for tokens NFTs
(define-private (send-ft-to-winner (player principal))
  (begin
    (try! (as-contract (contract-call? 'SP3BRXZ9Y7P5YP28PSR8YJT39RT51ZZBSECTCADGR.skullcoin-stxcity transfer (var-get token-amount) tx-sender player none)))
  (ok true)))

;; Register this contract as allowed to mint
(as-contract (contract-call? .skullcoin-competitive-seed-phase1 set-mint-address))
(as-contract (contract-call? .skullcoin-competitive-seed-phase2 set-mint-address))