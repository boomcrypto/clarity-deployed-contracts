---
title: "Trait arkadiko-stx-usda-pool"
draft: true
---
```
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant ERR-TOKEN-TRANSFER (err u108))
(define-constant ERR-GET-PAIR-BALANCE (err u109))
(define-constant ERR-GET-LP-BALANCE (err u110))
(define-constant ERR-GET-REAP-SUPPLY (err u111))
(define-constant ERR-GET-STAKED-LP-TOKES (err u112))
(define-constant ERR-GET-REAP-BALANCE (err u113))
(define-constant ERR-GET-PAIR-DATA (err u114))
(define-constant ERR-CALC-LP-FROM-STX (err u115))
(define-constant ERR-LP-WITHDRAWL (err u116))
(define-constant ERR-GET-WITHDRAWL-PAIR (err u117))
(define-constant ERR-NOT-OWNER (err u118))
(define-constant ERR-FEE-TOO-HIGH (err u119))
(define-constant ERR-NOT-APPROVED (err u120))
(define-constant ERR-SWAP-TOKENS-ARKADIKO (err u121))
(define-constant ERR-SWAP-TOKENS-ALEX (err u122))
(define-constant ERR-NO-LP-TOKENS (err u123))
(define-constant ERR-POOL-BALANCE-0 (err u124))
(define-constant ERR-INSUFFICIENT-REAP-BALANCE (err u125))
(define-constant ERR-WRONG-UNSTAKE-MODE (err u126))

(define-constant ONE_8 u100000000)
(define-constant FIXED_POOL_WEIGHT u50000000)

;; UNSTAKE ENUM for choosing which tokens are returned to user
(define-constant UNSTAKE_LP u0)
(define-constant UNSTAKE_PAIR u1)
(define-constant UNSTAKE_STX u2)
(define-constant UNSTAKE_USDA u3)

;; default fee is 0.3%
(define-data-var fee-percent uint u30000000)

;; Max possible fee is 2%
(define-constant MAX_FEE u200000000)

(define-data-var fee-recipient principal tx-sender)
(define-data-var contract-owner principal tx-sender)

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

(define-private (arkadiko-swap-diko-for-stx (amount uint)) 
  (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token amount u0))
)

(define-private (arkadiko-swap-stx-for-usda (amount uint)) 
  (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token amount u0))
)

(define-private (arkadiko-swap-usda-for-stx (amount uint)) 
  (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token amount u0))
)

(define-private (arkadiko-swap-diko-for-usda (amount uint)) 
  (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token amount u0))
)

(define-private (alexlab-swap-diko-for-stx (amount uint))
  (as-contract (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper-a 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wdiko 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx ONE_8 ONE_8 (* amount u100) (some u0)))
)

(define-private (alexlab-swap-stx-for-usda (amount uint))
  (as-contract (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda (* amount u100) (some u0)))
)

(define-private (alexlab-swap-usda-for-stx (amount uint))
  (as-contract (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx (* amount u100) (some u0)))
)

(define-private (alexlab-swap-diko-for-usda (amount uint))
  (as-contract (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-bridged-v1-1 swap-helper-from-amm 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wdiko 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda ONE_8 (* amount u100) (some u0)))
)

(define-private (add-to-stx-usda-lp (stx-amount uint) (usda-amount uint)) 
  (let 
    (
      (initial-lp-balance (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-usda get-balance (as-contract tx-sender)) ERR-GET-LP-BALANCE))
      (swap-result (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 add-to-position 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-usda stx-amount usda-amount)))
      (updated-lp-balance (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-usda get-balance (as-contract tx-sender)) ERR-GET-LP-BALANCE))
    ) 
    (ok (- updated-lp-balance initial-lp-balance))
  )
)

(define-private (add-lp-tokens-to-farm (amount uint))
  (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v2-1 stake 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v2-1 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-pool-wstx-usda-v1-1 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-usda amount))
)

(define-private (unstake-from-farm (amount uint))
  (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v2-1 unstake 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v2-1 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-pool-wstx-usda-v1-1 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-usda amount))
)

(define-private (claim-rewards) 
  (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v2-1 claim-pending-rewards 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-v2-1 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-pool-wstx-usda-v1-1))
)

(define-private (withdrawl-from-lp)
  (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 reduce-position 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-usda u100))
)

(define-read-only (get-lp-token-amount-from-reap (reap-amount uint)) 
  (let 
    (
      (reap-total-supply (unwrap! (contract-call? .reap-stx-usda-token get-total-supply) ERR-GET-REAP-SUPPLY))
      (lp-tokens-amount (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-pool-wstx-usda-v1-1 get-stake-amount-of (as-contract tx-sender)))
    )
    ;; check for reap-total-supply === 0 here is unneccessary since this method gets called only in unstake and reap total supply can't be 0 there
    (ok (/ (* reap-amount lp-tokens-amount) reap-total-supply))
  )
)

(define-read-only (get-reap-token-amount-from-lp (lp-amount uint)) 
  (let 
    (
      (reap-total-supply (unwrap! (contract-call? .reap-stx-usda-token get-total-supply) ERR-GET-REAP-SUPPLY))
      (total-lp-amount (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-pool-wstx-usda-v1-1 get-stake-amount-of (as-contract tx-sender)))
    ) 
    (if (is-eq total-lp-amount u0) 
      (ok lp-amount)
      (ok (/ (* lp-amount reap-total-supply) total-lp-amount))
    )
  )
)

(define-private (get-stx-value-in-usda (stx-amount uint))
  (let 
    (
      (stx-usda-pair (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-balances 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token) ERR-GET-PAIR-BALANCE))
      (stx-pool-balance (unwrap! (element-at? stx-usda-pair u0) ERR-GET-PAIR-BALANCE))
      (usda-pool-balance (unwrap! (element-at? stx-usda-pair u1) ERR-GET-PAIR-BALANCE))
    )
    (if (is-eq stx-pool-balance u0) 
      ERR-POOL-BALANCE-0
      (ok (/ (* stx-amount usda-pool-balance) stx-pool-balance))
    )
  )
)

(define-private (get-usda-value-in-stx (usda-amount uint))
  (let 
    (
      (stx-usda-pair (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-balances 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token) ERR-GET-PAIR-BALANCE))
      (stx-pool-balance (unwrap! (element-at? stx-usda-pair u0) ERR-GET-PAIR-BALANCE))
      (usda-pool-balance (unwrap! (element-at? stx-usda-pair u1) ERR-GET-PAIR-BALANCE))
    )
    (if (is-eq usda-pool-balance u0) 
      ERR-POOL-BALANCE-0
      (ok (/ (* usda-amount stx-pool-balance) usda-pool-balance))
    )
  )
)

(define-private (swap-stx-for-usda-best-ratio (stx-amount uint))
  (let 
    (
      (alex-expected-swap-amount-response (contract-call? .reap-swap-helpers-v1 alexlab-get-stx-usda-swap-result stx-amount))
      (alex-expected-swap-amount (if (is-err alex-expected-swap-amount-response) u0 (try! alex-expected-swap-amount-response)))
      (arkadiko-expected-swap-amount (try! (contract-call? .reap-swap-helpers-v1 arkadiko-get-stx-usda-swap-result stx-amount)))
      (swap-response 
          (if (> alex-expected-swap-amount arkadiko-expected-swap-amount) 
            (ok (/ (try! (alexlab-swap-stx-for-usda stx-amount)) u100))
            (let 
              (
                (usda-amount (element-at? (try! (arkadiko-swap-stx-for-usda stx-amount)) u1))
              )
              (if (is-some usda-amount)
                (ok (unwrap! usda-amount ERR-SWAP-TOKENS-ARKADIKO))
                ERR-SWAP-TOKENS-ARKADIKO
              )
            )
          )
        )
      )
      (print {
        alex-amount: alex-expected-swap-amount,
        arkadiko-amount: arkadiko-expected-swap-amount,
        swap-response: swap-response,
      })
      swap-response
  )
)

(define-private (swap-diko-for-stx-best-ratio (diko-amount uint))
  (let 
    (
      (alex-expected-swap-amount-response (contract-call? .reap-swap-helpers-v1 alexlab-get-diko-stx-swap-result diko-amount))
      (alex-expected-swap-amount (if (is-err alex-expected-swap-amount-response) u0 (try! alex-expected-swap-amount-response)))
      (arkadiko-expected-swap-amount (try! (contract-call? .reap-swap-helpers-v1 arkadiko-get-diko-stx-swap-result diko-amount)))
      (swap-response 
        (if (and (is-ok alex-expected-swap-amount-response) (> alex-expected-swap-amount arkadiko-expected-swap-amount)) 
          (ok (/ (try! (alexlab-swap-diko-for-stx diko-amount)) u100))
          (let 
            (
              (stx-amount (element-at? (try! (arkadiko-swap-diko-for-stx diko-amount)) u0))
            )
            (if (is-some stx-amount)
              (ok (unwrap! stx-amount ERR-SWAP-TOKENS-ARKADIKO))
              ERR-SWAP-TOKENS-ARKADIKO
            )
          )
        )
      )
    )
    (print {
      alex-amount: alex-expected-swap-amount,
      arkadiko-amount: arkadiko-expected-swap-amount,
      swap-response: swap-response,
    })
    swap-response
  )
)

(define-private (swap-usda-for-stx-best-ratio (usda-amount uint))
  (let 
    (
      (alex-expected-swap-amount-response (contract-call? .reap-swap-helpers-v1 alexlab-get-usda-stx-swap-result usda-amount))
      (alex-expected-swap-amount (if (is-err alex-expected-swap-amount-response) u0 (try! alex-expected-swap-amount-response)))
      (arkadiko-expected-swap-amount (try! (contract-call? .reap-swap-helpers-v1 arkadiko-get-usda-stx-swap-result usda-amount)))
      (swap-response 
          (if (and (is-ok alex-expected-swap-amount-response) (> alex-expected-swap-amount arkadiko-expected-swap-amount)) 
            (ok (/ (try! (alexlab-swap-usda-for-stx usda-amount)) u100))
            (let 
              (
                (stx-amount (element-at? (try! (arkadiko-swap-usda-for-stx usda-amount)) u0))
              )
              (if (is-some stx-amount)
                (ok (unwrap! stx-amount ERR-SWAP-TOKENS-ARKADIKO))
                ERR-SWAP-TOKENS-ARKADIKO
              )
            )
          )
        )
      )
    (print {
      alex-amount: alex-expected-swap-amount,
      arkadiko-amount: arkadiko-expected-swap-amount,
      swap-response: swap-response,
    })
    swap-response
  )
)

(define-private (swap-diko-for-usda-best-ratio (diko-amount uint))
  (let 
    (
      (alex-expected-swap-amount-response (contract-call? .reap-swap-helpers-v1 alexlab-get-diko-usda-swap-result diko-amount))
      (alex-expected-swap-amount (if (is-err alex-expected-swap-amount-response) u0 (try! alex-expected-swap-amount-response)))
      (arkadiko-expected-swap-amount (try! (contract-call? .reap-swap-helpers-v1 arkadiko-get-diko-usda-swap-result diko-amount)))
      (swap-response 
          (if (and (is-ok alex-expected-swap-amount-response) (> alex-expected-swap-amount arkadiko-expected-swap-amount)) 
            (ok (/ (try! (alexlab-swap-diko-for-usda diko-amount)) u100))
            (let 
              (
                (usda-amount (element-at? (try! (arkadiko-swap-diko-for-usda diko-amount)) u1))
              )
              (if (is-some usda-amount)
                (ok (unwrap! usda-amount ERR-SWAP-TOKENS-ARKADIKO))
                ERR-SWAP-TOKENS-ARKADIKO
              )
            )
          )
        )
      )
      (print {
        alex-amount: alex-expected-swap-amount,
        arkadiko-amount: arkadiko-expected-swap-amount,
        swap-response: swap-response,
      })
      swap-response
  )
)

(define-public (stake-single-token (amount uint) (is-usda bool))
  (begin
    (if is-usda 
      (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer amount contract-caller (as-contract tx-sender) none) ERR-TOKEN-TRANSFER)
      (unwrap! (stx-transfer? amount contract-caller (as-contract tx-sender)) ERR-TOKEN-TRANSFER)
    ) 
    (let
      (
        (swap-amount (/ (* amount u490) u1000))
        (stx-amount (if is-usda
          (try! (swap-usda-for-stx-best-ratio swap-amount))
          (- amount swap-amount)
        ))
        (usda-amount (if is-usda
          (- amount swap-amount)
          (try! (swap-stx-for-usda-best-ratio swap-amount))
        ))
        (add-to-lp-stx-amount 
          (if (> (try! (get-stx-value-in-usda stx-amount)) usda-amount)
            (try! (get-usda-value-in-stx usda-amount))
            stx-amount
          )
        )
        (stx-tokens-left (- stx-amount add-to-lp-stx-amount))
        (usda-tokens-left (- usda-amount (try! (get-stx-value-in-usda add-to-lp-stx-amount))))
        (lp-tokens-amount (try! (add-to-stx-usda-lp add-to-lp-stx-amount add-to-lp-stx-amount)))  ;; second arg used only when pair is created to it doesn't matter
        (reap-tokens-to-mint (try! (get-reap-token-amount-from-lp lp-tokens-amount)))
        (user tx-sender)
      )
      ;; PUT LP TOKENS TO FARM
      (try! (add-lp-tokens-to-farm lp-tokens-amount))
      ;; MINT REAP-DIKO-STX token
      (try! (as-contract (contract-call? .reap-stx-usda-token mint reap-tokens-to-mint user)))

      
      ;; SEND BACK TO USED LEFTOVER TOKENS
      (if (is-eq usda-tokens-left u0)
        true
        (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer usda-tokens-left tx-sender user none))) 
      )
      (if (is-eq stx-tokens-left u0)
        true
        (try! (as-contract (stx-transfer? stx-tokens-left tx-sender user)))
      )
      
      (print {
        user: user,
        is-usda: is-usda,
        stx-amount: stx-amount,
        usda-amount: usda-amount,
        add-to-lp-stx-amount: add-to-lp-stx-amount,
        lp-tokens-amount: lp-tokens-amount,
        reap-tokens-minted: reap-tokens-to-mint,
        stx-tokens-left: stx-tokens-left,
        usda-tokens-left: usda-tokens-left,
      })

      (ok reap-tokens-to-mint)
    )
  )
)

(define-public (stake-stx-usda-lp (amount uint))
  (begin 
    (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-usda transfer amount contract-caller (as-contract tx-sender) none) ERR-TOKEN-TRANSFER)
    (let
      (
        (reap-tokens-to-mint (try! (get-reap-token-amount-from-lp amount)))
        (user tx-sender)
      )
      (try! (add-lp-tokens-to-farm amount))
      (try! (as-contract (contract-call? .reap-stx-usda-token mint reap-tokens-to-mint user)))

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
        (diko-amount (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance (as-contract tx-sender)) ERR-GET-LP-BALANCE))
        (stx-amount (swap-diko-for-stx-best-ratio (/ diko-amount u2)))
        (usda-amount (swap-diko-for-usda-best-ratio (- diko-amount (/ diko-amount u2))))
        (stx-balance (stx-get-balance (as-contract tx-sender)))
        (usda-balance (unwrap! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance (as-contract tx-sender)) ERR-GET-LP-BALANCE))
        ;; CHECKING WHAT WE HAVE MORE STX OR USDA
        (add-to-lp-stx-amount
          (if (> (try! (get-stx-value-in-usda stx-balance)) usda-balance)
            (try! (get-usda-value-in-stx usda-balance))
            stx-balance
          )
        )
        (lp-tokens-amount (try! (add-to-stx-usda-lp add-to-lp-stx-amount add-to-lp-stx-amount))) ;; second arg used only when pair is created to it doesn't matter
      )
      (try! (add-lp-tokens-to-farm lp-tokens-amount))
      
      (print {
        diko-amount: diko-amount,
        usda-amount: usda-amount,
        usda-balance: usda-balance,
        stx-amount: stx-amount,
        stx-balance: usda-balance,
        add-to-lp-stx-amount: add-to-lp-stx-amount,
        lp-tokens-amount: lp-tokens-amount,
      })
      
      (ok true)
    )
  )
)

(define-public (unstake (reap-amount uint) (unstake-mode uint))
  (let 
    (
      (reap-tokens-balance (unwrap! (contract-call? .reap-stx-usda-token get-balance tx-sender) ERR-GET-REAP-BALANCE))
      (lp-tokens-amount (try! (get-lp-token-amount-from-reap reap-amount)))
      (unstaked-lp-tokens (try! (unstake-from-farm lp-tokens-amount)))
      (lp-fee (calc-fee unstaked-lp-tokens))
      (unstaked-lp-tokens-net-fee (if (> unstaked-lp-tokens lp-fee) (- unstaked-lp-tokens lp-fee) u0))
      (user contract-caller)
    )
    (asserts! (< unstake-mode u4) ERR-WRONG-UNSTAKE-MODE)
    (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-usda transfer lp-fee tx-sender (var-get fee-recipient) none)))
    (asserts! (>= reap-tokens-balance reap-amount) ERR-INSUFFICIENT-REAP-BALANCE)
    (try! (as-contract (contract-call? .reap-stx-usda-token burn reap-amount user)))
    (if (is-eq unstake-mode UNSTAKE_LP)
      (begin
        (print {
          user-reap-tokens-balance: reap-tokens-balance,
          unstaked-lp-tokens: unstaked-lp-tokens,
          lp-fee: lp-fee,
          transfer-to-user-lp-amount: unstaked-lp-tokens-net-fee,
        })
        (unwrap! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wstx-usda transfer unstaked-lp-tokens-net-fee tx-sender user none)) ERR-TOKEN-TRANSFER)
      )
      (let
        (
          (withdrawn-pair (unwrap! (withdrawl-from-lp) ERR-LP-WITHDRAWL))
          (withdrawn-stx (unwrap! (element-at? withdrawn-pair u0) ERR-GET-WITHDRAWL-PAIR))
          (withdrawn-usda (unwrap! (element-at? withdrawn-pair u1) ERR-GET-WITHDRAWL-PAIR))
        )
        (if (is-eq unstake-mode UNSTAKE_PAIR)
          (begin
            (try! (as-contract (stx-transfer? withdrawn-stx tx-sender user)))
            (print {
              user-reap-tokens-balance: reap-tokens-balance,
              unstaked-lp-tokens: unstaked-lp-tokens,
              lp-fee: lp-fee,
              withdrawn-stx: withdrawn-stx,
              withdrawn-usda: withdrawn-usda,
            })
            (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer withdrawn-usda tx-sender user none))) 
          )
          (if (is-eq unstake-mode UNSTAKE_STX)
            (let 
              (
                (swapped-stx-amount (try! (swap-usda-for-stx-best-ratio withdrawn-usda)))
                (total-stx-withdrawn (+ withdrawn-stx swapped-stx-amount))
              ) 
              (print {
                user-reap-tokens-balance: reap-tokens-balance,
                unstaked-lp-tokens: unstaked-lp-tokens,
                lp-fee: lp-fee,
                withdrawn-stx: withdrawn-stx,
                withdrawn-usda: withdrawn-usda,
                swapped-stx-amount: swapped-stx-amount,
                total-stx-withdrawn: total-stx-withdrawn,
              })
              (try! (as-contract (stx-transfer? total-stx-withdrawn tx-sender user)))
            )
            (let 
              (
                (swapped-usda-amount (try! (swap-stx-for-usda-best-ratio withdrawn-stx)))
                (total-usda-withdrawn (+ withdrawn-usda swapped-usda-amount))
              ) 
              (print {
                user-reap-tokens-balance: reap-tokens-balance,
                unstaked-lp-tokens: unstaked-lp-tokens,
                lp-fee: lp-fee,
                withdrawn-stx: withdrawn-stx,
                withdrawn-usda: withdrawn-usda,
                swapped-diko-amount: swapped-usda-amount,
                total-usda-withdrawn: total-usda-withdrawn,
              })
              (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer total-usda-withdrawn tx-sender user none))) 
            )
          )
        )
      )
    )
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
