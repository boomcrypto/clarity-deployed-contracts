(use-trait proposal-trait .aibtcdev-dao-traits-v1.proposal)
(use-trait extension-trait .aibtcdev-dao-traits-v1.extension)

(define-trait aibtcdev-base-dao (
    ;; Execute a governance proposal
    (execute (<proposal-trait> principal) (response bool uint))
    ;; Enable or disable an extension contract
    (set-extension (principal bool) (response bool uint))
    ;; Request extension callback
    (request-extension-callback (<extension-trait> (buff 34)) (response bool uint))
))
