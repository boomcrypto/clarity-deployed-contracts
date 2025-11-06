(define-constant ERR_STX_BLOCK_IN_FUTURE (err u101))

;; Get user's sBTC balance at a specific block height
(define-read-only (get-user-sbtc-balance-at-block
    (user principal)
    (stacks-height uint)
  )
  (ok (at-block
    ;; Get the block header hash for the specified block height
    (unwrap!
      (get-stacks-block-info? id-header-hash stacks-height)
      ERR_STX_BLOCK_IN_FUTURE
    )
    ;; Get the user's available sBTC balance at that block height
    (unwrap-panic (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance-available user))
  ))
)
