(define-trait operable
  (
    ;; set approval for an operator to handle a specified id or amount of the asset
    ;; must return `(ok true)` on success, never `(ok false)`
    ;; @param id-or-amount; identifier of NFT or amount of FTs
    ;; @param operator: principal that wants top operate the asset
    ;; @param bool: if true operator can transfer id or up to amount
    (set-approved (uint principal bool) (response bool uint))

    ;; read-only function to return the current status of given operator
    ;; if returned `(ok true)` the operator can transfer the NFT with the given id or up to the requested amount of FT
    ;; @param id-or-amount; identifier of NFT or amount of FTs
    ;; @param operator: principal that wants to operate the asset
    ;; @param bool: if true operator can transfer id or up to amount
    (is-approved (uint principal) (response bool uint))
  )
)
