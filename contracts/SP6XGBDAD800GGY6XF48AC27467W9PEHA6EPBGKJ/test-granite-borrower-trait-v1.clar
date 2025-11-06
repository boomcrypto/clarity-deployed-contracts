;; @contract GraniteBorrowerTrait
;; @version 1.0
;; @description Trait contract for granite borrower functionality

(use-trait ft 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;;-------------------------------------
;; Trait Definition
;;-------------------------------------

(define-trait granite-borrower-trait
  (
    ;;-------------------------------------
    ;; Core Borrowing Functions
    ;;-------------------------------------

    ;; @desc - Borrow assets from the lending pool
    ;; @param - pyth-price-feed-data: optional Pyth price feed data for oracle updates
    ;; @param - amount: amount of asset to borrow
    ;; @param - maybe-user: optional principal of the user borrowing
    ;; @return - (ok bool) on success, (err uint) on failure
    (borrow 
      (
        (optional (buff 8192))
        uint
        (optional principal)
      ) 
      (response bool uint)
    )

    ;; @desc - Repay borrowed assets
    ;; @param - amount: amount of asset to repay
    ;; @param - on-behalf-of: optional principal whose debt is being repaid
    ;; @return - (ok bool) on success, (err uint) on failure
    (repay 
      (
        uint
        (optional principal)
      ) 
      (response bool uint)
    )

    ;;-------------------------------------
    ;; Collateral Management Functions
    ;;-------------------------------------

    ;; @desc - Add collateral to the borrowing position
    ;; @param - collateral: SIP-010 trait of the collateral asset
    ;; @param - amount: amount of collateral to add
    ;; @param - maybe-user: optional principal of the user adding collateral
    ;; @return - (ok bool) on success, (err uint) on failure
    (add-collateral 
      (
        <ft>
        uint
        (optional principal)
      ) 
      (response bool uint)
    )

    ;; @desc - Remove collateral from the borrowing position
    ;; @param - pyth-price-feed-data: optional Pyth price feed data for oracle updates
    ;; @param - collateral: SIP-010 trait of the collateral asset
    ;; @param - amount: amount of collateral to remove
    ;; @param - maybe-user: optional principal of the user removing collateral
    ;; @return - (ok bool) on success, (err uint) on failure
    (remove-collateral 
      (
        (optional (buff 8192))
        <ft>
        uint
        (optional principal)
      ) 
      (response bool uint)
    )
  ) 
) 