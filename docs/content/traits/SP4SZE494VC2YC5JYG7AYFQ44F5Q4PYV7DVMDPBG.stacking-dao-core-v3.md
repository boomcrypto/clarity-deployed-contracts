---
title: "Trait stacking-dao-core-v3"
draft: true
---
```
;; @contract Core
;; @version 3
;;
;; Core contract for the user to interact with (deposit, withdraw)

(use-trait reserve-trait .reserve-trait-v1.reserve-trait)
(use-trait direct-helpers-trait .direct-helpers-trait-v1.direct-helpers-trait)
(use-trait staking-trait .staking-trait-v1.staking-trait)
(use-trait commission-trait .commission-trait-v1.commission-trait)

;;-------------------------------------
;; Constants 
;;-------------------------------------

(define-constant ERR_WITHDRAW_LOCKED u204001)
(define-constant ERR_SHUTDOWN u204002)
(define-constant ERR_WITHDRAW_NOT_NFT_OWNER u204003)
(define-constant ERR_WITHDRAW_NFT_DOES_NOT_EXIST u204004)
(define-constant ERR_GET_OWNER u204005)
(define-constant ERR_WITHDRAW_CANCEL u204006)
(define-constant ERR_WRONG_BPS u204007)

(define-constant DENOMINATOR_6 u1000000)
(define-constant DENOMINATOR_BPS u10000)

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var shutdown-deposits bool false)
(define-data-var stack-fee uint u0) ;; in bps
(define-data-var unstack-fee uint u0) ;; in bps

;;-------------------------------------
;; Getters 
;;-------------------------------------

(define-read-only (get-shutdown-deposits)
  (var-get shutdown-deposits)
)

(define-read-only (get-stack-fee)
  (var-get stack-fee)
)

(define-read-only (get-unstack-fee)
  (var-get unstack-fee)
)

(define-read-only (get-withdraw-unlock-burn-height)
  (let (
    (current-cycle (current-pox-reward-cycle))
    (start-block-next-cycle (reward-cycle-to-burn-height (+ current-cycle u1)))
    (withdraw-offset (contract-call? .data-core-v1 get-cycle-withdraw-offset))
  )
    (if (< burn-block-height (- start-block-next-cycle withdraw-offset))
      ;; Can withdraw next cycle
      (ok start-block-next-cycle)

      ;; Withdraw cycle after next
      (ok (+ start-block-next-cycle (get-reward-cycle-length)))
    )
  )
)

;;-------------------------------------
;; User  
;;-------------------------------------

;; Deposit STX for stSTX
(define-public (deposit 
  (reserve <reserve-trait>) 
  (commission-contract <commission-trait>) 
  (staking-contract <staking-trait>) 
  (direct-helpers <direct-helpers-trait>)
  (stx-amount uint)
  (referrer (optional principal)) 
  (pool (optional principal))
)
  (let (
    (stx-fee-amount (/ (* (get-stack-fee) stx-amount) DENOMINATOR_BPS))
    (stx-user-amount (- stx-amount stx-fee-amount))

    (stx-ststx (try! (contract-call? .data-core-v1 get-stx-per-ststx reserve)))
    (ststx-amount (/ (* stx-user-amount DENOMINATOR_6) stx-ststx))
  )
    (try! (contract-call? .dao check-is-enabled))
    (try! (contract-call? .dao check-is-protocol (contract-of reserve)))
    (try! (contract-call? .dao check-is-protocol (contract-of commission-contract)))
    (try! (contract-call? .dao check-is-protocol (contract-of staking-contract)))
    (try! (contract-call? .dao check-is-protocol (contract-of direct-helpers)))
    (asserts! (not (get-shutdown-deposits)) (err ERR_SHUTDOWN))

    (try! (contract-call? direct-helpers add-direct-stacking tx-sender pool stx-user-amount))

    ;; User
    (try! (stx-transfer? stx-user-amount tx-sender (contract-of reserve)))
    (try! (contract-call? .ststx-token mint-for-protocol ststx-amount tx-sender))

    ;; Fee
    (if (> stx-fee-amount u0)
      (begin
        (try! (stx-transfer? stx-fee-amount tx-sender (as-contract tx-sender)))
        (try! (as-contract (contract-call? commission-contract add-commission staking-contract stx-fee-amount)))
      )
      u0
    )

    (print { action: "deposit", data: { stacker: tx-sender, stx-amount: stx-amount, stxstx-amount: ststx-amount, referrer: referrer, pool: pool, block-height: block-height } })
    (ok ststx-amount)
  )
)

;; Initiate withdrawal, given stSTX amount. Can update amount as long as cycle not started.
;; The stSTX tokens are transferred to this contract, and are burned on the actual withdrawal.
;; An NFT is minted for the user as a token representation of the withdrawal.
(define-public (init-withdraw 
  (reserve <reserve-trait>) 
  (direct-helpers <direct-helpers-trait>)
  (ststx-amount uint)
)
  (let (
    (sender tx-sender)
    (unlock-burn-height (unwrap-panic (get-withdraw-unlock-burn-height)))

    (stx-ststx (try! (contract-call? .data-core-v1 get-stx-per-ststx reserve)))
    (stx-amount (/ (* ststx-amount stx-ststx) DENOMINATOR_6))

    (nft-id (unwrap-panic (contract-call? .ststx-withdraw-nft-v2 get-last-token-id)))
  )
    (try! (contract-call? .dao check-is-enabled))
    (try! (contract-call? .dao check-is-protocol (contract-of reserve)))
    (try! (contract-call? .dao check-is-protocol (contract-of direct-helpers)))

    (try! (contract-call? .data-core-v1 set-withdrawals-by-nft nft-id stx-amount ststx-amount unlock-burn-height))
    
    (try! (contract-call? direct-helpers subtract-direct-stacking tx-sender stx-amount))

    ;; Transfer stSTX token to contract, only burn on actual withdraw
    (try! (as-contract (contract-call? reserve lock-stx-for-withdrawal stx-amount)))
    (try! (contract-call? .ststx-token transfer ststx-amount tx-sender (as-contract tx-sender) none))
    (try! (as-contract (contract-call? .ststx-withdraw-nft-v2 mint-for-protocol sender)))

    (print { action: "init-withdraw", data: { stacker: tx-sender, nft-id: nft-id, ststx-amount: ststx-amount, stx-amount: stx-amount, block-height: block-height } })
    (ok nft-id)
  )
)

;; Actual withdrawal for given NFT. 
;; The NFT and stSTX tokens will be burned and the user will receive STX tokens.
(define-public (withdraw 
  (reserve <reserve-trait>)
  (commission-contract <commission-trait>) 
  (staking-contract <staking-trait>) 
  (nft-id uint)
)
  (let (
    (receiver tx-sender)

    (withdrawal-entry (contract-call? .data-core-v1 get-withdrawals-by-nft nft-id))
    (unlock-burn-height (get unlock-burn-height withdrawal-entry))
    (stx-amount (get stx-amount withdrawal-entry))
    (ststx-amount (get ststx-amount withdrawal-entry))

    (nft-owner (unwrap! (contract-call? .ststx-withdraw-nft-v2 get-owner nft-id) (err ERR_GET_OWNER)))

    (stx-fee-amount (/ (* (get-unstack-fee) stx-amount) DENOMINATOR_BPS))
    (stx-user-amount (- stx-amount stx-fee-amount))
  )
    (try! (contract-call? .dao check-is-enabled))
    (try! (contract-call? .dao check-is-protocol (contract-of reserve)))
    (try! (contract-call? .dao check-is-protocol (contract-of commission-contract)))
    (try! (contract-call? .dao check-is-protocol (contract-of staking-contract)))
    (asserts! (is-some nft-owner) (err ERR_WITHDRAW_NFT_DOES_NOT_EXIST))
    (asserts! (is-eq (unwrap! nft-owner (err ERR_GET_OWNER)) tx-sender) (err ERR_WITHDRAW_NOT_NFT_OWNER))
    (asserts! (>= burn-block-height unlock-burn-height) (err ERR_WITHDRAW_LOCKED))

    (try! (contract-call? .data-core-v1 delete-withdrawals-by-nft nft-id))

    ;; STX to user, burn stSTX
    (try! (as-contract (contract-call? reserve request-stx-for-withdrawal stx-user-amount receiver)))
    (try! (contract-call? .ststx-token burn-for-protocol (get ststx-amount withdrawal-entry) (as-contract tx-sender)))
    (try! (as-contract (contract-call? .ststx-withdraw-nft-v2 burn-for-protocol nft-id)))

    ;; Fee
    (if (> stx-fee-amount u0)
      (begin
        (try! (as-contract (contract-call? reserve request-stx-for-withdrawal stx-fee-amount tx-sender)))
        (try! (as-contract (contract-call? commission-contract add-commission staking-contract stx-fee-amount)))
      )
      u0
    )

    (print { action: "withdraw", data: { stacker: tx-sender, ststx-amount: ststx-amount, stx-amount: stx-amount, block-height: block-height } })
    (ok { stx-user-amount: stx-user-amount, stx-fee-amount: stx-fee-amount})
  )
)

;;-------------------------------------
;; Admin
;;-------------------------------------

(define-public (set-shutdown-deposits (shutdown bool))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))
    
    (var-set shutdown-deposits shutdown)
    (ok true)
  )
)

(define-public (set-stack-fee (fee uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))
    (asserts! (<= fee DENOMINATOR_BPS) (err ERR_WRONG_BPS))

    (var-set stack-fee fee)
    (ok true)
  )
)

(define-public (set-unstack-fee (fee uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))
    (asserts! (<= fee DENOMINATOR_BPS) (err ERR_WRONG_BPS))

    (var-set unstack-fee fee)
    (ok true)
  )
)

;;-------------------------------------
;; PoX Helpers
;;-------------------------------------

(define-read-only (current-pox-reward-cycle) 
  (contract-call? 'SP000000000000000000002Q6VF78.pox-4 current-pox-reward-cycle)
)

(define-read-only (reward-cycle-to-burn-height (cycle-id uint)) 
  (contract-call? 'SP000000000000000000002Q6VF78.pox-4 reward-cycle-to-burn-height cycle-id)
)

(define-read-only (get-reward-cycle-length)
  (get reward-cycle-length (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.pox-4 get-pox-info)))
)


;;-------------------------------------
;; Migrate stSTX from V1
;;-------------------------------------

(define-public (migrate-ststx)
  (let (
    (balance-v1 (unwrap-panic (contract-call? .ststx-token get-balance .stacking-dao-core-v1)))
  )
    (try! (contract-call? .dao check-is-protocol contract-caller))
    
    (try! (contract-call? .ststx-token burn-for-protocol balance-v1 .stacking-dao-core-v1))
    (try! (contract-call? .ststx-token mint-for-protocol balance-v1 (as-contract tx-sender)))

    (ok true)
  )
)

```
