;; SPDX-License-Identifier: BUSL-1.1

(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait) 

(define-constant err-not-authorized (err u1000))
(define-constant err-get-block-info (err u1001))
(define-constant err-invalid-campaign-registration (err u1002))
(define-constant err-invalid-campaign-id (err u1003))
(define-constant err-registration-cutoff-passed (err u1004))
(define-constant err-stake-cutoff-passed (err u1005))
(define-constant err-campaign-not-ended (err u1006))
(define-constant err-token-mismatch (err u1007))
(define-constant err-invalid-input (err u1008))
(define-constant err-invalid-reward-token (err u1010))
(define-constant err-already-claimed (err u1011))
(define-constant err-stake-end-passed (err u1005))
(define-constant err-not-registered (err u1013))
(define-constant err-revoke-disabled (err u1014))
(define-constant err-registration-cutoff-not-passed (err u1015))
(define-constant err-voting-cutoff-passed (err u1016))
(define-constant err-pool-not-registered (err u1017))
(define-constant err-pool-already-registered (err u1018))

(define-constant ONE_8 u100000000)

(define-data-var campaign-nonce uint (contract-call? .farming-campaign-v2-02 get-campaign-nonce))
(define-data-var whitelisted-pools (list 1000 uint) (contract-call? .farming-campaign-v2-02 get-whitelisted-pools))
(define-data-var project-reward-ignore-list (list 1000 principal) (contract-call? .farming-campaign-v2-02 get-project-reward-ignore-list))
(define-data-var revoke-enabled bool false)

(define-map campaigns uint { registration-cutoff: uint, voting-cutoff: uint, stake-cutoff: uint, stake-end: uint, reward-amount: uint, snapshot-block: uint }) ;; Campaign data.
(define-map campaign-registrations { campaign-id: uint, pool-id: uint } { reward-amount-x: uint, reward-amount-y: uint, total-staked: uint }) ;; Registration data of particular pool.
(define-map campaign-stakers { campaign-id: uint, pool-id: uint, staker: principal } { amount: uint, claimed: bool }) ;; Staker data of particular pool.
(define-map campaign-total-vote uint uint) ;; campaign-id -> total-votes
(define-map campaign-registered-pools uint (list 1000 uint)) ;; campaign-id -> pool-ids
(define-map campaign-registrants { campaign-id: uint, pool-id: uint, registrant: principal } { token-x-amount: uint, token-y-amount: uint }) ;; Needed for revoke adding rewards
(define-map campaign-voter-votes { campaign-id: uint, voter: principal } uint) ;; Tracks how much voting power a voter has spent across all pools in a campaign
(define-map campaign-pool-votes-by-voter { campaign-id: uint, pool-id: uint, voter: principal } uint) ;; Tracks votes per pool per voter - used for project reward calculation
(define-map campaign-pool-votes-for-project-reward { campaign-id: uint, pool-id: uint } uint) ;; Tracks total votes per pool for project reward distribution
(define-map campaign-pool-votes-for-alex-reward { campaign-id: uint, pool-id: uint } uint) ;; Tracks total votes per pool for ALEX reward distribution
(define-map campaign-vote-rewards-claimed { campaign-id: uint, pool-id: uint, voter: principal } bool) ;; Add new map for tracking claimed vote rewards

;; read-only functions

;; __IF_MAINNET__				
(define-read-only (block-timestamp)
  (ok (unwrap! (get-stacks-block-info? time (- stacks-block-height u1)) err-get-block-info)))
;; (define-data-var custom-timestamp (optional uint) none)
;; (define-public (set-custom-timestamp (new-timestamp (optional uint)))
;;     (begin
;;         (try! (is-dao-or-extension))
;;         (var-set custom-timestamp new-timestamp)
;;         (ok true)))
;; (define-read-only (block-timestamp)
;;     (match (var-get custom-timestamp)
;;         timestamp (ok timestamp)
;;         (ok (unwrap! (get-stacks-block-info? time (- stacks-block-height u1)) err-get-block-info))))
;; __ENDIF__
(define-read-only (is-dao-or-extension) (ok (asserts! (or (is-eq tx-sender 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao) (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao is-extension contract-caller)) err-not-authorized)))
(define-read-only (get-campaign-nonce) (var-get campaign-nonce))
(define-read-only (get-campaign-or-fail (campaign-id uint)) (ok (unwrap! (map-get? campaigns campaign-id) err-invalid-campaign-id)))
(define-read-only (get-campaigns-or-fail-many (campaign-ids (list 200 uint))) (map get-campaign-or-fail campaign-ids))
(define-read-only (get-campaign-registration-by-id-or-fail (campaign-id uint) (pool-id uint)) (ok (unwrap! (map-get? campaign-registrations { campaign-id: campaign-id, pool-id: pool-id }) err-invalid-campaign-registration)))
(define-read-only (get-campaign-registration-by-id-or-fail-many (campaign-ids (list 200 uint)) (pool-ids (list 200 uint))) (map get-campaign-registration-by-id-or-fail campaign-ids pool-ids))
(define-read-only (get-campaign-staker-or-default (campaign-id uint) (pool-id uint) (staker principal)) (default-to { amount: u0, claimed: false } (map-get? campaign-stakers { campaign-id: campaign-id, pool-id: pool-id, staker: staker })))
(define-read-only (get-campaign-staker-or-default-many (campaign-ids (list 200 uint)) (pool-ids (list 200 uint)) (stakers (list 200 principal))) (map get-campaign-staker-or-default campaign-ids pool-ids stakers))
(define-read-only (get-pool-whitelisted (pool-id uint)) (is-some (index-of (var-get whitelisted-pools) pool-id)))
(define-read-only (get-whitelisted-pools) (var-get whitelisted-pools))

(define-read-only (voting-power (campaign-id uint) (address principal) (lp-pools (list 200 uint)))
  (let ((campaign (unwrap! (map-get? campaigns campaign-id) err-invalid-campaign-id))
        (snapshot-block (get snapshot-block campaign))
        (snapshot-block-id (unwrap-panic (get-stacks-block-info? id-header-hash snapshot-block)))
        (snapshot-data (at-block snapshot-block-id
          (let ((alex-balance (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance-fixed address)))
                (auto-alex-balance (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wlialex get-balance-fixed address)))
                (wrapped-auto-alex-balance 
									(let ((bal-base (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3-wrapped get-shares-to-tokens (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3-wrapped get-balance address))))
											(decimals-base (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3-wrapped get-decimals))))									
										(if (is-eq decimals-base u8) bal-base (/ (* bal-base ONE_8) (pow u10 decimals-base)))))									
                (manual-balance (match (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-staking-v2 get-user-id address)
                  some-value (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-staking-v2 get-staker-at-cycle-or-default (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-staking-v2 get-reward-cycle tenure-height)) some-value)
                  { amount-staked: u0, to-return: u0 }))
								(lp-voting-power (fold calculate-lp-voting-power lp-pools { address: address, total: u0 })))
            { alex: alex-balance, auto-alex: auto-alex-balance, manual-alex: (+ (get amount-staked manual-balance) (get to-return manual-balance)), lp-power: (get total lp-voting-power), wrapped: wrapped-auto-alex-balance })))
        (total-voting-power (+ (get alex snapshot-data) (get auto-alex snapshot-data) (get manual-alex snapshot-data) (get lp-power snapshot-data) (get wrapped snapshot-data)))
        (voted-amount (default-to u0 (map-get? campaign-voter-votes { campaign-id: campaign-id, voter: address }))))
    (ok { voting-power: total-voting-power, voted: voted-amount, snapshot-data: snapshot-data })))

(define-read-only (get-campaign-registered-pools (campaign-id uint)) (ok (default-to (list) (map-get? campaign-registered-pools campaign-id))))

(define-read-only (get-campaign-summary (campaign-id uint))
  (let ((campaign (unwrap! (map-get? campaigns campaign-id) (err err-invalid-campaign-id)))
        (registered-pool-ids (default-to (list) (map-get? campaign-registered-pools campaign-id)))
        (pool-summaries-result (fold get-pool-summary-fold registered-pool-ids { campaign-id: campaign-id, summaries: (list) }))
        (total-votes (default-to u0 (map-get? campaign-total-vote campaign-id))))
    (ok (merge campaign { pool-summaries: (get summaries pool-summaries-result), total-votes: total-votes }))))

(define-read-only (get-campaign-staker-history-many (address principal) (campaign-ids (list 200 uint)))
  (get history (fold get-campaign-staker-history campaign-ids { address: address, history: (list) })))

(define-read-only (get-registration-or-default (campaign-id uint) (pool-id uint) (registrant principal))
  (default-to { token-x-amount: u0, token-y-amount: u0 } (map-get? campaign-registrants { campaign-id: campaign-id, pool-id: pool-id, registrant: registrant })))

(define-read-only (get-registration-or-default-many (campaign-id uint) (pool-ids (list 1000 uint)) (registrant principal))
  (fold get-registration-fold pool-ids { campaign-id: campaign-id, registrant: registrant, registrations: (list) }))

(define-read-only (get-revoke-enabled) (var-get revoke-enabled))

(define-read-only (get-project-reward-ignore-list) (var-get project-reward-ignore-list))

;; public functions

(define-public (stake (pool-id uint) (campaign-id uint) (amount uint))
  (let ((current-timestamp (try! (block-timestamp)))
        (campaign-details (try! (get-campaign-or-fail campaign-id)))
        (campaign-registration-details (try! (get-campaign-registration-by-id-or-fail campaign-id pool-id)))
        (staker-info (get-campaign-staker-or-default campaign-id pool-id tx-sender))
        (updated-staker-stake (+ (get amount staker-info) amount))
        (updated-total-stake (+ (get total-staked campaign-registration-details) amount)))
    (asserts! (> current-timestamp (get registration-cutoff campaign-details)) err-registration-cutoff-not-passed)
    (asserts! (< current-timestamp (get stake-cutoff campaign-details)) err-stake-cutoff-passed)
    (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 transfer-fixed pool-id amount tx-sender (as-contract tx-sender)))
    (map-set campaign-registrations { campaign-id: campaign-id, pool-id: pool-id } (merge campaign-registration-details { total-staked: updated-total-stake }))
    (map-set campaign-stakers { campaign-id: campaign-id, pool-id: pool-id, staker: tx-sender } { amount: updated-staker-stake, claimed: false })
    (print { notification: "stake", payload: { sender: tx-sender, campaign-id: campaign-id, pool-id: pool-id, total-stake: updated-total-stake, staker-stake: updated-staker-stake, amount: amount }})
    (ok true)))

(define-public (unstake (pool-id uint) (campaign-id uint))
    (let (
        (sender tx-sender)
        (current-timestamp (try! (block-timestamp)))
        (campaign-details (try! (get-campaign-or-fail campaign-id)))
        (campaign-registration-details (try! (get-campaign-registration-by-id-or-fail campaign-id pool-id)))
        (staker-info (get-campaign-staker-or-default campaign-id pool-id sender))
        (staker-stake (get amount staker-info))
        (pool-votes (default-to u0 (map-get? campaign-pool-votes-for-alex-reward { campaign-id: campaign-id, pool-id: pool-id })))
        (total-votes (default-to u0 (map-get? campaign-total-vote campaign-id)))
        (total-alex-reward-for-pool (if (is-eq total-votes u0) u0 (div-down (mul-down (get reward-amount campaign-details) pool-votes) total-votes)))
        (alex-reward (mul-down (div-down staker-stake (get total-staked campaign-registration-details)) total-alex-reward-for-pool)))
      (asserts! (< (get stake-end campaign-details) current-timestamp) err-campaign-not-ended)
      (asserts! (not (get claimed staker-info)) err-already-claimed)        
      (and (> alex-reward u0) (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex mint-fixed alex-reward sender)))  
      (map-set campaign-stakers { campaign-id: campaign-id, pool-id: pool-id, staker: sender } { amount: staker-stake, claimed: true })
      (as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 transfer-fixed pool-id staker-stake tx-sender sender)))
			(print { notification: "unstake", payload: { sender: tx-sender, campaign-id: campaign-id, pool-id: pool-id, alex-reward: alex-reward, staker-stake: staker-stake }})
      (ok true)))

(define-public (register-for-campaign (pool-id uint) (campaign-id uint))
  (let ((current-timestamp (try! (block-timestamp)))
        (campaign-details (try! (get-campaign-or-fail campaign-id)))
        (registered-pools (default-to (list) (map-get? campaign-registered-pools campaign-id)))
        (existing-registration (map-get? campaign-registrations { campaign-id: campaign-id, pool-id: pool-id })))
    (asserts! (get-pool-whitelisted pool-id) err-not-authorized)
    (asserts! (< current-timestamp (get registration-cutoff campaign-details)) err-registration-cutoff-passed)
    (asserts! (is-none existing-registration) err-pool-already-registered)
    (map-set campaign-registrations { campaign-id: campaign-id, pool-id: pool-id } { reward-amount-x: u0, reward-amount-y: u0, total-staked: u0 })
    (and (is-none (index-of registered-pools pool-id)) (map-set campaign-registered-pools campaign-id (unwrap! (as-max-len? (append registered-pools pool-id) u1000) err-invalid-input)))
    (print { notification: "register-for-campaign", payload: { sender: tx-sender, campaign-id: campaign-id, pool-id: pool-id }})
    (ok true)))

(define-public (add-reward-for-campaign (pool-id uint) (campaign-id uint) (reward-token-trait <ft-trait>) (reward-amount uint))
  (let ((reward-token (contract-of reward-token-trait))
        (current-timestamp (try! (block-timestamp)))
        (campaign-details (try! (get-campaign-or-fail campaign-id)))
        (current-registration (get-registration-or-default campaign-id pool-id tx-sender))
        (pool-details (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details-by-id pool-id)))
        (is-token-x (is-eq reward-token (get token-x pool-details)))
        (is-token-y (is-eq reward-token (get token-y pool-details))))
    (asserts! (is-ok (get-campaign-registration-by-id-or-fail campaign-id pool-id)) err-pool-not-registered)
    (asserts! (< current-timestamp (get voting-cutoff campaign-details)) err-voting-cutoff-passed)
    (asserts! (or is-token-x is-token-y) err-invalid-reward-token)
    (and (> reward-amount u0) (try! (contract-call? reward-token-trait transfer-fixed reward-amount tx-sender (as-contract tx-sender) none)))
    (let ((registration (unwrap! (get-campaign-registration-by-id-or-fail campaign-id pool-id) err-pool-not-registered)))
      (map-set campaign-registrations { campaign-id: campaign-id, pool-id: pool-id } (merge registration { reward-amount-x: (if is-token-x (+ (get reward-amount-x registration) reward-amount) (get reward-amount-x registration)), reward-amount-y: (if is-token-y (+ (get reward-amount-y registration) reward-amount) (get reward-amount-y registration)) })))
    (map-set campaign-registrants { campaign-id: campaign-id, pool-id: pool-id, registrant: tx-sender } { token-x-amount: (if is-token-x (+ (get token-x-amount current-registration) reward-amount) (get token-x-amount current-registration)), token-y-amount: (if is-token-y (+ (get token-y-amount current-registration) reward-amount) (get token-y-amount current-registration)) })
    (print { notification: "add-reward-for-campaign", payload: { sender: tx-sender, campaign-id: campaign-id, pool-id: pool-id, reward-token: reward-token, reward-amount-added: reward-amount }})
    (ok true)))

(define-public (vote-campaign (campaign-id uint) (votes (list 1000 { pool-id: uint, votes: uint })) (lp-pools (list 200 uint)))
  (let ((campaign (unwrap! (map-get? campaigns campaign-id) err-invalid-campaign-id))
        (current-timestamp (unwrap! (block-timestamp) err-get-block-info))
        (voter-power (unwrap! (voting-power campaign-id tx-sender lp-pools) err-invalid-input))
        (total-new-votes (fold + (map get-votes votes) u0))
        (previous-votes (default-to u0 (map-get? campaign-voter-votes { campaign-id: campaign-id, voter: tx-sender })))
        (total-votes-after (+ previous-votes total-new-votes)))
    (asserts! (> current-timestamp (get registration-cutoff campaign)) err-registration-cutoff-not-passed)
    (asserts! (< current-timestamp (get voting-cutoff campaign)) err-voting-cutoff-passed)
    (asserts! (<= total-votes-after (get voting-power voter-power)) err-invalid-input)
    (fold update-pool-votes votes { campaign-id: campaign-id, voter: tx-sender })
    (map-set campaign-voter-votes { campaign-id: campaign-id, voter: tx-sender } total-votes-after)
    (map-set campaign-total-vote campaign-id (+ (default-to u0 (map-get? campaign-total-vote campaign-id)) total-new-votes))
    (print { notification: "vote-campaign", payload: { campaign-id: campaign-id, voter: tx-sender, votes: votes, total-new-votes: total-new-votes, total-votes-after: total-votes-after }})
    (ok true)))

(define-public (claim-vote-reward (pool-id uint) (campaign-id uint) (reward-token-x-trait <ft-trait>) (reward-token-y-trait <ft-trait>))
  (let ((sender tx-sender)
        (current-timestamp (try! (block-timestamp)))
        (campaign-details (try! (get-campaign-or-fail campaign-id)))
        (campaign-registration-details (try! (get-campaign-registration-by-id-or-fail campaign-id pool-id)))
        (pool-details (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details-by-id pool-id)))
        (voter-pool-votes (default-to u0 (map-get? campaign-pool-votes-by-voter { campaign-id: campaign-id, pool-id: pool-id, voter: sender })))
        (pool-total-votes (default-to u0 (map-get? campaign-pool-votes-for-project-reward { campaign-id: campaign-id, pool-id: pool-id })))
        (already-claimed (default-to false (map-get? campaign-vote-rewards-claimed { campaign-id: campaign-id, pool-id: pool-id, voter: sender })))
        (is-ignored (is-some (index-of (var-get project-reward-ignore-list) sender)))
				(reward-x (div-down (mul-down (get reward-amount-x campaign-registration-details) voter-pool-votes) pool-total-votes))
				(reward-y (div-down (mul-down (get reward-amount-y campaign-registration-details) voter-pool-votes) pool-total-votes)))
    (asserts! (> current-timestamp (get voting-cutoff campaign-details)) err-campaign-not-ended)
    (asserts! (not already-claimed) err-already-claimed)
    (asserts! (is-eq (contract-of reward-token-x-trait) (get token-x pool-details)) err-token-mismatch)
    (asserts! (is-eq (contract-of reward-token-y-trait) (get token-y pool-details)) err-token-mismatch)
    (asserts! (and (> voter-pool-votes u0) (not is-ignored)) err-invalid-input)
    (and (> reward-x u0) (as-contract (try! (contract-call? reward-token-x-trait transfer-fixed reward-x tx-sender sender none))))
    (and (> reward-y u0) (as-contract (try! (contract-call? reward-token-y-trait transfer-fixed reward-y tx-sender sender none))))
    (map-set campaign-vote-rewards-claimed { campaign-id: campaign-id, pool-id: pool-id, voter: sender } true)
    (print { notification: "claim-vote-reward", payload: { sender: tx-sender, campaign-id: campaign-id, pool-id: pool-id, voter-pool-votes: voter-pool-votes, pool-total-votes: pool-total-votes, reward-x: reward-x, reward-y: reward-y }})
    (ok { reward-x: reward-x, reward-y: reward-y })))

(define-public (claim-vote-reward-many (pool-ids (list 100 uint)) (campaign-ids (list 100 uint)) (reward-token-x-traits (list 100 <ft-trait>)) (reward-token-y-traits (list 100 <ft-trait>)))
  (ok (map claim-vote-reward pool-ids campaign-ids reward-token-x-traits reward-token-y-traits)))

;; privileged functions

(define-public (revoke-registration (pool-id uint) (campaign-id uint) (registrant principal) (reward-token-x-trait <ft-trait>) (reward-token-y-trait <ft-trait>))
  (let ((current-timestamp (try! (block-timestamp)))
        (campaign-details (try! (get-campaign-or-fail campaign-id)))
        (current-registration (get-registration-or-default campaign-id pool-id registrant))
        (campaign-registration (try! (get-campaign-registration-by-id-or-fail campaign-id pool-id)))
        (pool-details (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details-by-id pool-id)))
        (token-x-amount (get token-x-amount current-registration))
        (token-y-amount (get token-y-amount current-registration)))    
    (asserts! (or (and (get-revoke-enabled) (is-eq tx-sender registrant)) (is-ok (is-dao-or-extension))) err-not-authorized)
    (asserts! (or (> token-x-amount u0) (> token-y-amount u0)) err-not-registered)
    (asserts! (< current-timestamp (get registration-cutoff campaign-details)) err-registration-cutoff-passed)
    (asserts! (is-eq (contract-of reward-token-x-trait) (get token-x pool-details)) err-token-mismatch)
    (asserts! (is-eq (contract-of reward-token-y-trait) (get token-y pool-details)) err-token-mismatch)
    (map-set campaign-registrations { campaign-id: campaign-id, pool-id: pool-id } (merge campaign-registration { reward-amount-x: (- (get reward-amount-x campaign-registration) token-x-amount), reward-amount-y: (- (get reward-amount-y campaign-registration) token-y-amount) }))
    (map-set campaign-registrants { campaign-id: campaign-id, pool-id: pool-id, registrant: registrant } { token-x-amount: u0, token-y-amount: u0 })
    (and (> token-x-amount u0) (as-contract (try! (contract-call? reward-token-x-trait transfer-fixed token-x-amount tx-sender registrant none))))
    (and (> token-y-amount u0) (as-contract (try! (contract-call? reward-token-y-trait transfer-fixed token-y-amount tx-sender registrant none))))
    (print { notification: "revoke-registration", payload: { campaign-id: campaign-id, pool-id: pool-id, registrant: registrant, token-x-amount-refunded: token-x-amount, token-y-amount-refunded: token-y-amount }})
    (ok true)))

;; governance functions

(define-public (set-campaign-nonce (new-nonce uint))
  (begin (try! (is-dao-or-extension)) (var-set campaign-nonce new-nonce) (ok true)))

(define-public (set-revoke-enabled (enabled bool))
  (begin (try! (is-dao-or-extension)) (ok (var-set revoke-enabled enabled))))

(define-public (whitelist-pools (pools (list 1000 uint)))
  (begin (try! (is-dao-or-extension)) (var-set whitelisted-pools pools) (ok true)))

(define-public (create-campaign (registration-cutoff uint) (voting-cutoff uint) (stake-cutoff uint) (stake-end uint) (reward-amount uint) (snapshot-block uint))
  (let ((campaign-id (+ (var-get campaign-nonce) u1)))
    (try! (is-dao-or-extension))
    (asserts! (< registration-cutoff voting-cutoff) err-invalid-input)
    (asserts! (<= voting-cutoff stake-cutoff) err-invalid-input)
    (asserts! (< stake-cutoff stake-end) err-invalid-input)
    (map-set campaigns campaign-id { registration-cutoff: registration-cutoff, voting-cutoff: voting-cutoff, stake-cutoff: stake-cutoff, stake-end: stake-end, reward-amount: reward-amount, snapshot-block: snapshot-block })
    (print { notification: "create-campaign", payload: { campaign-id: campaign-id, registration-cutoff: registration-cutoff, voting-cutoff: voting-cutoff, stake-cutoff: stake-cutoff, stake-end: stake-end, reward-amount: reward-amount, snapshot-block: snapshot-block }})
    (var-set campaign-nonce campaign-id)
    (ok campaign-id)))

(define-public (transfer-token (token-trait <ft-trait>) (amount uint) (recipient principal))
  (begin (try! (is-dao-or-extension)) (as-contract (contract-call? token-trait transfer-fixed amount tx-sender recipient none))))

(define-public (update-campaign (campaign-id uint) (details { registration-cutoff: uint, voting-cutoff: uint, stake-cutoff: uint, stake-end: uint, reward-amount: uint, snapshot-block: uint }))
  (let ((campaign-details (try! (get-campaign-or-fail campaign-id))))
    (try! (is-dao-or-extension))
    (asserts! (< (get registration-cutoff details) (get voting-cutoff details)) err-invalid-input)
    (asserts! (<= (get voting-cutoff details) (get stake-cutoff details)) err-invalid-input)
    (asserts! (< (get stake-cutoff details) (get stake-end details)) err-invalid-input)      
    (map-set campaigns campaign-id details)
    (print { notification: "update-campaign", payload: { campaign-id: campaign-id, details: details }})
    (ok true)))

(define-public (update-campaign-registrations (campaign-id uint) (pool-id uint) (reward-amount-x uint) (reward-amount-y uint) (total-staked uint))
  (let ((registered-pools (default-to (list) (map-get? campaign-registered-pools campaign-id))))
    (try! (is-dao-or-extension))
    (map-set campaign-registrations { campaign-id: campaign-id, pool-id: pool-id } { reward-amount-x: reward-amount-x, reward-amount-y: reward-amount-y, total-staked: total-staked })
    (and (is-none (index-of registered-pools pool-id)) (map-set campaign-registered-pools campaign-id (unwrap! (as-max-len? (append registered-pools pool-id) u1000) err-invalid-input)))
    (print { notification: "update-campaign-registrations", payload: { campaign-id: campaign-id, pool-id: pool-id, reward-amount-x: reward-amount-x, reward-amount-y: reward-amount-y, total-staked: total-staked }})
    (ok true)))

(define-public (update-campaign-stakers (campaign-id uint) (pool-id uint) (staker principal) (amount uint) (claimed bool))
  (begin
    (try! (is-dao-or-extension))
    (map-set campaign-stakers { campaign-id: campaign-id, pool-id: pool-id, staker: staker } { amount: amount, claimed: claimed })
    (print { notification: "update-campaign-stakers", payload: { campaign-id: campaign-id, pool-id: pool-id, staker: staker, amount: amount, claimed: claimed }})
    (ok true)))

(define-public (update-campaign-registrants (campaign-id uint) (pool-id uint) (registrant principal) (token-x-amount uint) (token-y-amount uint))
  (begin
    (try! (is-dao-or-extension))
    (map-set campaign-registrants { campaign-id: campaign-id, pool-id: pool-id, registrant: registrant } { token-x-amount: token-x-amount, token-y-amount: token-y-amount })
    (print { notification: "update-campaign-registrants", payload: { campaign-id: campaign-id, pool-id: pool-id, registrant: registrant, token-x-amount: token-x-amount, token-y-amount: token-y-amount }})
    (ok true)))

(define-public (set-project-reward-ignore-list (addresses (list 1000 principal)))
  (begin (try! (is-dao-or-extension)) (ok (var-set project-reward-ignore-list addresses))))

;; private functions

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value)))

(define-private (mul-down (a uint) (b uint)) (/ (* a b) ONE_8))

(define-private (div-down (a uint) (b uint)) (if (is-eq a u0) u0 (/ (* a ONE_8) b)))

(define-private (min (a uint) (b uint)) (if (<= a b) a b))

(define-private (max (a uint) (b uint)) (if (>= a b) a b))

(define-private (get-votes (entry { pool-id: uint, votes: uint })) (get votes entry))

(define-private (update-pool-votes (vote { pool-id: uint, votes: uint }) (context { campaign-id: uint, voter: principal }))
  (let ((campaign-id (get campaign-id context))
        (voter (get voter context))
        (pool-id (get pool-id vote))
        (vote-amount (get votes vote))
        (current-pool-votes-project (default-to u0 (map-get? campaign-pool-votes-for-project-reward { campaign-id: campaign-id, pool-id: pool-id })))
        (current-pool-votes-alex (default-to u0 (map-get? campaign-pool-votes-for-alex-reward { campaign-id: campaign-id, pool-id: pool-id })))
        (current-voter-pool-votes (default-to u0 (map-get? campaign-pool-votes-by-voter { campaign-id: campaign-id, pool-id: pool-id, voter: voter })))
        (is-ignored (is-some (index-of (var-get project-reward-ignore-list) voter))))
    (and (not is-ignored) (map-set campaign-pool-votes-for-project-reward { campaign-id: campaign-id, pool-id: pool-id } (+ current-pool-votes-project vote-amount)))
    (map-set campaign-pool-votes-for-alex-reward { campaign-id: campaign-id, pool-id: pool-id } (+ current-pool-votes-alex vote-amount))
    (map-set campaign-pool-votes-by-voter { campaign-id: campaign-id, pool-id: pool-id, voter: voter } (+ current-voter-pool-votes vote-amount))
    context))

(define-private (calculate-lp-voting-power (pool-id uint) (acc { address: principal, total: uint }))
  (let ((pool-tokens (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details-by-id pool-id)))
        (pool-details (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details (get token-x pool-tokens) (get token-y pool-tokens) (get factor pool-tokens))))
        (total-supply (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 get-total-supply pool-id)))
        (user-farm-details (match (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming get-user-id 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 pool-id (get address acc))
          some-value (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming get-staker-at-cycle-or-default 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 pool-id (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming get-reward-cycle 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 pool-id tenure-height)) some-value)
          { amount-staked: u0, to-return: u0 }))
        (user-lp-balance (+ (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 get-balance pool-id (get address acc))) (get amount-staked user-farm-details) (get to-return user-farm-details)))
        (alex-from-x (if (or (is-eq (get token-x pool-tokens) 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex) (is-eq (get token-x pool-tokens) 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3)) (/ (* user-lp-balance (get balance-x pool-details)) total-supply) u0))
        (alex-from-y (if (or (is-eq (get token-y pool-tokens) 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex) (is-eq (get token-y pool-tokens) 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3)) (/ (* user-lp-balance (get balance-y pool-details)) total-supply) u0)))
    (merge acc { total: (+ (get total acc) alex-from-x alex-from-y) })))

(define-private (get-pool-summary-fold (pool-id uint) (acc { campaign-id: uint, summaries: (list 1000 { pool-id: uint, votes: uint, project-reward-votes: uint, reward-amount-x: uint, reward-amount-y: uint, total-staked: uint })}))
  (let ((campaign-id (get campaign-id acc))
        (registration (unwrap-panic (map-get? campaign-registrations { campaign-id: campaign-id, pool-id: pool-id })))
        (votes (default-to u0 (map-get? campaign-pool-votes-for-alex-reward { campaign-id: campaign-id, pool-id: pool-id })))
        (project-reward-votes (default-to u0 (map-get? campaign-pool-votes-for-project-reward { campaign-id: campaign-id, pool-id: pool-id })))
        (summary { pool-id: pool-id, votes: votes, project-reward-votes: project-reward-votes, reward-amount-x: (get reward-amount-x registration), reward-amount-y: (get reward-amount-y registration), total-staked: (get total-staked registration) }))
    (merge acc { summaries: (unwrap-panic (as-max-len? (append (get summaries acc) summary) u1000)) })))

(define-private (get-campaign-staker-history (campaign-id uint) (acc { address: principal, history: (list 1000 { campaign-id: uint, pool-id: uint, staker-info: { amount: uint, claimed: bool } }) }))
  (let ((address (get address acc))
        (registered-pools (default-to (list) (map-get? campaign-registered-pools campaign-id)))
        (campaign-history (fold get-pool-staker-history registered-pools { campaign-id: campaign-id, address: address, history: (list) })))
    (merge acc { history: (unwrap-panic (as-max-len? (concat (get history acc) (get history campaign-history)) u1000)) })))

(define-private (get-pool-staker-history (pool-id uint) (acc { campaign-id: uint, address: principal, history: (list 1000 { campaign-id: uint, pool-id: uint, staker-info: { amount: uint, claimed: bool } }) }))
  (let ((campaign-id (get campaign-id acc))
        (address (get address acc))
        (staker-info (get-campaign-staker-or-default campaign-id pool-id address))
        (staker-record { campaign-id: campaign-id, pool-id: pool-id, staker-info: staker-info })
        (updated-history (if (> (get amount (get staker-info staker-record)) u0) (unwrap-panic (as-max-len? (append (get history acc) staker-record) u1000)) (get history acc))))
    (merge acc { history: updated-history })))

(define-private (get-registration-fold (pool-id uint) (acc { campaign-id: uint, registrant: principal, registrations: (list 1000 { pool-id: uint, token-x-amount: uint, token-y-amount: uint }) }))
  (let ((campaign-id (get campaign-id acc))
        (registrant (get registrant acc))
        (registration-info (get-registration-or-default campaign-id pool-id registrant))
        (registration { pool-id: pool-id, token-x-amount: (get token-x-amount registration-info), token-y-amount: (get token-y-amount registration-info) }))
    (merge acc { registrations: (unwrap-panic (as-max-len? (append (get registrations acc) registration) u1000)) })))
