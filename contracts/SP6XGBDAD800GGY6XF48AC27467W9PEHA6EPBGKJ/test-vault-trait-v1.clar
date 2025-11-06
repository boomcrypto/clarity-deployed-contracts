;; @contract Vault Trait v1
;; @version 1.0

(define-trait vault-trait
  (
    ;; User functions
    (deposit (uint (optional (buff 64))) (response uint uint))
    (init-withdraw (uint bool) (response uint uint))
    (withdraw (uint) (response uint uint))
    (withdraw-many ((list 1000 uint)) (response uint uint))
    
    ;; Protocol functions
    (fund-claim (uint) (response bool uint))
    (fund-claim-many ((list 1000 uint)) (response bool uint))
    
    ;; Read-only functions
    (get-claim (uint) (response {
      user: principal,
      assets: uint,
      fee: uint,
      ts: uint,
      is-funded: bool
    } uint))
  )
)