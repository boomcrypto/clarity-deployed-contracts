;; @contract Harvest liquidation pool rewards (xSTX)
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
(define-data-var next-unlock-block uint u0)

(define-read-only (get-last-total-reward-ids)
  (var-get last-total-reward-ids)
)

(define-read-only (get-next-unlock-block)
  (var-get next-unlock-block)
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

    ;; Reset to 0
    (var-set next-unlock-block u0)
    
    ;; Loop over all rewards, will set next-unlock-block to earliest unlock block
    (map claim-liquidation-rewards reward-list total-list)

    ;; Check if anything left to claim in next batch
    (if (is-eq (var-get next-unlock-block) u0)
      (if (< (+ last-id u25) total-ids) 
        (var-set last-total-reward-ids (+ last-id u25))
        (var-set last-total-reward-ids (- total-ids u1))
      )
      false
    )

    (ok true)
  )
)

;; ------------------------------------------
;; Helpers
;; ------------------------------------------

(define-read-only (has-claimed-reward (reward-id uint) (total-reward-ids uint))
  (let (
    (reward-claimed (get claimed (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-liquidation-rewards-v1-2 get-reward-claimed reward-id .lydian-dao)))
    (reward-data (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-liquidation-rewards-v1-2 get-reward-data reward-id))

    (is-xstx (and 
      (is-eq (get token reward-data) 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.xstx-token)
      (is-eq (get token-is-stx reward-data) false)
    ))
  )
    (and
      (< reward-id total-reward-ids)
      (or 
        reward-claimed
        (not is-xstx)
      )
    )
  )
)

(define-read-only (can-claim-reward (reward-id uint) (total-reward-ids uint))
  (let (
    (reward-claimed (get claimed (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-liquidation-rewards-v1-2 get-reward-claimed reward-id .lydian-dao)))
    (reward-data (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-liquidation-rewards-v1-2 get-reward-data reward-id))
  )
    (and 
      (not reward-claimed) 
      (< reward-id total-reward-ids)
      (is-eq (get token reward-data) 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.xstx-token)
      (is-eq (get token-is-stx reward-data) false)
      (> (get unlock-block reward-data) block-height)
    )
  )
)

(define-private (claim-liquidation-rewards (reward-id uint) (total-reward-ids uint))
  (let (
    (reward-claimed (get claimed (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-liquidation-rewards-v1-2 get-reward-claimed reward-id .lydian-dao)))
    (reward-data (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-liquidation-rewards-v1-2 get-reward-data reward-id))
    (is-xstx (and
      (is-eq (get token reward-data) 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.xstx-token)
      (is-eq (get token-is-stx reward-data) false)
    ))
  )
    ;; Check if token is xSTX + not claimed + reward exist
    (if (and is-xstx (not reward-claimed) (< reward-id total-reward-ids))

      ;; Check if unlock block passed
      (if (> (get unlock-block reward-data) block-height)
        (begin
          (try! (claim-reward-xstx reward-id))
          (ok true)
        )

        ;; Check if next-unlock-block needs to be updated
        (if (or (is-eq (var-get next-unlock-block) u0) (< (get unlock-block reward-data) (var-get next-unlock-block)))
          (begin
            (var-set next-unlock-block (get unlock-block reward-data))
            (ok false)
          )
          (ok false)
        )
      )

      (ok false)
    )
  )
)

(define-private (claim-reward-xstx (reward-id uint))
  (begin
    ;; Claim
    (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-liquidation-rewards-v1-2 claim-rewards-of 
      reward-id
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.xstx-token
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-liquidation-pool-v1-1
    ))
    ;; Redeem STX
    (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stacker-payer-v3-2 redeem-stx-helper 
      (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.xstx-token get-balance .lydian-dao)) 
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