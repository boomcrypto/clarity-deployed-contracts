;; @contract Reverse Bonds
;; @version 1.1

(use-trait ft-trait .sip-010-trait-ft-standard.sip-010-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant ERR-NOT-AUTHORIZED u5103001)
(define-constant ERR-CONTRACT-DISABLED u4101001)

(define-constant SNAPSHOT-BLOCK-HEIGHT u117892)

;; ------------------------------------------
;; Variables
;; ------------------------------------------

(define-data-var treasury-balances-block-height uint block-height)

(define-data-var contract-owner principal tx-sender)
(define-data-var contract-is-enabled bool false)

;; ------------------------------------------
;; Helpers
;; ------------------------------------------

;; Get unclaimed sLDN rewards
(define-read-only (get-staking-rewards (account principal))
  (let (
    (account-fragments (contract-call? .staked-lydian-token get-account-fragments account))
    (fragments-per-token (contract-call? .staked-lydian-token get-fragments-per-token))
    (current-balance (unwrap-panic (contract-call? .staked-lydian-token get-balance account)))

    (fragments (get fragments account-fragments))
    (new-balance (/ fragments fragments-per-token))
    (diff (- new-balance current-balance))
  )
    (ok diff)
  )
)

;; ------------------------------------------
;; Getters
;; ------------------------------------------

;; Current contract balances
(define-read-only (current-contract-balances)
  (let (
    (balance-usda (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance (as-contract tx-sender))))
    (balance-stx (stx-get-balance (as-contract tx-sender)))
    (balance-xbtc (unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance (as-contract tx-sender))))
    (balance-diko (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance (as-contract tx-sender))))
    (balance-alex (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex-v2 get-balance (as-contract tx-sender))))
  )
    (ok {
      usda: balance-usda,
      stx: balance-stx,
      xbtc: balance-xbtc,
      diko: balance-diko,
      alex: balance-alex 
    })
  )
)

;; Contract balances for snapshot
(define-read-only (snapshot-contract-balances)
  (let (
    (block-hash (unwrap-panic (get-block-info? id-header-hash (var-get treasury-balances-block-height))))
  )
    (at-block block-hash (current-contract-balances))
  )
)

;; Overview of current user balances
(define-read-only (current-user-amounts (user principal))
  (let (
    (balance-ldn (unwrap-panic (contract-call? .lydian-token get-balance user)))
    (balance-sldn (unwrap-panic (contract-call? .staked-lydian-token get-balance user)))
    (claimable-sldn (unwrap-panic (get-staking-rewards user)))
    (balance-wldn (unwrap-panic (contract-call? .wrapped-lydian-token get-balance user)))

    (sldn-index (contract-call? .staked-lydian-token get-index))
    (balance-wldn-as-ldn (/ (* balance-wldn sldn-index) u1000000))
  )
    (ok {
      ldn: balance-ldn,
      sldn: balance-sldn,
      claimable-sldn: claimable-sldn,
      wldn: balance-wldn,
      wldn-as-ldn: balance-wldn-as-ldn
    })
  )
)

;; Overview of user balances on snapshot
(define-read-only (snapshot-user-amounts (user principal))
  (let (
    (block-hash (unwrap-panic (get-block-info? id-header-hash SNAPSHOT-BLOCK-HEIGHT)))
  )
    (at-block block-hash (current-user-amounts user))
  )
)

;; Total balance (LDN + sLDN + claimable sLDN + wLDN) in LDN
(define-read-only (current-user-total-ldn (user principal))
  (let (
    (amounts (unwrap-panic (current-user-amounts user)))

    (balance-ldn (get ldn amounts))
    (balance-sldn (get sldn amounts))
    (claimable-sldn (get claimable-sldn amounts))
    (balance-wldn-as-ldn (get wldn-as-ldn amounts))
  )
    (ok (+ balance-ldn balance-sldn claimable-sldn balance-wldn-as-ldn))
  )
)

(define-read-only (snapshot-user-total-ldn (user principal))
  (let (
    (block-hash (unwrap-panic (get-block-info? id-header-hash SNAPSHOT-BLOCK-HEIGHT)))
  )
    (at-block block-hash (current-user-total-ldn user))
  )
)

;; Amounts user should receive based on current LDN
(define-read-only (current-user-receive (user principal))
  (let (
    (user-amount (unwrap-panic (current-user-total-ldn user)))
    (total-amount (unwrap-panic (snapshot-total-ldn)))
    (token-balances (unwrap-panic (snapshot-contract-balances)))
  )
    (ok {
      usda: (/ (* user-amount (get usda token-balances)) total-amount),
      stx: (/ (* user-amount (get stx token-balances)) total-amount),
      xbtc: (/ (* user-amount (get xbtc token-balances)) total-amount),
      diko: (/ (* user-amount (get diko token-balances)) total-amount),
      alex: (/ (* user-amount (get alex token-balances)) total-amount) 
    })
  )
)

;; Amounts user should receive based on snapshot data
(define-read-only (snapshot-user-receive (user principal))
  (let (
    (user-amount (unwrap-panic (snapshot-user-total-ldn user)))
    (total-amount (unwrap-panic (snapshot-total-ldn)))
    (token-balances (unwrap-panic (snapshot-contract-balances)))
  )
    (ok {
      usda: (/ (* user-amount (get usda token-balances)) total-amount),
      stx: (/ (* user-amount (get stx token-balances)) total-amount),
      xbtc: (/ (* user-amount (get xbtc token-balances)) total-amount),
      diko: (/ (* user-amount (get diko token-balances)) total-amount),
      alex: (/ (* user-amount (get alex token-balances)) total-amount) 
    })
  )
)

;; Get LDN from liquidity pool
(define-read-only (snapshot-pooled-ldn)
  (let (
    (block-hash (unwrap-panic (get-block-info? id-header-hash SNAPSHOT-BLOCK-HEIGHT)))
    (pooled-ldn (unwrap-panic (at-block block-hash (contract-call? .lydian-token get-balance .arkadiko-swap-v2-1))))
  )
    (ok pooled-ldn)
  )
)

;; Total LDN at time of snapshot, minus LDN in liquidity pool
(define-read-only (snapshot-total-ldn)
  (let (
    (block-hash (unwrap-panic (get-block-info? id-header-hash SNAPSHOT-BLOCK-HEIGHT)))
    (supply-ldn (unwrap-panic (at-block block-hash (contract-call? .lydian-token get-total-supply))))
  )
    (ok (- supply-ldn (unwrap-panic (snapshot-pooled-ldn))))
  )
)

;; ------------------------------------------
;; Reverse bond
;; ------------------------------------------

(define-public (reverse-bond)
  (begin
    (asserts! (var-get contract-is-enabled) (err ERR-CONTRACT-DISABLED))
    (reverse-bond-helper)
  )
)

(define-public (reverse-bond-owner)
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (reverse-bond-helper)
  )
)

;; Execute
(define-private (reverse-bond-helper)
  (let (
    (receiver tx-sender)

    (snapshot-user-ldn (unwrap-panic (snapshot-user-total-ldn receiver)))
    (current-user-ldn (unwrap-panic (current-user-total-ldn receiver)))

    (ldn-to-burn (if (> snapshot-user-ldn current-user-ldn)
      current-user-ldn
      snapshot-user-ldn
    ))

    (user-amounts (if (> snapshot-user-ldn current-user-ldn)
      (unwrap-panic (current-user-amounts receiver))
      (unwrap-panic (snapshot-user-amounts receiver))
    ))

    (to-receive (if (> snapshot-user-ldn current-user-ldn)
      (unwrap-panic (current-user-receive receiver))
      (unwrap-panic (snapshot-user-receive receiver))
    ))

  )
    ;; Transfer and burn
    (if (> (get ldn user-amounts) u0)
      (begin
        (try! (contract-call? .lydian-token transfer (get ldn user-amounts) receiver (as-contract tx-sender) none))
        (try! (as-contract (contract-call? .lydian-token burn tx-sender (get ldn user-amounts))))
      )
      true
    )
    (if (> (get sldn user-amounts) u0)
      (begin
        (try! (contract-call? .staked-lydian-token transfer (get sldn user-amounts) receiver (as-contract tx-sender) none))
        (try! (as-contract (contract-call? .staked-lydian-token burn tx-sender (get sldn user-amounts))))
      )
      true
    )
    (if (> (get wldn user-amounts) u0)
      (begin
        (try! (contract-call? .wrapped-lydian-token transfer (get wldn user-amounts) receiver (as-contract tx-sender) none))
        (try! (as-contract (contract-call? .wrapped-lydian-token burn tx-sender (get wldn user-amounts))))
      )
      true
    )

    ;; Get tokens
    (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer (get usda to-receive) tx-sender receiver none)))
    (try! (as-contract (stx-transfer? (get stx to-receive) tx-sender receiver)))
    (try! (as-contract (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin transfer (get xbtc to-receive) tx-sender receiver none)))
    (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token transfer (get diko to-receive) tx-sender receiver none)))
    (try! (as-contract (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex-v2 transfer (get alex to-receive) tx-sender receiver none)))

    (ok true)
  )
)

;; ------------------------------------------
;; Admin
;; ------------------------------------------

(define-public (set-contract-is-enabled (enabled bool))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (var-set contract-is-enabled enabled)
    (ok true)
  )
)

(define-public (set-treasury-balances-block-height (height uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (var-set treasury-balances-block-height height)
    (ok true)
  )
)

(define-public (get-stx-tokens (recipient principal))
  (let (
    (balance (stx-get-balance (as-contract tx-sender)))
  )
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (try! (as-contract (stx-transfer? balance tx-sender recipient)))
    (ok true)
  )
)

(define-public (get-sip10-tokens (token-trait <ft-trait>) (recipient principal))
  (let (
    (balance (unwrap-panic (contract-call? token-trait get-balance (as-contract tx-sender))))
  )
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (try! (as-contract (contract-call? token-trait transfer balance tx-sender recipient none)))
    (ok true)
  )
)

;; ------------------------------------------
;; STX
;; ------------------------------------------

(define-public (stx-transfer (amount uint) (receiver principal))
  (stx-transfer? amount tx-sender receiver)
)

(define-read-only (stx-balance (user principal))
  (stx-get-balance user)
)
