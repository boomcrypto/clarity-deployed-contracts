;; title: aibtc-base-initialize-dao
;; version: 1.0.0
;; summary: A proposal that sets up the initial DAO configuration and extensions.

(impl-trait 'SPW8QZNWKZGVHX012HCBJVJVPS94PXFG578P53TM.aibtc-dao-traits.proposal)

(define-constant CFG_DAO_MANIFEST_TEXT u"This is a test. No monetary value.")
(define-constant CFG_DAO_TOKEN .fake-faktory)
(define-constant CFG_SBTC_TOKEN 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)

(define-public (execute (sender principal))
  (begin
    ;; set initial dao extensions list
    (try! (contract-call? .fake-base-dao set-extensions
      (list
        ;; initial DAO extensions (features)
        {
          extension: .fake-action-proposal-voting,
          enabled: true,
        }
        {
          extension: .fake-dao-charter,
          enabled: true,
        }
        {
          extension: .fake-dao-epoch,
          enabled: true,
        }
        {
          extension: .fake-dao-users,
          enabled: true,
        }
        {
          extension: .fake-onchain-messaging,
          enabled: true,
        }
        {
          extension: .fake-token-owner,
          enabled: true,
        }
        {
          extension: .fake-treasury,
          enabled: true,
        }
        ;; initial action proposals (as extensions)
        {
          extension: .fake-action-send-message,
          enabled: true,
        }
      )))
    ;; allow default assets in treasury
    (try! (contract-call? .fake-treasury allow-asset CFG_DAO_TOKEN true))
    (try! (contract-call? .fake-treasury allow-asset CFG_SBTC_TOKEN true))
    ;; set DAO manifest in dao-charter extension
    (try! (contract-call? .fake-dao-charter set-dao-charter CFG_DAO_MANIFEST_TEXT))
    ;; send DAO manifest as onchain message
    (try! (contract-call? .fake-onchain-messaging send CFG_DAO_MANIFEST_TEXT))
    ;; print initialization data
    (print {
      notification: "fake-base-initialize-dao/execute",
      payload: {
        manifest: CFG_DAO_MANIFEST_TEXT,
        sender: sender,
        contractCaller: contract-caller,
        txSender: tx-sender,
      },
    })
    (ok true)
  )
)
