(define-constant ONE_8 u100000000)
(define-constant ONE_6 u1000000)

;; ERRS

(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-PAUSED (err u1001))
(define-constant ERR-BELOW-MIN-STAKE (err u1002))
(define-constant ERR-ZERO-INTEREST-RATE (err u2000))
(define-constant ERR-ZERO-LOCK-DURATION (err u2001))
(define-constant ERR-ZERO-AMOUNT (err u2002))
(define-constant ERR-INSUFFICIENT-REWARD-BALANCE (err u2003))
(define-constant ERR-STAKE-RECORD-EXISTS (err u3000))
(define-constant ERR-INVALID-STAKE-RECORD (err u3001))
(define-constant ERR-NO-STAKE-FOUND (err u3002))
(define-constant ERR-STAKE-LOCK-EXPIRED (err u3003))
(define-constant ERR-STAKE-LOCK-NOT-EXPIRED (err u3004))
(define-constant ERR-STAKE-LOCK-PAID-OUT (err u3005))
(define-constant ERR-STAKE-SWITCH-NOT-ALLOWED (err u3006))

;; DATA MAPS AND VARS

(define-data-var contract-owner principal tx-sender)
(define-data-var staked-balance uint u0)
(define-data-var reward-balance uint u0)
(define-data-var staked-total uint u0)
(define-data-var total-reward uint u0)
(define-data-var total-participants uint u0)
(define-data-var lock-duration uint u0)
(define-data-var paused bool false)
(define-data-var minimum-stake uint u200000000000)

;; @desc map to store user staking data
(define-map deposit-map
    { user-addr: principal }
    {
        deposit-amount: uint,
        deposit-block: uint, 
        end-block: uint,
        lock-rewards: uint,
        stake-index: uint,
        paid: bool
    }
)

;; @desc map to store user staking status
(define-map has-staked {user-addr: principal} bool)

;; @desc map to store the stake rates for each period
(define-map stake-rates
  { stake-index: uint} 
  { 
    duration-in-blocks: uint,
    interest-rate: uint,
    block-stamp: uint
  }  
)

;; READ-ONLY CALLS

;; @desc is-paused: contract status
;; @returns (boolean)
(define-read-only (is-paused)
    (var-get paused)
)

;; @desc get-stake-record: gets the stake record of index
;; @params stake-index
;; @returns (response stake-record)
(define-read-only (get-stake-record (stake-index uint))
    (ok (unwrap! (get-stake-record-exists stake-index) ERR-INVALID-STAKE-RECORD))
)

;; @desc get-stake-record-exist: checks if stake record of index is set
;; @params stake-index
;; @returns (option stake-record)
(define-read-only (get-stake-record-exists (stake-index uint))
    (map-get? stake-rates { stake-index: stake-index }) 
)

;; @desc get-stake-staking-data: get user stake data
;; @params user-addr
;; @returns (response stake-data)
(define-read-only (get-user-staking-data (user-addr principal))
    (ok (unwrap! (get-user-staking-data-exists user-addr ) ERR-NO-STAKE-FOUND))
)

;; @desc get-stake-staking-data-exists: check if user stake data exists
;; @params user-addr
;; @returns (option stake-data)
(define-read-only (get-user-staking-data-exists (user-addr principal)) 
  (map-get? deposit-map {user-addr: user-addr})
)

;; @desc get-user-has-staked: check if user has active stake
;; @params user-addr
;; @returns (boolean)
(define-read-only (get-user-stake-has-staked (user-addr principal)) 
  (default-to false (map-get? has-staked {user-addr: user-addr}))
)

;; @desc calculate-rewards: calculate rewards  based on user staked amount 
;; @params user-addr
;; @returns (boolean)
(define-read-only (calculate-rewards (user-addr principal))
  (do-calculate user-addr (get end-block (try! (get-user-staking-data user-addr))))
)

;; @desc get-total-rewards
;; @returns (response uint)
(define-read-only (get-total-rewards)
  (ok (var-get total-reward))
)

;; @desc get-total-staked
;; @returns (response uint)
(define-read-only (get-total-staked) 
  (ok (var-get staked-total))
)

;; @desc get-min-stake
;; @returns (response uint)
(define-read-only (get-minimum-stake)
  (ok (var-get minimum-stake))
)


;; MANAGEMENT CALLS

;; @desc set-contract-owner: sets owner
;; @requirement only callable by current owner
;; @params owner
;; @returns (response boolean)
(define-public (set-contract-owner (owner principal))
  (begin
    (try! (check-is-owner)) 
    (ok (var-set contract-owner owner))
  )
)

;; @desc pause: updates contracts paused state
;; @requirement only callable by current owner
;; @params new-paused
;; @returns (response boolean)
(define-public (pause (new-paused bool))
    (begin 
        (try! (check-is-owner))
        (ok (var-set paused new-paused))
    )
)

;; @desc set-stake-record: sets staked record information (i.e stake interest and duration)
;; @requirement only callable by current owner
;; @params stake-index
;; @params interest-rate
;; @params duration-on-blocks
;; @returns (response boolean)
(define-public (set-stake-record (stake-index uint) (interest-rate uint) (duration-in-blocks uint))
  (begin
    (try! (check-is-owner))
    (asserts! (> interest-rate u0) ERR-ZERO-INTEREST-RATE)
    (asserts! (> duration-in-blocks u0) ERR-ZERO-LOCK-DURATION)
    (asserts! (is-none (get-stake-record-exists stake-index)) ERR-STAKE-RECORD-EXISTS)
    (map-set stake-rates {stake-index: stake-index} { interest-rate: interest-rate, duration-in-blocks: duration-in-blocks, block-stamp: block-height})
    (ok true)
  )
)

;; @desc add-rewards: increments staking reward balance
;; @requirement only callable by current owner
;; @params reward-amount
;; @returns (response boolean)
(define-public (add-rewards (reward-amount uint))
  (begin
    (asserts! (> reward-amount u0) ERR-ZERO-AMOUNT)
    (let
      (
        (total-reward_ (var-get total-reward))
        (reward-balance_ (var-get reward-balance))
      )
      (var-set total-reward (+ total-reward_ reward-amount))
      (var-set reward-balance (+ reward-balance_ reward-amount))  
    )
    ;; transfer memegoat to vault
    (try! (contract-call? .memegoatstx transfer-fixed (decimals-to-fixed reward-amount) tx-sender .memegoat-vault-v1 none))
    (ok true)
  )
)

;; @desc set-min-stake: sets min stake
;; @requirement only callable by current owner
;; @params amount
;; @returns (response boolean)
(define-public (set-min-stake (amount uint))
  (begin
    (try! (check-is-owner))
    (asserts! (> amount u0) ERR-ZERO-AMOUNT)
    (var-set minimum-stake amount)
    (ok true)
  )
)


;; PUBLIC CALLS

;; @desc stake: transfers amount to be staked.
;; @params amount
;; @returns (response boolean)
(define-public (stake (amount uint) (stake-index uint))
  (begin
    (asserts! (>= amount (var-get minimum-stake)) ERR-BELOW-MIN-STAKE)
    (asserts! (not (is-paused)) ERR-PAUSED)
    (try! (do-stake tx-sender amount stake-index))
    (ok true)
  )
)

;; @desc unstake: withdraws stake from contract
;; @requirement user has active stake in contract.
;; @returns (response boolean)
(define-public (unstake) 
  (begin
    (asserts! (not (is-paused)) ERR-PAUSED)
    (asserts! (get-user-stake-has-staked tx-sender) ERR-NO-STAKE-FOUND)
    (try! (do-withdraw-stake  tx-sender))
    (ok true)
  )
)

;; @desc unstake: withdraws stake from contract without rewards
;; @requirement user has active stake in contract.
;; @returns (response boolean)
(define-public (emergency-withdraw) 
  (begin
    (asserts! (not (is-paused)) ERR-PAUSED)
    (asserts! (get-user-stake-has-staked tx-sender) ERR-NO-STAKE-FOUND)
    (try! (do-emergency-withdraw tx-sender))
    (ok true)
  )
)

;; PRIVATE CALLS

(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)

(define-private (decimals-to-fixed (amount uint)) 
  (/ (* amount ONE_8) ONE_6)
)

(define-private (do-stake (user-addr principal) (amount uint) (stake-index uint))
  (begin
    (let
      ;; get variables
      (
        (has-stake (get-user-stake-has-staked user-addr))
        (stake-record (try! (get-stake-record stake-index)))
        (duration-in-blocks (get duration-in-blocks stake-record))
        (participants (var-get total-participants))
        (staked-balances (var-get staked-balance))
        (total-staked (var-get staked-total))
      )

     

      ;; check for stake
      (if has-stake
        (let
          ;; calculate rewards and update stake data
          (
            (user-stake (try! (get-user-staking-data user-addr)))
            (curr-stake-index (get stake-index user-stake))
            (deposit-amount (get deposit-amount user-stake))
            (stake-rewards (get lock-rewards user-stake))
            (end-block (get end-block user-stake))
            (new-rewards (+ (try! (do-calculate user-addr block-height)) stake-rewards))
            (user-stake-updated (merge user-stake {
              deposit-amount: (+ deposit-amount amount),
              deposit-block: block-height,
              end-block: (+ duration-in-blocks block-height),
              lock-rewards: new-rewards,
              })
            )
          )
          (asserts! (is-eq stake-index curr-stake-index) ERR-STAKE-SWITCH-NOT-ALLOWED)
          (asserts! (< block-height end-block) ERR-STAKE-LOCK-EXPIRED)
          (map-set deposit-map {user-addr: user-addr} user-stake-updated)
        )
        
        (begin
          ;; create new stake data for user
          (map-set has-staked { user-addr: user-addr } true)
          (map-set deposit-map 
            { user-addr: user-addr } 
            {deposit-amount: amount, deposit-block: block-height, end-block: (+ block-height duration-in-blocks), lock-rewards: u0, stake-index: stake-index, paid: false }
          )
          (var-set total-participants (+ participants u1))
        )
      )

      ;; transfer memegoat to vault
      (try! (contract-call? .memegoatstx transfer-fixed (decimals-to-fixed amount) user-addr .memegoat-vault-v1 none)) 

      ;; update stake balances 
      (var-set staked-balance (+ staked-balances amount))
      (var-set staked-total (+ total-staked amount))
    )
    (ok true)
  )
)


(define-private (do-withdraw-stake (user-addr principal))
  (begin 
    (let
      ;; get variables and calculate rewards
      (
        (participants (var-get total-participants))
        (staked-balance_ (var-get staked-balance))
        (user-stake (try! (get-user-staking-data user-addr)))
        (end-block (get end-block user-stake))
        (deposit-amount (get deposit-amount user-stake))
        (paid (get paid user-stake))
        (lock-rewards (get lock-rewards user-stake))
        (stake-rewards (try! (do-calculate user-addr end-block)))
        (total-rewards (+ stake-rewards lock-rewards))
        (amount-to-pay (+ deposit-amount total-rewards))
        (reward-balance_ (var-get reward-balance))
        (user-stake-updated (merge user-stake {
            paid: true,
            deposit-amount: u0,
            lock-rewards: u0,
          })
        )
      )

      ;; run checks 
      (asserts! (> block-height end-block) ERR-STAKE-LOCK-NOT-EXPIRED)
      (asserts! (not paid) ERR-STAKE-LOCK-PAID-OUT)
      (asserts! (< total-rewards reward-balance_ ) ERR-INSUFFICIENT-REWARD-BALANCE)

      ;; transfer token from vault
      (as-contract (try! (contract-call? .memegoat-vault-v1 transfer-ft .memegoatstx (decimals-to-fixed amount-to-pay) user-addr)))   

      ;; update balances and decrement participant
      (var-set staked-balance (- staked-balance_ deposit-amount))
      (var-set reward-balance (- reward-balance_ total-rewards))
      (var-set total-participants (- participants u1))

      ;; update user records
      (map-set has-staked {user-addr: user-addr} false)
      (map-set deposit-map {user-addr: user-addr} user-stake-updated)
   
    )
    (ok true)
  )
)

(define-private (do-emergency-withdraw (user-addr principal))
  (begin
    (let
      ;; get variables
      (
        (participants (var-get total-participants))
        (staked-balance_ (var-get staked-balance))
        (user-stake (try! (get-user-staking-data user-addr)))
        (end-block (get end-block user-stake))
        (amount (get deposit-amount user-stake))
        (paid (get paid user-stake))
        (user-stake-updated (merge user-stake {
            paid: true,
            deposit-amount: u0,
            lock-rewards: u0,
          })
        )
      )

      ;; run checks
      (asserts! (> block-height end-block) ERR-STAKE-LOCK-NOT-EXPIRED)
      (asserts! (not paid) ERR-STAKE-LOCK-PAID-OUT)

      ;; transfer token from vault
      (as-contract (try! (contract-call? .memegoat-vault-v1 transfer-ft .memegoatstx (decimals-to-fixed amount) user-addr)))  

      ;; update balances
      (var-set staked-balance (- staked-balance_ amount))
      (var-set total-participants (- participants u1))

      ;; update user records
      (map-set has-staked {user-addr: user-addr} false)
      (map-set deposit-map {user-addr: user-addr} user-stake-updated)
    )
    (ok true)
  )
)

(define-private (do-calculate (user-addr principal) (end-block uint))
  (begin
    ;; check for stake
    (if (get-user-stake-has-staked user-addr)
      (let
        ;; get variables
        (
          (user-stake (try! (get-user-staking-data user-addr)))
          (deposit-amount (get deposit-amount user-stake))
          (deposit-block (get deposit-block user-stake))
          (stake-index (get stake-index user-stake))
          (initial-lock-period (- (get end-block user-stake) deposit-block))
          (lock-period (- end-block deposit-block))
          (stake-record (try! (get-stake-record stake-index)))
        )
        ;; calculate rewards based on stake amount and interest
        (ok (/ (* lock-period deposit-amount (get interest-rate stake-record)) (* initial-lock-period u10000)))
      )
      (ok u0)
    )
  )
)