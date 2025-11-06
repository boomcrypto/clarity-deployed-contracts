;; title: aibtc-onchain-messaging
;; version: 1.0.0
;; summary: An extension to send messages on-chain to anyone listening to this contract.

;; traits
;;

(impl-trait 'SPW8QZNWKZGVHX012HCBJVJVPS94PXFG578P53TM.aibtc-dao-traits.extension)
(impl-trait 'SPW8QZNWKZGVHX012HCBJVJVPS94PXFG578P53TM.aibtc-dao-traits.messaging)

;; constants
;;
(define-constant ERR_NOT_DAO_OR_EXTENSION (err u1600))
(define-constant ERR_INVALID_INPUT (err u1601))
(define-constant ERR_FETCHING_TOKEN_DATA (err u1602))

;; data-vars
(define-data-var messageCost uint u0)

;; public functions

(define-public (callback
    (sender principal)
    (memo (buff 34))
  )
  (ok true)
)

;; DAO itself can send messages via proposals
;; DAO token holders can send messages by paying a fee
(define-public (send (msg (string-utf8 10000)))
  (let (
      (isFromDao (is-ok (is-dao-or-extension)))
      (senderBalance (unwrap! (contract-call? .fake-faktory get-balance tx-sender)
        ERR_FETCHING_TOKEN_DATA
      ))
      (isFromHolder (> senderBalance u0))
    )
    ;; check there is a message
    (asserts! (> (len msg) u0) ERR_INVALID_INPUT)
    ;; print the envelope and message
    (print {
      notification: "fake-onchain-messaging/send",
      payload: {
        contractCaller: contract-caller,
        txSender: tx-sender,
        height: stacks-block-height,
        isFromDao: isFromDao,
        isFromHolder: isFromHolder,
        messageLength: (len msg),
        message: msg,
      },
    })
    ;; check if sender is not dao via proposal
    (ok (and
      (not isFromDao)
      ;; transfer the message cost to the dao
      (try! (contract-call? .fake-treasury deposit-ft .fake-faktory
        (var-get messageCost)
      ))
    ))
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

;; initialization
;;

(let (
    (proposalConfig (contract-call? .fake-action-proposal-voting get-voting-configuration))
    (bondAmount (get proposalBond proposalConfig))
  )
  (print {
    notification: "aibtc-onchain-messaging/initialize",
    payload: {
      contractCaller: contract-caller,
      txSender: tx-sender,
      messageCost: bondAmount,
    },
  })
  (ok (var-set messageCost bondAmount))
)
