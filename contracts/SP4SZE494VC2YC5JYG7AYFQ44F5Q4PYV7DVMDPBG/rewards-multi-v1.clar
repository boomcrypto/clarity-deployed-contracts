;; @contract Rewards Multi
;; @version 1
;;

(use-trait commission-trait .commission-trait-v1.commission-trait)
(use-trait staking-trait .staking-trait-v1.staking-trait)
(use-trait reserve-trait .reserve-trait-v1.reserve-trait)

;;-------------------------------------
;; Add 
;;-------------------------------------

(define-public (add-rewards 
  (commission <commission-trait>) 
  (staking <staking-trait>) 
  (reserve <reserve-trait>) 
  (rewards-list (list 20 (tuple (pool principal) (amount uint))))
) 
  (let (
    ;; Add all rewards from list
    (errors (filter is-error (map add-rewards-helper rewards-list)))
    (error (element-at? errors u0))
  )
    (asserts! (is-eq error none) (unwrap-panic error))

    ;; Try to process
    (match (contract-call? .rewards-v2 process-rewards commission staking reserve)
      success (ok true)
      fail (ok false)
    )
  )
)

;;-------------------------------------
;; Helpers 
;;-------------------------------------

(define-private (add-rewards-helper (reward (tuple (pool principal) (amount uint))))
  (contract-call? .rewards-v2 add-rewards (get pool reward) (get amount reward))
)

(define-read-only (is-error (response (response bool uint)))
  (is-err response)
)
