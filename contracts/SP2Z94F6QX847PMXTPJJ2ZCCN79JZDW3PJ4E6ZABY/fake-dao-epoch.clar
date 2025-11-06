;; title: aibtc-dao-epoch
;; version: 1.0.0
;; summary: An extension that tracks the current epoch of the DAO.

;; traits
;;

(impl-trait 'SPW8QZNWKZGVHX012HCBJVJVPS94PXFG578P53TM.aibtc-dao-traits.extension)
(impl-trait 'SPW8QZNWKZGVHX012HCBJVJVPS94PXFG578P53TM.aibtc-dao-traits.dao-epoch)

;; constants
;;

;; contract details
(define-constant DEPLOYED_BURN_BLOCK burn-block-height)
(define-constant DEPLOYED_STACKS_BLOCK stacks-block-height)
(define-constant SELF (as-contract tx-sender))

;; track epochs by BTC block height
(define-constant EPOCH_LENGTH u4320) ;; 30 days in BTC blocks

;; public functions
;;

(define-public (callback
    (sender principal)
    (memo (buff 34))
  )
  (ok true)
)

;; read only functions
;;

;; returns the current epoch based on deployed burn block
(define-read-only (get-current-dao-epoch)
  (ok (/ (- burn-block-height DEPLOYED_BURN_BLOCK) EPOCH_LENGTH))
)

;; returns the epoch length
(define-read-only (get-dao-epoch-length)
  (ok EPOCH_LENGTH)
)
