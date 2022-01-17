
(define-constant ERR-NOT-AUTHORIZED u19401)
(define-constant ERR-BURN-HEIGHT-NOT-REACHED u191)
(define-constant ERR-WRONG-STACKER u192)
(define-constant ERR-WRONG-COLLATERAL-TOKEN u193)
(define-constant ERR-ALREADY-STACKING u194)
(define-constant ERR-EMERGENCY-SHUTDOWN-ACTIVATED u195)
(define-constant ERR-VAULT-LIQUIDATED u196)
(define-constant ERR-STILL-STACKING u197)

(define-data-var stacking-unlock-burn-height uint u0) 
(define-data-var stacking-stx-stacked uint u0) 
(define-data-var stacker-shutdown-activated bool false)
(define-data-var stacker-name (string-ascii 256) "l-stacker-2")

(define-read-only (get-stacking-unlock-burn-height)
  (ok (var-get stacking-unlock-burn-height))
)

(define-read-only (get-stacking-stx-stacked)
  (ok (var-get stacking-stx-stacked))
)


(define-public (initiate-stacking (pox-addr (tuple (version (buff 1)) (hashbytes (buff 20))))
                                  (start-burn-ht uint)
                                  (lock-period uint))
  (let (
    (tokens-to-stack (unwrap! (contract-call? .stackswap-stx-reserve-v1b get-tokens-to-stack (var-get stacker-name)) (ok u0)))
    (stx-balance (get-stx-balance))
  )
    (asserts! (is-eq tx-sender (contract-call? .stackswap-dao-v5k get-dao-owner)) (err ERR-NOT-AUTHORIZED))
    (asserts! (>= burn-block-height (var-get stacking-unlock-burn-height)) (err ERR-ALREADY-STACKING))

    (match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.pox can-stack-stx pox-addr tokens-to-stack start-burn-ht lock-period))
      success (begin
        (if (> tokens-to-stack stx-balance)
          (try! (contract-call? .stackswap-stx-reserve-v1b request-stx-to-stack (var-get stacker-name) (- tokens-to-stack stx-balance)))
          true
        )
        (match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.pox stack-stx tokens-to-stack pox-addr start-burn-ht lock-period))
          result (begin
            (print result)
            (var-set stacking-unlock-burn-height (get unlock-burn-height result))
            (var-set stacking-stx-stacked (get lock-amount result))
            (try! (contract-call? .stackswap-mortgager-v1b set-stacking-unlock-burn-height (var-get stacker-name) (get unlock-burn-height result)))
            (try! (contract-call? .stackswap-stx-reserve-v1b set-next-stacker-name "l-stacker-3"))
            (ok (get lock-amount result))
          )
          error (begin
            (print (err (to-uint error)))
          )
        )
      )
      failure (print (err (to-uint failure)))
    )
  )
)

(define-read-only (get-stx-balance)
  (stx-get-balance (as-contract tx-sender))
)

(define-public (return-stx (ustx-amount uint))
  (begin
    (asserts! (is-eq tx-sender (contract-call? .stackswap-dao-v5k get-dao-owner)) (err ERR-NOT-AUTHORIZED))

    (as-contract
      (stx-transfer? ustx-amount tx-sender (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "l-stx-reserve")))
    )
  )
)

(define-public (enable-vault-withdrawals (vault-id uint))
  (let (
    (vault (contract-call? .stackswap-vault-data-v1b get-vault-by-id vault-id))
  )

    (asserts! (is-eq "STX" (get collateral-token vault)) (err ERR-WRONG-COLLATERAL-TOKEN))
    (asserts! 
      (or 
        (is-eq false (get is-liquidated vault))
        (is-eq true (get liquidation-finished vault))
      )
      (err ERR-VAULT-LIQUIDATED))
    (asserts! (is-eq true (get revoked-stacking vault)) (err ERR-STILL-STACKING))
    (asserts!
      (or
        (is-eq u0 (var-get stacking-stx-stacked))
        (>= burn-block-height (get toggled-at-block-height vault))
      )
      (err ERR-BURN-HEIGHT-NOT-REACHED)
    )
    (asserts! (is-eq (var-get stacker-name) (get stacker-name vault)) (err ERR-WRONG-STACKER))

    (try! (contract-call? .stackswap-vault-data-v1b update-vault vault-id (merge vault {
        stacked-tokens: u0,
        updated-at-block-height: block-height
      }))
    )
    (ok true)
  )
)

