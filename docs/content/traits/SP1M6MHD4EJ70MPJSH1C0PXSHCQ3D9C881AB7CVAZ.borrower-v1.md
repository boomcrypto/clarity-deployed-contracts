---
title: "Trait borrower-v1"
draft: true
---
```
;; TRAITS
(use-trait token-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; ERRORS
(define-constant ERR-INTEREST-PARAMS (err u20000))
(define-constant ERR-INSUFFICIENT-FREE-LIQUIDITY (err u20001))
(define-constant ERR-MAX-LTV (err u20002))
(define-constant ERR-NO-POSITION (err u20003))
(define-constant ERR-NOT-ENOUGH-SHARES (err u20004))
(define-constant ERR-LIST-OVERFLOW (err u20005))
(define-constant ERR-INSUFFICIENT-BALANCE (err u20006))
(define-constant ERR-COLLATERAL-NOT-SUPPORTED (err u20007))
(define-constant ERR-MISSING-MARKET-PRICE (err u20008))

;; CONSTANTS
(define-constant SUCCESS (ok true))
(define-constant SCALING-FACTOR (contract-call? .constants-v1 get-scaling-factor))
(define-constant MARKET-TOKEN-DECIMALS (contract-call? .constants-v1 get-market-token-decimals))


;; PUBLIC FUNCTIONS
(define-public (borrow (pyth-price-feed-data (optional (buff 8192))) (amount uint) )
  (begin
    (try! (contract-call? .pyth-adapter-v1 update-pyth pyth-price-feed-data))
    (try! (accrue-interest))
    (asserts! (>= (contract-call? .state-v1 get-borrowable-balance) amount) ERR-INSUFFICIENT-FREE-LIQUIDITY)
    (let
      (
        ;; can't borrow if no collaterals were posted
        (borrow-params (contract-call? .state-v1 get-borrow-repay-params contract-caller))
        (position (unwrap! (get user-position borrow-params) ERR-NO-POSITION))
        (current-debt-shares (get debt-shares position))
        (debt-params (contract-call? .state-v1 get-debt-params))
        (current-debt (contract-call? .math-v1 convert-to-debt-assets debt-params current-debt-shares true))
        (new-debt-shares (contract-call? .math-v1 convert-to-debt-shares debt-params amount true))
        (total-user-debt-shares (+ new-debt-shares (get debt-shares position)))
        (position-collaterals (get collaterals position))
        (collateral-prices (try! (contract-call? .pyth-adapter-v1 bulk-read-collateral-prices position-collaterals)))
        (total-max-ltv (fold + (map iterate-collateral-value position-collaterals collateral-prices) u0))
        (new-current-debt (+ amount current-debt))
        (market-asset-price (unwrap! (contract-call? .pyth-adapter-v1 read-price 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc ) ERR-MISSING-MARKET-PRICE))
        (new-current-debt-adjusted (contract-call? .math-v1 get-market-asset-value market-asset-price new-current-debt))
      )
      (asserts! (<= new-current-debt-adjusted total-max-ltv) ERR-MAX-LTV)
      (try! (contract-call? .state-v1 update-borrow-state {
        user: contract-caller,
        user-debt-shares: total-user-debt-shares,
        user-collaterals: position-collaterals,
        user-borrowed-amount: (+ (get borrowed-amount position) amount),
        shares: new-debt-shares,
        amount: amount,
        total-borrowed-amount: (+ (get total-borrowed-amount borrow-params) amount)
      }))
      (print {
        assets: amount,
        total-user-debt-shares: total-user-debt-shares,
        new-debt-shares: new-debt-shares,
        user: contract-caller,
        action: "borrow"
      })
      SUCCESS
    )
))

(define-public (repay (amount uint) (on-behalf-of (optional principal)))
  (begin
    (try! (accrue-interest))
    (let
      (
        (user (default-to contract-caller on-behalf-of))
        (repay-params (contract-call? .state-v1 get-borrow-repay-params user))
        (position (unwrap! (get user-position repay-params) ERR-NO-POSITION))
        (total-borrowed-amount (get total-borrowed-amount repay-params))
        (interest-params (contract-call? .state-v1 get-open-interest))
        (open-interest (+ (get lp-open-interest interest-params) (get staked-open-interest interest-params) (get protocol-open-interest interest-params)))
        (repay-info (max-repay-amount amount (get debt-shares position)))
        (shares (get shares repay-info))
        (repay-amount (get repay-amount repay-info))
        (borrowed-amount (get borrowed-amount position))
        (current-debt (get current-debt repay-info))
        (interest-portion (contract-call? .math-v1 calculate-interest-portions current-debt borrowed-amount repay-amount))
        (principal-part (get principal-part interest-portion))
        (interest-part (get interest-part interest-portion))
        (open-interest-without-principal (- open-interest total-borrowed-amount))
        (lp-open-interest-without-principal (- (get lp-open-interest interest-params) total-borrowed-amount))
        (lp-part (contract-call? .math-v1 safe-div (* interest-part lp-open-interest-without-principal) open-interest-without-principal))
        (protocol-part (contract-call? .math-v1 safe-div (* interest-part (get protocol-open-interest interest-params)) open-interest-without-principal))
        (staked-part (contract-call? .math-v1 safe-div (* interest-part (get staked-open-interest interest-params)) open-interest-without-principal))
        (asset-params (contract-call? .state-v1 get-lp-params))
        (staked-lp-tokens (contract-call? .math-v1 convert-to-shares asset-params staked-part false))
        (total-user-debt-shares (unwrap! (contract-call? .math-v1 sub (get debt-shares position) shares) ERR-NOT-ENOUGH-SHARES))
        (updated-borrowed-amount (contract-call? .math-v1 safe-sub borrowed-amount principal-part))
        (updated-total-borrowed-amount (contract-call? .math-v1 safe-sub total-borrowed-amount principal-part))
      )
      (asserts! (<= shares (get debt-shares position)) ERR-NOT-ENOUGH-SHARES)
      (try! (contract-call? .state-v1 update-repay-state {
        user: user,
        user-debt-shares: total-user-debt-shares,
        user-collaterals: (get collaterals position),
        shares: shares,
        amount: repay-amount,
        lp-part: (+ principal-part lp-part),
        protocol-part: protocol-part,
        staked-part: staked-part,
        staked-lp-tokens: staked-lp-tokens,
        payor: contract-caller,
        borrowed-amount: updated-borrowed-amount,
        total-borrowed-amount: updated-total-borrowed-amount,
        staking-contract: .staking-v1,
        borrowed-block: (get borrowed-block position)
      }))
      (try! (contract-call? .staking-v1 increase-lp-staked-balance staked-lp-tokens))
      (print {
        assets: repay-amount,
        total-user-debt-shares: total-user-debt-shares,
        repaid-debt-shares: shares,
        on-behalf-of: on-behalf-of,
        sender: contract-caller,
        action: "repay"
      })
      SUCCESS
    )
))

(define-public (add-collateral (collateral <token-trait>) (amount uint))
  (begin
    (let
      (
        (collateral-token (contract-of collateral))
        (add-collateral-params (try! (contract-call? .state-v1 get-collateral-params collateral-token contract-caller)))
        (collateral-info (get collateral-info add-collateral-params))
        (user-balance (get user-balance add-collateral-params))
        (new-amount (+ amount (default-to u0 (get amount user-balance))))
        ;; if the user doesn't have a position, get a default one
        (position (get user-position add-collateral-params))
        ;; check if the collateral is already in the list, otherwise add it
        (updated-collaterals (if (is-none (index-of (get collaterals position) collateral-token))
          (unwrap! (add-item (get collaterals position) collateral-token) ERR-LIST-OVERFLOW)
          (get collaterals position)
        ))
      )
      (asserts! (> (get max-ltv collateral-info) u0) ERR-COLLATERAL-NOT-SUPPORTED)
      (try! (contract-call? .state-v1 update-add-collateral collateral {
        amount: amount,
        total-collateral-amount: new-amount,
        user: contract-caller,
        user-position: {debt-shares: (get debt-shares position), collaterals: updated-collaterals, borrowed-amount: (get borrowed-amount position), borrowed-block: (get borrowed-block position)},
      }))
      (print {
        collateral: collateral-token,
        amount-deposited: amount,
        user-balance: new-amount,
        user: contract-caller,
        action: "add-collateral"
      })
      SUCCESS
    )
))

(define-public (remove-collateral (pyth-price-feed-data (optional (buff 8192))) (collateral <token-trait>) (amount uint))
  (begin
    (try! (contract-call? .pyth-adapter-v1 update-pyth pyth-price-feed-data))
    (try! (accrue-interest))
    (let
      (
        (collateral-token (contract-of collateral))
        (remove-collateral-params (try! (contract-call? .state-v1 get-collateral-params collateral-token contract-caller)))
        (collateral-info (get collateral-info remove-collateral-params))
        (user-balance (unwrap! (get user-balance remove-collateral-params) ERR-INSUFFICIENT-BALANCE))
        (prev-amount (get amount user-balance))
        (position (get user-position remove-collateral-params))
        (remove-user-collateral-info (try! (remove-user-collateral prev-amount amount collateral-token (get debt-shares position) (get collaterals position) (get borrowed-amount position) (get borrowed-block position))))
        (collateral-prices (try! (contract-call? .pyth-adapter-v1 bulk-read-collateral-prices (get position-collaterals remove-user-collateral-info))))
        (total-max-ltv (fold + (map iterate-collateral-value (get position-collaterals remove-user-collateral-info) collateral-prices) u0))
        (debt-params (contract-call? .state-v1 get-debt-params))
        (current-debt (contract-call? .math-v1 convert-to-debt-assets debt-params (get debt-shares position) true))
        (market-asset-price (unwrap! (contract-call? .pyth-adapter-v1 read-price 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc) ERR-MISSING-MARKET-PRICE))
        (current-debt-adjusted (contract-call? .math-v1 get-market-asset-value market-asset-price current-debt))
      )
      (asserts! (<= current-debt-adjusted total-max-ltv) ERR-MAX-LTV)

      ;; transfer the collateral tokens to the user
      (try! (contract-call? .state-v1 transfer-to collateral contract-caller amount))
      (print {
          collateral: collateral-token,
          amount-removed: amount,
          user-balance: (get remaining-amount remove-user-collateral-info),
          user: contract-caller,
          action: "remove-collateral"
      })
      SUCCESS
    )
))

;; READ-ONLY FUNCTIONS
(define-read-only (get-user-collaterals-value (account principal))
  (match (contract-call? .state-v1 get-user-position account) 
  position
  (let
    (
      (posted-collaterals (get collaterals position))
      (collateral-prices (try! (contract-call? .pyth-adapter-v1 bulk-read-collateral-prices posted-collaterals)))
    )
    (begin
      (ok (fold + (map get-collateral-value posted-collaterals (list
        contract-caller contract-caller contract-caller contract-caller contract-caller contract-caller contract-caller contract-caller contract-caller contract-caller
      ) collateral-prices) u0))
    )
  )
  ERR-NO-POSITION
))

;; PRIVATE FUNCTIONS

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
    ))
    (contract-call? .state-v1 set-accrued-interest accrued-interest)
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

(define-private (iterate-collateral-value (collateral principal) (collateral-price uint))
  (let
    (
      (collateral-info (contract-call? .state-v1 get-collateral collateral))
      (user-collateral-value (get-collateral-value collateral contract-caller collateral-price))
      (max-ltv (default-to u0 (get max-ltv collateral-info)))
    )
    (/ (* user-collateral-value max-ltv) SCALING-FACTOR)
))

(define-private (add-item (collaterals-list (list 10 principal)) (collateral principal))
  (as-max-len? (append collaterals-list collateral) u10)
)

(define-private (remove-user-collateral (prev-amount uint) (amount uint) (collateral principal) (debt-shares uint) (position-collaterals (list 10 principal)) (borrowed-amount uint) (borrowed-block uint))
  (let ((remaining-amount (unwrap! (contract-call? .math-v1 sub prev-amount amount) ERR-INSUFFICIENT-BALANCE)))
    (if (is-eq remaining-amount u0)
      (let ((updated-position-collaterals (contract-call? .state-v1 remove-item position-collaterals collateral)))
        ;; remove the collateral since there is no user collateral left
        (try! (contract-call? .state-v1 update-remove-collateral contract-caller collateral debt-shares (get new-list updated-position-collaterals) borrowed-amount borrowed-block))
        (ok {
          remaining-amount: remaining-amount,
          position-collaterals: (get new-list updated-position-collaterals),
        })
      )
      (begin
        ;; decrease the amount of collateral deposited by the user
        (try! (contract-call? .state-v1 update-user-collateral contract-caller collateral remaining-amount))
        (ok {
          remaining-amount: remaining-amount,
          position-collaterals: position-collaterals,
        })
    ))
))

(define-private (max-repay-amount (amount uint) (total-user-debt-shares uint))
  (let (
      (debt-params (contract-call? .state-v1 get-debt-params))
      (current-debt (contract-call? .math-v1 convert-to-debt-assets debt-params total-user-debt-shares true))
      (repay-amount (if (>= amount current-debt) current-debt amount))
      (shares (if (is-eq repay-amount current-debt) total-user-debt-shares (contract-call? .math-v1 convert-to-debt-shares debt-params amount false)))
    )
    {
      current-debt: current-debt,
      repay-amount: repay-amount,
      shares: shares,
    }
))

```
