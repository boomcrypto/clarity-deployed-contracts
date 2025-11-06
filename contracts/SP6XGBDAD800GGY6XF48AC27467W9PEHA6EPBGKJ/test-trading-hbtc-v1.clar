;; @contract Trading
;; @version 0.1
;; @description Atomic position management across DeFi protocols

(use-trait borrow-helper .test-zest-borrow-helper-trait-v1.zest-borrow-helper-trait)
(use-trait staking .test-staking-trait-v1.staking-trait)
(use-trait staking-silo .test-staking-silo-trait-v1.staking-silo-trait)

(use-trait ft 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.ft-trait.ft-trait)
(use-trait ft-mint 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.ft-mint-trait.ft-mint-trait)
(use-trait oracle 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.oracle-trait.oracle-trait)
(use-trait redeemable-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.redeemeable-trait-v1-2.redeemeable-trait)
(use-trait incentives 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.incentives-trait-v2-1.incentives-trait)

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_INVALID_AMOUNT (err u120001))
(define-constant ERR_POSITION_MISMATCH (err u120002))

;;-------------------------------------
;; Open Zest Position
;;-------------------------------------

;; @desc Opens a leveraged position: supplies sBTC to Zest, borrows USDh, stakes USDh in Hermetica
(define-public (open-position-zest
  (sbtc-supply-amount uint)
  (usdh-borrow-amount uint)
  (interest-rate-mode uint)
  (borrow-helper-trait <borrow-helper>)
  (staking-trait <staking>)
  (lp-sbtc-trait <redeemable-token>)
  (lp-usdh-trait <ft>)
  (oracle-trait <oracle>)
  (incentives-trait <incentives>)
  (sbtc-token-trait <ft>)
  (borrowed-asset-trait <ft>)
  (pool-reserve-data principal)
  (fee-calculator principal)
  (pools (list 100 { asset: <ft>, lp-token: <ft-mint>, oracle: <oracle> }))
  (referral (optional principal))
  (price-feed-bytes1 (optional (buff 8192)))
  (price-feed-bytes2 (optional (buff 8192))))
  (begin
    (asserts! (> usdh-borrow-amount u0) ERR_INVALID_AMOUNT)

    ;; Step 1: Supply sBTC to Zest as collateral (skip if amount is 0)
    ;; The zest-interface will check trader permissions and move tokens from Reserve
    (if (> sbtc-supply-amount u0)
      (try! (contract-call? .test-zest-interface-hbtc4-v1 zest-supply
        borrow-helper-trait
        lp-sbtc-trait
        pool-reserve-data
        sbtc-token-trait
        sbtc-supply-amount
        referral
        incentives-trait))
      true)

    ;; Step 2: Borrow asset using the supplied sBTC as collateral
    ;; The borrowed asset will be transferred to Reserve by zest-interface
    (try! (contract-call? .test-zest-interface-hbtc4-v1 zest-borrow
      borrow-helper-trait
      pool-reserve-data
      oracle-trait
      borrowed-asset-trait
      lp-usdh-trait
      pools
      usdh-borrow-amount
      fee-calculator
      interest-rate-mode
      price-feed-bytes1
      price-feed-bytes2))

    ;; Step 3: Stake the borrowed USDh into Hermetica to earn sUSDh yield
    ;; The hermetica-interface will move USDh from Reserve and return sUSDh to Reserve
    (try! (contract-call? .test-hermetica-interface-hbtc4-v1 hermetica-stake
      usdh-borrow-amount
      staking-trait))

    (print {
      action: "open-position-zest",
      user: tx-sender,
      data: {
        sbtc-supplied: sbtc-supply-amount,
        usdh-borrowed-and-staked: usdh-borrow-amount,
        interest-rate-mode: interest-rate-mode
      }
    })
    (ok true)
  )
)

;;-------------------------------------
;; Close Zest Position
;;-------------------------------------

;; @desc Closes a leveraged position: unstakes from Hermetica and repays Zest loan
(define-public (close-position-zest
  (susdh-unstake-amount uint)
  (usdh-repay-amount uint)
  (borrow-helper-trait <borrow-helper>)
  (staking-trait <staking>)
  (staking-silo-trait <staking-silo>)
  (borrowed-asset-trait <ft>))
  (begin
    ;; Ensure both amounts are non-zero for atomic transaction
    (asserts! (> susdh-unstake-amount u0) ERR_INVALID_AMOUNT)
    (asserts! (> usdh-repay-amount u0) ERR_INVALID_AMOUNT)

    ;; Step 1: Unstake sUSDh from Hermetica
    ;; This uses instant withdrawal (unstake-and-withdraw)
    (try! (contract-call? .test-hermetica-interface-hbtc4-v1 hermetica-unstake-and-withdraw
      susdh-unstake-amount
      staking-trait
      staking-silo-trait))

    ;; Step 2: Repay borrowed asset loan to Zest
    ;; The zest-interface will move borrowed asset from Reserve to Zest
    (try! (contract-call? .test-zest-interface-hbtc4-v1 zest-repay
      borrow-helper-trait
      borrowed-asset-trait
      usdh-repay-amount
      .test-zest-interface-hbtc4-v1)) ;; Payer is the zest-interface itself

    (print {
      action: "close-position-zest",
      user: tx-sender,
      data: {
        susdh-unstaked: susdh-unstake-amount,
        usdh-repaid: usdh-repay-amount,
      }
    })
    (ok true)
  )
)