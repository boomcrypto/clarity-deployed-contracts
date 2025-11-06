;; title: aibtc-base-dao-trait
;; version: 3.3.3
;; summary: A trait that defines an aibtc base dao.

(use-trait proposal-trait .aibtc-dao-traits.proposal)
(use-trait extension-trait .aibtc-dao-traits.extension)

(define-trait aibtc-base-dao (
  (execute
    (<proposal-trait> principal)
    (response bool uint)
  )
  (set-extension
    (principal bool)
    (response bool uint)
  )
  (request-extension-callback
    (<extension-trait> (buff 34))
    (response bool uint)
  )
))
