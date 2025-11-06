;; @contract ZestBorrowHelperTrait
;; @version 1.0
;; @description Trait contract for zest borrow helper functionality

(use-trait ft 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.ft-trait.ft-trait)
(use-trait ft-mint-trait 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.ft-mint-trait.ft-mint-trait)
(use-trait oracle-trait 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.oracle-trait.oracle-trait)
(use-trait redeemeable-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.redeemeable-trait-v1-2.redeemeable-trait)
(use-trait incentives-trait 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.incentives-trait-v2-1.incentives-trait)

;;-------------------------------------
;; Trait Definition
;;-------------------------------------

(define-trait zest-borrow-helper-trait
  (
    ;;-------------------------------------
    ;; Core Lending Functions
    ;;-------------------------------------

    ;; @desc - Supply assets to the lending pool
    ;; @param - lp: redeemable token trait for LP tokens
    ;; @param - pool-reserve: principal of the pool reserve contract
    ;; @param - asset: SIP-010 trait of the asset being supplied
    ;; @param - amount: amount of asset to supply
    ;; @param - owner: principal of the asset owner
    ;; @param - referral: optional referral principal
    ;; @param - incentives: incentives trait for rewards
    ;; @return - (ok bool) on success, (err uint) on failure
    (supply 
      (
        <redeemeable-token>
        principal
        <ft>
        uint
        principal
        (optional principal)
        <incentives-trait>
      ) 
      (response bool uint)
    )

    ;; @desc - Borrow assets from the lending pool
    ;; @param - pool-reserve: principal of the pool reserve contract
    ;; @param - oracle: oracle trait for price feeds
    ;; @param - asset-to-borrow: SIP-010 trait of the asset to borrow
    ;; @param - lp: LP token trait
    ;; @param - assets: list of supported assets with their LP tokens and oracles
    ;; @param - amount-to-be-borrowed: amount of asset to borrow
    ;; @param - fee-calculator: principal of the fee calculator contract
    ;; @param - interest-rate-mode: interest rate mode (0 for stable, 1 for variable)
    ;; @param - owner: principal of the borrower
    ;; @param - price-feed-bytes: optional Pyth price feed data
    ;; @return - (ok bool) on success, (err uint) on failure
    (borrow 
      (
        principal
        <oracle-trait>
        <ft>
        <ft>
        (list 100 { asset: <ft>, lp-token: <ft>, oracle: <oracle-trait> })
        uint
        principal
        uint
        principal
        (optional (buff 8192))
      ) 
      (response bool uint)
    )

    ;; @desc - Repay borrowed assets
    ;; @param - asset: SIP-010 trait of the asset being repaid
    ;; @param - amount-to-repay: amount of asset to repay
    ;; @param - on-behalf-of: principal whose debt is being repaid
    ;; @param - payer: principal paying the repayment
    ;; @return - (ok bool) on success, (err uint) on failure
    (repay 
      (
        <ft>
        uint
        principal
        principal
      ) 
      (response bool uint)
    )

    ;; @desc - Withdraw supplied assets from the lending pool
    ;; @param - lp: redeemable token trait for LP tokens
    ;; @param - pool-reserve: principal of the pool reserve contract
    ;; @param - asset: SIP-010 trait of the asset being withdrawn
    ;; @param - oracle: oracle trait for price feeds
    ;; @param - amount: amount of asset to withdraw
    ;; @param - owner: principal of the asset owner
    ;; @param - assets: list of supported assets with their LP tokens and oracles
    ;; @param - incentives: incentives trait for rewards
    ;; @param - price-feed-bytes: optional Pyth price feed data
    ;; @return - (ok bool) on success, (err uint) on failure
    (withdraw 
      (
        <redeemeable-token>
        principal
        <ft>
        <oracle-trait>
        uint
        principal
        (list 100 { asset: <ft>, lp-token: <ft-mint-trait>, oracle: <oracle-trait> })
        <incentives-trait>
        (optional (buff 8192))
      ) 
      (response bool uint)
    )

    ;; @desc - Claim rewards for supplied assets
    ;; @param - lp: redeemable token trait for LP tokens
    ;; @param - pool-reserve: principal of the pool reserve contract
    ;; @param - asset: SIP-010 trait of the asset
    ;; @param - oracle: oracle trait for price feeds
    ;; @param - owner: principal of the asset owner
    ;; @param - assets: list of supported assets with their LP tokens and oracles
    ;; @param - reward-asset: SIP-010 trait of the reward asset
    ;; @param - incentives: incentives trait for rewards
    ;; @param - price-feed-bytes: optional Pyth price feed data
    ;; @return - (ok bool) on success, (err uint) on failure
    (claim-rewards
      (
        <redeemeable-token>
        principal
        <ft>
        <oracle-trait>
        principal
        (list 100 { asset: <ft>, lp-token: <ft-mint-trait>, oracle: <oracle-trait> })
        <ft>
        <incentives-trait>
        (optional (buff 8192))
      )
      (response bool uint)
    )
    
  )
)