---
title: "Trait nakamoto-info"
draft: true
---
```
;; Expose info for stacks blocks, tenures and burn blocks so they can be used outside of smart contracts.
;; @version 1

(define-read-only (get-block-info-time (stx-height uint))
  (get-stacks-block-info? time stx-height))

(define-read-only (get-block-info-id-header-hash (stx-height uint))
  (get-stacks-block-info? id-header-hash stx-height))

(define-read-only (get-block-info-header-hash (stx-height uint))
  (get-stacks-block-info? header-hash stx-height))

;; tenure info
(define-read-only (get-tenure-info-burnchain-header-hash (stx-height uint))
  (get-tenure-info? burnchain-header-hash stx-height))

(define-read-only (get-tenure-info-miner-address (stx-height uint))
  (get-tenure-info? miner-address stx-height))

(define-read-only (get-tenure-info-time (stx-height uint))
  (get-tenure-info? time stx-height))

(define-read-only (get-tenure-info-vrf-seed (stx-height uint))
  (get-tenure-info? vrf-seed stx-height))

(define-read-only (get-tenure-info-block-reward (stx-height uint))
  (get-tenure-info? block-reward stx-height))

(define-read-only (get-tenure-info-miner-spend-total (stx-height uint))
  (get-tenure-info? miner-spend-total stx-height))

(define-read-only (get-tenure-info-miner-spend-winner (stx-height uint))
  (get-tenure-info? miner-spend-winner stx-height))

;; burn chain info
(define-read-only (get-burn-block-info-header-hash (burn-height uint))
  (get-burn-block-info? header-hash burn-height))

(define-read-only (get-burn-block-info-pox-addrs (burn-height uint))
  (get-burn-block-info? pox-addrs burn-height))

```
