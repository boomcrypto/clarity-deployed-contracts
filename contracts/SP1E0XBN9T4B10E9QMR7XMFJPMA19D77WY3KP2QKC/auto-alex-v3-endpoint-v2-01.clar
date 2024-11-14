;; SPDX-License-Identifier: BUSL-1.1

;; -- autoALEX creation/staking/redemption

;; constants
;;
(define-constant err-unauthorised (err u1000))
(define-constant err-invalid-liquidity (err u2003))
(define-constant err-not-activated (err u2043))
(define-constant err-paused (err u2046))
(define-constant err-staking-not-available (err u10015))
(define-constant err-reward-cycle-not-completed (err u10017))
(define-constant err-claim-and-stake (err u10018))
(define-constant err-no-redeem-revoke (err u10019))
(define-constant err-request-finalized-or-revoked (err u10020))
(define-constant err-end-cycle-v2 (err u10022))

(define-constant ONE_8 u100000000)
(define-constant REWARD-CYCLE-INDEXES (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32))

(define-constant PENDING 0x00)
(define-constant FINALIZED 0x01)
(define-constant REVOKED 0x02)

;; data maps and vars
;;

(define-data-var create-paused bool true)
(define-data-var redeem-paused bool true)

(define-constant max-cycles u32)

;; read-only calls

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lisa-dao) (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lisa-dao is-extension contract-caller)) err-unauthorised)))

(define-read-only (get-start-cycle)
  (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3-registry get-start-cycle))

(define-read-only (is-cycle-staked (reward-cycle uint))
  (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3-registry is-cycle-staked reward-cycle))

(define-read-only (get-shares-to-tokens-per-cycle-or-default (reward-cycle uint))
  (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3-registry get-shares-to-tokens-per-cycle-or-default reward-cycle))

(define-read-only (get-redeem-shares-per-cycle-or-default (reward-cycle uint))
  (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3-registry get-redeem-shares-per-cycle-or-default reward-cycle))

(define-read-only (get-redeem-request-or-fail (request-id uint))
  (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3-registry get-redeem-request-or-fail request-id))

(define-read-only (is-create-paused)
  (var-get create-paused))

(define-read-only (is-redeem-paused)
  (var-get redeem-paused))

;; @desc get the next capital base of the vault
;; @desc next-base = principal to be staked at the next cycle
;; @desc           + principal to be claimed at the next cycle and staked for the following cycle
;; @desc           + reward to be claimed at the next cycle and staked for the following cycle
;; @desc           + balance of ALEX in the contract
;; @desc           + intrinsic of autoALEXv2 in the contract
(define-read-only (get-next-base)
  (let (
      (current-cycle (unwrap! (get-reward-cycle block-height) err-staking-not-available))
      (auto-alex-v2-bal (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex-v2 get-balance 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3))))
    (asserts! (or (is-eq current-cycle (get-start-cycle)) (is-cycle-staked (- current-cycle u1))) err-claim-and-stake)
    (ok
      (+
        (get amount-staked (as-contract (get-staker-at-cycle (+ current-cycle u1))))
        (get to-return (as-contract (get-staker-at-cycle current-cycle)))
        (as-contract (get-staking-reward current-cycle))
        (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3))
        (if (is-eq auto-alex-v2-bal u0) u0 (mul-down auto-alex-v2-bal (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex-v2 get-intrinsic))))))))

;; @desc get the intrinsic value of auto-alex-v3
;; @desc intrinsic = next capital base of the vault / total supply of auto-alex-v3
(define-read-only (get-intrinsic)
  (get-shares-to-tokens ONE_8))

(define-read-only (get-reward-cycle (burn-height uint))
  (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.alex-reserve-pool get-reward-cycle 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token burn-height))

(define-read-only (get-staking-reward (reward-cycle uint))
  (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-staking-v2 get-staking-reward (get-user-id) reward-cycle))

(define-read-only (get-staker-at-cycle (reward-cycle uint))
  (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-staking-v2 get-staker-at-cycle-or-default reward-cycle (get-user-id)))

;; governance calls

(define-public (pause-create (pause bool))
  (begin
    (try! (is-dao-or-extension))
    (ok (var-set create-paused pause))))

(define-public (pause-redeem (pause bool))
  (begin
    (try! (is-dao-or-extension))
    (ok (var-set redeem-paused pause))))

;; public functions
;;

(define-public (rebase)
  (let (
      (current-cycle (unwrap! (get-reward-cycle block-height) err-staking-not-available))
      (start-cycle (get-start-cycle))
      (check-start-cycle (asserts! (<= start-cycle current-cycle) err-not-activated)))
    (and (> current-cycle start-cycle) (not (is-cycle-staked (- current-cycle u1))) (try! (claim-and-stake (- current-cycle u1))))
    (as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3 set-reserve (try! (get-next-base)))))    
    (ok current-cycle)))

;; claims alex for the reward-cycles and mint auto-alex-v3
(define-public (claim-and-mint (reward-cycles (list 200 uint)))
  (let (
      (claimed (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-staking-v2 claim-staking-reward-many reward-cycles))))
    (try! (add-to-position (try! (fold sum-claimed claimed (ok u0)))))
    (ok claimed)))

;; @desc add to position
;; @desc transfers dx to vault, stake them for 32 cycles and mints auto-alex-v3, the number of which is determined as % of total supply / next base
;; @param dx the number of $ALEX in 8-digit fixed point notation
(define-public (add-to-position (dx uint))
  (let (
      (current-cycle (try! (rebase)))
      (sender tx-sender))
    (asserts! (> dx u0) err-invalid-liquidity)
    (asserts! (not (is-create-paused)) err-paused)
    (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex transfer dx sender 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3 none))
    (try! (fold stake-tokens-iter REWARD-CYCLE-INDEXES (ok { current-cycle: current-cycle, remaining: dx })))
    (as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3 mint dx sender)))
    (print { notification: "position-added", payload: { new-supply: dx, sender: sender } })
    (try! (rebase))
		(ok true)))

(define-public (upgrade (dx uint))
  (let (
      (end-cycle-v2 (get-end-cycle-v2))
      (current-cycle (try! (rebase)))
      (intrinsic-dx (mul-down dx (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex-v2 get-intrinsic))))
      (sender tx-sender))
    (asserts! (> intrinsic-dx u0) err-invalid-liquidity)
    (asserts! (not (is-create-paused)) err-paused)
    (asserts! (< end-cycle-v2 (+ current-cycle max-cycles)) err-end-cycle-v2) ;; auto-alex-v2 is not configured correctly
    (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex-v2 transfer dx sender 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3 none))
    (and (< end-cycle-v2 current-cycle) (begin (as-contract (try! (reduce-position-v2))) true))
    (as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3 mint intrinsic-dx sender)))
    (print { notification: "upgrade-position-added", payload: { new-supply: intrinsic-dx, sender: sender } })
    (try! (rebase))
		(ok true)))

(define-public (request-redeem (amount uint))
  (let (
      (current-cycle (try! (rebase)))
      (redeem-cycle (+ current-cycle max-cycles))
      (request-details { requested-by: tx-sender, amount: amount, redeem-cycle: redeem-cycle, status: PENDING })
			(request-id (as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3-registry set-redeem-request u0 request-details)))))
    (asserts! (not (is-redeem-paused)) err-paused)
    (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3 transfer amount tx-sender 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3 none))
    (as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3-registry set-redeem-shares-per-cycle redeem-cycle (+ (get-redeem-shares-per-cycle-or-default redeem-cycle) amount))))
    (print { notification: "redeem-request", payload: request-details })
    (try! (rebase))
		(ok request-id)))

(define-public (finalize-redeem (request-id uint))
  (let (
      (request-details (try! (get-redeem-request-or-fail request-id)))
      (redeem-cycle (get redeem-cycle request-details))
      (check-claim-and-stake (and (not (is-cycle-staked redeem-cycle)) (try! (claim-and-stake redeem-cycle))))
      (current-cycle (try! (rebase)))
      (prev-shares-to-tokens (get-shares-to-tokens-per-cycle-or-default (- redeem-cycle u1)))
      (base-shares-to-tokens (get-shares-to-tokens-per-cycle-or-default (- redeem-cycle u32)))
      (tokens (div-down (mul-down prev-shares-to-tokens (get amount request-details)) base-shares-to-tokens))
      (updated-request-details (merge request-details { status: FINALIZED })))
    (asserts! (not (is-redeem-paused)) err-paused)
    (asserts! (is-eq PENDING (get status request-details)) err-request-finalized-or-revoked)

    (as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex transfer tokens tx-sender (get requested-by request-details) none)))
    (print { notification: "finalize-redeem", payload: updated-request-details })
    (as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3-registry set-redeem-request request-id updated-request-details)))
    (try! (rebase))
		(ok true)))

(define-public (revoke-redeem (request-id uint))
  (let (
      (request-details (try! (get-redeem-request-or-fail request-id)))
      (current-cycle (try! (rebase)))
      (redeem-cycle (get redeem-cycle request-details))
      (check-cycle (asserts! (> redeem-cycle current-cycle) err-no-redeem-revoke))
      (prev-shares-to-tokens (get-shares-to-tokens-per-cycle-or-default (- current-cycle u1)))
      (base-shares-to-tokens (get-shares-to-tokens-per-cycle-or-default (- redeem-cycle u33)))
      (tokens (div-down (mul-down prev-shares-to-tokens (get amount request-details)) base-shares-to-tokens))
      (updated-request-details (merge request-details { status: REVOKED })))
    (asserts! (is-eq tx-sender (get requested-by request-details)) err-unauthorised)
    (asserts! (is-eq PENDING (get status request-details)) err-request-finalized-or-revoked)
    (as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3 transfer-token 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3 tokens (get requested-by request-details))))
    (as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3-registry set-redeem-shares-per-cycle redeem-cycle (- (get-redeem-shares-per-cycle-or-default redeem-cycle) (get amount request-details)))))
    (print { notification: "revoke-redeem", payload: updated-request-details })
    (as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3-registry set-redeem-request request-id updated-request-details)))
    (try! (rebase))
		(ok true)))

;; private functions
;;

;; @desc triggers external event that claims all that's available and stake for another 32 cycles
;; @param reward-cycle the target cycle to claim (and stake for current cycle + 32 cycles). reward-cycle must be < current cycle.
(define-private (claim-and-stake (reward-cycle uint))
  (let (
      (current-cycle (unwrap! (get-reward-cycle block-height) err-staking-not-available))
      (end-cycle-v2 (get-end-cycle-v2))
      ;; claim all that's available to claim for the reward-cycle
      (claimed (as-contract (try! (claim-staking-reward reward-cycle))))
      (claimed-v2 (if (< end-cycle-v2 current-cycle) (as-contract (try! (reduce-position-v2))) (begin (try! (claim-and-stake-v2 reward-cycle)) u0)))
      (tokens (+ (get to-return claimed) (get entitled-token claimed) claimed-v2))      
      (redeeming (if (is-eq (get-redeem-shares-per-cycle-or-default reward-cycle) u0) u0
        (div-down (mul-down (get-shares-to-tokens-per-cycle-or-default (- reward-cycle u1)) (get-redeem-shares-per-cycle-or-default reward-cycle)) (get-shares-to-tokens-per-cycle-or-default (- reward-cycle u33))))))
    (asserts! (> current-cycle reward-cycle) err-reward-cycle-not-completed)
    (as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3-registry set-staked-cycle reward-cycle true)))
    (as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3 set-reserve (try! (get-next-base)))))
    (as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3-registry set-shares-to-tokens-per-cycle reward-cycle (get-shares-to-tokens ONE_8))))                            
    (and (> (min tokens redeeming) u0) (as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3 burn (min tokens redeeming) 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3))))
    (and (> (min tokens redeeming) u0) (as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3 transfer-token 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex (min tokens redeeming) tx-sender))))    
    (try! (fold stake-tokens-iter REWARD-CYCLE-INDEXES (ok { current-cycle: current-cycle, remaining: (- tokens (min tokens redeeming)) })))
    (print { notification: "claim-and-stake", payload: { redeeming: redeeming, tokens: tokens }})
    (ok true)))

(define-private (sum-claimed (claimed-response (response (tuple (entitled-token uint) (to-return uint)) uint)) (prior (response uint uint)))
  (match prior
    ok-value (match claimed-response claimed (ok (+ ok-value (get to-return claimed) (get entitled-token claimed))) err (err err))
    err-value (err err-value)))

(define-private (stake-tokens-iter (cycles-to-stake uint) (previous-response (response { current-cycle: uint, remaining: uint } uint)))
  (match previous-response
    ok-value
    (let (
      (reward-cycle (+ (get current-cycle ok-value) cycles-to-stake))
      (redeeming (if (is-eq (get-redeem-shares-per-cycle-or-default reward-cycle) u0) u0
        (div-down (get-shares-to-tokens (get-redeem-shares-per-cycle-or-default reward-cycle)) (get-shares-to-tokens-per-cycle-or-default (- reward-cycle u33)))))
      (returning (+ (get to-return (get-staker-at-cycle reward-cycle)) (get-staking-reward reward-cycle)))
      (staking (if (is-eq cycles-to-stake max-cycles)
        (get remaining ok-value)
        (if (> returning redeeming)
          u0
          (if (> (get remaining ok-value) (- redeeming returning))
            (- redeeming returning)
            (get remaining ok-value))))))
      (and (> staking u0) (as-contract (try! (stake-tokens staking cycles-to-stake))))
      (ok { current-cycle: (get current-cycle ok-value), remaining: (- (get remaining ok-value) staking) }))
    err-value previous-response))

(define-private (get-user-id)
  (default-to u0 (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-staking-v2 get-user-id 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3)))

(define-private (stake-tokens (amount-tokens uint) (lock-period uint))
  (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3 stake-tokens amount-tokens lock-period))

(define-private (claim-staking-reward (reward-cycle uint))
  (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3 claim-staking-reward reward-cycle))

(define-private (reduce-position-v2)
  (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3 reduce-position-v2))

(define-private (get-shares-to-tokens (dx uint))
  (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3 get-shares-to-tokens dx))

(define-private (claim-and-stake-v2 (reward-cycle uint))
  (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex-v2 claim-and-stake reward-cycle))

(define-private (get-end-cycle-v2)
  (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex-v2 get-end-cycle))

(define-private (mul-down (a uint) (b uint))
    (/ (* a b) ONE_8))

(define-private (div-down (a uint) (b uint))
  (if (is-eq a u0) u0 (/ (* a ONE_8) b)))

(define-private (max (a uint) (b uint)) (if (> a b) a b))
(define-private (min (a uint) (b uint)) (if (< a b) a b))

