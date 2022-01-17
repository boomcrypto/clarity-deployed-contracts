(impl-trait .trait-ownable.ownable-trait)
(use-trait ft-trait .trait-sip-010.sip-010-trait)

;; alex-reserve-pool

(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-TRANSFER-FAILED (err u3000))
(define-constant ERR-USER-ALREADY-REGISTERED (err u10001))
(define-constant ERR-USER-ID-NOT-FOUND (err u10003))
(define-constant ERR-ACTIVATION-THRESHOLD-REACHED (err u10004))
(define-constant ERR-CONTRACT-NOT-ACTIVATED (err u10005))
(define-constant ERR-STAKING-NOT-AVAILABLE (err u10015))
(define-constant ERR-CANNOT-STAKE (err u10016))
(define-constant ERR-REWARD-CYCLE-NOT-COMPLETED (err u10017))
(define-constant ERR-AMOUNT-EXCEED-RESERVE (err u2024))
(define-constant ERR-INVALID-TOKEN (err u2026))

(define-constant ONE_8 (pow u10 u8)) ;; 8 decimal places

(define-data-var contract-owner principal tx-sender)
(define-map approved-contracts principal bool)

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

(define-public (set-contract-owner (owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (ok (var-set contract-owner owner))
  )
)

(define-private (check-is-approved (sender principal))
  (ok (asserts! (or (default-to false (map-get? approved-contracts sender)) (is-eq sender (var-get contract-owner))) ERR-NOT-AUTHORIZED))
)

(define-public (add-approved-contract (new-approved-contract principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (map-set approved-contracts new-approved-contract true)
    (ok true)
  )
)

(define-map reserve principal uint)

;; @des get-balance 
;; @params token
;; @returns uint
(define-read-only (get-balance (token principal))
  (default-to u0 (map-get? reserve token))
)

;; @desc add-to-balance 
;; @params token 
;; @params amount 
;; @returns (response bool)
(define-public (add-to-balance (token principal) (amount uint))
  (begin
    (try! (check-is-approved tx-sender))
    (ok (map-set reserve token (+ amount (get-balance token))))
  )
)

;; @desc remove-from-balance 
;; @params token 
;; @params amount
;; @returns (response bool)
(define-public (remove-from-balance (token principal) (amount uint))
  (begin
    (try! (check-is-approved tx-sender))
    (asserts! (<= amount (get-balance token)) ERR-AMOUNT-EXCEED-RESERVE)
    (ok (map-set reserve token (- (get-balance token) amount)))
  )
)

;; STAKING CONFIGURATION
(define-map approved-tokens principal bool)

(define-constant MAX-REWARD-CYCLES u32)
(define-constant REWARD-CYCLE-INDEXES (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31))

;; how long a reward cycle is
(define-data-var reward-cycle-length uint u525)

;; At a given reward cycle, what is the total amount of tokens staked
(define-map staking-stats-at-cycle 
  {
    token: principal,
    reward-cycle: uint
  }
  uint
)

;; At a given reward cycle and user ID:
;; - what is the total tokens staked?
;; - how many tokens should be returned? (based on staking period)
(define-map staker-at-cycle
  {
    token: principal,
    reward-cycle: uint,
    user-id: uint
  }
  {
    amount-staked: uint,
    to-return: uint
  }
)

(define-data-var activation-delay uint u150)
(define-data-var activation-threshold uint u20)

;; activation-block for each stake-able token
(define-map activation-block principal uint)

;; users-nonce for each stake-able token
(define-map users-nonce principal uint)

;; store user principal by user id
(define-map users 
  {
    token: principal,
    user-id: uint
  }
  principal
)
;; store user id by user principal
(define-map user-ids 
  {
    token: principal,
    user: principal
  }
  uint
)

;; @desc get-reward-cycle-length
;; @returns uint
(define-read-only (get-reward-cycle-length)
  (var-get reward-cycle-length)
)

;; @desc is-token-approved
;; @params token
;; @returns bool
(define-read-only (is-token-approved (token principal))
  (is-some (map-get? approved-tokens token))
)

;; @desc add-token 
;; @params token
;; @returns (response bool)
(define-public (add-token (token principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (map-set approved-tokens token true)
    (map-set users-nonce token u0)
    (ok true)
  )
)

;; @desc get-activation-block-or-default 
;; @params token
;; @returns uint; Stacks block height registration was activated at plus activationDelay
(define-read-only (get-activation-block-or-default (token principal))
  (default-to u100000000 (map-get? activation-block token))
)

;; @desc get-activation-delay
;; @returns uint
(define-read-only (get-activation-delay)
  (var-get activation-delay)
)

;; @desc set-activation-delay 
;; @params new-activation-delay
;; @returns (response bool)
(define-public (set-activation-delay (new-activation-delay uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (ok (var-set activation-delay new-activation-delay))
  )
)

;; @desc get-activation-threshold
;; @returns uint
(define-read-only (get-activation-threshold)
  (var-get activation-threshold)
)

;; @desc set-activation-threshold 
;; @restricted Contract-Owner
;; @params new-activation-threshold
;; @returns (response bool)
(define-public (set-activation-threshold (new-activation-threshold uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (ok (var-set activation-threshold new-activation-threshold))
  )
)

;; returns the total staked tokens for a given reward cycle
;; @desc get-staking-stats-at-cycle 
;; @params token 
;; @params reward-cycle
;; @returns (optional (tuple))
(define-read-only (get-staking-stats-at-cycle (token principal) (reward-cycle uint))
  (map-get? staking-stats-at-cycle {token: token, reward-cycle: reward-cycle})
)

;; returns the total staked tokens for a given reward cycle
;; or, zero
;; @desc get-staking-stats-at-cycle-or-default
;; @params token
;; @params reward-cycle
;; @returns uint
(define-read-only (get-staking-stats-at-cycle-or-default (token principal) (reward-cycle uint))
  (default-to u0 (get-staking-stats-at-cycle token reward-cycle))
)

;; @desc get-user-id
;; @params token
;; @params user
;; @returns (some user-id) or none
(define-read-only (get-user-id (token principal) (user principal))
  (map-get? user-ids {token: token, user: user})
)

;; @desc get-user
;; @params token
;; @params user-id
;; @returns (some user-principal) or none
(define-read-only (get-user (token principal) (user-id uint))
  (map-get? users {token: token, user-id: user-id})
)

;; returns (some number of registered users), used for activation and tracking user IDs, or none
;; @desc get-registered-users-nonce 
;; @params token 
;; @returns (optional (tuple))
(define-read-only (get-registered-users-nonce (token principal))
  (map-get? users-nonce token)
)

;; @desc get-registered-users-nonce-or-default 
;; @params token
;; @returns uint
(define-read-only (get-registered-users-nonce-or-default (token principal))
  (default-to u0 (get-registered-users-nonce token))
)

;; returns user ID if it has been created, or creates and returns new ID
;; @desc get-or-create-user-id 
;; @params token 
;; @params user
;; @returns (response bool)/ (optional (tuple))
(define-private (get-or-create-user-id (token principal) (user principal))
  (match
    (map-get? user-ids {token: token, user: user})
    value value
    (let
      (
        (new-id (+ u1 (get-registered-users-nonce-or-default token)))
      )
      (map-insert users {token: token, user-id: new-id} user)
      (map-insert user-ids {token: token, user: user} new-id)
      (map-set users-nonce token new-id)
      new-id
    )
  )
)

;; registers users that signal activation of contract until threshold is met
;; @desc register-user
;; @params token
;; @params memo; expiry
;; @returns (response bool)
(define-public (register-user (token principal) (memo (optional (string-utf8 50))))
  (let
    (
      (new-id (+ u1 (get-registered-users-nonce-or-default token)))
      (threshold (var-get activation-threshold))
    )
    (asserts! (default-to false (map-get? approved-tokens token)) ERR-INVALID-TOKEN)
    (asserts! (is-none (map-get? user-ids {token: token, user: tx-sender})) ERR-USER-ALREADY-REGISTERED)

    (if (is-some memo) (print memo) none)

    (get-or-create-user-id token tx-sender)

    (if (is-eq new-id threshold)
      (begin
        (map-set activation-block token (+ block-height (var-get activation-delay)))
        (ok true)
      )
      (ok true)
    )
  )
)

;; @desc get-staker-at-cycle 
;; @params token 
;; @params reward-cycl
;; @params user-id 
;; @returns (optional (tuple))
(define-read-only (get-staker-at-cycle (token principal) (reward-cycle uint) (user-id uint))
  (map-get? staker-at-cycle { token: token, reward-cycle: reward-cycle, user-id: user-id })
)
;; @desc get-staker-at-cycle-or-default 
;; @params token 
;; @params reward-cycle
;; @params user-id
;; @returns (optional (tuple))
(define-read-only (get-staker-at-cycle-or-default (token principal) (reward-cycle uint) (user-id uint))
  (default-to { amount-staked: u0, to-return: u0 }
    (map-get? staker-at-cycle { token: token, reward-cycle: reward-cycle, user-id: user-id }))
)

;; get the reward cycle for a given Stacks block height
;; @desc get-reward-cycle 
;; @params token 
;; @params stacks-height
;; @returns response
(define-read-only (get-reward-cycle (token principal) (stacks-height uint))
  (let
    (
      (first-staking-block (get-activation-block-or-default token))
      (rcLen (var-get reward-cycle-length))
    )
    (if (>= stacks-height first-staking-block)
      (some (/ (- stacks-height first-staking-block) rcLen))
      none
    )
  )
)

;; determine if staking is active in a given cycle
;; @desc staking-active-at-cycle 
;; @params token 
;; @params reward-cycle
;; @response bool
(define-read-only (staking-active-at-cycle (token principal) (reward-cycle uint))
  (is-some (map-get? staking-stats-at-cycle {token: token, reward-cycle: reward-cycle}))
)

;; get the first Stacks block height for a given reward cycle.
;; @desc get-first-stacks-block-in-reward-cycle
;; @params token 
;; @params reward-cycle 
;; @returns uint
(define-read-only (get-first-stacks-block-in-reward-cycle (token principal) (reward-cycle uint))
  (+ (get-activation-block-or-default token) (* (var-get reward-cycle-length) reward-cycle))
)

;; getter for get-entitled-staking-reward that specifies block height
;; @desc get-staking-reward
;; @params token
;; @params user-id
;; @params target-cycle
;; @returns uint
(define-read-only (get-staking-reward (token principal) (user-id uint) (target-cycle uint))
  (get-entitled-staking-reward token user-id target-cycle block-height)
)

;; @desc get-entitled-staking-reward
;; @params token
;; @params user-id
;; @params target-cycle
;; @params stacks-height
;; @returns uint
(define-private (get-entitled-staking-reward (token principal) (user-id uint) (target-cycle uint) (stacks-height uint))
  (let
    (
      (total-staked-this-cycle (get-staking-stats-at-cycle-or-default token target-cycle))
      (user-staked-this-cycle (get amount-staked (get-staker-at-cycle-or-default token target-cycle user-id)))
    )
    (match (get-reward-cycle token stacks-height)
      current-cycle
      (mul-down (get-coinbase-amount-or-default token target-cycle) (div-down user-staked-this-cycle total-staked-this-cycle))
      u0
    )
  )
)

;; STAKING ACTIONS

;; @desc stake-tokens
;; @params token-trait; ft-trait
;; @params amount-token
;; @params lock-period
;; @response (ok response)
(define-public (stake-tokens (token-trait <ft-trait>) (amount-token uint) (lock-period uint))
  (begin
    (asserts! (default-to false (map-get? approved-tokens (contract-of token-trait))) ERR-INVALID-TOKEN)
    (stake-tokens-at-cycle token-trait tx-sender (get-or-create-user-id (contract-of token-trait) tx-sender) amount-token block-height lock-period)
  )
)

;; @desc stake-tokens-at-cycle
;; @params token-trait; ft-trait
;; @params user
;; @params user-id
;; @params amount-token
;; @params start-height 
;; @params lock-period
;; @returns (ok response)
(define-private (stake-tokens-at-cycle (token-trait <ft-trait>) (user principal) (user-id uint) (amount-token uint) (start-height uint) (lock-period uint))
  (let
    (
      (token (contract-of token-trait))
      (current-cycle (unwrap! (get-reward-cycle token start-height) ERR-STAKING-NOT-AVAILABLE))
      (target-cycle (+ u1 current-cycle))
      (commitment {
        token: token,
        staker-id: user-id,
        amount: amount-token,
        first: target-cycle,
        last: (+ target-cycle lock-period)
      })
    )   
    (asserts! (default-to false (map-get? approved-tokens (contract-of token-trait))) ERR-INVALID-TOKEN) 
    (asserts! (>= block-height (get-activation-block-or-default token)) ERR-CONTRACT-NOT-ACTIVATED)
    (asserts! (and (> lock-period u0) (<= lock-period MAX-REWARD-CYCLES)) ERR-CANNOT-STAKE)
    (asserts! (> amount-token u0) ERR-CANNOT-STAKE)
    (unwrap! (contract-call? token-trait transfer-fixed amount-token tx-sender .alex-vault none) ERR-TRANSFER-FAILED)
    (try! (as-contract (add-to-balance token amount-token)))
    (match (fold stake-tokens-closure REWARD-CYCLE-INDEXES (ok commitment))
      ok-value (ok true)
      err-value (err err-value)
    )
  )
)

;; @desc stake-tokens-closure
;; @params reward-cycle-idx
;; @returns bool/error
(define-private (stake-tokens-closure (reward-cycle-idx uint)
  (commitment-response (response 
    {
      token: principal,
      staker-id: uint,
      amount: uint,
      first: uint,
      last: uint
    }
    uint
  )))

  (match commitment-response
    commitment 
    (let
      (
        (token (get token commitment))
        (staker-id (get staker-id commitment))
        (amount-token (get amount commitment))
        (first-cycle (get first commitment))
        (last-cycle (get last commitment))
        (target-cycle (+ first-cycle reward-cycle-idx))
        (this-staker-at-cycle (get-staker-at-cycle-or-default token target-cycle staker-id))
        (amount-staked (get amount-staked this-staker-at-cycle))
        (to-return (get to-return this-staker-at-cycle))
      )
      (begin
        (if (and (>= target-cycle first-cycle) (< target-cycle last-cycle))
          (begin
            (if (is-eq target-cycle (- last-cycle u1))
              (set-tokens-staked token staker-id target-cycle amount-token amount-token)
              (set-tokens-staked token staker-id target-cycle amount-token u0)
            )
            true
          )
          false
        )
        commitment-response
      )
    )
    err-value commitment-response
  )
)

;; @desc set-tokens-staked
;; @params token
;; @params user-id
;; @params target-cycle
;; @params amount-staked
;; @params to-return
;; @returns (response bool)
(define-private (set-tokens-staked (token principal) (user-id uint) (target-cycle uint) (amount-staked uint) (to-return uint))
  (let
    (
      (this-staker-at-cycle (get-staker-at-cycle-or-default token target-cycle user-id))
    )
    (map-set staking-stats-at-cycle {token: token, reward-cycle: target-cycle} (+ amount-staked (get-staking-stats-at-cycle-or-default token target-cycle)))
    (map-set staker-at-cycle
      {
        token: token,
        reward-cycle: target-cycle,
        user-id: user-id
      }
      {
        amount-staked: (+ amount-staked (get amount-staked this-staker-at-cycle)),
        to-return: (+ to-return (get to-return this-staker-at-cycle))
      }
    )
  )
)

;; STAKING REWARD CLAIMS

;; calls function to claim staking reward in active logic contract
;; @desc claim-staking-reward
;; @params token-trait; ft-trait
;; @params target-cycle
;; @returns (response tuple)
(define-public (claim-staking-reward (token-trait <ft-trait>) (target-cycle uint))
  (begin
    (asserts! (default-to false (map-get? approved-tokens (contract-of token-trait))) ERR-INVALID-TOKEN)
    (claim-staking-reward-at-cycle token-trait tx-sender block-height target-cycle)
  )
)

;; @desc claim-staking-reward-at-cycle
;; @params token-trait; ft-trait
;; @params user
;; @params stacks-height
;; @params target-cycle
;; @returns (response tuple)
(define-private (claim-staking-reward-at-cycle (token-trait <ft-trait>) (user principal) (stacks-height uint) (target-cycle uint))
  (let
    (
      (token (contract-of token-trait))
      (current-cycle (unwrap! (get-reward-cycle token stacks-height) ERR-STAKING-NOT-AVAILABLE))
      (user-id (unwrap! (get-user-id token user) ERR-USER-ID-NOT-FOUND))
      (entitled-token (get-entitled-staking-reward token user-id target-cycle stacks-height))
      (to-return (get to-return (get-staker-at-cycle-or-default token target-cycle user-id)))
    )
    (asserts! (default-to false (map-get? approved-tokens token)) ERR-INVALID-TOKEN)
    (asserts! (> current-cycle target-cycle) ERR-REWARD-CYCLE-NOT-COMPLETED)
    ;; disable ability to claim again
    (map-set staker-at-cycle
      {
        token: token,
        reward-cycle: target-cycle,
        user-id: user-id
      }
      {
        amount-staked: u0,
        to-return: u0
      }
    )
    ;; send back tokens if user was eligible
    (and (> to-return u0) (as-contract (try! (contract-call? .alex-vault transfer-ft token-trait to-return user))))
    (and (> to-return u0) (as-contract (try! (remove-from-balance (contract-of token-trait) to-return))))
    ;; send back rewards if user was eligible
    (and (> entitled-token u0) (as-contract (try! (contract-call? .token-t-alex mint-fixed entitled-token user))))
    (ok { to-return: to-return, entitled-token: entitled-token })
  )
)

;; TOKEN CONFIGURATION

(define-data-var token-halving-cycle uint u100)

;; @desc get-token-halving-cycle
;; @returns uint
(define-read-only (get-token-halving-cycle)
  (var-get token-halving-cycle)
)

;; @desc set-token-halving-cycle
;; @params new-token-halving-cycle
;; @returns (response bool)
(define-public (set-token-halving-cycle (new-token-halving-cycle uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (var-set token-halving-cycle new-token-halving-cycle)
    (set-coinbase-thresholds)
    (ok true)
  )
)

;; store block height at each halving, set by register-user in core contract
(define-data-var coinbase-threshold-1 uint (var-get token-halving-cycle))
(define-data-var coinbase-threshold-2 uint (* u2 (var-get token-halving-cycle)))
(define-data-var coinbase-threshold-3 uint (* u3 (var-get token-halving-cycle)))
(define-data-var coinbase-threshold-4 uint (* u4 (var-get token-halving-cycle)))
(define-data-var coinbase-threshold-5 uint (* u5 (var-get token-halving-cycle)))

;; @desc set-coinbase-thresholds
;; @returns (response bool)
(define-private (set-coinbase-thresholds)
  (begin
    (var-set coinbase-threshold-1 (var-get token-halving-cycle))
    (var-set coinbase-threshold-2 (* u2 (var-get token-halving-cycle)))
    (var-set coinbase-threshold-3 (* u3 (var-get token-halving-cycle)))
    (var-set coinbase-threshold-4 (* u4 (var-get token-halving-cycle)))
    (var-set coinbase-threshold-5 (* u5 (var-get token-halving-cycle)))
  )
)

;; return coinbase thresholds if contract activated
;; @desc get-coinbase-thresholds
;; @returns (response tuple)
(define-read-only (get-coinbase-thresholds)
  (ok {
      coinbase-threshold-1: (var-get coinbase-threshold-1),
      coinbase-threshold-2: (var-get coinbase-threshold-2),
      coinbase-threshold-3: (var-get coinbase-threshold-3),
      coinbase-threshold-4: (var-get coinbase-threshold-4),
      coinbase-threshold-5: (var-get coinbase-threshold-5)
  })
)

;; token <> coinbase-amounts
(define-map coinbase-amounts 
  principal
  {
    coinbase-amount-1: uint,
    coinbase-amount-2: uint,
    coinbase-amount-3: uint,
    coinbase-amount-4: uint,
    coinbase-amount-5: uint
  }
)

;; @desc set-coinbase-amount
;; @restricted Contract-Owner
;; @params token
;; @params coinbase-1
;; @params coinbase-2
;; @params coinbase-3
;; @params coinbase-4
;; @params coinbase-5
;; @returns (response bool)
(define-public (set-coinbase-amount (token principal) (coinbase-1 uint) (coinbase-2 uint) (coinbase-3 uint) (coinbase-4 uint) (coinbase-5 uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (map-set coinbase-amounts token 
      {
        coinbase-amount-1: coinbase-1,
        coinbase-amount-2: coinbase-2,
        coinbase-amount-3: coinbase-3,
        coinbase-amount-4: coinbase-4,
        coinbase-amount-5: coinbase-5
      }
    )
    (ok true)
  )
)

;; function for deciding how many tokens to mint, depending on when they were mined
;; @desc get-coinbase-amount-or-default
;; @params token
;; @params reward-cycle
;; @returns uint
(define-read-only (get-coinbase-amount-or-default (token principal) (reward-cycle uint))
  (let
    (
      (coinbase (default-to {
                              coinbase-amount-1: u0,
                              coinbase-amount-2: u0,
                              coinbase-amount-3: u0,
                              coinbase-amount-4: u0,
                              coinbase-amount-5: u0
                            } 
                            (map-get? coinbase-amounts token))
      )
    )
    ;; computations based on each halving threshold
    (asserts! (> reward-cycle (var-get coinbase-threshold-1)) (get coinbase-amount-1 coinbase))
    (asserts! (> reward-cycle (var-get coinbase-threshold-2)) (get coinbase-amount-2 coinbase))
    (asserts! (> reward-cycle (var-get coinbase-threshold-3)) (get coinbase-amount-3 coinbase))
    (asserts! (> reward-cycle (var-get coinbase-threshold-4)) (get coinbase-amount-4 coinbase))
    (asserts! (> reward-cycle (var-get coinbase-threshold-5)) (get coinbase-amount-5 coinbase))
    ;; default value after 5th halving
    u0
  )
)

;; @desc mul-down
;; @params a
;; @params b
;; @returns uint
(define-read-only (mul-down (a uint) (b uint))
    (/ (* a b) ONE_8)
)

;; @desc div-down
;; @params a
;; @params b
;; @returns uint
(define-read-only (div-down (a uint) (b uint))
  (if (is-eq a u0)
    u0
    (/ (* a ONE_8) b)
  )
)

;; @desc set-reward-cycle-length
;; @restricted Contract-Owner
;; @params new-reward-cycle-length
;; @returns (response bool)
(define-public (set-reward-cycle-length (new-reward-cycle-length uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (ok (var-set reward-cycle-length new-reward-cycle-length))
  )
)

;; contract initialisation
(map-set approved-contracts .collateral-rebalancing-pool true)  
(map-set approved-contracts .fixed-weight-pool true)
(map-set approved-contracts .yield-token-pool true)
(map-set approved-contracts (as-contract tx-sender) true)
(map-set approved-contracts .yield-collateral-rebalancing-pool true)
