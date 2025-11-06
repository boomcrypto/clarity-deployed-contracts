;; @contract Core BTC
;; @version 2
;;
;; Core contract for the user to interact with (deposit, withdraw)

(use-trait reserve-trait .reserve-trait-v1.reserve-trait)
(use-trait direct-helpers-trait .direct-helpers-trait-v1.direct-helpers-trait)
(use-trait staking-trait .staking-trait-v1.staking-trait)
(use-trait commission-trait .commission-trait-v1.commission-trait)

;;-------------------------------------
;; Constants 
;;-------------------------------------

(define-constant ERR_WITHDRAW_LOCKED u204001)
(define-constant ERR_SHUTDOWN u204002)
(define-constant ERR_WITHDRAW_NOT_NFT_OWNER u204003)
(define-constant ERR_WITHDRAW_NFT_DOES_NOT_EXIST u204004)
(define-constant ERR_GET_OWNER u204005)
(define-constant ERR_INSUFFICIENT_IDLE u204006)
(define-constant ERR_WRONG_BPS u204007)
(define-constant ERR_WRONG_COMMISSION u204008)

(define-constant DENOMINATOR_6 u1000000)
(define-constant DENOMINATOR_BPS u10000)

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var commission-address principal .commission-v2) 
(define-data-var shutdown-deposits bool false)
(define-data-var shutdown-init-withdraw bool false)
(define-data-var shutdown-withdraw bool false)
(define-data-var shutdown-withdraw-idle bool false)
(define-data-var stack-fee uint u0) ;; in bps
(define-data-var unstack-fee uint u0) ;; in bps
(define-data-var withdraw-idle-fee uint u100) ;; in bps

;;-------------------------------------
;; Getters 
;;-------------------------------------

(define-read-only (get-commission-address)
  (var-get commission-address)
)

(define-read-only (get-shutdown-deposits)
  (var-get shutdown-deposits)
)

(define-read-only (get-shutdown-init-withdraw)
  (var-get shutdown-init-withdraw)
)

(define-read-only (get-shutdown-withdraw)
  (var-get shutdown-withdraw)
)

(define-read-only (get-shutdown-withdraw-idle)
  (var-get shutdown-withdraw-idle)
)

(define-read-only (get-stack-fee)
  (var-get stack-fee)
)

(define-read-only (get-unstack-fee)
  (var-get unstack-fee)
)

(define-read-only (get-withdraw-idle-fee)
  (var-get withdraw-idle-fee)
)

(define-read-only (get-idle-cycle)
  (let (
    (current-cycle (current-pox-reward-cycle))
    (start-block-next-cycle (reward-cycle-to-burn-height (+ current-cycle u1)))
    (withdraw-offset (contract-call? .data-core-v1 get-cycle-withdraw-offset))
  )
    (if (< burn-block-height (- start-block-next-cycle withdraw-offset))
      (ok current-cycle)
      (ok (+ current-cycle u1))
    )
  )
)

;;-------------------------------------
;; User  
;;-------------------------------------

;; Deposit STX for stSTXbtc
(define-public (deposit 
  (reserve <reserve-trait>) 
  (commission-contract <commission-trait>) 
  (staking-contract <staking-trait>) 
  (direct-helpers <direct-helpers-trait>)
  (stx-amount uint)
  (referrer (optional principal)) 
  (pool (optional principal))
)
  (let (
    (stx-fee-amount (/ (* (get-stack-fee) stx-amount) DENOMINATOR_BPS))
    (stx-user-amount (- stx-amount stx-fee-amount))
  )
    (try! (contract-call? .dao check-is-enabled))
    (try! (contract-call? .dao check-is-protocol (contract-of reserve)))
    (try! (contract-call? .dao check-is-protocol (contract-of commission-contract)))
    (try! (contract-call? .dao check-is-protocol (contract-of staking-contract)))
    (try! (contract-call? .dao check-is-protocol (contract-of direct-helpers)))

    (asserts! (is-eq (var-get commission-address) (contract-of commission-contract)) (err ERR_WRONG_COMMISSION))
    (asserts! (not (get-shutdown-deposits)) (err ERR_SHUTDOWN))

    (try! (contract-call? direct-helpers add-direct-stacking tx-sender pool stx-user-amount))
    (try! (contract-call? .data-core-v2 increase-stx-idle (unwrap-panic (get-idle-cycle)) stx-user-amount))

    ;; User
    (try! (stx-transfer? stx-user-amount tx-sender (contract-of reserve)))
    (try! (contract-call? .ststxbtc-token-v2 mint-for-protocol stx-user-amount tx-sender))

    ;; Fee
    (if (> stx-fee-amount u0)
      (begin
        (try! (stx-transfer? stx-fee-amount tx-sender (as-contract tx-sender)))
        (try! (as-contract (contract-call? commission-contract add-commission staking-contract stx-fee-amount)))
      )
      u0
    )

    (print { action: "deposit", data: { stacker: tx-sender, stx-amount: stx-amount, stx-user-amount: stx-user-amount, referrer: referrer, pool: pool, block-height: block-height } })
    (ok stx-user-amount)
  )
)

;; Deposited STX remains idle until the end of the cycle.
;; The idle STX can be used to withdraw immediately.
(define-public (withdraw-idle 
  (reserve <reserve-trait>)
  (direct-helpers <direct-helpers-trait>)
  (commission-contract <commission-trait>) 
  (staking-contract <staking-trait>) 
  (stx-amount uint)
)
  (let (
    (receiver tx-sender)

    (stx-fee-amount (/ (* (get-withdraw-idle-fee) stx-amount) DENOMINATOR_BPS))
    (stx-user-amount (- stx-amount stx-fee-amount))

    (idle-cycle (unwrap-panic (get-idle-cycle)))
    (current-idle-stx (contract-call? .data-core-v2 get-stx-idle idle-cycle))
  )
    (try! (contract-call? .dao check-is-enabled))
    (try! (contract-call? .dao check-is-protocol (contract-of reserve)))
    (try! (contract-call? .dao check-is-protocol (contract-of direct-helpers)))
    (try! (contract-call? .dao check-is-protocol (contract-of commission-contract)))
    (try! (contract-call? .dao check-is-protocol (contract-of staking-contract)))

    (asserts! (is-eq (var-get commission-address) (contract-of commission-contract)) (err ERR_WRONG_COMMISSION))
    (asserts! (not (get-shutdown-withdraw-idle)) (err ERR_SHUTDOWN))
    (asserts! (>= current-idle-stx stx-amount) (err ERR_INSUFFICIENT_IDLE))

    (try! (contract-call? .data-core-v2 decrease-stx-idle idle-cycle stx-amount))
    (try! (contract-call? direct-helpers subtract-direct-stacking tx-sender stx-amount))

    ;; STX to user, burn stSTXbtc
    (try! (as-contract (contract-call? reserve lock-stx-for-withdrawal stx-user-amount)))
    (try! (as-contract (contract-call? reserve request-stx-for-withdrawal stx-user-amount receiver)))
    (try! (contract-call? .ststxbtc-token-v2 burn-for-protocol stx-amount receiver))

    ;; Fee
    (if (> stx-fee-amount u0)
      (begin
        (try! (as-contract (contract-call? reserve lock-stx-for-withdrawal stx-fee-amount)))
        (try! (as-contract (contract-call? reserve request-stx-for-withdrawal stx-fee-amount tx-sender)))
        (try! (as-contract (contract-call? commission-contract add-commission staking-contract stx-fee-amount)))
      )
      u0
    )

    (print { action: "withdraw-idle", data: { stacker: tx-sender, stx-amount: stx-amount, block-height: block-height } })
    (ok { stx-user-amount: stx-user-amount, stx-fee-amount: stx-fee-amount})
  )
)

;; Initiate withdrawal, given STX amount. Can update amount as long as cycle not started.
;; The stSTXbtc tokens are transferred to this contract, and are burned on the actual withdrawal.
;; An NFT is minted for the user as a token representation of the withdrawal.
(define-public (init-withdraw 
  (reserve <reserve-trait>) 
  (direct-helpers <direct-helpers-trait>)
  (ststxbtc-amount uint)
)
  (let (
    (sender tx-sender)
    (unlock-burn-height (unwrap-panic (contract-call? .stacking-dao-core-v6 get-withdraw-unlock-burn-height)))

    (nft-id (unwrap-panic (contract-call? .ststxbtc-withdraw-nft get-last-token-id)))
  )
    (try! (contract-call? .dao check-is-enabled))
    (try! (contract-call? .dao check-is-protocol (contract-of reserve)))
    (try! (contract-call? .dao check-is-protocol (contract-of direct-helpers)))
    (asserts! (not (get-shutdown-init-withdraw)) (err ERR_SHUTDOWN))

    (try! (contract-call? .data-core-v2 set-ststxbtc-withdrawals-by-nft nft-id ststxbtc-amount unlock-burn-height))
    
    (try! (contract-call? direct-helpers subtract-direct-stacking tx-sender ststxbtc-amount))

    ;; Transfer stSTXbtc token to contract, only burn on actual withdraw
    (try! (as-contract (contract-call? reserve lock-stx-for-withdrawal ststxbtc-amount)))
    (try! (contract-call? .ststxbtc-token-v2 transfer ststxbtc-amount sender (as-contract tx-sender) none))
    (try! (as-contract (contract-call? .ststxbtc-withdraw-nft mint-for-protocol sender)))

    (print { action: "init-withdraw", data: { stacker: tx-sender, nft-id: nft-id, ststxbtc-amount: ststxbtc-amount, unlock-burn-height: unlock-burn-height, block-height: block-height } })
    (ok nft-id)
  )
)

;; Actual withdrawal for given NFT. 
;; The NFT and stSTXbtc tokens will be burned and the user will receive STX tokens.
(define-public (withdraw 
  (reserve <reserve-trait>)
  (commission-contract <commission-trait>) 
  (staking-contract <staking-trait>) 
  (nft-id uint)
)
  (let (
    (receiver tx-sender)

    (withdrawal-entry (contract-call? .data-core-v2 get-ststxbtc-withdrawals-by-nft nft-id))
    (unlock-burn-height (get unlock-burn-height withdrawal-entry))
    (stx-amount (get stx-amount withdrawal-entry))

    (nft-owner (unwrap! (contract-call? .ststxbtc-withdraw-nft get-owner nft-id) (err ERR_GET_OWNER)))

    (stx-fee-amount (/ (* (get-unstack-fee) stx-amount) DENOMINATOR_BPS))
    (stx-user-amount (- stx-amount stx-fee-amount))
  )
    (try! (contract-call? .dao check-is-enabled))
    (try! (contract-call? .dao check-is-protocol (contract-of reserve)))
    (try! (contract-call? .dao check-is-protocol (contract-of commission-contract)))
    (try! (contract-call? .dao check-is-protocol (contract-of staking-contract)))
    (asserts! (not (get-shutdown-withdraw)) (err ERR_SHUTDOWN))

    (asserts! (is-eq (var-get commission-address) (contract-of commission-contract)) (err ERR_WRONG_COMMISSION))
    (asserts! (is-some nft-owner) (err ERR_WITHDRAW_NFT_DOES_NOT_EXIST))
    (asserts! (is-eq (unwrap! nft-owner (err ERR_GET_OWNER)) tx-sender) (err ERR_WITHDRAW_NOT_NFT_OWNER))
    (asserts! (>= burn-block-height unlock-burn-height) (err ERR_WITHDRAW_LOCKED))

    (try! (contract-call? .data-core-v2 delete-ststxbtc-withdrawals-by-nft nft-id))

    ;; STX to user, burn stSTXbtc
    (try! (as-contract (contract-call? reserve request-stx-for-withdrawal stx-user-amount receiver)))
    (try! (contract-call? .ststxbtc-token-v2 burn-for-protocol (get stx-amount withdrawal-entry) (as-contract tx-sender)))
    (try! (as-contract (contract-call? .ststxbtc-withdraw-nft burn-for-protocol nft-id)))

    ;; Fee
    (if (> stx-fee-amount u0)
      (begin
        (try! (as-contract (contract-call? reserve request-stx-for-withdrawal stx-fee-amount tx-sender)))
        (try! (as-contract (contract-call? commission-contract add-commission staking-contract stx-fee-amount)))
      )
      u0
    )

    (print { action: "withdraw", data: { stacker: tx-sender, stx-user-amount: stx-user-amount, stx-amount: stx-amount, block-height: block-height } })
    (ok { stx-user-amount: stx-user-amount, stx-fee-amount: stx-fee-amount})
  )
)

;;-------------------------------------
;; Admin
;;-------------------------------------

(define-public (set-commission-address (contract principal))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (var-set commission-address contract)
    (ok true)
  )
)

(define-public (set-shutdown-deposits (shutdown bool))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))
    
    (var-set shutdown-deposits shutdown)
    (ok true)
  )
)

(define-public (set-shutdown-init-withdraw (shutdown bool))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))
    
    (var-set shutdown-init-withdraw shutdown)
    (ok true)
  )
)

(define-public (set-shutdown-withdraw (shutdown bool))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))
    
    (var-set shutdown-withdraw shutdown)
    (ok true)
  )
)

(define-public (set-shutdown-withdraw-idle (shutdown bool))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (var-set shutdown-withdraw-idle shutdown)
    (ok true)
  )
)

(define-public (set-stack-fee (fee uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))
    (asserts! (<= fee DENOMINATOR_BPS) (err ERR_WRONG_BPS))

    (var-set stack-fee fee)
    (ok true)
  )
)

(define-public (set-unstack-fee (fee uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))
    (asserts! (<= fee DENOMINATOR_BPS) (err ERR_WRONG_BPS))

    (var-set unstack-fee fee)
    (ok true)
  )
)

(define-public (set-withdraw-idle-fee (fee uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))
    (asserts! (<= fee DENOMINATOR_BPS) (err ERR_WRONG_BPS))

    (var-set withdraw-idle-fee fee)
    (ok true)
  )
)

;;-------------------------------------
;; PoX Helpers
;;-------------------------------------

(define-read-only (current-pox-reward-cycle) 
  (contract-call? 'SP000000000000000000002Q6VF78.pox-4 current-pox-reward-cycle)
)

(define-read-only (reward-cycle-to-burn-height (cycle-id uint)) 
  (contract-call? 'SP000000000000000000002Q6VF78.pox-4 reward-cycle-to-burn-height cycle-id)
)

(define-read-only (get-reward-cycle-length)
  (get reward-cycle-length (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.pox-4 get-pox-info)))
)
