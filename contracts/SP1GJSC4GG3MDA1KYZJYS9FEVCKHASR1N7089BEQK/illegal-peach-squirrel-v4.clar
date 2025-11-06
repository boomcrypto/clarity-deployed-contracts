;; Traits
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Constants
(define-constant SELF (as-contract contract-caller))
(define-constant SCALING-FACTOR u10000)
(define-constant SUCCESS (ok true))
(define-constant FEE u100)

;; Errors
(define-constant ERR-UNAUTHORIZED (err u20000))
(define-constant ERR-INVALID-DEX (err u20001))
(define-constant ERR-INSUFFICIENT-BALANCE (err u20002))
(define-constant ERR-INVALID-CALLBACK-DATA (err u20003))
(define-constant ERR-TIMEOUT (err u20004))
(define-constant ERR-INVALID-VALUE (err u20005))
(define-constant ERR-TRANSFER-NULL (err u20006))


(define-public (leverage-helper 
  (pyth-price-feed-data (optional (buff 8192)))
  (borrow-amount uint)
  (min-sbtc-out uint)
)
  (let 
    (
      ;; get USDC balance
      (market-asset-balance (unwrap-panic (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-balance SELF)))
      ;; swap USDC to sBTC
      (sbtc-out (try! (as-contract (swap-aeusdc-to-sbtc-bitflow market-asset-balance min-sbtc-out))))
      (collateral-balance (unwrap-panic (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance SELF)))
    )
      (asserts! (is-eq sbtc-out collateral-balance) ERR-INSUFFICIENT-BALANCE)
      ;; deposit sBTC
      (try! (contract-call? 'SP3BJR4P3W2Y9G22HA595Z59VHBC9EQYRFWSKG743.borrower-v1 add-collateral 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token sbtc-out))
      ;; borrow
      (try! (contract-call? 'SP3BJR4P3W2Y9G22HA595Z59VHBC9EQYRFWSKG743.borrower-v1 borrow pyth-price-feed-data borrow-amount))
      SUCCESS
    )
)

(define-private (swap-aeusdc-to-sbtc-bitflow (aeusdc-in-amount uint) (sbtc-min-out uint))
  (let
    (
      ;; sbtc -> stx
      (o1 (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 swap-y-for-x 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-stx-aeusdc-v-1-2 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc aeusdc-in-amount u1)))
      ;; stx -> aeusdc
      (sbtc-out (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 swap-y-for-x 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2 o1 sbtc-min-out)))
    )
    (ok sbtc-out)
  )
)

(define-public (deposit (token <ft-trait>) (amount uint))
  (begin
    (try! (transfer-from token contract-caller amount))
    SUCCESS
  )
)

(define-public (withdraw (token <ft-trait>) (amount uint))
  (begin
    (try! (transfer-to token contract-caller amount))
    SUCCESS
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
