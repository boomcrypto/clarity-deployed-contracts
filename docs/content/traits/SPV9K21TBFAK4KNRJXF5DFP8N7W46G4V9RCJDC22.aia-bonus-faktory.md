---
title: "Trait aia-bonus-faktory"
draft: true
---
```

      ;; 2357e40948e588d7d476709cf7af500eac32dc25a11e7fb547f7a2d1b5c9dfd1
      ;; Simple contract to lock meme creator bonus for 9 months
      
      (use-trait faktory-token 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.faktory-trait-v1.sip-010-trait)
      
      (define-constant ERR-NOT-AUTHORIZED (err u305))
      (define-constant ERR-INVALID-TOKEN (err u404))
      (define-constant ERR-ALREADY-CLAIMED (err u401))
      (define-constant ERR-LOCK-PERIOD (err u400))
      
      (define-constant DEX-DAO 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.aia-faktory-dex)
      (define-constant TOKEN-DAO 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.aia-faktory)
      
      (define-constant LOCK_PERIOD u38880)
      (define-constant FAKTORY 'SMH8FRN30ERW1SX26NJTJCKTDR3H27NRJ6W75WQE)
      (define-constant ORIGINATOR 'SP3MZAPFZEA9MZHBCGHG3TYKNFGDMNF5FW9RZ3AXS)
      
      (define-data-var agent-claim-status bool false)
      (define-data-var originator-claim-status bool false)
      (define-data-var deposit-height uint u0)
      (define-data-var agent-amount uint u0)
      (define-data-var originator-amount uint u0)
      
      ;; Function to deposit rewards (called by DEX contract)
      (define-public (deposit-bonus (new-agent-amount uint) (new-originator-amount uint))
        (begin
          (asserts! (is-eq contract-caller DEX-DAO) ERR-NOT-AUTHORIZED)
          (var-set deposit-height burn-block-height) 
          (var-set agent-amount new-agent-amount)
          (var-set originator-amount new-originator-amount)
          (ok true)
        )
      )
      
      ;; Function for agent to claim their rewards after lock period
      (define-public (claim-agent-bonus (ft <faktory-token>))
        (begin
          (asserts! (is-eq (contract-of ft) TOKEN-DAO) ERR-INVALID-TOKEN)
          (asserts! (not (var-get agent-claim-status)) ERR-ALREADY-CLAIMED)
          (asserts! (>= burn-block-height (+ (var-get deposit-height) LOCK_PERIOD)) ERR-LOCK-PERIOD)
          (try! (as-contract (contract-call? ft transfer (var-get agent-amount) tx-sender FAKTORY none)))
          (var-set agent-claim-status true)
          (ok true)
        )
      )
      
      ;; Function for originator to claim their rewards after lock period
      (define-public (claim-originator-bonus (ft <faktory-token>))
        (begin
          (asserts! (is-eq (contract-of ft) TOKEN-DAO) ERR-INVALID-TOKEN)
          (asserts! (not (var-get originator-claim-status)) ERR-ALREADY-CLAIMED)
          (asserts! (>= burn-block-height (+ (var-get deposit-height) LOCK_PERIOD)) ERR-LOCK-PERIOD)
          (try! (as-contract (contract-call? ft transfer (var-get originator-amount) tx-sender ORIGINATOR none)))
          (var-set originator-claim-status true)
          (ok true)
        )
      )
      
      ;; Read-only function to check if rewards are claimable for agent
      (define-read-only (get-agent-status)
        (let
          (
            (claimed (var-get agent-claim-status))
            (deposit-h (var-get deposit-height))
            (amount (var-get agent-amount))
            (unlock-height (+ deposit-h LOCK_PERIOD))
            (claimable (and (> amount u0) (>= burn-block-height unlock-height) (not claimed)))
          )
          {
            deposit-amount: amount,
            deposit-block: deposit-h,
            unlock-block: unlock-height,
            blocks-remaining: (if (>= burn-block-height unlock-height) 
                                 u0 
                                 (- unlock-height burn-block-height)),
            claimed: claimed,
            claimable: claimable
          }
        )
      )
      
      ;; Read-only function to check if rewards are claimable for originator
      (define-read-only (get-originator-status)
        (let
          (
            (claimed (var-get originator-claim-status))
            (deposit-h (var-get deposit-height))
            (amount (var-get originator-amount))
            (unlock-height (+ deposit-h LOCK_PERIOD))
            (claimable (and (> amount u0) (>= burn-block-height unlock-height) (not claimed)))
          )
          {
            deposit-amount: amount,
            deposit-block: deposit-h,
            unlock-block: unlock-height,
            blocks-remaining: (if (>= burn-block-height unlock-height) 
                                 u0 
                                 (- unlock-height burn-block-height)),
            claimed: claimed,
            claimable: claimable
          }
        )
      )
      
      (define-read-only (get-info)
        {
          lock-period: LOCK_PERIOD,
          agent-address: FAKTORY,
          originator-address: ORIGINATOR,
          deposit-height: (var-get deposit-height)
        }
      )
```
