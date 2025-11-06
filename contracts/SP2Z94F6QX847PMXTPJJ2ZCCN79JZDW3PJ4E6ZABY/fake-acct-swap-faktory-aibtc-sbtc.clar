;; title: fake-acct-swap-faktory-fake-sbtc
;; version: 1.0.0
;; summary: Adapter to trade fake:sbtc on the Faktory DEX with an agent account.

;; traits

(impl-trait 'SP6382W148DH1J3BMEBGWENZ9AK8DXCN5XJPP01C.aibtc-agent-account-traits.aibtc-dao-swap-adapter)
(use-trait sip010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; constants
(define-constant DEPLOYED_BURN_BLOCK burn-block-height)
(define-constant DEPLOYED_STACKS_BLOCK stacks-block-height)
(define-constant SELF (as-contract tx-sender))

(define-constant DAO_TOKEN .fake-faktory)

;; error codes
(define-constant ERR_INVALID_DAO_TOKEN (err u2200))
(define-constant ERR_SWAP_FAILED (err u2201))
(define-constant ERR_QUOTE_FAILED (err u2202))
(define-constant ERR_SLIPPAGE_TOO_HIGH (err u2203))

;; data vars

(define-data-var totalBuys uint u0)
(define-data-var totalSells uint u0)

;; public functions

(define-public (buy-dao-token
    (daoToken <sip010-trait>)
    (amount uint)
    (minReceive (optional uint))
  )
  (let (
      (daoTokenContract (contract-of daoToken))
      (swapInInfo (unwrap! (contract-call? .fake-faktory-dex get-in amount) ERR_QUOTE_FAILED))
      (swapTokensOut (get tokens-out swapInInfo))
    )
    ;; verify token matches adapter config
    (asserts! (is-eq daoTokenContract DAO_TOKEN) ERR_INVALID_DAO_TOKEN)
    ;; if min-receive is set, check slippage
    (and
      (is-some minReceive)
      (asserts! (>= swapTokensOut (unwrap-panic minReceive))
        ERR_SLIPPAGE_TOO_HIGH
      )
    )
    ;; call faktory dex to perform the swap
    (match (contract-call? .fake-faktory-dex buy daoToken amount)
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
  (let (
      (daoTokenContract (contract-of daoToken))
      (swapOutInfo (unwrap! (contract-call? .fake-faktory-dex get-out amount)
        ERR_QUOTE_FAILED
      ))
      (swapTokensIn (get amount-in swapOutInfo))
    )
    ;; verify token matches adapter config
    (asserts! (is-eq daoTokenContract DAO_TOKEN) ERR_INVALID_DAO_TOKEN)
    ;; if min-receive is set, check slippage
    (and
      (is-some minReceive)
      (asserts! (>= swapTokensIn (unwrap-panic minReceive)) ERR_SLIPPAGE_TOO_HIGH)
    )
    ;; call faktory dex to perform the swap
    (match (contract-call? .fake-faktory-dex sell daoToken amount)
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
    swapContract: .fake-faktory-dex,
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
