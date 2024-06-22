---
title: "Trait data-core-v1"
draft: true
---
```
;; @contract Data Core
;; @version 1
;;
;; Helper methods to get STX per stSTX.
;; Storing withdrawal offset & withdrawal NFT info.

(use-trait reserve-trait .reserve-trait-v1.reserve-trait)

;;-------------------------------------
;; STX per stSTX  
;;-------------------------------------

(define-public (get-stx-per-ststx (reserve-contract <reserve-trait>))
  (let (
    (stx-amount (try! (contract-call? reserve-contract get-total-stx)))
  )
    (try! (contract-call? .dao check-is-protocol (contract-of reserve-contract)))
    (ok (get-stx-per-ststx-helper stx-amount))
  )
)

(define-read-only (get-stx-per-ststx-helper (stx-amount uint))
  (let (
    (ststx-supply (unwrap-panic (contract-call? .ststx-token get-total-supply)))
  )
    (if (is-eq ststx-supply u0)
      u1000000
      (/ (* stx-amount u1000000) ststx-supply)
    )
  )
)

;;-------------------------------------
;; Cycle Withdraw Offset
;;-------------------------------------

;; In the last X blocks of the cycle
(define-data-var cycle-withdraw-offset uint u288) ;; 2 days

(define-read-only (get-cycle-withdraw-offset)
  (var-get cycle-withdraw-offset)
)

(define-public (set-cycle-withdraw-offset (offset uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (var-set cycle-withdraw-offset offset)
    (ok true)
  )
)

;;-------------------------------------
;; Withdrawal NFT 
;;-------------------------------------

(define-map migrated-nfts uint bool)

(define-map withdrawals-by-nft
  { 
    nft-id: uint
  }
  {
    unlock-burn-height: uint, 
    stx-amount: uint,
    ststx-amount: uint
  }
)

(define-read-only (get-migrated-nft (nft-id uint))
  (default-to
    false
    (map-get? migrated-nfts nft-id)
  )
)

(define-read-only (get-withdrawals-by-nft (nft-id uint))
  (default-to
    (if (get-migrated-nft nft-id)
      ;; Already migrated
      {
        unlock-burn-height: u0,
        stx-amount: u0,
        ststx-amount: u0
      }

      ;; Default to info from stacking-dao-core-v1.
      (let (
        (prev-info (contract-call? .stacking-dao-core-v1 get-withdrawals-by-nft nft-id))
        (cycle-start-block (if (> (get cycle-id prev-info) u0)
          ;; Need to translate cycle-id into unlock-burn-height
          (reward-cycle-to-burn-height (get cycle-id prev-info))
          u0
        ))
      )
        { unlock-burn-height: cycle-start-block, stx-amount: (get stx-amount prev-info), ststx-amount: (get ststx-amount prev-info) }
      )
    )

    (map-get? withdrawals-by-nft { nft-id: nft-id })
  )
)

(define-public (set-withdrawals-by-nft (nft-id uint) (stx-amount uint) (ststx-amount uint) (unlock-burn-height uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (map-set migrated-nfts nft-id true)
    (map-set withdrawals-by-nft { nft-id: nft-id } { stx-amount: stx-amount, ststx-amount: ststx-amount, unlock-burn-height: unlock-burn-height })

    (print { action: "set-withdrawals-by-nft", data: { nft-id: nft-id, stx-amount: stx-amount, ststx-amount: ststx-amount, unlock-burn-height: unlock-burn-height, block-height: block-height } })
    (ok true)
  )
)

(define-public (delete-withdrawals-by-nft (nft-id uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (map-set migrated-nfts nft-id true)
    (map-delete withdrawals-by-nft { nft-id: nft-id })

    (print { action: "delete-withdrawals-by-nft", data: { nft-id: nft-id, block-height: block-height } })
    (ok true)
  )
)

;;-------------------------------------
;; PoX Helpers
;;-------------------------------------

(define-read-only (reward-cycle-to-burn-height (cycle-id uint)) 
  (contract-call? 'SP000000000000000000002Q6VF78.pox-4 reward-cycle-to-burn-height cycle-id)
)

```
