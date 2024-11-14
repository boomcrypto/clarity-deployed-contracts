---
title: "Trait arkadiko-stx-diko-pool-v2-1"
draft: true
---
```
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant ERR-TOKEN-TRANSFER (err u108))
(define-constant ERR-GET-PAIR-BALANCE (err u109))
(define-constant ERR-GET-LP-BALANCE (err u110))
(define-constant ERR-GET-REAP-SUPPLY (err u111))
(define-constant ERR-GET-REAP-BALANCE (err u113))
(define-constant ERR-LP-WITHDRAWL (err u116))
(define-constant ERR-GET-WITHDRAWL-PAIR (err u117))
(define-constant ERR-NOT-OWNER (err u118))
(define-constant ERR-FEE-TOO-HIGH (err u119))
(define-constant ERR-SWAP-TOKENS-ARKADIKO (err u121))
(define-constant ERR-SWAP-TOKENS-ALEX (err u122))
(define-constant ERR-NO-LP-TOKENS (err u123))
(define-constant ERR-POOL-BALANCE-0 (err u124))
(define-constant ERR-INSUFFICIENT-REAP-BALANCE (err u125))
(define-constant ERR-WRONG-UNSTAKE-MODE (err u126))
(define-constant ERR-INSUFFICIENT-REWARDS (err u127))
(define-constant ERR-WRONG-SWAP-PERCENT (err u128))
(define-constant ERR-WRONG-UNSTAKE-ORDER (err u129))
(define-constant ERR-UNSTAKE-LOCKED (err u130))
(define-constant ERR-WRONG-ORDER-USER (err u131))

(define-constant ONE_8 u100000000)

;; UNSTAKE ENUM for choosing which tokens are returned to user
(define-constant UNSTAKE_LP u0)
(define-constant UNSTAKE_PAIR u1)
(define-constant UNSTAKE_STX u2)
(define-constant UNSTAKE_DIKO u3)

;; default fee is 0.3%
(define-data-var fee-percent uint u30000000)

;; Max possible fee is 2%
(define-constant MAX_FEE u200000000)

;; default swap percent is 47%
(define-data-var swap-percent uint u470)
;; swap percent range is 45% - 55%
(define-constant MIN_SWAP_PERCENT u450)
(define-constant MAX_SWAP_PERCENT u550)

;; about a week worth of block assuming avg stack block to be 10 minutes
(define-constant UNSTAKE_LOCK_PERIOD u800)


(define-data-var fee-recipient principal tx-sender)
(define-data-var contract-owner principal tx-sender)

(define-map unstake-orders uint { reap-amount: uint, created-block: uint, user: principal })
(define-data-var last-id uint u0)
(define-data-var locked-reap-amount uint u0)

(define-read-only (get-fee-recipient)
  (ok (var-get fee-recipient))
)

(define-public (set-fee-recipient (new-fee-recipient principal))
  (begin
    (try! (check-is-owner))
    (var-set fee-recipient new-fee-recipient)
    (ok true)
  )
)

(define-public (set-swap-percent (new-swap uint))
  (begin
    (try! (check-is-owner))
    (asserts! (and (<= new-swap MAX_SWAP_PERCENT) (>= new-swap MIN_SWAP_PERCENT)) ERR-WRONG-SWAP-PERCENT)
    (var-set swap-percent new-swap)
    (ok true)
  )
)


(define-public (set-fee-percent (new-fee uint))
  (begin
    (try! (check-is-owner))
    (asserts! (<= new-fee MAX_FEE) ERR-FEE-TOO-HIGH)
    (var-set fee-percent new-fee)
    (ok true)
  )
)

(define-public (set-contract-owner (owner principal))
	(begin
		(try! (check-is-owner))
		(ok (var-set contract-owner owner))
	)
)

(define-private (check-is-owner)
	(ok (asserts! (is-eq contract-caller (var-get contract-owner)) ERR-NOT-OWNER))
)

(define-read-only (calc-fee (amount uint))
  (/ (/ (* amount (var-get fee-percent)) u100) ONE_8)
)

(define-private (arkadiko-swap-stx-for-diko (amount uint))
  (let 
    (
      (swap-response (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token amount u0)))
      (diko-amount (element-at? (try! swap-response) u1))
    )
    (if (is-some diko-amount)
      (ok (unwrap! diko-amount ERR-SWAP-TOKENS-ARKADIKO))
      ERR-SWAP-TOKENS-ARKADIKO
    )
  )
)

(define-private (arkadiko-swap-diko-for-stx (amount uint))
  (let 
    (
      (swap-response (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token amount u0)))
      (stx-amount (element-at? (try! swap-response) u0))
    )
    (if (is-some stx-amount)
      (ok (unwrap! stx-amount ERR-SWAP-TOKENS-ARKADIKO))
      ERR-SWAP-TOKENS-ARKADIKO
    )
  )
)

(define-private (alexlab-swap-stx-for-diko (amount uint))
  (let 
    ((swap-response (as-contract (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-a 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko ONE_8 ONE_8 (* amount u100) (some u0)))))
    (if (is-err swap-response) 
      swap-response
      (ok (/ (unwrap! swap-response ERR-SWAP-TOKENS-ALEX) u100))
    )
  )
)

(define-private (alexlab-swap-diko-for-stx (amount uint))
  (let 
    ((swap-response (as-contract (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-a 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 ONE_8 ONE_8 (* amount u100) (some u0)))))
    (if (is-err swap-response) 
      swap-response
      (ok (/ (unwrap! swap-response ERR-SWAP-TOKENS-ALEX) u100))
    )
  )
)

(define-private (add-to-stx-diko-lp (stx-amount uint) (diko-amount uint)) 
  (let 
    (
      (initial-lp-balance (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-diko get-balance (as-contract tx-sender)) ERR-GET-LP-BALANCE))
      (swap-result (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 add-to-position 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-diko stx-amount diko-amount))))
      (updated-lp-balance (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-diko get-balance (as-contract tx-sender)) ERR-GET-LP-BALANCE))
    ) 
    (ok (- updated-lp-balance initial-lp-balance))
  )
)

(define-private (add-lp-tokens-to-farm (amount uint))
  (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v2-1 stake 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v2-1 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-pool-wstx-diko-v1-1 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-diko amount))
)

(define-private (unstake-from-farm (amount uint))
  (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v2-1 unstake 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v2-1 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-pool-wstx-diko-v1-1 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-diko amount))
)

(define-private (claim-rewards) 
  (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v2-1 claim-pending-rewards 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v2-1 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-pool-wstx-diko-v1-1))
)

(define-public (get-total-value-locked) 
  (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-position 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-diko))
)

(define-private (withdrawl-from-lp)
  (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 reduce-position 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-diko u100))
)

(define-read-only (get-lp-token-amount-from-reap (reap-amount uint)) 
  (let 
    (
      (reap-supply (unwrap! (contract-call? .reap-stx-diko-token-v2-1 get-total-supply) ERR-GET-REAP-SUPPLY))
      (reap-total (+ reap-supply (var-get locked-reap-amount)))
      (total-lp-amount (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-pool-wstx-diko-v1-1 get-stake-amount-of (as-contract tx-sender)))
    )
    (if (is-eq reap-total u0)
      ERR-NO-LP-TOKENS
      (ok (/ (* reap-amount total-lp-amount) reap-total))
    ) 
  )
)

(define-read-only (get-reap-token-amount-from-lp (lp-amount uint)) 
  (let 
    (
      (reap-supply (unwrap! (contract-call? .reap-stx-diko-token-v2-1 get-total-supply) ERR-GET-REAP-SUPPLY))
      (reap-total (+ reap-supply (var-get locked-reap-amount)))
      (total-lp-amount (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-pool-wstx-diko-v1-1 get-stake-amount-of (as-contract tx-sender)))
    ) 
    (if (is-eq total-lp-amount u0)
      (ok lp-amount)
      (ok (/ (* lp-amount reap-total) total-lp-amount))
    )
  )
)

(define-private (get-stx-value-in-diko (stx-amount uint))
  (let 
    (
      (stx-diko-pair (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-balances 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token) ERR-GET-PAIR-BALANCE))
      (stx-pool-balance (unwrap! (element-at? stx-diko-pair u0) ERR-GET-PAIR-BALANCE))
      (diko-pool-balance (unwrap! (element-at? stx-diko-pair u1) ERR-GET-PAIR-BALANCE))
    )
    (if (is-eq stx-pool-balance u0) 
      ERR-POOL-BALANCE-0
      (ok (/ (* stx-amount diko-pool-balance) stx-pool-balance))
    )
  )
)

(define-private (get-diko-value-in-stx (diko-amount uint))
  (let 
    (
      (stx-diko-pair (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-balances 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token) ERR-GET-PAIR-BALANCE))
      (stx-pool-balance (unwrap! (element-at? stx-diko-pair u0) ERR-GET-PAIR-BALANCE))
      (diko-pool-balance (unwrap! (element-at? stx-diko-pair u1) ERR-GET-PAIR-BALANCE))
    )
    (if (is-eq diko-pool-balance u0) 
      ERR-POOL-BALANCE-0
      (ok (/ (* diko-amount stx-pool-balance) diko-pool-balance))
    )
  )
)

(define-private (swap-stx-for-diko-best-ratio (stx-amount uint))
  (let 
    (
      (alex-expected-swap-amount-response (contract-call? .reap-swap-helpers alexlab-get-stx-diko-swap-result stx-amount))
      (alex-expected-swap-amount (if (is-err alex-expected-swap-amount-response) u0 (try! alex-expected-swap-amount-response)))
      (arkadiko-expected-swap-amount (try! (contract-call? .reap-swap-helpers arkadiko-get-stx-diko-swap-result stx-amount)))
      (swap-response 
        (if (> alex-expected-swap-amount arkadiko-expected-swap-amount) 
          (alexlab-swap-stx-for-diko stx-amount)
          (arkadiko-swap-stx-for-diko stx-amount)
        )
      )
    )
    (print {
      alex-amount: alex-expected-swap-amount,
      arkadiko-amount: arkadiko-expected-swap-amount,
      swap-response: swap-response,
    })
    ;; fallback to arkadiko swap if alex returned error
    ;; when alex pool is paused alex-expected-swap-amount is ok(value) but actual swap returns error
    (if (is-err swap-response)
      (arkadiko-swap-stx-for-diko stx-amount)
      swap-response
    )
  )
)

(define-private (swap-diko-for-stx-best-ratio (diko-amount uint))
  (let 
    (
      (alex-expected-swap-amount-response (contract-call? .reap-swap-helpers alexlab-get-diko-stx-swap-result diko-amount))
      (alex-expected-swap-amount (if (is-err alex-expected-swap-amount-response) u0 (try! alex-expected-swap-amount-response)))
      (arkadiko-expected-swap-amount (try! (contract-call? .reap-swap-helpers arkadiko-get-diko-stx-swap-result diko-amount)))
      (swap-response 
        (if (> alex-expected-swap-amount arkadiko-expected-swap-amount) 
          (alexlab-swap-diko-for-stx diko-amount)
          (arkadiko-swap-diko-for-stx diko-amount)
        )
      )
    )
    (print {
      alex-amount: alex-expected-swap-amount,
      arkadiko-amount: arkadiko-expected-swap-amount,
      swap-response: swap-response,
    })
    ;; fallback to arkadiko swap if alex returned error
    ;; when alex pool is paused alex-expected-swap-amount is ok(value) but actual swap returns error
    (if (is-err swap-response)
      (arkadiko-swap-diko-for-stx diko-amount)
      swap-response
    )
  )
)

(define-public (stake-single-token (amount uint) (is-diko bool))
  (begin 
    (if is-diko 
      (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token transfer amount contract-caller (as-contract tx-sender) none) ERR-TOKEN-TRANSFER)
      (unwrap! (stx-transfer? amount contract-caller (as-contract tx-sender)) ERR-TOKEN-TRANSFER)
    )
    (let
      (
        ;; We're trying to decrease leftover amount by swaping 47% instead of half
        (swap-amount (/ (* amount (var-get swap-percent)) u1000))
        (stx-amount (if is-diko
          (try! (swap-diko-for-stx-best-ratio swap-amount))
          (- amount swap-amount)
        ))
        (diko-amount (if is-diko
          (- amount swap-amount)
          (try! (swap-stx-for-diko-best-ratio swap-amount))
        ))
        (add-to-lp-stx-amount 
          (if (> (try! (get-stx-value-in-diko stx-amount)) diko-amount)
            (try! (get-diko-value-in-stx diko-amount))
            stx-amount
          )
        )
        (stx-tokens-left (- stx-amount add-to-lp-stx-amount))
        (diko-tokens-left (- diko-amount (try! (get-stx-value-in-diko add-to-lp-stx-amount))))
        (lp-tokens-amount (try! (add-to-stx-diko-lp add-to-lp-stx-amount add-to-lp-stx-amount)))
        (reap-tokens-to-mint (try! (get-reap-token-amount-from-lp lp-tokens-amount)))
        (user tx-sender)
      )
      ;; PUT LP TOKENS TO FARM
      (try! (add-lp-tokens-to-farm lp-tokens-amount))
      ;; MINT REAP-DIKO-STX token
      (try! (as-contract (contract-call? .reap-stx-diko-token-v2-1 mint reap-tokens-to-mint user)))

      (if (is-eq diko-tokens-left u0)
        true
        (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token transfer diko-tokens-left tx-sender user none))) 
      )
      (if (is-eq stx-tokens-left u0)
        true
        (try! (as-contract (stx-transfer? stx-tokens-left tx-sender user)))
      )

      (print {
        user: tx-sender,
        is-diko: is-diko,
        stx-amount: stx-amount,
        diko-amount: diko-amount,
        add-to-lp-stx-amount: add-to-lp-stx-amount,
        lp-tokens-amount: lp-tokens-amount,
        reap-tokens-minted: reap-tokens-to-mint,
        stx-tokens-left: stx-tokens-left,
        diko-tokens-left: diko-tokens-left,
      })

      (ok reap-tokens-to-mint)
    )
  )
)

(define-public (stake-lp (amount uint))
  (begin 
    (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-diko transfer amount contract-caller (as-contract tx-sender) none) ERR-TOKEN-TRANSFER)
    (let
      (
        (reap-tokens-to-mint (try! (get-reap-token-amount-from-lp amount)))
        (user tx-sender)
      )
      (try! (add-lp-tokens-to-farm amount))
      (try! (as-contract (contract-call? .reap-stx-diko-token-v2-1 mint reap-tokens-to-mint user)))

      (print {
        user: tx-sender,
        lp-tokens-amount: amount,
        reap-tokens-minted: reap-tokens-to-mint,
      })

      (ok reap-tokens-to-mint)
    )
  )
)

(define-public (claim-and-restake-rewards) 
  (begin
    (try! (claim-rewards))
    (let
      (
        (diko-initial-balance (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance (as-contract tx-sender)) ERR-GET-LP-BALANCE))
        (diko-left (- diko-initial-balance (/ diko-initial-balance u2)))
        (swap-result (swap-diko-for-stx-best-ratio (/ diko-initial-balance u2)))
        (stx-balance (stx-get-balance (as-contract tx-sender)))
        ;; CHECKING WHAT WE HAVE MORE STX OR DIKO
        (add-to-lp-stx-amount
          (if (> (try! (get-stx-value-in-diko stx-balance)) diko-left)
            (try! (get-diko-value-in-stx diko-left))
            stx-balance
          )
        )
        (lp-tokens-amount (try! (add-to-stx-diko-lp add-to-lp-stx-amount add-to-lp-stx-amount)))
      )
      (asserts! (> lp-tokens-amount u0) ERR-INSUFFICIENT-REWARDS)
      (try! (add-lp-tokens-to-farm lp-tokens-amount))
      
      (print {
        diko-balance-after-claim: diko-initial-balance,
        add-to-lp-stx-amount: add-to-lp-stx-amount,
        lp-tokens-amount: lp-tokens-amount,
      })
      
      (ok lp-tokens-amount)
    )
  )
)

(define-public (create-unstake-order (reap-amount uint))
  (let 
    (
      (reap-tokens-balance (unwrap! (contract-call? .reap-stx-diko-token-v2-1 get-balance tx-sender) ERR-GET-REAP-BALANCE))
      (next-id (+ (var-get last-id) u1))
      (user contract-caller)
      (unstake-order { reap-amount: reap-amount, created-block: block-height, user: user })
    )
    (asserts! (>= reap-tokens-balance reap-amount) ERR-INSUFFICIENT-REAP-BALANCE)
    (try! (as-contract (contract-call? .reap-stx-diko-token-v2-1 burn reap-amount user)))
    (map-set unstake-orders next-id unstake-order)
    (var-set locked-reap-amount (+ (var-get locked-reap-amount) reap-amount))
    (var-set last-id next-id)
    (print {
      user: user,
      reap-tokens-balance: reap-tokens-balance,
      order-id: next-id,
      reap-amount: reap-amount,
    })
    (ok { id: next-id, order: unstake-order })
  )
)

(define-public (unstake (order-id uint) (unstake-mode uint))
  (let 
    (
      (user contract-caller)
      (unstake-order (unwrap! (map-get? unstake-orders order-id ) ERR-WRONG-UNSTAKE-ORDER))
      (reap-amount (get reap-amount unstake-order))
      (lp-tokens-amount (try! (get-lp-token-amount-from-reap reap-amount)))
      (unstaked-lp-tokens (try! (unstake-from-farm lp-tokens-amount)))
      (lp-fee (calc-fee unstaked-lp-tokens))
      (unstaked-lp-tokens-net-fee (if (> unstaked-lp-tokens lp-fee) (- unstaked-lp-tokens lp-fee) u0))
    )
    (asserts! (< unstake-mode u4) ERR-WRONG-UNSTAKE-MODE)
    (asserts! (is-eq user (get user unstake-order)) ERR-WRONG-ORDER-USER)
    (asserts! (>= block-height (+ (get created-block unstake-order) UNSTAKE_LOCK_PERIOD)) ERR-UNSTAKE-LOCKED)
    (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-diko transfer lp-fee tx-sender (var-get fee-recipient) none)))
    (if (is-eq unstake-mode UNSTAKE_LP)
      (try! (unstake-lp unstaked-lp-tokens-net-fee))
      (if (is-eq unstake-mode UNSTAKE_PAIR)
        (try! (unstake-pair unstaked-lp-tokens-net-fee))
        (try! (unstake-single-token unstaked-lp-tokens-net-fee (is-eq unstake-mode UNSTAKE_DIKO)))
      )
    )
    (map-delete unstake-orders order-id)
    (var-set locked-reap-amount (- (var-get locked-reap-amount) reap-amount))
    (print {
      order-id: order-id,
      user: user,
      reap-amount: reap-amount,
      unstaked-lp-tokens: unstaked-lp-tokens,
      lp-fee: lp-fee,
    })
    (ok true)
  )
)

(define-private (check-order-iter (order { reap-amount: uint, created-block: uint, user: principal }))
  (let ((user contract-caller))
    (and (is-eq user (get user order)) (>= block-height (+ (get created-block order) UNSTAKE_LOCK_PERIOD)))
  )
)

(define-private (get-reap-from-order-iter (order { reap-amount: uint, created-block: uint, user: principal }))
  (get reap-amount order)
)

(define-private (get-order-iter (order-id uint))
  (unwrap-panic (map-get? unstake-orders order-id))
)

(define-private (delete-order-iter (order-id uint))
  (map-delete unstake-orders order-id)
)


(define-public (unstake-batch (orders-ids (list 100 uint)) (unstake-mode uint))
  (let 
    (
      (user contract-caller)
      (orders (map get-order-iter orders-ids))
      (is-all-orders-correct (fold and (map check-order-iter orders) true ))
      (reap-amount (fold + (map get-reap-from-order-iter orders) u0))
      (lp-tokens-amount (try! (get-lp-token-amount-from-reap reap-amount)))
      (unstaked-lp-tokens (try! (unstake-from-farm lp-tokens-amount)))
      (lp-fee (calc-fee unstaked-lp-tokens))
      (unstaked-lp-tokens-net-fee (if (> unstaked-lp-tokens lp-fee) (- unstaked-lp-tokens lp-fee) u0))
    )
    (asserts! (< unstake-mode u4) ERR-WRONG-UNSTAKE-MODE)
    (asserts! is-all-orders-correct ERR-WRONG-UNSTAKE-ORDER)
    (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-diko transfer lp-fee tx-sender (var-get fee-recipient) none)))
    (if (is-eq unstake-mode UNSTAKE_LP)
      (try! (unstake-lp unstaked-lp-tokens-net-fee))
      (if (is-eq unstake-mode UNSTAKE_PAIR)
        (try! (unstake-pair unstaked-lp-tokens-net-fee))
        (try! (unstake-single-token unstaked-lp-tokens-net-fee (is-eq unstake-mode UNSTAKE_DIKO)))
      )
    )
    (map delete-order-iter orders-ids)
    (var-set locked-reap-amount (- (var-get locked-reap-amount) reap-amount))
    (print {
      orders-ids: orders-ids,
      user: user,
      reap-amount: reap-amount,
      unstaked-lp-tokens: unstaked-lp-tokens,
      lp-fee: lp-fee,
    })
    (ok true)
  )
)

(define-private (unstake-lp (lp-amount uint))
  (let
    ((user contract-caller))
    (unwrap! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-diko transfer lp-amount tx-sender user none)) ERR-TOKEN-TRANSFER)
    (print {
      transfer-to-user-lp-amount: lp-amount,
    })
    (ok true)
  )
)

(define-private (unstake-pair (lp-amount uint))
  (let
    (
      (withdrawn-pair (unwrap! (withdrawl-from-lp) ERR-LP-WITHDRAWL))
      (withdrawn-stx (unwrap! (element-at? withdrawn-pair u0) ERR-GET-WITHDRAWL-PAIR))
      (withdrawn-diko (unwrap! (element-at? withdrawn-pair u1) ERR-GET-WITHDRAWL-PAIR))
      (user contract-caller)
    )
    (try! (as-contract (stx-transfer? withdrawn-stx tx-sender user)))
    (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token transfer withdrawn-diko tx-sender user none)))
    (print {
      withdrawn-stx: withdrawn-stx,
      withdrawn-diko: withdrawn-diko,
    })
    (ok true)
  )
)

(define-private (unstake-single-token (lp-amount uint) (is-diko bool))
  (let
    (
      (withdrawn-pair (unwrap! (withdrawl-from-lp) ERR-LP-WITHDRAWL))
      (withdrawn-stx (unwrap! (element-at? withdrawn-pair u0) ERR-GET-WITHDRAWL-PAIR))
      (withdrawn-diko (unwrap! (element-at? withdrawn-pair u1) ERR-GET-WITHDRAWL-PAIR))
      (user contract-caller)
      (swapped-token-amount (if is-diko 
        (try! (swap-stx-for-diko-best-ratio withdrawn-stx))
        (try! (swap-diko-for-stx-best-ratio withdrawn-diko)))
      )
      (total-token-withdrawn (+ swapped-token-amount (if is-diko withdrawn-diko withdrawn-stx)))
    )
    (if is-diko
      (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token transfer total-token-withdrawn tx-sender user none)))
      (try! (as-contract (stx-transfer? total-token-withdrawn tx-sender user)))
    )
    (print {
      withdrawn-stx: withdrawn-stx,
      withdrawn-diko: withdrawn-diko,
      swapped-token-amount: swapped-token-amount,
      total-token-withdrawn: total-token-withdrawn,
      is-diko: is-diko,
    })
    (ok true)
  )
)

(define-public (withdraw-ft (token <ft-trait>) (recipient principal) (amount uint))
    (begin
      (try! (check-is-owner))
      (as-contract (contract-call? token transfer amount tx-sender recipient none))
    )
)

(define-public (withdrawal-stx (amount uint) (recipient principal))
    (begin
      (try! (check-is-owner))
      (as-contract (stx-transfer? amount tx-sender recipient))
    )
)

```
