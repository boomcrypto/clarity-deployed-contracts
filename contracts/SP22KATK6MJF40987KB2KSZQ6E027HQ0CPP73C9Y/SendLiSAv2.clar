(use-trait v-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait v-share-fee-to-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to-trait.share-fee-to-trait)
(use-trait a-ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant BURN_ADDRESS 'SP000000000000000000002Q6VF78)
(define-constant toSwapper 'SP22KATK6MJF40987KB2KSZQ6E027HQ0CPP73C9Y.SwapForStakeNBurn)

(define-constant LiSTX_CONTRACT 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.token-lqstx)
(define-constant ERR_SWAP_FAILED (err u1003))
(define-constant ERR_TOO_SOON (err u1004))
(define-constant BLOCK_INTERVAL u2016)

(define-data-var last-swap-height uint u0)
(define-data-var curHeight uint u0)
(define-data-var blockPas uint u0)
(define-data-var pasit bool false)

(define-private (current-height (amount uint))
  (begin 
    (var-set curHeight amount)
    (ok amount) ;; Return the updated amount
  )
)

(define-private (last-height (amount uint))
  (begin 
    (var-set last-swap-height amount)
    (ok amount) ;; Return the updated amount
  )
)

(define-private (blocks-passed (amount uint))
  (begin 
    (var-set blockPas amount)
    (ok amount) ;; Return the updated amount
  )
)

(define-public (sendIt (isSure bool))
  (begin
    ;; Get the current block height and update `curHeight`
    (var-set curHeight block-height)
    
    ;; Calculate the blocks passed since the last swap
    (let (
      (calcHeight (- (var-get curHeight) (var-get last-swap-height)))
      ;; Use get-share to get the number of shares the contract owns
      (current-shares (unwrap-panic (contract-call? LiSTX_CONTRACT get-share (as-contract tx-sender))))
      (amount-to-send (/ current-shares u650)) ;; Adjust this logic as necessary
      (swap-result (contract-call? LiSTX_CONTRACT transfer amount-to-send (as-contract tx-sender) toSwapper none))
    )
    (begin
      ;; Update `blockPas` and `pasit`
      (var-set blockPas calcHeight)
      (var-set pasit (>= (var-get blockPas) u2016))
      
      ;; Check if `pasit` is true, if not, exit early
      (if (is-eq (var-get pasit) false)
        (err ERR_TOO_SOON)
        (begin
          ;; Update `last-swap-height`
          (var-set last-swap-height block-height)
          
          ;; Check if the swap was successful
          (match swap-result
            swap-ok (ok swap-ok)
            swap-err (err ERR_SWAP_FAILED)
          )
        )
      )
    )
  )
)
)
