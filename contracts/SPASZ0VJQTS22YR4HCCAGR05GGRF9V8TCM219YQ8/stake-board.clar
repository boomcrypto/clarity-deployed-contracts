
;; constants
(define-constant ERR-NOT-AUTHORIZED (err u3001))
(define-constant ERR-REWARDS-CALC (err u3002))

;; variables
(define-data-var contract-start-block uint block-height)
(define-data-var total-staked uint u0)
(define-data-var cumm-reward-per-stake uint u0)
(define-data-var last-reward-increase-block uint u0) 

;; maps
(define-map stakes 
   { staker: principal } 
   {
      uamount: uint,  ;; Total value
      total-token-points: uint, ;; Tile points + level
      amount-staked: uint, ;; Tiles staked
      cumm-reward-per-stake: uint
   }
)
(define-map user-tokens { user: principal } { token-ids: (list 200 uint) })
(define-map removing-token { user: principal } { token-id: uint })

;;
;; Getters
;;

;; User lists
(define-read-only (get-user-tokens (user principal))
  (unwrap! (map-get? user-tokens { user: user }) (tuple (token-ids (list ))  ))
)

(define-private (add-token-to-user-list (user principal) (token-id uint))
  (let (
    (current-user-tokens (get token-ids (get-user-tokens user)))
  )
    (map-set user-tokens { user: user } { token-ids: (unwrap-panic (as-max-len? (append current-user-tokens token-id) u200)) })
  )
)

(define-private (remove-token-from-user-list (user principal) (token-id uint))
  (let (
    (token-ids (get token-ids (get-user-tokens user)))
  )
    (map-set removing-token { user: user } { token-id: token-id })
    (map-set user-tokens { user: user } { token-ids: (filter remove-unstaked-token token-ids) })
  )
)

(define-private (remove-unstaked-token (token-id uint))
  (let (
    (current-token (unwrap-panic (map-get? removing-token { user: tx-sender })))
  )
    (if (is-eq token-id (get token-id current-token))
      false
      true
    )
  )
)

;;
;; Getters
;;

;; Keep track of total amount staked and last cumm reward per stake
(define-read-only (get-stake-of (staker principal))
  (default-to
    { uamount: u0, total-token-points: u0, amount-staked: u0, cumm-reward-per-stake: u0 }
    (map-get? stakes { staker: staker })
  )
)

;; Get stake info - amount staked
(define-read-only (get-stake-amount-of (staker principal))
  (get uamount (get-stake-of staker))
)

;; Get stake info - last rewards block
(define-read-only (get-stake-cumm-reward-per-stake-of (staker principal))
  (get cumm-reward-per-stake (get-stake-of staker))
)

;; Get variable total-staked
(define-read-only (get-total-staked)
  (var-get total-staked)
)

;; Get variable cumm-reward-per-stake
(define-read-only (get-cumm-reward-per-stake)
  (var-get cumm-reward-per-stake)
)

;; Get variable last-reward-increase-block
(define-read-only (get-last-reward-increase-block)
  (var-get last-reward-increase-block)
)

;; 
;; Stake / unstake
;; 

(define-public (stake (token-id uint))
  (begin
    ;; Save currrent cumm reward per stake
    (unwrap-panic (increase-cumm-reward-per-stake))

    (let (
      ;; Token info
      (token-points (contract-call? .tiles get-token-points token-id))
      (token-level (contract-call? .tiles get-token-level token-id))

      ;; Current
      (current-stake (get-stake-of tx-sender))
      (current-uamount (get uamount current-stake))
      (current-total-token-points (get total-token-points current-stake))
      (current-amount-staked (get amount-staked current-stake))
      
      ;; New
      (new-total-token-points (+ current-total-token-points (* token-points token-level)))
      (new-amount-staked (+ current-amount-staked u1))

      (new-uamount (* new-total-token-points new-amount-staked))
    )
      ;; Claim all pending rewards for staker so we can set the new cumm-reward for this user
      (try! (claim-pending-rewards))

      ;; Add token to list
      (add-token-to-user-list tx-sender token-id)

      ;; Update total stake
      (var-set total-staked (- (var-get total-staked) current-uamount))
      (var-set total-staked (+ (var-get total-staked) new-uamount))

      ;; Update cumm reward per stake now that total is updated
      (unwrap-panic (increase-cumm-reward-per-stake))

      ;; Transfer NFT token to this contract
      (try! (contract-call? .tiles transfer token-id tx-sender (as-contract tx-sender)))

      ;; Update sender stake info
      (map-set stakes { staker: tx-sender } { 
        uamount: new-uamount, 
        total-token-points: new-total-token-points,
        amount-staked: new-amount-staked,
        cumm-reward-per-stake: (var-get cumm-reward-per-stake) 
      })

      (ok token-id)
    )
  )
)

(define-public (unstake (token-id uint))
  (begin
    ;; Save currrent cumm reward per stake
    (unwrap-panic (increase-cumm-reward-per-stake))

    (let (
      (staker tx-sender)

      ;; Token info
      (token-points (contract-call? .tiles get-token-points token-id))
      (token-level (contract-call? .tiles get-token-level token-id))

      ;; Current
      (current-stake (get-stake-of tx-sender))
      (current-uamount (get uamount current-stake))
      (current-total-token-points (get total-token-points current-stake))
      (current-amount-staked (get amount-staked current-stake))
      
      ;; New
      (new-total-token-points (- current-total-token-points (* token-points token-level)))
      (new-amount-staked (- current-amount-staked u1))

      (new-uamount (* new-total-token-points new-amount-staked))
    )
      ;; Claim all pending rewards for staker so we can set the new cumm-reward for this user
      (try! (claim-pending-rewards))

      ;; Remove token from list
      (remove-token-from-user-list tx-sender token-id)

      ;; Update total stake
      (var-set total-staked (- (var-get total-staked) current-uamount))
      (var-set total-staked (+ (var-get total-staked) new-uamount))

      ;; Update cumm reward per stake now that total is updated
      (unwrap-panic (increase-cumm-reward-per-stake))

      ;; Transfer NFT token from this contract
      (try! (as-contract (contract-call? .tiles transfer token-id tx-sender staker)))

      ;; Update sender stake info
      (map-set stakes { staker: tx-sender } { 
        uamount: new-uamount, 
        total-token-points: new-total-token-points,
        amount-staked: new-amount-staked,
        cumm-reward-per-stake: (var-get cumm-reward-per-stake) 
      })

      (ok token-id)
    )
  )
)

;; 
;; Rewards
;; 

(define-public (get-pending-rewards (staker principal))
  (let (
    (stake-amount (get-stake-amount-of staker))
    (amount-owed-per-token (- (unwrap-panic (calculate-cumm-reward-per-stake)) (get-stake-cumm-reward-per-stake-of staker)))
    (rewards-decimals (* stake-amount amount-owed-per-token))
    (rewards (/ rewards-decimals u1000000))
  )
    (ok rewards)
  )
)

(define-public (claim-pending-rewards)
  (begin
    (unwrap-panic (increase-cumm-reward-per-stake))
    (let (
      (pending-rewards (unwrap! (get-pending-rewards tx-sender) ERR-REWARDS-CALC))
      (stake-of (get-stake-of tx-sender))
    )
      (if (>= pending-rewards u1)
        (begin
          (try! (contract-call? .points mint-points pending-rewards tx-sender))
          (map-set stakes { staker: tx-sender } (merge stake-of { cumm-reward-per-stake: (var-get cumm-reward-per-stake) }))
          (ok pending-rewards)
        )
        (ok u0)
      )
    )
  )
)

(define-public (increase-cumm-reward-per-stake)
  (let (
    (new-cumm-reward-per-stake (unwrap-panic (calculate-cumm-reward-per-stake)))
  )
    (var-set cumm-reward-per-stake new-cumm-reward-per-stake)
    (var-set last-reward-increase-block block-height)
    (ok new-cumm-reward-per-stake)
  )
)

(define-public (calculate-cumm-reward-per-stake)
  (let (
    (rewards-per-block (get-rewards-per-block)) 
    (current-total-staked (var-get total-staked))
    (block-diff (- block-height (var-get last-reward-increase-block)))
    (current-cumm-reward-per-stake (var-get cumm-reward-per-stake)) 
  )
    (if (> current-total-staked u0)
      (let (
        (total-rewards-to-distribute (* rewards-per-block block-diff))
        (reward-added-per-token (/ (* total-rewards-to-distribute u1000000) current-total-staked))
        (new-cumm-reward-per-stake (+ current-cumm-reward-per-stake reward-added-per-token))
      )
        (ok new-cumm-reward-per-stake)
      )
      (ok current-cumm-reward-per-stake)
    )
  )
)

(define-read-only (get-rewards-per-block)
  (let (
    (start-rewards u4000000000000) ;; 4M
    (blocks-per-day u145)
    (block-progress (- block-height (var-get contract-start-block)))
    (days-progress (/ block-progress blocks-per-day))
  )
    (if (>= days-progress u400)
      u60000000
      (let (
        (days-rewards (- start-rewards (* days-progress u10000000000)))
        (block-rewards (/ days-rewards blocks-per-day))
      )
        block-rewards
      )
    )
  )
)


;;
;; Initialise
;;

(begin
  (var-set last-reward-increase-block block-height)
)
