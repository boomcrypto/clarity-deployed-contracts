---
title: "Trait skullcoin-competitive-g1-base"
draft: true
---
```
;; Skullcoin | Competitive | Game #1 | v.1.0.0
;; skullco.in

;; Traits
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Constants and Errors
(define-constant CONTRACT-OWNER tx-sender)
(define-constant BURN-WALLET 'SP5EDWN88FN8Q6A1MQ0N7SKKAG0VZ0ZQ9MFZ6RS8)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-SALE-NOT-ACTIVE (err u101))
(define-constant ERR-NOT-OWNER (err u102))
(define-constant ERR-NOT-TREASURE (err u103))
(define-constant ERR-NOT-CHEST (err u104))
(define-constant ERR-NOT-TOKENS (err u105))
(define-constant ERR-NOT-STX (err u106))
(define-constant REACHED-BLOCK-PICK-LIMIT (err u107))
(define-constant ERR-NO-WL-REMAINING (err u108))

;; Variables
(define-data-var wl-sale-active bool false)
(define-data-var sale-active bool false)
(define-data-var last-block uint u0)
(define-data-var byte-id uint u0)
(define-data-var picked-id uint u0)
(define-data-var last-vrf (buff 64) 0x00)

;; Maps
(define-map wl-count principal uint)
(define-map treasure-phase-1 { id: uint} {claim: bool})
(define-map treasure-phase-2 { id: uint} {claim: bool})
(define-map treasure-phase-3 { id: uint} {claim: bool})
(define-map chest-phase-1 { id: uint} {claim: bool})
(define-map chest-phase-2 { id: uint} {claim: bool})
(define-map chest-phase-3 { id: uint} {claim: bool})
(define-map tokens-phase-1 { id: uint} {claim: bool})
(define-map tokens-phase-2 { id: uint} {claim: bool})
(define-map tokens-phase-3 { id: uint} {claim: bool})
(define-map stx-phase-1 { id: uint} {claim: bool})
(define-map stx-phase-2 { id: uint} {claim: bool})
(define-map stx-phase-3 { id: uint} {claim: bool})

;; Get whitelist balance
(define-read-only (get-wl-balance (account principal))
  (default-to u0
    (map-get? wl-count account)))

;; Check whitelist sales active
(define-read-only (wl-enabled)
  (ok (var-get wl-sale-active)))

;; Check public sales active
(define-read-only (public-enabled)
  (ok (var-get sale-active)))

;; Set whitelist sale flag (only contract owner)
(define-public (flip-wl-sale)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set wl-sale-active (not (var-get wl-sale-active)))
    (ok (var-get wl-sale-active))))

;; Set public sale flag (only contract owner)
(define-public (flip-sale)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set sale-active (not (var-get sale-active)))
    (ok (var-get sale-active))))

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

;; Deposit STX in contract (only contract owner)
(define-public (deposit-stx (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
  (ok true)))

;; Withdrawal STX from contract (only contract owner)
(define-public (withdraw-stx (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (try! (as-contract (stx-transfer? amount tx-sender CONTRACT-OWNER)))
  (ok true)))

;; Set whitelist wallets (only contract owner)
(define-public (set-wl-wallets (wallet principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set wl-count wallet amount)
  (ok true)))

;; Set treasures ids / Phase 1 (only contract owner)
(define-public (set-treasure-phase-1 (nft-id uint) (status bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set treasure-phase-1 { id: nft-id } { claim: status})
  (ok true)))

;; Set treasures ids / Phase 2 (only contract owner)
(define-public (set-treasure-phase-2 (nft-id uint) (status bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set treasure-phase-2 { id: nft-id } { claim: status})
  (ok true)))

;; Set treasures ids / Phase 3 (only contract owner)
(define-public (set-treasure-phase-3 (nft-id uint) (status bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set treasure-phase-3 { id: nft-id } { claim: status})
  (ok true)))

;; Set chests ids / Phase 1 (only contract owner)
(define-public (set-chest-phase-1 (nft-id uint) (status bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set chest-phase-1 { id: nft-id } { claim: status})
  (ok true)))

;; Set chests ids / Phase 2 (only contract owner)
(define-public (set-chest-phase-2 (nft-id uint) (status bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set chest-phase-2 { id: nft-id } { claim: status})
  (ok true)))

;; Set chests ids / Phase 3 (only contract owner)
(define-public (set-chest-phase-3 (nft-id uint) (status bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set chest-phase-3 { id: nft-id } { claim: status})
  (ok true)))

;; Set tokens ids / Phase 1 (only contract owner)
(define-public (set-tokens-phase-1 (nft-id uint) (status bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set tokens-phase-1 { id: nft-id } { claim: status})
  (ok true)))

;; Set tokens ids / Phase 2 (only contract owner)
(define-public (set-tokens-phase-2 (nft-id uint) (status bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set tokens-phase-2 { id: nft-id } { claim: status})
  (ok true)))

;; Set tokens ids / Phase 3 (only contract owner)
(define-public (set-tokens-phase-3 (nft-id uint) (status bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set tokens-phase-3 { id: nft-id } { claim: status})
  (ok true)))

;; Set stx reward ids / Phase 1 (only contract owner)
(define-public (set-stx-phase-1 (nft-id uint) (status bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set stx-phase-1 { id: nft-id } { claim: status})
  (ok true)))

;; Set stx reward ids / Phase 2 (only contract owner)
(define-public (set-stx-phase-2 (nft-id uint) (status bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set stx-phase-2 { id: nft-id } { claim: status})
  (ok true)))

;; Set stx reward ids / Phase 3 (only contract owner)
(define-public (set-stx-phase-3 (nft-id uint) (status bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set stx-phase-3 { id: nft-id } { claim: status})
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

;; Claim treasure / Phase 1
(define-public (claim-treasure-phase-1 (id uint) (amount uint))
  (begin
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-g1-phase1 get-owner id) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
    (asserts! (is-eq (get claim (unwrap-panic (map-get? treasure-phase-1 { id: id }))) true) ERR-NOT-TREASURE)
    (try! (send-stx-to-winner amount tx-sender))
    (map-set treasure-phase-1 { id: id } { claim: false})
    (print "Congrats")
  (ok true)))

;; Claim treasure / Phase 2
(define-public (claim-treasure-phase-2 (id uint) (amount uint))
  (begin
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-g1-phase2 get-owner id) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
    (asserts! (is-eq (get claim (unwrap-panic (map-get? treasure-phase-2 { id: id }))) true) ERR-NOT-TREASURE)
    (try! (send-stx-to-winner amount tx-sender))
    (map-set treasure-phase-2 { id: id } { claim: false})
    (print "Congrats")
  (ok true)))

;; Claim treasure / Phase 3
(define-public (claim-treasure-phase-3 (id uint) (amount uint))
  (begin
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-g1-phase3 get-owner id) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
    (asserts! (is-eq (get claim (unwrap-panic (map-get? treasure-phase-3 { id: id }))) true) ERR-NOT-TREASURE)
    (try! (send-stx-to-winner amount tx-sender))
    (map-set treasure-phase-3 { id: id } { claim: false})
    (print "Congrats")
  (ok true)))

;; Claim chest / Phase 1
(define-public (claim-chest-phase-1 (id uint) (amount uint))
  (begin
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-g1-phase1 get-owner id) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
    (try! (pick-id))
        (if (is-eq (mod (var-get picked-id) u2) u0)
          (begin
            (asserts! (is-eq (get claim (unwrap-panic (map-get? chest-phase-1 { id: id }))) true) ERR-NOT-CHEST)
            (try! (send-stx-to-winner amount tx-sender))
            (map-set chest-phase-1 { id: id } { claim: false})
            (print "Congrats")
            (ok (var-get picked-id)))
          (begin
            (map-set chest-phase-1 { id: id } { claim: false})
            (print "Not this time")
            (ok (var-get picked-id))))))

;; Claim chest / Phase 2
(define-public (claim-chest-phase-2 (id uint) (amount uint))
  (begin
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-g1-phase2 get-owner id) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
    (try! (pick-id))
        (if (is-eq (mod (var-get picked-id) u2) u0)
          (begin
            (asserts! (is-eq (get claim (unwrap-panic (map-get? chest-phase-2 { id: id }))) true) ERR-NOT-CHEST)
            (try! (send-stx-to-winner amount tx-sender))
            (map-set chest-phase-2 { id: id } { claim: false})
            (print "Congrats")
            (ok (var-get picked-id)))
          (begin
            (map-set chest-phase-2 { id: id } { claim: false})
            (print "Not this time")
            (ok (var-get picked-id))))))

;; Claim chest / Phase 3
(define-public (claim-chest-phase-3 (id uint) (amount uint))
  (begin
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-g1-phase3 get-owner id) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
    (try! (pick-id))
        (if (is-eq (mod (var-get picked-id) u2) u0)
          (begin
            (asserts! (is-eq (get claim (unwrap-panic (map-get? chest-phase-3 { id: id }))) true) ERR-NOT-CHEST)
            (try! (send-stx-to-winner amount tx-sender))
            (map-set chest-phase-3 { id: id } { claim: false})
            (print "Congrats")
            (ok (var-get picked-id)))
          (begin
            (map-set chest-phase-3 { id: id } { claim: false})
            (print "Not this time")
            (ok (var-get picked-id))))))

;; Claim STX / Phase 1
(define-public (claim-stx-phase-1 (id uint) (amount uint))
  (begin
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-g1-phase1 get-owner id) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
    (asserts! (is-eq (get claim (unwrap-panic (map-get? stx-phase-1 { id: id }))) true) ERR-NOT-STX)
    (try! (send-stx-to-winner amount tx-sender))
    (map-set stx-phase-1 { id: id } { claim: false})
    (print "Congrats")
  (ok true)))

;; Claim STX / Phase 2
(define-public (claim-stx-phase-2 (id uint) (amount uint))
  (begin
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-g1-phase2 get-owner id) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
    (asserts! (is-eq (get claim (unwrap-panic (map-get? stx-phase-2 { id: id }))) true) ERR-NOT-STX)
    (try! (send-stx-to-winner amount tx-sender))
    (map-set stx-phase-2 { id: id } { claim: false})
    (print "Congrats")
  (ok true)))

;; Claim STX / Phase 3
(define-public (claim-stx-phase-3 (id uint) (amount uint))
  (begin
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-g1-phase3 get-owner id) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
    (asserts! (is-eq (get claim (unwrap-panic (map-get? stx-phase-3 { id: id }))) true) ERR-NOT-STX)
    (try! (send-stx-to-winner amount tx-sender))
    (map-set stx-phase-3 { id: id } { claim: false})
    (print "Congrats")
  (ok true)))

;; Claim FT / Phase 1
(define-public (claim-tokens-phase-1 (asset <ft-trait>) (id uint) (amount uint))
  (begin
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-g1-phase1 get-owner id) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
    (asserts! (is-eq (get claim (unwrap-panic (map-get? tokens-phase-1 { id: id }))) true) ERR-NOT-TOKENS)
    (try! (send-ft-to-winner asset amount tx-sender))
    (map-set tokens-phase-1 { id: id } { claim: false})
    (print "Congrats")
  (ok true)))

;; Claim FT / Phase 2
(define-public (claim-tokens-phase-2 (asset <ft-trait>) (id uint) (amount uint))
  (begin
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-g1-phase2 get-owner id) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
    (asserts! (is-eq (get claim (unwrap-panic (map-get? tokens-phase-2 { id: id }))) true) ERR-NOT-TOKENS)
    (try! (send-ft-to-winner asset amount tx-sender))
    (map-set tokens-phase-2 { id: id } { claim: false})
    (print "Congrats")
  (ok true)))

;; Claim FT / Phase 3
(define-public (claim-tokens-phase-3 (asset <ft-trait>) (id uint) (amount uint))
  (begin
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-g1-phase3 get-owner id) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
    (asserts! (is-eq (get claim (unwrap-panic (map-get? tokens-phase-3 { id: id }))) true) ERR-NOT-TOKENS)
    (try! (send-ft-to-winner asset amount tx-sender))
    (map-set tokens-phase-3 { id: id } { claim: false})
    (print "Congrats")
  (ok true)))

;; Burn 5 NFTs / Phase 1
(define-public (burn-phase-1 (id1 uint) (id2 uint) (id3 uint) (id4 uint) (id5 uint))
  (begin
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-g1-phase1 get-owner id1) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-g1-phase1 get-owner id2) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-g1-phase1 get-owner id3) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-g1-phase1 get-owner id4) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-g1-phase1 get-owner id5) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (try! (contract-call? .skullcoin-competitive-g1-phase1 transfer id1 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-competitive-g1-phase1 transfer id2 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-competitive-g1-phase1 transfer id3 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-competitive-g1-phase1 transfer id4 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-competitive-g1-phase1 transfer id5 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-competitive-g1-phase2 mint tx-sender))
      (try! (contract-call? .skullcoin-competitive-g1-phase2 mint tx-sender))
      (ok true)))

;; Burn 5 NFTs / Phase 2
(define-public (burn-phase-2 (id1 uint) (id2 uint) (id3 uint) (id4 uint) (id5 uint))
  (begin
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-g1-phase2 get-owner id1) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-g1-phase2 get-owner id2) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-g1-phase2 get-owner id3) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-g1-phase2 get-owner id4) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-g1-phase2 get-owner id5) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (try! (contract-call? .skullcoin-competitive-g1-phase2 transfer id1 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-competitive-g1-phase2 transfer id2 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-competitive-g1-phase2 transfer id3 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-competitive-g1-phase2 transfer id4 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-competitive-g1-phase2 transfer id5 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-competitive-g1-phase3 mint tx-sender))
      (try! (contract-call? .skullcoin-competitive-g1-phase3 mint tx-sender))
      (ok true)))

;; Burn 5 NFTs / Phase 3
(define-public (burn-phase-3 (id1 uint) (id2 uint) (id3 uint) (id4 uint) (id5 uint))
  (begin
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-g1-phase3 get-owner id1) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-g1-phase3 get-owner id2) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-g1-phase3 get-owner id3) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-g1-phase3 get-owner id4) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-competitive-g1-phase3 get-owner id5) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (try! (contract-call? .skullcoin-competitive-g1-phase3 transfer id1 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-competitive-g1-phase3 transfer id2 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-competitive-g1-phase3 transfer id3 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-competitive-g1-phase3 transfer id4 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-competitive-g1-phase3 transfer id5 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-competitive-g1-phase4 mint tx-sender))
      (ok true)))

;; Internal - Claim NFT
(define-private (claim)
  (if (var-get wl-sale-active)
    (wl-mint tx-sender)
    (mint tx-sender)))

;; Internal - Mint NFT via whitelist
(define-private (wl-mint (new-owner principal))
  (let ((wl-balance (get-wl-balance new-owner)))
    (asserts! (> wl-balance u0) ERR-NO-WL-REMAINING)
    (map-set wl-count new-owner (- wl-balance u1))
    (try! (contract-call? .skullcoin-competitive-g1-phase1 mint new-owner))
    (ok true)))

;; Internal - Mint NFT via public
(define-private (mint (new-owner principal))
  (begin
    (asserts! (var-get sale-active) ERR-SALE-NOT-ACTIVE)
    (try! (contract-call? .skullcoin-competitive-g1-phase1 mint new-owner))
    (ok true)))

;; Internal - Send STX to winner player in claim function for treasure/chest/stx NFTs
(define-private (send-stx-to-winner (amount uint) (player principal))
  (begin
    (try! (as-contract (stx-transfer? amount tx-sender player)))
  (ok true)))

;; Internal - Send SIP-010 tokens to winner player in claim function for tokens NFTs
(define-private (send-ft-to-winner (asset <ft-trait>) (amount uint) (player principal))
  (begin
    (try! (as-contract (contract-call? asset transfer amount tx-sender player none)))
  (ok true)))

;; Internal - Pick id with RNG based on VRF
(define-private (pick-id)
  (let ((vrf (var-get last-vrf))
        (b-idx (var-get byte-id)))
    (if (is-eq (var-get last-block) block-height)
      (begin
        (asserts! (< b-idx u63) REACHED-BLOCK-PICK-LIMIT)
        (var-set picked-id (buff-to-uint-be (unwrap-panic (element-at vrf b-idx))))
        (var-set byte-id (+ b-idx u1))
        (ok (var-get picked-id)))
      (begin
        (set-vrf)
        (var-set last-block block-height)
        (var-set picked-id (buff-to-uint-be (unwrap-panic (element-at vrf b-idx))))
        (var-set byte-id u1)
        (ok (var-get picked-id))))))

;; Internal - Set VRF from previous block
(define-private (set-vrf)    
    (var-set last-vrf (sha512 (unwrap-panic (get-block-info? vrf-seed (- block-height u1))))))

;; Register this contract as allowed to mint
(as-contract (contract-call? .skullcoin-competitive-g1-phase1 set-mint-address))
(as-contract (contract-call? .skullcoin-competitive-g1-phase2 set-mint-address))
(as-contract (contract-call? .skullcoin-competitive-g1-phase3 set-mint-address))
(as-contract (contract-call? .skullcoin-competitive-g1-phase4 set-mint-address))
```
