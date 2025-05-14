---
title: "Trait liquidator-v1"
draft: true
---
```
;; TRAITS
(use-trait token-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; CONSTANTS
(define-constant SUCCESS (ok true))
(define-constant MARKET-TOKEN-DECIMALS (contract-call? .constants-v1 get-market-token-decimals))
(define-constant SCALING-FACTOR (contract-call? .constants-v1 get-scaling-factor))

;; ERROR VALUES
(define-constant ERR-DIVIDE-BY-ZERO (err u30000))
(define-constant ERR-INTEREST-PARAMS (err u30001))
(define-constant ERR-NO-POSITION (err u30002))
(define-constant ERR-USER-POSITION-HEALTHY (err u30003))
(define-constant ERR-LIQUIDATED-TOO-MUCH (err u30004))
(define-constant ERR-COLLATERAL-NOT-SUPPORTED (err u30005))
(define-constant ERR-INSUFFICIENT-BALANCE (err u30006))
(define-constant ERR-SLIPPAGE (err u30007))
(define-constant ERR-INVALID-ORACLE-PRICE (err u30008))
(define-constant ERR-MISSING-MARKET-PRICE (err u30009))

;; PUBLIC FUNCTIONS 
(define-public (batch-liquidate (pyth-price-feed-data (optional (buff 8192))) (collateral <token-trait>) (batch (list 20 (optional {
  user: principal,
  liquidator-repay-amount: uint,
  min-collateral-expected: uint
}))))
  (begin
  (try! (contract-call? .pyth-adapter-v1 update-pyth pyth-price-feed-data))
  (try! (accrue-interest))
  (try! (get res (fold fold-execute-liquidation batch {collateral: collateral, res: (ok true)})))
  SUCCESS
))

(define-public (liquidate-collateral (pyth-price-feed-data (optional (buff 8192))) (collateral <token-trait>) (user principal) (liquidator-repay-amount uint) (min-collateral-expected uint))
  (begin
    (try! (contract-call? .pyth-adapter-v1 update-pyth pyth-price-feed-data))
    (try! (accrue-interest))
    (execute-liquidation user collateral liquidator-repay-amount min-collateral-expected)
))

;; READ-ONLY FUNCTIONS
(define-read-only (user-collateral-repayment-info 
    (collateral <token-trait>) 
    (user principal)
    (user-debt uint)
    (maybe-market-asset-price (optional uint))
    (maybe-total-liquid-ltv (optional uint))
    (maybe-collateral-value (optional uint))
  )
  (let (
      (position-data (unwrap! (try! (check-account-unhealthy user maybe-market-asset-price maybe-total-liquid-ltv)) ERR-USER-POSITION-HEALTHY))
      (total-liquid-ltv (get total-liquid-ltv position-data))
      (collateral-token (contract-of collateral))
      (collateral-value (match maybe-collateral-value value value (get-collateral-value collateral-token user (try! (contract-call? .pyth-adapter-v1 read-price collateral-token)))))
      (collateral-info (unwrap! (contract-call? .state-v1 get-collateral collateral-token) ERR-COLLATERAL-NOT-SUPPORTED))
      (liquidation-premium (get liquidation-premium collateral-info))
      (collateral-liquidation-ltv (get liquidation-ltv collateral-info))
      (repayment-info (try! (calculate-repayment-info user-debt total-liquid-ltv collateral-value liquidation-premium collateral-liquidation-ltv)))
    )
    (ok (get repay-allowed repayment-info))
  )
)

(define-read-only (account-health (user principal) (maybe-market-asset-price (optional uint)) (maybe-total-liquid-ltv (optional uint)))
  (let (
      (borrow-params (contract-call? .state-v1 get-borrow-repay-params user))
      (position (unwrap! (get user-position borrow-params) ERR-NO-POSITION))
      ;; get user current debt
      (debt-params (contract-call? .state-v1 get-debt-params))
      (current-debt (contract-call? .math-v1 convert-to-debt-assets debt-params (get debt-shares position) true))
      (market-asset-price (match maybe-market-asset-price price price (unwrap! (contract-call? .pyth-adapter-v1 read-price .mock-usdc) ERR-MISSING-MARKET-PRICE)))
      (current-debt-adjusted (contract-call? .math-v1 get-market-asset-value market-asset-price current-debt))
      (position-collaterals (get collaterals position))
      (total-liquid-ltv (match maybe-total-liquid-ltv ltv 
        ltv
        (let (
          (collateral-prices (try! (contract-call? .pyth-adapter-v1 bulk-read-collateral-prices position-collaterals)))
        )
          (if (is-eq (len position-collaterals) u0) 
            u0
            (fold + (map iterate-collateral-value-ltv position-collaterals (
            list user user user user user user user user user user
            ) collateral-prices) u0)
          )  
      )))
      (position-health (if (> current-debt-adjusted u0) (/ (* total-liquid-ltv SCALING-FACTOR) current-debt-adjusted) u1))
    )
    (ok {
      position-health: position-health,
      total-liquid-ltv: total-liquid-ltv,
      current-debt: current-debt,
      borrowed-amount: (get borrowed-amount position),
      current-debt-adjusted: current-debt-adjusted,
      collaterals: (get collaterals position),
      total-borrowed-amount: (get total-borrowed-amount borrow-params)
    })
))

(define-read-only (get-liquidation-data 
  (user principal)
  (collateral <token-trait>)
  (liquidator-repay-amount uint)
  (maybe-market-asset-price (optional uint))
  (maybe-total-liquid-ltv (optional uint))
  (maybe-collateral-value (optional uint))
  (maybe-collateral-price (optional uint)))

  (let (
    (liquidation-info (try! (get-liquidation-info 
      user
      collateral
      liquidator-repay-amount
      maybe-market-asset-price
      maybe-total-liquid-ltv
      maybe-collateral-value
      maybe-collateral-price
  )))) (ok {liquidation-info: (get liquidation-info liquidation-info)})))

(define-read-only
  (liquidate
    (debt uint)
    (total-collaterals-liquid-value uint)
    (collateral-value uint)
    (liquidation-discount uint)
    (collateral-liquid-ltv uint)
    (deposited-collateral-amount uint)
    (collateral-price uint)
    (liquidator-repay-amount uint)
    (collateral-decimals uint)
  )
  (let
    (
      (repayment-info (try! (calculate-repayment-info debt total-collaterals-liquid-value collateral-value liquidation-discount collateral-liquid-ltv)))
      (repay-allowed (get repay-allowed repayment-info))
      (repay-amount-without-discount (get repay-amount-without-discount repayment-info))
      ;; if the total repay amount is <= liquidator repay amount, return total repay amount
      ;; else return liquidator repay amount
      (repay-amount (if (<= repay-allowed liquidator-repay-amount) repay-allowed liquidator-repay-amount))
      (collateral-to-give (if (or (is-eq repay-amount-without-discount repay-amount) (is-eq u0 repay-amount))
        deposited-collateral-amount
        (try! (calc-collateral-to-give repay-amount liquidation-discount collateral-price collateral-decimals))
      ))
    )
    (ok {repay-amount: repay-amount, collateral-to-give: collateral-to-give})
))


;; PRIVATE FUNCTIONS
(define-private (get-liquidate-params 
  (user principal)
  (collateral <token-trait>)
  (liquidator-repay-amount uint)
  (maybe-market-asset-price (optional uint))
  (maybe-total-liquid-ltv (optional uint))
  (maybe-collateral-value (optional uint))
  (maybe-collateral-price (optional uint))
)
  (let (
    (position-data (unwrap! (try! (check-account-unhealthy user maybe-market-asset-price maybe-total-liquid-ltv)) ERR-USER-POSITION-HEALTHY))
    (current-debt-adjusted (get current-debt-adjusted position-data))
    (total-liquid-ltv (get total-liquid-ltv position-data))
    (collateral-token (contract-of collateral))
    (collateral-price (match maybe-collateral-price price price (unwrap! (contract-call? .pyth-adapter-v1 read-price collateral-token) ERR-INVALID-ORACLE-PRICE)))
    (collateral-value (match maybe-collateral-value value value (get-collateral-value collateral-token user collateral-price)))
    (collateral-info (unwrap! (contract-call? .state-v1 get-collateral collateral-token) ERR-COLLATERAL-NOT-SUPPORTED))
    (liquidation-discount (get liquidation-premium collateral-info))
    (collateral-liquid-ltv (get liquidation-ltv collateral-info))
    (user-balance (unwrap! (get amount (contract-call? .state-v1 get-user-collateral user collateral-token))  ERR-INSUFFICIENT-BALANCE))
    (collateral-decimals (get decimals collateral-info))
  )
    (ok {
      position-data: position-data,
      collateral-value: collateral-value,
      collateral-info: collateral-info,
      user-balance: user-balance,
      collateral-price: collateral-price
    })
  )
)

(define-private (get-liquidation-info 
  (user principal)
  (collateral <token-trait>)
  (liquidator-repay-amount uint)
  (maybe-market-asset-price (optional uint))
  (maybe-total-liquid-ltv (optional uint))
  (maybe-collateral-value (optional uint))
  (maybe-collateral-price (optional uint))
) 
  (let (
    (liquidation-params (try! (get-liquidate-params user collateral liquidator-repay-amount maybe-market-asset-price maybe-total-liquid-ltv maybe-collateral-value maybe-collateral-price)))
    ;; check position is unhealthy
    (position-data (get position-data liquidation-params))
    (user-borrowed-amount (get borrowed-amount position-data))
    ;; get user current debt
    (current-debt (get current-debt position-data))
    (current-debt-adjusted (get current-debt-adjusted position-data))
    (user-collaterals (get collaterals position-data))
    (bad-debt (match maybe-collateral-price price 
      false
      (let ((total-collateral-value-and-reward (get-user-total-collateral-value-and-reward user user-collaterals (try! (contract-call? .pyth-adapter-v1 bulk-read-collateral-prices user-collaterals)))))
        (is-bad-debt current-debt-adjusted total-collateral-value-and-reward))))
    ;; total collaterals value * collateral liquid ltv
    (total-liquid-ltv (get total-liquid-ltv position-data))
    ;; user collateral value and amount
    (collateral-value (get collateral-value liquidation-params))
    ;; revert if the collateral isn't supported
    (collateral-info (get collateral-info liquidation-params))
    ;; collateral decimals
    (collateral-decimals (get decimals collateral-info))
    ;; collateral liquidation premium
    (liquidation-premium (get liquidation-premium collateral-info))
    ;; collateral liquidation ltv
    (liquidation-ltv (get liquidation-ltv collateral-info))
    ;; user collateral amount
    (user-balance (get user-balance liquidation-params))
    (collateral-price (get collateral-price liquidation-params))
    ;; get liquidation info for the user
    (liquidation-info (try! (liquidate
        current-debt-adjusted
        total-liquid-ltv
        collateral-value
        liquidation-premium
        liquidation-ltv
        user-balance
        collateral-price
        liquidator-repay-amount
        collateral-decimals
    ))))
    (ok {
      liquidation-info: liquidation-info,
      current-debt: current-debt,
      user-borrowed-amount: user-borrowed-amount,
      position-data: position-data,
      user-balance: user-balance,
      bad-debt: bad-debt
    })
  )
)

(define-private (execute-liquidation (user principal) (collateral <token-trait>) (liquidator-repay-amount uint) (min-collateral-expected uint))
  (let
      (
        (collateral-token (contract-of collateral))      
        ;; get liquidation info for the user
        (liquidation-res (try! (get-liquidation-info user collateral liquidator-repay-amount none none none none)))
        (liquidation-info (get liquidation-info liquidation-res))
        (current-debt (get current-debt liquidation-res))
        (user-borrowed-amount (get user-borrowed-amount liquidation-res))
        (position-data (get position-data liquidation-res))
        (user-balance (get user-balance liquidation-res))
        (bad-debt (get bad-debt liquidation-res))
        ;; get open interest
        (open-interest-info (contract-call? .state-v1 get-open-interest))
        (open-interest (+ (get lp-open-interest open-interest-info) (get staked-open-interest open-interest-info) (get protocol-open-interest open-interest-info)))
        ;; get collateral to give to liquidator
        (collateral-to-give (get collateral-to-give liquidation-info))
        ;; get repay amount
        (repay-amount (get repay-amount liquidation-info))
        ;; convert repay amount to debt shares
        (debt-params (contract-call? .state-v1 get-debt-params))
        (paid-shares (contract-call? .math-v1 convert-to-debt-shares debt-params repay-amount false))
        (interest-portion (contract-call? .math-v1 calculate-interest-portions current-debt user-borrowed-amount repay-amount))
        (principal-part (get principal-part interest-portion))
        (interest-part (get interest-part interest-portion))
        (total-borrowed-amount (get total-borrowed-amount position-data))
        (open-interest-without-principal (- open-interest total-borrowed-amount))
        (lp-open-interest-without-principal (- (get lp-open-interest open-interest-info) total-borrowed-amount))
        ;; calculate liquidity provider and protocol debt repaid
        (lp-part (contract-call? .math-v1 safe-div (* interest-part lp-open-interest-without-principal) open-interest-without-principal))
        (protocol-part (contract-call? .math-v1 safe-div (* interest-part (get protocol-open-interest open-interest-info)) open-interest-without-principal))
        (staked-part (contract-call? .math-v1 safe-div (* interest-part (get staked-open-interest open-interest-info)) open-interest-without-principal))
        (asset-params (contract-call? .state-v1 get-lp-params))
        (staked-lp-tokens (contract-call? .math-v1 convert-to-shares asset-params staked-part false))
        (updated-borrowed-amount (contract-call? .math-v1 safe-sub user-borrowed-amount principal-part))
        (updated-total-borrowed-amount (contract-call? .math-v1 safe-sub total-borrowed-amount principal-part))
        (remaining-collateral-balance (- user-balance collateral-to-give))
        (updated-collaterals-list (if (is-eq remaining-collateral-balance u0)
          (get new-list (contract-call? .state-v1 remove-item (get collaterals position-data) collateral-token))
          (get collaterals position-data)
        ))
      )
      ;; update state
      (try! (contract-call? .state-v1 update-liquidate-collateral-state collateral {
        liquidator: contract-caller,
        user: user,
        collateral-to-give: collateral-to-give,
        repay-amount: repay-amount,
        paid-shares: paid-shares,
        lp-part: (+ principal-part lp-part),
        protocol-part: protocol-part,
        staked-part: staked-part,
        staked-lp-tokens: staked-lp-tokens,
        borrowed-amount: updated-borrowed-amount,
        total-borrowed-amount: updated-total-borrowed-amount,
        staking-contract: .staking-v1,
        remaining-balance: remaining-collateral-balance,
        updated-collaterals: updated-collaterals-list
      }))
      (try! (contract-call? .staking-v1 increase-lp-staked-balance staked-lp-tokens))
      ;; slippage check
      (asserts! (>= collateral-to-give min-collateral-expected) ERR-SLIPPAGE)
      ;; check account health post liquidation
      (asserts! (<= (get position-health (try! (account-health user none none))) SCALING-FACTOR) ERR-LIQUIDATED-TOO-MUCH)
      ;; socialize debt if bad debt
      (try! (socialize-bad-debt bad-debt user))
      (print {
          collateral: collateral-token,
          liquidator: contract-caller,
          user: user,
          liquidated-collateral-amount: collateral-to-give,
          repaid-amount: repay-amount,
          repaid-shares: paid-shares,
          action: "liquidate-collateral"
      })
      SUCCESS
    )
)

(define-private (fold-execute-liquidation (maybe-liquidation-data (optional {
  user: principal,
  liquidator-repay-amount: uint,
  min-collateral-expected: uint
})) (result {collateral: <token-trait>, res: (response bool uint)}))
  (let (
      (collateral (get collateral result))
      (prev-result (get res result))
    )
    
    (if (is-err prev-result)
      result
      (match maybe-liquidation-data liquidation-data
        {collateral: (get collateral result), res: (execute-liquidation (get user liquidation-data) (get collateral result) (get liquidator-repay-amount liquidation-data) (get min-collateral-expected liquidation-data))}
        result
      )
    )
  )
)

(define-private (calculate-repayment-info
    (debt uint)
    (total-collaterals-liquid-value uint)
    (collateral-value uint)
    (liquidation-discount uint)
    (collateral-liquid-ltv uint)
  )
  (let
    (
      (denominator (-
          SCALING-FACTOR
          (try! (safe-div (* (+ SCALING-FACTOR liquidation-discount) collateral-liquid-ltv) SCALING-FACTOR))
      ))
      (total-repay-amount (try! (safe-div (* (- debt total-collaterals-liquid-value) SCALING-FACTOR) denominator)))
      (repay-amount-without-discount (/ (* collateral-value SCALING-FACTOR) (+ liquidation-discount SCALING-FACTOR)))
      (repay-allowed (if (< total-repay-amount repay-amount-without-discount) total-repay-amount repay-amount-without-discount))
    )
    (ok {repay-allowed: repay-allowed, repay-amount-without-discount: repay-amount-without-discount})
))

(define-private (calc-collateral-to-give (repay-amount uint) (liquidation-discount uint) (collateral-price uint) (collateral-decimals uint))
  (let
    (
      (repay-amount-with-discount (/ (* repay-amount (+ SCALING-FACTOR liquidation-discount)) SCALING-FACTOR))
      (collateral-amount (try! (safe-div (* repay-amount-with-discount SCALING-FACTOR) collateral-price)))
      (decimal-corrected-collateral (contract-call? .math-v1 to-fixed collateral-amount MARKET-TOKEN-DECIMALS collateral-decimals))
    )
    (ok decimal-corrected-collateral)
))

(define-private (safe-div (x uint) (y uint))
  (begin
    (asserts! (> y u0) ERR-DIVIDE-BY-ZERO)
    (ok (/ x y))
))

(define-private (accrue-interest)
  (let (
    (accrue-interest-params (unwrap! (contract-call? .state-v1 get-accrue-interest-params) ERR-INTEREST-PARAMS))
    (accrued-interest (try! (contract-call? .linear-kinked-ir-v1 accrue-interest
      (get last-accrued-block-time accrue-interest-params)
      (get lp-interest accrue-interest-params)
      (get staked-interest accrue-interest-params)
      (try! (contract-call? .staking-reward-v1 calculate-staking-reward-percentage (contract-call? .staking-v1 get-active-staked-lp-tokens)))
      (get protocol-interest accrue-interest-params)
      (get protocol-reserve-percentage accrue-interest-params)
      (get total-assets accrue-interest-params)))
    )
  )
  (contract-call? .state-v1 set-accrued-interest accrued-interest)
))

(define-private (check-account-unhealthy (user principal) (maybe-market-asset-price (optional uint)) (maybe-total-liquid-ltv (optional uint)))
  (let ((health-data (try! (account-health user maybe-market-asset-price maybe-total-liquid-ltv))))
    (if (< (get position-health health-data) SCALING-FACTOR)
      (ok (some health-data))
      (ok none)
    )
))

(define-private (get-collateral-value (collateral principal) (user principal) (collateral-price uint))
  (contract-call? .math-v1 to-fixed
    (/
      (* 
        (default-to u0 (get amount (contract-call? .state-v1 get-user-collateral user collateral)))
        collateral-price
      )
      SCALING-FACTOR
    ) 
    (default-to u8 (get decimals (contract-call? .state-v1 get-collateral collateral)))
    MARKET-TOKEN-DECIMALS
  )
)

(define-private (iterate-collateral-value-ltv (collateral principal) (user principal) (collateral-price uint))
  (let
    (
      (collateral-info (contract-call? .state-v1 get-collateral collateral))
      (user-collateral-value (get-collateral-value collateral user collateral-price))
      (liquidation-ltv (default-to u0 (get liquidation-ltv collateral-info)))
    )
    (/ (* user-collateral-value liquidation-ltv) SCALING-FACTOR)
))

(define-private (iterate-collateral-value-and-reward (collateral principal) (user principal) (collateral-price uint))
  (let
    (
      (collateral-info (contract-call? .state-v1 get-collateral collateral))
      (user-collateral-value (get-collateral-value collateral user collateral-price))
      (liquidation-premium (default-to u0 (get liquidation-premium collateral-info)))
    )
    {collateral-value: user-collateral-value, collateral-reward: (/ (* user-collateral-value liquidation-premium) SCALING-FACTOR)}
))

(define-private (fold-iterate-collateral-value-and-reward (a {collateral-value: uint, collateral-reward: uint}) (b {collateral-value: uint, collateral-reward: uint}))
  {
    collateral-value: (+ (get collateral-value a) (get collateral-value b)),
    collateral-reward: (+ (get collateral-reward a) (get collateral-reward b)),
  }
)

(define-private (get-user-total-collateral-value-and-reward (user principal) (position-collaterals (list 10 principal)) (collateral-prices (list 10 uint)))
  (fold fold-iterate-collateral-value-and-reward 
    (map iterate-collateral-value-and-reward position-collaterals (
        list user user user user user user user user user user
    ) collateral-prices) {collateral-value: u0, collateral-reward: u0}
))

(define-private (is-bad-debt (current-debt uint) (collateral-value-and-reward {collateral-value: uint, collateral-reward: uint}))
  ;; if collateral_value < debt + reward, it is a bad debt
  ;; if so, ensure if the liquidator is a bad debt liquidator else do not allow liquidation
  (let (
      (collateral-value (get collateral-value collateral-value-and-reward))
      (collateral-reward (get collateral-reward collateral-value-and-reward))
    ) 
    (if (< collateral-value (+ current-debt collateral-reward)) true false)
))

(define-private (get-user-total-collateral-value (user principal) (position-collaterals (list 10 principal)) (collateral-prices (list 10 uint)))
  (fold +
    (map get-collateral-value position-collaterals (
        list user user user user user user user user user user
    ) collateral-prices) u0
))

(define-private (socialize-bad-debt (bad-debt bool) (user principal))
  (if (not bad-debt) 
    SUCCESS
    (let (
        (repay-params (contract-call? .state-v1 get-borrow-repay-params user))
        (position (unwrap! (get user-position repay-params) ERR-NO-POSITION))
        (total-borrowed-amount (get total-borrowed-amount repay-params))
        (user-collaterals (get collaterals position))
        (collateral-prices (try! (contract-call? .pyth-adapter-v1 bulk-read-collateral-prices user-collaterals)))
        (total-collateral-value (get-user-total-collateral-value user user-collaterals collateral-prices))
        (debt-params (contract-call? .state-v1 get-debt-params))
        (remaining-debt (contract-call? .math-v1 convert-to-debt-assets debt-params (get debt-shares position) true))
      )
      
      (if (> total-collateral-value u0) 
        SUCCESS
        (let (
            (user-borrowed-amount (get borrowed-amount position))
            (open-interest-data (contract-call? .state-v1 get-open-interest))
            (lp-open-interest-val (get lp-open-interest open-interest-data))
            (protocol-open-interest-val (get protocol-open-interest open-interest-data))
            (staked-open-interest-val (get staked-open-interest open-interest-data))
            (total-open-interest (+ lp-open-interest-val protocol-open-interest-val staked-open-interest-val))
            (interest-portion (contract-call? .math-v1 calculate-interest-portions remaining-debt user-borrowed-amount remaining-debt))
            (principal-part (get principal-part interest-portion))
            (interest-part (get interest-part interest-portion))
            (open-interest-without-principal (- total-open-interest total-borrowed-amount))
            (lp-open-interest-without-principal (- lp-open-interest-val total-borrowed-amount))
            (lp-part (+ principal-part (contract-call? .math-v1 safe-div (* interest-part lp-open-interest-without-principal) open-interest-without-principal)))
            (protocol-part (contract-call? .math-v1 safe-div (* interest-part protocol-open-interest-val) open-interest-without-principal))
            (staked-part (contract-call? .math-v1 safe-div (* interest-part staked-open-interest-val) open-interest-without-principal))
            (updated-total-borrowed-amount (contract-call? .math-v1 safe-sub total-borrowed-amount principal-part))
            (staked-lp-tokens (contract-call? .staking-v1 get-total-staked-lp-tokens))
            (burned-staking-lp-tokens (try! (contract-call? .state-v1 socialize-user-bad-debt user remaining-debt lp-part staked-part protocol-part updated-total-borrowed-amount .staking-v1 staked-lp-tokens)))
          )
          (print {
            user: user,
            action: "socialized-bad-debt",
            amount: remaining-debt,
            lp-part: lp-part,
            staked-part: staked-part,
            protocol-part: protocol-part,
            updated-total-borrowed-amount: updated-total-borrowed-amount,
            burned-staking-lp-tokens: burned-staking-lp-tokens
          })
          (asserts! (<= burned-staking-lp-tokens u0) (contract-call? .staking-v1 slash-total-staked-lp-tokens burned-staking-lp-tokens))
          SUCCESS
      ))
    )
))

```
