;; SPDX-License-Identifier: BUSL-1.1

(impl-trait .alex-voting-power-trait.alex-voting-power)

(define-constant ONE_8 u100000000)
(define-constant err-get-block-info (err u1001))
(define-constant err-not-authorized (err u1000))

;; Data vars for storing pool IDs
(define-data-var voting-power-lp-pools (list 1000 uint) (list))
;; (define-data-var voting-power-surge-ids (list 200 uint) (list))

(define-private (mul-down (a uint) (b uint)) (/ (* a b) ONE_8))
(define-private (div-down (a uint) (b uint)) (if (is-eq a u0) u0 (/ (* a ONE_8) b)))

;; Authorization check
(define-read-only (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao) 
                    (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao is-extension contract-caller)) 
                err-not-authorized)))

;; Getters for the lists
(define-read-only (get-voting-power-lp-pools)
  (var-get voting-power-lp-pools))

;; (define-read-only (get-voting-power-surge-ids)
;;   (var-get voting-power-surge-ids))

;; Governance functions to update the lists
(define-public (set-voting-power-lp-pools (pools (list 1000 uint)))
  (begin
    (try! (is-dao-or-extension))
    (ok (var-set voting-power-lp-pools pools))))

;; (define-public (set-voting-power-surge-ids (surge-ids (list 200 uint)))
;;   (begin
;;     (try! (is-dao-or-extension))
;;     (ok (var-set voting-power-surge-ids surge-ids))))

;; Helper function to calculate voting power from a single pool
(define-private (get-pool-alex-balance (pool-id uint) (address principal))
  (let ((pool-tokens (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details-by-id pool-id)))
    (match pool-tokens
      success
        (let ((pool-details (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details 
                                                    (get token-x success) 
                                                    (get token-y success) 
                                                    (get factor success))))
            (total-supply (get total-supply pool-details)) ;; @dev instead of reading off token-amm-pool-v2-01, we use the pool-details to account for burnt liquidity.
            ;; (user-farm-details (match (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming get-user-id 
            ;;                                       'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 
            ;;                                       pool-id 
            ;;                                       address)
            ;;                   some-value (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming get-staker-at-cycle-or-default 
            ;;                                           'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 
            ;;                                           pool-id 
            ;;                                           (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming get-reward-cycle 
            ;;                                                                       'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 
            ;;                                                                       pool-id 
            ;;                                                                       tenure-height))
            ;;                                           some-value)
            ;;                   { amount-staked: u0, to-return: u0 }))
            (user-lp-balance (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 get-balance pool-id address)))
						(total-lp-balance user-lp-balance)
            ;; (total-lp-balance (+ user-lp-balance 
                              ;; (get amount-staked user-farm-details) 
                              ;; (get to-return user-farm-details)))
            (alex-from-x (if (and (> total-supply u0) (or (is-eq (get token-x success) 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex) 
                              (is-eq (get token-x success) 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3))) 
                          (/ (* total-lp-balance (get balance-x pool-details)) total-supply) 
                          u0))
            (alex-from-y (if (and (> total-supply u0) (or (is-eq (get token-y success) 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex) 
                              (is-eq (get token-y success) 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3))) 
                          (/ (* total-lp-balance (get balance-y pool-details)) total-supply) 
                          u0)))
        (+ alex-from-x alex-from-y))
      error u0)))

(define-private (calculate-lp-voting-power (pool-id uint) (acc { address: principal, total: uint }))
  (merge acc { total: (+ (get total acc) (get-pool-alex-balance pool-id (get address acc))) }))

;; (define-private (calculate-surge-lp-voting-power (surge-id uint) (acc { address: principal, total: uint }))
;;   (let ((staker-info (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-02 get-campaign-staker-or-default surge-id u0 (get address acc)))
;;         (unclaimed-amount (if (get claimed staker-info) u0 (get amount staker-info))))
;;     (merge acc { total: (+ (get total acc) unclaimed-amount) })))

(define-read-only (get-voting-power (snapshot-block uint) (address principal))
  (let ((snapshot-block-id (unwrap! (get-stacks-block-info? id-header-hash snapshot-block) err-get-block-info))
        (current-lp-pools (var-get voting-power-lp-pools))
        ;; (current-surge-ids (var-get voting-power-surge-ids))
        (total-voting-power (at-block snapshot-block-id
          (let ((alex-balance (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance-fixed address)))
                (auto-alex-balance (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wlialex get-balance-fixed address)))
                (wrapped-auto-alex-balance 
                  (let ((bal-base (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3-wrapped get-shares-to-tokens (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3-wrapped get-balance address))))
                      (decimals-base (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3-wrapped get-decimals))))                  
                    (if (is-eq decimals-base u8) bal-base (/ (* bal-base ONE_8) (pow u10 decimals-base)))))                  
                (manual-balance (match (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-staking-v2 get-user-id address)
                  some-value (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-staking-v2 get-staker-at-cycle-or-default (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-staking-v2 get-reward-cycle tenure-height)) some-value)
                  { amount-staked: u0, to-return: u0 }))
                (lp-voting-power (fold calculate-lp-voting-power current-lp-pools { address: address, total: u0 })))
                ;; (surge-voting-power (fold calculate-surge-lp-voting-power current-surge-ids { address: address, total: u0 })))
            (+ alex-balance 
               auto-alex-balance 
               (+ (get amount-staked manual-balance) (get to-return manual-balance))
               (get total lp-voting-power)
              ;;  (get total surge-voting-power)
               wrapped-auto-alex-balance)))))
    (ok total-voting-power))) 
