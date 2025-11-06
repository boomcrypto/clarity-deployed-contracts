;; @contract Trading
;; @version 0.1
;; @description Atomic position management across DeFi protocols

(use-trait borrow-helper .test-zest-borrow-helper-trait-v1.zest-borrow-helper-trait)
(use-trait staking 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.staking-trait-v1.staking-trait)
(use-trait staking-silo 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.staking-silo-trait-v1.staking-silo-trait)
(use-trait hbtc-vault .test-vault-trait-v1.vault-trait)

(use-trait ft 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.ft-trait.ft-trait)
(use-trait ft-mint 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.ft-mint-trait.ft-mint-trait)
(use-trait oracle 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.oracle-trait.oracle-trait)
(use-trait redeemable-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.redeemeable-trait-v1-2.redeemeable-trait)
(use-trait incentives 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.incentives-trait-v2-1.incentives-trait)

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_INVALID_AMOUNT (err u120001))
(define-constant ERR_EMPTY_CLAIM_IDS (err u120002))

(define-constant zest-interface .test-zest-interface-hbtc-v3)

;;-------------------------------------
;; Open Zest Position
;;-------------------------------------

;; @desc - Borrows USDh from Zest and stakes it in Hermetica
;; @param - borrow-helper-trait: Zest borrow helper contract
;; @param - staking-trait: Hermetica staking contract
;; @param - lp-usdh-trait: Zest USDh LP token
;; @param - oracle-trait: Oracle for price feeds
;; @param - borrowed-asset-trait: Asset to borrow (e.g., USDh token contract)
;; @param - usdh-borrow-amount: Amount of USDh to borrow
;; @param - interest-rate-mode: 0 for stable rate, 1 for variable rate
;; @param - pool-reserve-data: Zest pool reserve data contract
;; @param - fee-calculator: Zest fee calculator contract
;; @param - pools: List of Zest pool assets for collateral calculations
;; @param - price-feed-1: Optional price feed update for oracle
;; @param - price-feed-2: Optional second price feed update
(define-public (zest-open
  (borrow-helper-trait <borrow-helper>) (staking-trait <staking>) 
  (lp-usdh-trait <ft>) (oracle-trait <oracle>) (borrowed-asset-trait <ft>)
  (usdh-borrow-amount uint) (interest-rate-mode uint)
  (pool-reserve-data principal) (fee-calculator principal)
  (pools (list 100 { asset: <ft>, lp-token: <ft-mint>, oracle: <oracle> }))
  (price-feed-1 (optional (buff 8192))) (price-feed-2 (optional (buff 8192))))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-trader contract-caller))
    (asserts! (> usdh-borrow-amount u0) ERR_INVALID_AMOUNT)
    ;; Borrow asset using the supplied collateral
    ;; The borrowed asset will be transferred to Reserve by zest-interface
    (try! (contract-call? .test-zest-interface-hbtc-v3 zest-borrow
      borrow-helper-trait pool-reserve-data oracle-trait borrowed-asset-trait lp-usdh-trait
      pools usdh-borrow-amount fee-calculator interest-rate-mode
      price-feed-1 price-feed-2))

    ;; Stake the borrowed USDh into Hermetica to earn sUSDh yield
    ;; The hermetica-interface will move USDh from Reserve and return sUSDh to Reserve
    (try! (contract-call? .test-hermetica-interface-hbtc-v3 hermetica-stake usdh-borrow-amount staking-trait))

    (print { action: "zest-open", user: contract-caller, data: { usdh-borrowed: usdh-borrow-amount, interest-rate-mode: interest-rate-mode } })
    (ok true)
  )
)

;; @desc - Opens a leveraged position: supplies sBTC to Zest, borrows USDh, stakes USDh in Hermetica
;; @param - borrow-helper-trait: Zest borrow helper contract
;; @param - staking-trait: Hermetica staking contract
;; @param - lp-sbtc-trait: Zest sBTC LP token
;; @param - lp-usdh-trait: Zest USDh LP token
;; @param - oracle-trait: Oracle for price feeds
;; @param - incentives-trait: Zest incentives contract
;; @param - sbtc-token-trait: sBTC token contract
;; @param - borrowed-asset-trait: Asset to borrow (e.g., USDh token contract)
;; @param - sbtc-supply-amount: Amount of sBTC to supply as collateral
;; @param - usdh-borrow-amount: Amount of USDh to borrow
;; @param - interest-rate-mode: 0 for stable rate, 1 for variable rate
;; @param - pool-reserve-data: Zest pool reserve data contract
;; @param - fee-calculator: Zest fee calculator contract
;; @param - pools: List of Zest pool assets for collateral calculations
;; @param - referral: Optional referral address for Zest
;; @param - price-feed-1: Optional price feed update for oracle
;; @param - price-feed-2: Optional second price feed update
(define-public (zest-open-add
  (borrow-helper-trait <borrow-helper>) (staking-trait <staking>)
  (lp-sbtc-trait <redeemable-token>) (lp-usdh-trait <ft>) (oracle-trait <oracle>) (incentives-trait <incentives>)
  (sbtc-token-trait <ft>) (borrowed-asset-trait <ft>)
  (sbtc-supply-amount uint) (usdh-borrow-amount uint) (interest-rate-mode uint)
  (pool-reserve-data principal) (fee-calculator principal)
  (pools (list 100 { asset: <ft>, lp-token: <ft-mint>, oracle: <oracle> }))
  (referral (optional principal))
  (price-feed-1 (optional (buff 8192))) (price-feed-2 (optional (buff 8192))))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-trader contract-caller))
    (asserts! (> sbtc-supply-amount u0) ERR_INVALID_AMOUNT)
    (asserts! (> usdh-borrow-amount u0) ERR_INVALID_AMOUNT)

    ;; Step 1: Supply sBTC to Zest as collateral
    (try! (contract-call? .test-zest-interface-hbtc-v3 zest-supply
      borrow-helper-trait lp-sbtc-trait pool-reserve-data sbtc-token-trait
      sbtc-supply-amount referral incentives-trait))

    ;; Step 2: Borrow USDh and stake it in Hermetica
    (try! (zest-open
      borrow-helper-trait staking-trait lp-usdh-trait oracle-trait borrowed-asset-trait
      usdh-borrow-amount interest-rate-mode
      pool-reserve-data fee-calculator pools
      price-feed-1 price-feed-2))

    (print { action: "zest-open-add", user: contract-caller, data: { sbtc-supplied: sbtc-supply-amount, usdh-borrowed-and-staked: usdh-borrow-amount, interest-rate-mode: interest-rate-mode } })
    (ok true)
  )
)

;;-------------------------------------
;; Close Zest Position
;;-------------------------------------

;; @desc - Unstakes sUSDh from Hermetica and repays USDh to Zest
;; @param - borrow-helper-trait: Zest borrow helper contract
;; @param - staking-trait: Hermetica staking contract
;; @param - staking-silo-trait: Hermetica silo for withdrawal claims
;; @param - borrowed-asset-trait: Asset to repay (e.g., USDh token contract)
;; @param - susdh-unstake-amount: Amount of sUSDh to unstake from Hermetica
;; @param - usdh-repay-amount: Amount of USDh to repay to Zest (can be partial)
(define-public (zest-close
  (borrow-helper-trait <borrow-helper>) (staking-trait <staking>) (staking-silo-trait <staking-silo>) 
  (borrowed-asset-trait <ft>)
  (susdh-unstake-amount uint) (usdh-repay-amount uint))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-trader contract-caller))
    (asserts! (> susdh-unstake-amount u0) ERR_INVALID_AMOUNT)
    (asserts! (> usdh-repay-amount u0) ERR_INVALID_AMOUNT)
    (let (
      ;; Unstake sUSDh from Hermetica (instant withdrawal)
      (usdh-amount (try! (contract-call? .test-hermetica-interface-hbtc-v3 hermetica-unstake-and-withdraw susdh-unstake-amount staking-trait staking-silo-trait))))
      ;; Repay USDh loan to Zest
      ;; The zest-interface will move borrowed asset from Reserve to Zest
      (try! (contract-call? .test-zest-interface-hbtc-v3 zest-repay borrow-helper-trait borrowed-asset-trait usdh-repay-amount zest-interface))
      (print { action: "zest-close", user: contract-caller, data: { susdh-unstaked: susdh-unstake-amount, usdh-received: usdh-amount, usdh-repaid: usdh-repay-amount } })
      (ok true)
    )
  )
)

;; @desc - Withdraws sBTC collateral from Zest and funds withdrawal claims
;; @param - borrow-helper-trait: Zest borrow helper contract
;; @param - hbtc-vault-trait: Vault for sBTC collateral claims
;; @param - lp-sbtc-trait: Zest sBTC LP token
;; @param - sbtc-token-trait: sBTC token contract
;; @param - oracle-trait: Oracle for price feeds
;; @param - incentives-trait: Zest incentives contract
;; @param - collateral-amount: Amount of sBTC collateral to withdraw
;; @param - claim-ids: List of claim IDs to fund with sBTC (must have at least one)
;; @param - pool-reserve-data: Zest pool reserve data contract
;; @param - assets: List of Zest pool assets for collateral calculations
;; @param - price-feed-1: Optional price feed update for oracle
;; @param - price-feed-2: Optional second price feed update
(define-public (zest-withdraw-fund
  (borrow-helper-trait <borrow-helper>) (hbtc-vault-trait <hbtc-vault>)
  (lp-sbtc-trait <redeemable-token>) (sbtc-token-trait <ft>) (oracle-trait <oracle>) (incentives-trait <incentives>)
  (collateral-amount uint) 
  (claim-ids (list 100 uint))
  (pool-reserve-data principal)
  (assets (list 100 { asset: <ft>, lp-token: <ft-mint>, oracle: <oracle> }))
  (price-feed-1 (optional (buff 8192))) (price-feed-2 (optional (buff 8192))))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-trader contract-caller))
    (asserts! (> collateral-amount u0) ERR_INVALID_AMOUNT)
    (asserts! (> (len claim-ids) u0) ERR_EMPTY_CLAIM_IDS)
    (try! (contract-call? .test-hq-vaults-v3 check-is-protocol (contract-of hbtc-vault-trait)))

    ;; Step 1: Withdraw sBTC collateral from Zest
    (try! (contract-call? .test-zest-interface-hbtc-v3 zest-withdraw
      borrow-helper-trait lp-sbtc-trait pool-reserve-data sbtc-token-trait oracle-trait
      collateral-amount assets incentives-trait
      price-feed-1 price-feed-2))

    ;; Step 2: Fund claims with withdrawn sBTC
    (try! (contract-call? hbtc-vault-trait fund-claim-many claim-ids))

    (print { action: "zest-withdraw-fund-claims", user: contract-caller, data: { collateral-amount: collateral-amount, claim-ids: claim-ids } })
    (ok true)
  )
)