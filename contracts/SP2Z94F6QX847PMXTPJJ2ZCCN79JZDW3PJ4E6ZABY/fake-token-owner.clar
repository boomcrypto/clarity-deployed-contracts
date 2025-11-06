;; title: aibtc-token-owner
;; version: 1.0.0
;; summary: An extension that provides management functions for the dao token

;; traits
;;

(impl-trait 'SPW8QZNWKZGVHX012HCBJVJVPS94PXFG578P53TM.aibtc-dao-traits.extension)
(impl-trait 'SPW8QZNWKZGVHX012HCBJVJVPS94PXFG578P53TM.aibtc-dao-traits.token-owner)

;; constants
;;

(define-constant ERR_NOT_DAO_OR_EXTENSION (err u1800))

;; public functions
;;

(define-public (callback
    (sender principal)
    (memo (buff 34))
  )
  (ok true)
)

(define-public (set-token-uri (value (string-utf8 256)))
  (begin
    ;; check if caller is authorized
    (try! (is-dao-or-extension))
    ;; update token uri
    (try! (as-contract (contract-call? .fake-faktory set-token-uri value)))
    ;; print event
    (print {
      notification: "fake-token-owner/set-token-uri",
      payload: {
        contractCaller: contract-caller,
        txSender: tx-sender,
        value: value,
      },
    })
    (ok true)
  )
)

;; keeping old format for trait adherance
(define-public (transfer-ownership (new-owner principal))
  (begin
    ;; check if caller is authorized
    (try! (is-dao-or-extension))
    ;; transfer ownership
    (try! (as-contract (contract-call? .fake-faktory set-contract-owner new-owner)))
    ;; print event
    (print {
      notification: "fake-token-owner/transfer-ownership",
      payload: {
        contractCaller: contract-caller,
        txSender: tx-sender,
        newOwner: new-owner,
      },
    })
    (ok true)
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
