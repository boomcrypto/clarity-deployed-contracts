;; @contract Harvest liquidation pool rewards (DIKO, xBTC, STX, atALEX) - not xSTX
;; @version 1.1

(impl-trait .lydian-dao-proposal-trait.lydian-dao-proposal-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant ERR-NOT-AUTHORIZED u1001)

;; ------------------------------------------
;; Variables
;; ------------------------------------------

(define-data-var last-total-reward-ids uint u30)

(define-read-only (get-last-total-reward-ids)
  (var-get last-total-reward-ids)
)

;; ------------------------------------------
;; DAO execution
;; ------------------------------------------

(define-public (execute)
  (let (
    (total-reward-ids (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-liquidation-rewards-v1-2 get-total-reward-ids))
    (id-1 (+ (var-get last-total-reward-ids) u1))
    (id-2 (+ (var-get last-total-reward-ids) u2))
    (id-3 (+ (var-get last-total-reward-ids) u3))
    (id-4 (+ (var-get last-total-reward-ids) u4))
    (id-5 (+ (var-get last-total-reward-ids) u5))
    (id-6 (+ (var-get last-total-reward-ids) u6))
    (id-7 (+ (var-get last-total-reward-ids) u7))
    (id-8 (+ (var-get last-total-reward-ids) u8))
    (id-9 (+ (var-get last-total-reward-ids) u9))
    (id-10 (+ (var-get last-total-reward-ids) u10))
  )
    (asserts! (is-eq contract-caller .lydian-dao) (err  ERR-NOT-AUTHORIZED))
    
    (if (< id-1 total-reward-ids) (try! (claim-liquidation-rewards id-1)) false)
    (if (< id-2 total-reward-ids) (try! (claim-liquidation-rewards id-2)) false)
    (if (< id-3 total-reward-ids) (try! (claim-liquidation-rewards id-3)) false)
    (if (< id-4 total-reward-ids) (try! (claim-liquidation-rewards id-4)) false)
    (if (< id-5 total-reward-ids) (try! (claim-liquidation-rewards id-5)) false)
    (if (< id-6 total-reward-ids) (try! (claim-liquidation-rewards id-6)) false)
    (if (< id-7 total-reward-ids) (try! (claim-liquidation-rewards id-7)) false)
    (if (< id-8 total-reward-ids) (try! (claim-liquidation-rewards id-8)) false)
    (if (< id-9 total-reward-ids) (try! (claim-liquidation-rewards id-9)) false)
    (if (< id-10 total-reward-ids) (try! (claim-liquidation-rewards id-10)) false)

    (if (< id-10 total-reward-ids) 
      (var-set last-total-reward-ids id-10)
      (var-set last-total-reward-ids (- total-reward-ids u1))
    )

    (ok true)
  )
)

;; ------------------------------------------
;; Helpers
;; ------------------------------------------

(define-public (claim-liquidation-rewards (reward-id uint))
  (let (
    (reward-data (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-liquidation-rewards-v1-2 get-reward-data reward-id))
  )
    ;; DIKO
    (if (is-eq (get token reward-data) 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token)
      (begin
        (try! (claim-reward-diko reward-id))
        true
      )
      false
    )

    ;; STX
    (if 
      (and
        (is-eq (get token reward-data) 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.xstx-token)
        (is-eq (get token-is-stx reward-data) true)
      )
      (begin
        (try! (claim-reward-stx reward-id))
        true
      )
      false
    )

    ;; xBTC
    (if (is-eq (get token reward-data) 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin)
      (begin
        (try! (claim-reward-xbtc reward-id))
        true
      )
      false
    )

    ;; auto-alex
    (if (is-eq (get token reward-data) 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex)
      (begin
        (try! (claim-reward-autoalex reward-id))
        true
      )
      false
    )

    (ok true)
  )
)

(define-private (claim-reward-diko (reward-id uint))
  (begin
    ;; Claim and keep in DAO
    (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-liquidation-rewards-v1-2 claim-rewards-of 
      reward-id
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-liquidation-pool-v1-1
    ))
    (ok true)
  )
)

(define-private (claim-reward-stx (reward-id uint))
  (begin
    ;; Claim
    (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-liquidation-rewards-v1-2 claim-rewards-of 
      reward-id
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.xstx-token
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-liquidation-pool-v1-1
    ))
    ;; Wrap
    (try! (contract-call? .wrapped-stacks-token wrap 
      (stx-get-balance .lydian-dao)
    ))
    ;; Transfer to treasury
    (try! (contract-call? .wrapped-stacks-token transfer 
      (unwrap-panic (contract-call? .wrapped-stacks-token get-balance .lydian-dao)) 
      .lydian-dao 
      .treasury-v1-1 
      none
    ))
    (ok true)
  )
)

(define-private (claim-reward-xbtc (reward-id uint))
  (begin
    ;; Claim
    (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-liquidation-rewards-v1-2 claim-rewards-of 
      reward-id
      'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-liquidation-pool-v1-1
    ))
    ;; Transfer to treasury
    (try! (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin transfer 
      (unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance .lydian-dao)) 
      .lydian-dao 
      .treasury-v1-1 
      none
    ))
    (ok true)
  )
)

(define-private (claim-reward-autoalex (reward-id uint))
  (begin
    ;; Claim
    (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-liquidation-rewards-v1-2 claim-rewards-of 
      reward-id
      'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-liquidation-pool-v1-1
    ))
    ;; Transfer to treasury
    (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex transfer 
      (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex get-balance .lydian-dao)) 
      .lydian-dao 
      .treasury-v1-1 
      none
    ))
    (ok true)
  )
)
