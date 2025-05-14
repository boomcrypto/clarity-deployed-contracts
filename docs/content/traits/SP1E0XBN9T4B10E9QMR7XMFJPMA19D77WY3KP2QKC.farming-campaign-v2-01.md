---
title: "Trait farming-campaign-v2-01"
draft: true
---
```
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

(define-constant ONE_8 u100000000)

(define-data-var campaign-nonce uint u0)
(define-data-var revoke-enabled bool false)

(define-map campaigns uint { registration-cutoff: uint, voting-cutoff: uint, stake-cutoff: uint, stake-end: uint, reward-amount: uint, snapshot-block: uint })
(define-map campaign-registrations { campaign-id: uint, pool-id: uint } { reward-token: principal, reward-amount: uint, total-staked: uint })
(define-map campaign-stakers { campaign-id: uint, pool-id: uint, staker: principal } { amount: uint, claimed: bool })
(define-data-var whitelisted-pools (list 1000 uint) (list))

(define-map campaign-voted { campaign-id: uint, voter: principal } bool)
(define-map campaign-pool-votes { campaign-id: uint, pool-id: uint } uint)
(define-map campaign-total-vote uint uint)
(define-map campaign-registered-pools uint (list 1000 uint))

(define-map campaign-registrants
  { campaign-id: uint, pool-id: uint, registrant: principal } 
  uint)

;; read-only calls

(define-read-only (is-dao-or-extension)
    (ok (asserts! (or (is-eq tx-sender 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao) (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao is-extension contract-caller)) err-not-authorized)))


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

(define-read-only (get-campaign-nonce)
  (var-get campaign-nonce))

(define-read-only (get-campaign-or-fail (campaign-id uint))
	(ok (unwrap! (map-get? campaigns campaign-id) err-invalid-campaign-id)))

(define-read-only (get-campaigns-or-fail-many (campaign-ids (list 200 uint)))
	(map get-campaign-or-fail campaign-ids))

(define-read-only (get-campaign-registration-by-id-or-fail (campaign-id uint) (pool-id uint))
	(ok (unwrap! (map-get? campaign-registrations { campaign-id: campaign-id, pool-id: pool-id }) err-invalid-campaign-registration)))

(define-read-only (get-campaign-registration-by-id-or-fail-many (campaign-ids (list 200 uint)) (pool-ids (list 200 uint)))
	(map get-campaign-registration-by-id-or-fail campaign-ids pool-ids))

(define-read-only (get-campaign-staker-or-default (campaign-id uint) (pool-id uint) (staker principal))
    (default-to { amount: u0, claimed: false } (map-get? campaign-stakers { campaign-id: campaign-id, pool-id: pool-id, staker: staker })))

(define-read-only (get-campaign-staker-or-default-many (campaign-ids (list 200 uint)) (pool-ids (list 200 uint)) (stakers (list 200 principal)))
    (map get-campaign-staker-or-default campaign-ids pool-ids stakers))

(define-read-only (get-pool-whitelisted (pool-id uint))
    (is-some (index-of (var-get whitelisted-pools) pool-id)))

(define-read-only (get-whitelisted-pools)
  (var-get whitelisted-pools))

;; New read-only function for voting power
(define-read-only (voting-power (campaign-id uint) (address principal))
  (let (
    (campaign (unwrap! (map-get? campaigns campaign-id) err-invalid-campaign-id))
    (snapshot-block (get snapshot-block campaign))
    (alex-balance (unwrap-panic (at-block (unwrap-panic (get-stacks-block-info? id-header-hash snapshot-block))
      (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance address))))
    (auto-alex-balance (unwrap-panic (at-block (unwrap-panic (get-stacks-block-info? id-header-hash snapshot-block))
      (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3 get-balance address))))
    (total-voting-power (+ alex-balance auto-alex-balance))
    (voted (default-to false (map-get? campaign-voted { campaign-id: campaign-id, voter: address }))))
    (ok { voting-power: total-voting-power, voted: voted })))

(define-read-only (get-campaign-registered-pools (campaign-id uint))
	(ok (default-to (list) (map-get? campaign-registered-pools campaign-id))))

;; New read-only function to get campaign summary
(define-read-only (get-campaign-summary (campaign-id uint))
  (let (
    (campaign (unwrap! (map-get? campaigns campaign-id) (err err-invalid-campaign-id)))
    (registered-pool-ids (default-to (list) (map-get? campaign-registered-pools campaign-id)))
    (pool-summaries-result (fold get-pool-summary-fold registered-pool-ids { campaign-id: campaign-id, summaries: (list) }))
    (total-votes (default-to u0 (map-get? campaign-total-vote campaign-id))))
    (ok (merge campaign {
      pool-summaries: (get summaries pool-summaries-result),
      total-votes: total-votes,
    }))))

;; Helper function to get summary for a single pool
(define-private (get-pool-summary-fold (pool-id uint) (acc { campaign-id: uint, summaries: (list 1000 {
    pool-id: uint,
    votes: uint,
    reward-token: principal,
    reward-token-amount: uint,
    total-staked: uint
  })}))
  (let (
    (campaign-id (get campaign-id acc))
    (registration (unwrap-panic (map-get? campaign-registrations { campaign-id: campaign-id, pool-id: pool-id })))
    (votes (default-to u0 (map-get? campaign-pool-votes { campaign-id: campaign-id, pool-id: pool-id })))
    (summary {
      pool-id: pool-id,
      votes: votes,
      reward-token: (get reward-token registration),
      reward-token-amount: (get reward-amount registration),
      total-staked: (get total-staked registration)
    }))
    (merge acc { summaries: (unwrap-panic (as-max-len? (append (get summaries acc) summary) u1000)) })))

;; New read-only function to get staker history across multiple campaigns
(define-read-only (get-campaign-staker-history-many (address principal) (campaign-ids (list 200 uint)))
  (get history (fold get-campaign-staker-history campaign-ids { address: address, history: (list) })))

;; Helper function to get staker history for a single campaign
(define-private (get-campaign-staker-history (campaign-id uint) (acc { address: principal, history: (list 1000 { campaign-id: uint, pool-id: uint, staker-info: { amount: uint, claimed: bool } }) }))
  (let (
    (address (get address acc))
    (registered-pools (default-to (list) (map-get? campaign-registered-pools campaign-id)))
    (campaign-history (fold get-pool-staker-history registered-pools { campaign-id: campaign-id, address: address, history: (list) })))
    (merge acc { history: (unwrap-panic (as-max-len? (concat (get history acc) (get history campaign-history)) u1000)) })))

;; Helper function to get staker history for a single pool in a campaign
(define-private (get-pool-staker-history (pool-id uint) (acc { campaign-id: uint, address: principal, history: (list 1000 { campaign-id: uint, pool-id: uint, staker-info: { amount: uint, claimed: bool } }) }))
  (let (
    (campaign-id (get campaign-id acc))
    (address (get address acc))
    (staker-info (get-campaign-staker-or-default campaign-id pool-id address))
    (staker-record { campaign-id: campaign-id, pool-id: pool-id, staker-info: staker-info })
    (updated-history (if (> (get amount (get staker-info staker-record)) u0)
      (unwrap-panic (as-max-len? (append (get history acc) staker-record) u1000))
      (get history acc))))
    (merge acc { history: updated-history })))

(define-read-only (get-registration-or-default (campaign-id uint) (pool-id uint) (registrant principal))
  (default-to u0
    (map-get? campaign-registrants { campaign-id: campaign-id, pool-id: pool-id, registrant: registrant })))

;; Read-only function to get registration amounts for multiple pools in a campaign
(define-read-only (get-registration-or-default-many (campaign-id uint) (pool-ids (list 1000 uint)) (registrant principal))
  (fold get-registration-fold pool-ids { 
    campaign-id: campaign-id,
    registrant: registrant,
    registrations: (list)
  }))

;; Helper function to get registration for a single pool
(define-private (get-registration-fold (pool-id uint) (acc { campaign-id: uint, registrant: principal, registrations: (list 1000 { pool-id: uint, amount: uint }) }))
  (let (
    (campaign-id (get campaign-id acc))
    (registrant (get registrant acc))
    (amount (get-registration-or-default campaign-id pool-id registrant))
    (registration { pool-id: pool-id, amount: amount }))
    (merge acc { registrations: (unwrap-panic (as-max-len? (append (get registrations acc) registration) u1000)) })))

(define-read-only (get-revoke-enabled)
  (var-get revoke-enabled))

;; public calls

(define-public (stake (pool-id uint) (campaign-id uint) (amount uint))
    (let (
			(current-timestamp (try! (block-timestamp)))
			(campaign-details (try! (get-campaign-or-fail campaign-id)))
			(campaign-registration-details (try! (get-campaign-registration-by-id-or-fail campaign-id pool-id)))
			(staker-info (get-campaign-staker-or-default campaign-id pool-id tx-sender))
			(updated-staker-stake (+ (get amount staker-info) amount))
			(updated-total-stake (+ (get total-staked campaign-registration-details) amount)))
		(asserts! (< current-timestamp (get stake-cutoff campaign-details)) err-stake-cutoff-passed)

		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 transfer-fixed pool-id amount tx-sender (as-contract tx-sender)))
		(map-set campaign-registrations { campaign-id: campaign-id, pool-id: pool-id } (merge campaign-registration-details { total-staked: updated-total-stake }))
		(map-set campaign-stakers { campaign-id: campaign-id, pool-id: pool-id, staker: tx-sender } { amount: updated-staker-stake, claimed: false })

		(print { notification: "stake", payload: { sender: tx-sender, campaign-id: campaign-id, pool-id: pool-id, total-stake: updated-total-stake, staker-stake: updated-staker-stake, amount: amount }})
		(ok true)))

(define-public (unstake (pool-id uint) (campaign-id uint) (reward-token-trait <ft-trait>))
   (let (
			(sender tx-sender)
			(current-timestamp (try! (block-timestamp)))
			(campaign-details (try! (get-campaign-or-fail campaign-id)))
			(campaign-registration-details (try! (get-campaign-registration-by-id-or-fail campaign-id pool-id)))
			(staker-info (get-campaign-staker-or-default campaign-id pool-id sender))
			(staker-stake (get amount staker-info))
			(reward (div-down (mul-down (get reward-amount campaign-registration-details) staker-stake) (get total-staked campaign-registration-details)))
			(pool-votes (default-to u0 (map-get? campaign-pool-votes { campaign-id: campaign-id, pool-id: pool-id })))
			(total-votes (default-to u0 (map-get? campaign-total-vote campaign-id)))
			(total-alex-reward-for-pool (if (is-eq total-votes u0)
					u0
					(div-down (mul-down (get reward-amount campaign-details) pool-votes) total-votes)))
			(alex-reward (div-down (mul-down total-alex-reward-for-pool staker-stake) (get total-staked campaign-registration-details))))
		(asserts! (< (get stake-end campaign-details) current-timestamp) err-campaign-not-ended)
		(asserts! (is-eq (contract-of reward-token-trait) (get reward-token campaign-registration-details)) err-token-mismatch)
		(asserts! (not (get claimed staker-info)) err-already-claimed)

		(and (> reward u0) (as-contract (try! (contract-call? reward-token-trait transfer-fixed reward tx-sender sender none))))
		(and (> alex-reward u0) (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex mint-fixed alex-reward sender)))
		(map-set campaign-stakers { campaign-id: campaign-id, pool-id: pool-id, staker: sender } { amount: u0, claimed: true })
		(as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 transfer-fixed pool-id staker-stake tx-sender sender)))

		(print { notification: "unstake", payload: { sender: tx-sender, campaign-id: campaign-id, pool-id: pool-id, reward: reward, alex-reward: alex-reward, staker-stake: staker-stake }})
		(ok true)))

(define-public (register-for-campaign (pool-id uint) (campaign-id uint) (reward-token-trait <ft-trait>) (reward-amount uint))
	(let (
			(reward-token (contract-of reward-token-trait))
			(current-timestamp (try! (block-timestamp)))
			(campaign-details (try! (get-campaign-or-fail campaign-id)))
			(registered-pools (default-to (list) (map-get? campaign-registered-pools campaign-id)))
      (current-amount (get-registration-or-default campaign-id pool-id tx-sender)))
		(asserts! (get-pool-whitelisted pool-id) err-not-authorized)
		(asserts! (< current-timestamp (get registration-cutoff campaign-details)) err-registration-cutoff-passed)
		(asserts! (is-eq reward-token (get token-y (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details-by-id pool-id)))) err-invalid-reward-token)
		(and (> reward-amount u0) (try! (contract-call? reward-token-trait transfer-fixed reward-amount tx-sender (as-contract tx-sender) none)))
		(match (get-campaign-registration-by-id-or-fail campaign-id pool-id)
			ok-value (map-set campaign-registrations { campaign-id: campaign-id, pool-id: pool-id } (merge ok-value { reward-amount: (+ (get reward-amount ok-value) reward-amount) }))
			err-value (map-set campaign-registrations { campaign-id: campaign-id, pool-id: pool-id } { reward-token: reward-token, reward-amount: reward-amount, total-staked: u0 }))
		(and (is-none (index-of registered-pools pool-id)) 
			(map-set campaign-registered-pools campaign-id (unwrap! (as-max-len? (append registered-pools pool-id) u1000) err-invalid-input)))
    ;; Save registration amount
    (map-set campaign-registrants
      { campaign-id: campaign-id, pool-id: pool-id, registrant: tx-sender }
      (+ current-amount reward-amount))
		(print { notification: "register-for-campaign", payload: { sender: tx-sender, campaign-id: campaign-id, pool-id: pool-id, reward-token: reward-token, reward-amount-added: reward-amount }})
		(ok true)))

;; New public function for voting
(define-public (vote-campaign (campaign-id uint) (votes (list 1000 { pool-id: uint, votes: uint })))
  (let (
    (campaign (unwrap! (map-get? campaigns campaign-id) err-invalid-campaign-id))
    (current-timestamp (unwrap! (block-timestamp) err-get-block-info))
    (voter-power (unwrap! (voting-power campaign-id tx-sender) err-invalid-input))
    (total-votes (fold + (map get-votes votes) u0)))
    
    (asserts! (< current-timestamp (get stake-end campaign)) err-stake-end-passed)
    (asserts! (not (get voted voter-power)) err-not-authorized)
    (asserts! (<= total-votes (get voting-power voter-power)) err-invalid-input)
    
    (fold update-pool-votes votes campaign-id)
    (map-set campaign-voted { campaign-id: campaign-id, voter: tx-sender } true)
    (map-set campaign-total-vote campaign-id (+ (default-to u0 (map-get? campaign-total-vote campaign-id)) total-votes))
    
    (print { notification: "vote-campaign", payload: { campaign-id: campaign-id, voter: tx-sender, votes: votes, total-votes: total-votes }})
    (ok true)))

;; governance calls

(define-public (set-revoke-enabled (enabled bool))
  (begin
    (try! (is-dao-or-extension))
    (ok (var-set revoke-enabled enabled))))

(define-public (whitelist-pools (pools (list 1000 uint)))
    (begin
        (try! (is-dao-or-extension))
        (var-set whitelisted-pools pools)
        (ok true)))

(define-public (create-campaign (registration-cutoff uint) (voting-cutoff uint) (stake-cutoff uint) (stake-end uint) (reward-amount uint) (snapshot-block uint))
  (let (
    (campaign-id (+ (var-get campaign-nonce) u1))
    (snapshot snapshot-block))
    (try! (is-dao-or-extension))
    (asserts! (< registration-cutoff voting-cutoff) err-invalid-input)
    (asserts! (< voting-cutoff stake-cutoff) err-invalid-input)
    (asserts! (< stake-cutoff stake-end) err-invalid-input)
    (map-set campaigns campaign-id { 
      registration-cutoff: registration-cutoff, 
      voting-cutoff: voting-cutoff,
      stake-cutoff: stake-cutoff, 
      stake-end: stake-end, 
      reward-amount: reward-amount,
      snapshot-block: snapshot
    })
		(print { notification: "create-campaign", payload: { campaign-id: campaign-id, registration-cutoff: registration-cutoff, voting-cutoff: voting-cutoff, stake-cutoff: stake-cutoff, stake-end: stake-end, reward-amount: reward-amount, snapshot-block: snapshot }})
    (var-set campaign-nonce campaign-id)
    (ok campaign-id)))

(define-public (transfer-token (token-trait <ft-trait>) (amount uint) (recipient principal))
	(begin 
		(try! (is-dao-or-extension))
		(as-contract (contract-call? token-trait transfer-fixed amount tx-sender recipient none))))

(define-public (update-campaign (campaign-id uint) (details { registration-cutoff: uint, voting-cutoff: uint, stake-cutoff: uint, stake-end: uint, reward-amount: uint, snapshot-block: uint }))
  (let (
    (campaign-details (try! (get-campaign-or-fail campaign-id))))
    (try! (is-dao-or-extension))
    (asserts! (< (get registration-cutoff details) (get voting-cutoff details)) err-invalid-input)
    (asserts! (< (get voting-cutoff details) (get stake-cutoff details)) err-invalid-input)
    (asserts! (< (get stake-cutoff details) (get stake-end details)) err-invalid-input)      
    (map-set campaigns campaign-id details)
    (print { notification: "update-campaign", payload: { campaign-id: campaign-id, details: details }})
    (ok true)))

(define-public (update-campaign-registrations (campaign-id uint) (pool-id uint) (reward-token principal) (reward-amount uint))
  (let (
    	(registered-pools (default-to (list) (map-get? campaign-registered-pools campaign-id))))
    (try! (is-dao-or-extension))
    (map-set campaign-registrations { campaign-id: campaign-id, pool-id: pool-id } { reward-token: reward-token, reward-amount: reward-amount, total-staked: u0 })
		(and (is-none (index-of registered-pools pool-id)) (map-set campaign-registered-pools campaign-id (unwrap! (as-max-len? (append registered-pools pool-id) u1000) err-invalid-input)))
    (print { notification: "update-campaign-registrations", payload: { campaign-id: campaign-id, pool-id: pool-id, reward-token: reward-token, reward-amount: reward-amount }})
    (ok true)))

(define-public (update-campaign-stakers (campaign-id uint) (pool-id uint) (staker principal) (amount uint) (claimed bool))
  (begin
    (try! (is-dao-or-extension))
    (map-set campaign-stakers { campaign-id: campaign-id, pool-id: pool-id, staker: staker } { amount: amount, claimed: claimed })
    (print { notification: "update-campaign-stakers", payload: { campaign-id: campaign-id, pool-id: pool-id, staker: staker, amount: amount, claimed: claimed }})
    (ok true)))
	
(define-public (update-campaign-registrants (campaign-id uint) (pool-id uint) (registrant principal) (amount uint))
  (begin
    (try! (is-dao-or-extension))
    (map-set campaign-registrants { campaign-id: campaign-id, pool-id: pool-id, registrant: registrant } amount)
    (print { notification: "update-campaign-registrants", payload: { campaign-id: campaign-id, pool-id: pool-id, registrant: registrant, amount: amount }})
    (ok true)))

;; privileged calls
		
;; private calls

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value)))

(define-private (mul-down (a uint) (b uint))
    (/ (* a b) ONE_8))

(define-private (div-down (a uint) (b uint))
  (if (is-eq a u0) u0 (/ (* a ONE_8) b)))

(define-private (min (a uint) (b uint))
    (if (<= a b) a b))

(define-private (max (a uint) (b uint))
    (if (>= a b) a b))

;; Helper function to get votes from vote entry
(define-private (get-votes (entry { pool-id: uint, votes: uint }))
  (get votes entry))

;; Helper function to update pool votes
(define-private (update-pool-votes (vote { pool-id: uint, votes: uint }) (campaign-id uint))
  (let (
    (pool-id (get pool-id vote))
    (vote-amount (get votes vote))
    (current-votes (default-to u0 (map-get? campaign-pool-votes { campaign-id: campaign-id, pool-id: pool-id }))))
    (map-set campaign-pool-votes { campaign-id: campaign-id, pool-id: pool-id } (+ current-votes vote-amount))
    campaign-id))  ;; Return the campaign-id to be used in the next iteration

(define-public (revoke-registration (pool-id uint) (campaign-id uint) (registrant principal) (reward-token-trait <ft-trait>))
  (let (
    (current-timestamp (try! (block-timestamp)))
    (campaign-details (try! (get-campaign-or-fail campaign-id)))
    (current-amount (get-registration-or-default campaign-id pool-id registrant))
    (campaign-registration (try! (get-campaign-registration-by-id-or-fail campaign-id pool-id))))

		(asserts! (get-revoke-enabled) err-revoke-disabled)

    ;; Check authorization - only DAO/extension or the registrant themselves can revoke
    (asserts! (or (is-eq tx-sender registrant) (is-ok (is-dao-or-extension))) err-not-authorized)
    
    ;; Check if registration exists
    (asserts! (> current-amount u0) err-not-registered)
    
    ;; Check if we're still in registration period
    (asserts! (< current-timestamp (get registration-cutoff campaign-details)) err-registration-cutoff-passed)

    ;; Verify the reward token matches what's registered
    (asserts! (is-eq (contract-of reward-token-trait) (get reward-token campaign-registration)) err-token-mismatch)

    ;; Update campaign registration total
    (map-set campaign-registrations 
      { campaign-id: campaign-id, pool-id: pool-id }
      (merge campaign-registration { reward-amount: (- (get reward-amount campaign-registration) current-amount) }))

    ;; Set registration amount to 0
    (map-set campaign-registrants
      { campaign-id: campaign-id, pool-id: pool-id, registrant: registrant }
      u0)

    ;; Refund the reward tokens
    (as-contract (try! (contract-call? 
      reward-token-trait
      transfer-fixed 
      current-amount
      tx-sender
      registrant
      none)))

    (print { notification: "revoke-registration", payload: { 
      campaign-id: campaign-id, 
      pool-id: pool-id, 
      registrant: registrant,
      amount-refunded: current-amount 
    }})
    (ok true)))

```
