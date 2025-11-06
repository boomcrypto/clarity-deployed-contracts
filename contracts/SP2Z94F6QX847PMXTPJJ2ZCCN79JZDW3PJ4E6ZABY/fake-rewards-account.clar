;; title: aibtc-rewards-account
;; version: 2.0.0
;; summary: A smart contract that holds funds used for proposal rewards.

;; traits
;;

(impl-trait 'SPW8QZNWKZGVHX012HCBJVJVPS94PXFG578P53TM.aibtc-dao-traits.extension)
(impl-trait 'SPW8QZNWKZGVHX012HCBJVJVPS94PXFG578P53TM.aibtc-dao-traits.rewards-account)

(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; constants
;;

;; error messages
(define-constant ERR_NOT_DAO_OR_EXTENSION (err u1700))
(define-constant ERR_INSUFFICIENT_BALANCE (err u1701))

;; contract details
(define-constant DEPLOYED_BURN_BLOCK burn-block-height)
(define-constant DEPLOYED_STACKS_BLOCK stacks-block-height)
(define-constant SELF (as-contract tx-sender))

;; public functions
;;

(define-public (callback
    (sender principal)
    (memo (buff 34))
  )
  (ok true)
)

(define-public (transfer-reward
    (recipient principal)
    (amount uint)
  )
  (let ((contractBalance (unwrap-panic (contract-call? .fake-faktory get-balance SELF))))
    (try! (is-dao-or-extension))
    (asserts! (>= contractBalance amount) ERR_INSUFFICIENT_BALANCE)
    (print {
      notification: "fake-rewards-account/transfer-reward",
      payload: {
        recipient: recipient,
        amount: amount,
        contractCaller: contract-caller,
        txSender: tx-sender,
      },
    })
    (as-contract (contract-call? .fake-faktory transfer amount SELF recipient none))
  )
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
