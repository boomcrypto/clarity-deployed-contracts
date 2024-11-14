;; .derupt-miners Contract
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-NOTFOUND (err u101))

;; Get Derupt core contract
(define-read-only (get-derupt-core-contract)
  (contract-call? .derupt-feed get-derupt-core-contract)
)

;; Log Mine
(define-public (log-mine (miner principal) (mine-amounts (list 200 uint)))
  (let 
    ((derupt-core-contract (unwrap! (get-derupt-core-contract) ERR-NOTFOUND))) 
    (asserts! (is-eq contract-caller derupt-core-contract) ERR-UNAUTHORIZED)
    (print { event: "mine", miner: miner, mine-total: (fold + mine-amounts u0), mine-amounts: mine-amounts })
    (ok true)
  )
)

;; Log Mining Reward Claim
(define-public (log-mining-reward-claim (claimHeights (list 200 uint)))
  (let 
    ((derupt-core-contract (unwrap! (get-derupt-core-contract) ERR-NOTFOUND))) 
    (asserts! (is-eq contract-caller derupt-core-contract) ERR-UNAUTHORIZED)
    (print { event: "mining-reward-claim", miner: tx-sender, claimHeights: claimHeights })
    (ok true)
  )
)