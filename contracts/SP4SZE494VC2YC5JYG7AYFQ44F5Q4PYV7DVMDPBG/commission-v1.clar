;; @contract Commission
;; @version 1
;;
;; Part of the stacking rewards are captured as commission.
;; The commission is split between the protocol and stakers.

(impl-trait .commission-trait-v1.commission-trait)
(use-trait staking-trait .staking-trait-v1.staking-trait)

;;-------------------------------------
;; Constants 
;;-------------------------------------

(define-constant ERR_MIN_STAKING_BASISPOINTS u29001)

(define-constant MIN_STAKING_BASISPOINTS u7000) ;; 70% in basis points

;;-------------------------------------
;; Variables 
;;-------------------------------------

(define-data-var staking-basispoints uint u0) ;; 0% in basis points, set later

;;-------------------------------------
;; Getters 
;;-------------------------------------

(define-read-only (get-staking-basispoints)
  (var-get staking-basispoints)
)

;;-------------------------------------
;; Helpers 
;;-------------------------------------

;; Adding rewards for cycle X happens at the end of cycle X+1
;; These rewards are distributed per block during cycle X+2,
;; and the distribution ends at the end of cycle X+2 plus pox-prepare-length
(define-read-only (get-cycle-rewards-end-block) 
  (let (
    (current-cycle (contract-call? 'SP000000000000000000002Q6VF78.pox-3 current-pox-reward-cycle))
    (cycle-end-block (contract-call? 'SP000000000000000000002Q6VF78.pox-3 reward-cycle-to-burn-height (+ current-cycle u2)))
    (pox-prepare-length (get prepare-cycle-length (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.pox-3 get-pox-info))))
  )
    (+ cycle-end-block pox-prepare-length)
  )
)

;;-------------------------------------
;; Trait 
;;-------------------------------------

;; Used by core contract
;; Commission is split between stakers and protocol
(define-public (add-commission (staking-contract <staking-trait>) (stx-amount uint))
  (let (
    (amount-for-staking (/ (* stx-amount (get-staking-basispoints)) u10000))
    (amount-to-keep (- stx-amount amount-for-staking))
  )
    (try! (contract-call? .dao check-is-protocol (contract-of staking-contract)))

    ;; Send to stakers
    (if (> amount-for-staking u0)
      (try! (contract-call? staking-contract add-rewards amount-for-staking (get-cycle-rewards-end-block)))
      u0    
    )

    ;; Keep in contract
    (if (> amount-to-keep u0)
      (try! (stx-transfer? amount-to-keep tx-sender (as-contract tx-sender)))
      false
    )

    (ok stx-amount)
  )
)

;;-------------------------------------
;; Get commission 
;;-------------------------------------

(define-public (withdraw-commission)
  (let (
    (receiver tx-sender)
    (amount (stx-get-balance (as-contract tx-sender)))
  )
    (try! (contract-call? .dao check-is-protocol tx-sender))

    (try! (as-contract (stx-transfer? amount tx-sender receiver)))

    (ok amount)
  )
)

;;-------------------------------------
;; Admin 
;;-------------------------------------

(define-public (set-staking-basispoints (new-basispoints uint))
  (begin
    (try! (contract-call? .dao check-is-protocol tx-sender))
    (asserts! (>= new-basispoints MIN_STAKING_BASISPOINTS) (err ERR_MIN_STAKING_BASISPOINTS))

    (var-set staking-basispoints new-basispoints)
    (ok true)
  )
)
