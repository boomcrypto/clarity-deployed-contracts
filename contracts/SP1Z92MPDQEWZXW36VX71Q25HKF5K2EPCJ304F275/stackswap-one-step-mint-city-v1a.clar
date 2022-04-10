(use-trait sip-010-token .sip-010-v1a.sip-010-trait)
(use-trait liquidity-token .liquidity-token-trait-v4c.liquidity-token-trait)
(use-trait initable-city .initializable-city-token-trait-v1a.initializable-city-token-trait)
(use-trait initable-liquidity .initializable-trait-v1b.initializable-liquidity-token-trait)
(use-trait stackswap-swap .stackswap-swap-trait-v1c.stackswap-swap)

(define-constant ERR_INVALID_ROUTER (err u4001))
(define-constant ERR_DAO_ACCESS (err u4003))
(define-constant ERR_LP_TOKEN_NOT_VALID (err u4004))
(define-constant ERR_NO_CITY_TOKEN (err u4006))
(define-constant ERR_NO_LP_TOKEN (err u4007))
(define-constant ERR_CALLER_MISMATCH (err u4008))

(define-data-var city-token-list (list 200 principal) (list))

(define-data-var rem-item principal tx-sender)

(define-read-only (get-city-token-list)
  (ok (var-get city-token-list)))

(define-private (remove-filter (a principal)) (not (is-eq a (var-get rem-item))))

(define-public (remove-city-token (ritem principal))
  (begin
    (try! (is-valid-caller contract-caller))
    (try! (remove-city-token-inner ritem))
    (ok true)
  )
)

(define-private (remove-city-token-inner (ritem principal))
  (begin
    (var-set rem-item ritem)
    (unwrap! (index-of (var-get city-token-list) ritem)  ERR_NO_CITY_TOKEN)
    (var-set city-token-list (unwrap-panic (as-max-len? (filter remove-filter (var-get city-token-list)) u200)))
    (ok true)
  )
)

(define-public (add-city-token (new-token principal))
  (begin
    (try! (is-valid-caller contract-caller))
    (ok (var-set city-token-list (unwrap-panic (as-max-len? (append (var-get city-token-list) new-token) u200))))))


(define-public (add-city-tokens (new-tokens (list 100 principal)))
  (begin
    (try! (is-valid-caller contract-caller))
    (ok (var-set city-token-list (unwrap-panic (as-max-len? (concat (var-get city-token-list) new-tokens) u200))))))

(define-public (create-pair-new-city-token-with-stx (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>) (pair-name (string-ascii 32)) (x uint) (y uint) (token-y-init-trait <initable-city>) (token-liquidity-soft <initable-liquidity>)  (name-to-set (string-ascii 32)) (symbol-to-set (string-ascii 32)) (decimals-to-set uint) (uri-to-set (string-utf8 256)) (website-to-set (string-utf8 256))  (initial-amount uint)  (first-stacking-block-to-set uint) (reward-cycle-lengh-to-set uint) (token-reward-maturity-to-set uint) (coinbase-reward-to-set uint) (reserve-ratio uint) (minimum-mining-amount-to-set uint) (swap-contract <stackswap-swap>) )
  (begin
    (asserts! (is-eq (contract-of token-liquidity-trait) (contract-of token-liquidity-soft)) ERR_LP_TOKEN_NOT_VALID)
    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) ERR_INVALID_ROUTER)
    (try! (contract-call? token-y-init-trait initialize name-to-set symbol-to-set decimals-to-set uri-to-set website-to-set initial-amount first-stacking-block-to-set reward-cycle-lengh-to-set token-reward-maturity-to-set coinbase-reward-to-set reserve-ratio minimum-mining-amount-to-set))
    (try! (contract-call? .stackswap-one-step-mint-v5k create-pair-new-liquidity-token .wstx-token-v4a token-y-trait token-liquidity-trait pair-name x y token-liquidity-soft swap-contract))
    (try! (remove-city-token-inner (contract-of token-y-trait)))
    (ok true)
  )
)


(define-public (create-pair-new-city-token-with-stsw (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>) (pair-name (string-ascii 32)) (x uint) (y uint) (token-y-init-trait <initable-city>) (token-liquidity-soft <initable-liquidity>)  (name-to-set (string-ascii 32)) (symbol-to-set (string-ascii 32)) (decimals-to-set uint) (uri-to-set (string-utf8 256)) (website-to-set (string-utf8 256))  (initial-amount uint)  (first-stacking-block-to-set uint) (reward-cycle-lengh-to-set uint) (token-reward-maturity-to-set uint) (coinbase-reward-to-set uint)  (reserve-ratio uint) (minimum-mining-amount-to-set uint) (swap-contract <stackswap-swap>) )
  (begin
    (asserts! (is-eq (contract-of token-liquidity-trait) (contract-of token-liquidity-soft)) ERR_LP_TOKEN_NOT_VALID)
    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) ERR_INVALID_ROUTER)
    (try! (contract-call? token-y-init-trait initialize name-to-set symbol-to-set decimals-to-set uri-to-set website-to-set initial-amount first-stacking-block-to-set reward-cycle-lengh-to-set token-reward-maturity-to-set coinbase-reward-to-set reserve-ratio minimum-mining-amount-to-set))
    (try! (contract-call? .stackswap-one-step-mint-v5k create-pair-new-liquidity-token .stsw-token-v4a token-y-trait token-liquidity-trait pair-name x y token-liquidity-soft swap-contract))
    (try! (remove-city-token-inner (contract-of token-y-trait)))
    (ok true)
  )
)


(define-private (is-valid-caller (caller principal))
  (begin
    (asserts! (is-eq caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "lp-deployer"))) ERR_DAO_ACCESS)
    (ok true)
  )
)
