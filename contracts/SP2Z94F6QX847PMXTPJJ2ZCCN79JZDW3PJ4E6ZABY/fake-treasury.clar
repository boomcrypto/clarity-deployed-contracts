;; title: aibtc-treasury
;; version: 3.0.0
;; summary: A secure treasury contract that controls the funds of the DAO.

;; traits
;;

(impl-trait 'SPW8QZNWKZGVHX012HCBJVJVPS94PXFG578P53TM.aibtc-dao-traits.extension)
(impl-trait 'SPW8QZNWKZGVHX012HCBJVJVPS94PXFG578P53TM.aibtc-dao-traits.treasury)

(use-trait sip010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; constants
;;

;; error messages
(define-constant ERR_NOT_DAO_OR_EXTENSION (err u1900))
(define-constant ERR_ASSET_NOT_ALLOWED (err u1901))

;; contract details
(define-constant DEPLOYED_BURN_BLOCK burn-block-height)
(define-constant DEPLOYED_STACKS_BLOCK stacks-block-height)
(define-constant SELF (as-contract tx-sender))

;; data maps
;;

;; track allowed assets for deposit/transfer
(define-map AllowedAssets
  principal
  bool
)

;; public functions
(define-public (callback
    (sender principal)
    (memo (buff 34))
  )
  (ok true)
)

;; add or update an asset to the allowed list
(define-public (allow-asset
    (token principal)
    (enabled bool)
  )
  (begin
    (try! (is-dao-or-extension))
    (print {
      notification: "fake-treasury/allow-asset",
      payload: {
        token: token,
        enabled: enabled,
        contractCaller: contract-caller,
        txSender: tx-sender,
      },
    })
    (ok (map-set AllowedAssets token enabled))
  )
)

;; deposit FT to the treasury
(define-public (deposit-ft
    (ft <sip010-trait>)
    (amount uint)
  )
  (begin
    ;; no auth - anyone can deposit if token allowed
    (asserts! (is-allowed-asset (contract-of ft)) ERR_ASSET_NOT_ALLOWED)
    (print {
      notification: "fake-treasury/deposit-ft",
      payload: {
        amount: amount,
        recipient: SELF,
        assetContract: (contract-of ft),
        contractCaller: contract-caller,
        txSender: tx-sender,
      },
    })
    (contract-call? ft transfer amount tx-sender SELF none)
  )
)

;; withdraw FT from the treasury
(define-public (withdraw-ft
    (ft <sip010-trait>)
    (amount uint)
    (to principal)
  )
  (begin
    ;; only DAO contract can withdraw if token allowed
    (try! (is-dao-or-extension))
    (asserts! (is-allowed-asset (contract-of ft)) ERR_ASSET_NOT_ALLOWED)
    (print {
      notification: "fake-treasury/withdraw-ft",
      payload: {
        amount: amount,
        recipient: to,
        assetContract: (contract-of ft),
        contractCaller: contract-caller,
        txSender: tx-sender,
      },
    })
    (as-contract (contract-call? ft transfer amount SELF to none))
  )
)

;; read only functions
;;

(define-read-only (is-allowed-asset (assetContract principal))
  (default-to false (get-allowed-asset assetContract))
)

(define-read-only (get-allowed-asset (assetContract principal))
  (map-get? AllowedAssets assetContract)
)

(define-read-only (get-contract-info)
  {
    self: SELF,
    deployedBurnBlock: DEPLOYED_BURN_BLOCK,
    deployedStacksBlock: DEPLOYED_STACKS_BLOCK,
  }
)

;; private functions
;;

(define-private (is-dao-or-extension)
  (ok (asserts!
    (or
      (is-eq tx-sender .fake-base-dao)
      (contract-call? .fake-base-dao is-extension contract-caller)
    )
    ERR_NOT_DAO_OR_EXTENSION
  ))
)
