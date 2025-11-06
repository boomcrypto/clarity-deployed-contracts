;; Wrapper Example
;; This contract is a wrapper contract that wraps around the foobar-defi contract.
;; It showcases how Cofund vaults can be used to wrap around existing dapp contracts / protocols.
;; The pattern here follows a single entrypoint (router-wrapper) that takes in a name & a byte of instructions.
;; The name is used to determine which function to call, & the instructions are used to pass in the parameters.

;; cons
;; errs
(define-constant ERR_INVALID_INSTRUCTIONS (err u500))

;; router-wrapper
;; This function is the entrypoint for the wrapper contract.
;; It takes in a name of a function & a byte of instructions (serialized tuple).
;; It then calls the appropriate function based on the name & passes in the instructions.
;; The instructions are then deserialized into a tuple & finally passed into the appropriate contract call.
(define-public (router-wrapper (name (string-ascii 128)) (instructions (buff 4096)))
    (begin
        (if (is-eq name "mint-token")
            (try! (mint-token-wrapper instructions))
            (try! (transfer-token-wrapper instructions))
        )
        (ok true)
    )
)
(define-private (mint-token-wrapper (params (buff 4096)))
    (let
        (
            (params-deserialized (unwrap! (from-consensus-buff? {amount: uint} params) ERR_INVALID_INSTRUCTIONS))
            (params-amount (get amount params-deserialized))
        )
        (begin
            (try! (contract-call? .foobar-defi mint-token params-amount))
            (ok true)
        )
    )
)
(define-private (transfer-token-wrapper (params (buff 4096)))
    (let
        (
            (params-deserialized (unwrap! (from-consensus-buff? {amount: uint, to: principal} params) ERR_INVALID_INSTRUCTIONS))
            (params-amount (get amount params-deserialized))
            (params-to (get to params-deserialized))
        )
        (begin
            (try! (contract-call? .foobar-defi transfer-token params-amount params-to))
            (ok true)
        )
    )
)