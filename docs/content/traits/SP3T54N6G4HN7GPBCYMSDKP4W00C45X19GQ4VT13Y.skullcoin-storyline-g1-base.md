---
title: "Trait skullcoin-storyline-g1-base"
draft: true
---
```
;; Skullcoin | Storyline | Chapter #1 | v.1.0.0
;; skullco.in

;; Constants and Errors
(define-constant CONTRACT-OWNER tx-sender)
(define-constant BURN-WALLET 'SP5EDWN88FN8Q6A1MQ0N7SKKAG0VZ0ZQ9MFZ6RS8)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-SALE-NOT-ACTIVE (err u101))
(define-constant ERR-NOT-OWNER (err u102))
(define-constant ERR-NOT-TREASURE (err u103))
(define-constant REACHED-BLOCK-PICK-LIMIT (err u104))

;; Variables
(define-data-var sale-active bool false)
(define-data-var factor uint u1)
(define-data-var last-block uint u0)
(define-data-var byte-id uint u0)
(define-data-var picked-id uint u0)
(define-data-var last-vrf (buff 64) 0x00)

;; Maps
(define-map treasure-phase-1 { id: uint} {claim: bool})
(define-map treasure-phase-2 { id: uint} {claim: bool})
(define-map treasure-phase-3 { id: uint} {claim: bool})
(define-map treasure-phase-4 { id: uint} {claim: bool})
(define-map treasure-phase-5 { id: uint} {claim: bool})

;; Set public sale flag (only contract owner)
(define-public (flip-sale)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set sale-active (not (var-get sale-active)))
    (ok (var-get sale-active))))

;; Set factor (only contract owner)
(define-public (set-factor (value uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set factor value)
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

;; Send STX to player (only contract owner)
(define-public (send-stx (amount uint) (player principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (try! (as-contract (stx-transfer? amount tx-sender player)))
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

;; Set treasures ids / Phase 4 (only contract owner)
(define-public (set-treasure-phase-4 (nft-id uint) (status bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set treasure-phase-4 { id: nft-id } { claim: status})
  (ok true)))

;; Set treasures ids / Phase 5 (only contract owner)
(define-public (set-treasure-phase-5 (nft-id uint) (status bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set treasure-phase-5 { id: nft-id } { claim: status})
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

;; Claim treasure / Phase 1
(define-public (claim-treasure-phase-1 (id uint))
  (let ((fx (var-get factor)))
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase1 get-owner id) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
    (asserts! (is-eq (mod id u5) u0) ERR-NOT-TREASURE)
    (try! (pick-id))
        (if (is-eq (mod (var-get picked-id) u2) u0)
          (begin
            (asserts! (is-eq (get claim (unwrap-panic (map-get? treasure-phase-1 { id: id }))) true) ERR-NOT-TREASURE)
            (try! (send-stx-to-winner (* fx u1) tx-sender))
            (map-set treasure-phase-1 { id: id } { claim: false})
            (print "Congrats")
            (ok (var-get picked-id)))
          (begin
            (map-set treasure-phase-1 { id: id } { claim: false})
            (print "Not this time")
            (ok (var-get picked-id))))))

;; Claim treasure / Phase 2
(define-public (claim-treasure-phase-2 (id uint))
  (let ((fx (var-get factor)))
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase2 get-owner id) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
    (asserts! (is-eq (mod id u5) u0) ERR-NOT-TREASURE)
    (try! (pick-id))
        (if (is-eq (mod (var-get picked-id) u2) u0)
          (begin
            (asserts! (is-eq (get claim (unwrap-panic (map-get? treasure-phase-2 { id: id }))) true) ERR-NOT-TREASURE)
            (try! (send-stx-to-winner (* fx u2) tx-sender))
            (map-set treasure-phase-2 { id: id } { claim: false})
            (print "Congrats")
            (ok (var-get picked-id)))
          (begin
            (map-set treasure-phase-2 { id: id } { claim: false})
            (print "Not this time")
            (ok (var-get picked-id))))))

;; Claim treasure / Phase 3
(define-public (claim-treasure-phase-3 (id uint))
  (let ((fx (var-get factor)))
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase3 get-owner id) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
    (asserts! (is-eq (mod id u5) u0) ERR-NOT-TREASURE)
    (try! (pick-id))
        (if (is-eq (mod (var-get picked-id) u2) u0)
          (begin
            (asserts! (is-eq (get claim (unwrap-panic (map-get? treasure-phase-3 { id: id }))) true) ERR-NOT-TREASURE)
            (try! (send-stx-to-winner (* fx u3) tx-sender))
            (map-set treasure-phase-3 { id: id } { claim: false})
            (print "Congrats")
            (ok (var-get picked-id)))
          (begin
            (map-set treasure-phase-3 { id: id } { claim: false})
            (print "Not this time")
            (ok (var-get picked-id))))))

;; Claim treasure / Phase 4
(define-public (claim-treasure-phase-4 (id uint))
  (let ((fx (var-get factor)))
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase4 get-owner id) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
    (asserts! (is-eq (mod id u5) u0) ERR-NOT-TREASURE)
    (try! (pick-id))
        (if (is-eq (mod (var-get picked-id) u2) u0)
          (begin
            (asserts! (is-eq (get claim (unwrap-panic (map-get? treasure-phase-4 { id: id }))) true) ERR-NOT-TREASURE)
            (try! (send-stx-to-winner (* fx u4) tx-sender))
            (map-set treasure-phase-4 { id: id } { claim: false})
            (print "Congrats")
            (ok (var-get picked-id)))
          (begin
            (map-set treasure-phase-4 { id: id } { claim: false})
            (print "Not this time")
            (ok (var-get picked-id))))))

;; Claim treasure / Phase 5
(define-public (claim-treasure-phase-5 (id uint))
  (let ((fx (var-get factor)))
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase5 get-owner id) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
    (asserts! (is-eq (mod id u5) u0) ERR-NOT-TREASURE)
    (try! (pick-id))
        (if (is-eq (mod (var-get picked-id) u2) u0)
          (begin
            (asserts! (is-eq (get claim (unwrap-panic (map-get? treasure-phase-5 { id: id }))) true) ERR-NOT-TREASURE)
            (try! (send-stx-to-winner (* fx u5) tx-sender))
            (map-set treasure-phase-5 { id: id } { claim: false})
            (print "Congrats")
            (ok (var-get picked-id)))
          (begin
            (map-set treasure-phase-5 { id: id } { claim: false})
            (print "Not this time")
            (ok (var-get picked-id))))))

;; Burn 5 NFTs / Phase 1
(define-public (burn-phase-1 (id1 uint) (id2 uint) (id3 uint) (id4 uint) (id5 uint))
  (begin
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase1 get-owner id1) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase1 get-owner id2) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase1 get-owner id3) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase1 get-owner id4) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase1 get-owner id5) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (try! (contract-call? .skullcoin-storyline-g1-phase1 transfer id1 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-storyline-g1-phase1 transfer id2 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-storyline-g1-phase1 transfer id3 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-storyline-g1-phase1 transfer id4 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-storyline-g1-phase1 transfer id5 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-storyline-g1-phase2 mint tx-sender))
      (try! (contract-call? .skullcoin-storyline-g1-phase2 mint tx-sender))
      (try! (contract-call? .skullcoin-storyline-g1-phase2 mint tx-sender))
      (try! (contract-call? .skullcoin-storyline-g1-phase2 mint tx-sender))
      (try! (contract-call? .skullcoin-storyline-g1-phase2 mint tx-sender))
      (ok true)))

;; Burn 5 NFTs / Phase 2
(define-public (burn-phase-2 (id1 uint) (id2 uint) (id3 uint) (id4 uint) (id5 uint))
  (begin
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase2 get-owner id1) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase2 get-owner id2) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase2 get-owner id3) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase2 get-owner id4) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase2 get-owner id5) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (try! (contract-call? .skullcoin-storyline-g1-phase2 transfer id1 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-storyline-g1-phase2 transfer id2 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-storyline-g1-phase2 transfer id3 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-storyline-g1-phase2 transfer id4 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-storyline-g1-phase2 transfer id5 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-storyline-g1-phase3 mint tx-sender))
      (try! (contract-call? .skullcoin-storyline-g1-phase3 mint tx-sender))
      (try! (contract-call? .skullcoin-storyline-g1-phase3 mint tx-sender))
      (try! (contract-call? .skullcoin-storyline-g1-phase3 mint tx-sender))
      (try! (contract-call? .skullcoin-storyline-g1-phase3 mint tx-sender))
      (ok true)))

;; Burn 5 NFTs / Phase 3
(define-public (burn-phase-3 (id1 uint) (id2 uint) (id3 uint) (id4 uint) (id5 uint))
  (begin
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase3 get-owner id1) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase3 get-owner id2) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase3 get-owner id3) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase3 get-owner id4) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase3 get-owner id5) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (try! (contract-call? .skullcoin-storyline-g1-phase3 transfer id1 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-storyline-g1-phase3 transfer id2 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-storyline-g1-phase3 transfer id3 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-storyline-g1-phase3 transfer id4 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-storyline-g1-phase3 transfer id5 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-storyline-g1-phase4 mint tx-sender))
      (try! (contract-call? .skullcoin-storyline-g1-phase4 mint tx-sender))
      (try! (contract-call? .skullcoin-storyline-g1-phase4 mint tx-sender))
      (try! (contract-call? .skullcoin-storyline-g1-phase4 mint tx-sender))
      (try! (contract-call? .skullcoin-storyline-g1-phase4 mint tx-sender))
      (ok true)))

;; Burn 5 NFTs / Phase 4
(define-public (burn-phase-4 (id1 uint) (id2 uint) (id3 uint) (id4 uint) (id5 uint))
  (begin
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase4 get-owner id1) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase4 get-owner id2) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase4 get-owner id3) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase4 get-owner id4) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase4 get-owner id5) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (try! (contract-call? .skullcoin-storyline-g1-phase4 transfer id1 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-storyline-g1-phase4 transfer id2 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-storyline-g1-phase4 transfer id3 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-storyline-g1-phase4 transfer id4 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-storyline-g1-phase4 transfer id5 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-storyline-g1-phase5 mint tx-sender))
      (try! (contract-call? .skullcoin-storyline-g1-phase5 mint tx-sender))
      (try! (contract-call? .skullcoin-storyline-g1-phase5 mint tx-sender))
      (try! (contract-call? .skullcoin-storyline-g1-phase5 mint tx-sender))
      (try! (contract-call? .skullcoin-storyline-g1-phase5 mint tx-sender))
      (ok true)))

;; Burn 5 NFTs / Phase 5
(define-public (burn-phase-5 (id1 uint) (id2 uint) (id3 uint) (id4 uint) (id5 uint))
  (begin
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase5 get-owner id1) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase5 get-owner id2) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase5 get-owner id3) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase5 get-owner id4) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? .skullcoin-storyline-g1-phase5 get-owner id5) ERR-NOT-OWNER) ERR-NOT-OWNER) tx-sender) ERR-NOT-OWNER)
      (try! (contract-call? .skullcoin-storyline-g1-phase5 transfer id1 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-storyline-g1-phase5 transfer id2 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-storyline-g1-phase5 transfer id3 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-storyline-g1-phase5 transfer id4 tx-sender BURN-WALLET))
      (try! (contract-call? .skullcoin-storyline-g1-phase5 transfer id5 tx-sender BURN-WALLET))
      (ok true)))

;; Claim NFT
(define-private (claim)
  (begin
    (mint tx-sender)))

;; Internal - Mint NFT
(define-private (mint (new-owner principal))
  (begin
    (asserts! (var-get sale-active) ERR-SALE-NOT-ACTIVE)
    (try! (contract-call? .skullcoin-storyline-g1-phase1 mint new-owner))
    (ok true)))

;; Send STX to winner player in claim treasure function
(define-private (send-stx-to-winner (amount uint) (player principal))
  (begin
    (try! (as-contract (stx-transfer? amount tx-sender player)))
  (ok true)))

;; Pick id with RNG based on VRF
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

;; Set VRF from previous block
(define-private (set-vrf)    
    (var-set last-vrf (sha512 (unwrap-panic (get-block-info? vrf-seed (- block-height u1))))))

;; Register this contract as allowed to mint
(as-contract (contract-call? .skullcoin-storyline-g1-phase1 set-mint-address))
(as-contract (contract-call? .skullcoin-storyline-g1-phase2 set-mint-address))
(as-contract (contract-call? .skullcoin-storyline-g1-phase3 set-mint-address))
(as-contract (contract-call? .skullcoin-storyline-g1-phase4 set-mint-address))
(as-contract (contract-call? .skullcoin-storyline-g1-phase5 set-mint-address))
```
