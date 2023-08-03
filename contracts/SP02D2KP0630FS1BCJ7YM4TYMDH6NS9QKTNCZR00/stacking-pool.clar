
;; Main Stacking Pool Contract


;; Flow
;; 1. The liquidity provider deploys the contract 
;; 2. He locks into the SC a sum which will be sufficient to cover all the stackers' rewards
;; 3. Stackers who want to stack through the stacking pool have to join the pool.
;; 4. They will have to delegate the STX they want to stack to the pool's POX address
;; 5. When the total amount commited is enough to be stacked, it will be auto committed
;; 6. The stackers will be able to claim the rewards after they are distributed

;; + In prepare phase, calculate weight of the stackers inside the pool (Notion)

;; Default length of the PoX registration window, in burnchain blocks.
;;TODO: pox-2 mainnet address: 'SP000000000000000000002Q6VF78
(define-constant PREPARE_CYCLE_LENGTH (get prepare-cycle-length (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.pox-3 get-pox-info))))

;; Default length of the PoX reward cycle, in burnchain blocks.
(define-constant REWARD_CYCLE_LENGTH (get reward-cycle-length (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.pox-3 get-pox-info))))

;; Half cycle length is 1050 for mainnet
(define-constant half-cycle-length (/ (get reward-cycle-length (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.pox-3 get-pox-info))) u2))

(define-constant err-only-liquidity-provider (err u100))
(define-constant err-already-in-pool (err u101))
(define-constant err-not-in-pool (err u102))
(define-constant err-liquidity-provider-not-permitted (err u103))
(define-constant err-wrong-moment-to-update-balances (err u123))
(define-constant err-allow-pool-in-SC-first (err u195))
(define-constant err-allow-pool-in-pox-2-first (err u199))
(define-constant err-insufficient-funds (err u200))
(define-constant err-disallow-pool-in-pox-2-first (err u299))
(define-constant err-full-stacking-pool (err u300))
(define-constant err-same-value (err u325))
(define-constant err-future-reward-not-covered (err u333))
(define-constant err-not-delegated-that-amount (err u396))
(define-constant err-no-locked-funds (err u456))
(define-constant err-too-early (err u500))
(define-constant err-decrease-forbidden (err u503))
(define-constant err-no-reward-yet (err u576))
(define-constant err-not-enough-reserved-balance (err u579))
(define-constant err-stacking-permission-denied (err u609))
(define-constant err-transfer-failed (err u777))
(define-constant err-cant-calculate-weights (err u888))
(define-constant err-already-updated-balances (err u895))
(define-constant err-no-reward-for-this-block (err u900))
(define-constant err-already-rewarded-block (err u992))
(define-constant err-cant-withdraw-now (err u995))
(define-constant err-cant-unwrap-exchange-preview (err u996))
(define-constant err-return-div-exceeds-maximum (err u997))
(define-constant err-pox-address-deactivated (err u999))
(define-constant err-weights-not-calculated (err u1000))

(define-constant first-deposit u0)
(define-constant list-max-len u300)
(define-constant pool-contract (as-contract tx-sender))
(define-constant pox-2-contract (as-contract 'SP000000000000000000002Q6VF78.pox-3))
(define-constant blocks-to-pass-until-reward u101)
(define-constant max-return-div-accepted u20)
(define-constant ONE-6 u1000000)
;; liquidity provider data vars
(define-data-var sc-total-balance uint u0)
(define-data-var sc-owned-balance uint u0)
(define-data-var sc-reserved-balance uint u0)
  ;; (the percentage of the locked balance assured by the liquidity provider) ^ -1,
  ;; return-div = u20 => the liquidity provider is ready to grant a maximum of 5% of the total locked balance.
(define-data-var return-div uint u20)  
;; stackers data vars
(define-data-var sc-delegated-balance uint u0)
(define-data-var sc-locked-balance uint u0)

;; temporary data var helpers
(define-data-var calc-delegated-balance uint u0)
(define-data-var calc-locked-balance uint u0)
(define-data-var reward-cycle-to-calculate-weight uint u0)
(define-data-var burn-block-to-distribute-rewards uint u0)
(define-data-var reward-cycle-to-distribute-rewards uint u0)

;; common data vars
(define-data-var minimum-deposit-amount-liquidity-provider uint u10000000000) ;; minimum amount for the liquidity provider to transfer after deploy in microSTX (STX * 10^-6)
(define-data-var stackers-list (list 300 principal) (list tx-sender))
(define-data-var liquidity-provider principal tx-sender)
(define-data-var active bool true)
(define-data-var blocks-rewarded uint u0)
(define-data-var amount-rewarded uint u0)


;; liqidity provider reward bitcoin address
(define-data-var pool-pox-address {hashbytes: (buff 32), version: (buff 1)}
  {
    version: 0x04,
    hashbytes: 0x83ed66860315e334010bbfb76eb3eef887efee0a})

(define-data-var stx-buffer uint u0) ;; 0 STX

;; data maps

(define-map user-data { address: principal } {is-in-pool:bool, delegated-balance: uint, locked-balance:uint, until-burn-ht: (optional uint) })
(define-map pox-addr-indices uint uint)
(define-map last-aggregation uint uint)
(define-map allowance-contract-callers { sender: principal, contract-caller: principal} { until-burn-ht: (optional uint)})
(define-map stacker-weights-per-reward-cycle { stacker: principal, reward-cycle: uint } { weight-percentage: uint })
(define-map calculated-weights-reward-cycles { reward-cycle: uint } { calculated: bool })
(define-map burn-block-rewards { burn-height: uint } { reward: uint })
(define-map updated-sc-balances { reward-cycle: uint } { updated: bool, stackers-list: (list 300 principal) })
(define-map already-rewarded { burn-block-height: uint } { value: bool })
(allow-contract-caller (as-contract tx-sender) none)

(map-set user-data {address: tx-sender} {is-in-pool: true, delegated-balance: u0, locked-balance: u0, until-burn-ht: none})

;; Public functions

(define-public (deposit-stx-liquidity-provider (amount uint)) 
(begin 
  (asserts! (is-eq tx-sender (var-get liquidity-provider)) err-only-liquidity-provider)
  (asserts! (>= amount (var-get minimum-deposit-amount-liquidity-provider)) err-future-reward-not-covered)
  (try! (stx-transfer? amount tx-sender pool-contract))
  (var-set sc-total-balance (+ amount (var-get sc-total-balance)))
  (var-set sc-owned-balance (+ amount (var-get sc-owned-balance)))
  (ok true)))

(define-public (withdraw-stx-liquidity-provider (amount uint)) 
(begin 
  (asserts! (is-eq tx-sender (var-get liquidity-provider)) err-only-liquidity-provider)
  (asserts! 
    (and 
      (check-can-decrement-owned-balance amount) 
      (check-can-decrement-total-balance amount)) 
  err-insufficient-funds)
  (try! 
    (as-contract 
      (stx-transfer? amount tx-sender (var-get liquidity-provider))))
  (var-set sc-total-balance (- (var-get sc-total-balance) amount))
  (var-set sc-owned-balance (- (var-get sc-owned-balance) amount))
  (ok true)))

(define-public (reserve-funds-future-rewards (amount uint)) 
(begin 
  (asserts! (is-eq tx-sender (var-get liquidity-provider)) err-only-liquidity-provider)
  (asserts! (>= (var-get sc-owned-balance) amount) err-insufficient-funds) 
  (asserts! (>= amount (var-get minimum-deposit-amount-liquidity-provider)) err-future-reward-not-covered)
  (var-set sc-owned-balance (- (var-get sc-owned-balance) amount))
  (var-set sc-reserved-balance (+ (var-get sc-reserved-balance) amount))
  (ok true)))

(define-public (unlock-extra-reserved-funds) 
(begin 
  (asserts! 
    (is-eq 
      tx-sender 
      (var-get liquidity-provider)) 
  err-only-liquidity-provider)
  (asserts! (can-withdraw-extra-reserved-now) err-cant-withdraw-now)
    (let ((unreserve-amount (calculate-extra-reserved-funds))
          (reserved-balance-before (var-get sc-reserved-balance))
          (owned-balance-before (var-get sc-owned-balance))) 
      (var-set sc-reserved-balance 
        (- 
          reserved-balance-before 
          unreserve-amount))
      (var-set sc-owned-balance 
        (+ 
          owned-balance-before 
          unreserve-amount))
      (ok unreserve-amount))))

(define-public (join-stacking-pool)
(begin
  (asserts! (check-pool-SC-pox-2-allowance) err-allow-pool-in-pox-2-first)
  ;; (asserts! (check-caller-allowed) err-allow-pool-in-SC-first)
  (asserts! (is-none (map-get? user-data {address: tx-sender})) err-already-in-pool)
  (var-set stackers-list (unwrap! (as-max-len? (concat (var-get stackers-list) (list tx-sender )) u300) err-full-stacking-pool)) 
  (map-set user-data {address: tx-sender} {is-in-pool: true, delegated-balance: u0, locked-balance: u0, until-burn-ht: none})
  (ok true)))

(define-public (allow-contract-caller (caller principal) (until-burn-ht (optional uint)))
(begin
  (asserts! (is-eq tx-sender contract-caller) err-stacking-permission-denied)
  (ok (map-set allowance-contract-callers
        { sender: tx-sender, contract-caller: caller}
        { until-burn-ht: until-burn-ht}))))

;; revoke contract-caller authorization to call stacking methods
(define-public (disallow-contract-caller (caller principal))
(begin
  (asserts! (is-eq tx-sender contract-caller) err-stacking-permission-denied)
  (ok (map-delete allowance-contract-callers { sender: tx-sender, contract-caller: caller}))))

(define-public (quit-stacking-pool)
(begin
  (asserts! (not (check-pool-SC-pox-2-allowance)) err-disallow-pool-in-pox-2-first)
  (asserts! (is-some (map-get? user-data {address: tx-sender})) err-not-in-pool)
  (asserts! (not (is-eq tx-sender (var-get liquidity-provider))) err-liquidity-provider-not-permitted)
  (let ((result-revoke
          ;; calls revoke and ignores result
          (contract-call? 'SP000000000000000000002Q6VF78.pox-3 revoke-delegate-stx)))

      (try! (disallow-contract-caller pool-contract))
      (var-set stackers-list (filter remove-stacker-stackers-list (var-get stackers-list))) 
      (map-delete user-data {address: tx-sender})
      (ok true))))

;; The SC balances need to be updated during the first half of every Prepare Phase
;; Everyone can call the function in order to recalculate each stacker's weight inside the pool
;; This WILL directly AFFECT the reward distribution
(define-public (update-sc-balances)
(let (
  (next-reward-cycle (get-next-reward-cycle))
  (next-reward-cycle-first-block (contract-call? 'SP000000000000000000002Q6VF78.pox-3 reward-cycle-to-burn-height (get-next-reward-cycle)))) 
(begin 
  ;; check current block to be inside the first half of the current reward cycle's prepare phase
  (asserts! 
    (<= 
      burn-block-height 
      (+ 
        (- 
          next-reward-cycle-first-block
          PREPARE_CYCLE_LENGTH)
        (/ PREPARE_CYCLE_LENGTH u2))) 
  err-wrong-moment-to-update-balances)
  (asserts! (is-none (map-get? updated-sc-balances {reward-cycle: next-reward-cycle})) err-already-updated-balances)
  (var-set calc-locked-balance u0)
  (var-set calc-delegated-balance u0)
  (map update-sc-balances-one-stacker (var-get stackers-list))
  (var-set sc-locked-balance (var-get calc-locked-balance))
  (var-set sc-delegated-balance (var-get calc-delegated-balance))
  (map-set updated-sc-balances {reward-cycle: next-reward-cycle} {updated: true, stackers-list: (var-get stackers-list)})
  (var-set reward-cycle-to-calculate-weight next-reward-cycle)
  (unwrap! (calculate-all-stackers-weights (var-get stackers-list) next-reward-cycle) err-cant-calculate-weights)
  (ok true))))

;; recalculate balances inside pool
(define-public (update-sc-balances-one-stacker (stacker principal))
(let ((user-until-burn-ht (default-to u0 (default-to (some u0) (get until-burn-ht (map-get? user-data {address: stacker})))))
      (user-delegated-balance (default-to u0 (get delegated-balance (map-get? user-data {address: stacker}))))
      (user-locked-balance (default-to u0 (get locked-balance (map-get? user-data {address: stacker}))))) 
  (ok 
    ;; if burn-block-height < user's unlock burn block height, then user's balances 
    (if 
        (< 
          burn-block-height 
          user-until-burn-ht) 
        (begin 
          (var-set calc-locked-balance 
            (+ 
              (var-get calc-locked-balance) 
              user-locked-balance))
          (var-set calc-delegated-balance 
            (+ 
              (var-get calc-delegated-balance) 
              user-delegated-balance))) 
        (begin 
          (var-set calc-locked-balance (var-get calc-locked-balance))
          (var-set calc-delegated-balance (var-get calc-delegated-balance)))))))

;; The rewards will be distributed. At that moment, the SC balance should have been updated and the stackers' weights calculated
(define-public (reward-distribution (rewarded-burn-block uint))
(let ((reward-cycle 
        (contract-call? 'SP000000000000000000002Q6VF78.pox-3 burn-height-to-reward-cycle rewarded-burn-block))
      (stackers-list-for-reward-cycle 
        (default-to (list ) (get stackers-list (map-get? updated-sc-balances {reward-cycle: reward-cycle})))))
          (asserts! (< rewarded-burn-block burn-block-height) err-no-reward-yet)
          (asserts! (check-won-block-rewards rewarded-burn-block) err-no-reward-for-this-block)
          (asserts! (is-none (map-get? already-rewarded {burn-block-height: rewarded-burn-block})) err-already-rewarded-block)
          (var-set burn-block-to-distribute-rewards rewarded-burn-block)
          (var-set amount-rewarded (+ (var-get amount-rewarded) (default-to u0 (get reward (map-get? burn-block-rewards { burn-height: (var-get burn-block-to-distribute-rewards)})))))
          (var-set blocks-rewarded (+ (var-get blocks-rewarded) u1))
          (map-set already-rewarded {burn-block-height: rewarded-burn-block} {value: true})
          (var-set reward-cycle-to-distribute-rewards reward-cycle)
          (match (map-get? calculated-weights-reward-cycles {reward-cycle: reward-cycle}) 
            calculated (ok 
                        (transfer-rewards-all-stackers stackers-list-for-reward-cycle))
            err-weights-not-calculated)))

;; delegating stx to the pool SC
(define-public (delegate-stx (amount-ustx uint))
(let ((user tx-sender)
      (current-cycle (contract-call? 'SP000000000000000000002Q6VF78.pox-3 current-pox-reward-cycle)))
  (asserts! (check-caller-allowed) err-stacking-permission-denied)
  (asserts! (check-pool-SC-pox-2-allowance) err-allow-pool-in-pox-2-first)
  
  (asserts! (is-in-pool) err-not-in-pool)
  (try! (delegate-stx-inner amount-ustx (as-contract tx-sender) none))
  (try! (as-contract (lock-delegated-stx user)))
  (ok (maybe-stack-aggregation-commit current-cycle))))

;; Stacks the delegated amount for the given user for the next cycle.
;; This function can be called by automation, friends or family for user that have delegated once.
;; This function can be called only after the current cycle is half through
(define-public (delegate-stack-stx (user principal))
  (let ((current-cycle (contract-call? 'SP000000000000000000002Q6VF78.pox-3 current-pox-reward-cycle)))
    (asserts! (can-lock-now current-cycle) err-too-early)
    ;; Do 3.
    (try! (as-contract (lock-delegated-stx user)))
    ;; Do 4.
    (ok (maybe-stack-aggregation-commit current-cycle))))

(define-public (delegate-stack-stx-many (stackers-lock-list (list 100 principal))) 
(ok (map delegate-stack-stx stackers-lock-list)))

(define-public (multiple-blocks-check-won-rewards (burn-heights-list (list 100 uint))) 
(ok (map check-won-block-rewards burn-heights-list)))

;; liquidity provider pool management functions

(define-public (set-pool-pox-address (new-pool-pox-address {hashbytes: (buff 32), version: (buff 1)})) 
(begin 
  (asserts! (is-eq tx-sender (var-get liquidity-provider)) err-only-liquidity-provider)
  (ok (var-set pool-pox-address new-pool-pox-address))))

(define-public (set-active (is-active bool))
(begin
  (asserts! (is-eq tx-sender (var-get liquidity-provider)) err-only-liquidity-provider)    
  (ok (var-set active is-active))))

(define-public (set-liquidity-provider (new-liquidity-provider principal)) 
(begin 
  (asserts! (is-eq tx-sender (var-get liquidity-provider)) err-only-liquidity-provider)
  (asserts! (is-some (map-get? user-data {address: new-liquidity-provider})) err-not-in-pool) ;; new liquidity provider should be in pool
  (ok (var-set liquidity-provider new-liquidity-provider))))

(define-public (update-return (new-return-value uint)) 
(begin 
  (asserts! (is-eq tx-sender (var-get liquidity-provider)) err-only-liquidity-provider) 
  (asserts! (<= new-return-value max-return-div-accepted) err-return-div-exceeds-maximum)
  (asserts! (not (is-eq new-return-value (var-get return-div))) err-same-value)
  (var-set return-div new-return-value)
  (ok new-return-value)))

;; Private functions

;; Pox operative functions

(define-private (maybe-stack-aggregation-commit (current-cycle uint))
(let ((reward-cycle (+ u1 current-cycle)))
  (match (map-get? pox-addr-indices reward-cycle)
          ;; Total stacked already reached minimum.
          ;; Call stack-aggregate-increase.
          ;; It might fail because called in the same cycle twice.
    index (match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.pox-3 stack-aggregation-increase (var-get pool-pox-address) reward-cycle index))
            success (map-set last-aggregation reward-cycle block-height)
            error (begin (print {err-increase-ignored: error}) false))
          ;; Total stacked is still below minimum.
          ;; Just try to commit, it might fail because minimum not yet met
    (match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.pox-3 stack-aggregation-commit-indexed (var-get pool-pox-address) reward-cycle))
      index (begin
              (map-set pox-addr-indices reward-cycle index)
              (map-set last-aggregation reward-cycle block-height))
      error (begin 
              (print {err-commit-ignored: error}) false))))) ;; ignore errors

(define-private (delegate-stx-inner (amount-ustx uint) (delegate-to principal) (until-burn-ht (optional uint)))
(let ((result-revoke
        ;; Calls revoke and ignores result
        (contract-call? 'SP000000000000000000002Q6VF78.pox-3 revoke-delegate-stx))
      (user-delegated-balance 
        (default-to u0 (get delegated-balance (map-get? user-data {address: tx-sender})))))
      (if 
          (is-ok result-revoke) 
          (if 
            (unwrap-panic result-revoke) 
            (begin 
              (asserts! 
                (check-can-decrement-delegated-balance 
                  user-delegated-balance) 
              err-not-delegated-that-amount) 
              (decrement-sc-delegated-balance user-delegated-balance)) 
            (decrement-sc-delegated-balance u0)) 
          (decrement-sc-delegated-balance u0))
  ;; Calls delegate-stx, converts any error to uint
  (match (contract-call? 'SP000000000000000000002Q6VF78.pox-3 delegate-stx amount-ustx delegate-to until-burn-ht none)
    success (begin 
              (increment-sc-delegated-balance amount-ustx)
              (map-set 
                user-data 
                  {address: tx-sender} 
                  {
                    is-in-pool: (default-to false (get is-in-pool (map-get? user-data {address: tx-sender}))),                    
                    delegated-balance: amount-ustx, 
                    locked-balance: (default-to u0 (get locked-balance (map-get? user-data {address: tx-sender}))),
                    until-burn-ht: until-burn-ht})
              (print "sc delegated balance")
              (print (var-get sc-delegated-balance))
              (ok success))
    error (err (* u1000 (to-uint error))))))

(define-private (lock-delegated-stx (user principal))
(let ((start-burn-ht (+ burn-block-height u1))
      (pox-address (var-get pool-pox-address))
      (buffer-amount u0)
      (user-account (stx-account user))
      (allowed-amount (min (get-delegated-amount user) (+ (get locked user-account) (get unlocked user-account))))
      (amount-ustx (if (> allowed-amount buffer-amount) (- allowed-amount buffer-amount) allowed-amount)))
  (asserts! (var-get active) err-pox-address-deactivated)
  (match (contract-call? 'SP000000000000000000002Q6VF78.pox-3 delegate-stack-stx
            user amount-ustx
            pox-address start-burn-ht u1)
    stacker-details 
      (begin 
        (map-set 
          user-data 
            {address: user} 
            {
              is-in-pool: 
                (default-to false (get is-in-pool (map-get? user-data {address: user}))),
              delegated-balance: 
                (default-to u0 (get delegated-balance (map-get? user-data {address: user}))),
              locked-balance: (get lock-amount stacker-details),
              until-burn-ht: 
                  (some (get unlock-burn-height stacker-details))})
        (increment-sc-locked-balance (get lock-amount stacker-details))
        (ok stacker-details))

      error (if (is-eq error 3) ;; check whether user is already stacked
              (delegate-stack-extend-increase user amount-ustx pox-address start-burn-ht)
              (err (* u1000 (to-uint error)))))))

(define-private (delegate-stack-extend-increase (user principal)
                  (amount-ustx uint)
                  (pox-address {hashbytes: (buff 32), version: (buff 1)})
                  (start-burn-ht uint))
(let ((status (stx-account user)))
  (asserts! (>= amount-ustx (get locked status)) err-decrease-forbidden)
  (match (contract-call? 'SP000000000000000000002Q6VF78.pox-3 delegate-stack-extend
          user pox-address u1)
    success (begin 
            (print "success")
            (print success)
            (map-set user-data 
                    {address: user} 
                    {
                    is-in-pool: 
                      (default-to false (get is-in-pool (map-get? user-data {address: user}))),
                    delegated-balance: 
                      (default-to u0 (get delegated-balance (map-get? user-data {address: user}))), 
                    locked-balance: 
                      (default-to u0 (get locked-balance (map-get? user-data {address: user}))),
                    until-burn-ht: 
                      (some (+ (default-to u0 (default-to (some u0) (get until-burn-ht (map-get? user-data {address: user})))) REWARD_CYCLE_LENGTH))
                    })
            (if (> amount-ustx (get locked status))          
              (match (contract-call? 'SP000000000000000000002Q6VF78.pox-3 delegate-stack-increase 
                user 
                pox-address 
                (- 
                  amount-ustx 
                  (default-to u0 (get locked-balance (map-get? user-data {address: tx-sender})))))
                success-increase (begin
                                  (print "success-increase")
                                  (print success-increase)
                                  (map-set user-data 
                                    {address: user} 
                                    {
                                    is-in-pool:
                                      (default-to false (get is-in-pool (map-get? user-data {address: user}))),
                                    delegated-balance: 
                                      (default-to u0 (get delegated-balance (map-get? user-data {address: user}))), 
                                    locked-balance: (get total-locked success-increase),
                                    until-burn-ht:
                                      (default-to none (get until-burn-ht (map-get? user-data {address: user})))
                                    })
                                  (increment-sc-locked-balance 
                                    (- amount-ustx 
                                      (default-to u0 (get locked-balance (map-get? user-data {address: user})))))
                                  (ok {lock-amount: (get total-locked success-increase),
                                      stacker: user,
                                      unlock-burn-height: (get unlock-burn-height success)}))
                error-increase (begin (print "error-increase") (err (* u1000000000 (to-uint error-increase)))))
              (ok {
                    lock-amount: (get locked status),
                    stacker: user,
                    unlock-burn-height: (get unlock-burn-height success)})))
    error (err (* u1000000 (to-uint error))))))

;; Rewards transferring functions

(define-private (transfer-rewards-all-stackers (stackers-list-before-cycle (list 300 principal)))
(map transfer-reward-one-stacker stackers-list-before-cycle))

(define-private (transfer-reward-one-stacker (stacker principal)) 
(let (
      (reward 
        (unwrap! (preview-exchange-reward 
          (default-to u0 
            (get reward 
              (map-get? burn-block-rewards { burn-height: (var-get burn-block-to-distribute-rewards)}))) 
          u5) err-cant-unwrap-exchange-preview))
      (stacker-weight 
        (default-to u0 
          (get weight-percentage 
            (map-get? stacker-weights-per-reward-cycle {stacker: stacker, reward-cycle: (var-get reward-cycle-to-distribute-rewards)}))))
      (stacker-reward (/ (* stacker-weight reward) ONE-6))) 
        (if (> stacker-weight u0) 
          (match (as-contract (stx-transfer? stacker-reward tx-sender stacker))
            success 
              (begin 
                (if 
                  (not (check-can-decrement-reserved-balance stacker-reward))
                  (decrement-sc-owned-balance stacker-reward)
                  (decrement-sc-reserved-balance stacker-reward)) 
                (ok true))
            error (err error)) 
          (ok false))))


(define-private (preview-exchange-reward (sats-amount uint) (slippeage uint)) 
(contract-call? .bridge-contract swap-preview 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx sats-amount slippeage))

;; Weight calculation functions

;; calculating one stacker's weight inside pool based on his balances
(define-private (weight-calculator (stacker principal) (stacker-locked uint) (total-locked uint) (liquidity-provider-locked uint)) 
(begin 
  (asserts! (> (+ total-locked liquidity-provider-locked) u0) err-no-locked-funds) 
  (ok (/ (* stacker-locked ONE-6) (+ total-locked liquidity-provider-locked)))))

(define-private (calculate-all-stackers-weights (stackers-list-before-cycle (list 300 principal)) (next-reward-cycle uint))
(begin 
  (map calculate-one-stacker-weight stackers-list-before-cycle)
  (map-set calculated-weights-reward-cycles {reward-cycle: next-reward-cycle} {calculated: true})
  (ok true)))

;; each stacker will have a weight inside the pool which will be used when distributing rewards
(define-private (calculate-one-stacker-weight (stacker principal))
(let ((last-burn-block-before-reward-cycle 
        (- 
          (contract-call? 'SP000000000000000000002Q6VF78.pox-3 reward-cycle-to-burn-height (var-get reward-cycle-to-calculate-weight)) 
          u1))
      ;; total locked by pool
      (total-locked-at-reward-cycle 
        (var-get sc-locked-balance))
      ;; total reserved by liquidity provider
      (liquidity-provider-reserved-at-reward-cycle 
        (var-get sc-reserved-balance))
      ;; total locked by a stacker
      (stacker-locked-at-reward-cycle 
        (default-to u0 (get locked-balance (map-get? user-data {address: stacker}))))
      (liquidity-provider-contribution (+ liquidity-provider-reserved-at-reward-cycle stacker-locked-at-reward-cycle))
      ;; the weight calculator result for the given stacker
      (weight-calculator-result 
        (if 
          (is-eq stacker (var-get liquidity-provider)) 
          (weight-calculator 
            stacker 
            liquidity-provider-contribution
            total-locked-at-reward-cycle 
            liquidity-provider-reserved-at-reward-cycle)
          (weight-calculator 
            stacker 
            stacker-locked-at-reward-cycle 
            total-locked-at-reward-cycle 
            liquidity-provider-reserved-at-reward-cycle))))
    ;; register the stacker's weight for a given reward cycle using a map
    (map-set stacker-weights-per-reward-cycle 
      {stacker: stacker, reward-cycle: (var-get reward-cycle-to-calculate-weight)} 
      {weight-percentage: 
        (if 
          (not (is-err weight-calculator-result)) 
          (unwrap-panic weight-calculator-result) 
          u0)
      })))


;; check if pool pox address has won the rewards for a given burn height and store the reward if true
(define-private (check-won-block-rewards (burn-height uint)) 
(let ((reward-pox-addr-list (default-to (list ) (get addrs (get-burn-block-info? pox-addrs burn-height))))) 
  (if 
    (is-some 
      (index-of? reward-pox-addr-list (var-get pool-pox-address))) 
    (begin 
      (register-block-reward burn-height)
      true) 
    false)))

;; store the reward for a given block using a map
(define-private (register-block-reward (burn-height uint)) 
(map-set burn-block-rewards {burn-height: burn-height} {reward: (default-to u0 (get payout (get-burn-block-info? pox-addrs burn-height)))}))

(define-private (remove-stacker-stackers-list (address principal)) (not (is-eq tx-sender address)))

(define-private (increment-sc-delegated-balance (amount-ustx uint)) 
(var-set sc-delegated-balance (+ (var-get sc-delegated-balance) amount-ustx)))

(define-private (increment-sc-locked-balance (amount-ustx uint)) 
(var-set sc-locked-balance (+ (var-get sc-locked-balance) amount-ustx)))

(define-private (decrement-sc-delegated-balance (amount-ustx uint)) 
(var-set sc-delegated-balance (- (var-get sc-delegated-balance) amount-ustx)))

(define-private (decrement-sc-locked-balance (amount-ustx uint)) 
(var-set sc-locked-balance (- (var-get sc-locked-balance) amount-ustx)))

(define-private (decrement-sc-reserved-balance (amount-ustx uint)) 
(var-set sc-reserved-balance (- (var-get sc-reserved-balance) amount-ustx)))

(define-private (decrement-sc-owned-balance (amount-ustx uint)) 
(var-set sc-owned-balance (- (var-get sc-owned-balance) amount-ustx)))

(define-private (check-can-decrement-delegated-balance (amount-ustx uint)) 
(if 
  (< 
    (var-get sc-delegated-balance) 
    amount-ustx) 
  false
true))

(define-private (check-can-decrement-locked-balance (amount-ustx uint)) 
(if 
  (< 
    (var-get sc-locked-balance) 
    amount-ustx) 
  false
true))

(define-private (check-can-decrement-reserved-balance (amount-ustx uint)) 
(if 
  (< 
    (var-get sc-reserved-balance) 
    amount-ustx) 
  false
true))

(define-private (check-can-decrement-total-balance (amount-ustx uint)) 
(if 
  (< 
    (var-get sc-total-balance) 
    amount-ustx) 
  false
true))

(define-private (check-can-decrement-owned-balance (amount-ustx uint)) 
(if 
  (< 
    (var-get sc-owned-balance) 
    amount-ustx) 
  false
true))

(define-private (min (amount-1 uint) (amount-2 uint))
  (if (< amount-1 amount-2)
    amount-1
    amount-2))

(define-private (get-next-reward-cycle) 
(+ (contract-call? 'SP000000000000000000002Q6VF78.pox-3 burn-height-to-reward-cycle burn-block-height) u1))

;; Read-only helper functions

(define-read-only (get-stx-account)
(stx-account tx-sender))

(define-read-only (get-pool-members) 
(var-get stackers-list))

(define-read-only (check-caller-allowed)
  (or (is-eq tx-sender contract-caller)
    (let ((caller-allowed
            ;; if not in the caller map, return false
            (unwrap! 
              (map-get? allowance-contract-callers
                { sender: tx-sender, contract-caller: contract-caller})
            false))
          (expires-at
            ;; if until-burn-ht not set, then return true (because no expiry)
            (unwrap! (get until-burn-ht caller-allowed) true)))
      ;; is the caller allowance still valid
      (< burn-block-height expires-at))))

(define-read-only (is-in-pool) 
(default-to false (get is-in-pool (map-get? user-data {address: tx-sender}))))

(define-read-only (get-stacker-weight (stacker principal) (reward-cycle uint)) 
(get weight-percentage (map-get? stacker-weights-per-reward-cycle {stacker: stacker, reward-cycle: reward-cycle})))

(define-read-only (get-SC-total-balance) 
(var-get sc-total-balance))

(define-read-only (get-SC-owned-balance) 
(var-get sc-owned-balance))

(define-read-only (get-SC-locked-balance)
(var-get sc-locked-balance))

(define-read-only (get-SC-reserved-balance) 
(var-get sc-reserved-balance))

(define-read-only (get-user-data (user principal)) 
(map-get? user-data {address: user}))

(define-read-only (check-pool-SC-pox-2-allowance)
(is-some (contract-call? 'SP000000000000000000002Q6VF78.pox-3 get-allowance-contract-callers tx-sender pool-contract)))

(define-read-only (get-pox-addr-indices (reward-cycle uint))
(map-get? pox-addr-indices reward-cycle))

(define-read-only (get-block-rewards (burn-height uint)) 
(ok (get-burn-block-info? pox-addrs burn-height)))

(define-read-only (can-lock-now (cycle uint))
(> burn-block-height (+ (contract-call? 'SP000000000000000000002Q6VF78.pox-3 reward-cycle-to-burn-height cycle) half-cycle-length)))

(define-read-only (get-delegated-amount (user principal))
(default-to u0 (get amount-ustx (contract-call? 'SP000000000000000000002Q6VF78.pox-3 get-delegation-info user))))

(define-read-only (get-liquidity-provider) 
(var-get liquidity-provider))

(define-read-only (get-amount-rewarded) 
(var-get amount-rewarded))

(define-read-only (get-blocks-rewarded) 
(var-get blocks-rewarded))

(define-read-only (get-stacked-this-cycle) 
(var-get sc-locked-balance))

(define-private (check-is-liquidity-provider (address principal)) 
(is-eq address (var-get liquidity-provider)))

(define-private (check-is-stacker (address principal)) 
(default-to false (get is-in-pool (map-get? user-data {address: address}))))

(define-read-only (get-address-status (address principal))
(if (check-is-liquidity-provider address)  
  (ok "is-provider")
  (if (check-is-stacker address)
    (ok "is-stacker")
    (ok "is-none"))))

(define-read-only (calculate-extra-reserved-funds) 
;; subtract the potential return from the total reserved balance and get the extra reserved balance
(- 
  (var-get sc-reserved-balance) 
    (/ 
      (var-get sc-locked-balance) 
      (var-get return-div))))

(define-read-only (can-withdraw-extra-reserved-now) 
;; liquidity provider can only withdraw extra reserved balance within the last 10 blocks of a reward cycle
(let ((mod-burn-height (mod burn-block-height REWARD_CYCLE_LENGTH))
      (start-value (- REWARD_CYCLE_LENGTH u10))
      (end-value (- REWARD_CYCLE_LENGTH u1))) 
  (and (>= mod-burn-height start-value) (<= mod-burn-height end-value))))

(define-read-only (get-return) 
(var-get return-div))

(define-read-only (get-minimum-deposit-liquidity-provider) 
(var-get minimum-deposit-amount-liquidity-provider))

(define-read-only (was-block-claimed (rewarded-burn-block uint))
(map-get? already-rewarded {burn-block-height: rewarded-burn-block}))
