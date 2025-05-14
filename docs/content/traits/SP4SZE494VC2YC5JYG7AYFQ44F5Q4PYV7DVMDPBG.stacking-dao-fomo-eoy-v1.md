---
title: "Trait stacking-dao-fomo-eoy-v1"
draft: true
---
```
;; @contract FOMO EOY
;; @version 1
;; @desc
;; Treasure hunt on Stacks
;; 1/ In Stacking DAO FOMO, the claims have a linearly increasing price.
;; The claim price starts at 10 stSTX and increases by 1 stSTX with each claim.
;; The game stops if there's no claim for 24 hours.
;; The final key claimer (also called Master Key holder) unlocks the treasure vault.
;; 2/ Timer - The game has a built-in timer that counts down from 24 hours to 0.
;; Each key claim resets the timer to 24 hours.
;; Once the countdown elapses, the master key holder unlocks the grand prize.
;; 3/ When a key using stSTX is claimed, the funds are stored on the contract and allocated as follows:
;; - 70% goes to the winner prize pool [the last key claimer]
;; - 25% goes to the pool [all claim holders can burn their claim and claim the average of the pool]
;; - 5% goes to the protocol

;;-------------------------------------
;; Constants 
;;-------------------------------------

(define-constant ERR_GAME_NOT_STARTED u6660000)
(define-constant ERR_GAME_ENDED u6660001)
(define-constant ERR_CANNOT_CLAIM u6660002)
(define-constant ERR_GAME_NOT_ENDED u6660003)
(define-constant ERR_CLAIMER_NOT_WINNER u6660004)
(define-constant ERR_FEES_CLAIMED u6660005)
(define-constant ERR_WINNER_ALREADY_CLAIMED u6660006)

;;-------------------------------------
;; Variables 
;;-------------------------------------

(define-data-var current-winner principal tx-sender)
(define-data-var claim-cost uint u10000000) ;; 10 stSTX
(define-data-var increment uint u1000000) ;; 1 stSTX increments
(define-data-var last-claim-burn-block-height uint burn-block-height)
(define-data-var nft-amount uint u0)
(define-data-var total-treasure uint u100000000)
(define-data-var has-claimed-fees bool false)
(define-data-var has-claimed-winner bool false)
(define-data-var game-started bool false)

;;-------------------------------------
;; Getters 
;;-------------------------------------

(define-read-only (get-current-winner)
  (var-get current-winner)
)

(define-read-only (get-claim-cost)
  (var-get claim-cost)
)

(define-read-only (get-increment)
  (var-get increment)
)

(define-read-only (get-total-treasure)
  (var-get total-treasure)
)

(define-read-only (get-last-claim-burn-block-height)
  (var-get last-claim-burn-block-height)
)

(define-read-only (has-game-started)
  (var-get game-started)
)

(define-read-only (has-game-ended)
  (and (var-get game-started) (> burn-block-height (+ (var-get last-claim-burn-block-height) u144)))
)

;;-------------------------------------
;; Set 
;;-------------------------------------

(define-public (set-claim-cost (amount uint))
  (begin
    (try! (contract-call? .dao check-is-protocol tx-sender))

    (var-set claim-cost amount)
    (ok true)
  )
)

(define-public (set-increment (amount uint))
  (begin
    (try! (contract-call? .dao check-is-protocol tx-sender))

    (var-set increment amount)
    (ok true)
  )
)

(define-public (set-total-treasure (amount uint))
  (begin
    (try! (contract-call? .dao check-is-protocol tx-sender))

    (var-set total-treasure amount)
    (ok true)
  )
)

;;-------------------------------------
;; Main Logic
;;-------------------------------------

(define-public (buy-claim)
  (let (
    (next-claim-cost (+ (var-get claim-cost) (var-get increment)))
  )
    (asserts! (has-game-started) (err ERR_GAME_NOT_STARTED))
    (asserts! (not (has-game-ended)) (err ERR_GAME_ENDED))

    (try! (contract-call? .ststx-token transfer next-claim-cost tx-sender (as-contract tx-sender) none))
    (var-set current-winner tx-sender)
    (var-set claim-cost next-claim-cost)
    (var-set last-claim-burn-block-height burn-block-height)

    (try! (contract-call? .stacking-dao-fomo-eoy-nft mint-for-protocol tx-sender))
    (var-set nft-amount (+ (var-get nft-amount) u1))
    (var-set total-treasure (+ (var-get total-treasure) next-claim-cost))
    (ok true)
  )
)

(define-public (retrieve-winner (nft-id uint))
  (let (
    (ststx-balance (var-get total-treasure))
    (amount (/ (* ststx-balance u5000) u10000))
    (winner tx-sender)
  )
    (asserts! (has-game-ended) (err ERR_GAME_NOT_ENDED))
    (asserts! (is-eq (var-get current-winner) tx-sender) (err ERR_CLAIMER_NOT_WINNER))
    (asserts! (not (var-get has-claimed-winner)) (err ERR_WINNER_ALREADY_CLAIMED))

    (try! (as-contract (contract-call? .ststx-token transfer amount tx-sender winner none)))
    (try! (contract-call? .stacking-dao-fomo-eoy-nft burn-for-protocol nft-id))
    (var-set has-claimed-winner true)
    (ok amount)
  )
)

(define-public (retrieve-loser (nft-id uint))
  (let (
    (ststx-balance (var-get total-treasure))
    (amount (/ (* ststx-balance u4500) u10000))
    (loser tx-sender)
    (avg (/ amount (- (var-get nft-amount) u1)))
  )
    (asserts! (has-game-ended) (err ERR_GAME_NOT_ENDED))

    (try! (as-contract (contract-call? .ststx-token transfer avg tx-sender loser none)))
    (try! (contract-call? .stacking-dao-fomo-eoy-nft burn-for-protocol nft-id))
    (ok avg)
  )
)

;;-------------------------------------
;; Admin
;;-------------------------------------

(define-public (start-game)
  (begin
    (try! (contract-call? .dao check-is-protocol tx-sender))

    (var-set game-started true)
    (var-set last-claim-burn-block-height burn-block-height)
    (ok true)
  )
)

(define-public (retrieve-fees)
  (let (
    (ststx-balance (var-get total-treasure))
    (amount (/ (* ststx-balance u500) u10000))
    (admin tx-sender)
  )
    (try! (contract-call? .dao check-is-protocol tx-sender))
    (asserts! (has-game-ended) (err ERR_GAME_NOT_ENDED))
    (asserts! (not (var-get has-claimed-fees)) (err ERR_FEES_CLAIMED))

    (try! (as-contract (contract-call? .ststx-token transfer amount tx-sender admin none)))
    (var-set has-claimed-fees true)
    (ok amount)
  )
)

(define-public (rescue-funds)
  (let (
    (ststx-balance (unwrap-panic (contract-call? .ststx-token get-balance (as-contract tx-sender))))
    (admin tx-sender)
  )
    (try! (contract-call? .dao check-is-protocol tx-sender))

    (try! (as-contract (contract-call? .ststx-token transfer ststx-balance tx-sender admin none)))
    (ok ststx-balance)
  )
)

```
