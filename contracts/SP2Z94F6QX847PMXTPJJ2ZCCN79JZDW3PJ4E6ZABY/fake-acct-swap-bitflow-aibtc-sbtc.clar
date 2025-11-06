;; title: fake-acct-swap-bitflow-fake-sbtc
;; version: 1.0.0
;; summary: Adapter to trade fake:sbtc on the Bitflow pool with an agent account.

;; traits

(impl-trait 'SP6382W148DH1J3BMEBGWENZ9AK8DXCN5XJPP01C.aibtc-agent-account-traits.aibtc-dao-swap-adapter)
(use-trait sip010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; constants
(define-constant DEPLOYED_BURN_BLOCK burn-block-height)
(define-constant DEPLOYED_STACKS_BLOCK stacks-block-height)
(define-constant SELF (as-contract tx-sender))

(define-constant SBTC_TOKEN 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)
(define-constant DAO_TOKEN .fake-faktory)

;; error codes
(define-constant ERR_INVALID_DAO_TOKEN (err u2300))
(define-constant ERR_SWAP_FAILED (err u2301))
(define-constant ERR_MIN_RECEIVE_REQUIRED (err u2302))

;; data vars

(define-data-var totalBuys uint u0)
(define-data-var totalSells uint u0)

;; public functions

(define-public (buy-dao-token
    (daoToken <sip010-trait>)
    (amount uint)
    (minReceive (optional uint))
  )
  (let ((daoTokenContract (contract-of daoToken)))
    (asserts! (is-eq daoTokenContract DAO_TOKEN) ERR_INVALID_DAO_TOKEN)
    (asserts! (is-some minReceive) ERR_MIN_RECEIVE_REQUIRED)
    (match (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2
      swap-x-for-y .xyk-pool-sbtc-fake-v-1-1 SBTC_TOKEN daoToken amount
      (unwrap-panic minReceive)
    )
      success (ok (var-set totalBuys (+ (var-get totalBuys) u1)))
      error
      ERR_SWAP_FAILED
    )
  )
)

(define-public (sell-dao-token
    (daoToken <sip010-trait>)
    (amount uint)
    (minReceive (optional uint))
  )
  (let ((daoTokenContract (contract-of daoToken)))
    (asserts! (is-eq daoTokenContract DAO_TOKEN) ERR_INVALID_DAO_TOKEN)
    (asserts! (is-some minReceive) ERR_MIN_RECEIVE_REQUIRED)
    (match (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2
      swap-y-for-x .xyk-pool-sbtc-fake-v-1-1 SBTC_TOKEN daoToken amount
      (unwrap-panic minReceive)
    )
      success (ok (var-set totalSells (+ (var-get totalSells) u1)))
      error
      ERR_SWAP_FAILED
    )
  )
)

;; read-only functions

(define-read-only (get-contract-info)
  {
    self: SELF,
    deployedBurnBlock: DEPLOYED_BURN_BLOCK,
    deployedStacksBlock: DEPLOYED_STACKS_BLOCK,
    bitflowCore: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2,
    swapContract: .xyk-pool-sbtc-fake-v-1-1,
    daoToken: DAO_TOKEN,
  }
)

(define-read-only (get-swap-info)
  {
    totalBuys: (var-get totalBuys),
    totalSells: (var-get totalSells),
    totalSwaps: (+ (var-get totalBuys) (var-get totalSells)),
  }
)
