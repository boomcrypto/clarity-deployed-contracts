(define-read-only (read-balance-at-block (address principal) (block uint))
    (let
        ((block-hash (unwrap-panic (get-stacks-block-info? id-header-hash block))))
        (at-block block-hash (unwrap-panic (contract-call? .capy-stxcity get-balance address)))))