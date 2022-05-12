(use-trait sip-010-token .sip-010-v1a.sip-010-trait)
(use-trait liquidity-token .liquidity-token-trait-v4c.liquidity-token-trait)
(use-trait initable-farm .trait-initializable-farm-v1a.initializable-farm-trait)

(define-constant ERR_INVALID_ROUTER (err u4001))
(define-constant ERR_DAO_ACCESS (err u4003))
(define-constant ERR_LP_TOKEN_NOT_VALID (err u4004))
(define-constant ERR_NO_TEMPLATE_FARM (err u4006))
(define-constant ERR_NO_LP_TOKEN (err u4007))
(define-constant ERR_CALLER_MISMATCH (err u4008))
(define-constant ERR_INVALID_CALLER (err u4009))

(define-map farms
  uint
  principal
)

(define-data-var farm-count uint u0)

(define-read-only (get-farm-counts)
  (ok (var-get farm-count))
)

(define-read-only (get-farms (farm-ids (list 100 uint)))
  (ok (map get-farm-by-id farm-ids))
)

(define-read-only (get-farm-by-id (farm-id uint))
  (default-to 
    tx-sender
    (map-get? farms farm-id)
  )
)

(define-data-var template-farm-list (list 200 principal) (list))

(define-map updater principal bool)

(define-read-only (is-updater (user principal))
  (match (map-get? updater user)
    value (ok true)
    ERR_INVALID_CALLER
  )
)

(define-public (add-updater (user principal))
  (begin
    (asserts! (is-eq contract-caller (contract-call? .stackswap-dao-v5k get-dao-owner)) ERR_DAO_ACCESS)
    (ok (map-set updater 
      user true
    ))
  )
)

(map-set updater tx-sender true)

(define-public (remove-updater (user principal))
  (begin
    (asserts! (is-eq contract-caller (contract-call? .stackswap-dao-v5k get-dao-owner)) ERR_DAO_ACCESS)
    (ok (map-delete updater 
      user
    ))
  )
)

(define-data-var rem-item principal tx-sender)

(define-read-only (get-template-farm-list)
  (ok (var-get template-farm-list)))

(define-private (remove-filter (a principal)) (not (is-eq a (var-get rem-item))))

(define-public (remove-template-farm (ritem principal))
  (begin
    (try! (is-updater contract-caller))
    (try! (remove-template-farm-inner ritem))
    (ok true)
  )
)

(define-private (remove-template-farm-inner (ritem principal))
  (begin
    (var-set rem-item ritem)
    (unwrap! (index-of (var-get template-farm-list) ritem)  ERR_NO_TEMPLATE_FARM)
    (var-set template-farm-list (unwrap-panic (as-max-len? (filter remove-filter (var-get template-farm-list)) u200)))
    (ok true)
  )
)

(define-public (add-template-farm (new-farm principal))
  (begin
    (try! (is-updater contract-caller))
    (ok (var-set template-farm-list (unwrap-panic (as-max-len? (append (var-get template-farm-list) new-farm) u200))))))


(define-public (add-template-farms (new-farms (list 100 principal)))
  (begin
    (try! (is-updater contract-caller))
    (ok (var-set template-farm-list (unwrap-panic (as-max-len? (concat (var-get template-farm-list) new-farms) u200))))))


(define-public (initialize-farm (template-farm <initable-farm>)
      (name-to-set (string-ascii 32)) (uri-to-set (string-utf8 256))
      (project_token_in <sip-010-token>) (project_lp_token_in <sip-010-token>) (lp_lock_amount_in uint) 
      (reward_token_1_in <sip-010-token>) (reward_token_2_in <sip-010-token>)
      (reward_token_3_in <sip-010-token>) (reward_token_4_in <sip-010-token>)
      (pj_reward_list (list 4 uint)) (pj_lp_reward_list (list 4 uint)) (nft_reward_list (list 4 uint))
      (first_farming_block_in uint) (reward_round_length_in uint) (max_farming_rounds_in uint)
      (nft_end_block_in uint) (nft_count_limit_in uint) (nft_count_takes_in uint)
  )
  (begin
    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) ERR_INVALID_ROUTER)
    (try! (contract-call? template-farm initialize name-to-set uri-to-set 
      project_token_in project_lp_token_in lp_lock_amount_in
      reward_token_1_in reward_token_2_in reward_token_3_in reward_token_4_in 
      pj_reward_list pj_lp_reward_list nft_reward_list 
      first_farming_block_in reward_round_length_in max_farming_rounds_in 
      nft_end_block_in nft_count_limit_in nft_count_takes_in))
    (try! (remove-template-farm-inner (contract-of template-farm)))
    (var-set farm-count (+ (var-get farm-count) u1))
    (map-set farms
      (var-get farm-count)
      (contract-of template-farm)
    )
    (ok true)
  )
)
