---
title: "Trait zststx-v1-2"
draft: true
---
```
(use-trait ft .ft-mint-trait.ft-mint-trait)
(use-trait sip10 .ft-trait.ft-trait)
(use-trait oracle-trait .oracle-trait.oracle-trait)

(impl-trait .a-token-trait.a-token-trait)
(impl-trait .ownable-trait.ownable-trait)

(define-constant ERR_UNAUTHORIZED (err u14401))

(define-constant max-value (contract-call? .math get-max-value))
(define-constant one-8 u100000000)

(define-fungible-token zststx)

(define-data-var token-uri (string-utf8 256) u"https://token-meta.s3.eu-central-1.amazonaws.com/zstSTX.json")
(define-data-var token-name (string-ascii 32) "Zest stSTX")
(define-data-var token-symbol (string-ascii 32) "zstSTX")

(define-constant asset-addr 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
(define-constant decimals u6)

(define-read-only (get-total-supply)
  (ok (ft-get-supply zststx)))

(define-read-only (get-name)
  (ok (var-get token-name)))

(define-read-only (get-symbol)
  (ok (var-get token-symbol)))

(define-read-only (get-decimals)
  (ok decimals))

(define-read-only (get-token-uri)
  (ok (some (var-get token-uri))))

(define-read-only (get-balance (account principal))
  (let (
    (current-principal-balance (unwrap-panic (get-principal-balance account)))
  )
    (if (is-eq current-principal-balance u0)
      (ok u0)
      (let ((cumulated-balance
              (calculate-cumulated-balance
                account
                decimals
                asset-addr
                current-principal-balance
                decimals
              )))
        (ok cumulated-balance)
      )
    )
  )
)

(define-public (set-token-uri (value (string-utf8 256)))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR_UNAUTHORIZED)
    (ok (var-set token-uri value))))

(define-public (set-token-name (value (string-ascii 32)))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR_UNAUTHORIZED)
    (ok (var-set token-name value))))

(define-public (set-token-symbol (value (string-ascii 32)))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR_UNAUTHORIZED)
    (ok (var-set token-symbol value))))

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (try! (is-approved-contract contract-caller))
    (transfer-internal amount sender recipient none)
  )
)

(define-public (mint (amount uint) (recipient principal))
  (begin
    (try! (is-approved-contract contract-caller))
    (mint-internal amount recipient)
  )
)

(define-public (burn (amount uint) (owner principal))
  (begin
    (try! (is-approved-contract contract-caller))
    (burn-internal amount owner)
  )
)

(define-private (transfer-internal (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (match (ft-transfer? zststx amount sender recipient)
      response (begin
        (print memo)
        (ok response)
      )
      error (err error)
    )
  )
)

(define-private (mint-internal (amount uint) (owner principal))
  (ft-mint? zststx amount owner)
)

(define-private (burn-internal (amount uint) (owner principal))
  (ft-burn? zststx amount owner)
)

;; END sip-010 actions

(define-read-only (calculate-cumulated-balance
  (who principal)
  (lp-decimals uint)
  (asset <sip10>)
  (asset-balance uint)
  (asset-decimals uint))
  (let (
    (asset-principal (contract-of asset))
    (reserve-data (get-reserve-state asset-principal))
    (reserve-normalized-income
      (get-normalized-income
        (get current-liquidity-rate reserve-data)
        (get last-updated-block reserve-data)
        (get last-liquidity-cumulative-index reserve-data))))
      (mul-precision-with-factor
        asset-balance
        asset-decimals
        (div reserve-normalized-income (get-user-index who asset-principal)))
  )
)

(define-read-only (get-principal-balance (account principal))
  (ok 
    (+
      (unwrap-panic (contract-call? .zststx-v1-0 get-principal-balance account))
      (ft-get-balance zststx account)
    )
  )
)

(define-read-only (mul (x uint) (y uint)) (contract-call? .math-v1-2 mul x y))
(define-read-only (div (x uint) (y uint)) (contract-call? .math-v1-2 div x y))
(define-read-only (mul-precision-with-factor (a uint) (decimals-a uint) (b-fixed uint))
  (contract-call? .math-v1-2 mul-precision-with-factor a decimals-a b-fixed))

(define-read-only (get-reserve-state (asset principal))
  (unwrap-panic (contract-call? .pool-0-reserve-v1-2 get-reserve-state asset-addr))
)

(define-read-only (get-user-index (user principal) (asset principal))
  (unwrap-panic (contract-call? .pool-0-reserve-v1-2 get-user-index user asset))
)

(define-public (transfer-on-liquidation (amount uint) (from principal) (to principal))
  (begin
    (try! (is-approved-contract contract-caller))
    (try! (execute-transfer-internal amount from to))
    (ok amount)
  )
)

(define-public (burn-on-liquidation (amount uint) (owner principal))
  (begin
    (try! (is-approved-contract contract-caller))
    (let ((ret (try! (cumulate-balance-internal owner))))
      (try! (burn-internal amount owner))
      (if (is-eq (- (get current-balance ret) amount) u0)
        (begin
          (try! (contract-call? .pool-0-reserve-v1-2 set-user-reserve-as-collateral owner asset-addr false))
          (try! (contract-call? .pool-0-reserve-v1-2 remove-supplied-asset-ztoken owner asset-addr))
          (try! (contract-call? .pool-0-reserve-v1-2 reset-user-index owner asset-addr))
        )
        false
      )
      (ok amount)
    )
  )
)

(define-private (execute-transfer-internal
  (amount uint)
  (sender principal)
  (recipient principal)
  )
  (let (
    (from-ret (try! (cumulate-balance-internal sender)))
    (to-ret (try! (cumulate-balance-internal recipient)))
  )
    (if (is-eq sender recipient) 
      (ok true)
      (begin
        (try! (transfer-internal amount sender recipient none))
        (try! (contract-call? .pool-0-reserve-v1-2 add-supplied-asset-ztoken recipient asset-addr))
        (if (not (is-eq (- (get current-balance from-ret) amount) u0))
          (ok true)
          (begin
            (try! (contract-call? .pool-0-reserve-v1-2 set-user-reserve-as-collateral sender asset-addr false))
            (try! (contract-call? .pool-0-reserve-v1-2 remove-supplied-asset-ztoken sender asset-addr))
            (contract-call? .pool-0-reserve-v1-2 reset-user-index sender asset-addr)
          )
        )
      )
    )
  )
)

(define-public (cumulate-balance (account principal))
  (begin
    (try! (is-approved-contract contract-caller))
    (cumulate-balance-internal account)
  )
)

(define-private (cumulate-balance-internal (account principal))
  (let (
    (v0-balance (unwrap-panic (contract-call? .zststx get-principal-balance account)))
    (v1-balance (unwrap-panic (contract-call? .zststx-v1-0 get-principal-balance account)))
    (previous-balance (unwrap-panic (get-principal-balance account)))
    (balance-increase (- (unwrap-panic (get-balance account)) previous-balance))
    (reserve-state (get-reserve-state asset-addr))
    (new-user-index (get-normalized-income
        (get current-liquidity-rate reserve-state)
        (get last-updated-block reserve-state)
        (get last-liquidity-cumulative-index reserve-state))))
    (try! (contract-call? .pool-0-reserve-v1-2 set-user-index account asset-addr new-user-index))

    ;; transfer previous balance and mint to new token
    ;; can either have v0-balance or v1-balance, not both
    (if (> v0-balance u0)
      (begin
        (try! (mint-internal v0-balance account))
        (try! (contract-call? .zststx burn v0-balance account))
        true
      )
      (if (> v1-balance u0)
        (begin
          (try! (mint-internal v1-balance account))
          (try! (contract-call? .zststx-v1-0 burn v1-balance account))
          true
        )
        false
      )
    )

    (if (is-eq balance-increase u0)
      false
      (try! (mint-internal balance-increase account)))
    (ok {
      previous-user-balance: previous-balance,
      current-balance: (+ previous-balance balance-increase),
      balance-increase: balance-increase,
      index: new-user-index,
    })
  )
)

;; calculate income
(define-read-only (get-normalized-income
  (current-liquidity-rate uint)
  (last-updated-block uint)
  (last-liquidity-cumulative-index uint))
  (let (
    (cumulated
      (calculate-linear-interest
        current-liquidity-rate
        (- burn-block-height last-updated-block))))
    (mul cumulated last-liquidity-cumulative-index)
  )
)

(define-read-only (calculate-linear-interest
  (current-liquidity-rate uint)
  (delta uint))
  (let (
    (rate (get-rt-by-block current-liquidity-rate delta))
  )
    (+ one-8 rate)
  )
)

(define-read-only (get-rt-by-block (rate uint) (blocks uint))
  (contract-call? .math-v1-2 get-rt-by-block rate blocks)
)

;; -- ownable-trait --
(define-data-var contract-owner principal tx-sender)

(define-public (get-contract-owner)
  (ok (var-get contract-owner)))

(define-public (set-contract-owner (owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (print { type: "set-contract-owner-zststx", payload: owner })
    (ok (var-set contract-owner owner))))

(define-read-only (is-contract-owner (caller principal))
  (is-eq caller (var-get contract-owner)))

;; -- permissions
(define-map approved-contracts principal bool)

(define-public (set-approved-contract (contract principal) (enabled bool))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (ok (map-set approved-contracts contract enabled))
  )
)

(define-read-only (is-approved-contract (contract principal))
  (if (default-to false (map-get? approved-contracts contract))
    (ok true)
    ERR_UNAUTHORIZED))

```
