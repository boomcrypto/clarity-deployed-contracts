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
    (total-ids (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-liquidation-rewards-v1-2 get-total-reward-ids))
    (last-id (var-get last-total-reward-ids))

    (reward-list (map + 
      (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25) 
      (list last-id last-id last-id last-id last-id last-id last-id last-id last-id last-id last-id last-id last-id last-id last-id last-id last-id last-id last-id last-id last-id last-id last-id last-id last-id)
    ))
    (total-list (list total-ids total-ids total-ids total-ids total-ids total-ids total-ids total-ids total-ids total-ids total-ids total-ids total-ids total-ids total-ids total-ids total-ids total-ids total-ids total-ids total-ids total-ids total-ids total-ids total-ids))
  )
    (asserts! (is-eq contract-caller .lydian-dao) (err  ERR-NOT-AUTHORIZED))
    
    (map claim-liquidation-rewards reward-list total-list)

    (if (< (+ last-id u25) total-ids) 
      (var-set last-total-reward-ids (+ last-id u25))
      (var-set last-total-reward-ids (- total-ids u1))
    )

    (ok true)
  )
)

;; ------------------------------------------
;; Helpers
;; ------------------------------------------

(define-private (claim-liquidation-rewards (reward-id uint) (total-reward-ids uint))
  (let (
    (reward-claimed (get claimed (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-liquidation-rewards-v1-2 get-reward-claimed reward-id .lydian-dao)))
  )
    (if (and (not reward-claimed) (< reward-id total-reward-ids))
      (try! (claim-liquidation-rewards-helper reward-id))
      false
    )
    (ok true)
  )
)

(define-private (claim-liquidation-rewards-helper (reward-id uint))
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
