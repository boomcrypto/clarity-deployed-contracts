---
title: "Trait liquidator"
draft: true
---
```
;; TRAITS
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(impl-trait 'SP39XAFAFZPVE6SR01RNMCWCDSXWPG0TKZ75ZKR2N.trait-flash-loan-v1.flash-loan)

;; Constants
(define-constant SELF (as-contract contract-caller))
(define-constant SCALING-FACTOR u10000)
(define-constant SUCCESS (ok true))

;; TODO
(define-constant ERR-UNAUTHORIZED (err u10000))
(define-constant ERR-TRANSFER-NULL (err u10001))
(define-constant ERR-INVALID-VALUE (err u10002))
(define-constant ERR-TIMEOUT (err u10003))
(define-constant ERR-SWAP-FACTOR-C (err u10004))
(define-constant ERR-SWAP-FACTOR-B (err u10005))
(define-constant ERR-SWAP-FACTOR-A (err u10006))
(define-constant ERR-SWAP-FACTOR (err u10007))
(define-constant ERR-SWAP-PATH (err u10008))
(define-constant ERR-SWAP-RESULT (err u10009))
(define-constant ERR-INVALID-DEX (err u10012))
(define-constant ERR-INVALID-CALLBACK-DATA (err u10013))

;; data vars
(define-data-var owner principal contract-caller)
(define-data-var operator principal contract-caller)
(define-data-var flash-loan-sc principal .flash-loan-v1)
(define-data-var unprofitability-threshold uint u0)

;; Read only functions
(define-read-only (is-owner) (is-eq contract-caller (var-get owner)))

(define-read-only (is-operator) (is-eq contract-caller (var-get operator)))

(define-read-only (is-flash-loan-sc) (is-eq contract-caller (var-get flash-loan-sc)))

(define-read-only (get-unprofitability-threshold) (var-get unprofitability-threshold))

(define-read-only (get-info) 
  {
    operator: (var-get operator),
    owner: (var-get owner),
    flash-loan-sc: (var-get flash-loan-sc),
    unprofitability-threshold: (var-get unprofitability-threshold),
    market-asset: 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc,
    collateral-asset: 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
  }
)

;; Public functions

(define-public (set-owner (new-owner principal))
  (begin
    (asserts! (is-owner) ERR-UNAUTHORIZED)
    (print {
      previous-owner: (var-get owner),
      new-owner: new-owner,
      caller: contract-caller,
      action: "set-owner"
    })
    (var-set owner new-owner)
    SUCCESS
  )
)

(define-public (set-operator (new-operator principal))
  (begin
    (asserts! (is-owner) ERR-UNAUTHORIZED)
    (print {
      previous-operator: (var-get operator),
      new-operator: new-operator,
      caller: contract-caller,
      action: "set-operator"
    })
    (var-set operator new-operator)
    SUCCESS
  )
)

(define-public (set-flash-loan-sc (new-sc principal))
  (begin
    (asserts! (is-owner) ERR-UNAUTHORIZED)
    (print {
      previous-sc: (var-get flash-loan-sc),
      new-sc: new-sc,
      caller: contract-caller,
      action: "set-flash-loan-sc"
    })
    (var-set flash-loan-sc new-sc)
    SUCCESS
  )
)

(define-public (set-unprofitability-threshold (new-val uint))
  (begin
    (asserts! (is-owner) ERR-UNAUTHORIZED)
    (asserts! (<= new-val u10000) ERR-INVALID-VALUE)
    (print {
      previous: (var-get unprofitability-threshold),
      new: new-val,
      user: contract-caller,
      action: "set-unprofitability-threshold"
    })
    (var-set unprofitability-threshold new-val)
    SUCCESS
  )
)

(define-public (on-granite-flash-loan (amount uint) (fee uint) (data (optional (buff 20480))))
  (let (
    (cdata (unwrap! (from-consensus-buff? {
      pyth-price-feed-data: (optional (buff 8192)), 
      batch: (list 20 (optional {
        user: principal,
        liquidator-repay-amount: uint,
        min-collateral-expected: uint
      })),
      deadline: uint,
      dex: uint
      } (unwrap-panic data)) ERR-INVALID-CALLBACK-DATA))
      (dex (get dex cdata))
      (sender tx-sender)
  )
    (asserts! (is-flash-loan-sc) ERR-UNAUTHORIZED)
    (asserts! (> (get deadline cdata) (default-to u0 (get-stacks-block-info? time (- stacks-block-height u1)))) ERR-TIMEOUT)
    (asserts! (or (is-eq dex u1) (is-eq dex u2)) ERR-INVALID-DEX)
    (try! (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc transfer amount sender SELF none))
    (try! (liqudate-and-swap-inner (get pyth-price-feed-data cdata) (get batch cdata) dex))
    (try! (as-contract (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc transfer (+ amount fee) SELF sender none)))
    SUCCESS
  )
)

(define-public (liquidate-with-swap 
  (pyth-price-feed-data (optional (buff 8192)))
  (batch (list 20 (optional {
    user: principal,
    liquidator-repay-amount: uint,
    min-collateral-expected: uint
  })))
  (deadline uint)
  (dex uint))
  (begin 
    (asserts! (or (is-owner) (is-operator)) ERR-UNAUTHORIZED)
    (asserts! (> deadline (default-to u0 (get-stacks-block-info? time (- stacks-block-height u1)))) ERR-TIMEOUT)
    (asserts! (or (is-eq dex u1) (is-eq dex u2)) ERR-INVALID-DEX)
    (try! (liqudate-and-swap-inner pyth-price-feed-data batch dex))
    SUCCESS
  )
)

(define-public (liquidate
  (pyth-price-feed-data (optional (buff 8192)))
  (batch (list 20 (optional {
    user: principal,
    liquidator-repay-amount: uint,
    min-collateral-expected: uint
  })))
  (deadline uint))
    (let (
      (initial-market-balance (unwrap-panic (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-balance SELF)))
      (initial-collateral-balance (unwrap-panic (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance SELF)))
    )
      (asserts! (or (is-owner) (is-operator)) ERR-UNAUTHORIZED)
      (asserts! (> deadline (default-to u0 (get-stacks-block-info? time (- stacks-block-height u1)))) ERR-TIMEOUT)
      (try! (batch-liquidate-position pyth-price-feed-data batch))
      (let
        (
          (asset-amount-repaid (- initial-market-balance (unwrap-panic (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-balance SELF))))
          (collateral-obtained (- (unwrap-panic (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance SELF)) initial-collateral-balance ))
        ) 
        (print {
          initial-market-balance: initial-market-balance,
          initial-collateral-balance: initial-collateral-balance,
          asset-amount-repaid: asset-amount-repaid,
          collateral-obtained: collateral-obtained,
          action: "liquidate"
        })
        SUCCESS
)))

(define-public (deposit (token <ft-trait>) (amount uint))
  (begin
    (try! (transfer-from token contract-caller amount))
    SUCCESS
  )
)

(define-public (withdraw (token <ft-trait>) (amount uint))
  (begin
    (asserts! (is-owner) ERR-UNAUTHORIZED)
    (try! (transfer-to token contract-caller amount))
    SUCCESS
  )
)

(define-public (deposit-stx (amount uint))
  (stx-transfer? amount contract-caller SELF)
)

(define-public (withdraw-stx (amount uint))
  (let ((caller contract-caller))
    (asserts! (is-owner) ERR-UNAUTHORIZED)
    (as-contract (stx-transfer? amount (as-contract contract-caller) caller))
  )
)

;; Private functions
(define-private (fold-repay-amount-sum (batch (optional {user: principal, liquidator-repay-amount: uint, min-collateral-expected: uint})) (sum uint))
  (match batch liq-data 
    (+ sum (get liquidator-repay-amount liq-data))
    sum)
)

(define-private (liqudate-and-swap-inner 
  (pyth-price-feed-data (optional (buff 8192)))
  (batch (list 20 (optional {
    user: principal,
    liquidator-repay-amount: uint,
    min-collateral-expected: uint
  })))
  (dex uint)
)
  (let (
    (initial-market-balance (unwrap-panic (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-balance SELF)))
    (initial-collateral-balance (unwrap-panic (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance SELF)))
  )
    (try! (batch-liquidate-position pyth-price-feed-data batch))
    (let 
        (
          (market-balance-before-swap (unwrap-panic (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-balance SELF)))
          (collateral-balance (unwrap-panic (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance SELF)))
          (asset-amount-repaid (- initial-market-balance market-balance-before-swap))
          (collateral-obtained (- collateral-balance initial-collateral-balance))
          ;; TODO: Consider to make min out 0 and check expected market-asset in the end
          (asset-min-out (compute-min-out asset-amount-repaid))
          (aeusdc-out (try! (as-contract (swap-sbtc-to-aeusdc collateral-obtained asset-min-out dex))))
          (market-balance-after (unwrap-panic (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-balance SELF)))
        )
      ;; This check ensures that in the end of the swap operation we receive market-asset and swap-data passed properly.
      (asserts! (>= (- market-balance-after market-balance-before-swap) asset-min-out) ERR-SWAP-RESULT)
      (print {
        initial-market-balance: initial-market-balance,
        initial-collateral-balance: initial-collateral-balance,
        asset-amount-repaid: asset-amount-repaid,
        collateral-obtained: collateral-obtained,
        asset-min-out: asset-min-out,
        market-balance-before-swap: market-balance-before-swap,
        market-balance-after-swap: market-balance-after,
        swap-result: (- market-balance-after market-balance-before-swap),
        action: "liquidate-with-swap",
        dex: dex
      })
      SUCCESS
    )
  )
)


(define-private (compute-min-out (paid uint))
  (- paid 
    (/ 
      (* paid (var-get unprofitability-threshold))
      SCALING-FACTOR
    )
  )
)

(define-private (transfer-from (token <ft-trait>) (user principal) (amount uint))
  (begin
    (asserts! (> amount u0) ERR-TRANSFER-NULL)
    (try! (contract-call? token transfer amount user SELF none))
    SUCCESS
))

(define-private (transfer-to (token <ft-trait>) (user principal) (amount uint))
  (begin
    (asserts! (> amount u0) ERR-TRANSFER-NULL)
    (as-contract (try! (contract-call? token transfer amount SELF user none)))
    SUCCESS
))

(define-private (batch-liquidate-position
    (pyth-price-feed-data (optional (buff 8192)))
    (batch (list 20 (optional {
      user: principal,
      liquidator-repay-amount: uint,
      min-collateral-expected: uint
    })))
  )
  (as-contract (contract-call? 'SP1XN57PMR6X7JZ8JXMNRAE065YBA3NKRCZF5N46B.liquidator-v1 batch-liquidate
    pyth-price-feed-data
    'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
    batch
  ))
)

(define-private (swap-sbtc-to-aeusdc (sbtc-in-amount uint) (aeusdc-min-out uint) (dex uint))
  (if (is-eq dex u1) 
    (swap-sbtc-to-aeusdc-alex sbtc-in-amount aeusdc-min-out) 
    (if (is-eq dex u2) 
      (swap-sbtc-to-aeusdc-bitflow sbtc-in-amount aeusdc-min-out)
      ERR-INVALID-DEX
    ) 
  )
)

(define-private (swap-sbtc-to-aeusdc-alex (sbtc-in-amount uint) (aeusdc-min-out uint))
  (let 
    (
      (aeusdc-out (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-a
                  'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-waeusdc 
                  u100000000
                  u100000000
                  sbtc-in-amount
                  (some (/ (* aeusdc-min-out u100000000) u1000000))
      )))
    )

    (ok (/ (* aeusdc-out u1000000) u100000000))
  )
)

(define-private (swap-sbtc-to-aeusdc-bitflow (sbtc-in-amount uint) (aeusdc-min-out uint))
  (let (
    ;; sbtc->stx
    (stx-out (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 
      swap-x-for-y 
      'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2 
      sbtc-in-amount 
      u1)))
    
    ;; stx->aeusdc
    (aeusdc-out (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 
      swap-x-for-y 
      'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-stx-aeusdc-v-1-2 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc  
      stx-out aeusdc-min-out)))
  ) 
  
  (ok aeusdc-out)
))
```
