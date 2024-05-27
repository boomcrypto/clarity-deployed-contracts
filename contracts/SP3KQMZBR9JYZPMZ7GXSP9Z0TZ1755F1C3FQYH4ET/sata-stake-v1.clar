(use-trait ft-trait .trait-sip-010.sip-010-trait)

(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-USER-ID-NOT-FOUND (err u10003))
(define-constant ERR-STAKING-NOT-AVAILABLE (err u10015))
(define-constant ERR-INVALID-TOKEN (err u2026))
(define-constant ERR-CONTRACT-NOT-ACTIVATED (err u10005))
(define-constant ERR-CANNOT-STAKE (err u10016))
(define-constant ERR-TRANSFER-FAILED (err u3000))
(define-constant ERR-AMOUNT-EXCEED-RESERVE (err u2024))
(define-constant ERR-REWARD-CYCLE-NOT-COMPLETED (err u10017))

(define-constant MAX-REWARD-CYCLES u32)
(define-constant REWARD-CYCLE-INDEXES (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31))

(define-data-var contract-owner principal tx-sender)
(define-map approved-contracts principal bool)

;; activation-block for each stake-able token
(define-map activation-block principal uint)
(define-map approved-tokens principal bool)

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

;; At a given reward cycle, what is the total amount of tokens staked
(define-map staking-stats-at-cycle
  {
    token: principal,
    reward-cycle: uint
  }
  uint
)

(define-map reserve principal uint)

(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)

(define-private (check-is-self)
  (ok (asserts! (is-eq tx-sender (as-contract tx-sender)) ERR-NOT-AUTHORIZED))
)

(define-private (check-is-approved)
  (ok (asserts! (default-to false (map-get? approved-contracts tx-sender)) ERR-NOT-AUTHORIZED))
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

(define-public (add-approved-contract (new-approved-contract principal))
  (begin
    (try! (check-is-owner))
    (ok (map-set approved-contracts new-approved-contract true))
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
    (try! (check-is-approved-token (contract-of token-trait)))
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
      (stop-cycle (get-activation-block-or-default token))
      (commitment {
        sender:user,
        token: token,
        staker-id: user-id,
        amount: amount-token,
        first: block-height,
        last: stop-cycle
      })
    )
    (try! (check-is-approved-token (contract-of token-trait)))
    (asserts! (< block-height (get-activation-block-or-default token)) ERR-CONTRACT-NOT-ACTIVATED)
    (asserts! (> amount-token u0) ERR-CANNOT-STAKE)
    (unwrap! (contract-call? token-trait transfer-fixed amount-token tx-sender .sata-vault none) ERR-TRANSFER-FAILED)
    (try! (as-contract (add-to-balance token amount-token)))
    (set-tokens-staked token user-id stop-cycle u0 amount-token)
    (print commitment)
    (ok true)
  )
)

(define-public (set-activation-block (token principal) (new-activation-block uint))
  (begin
    (try! (check-is-owner))
    (ok (map-set activation-block token new-activation-block))
  )
)

;; @desc get-activation-block-or-default
;; @params token
;; @returns uint
(define-read-only (get-activation-block-or-default (token principal))
  (default-to u100000000 (map-get? activation-block token))
)

(define-private (check-is-approved-token (token principal))
  (ok (asserts! (default-to false (map-get? approved-tokens token)) ERR-INVALID-TOKEN))
)

;; @desc add-token
;; @params token
;; @returns (response bool)
(define-public (add-token (token principal))
  (begin
    (try! (check-is-owner))
    (map-set approved-tokens token true)
    (ok (map-set users-nonce token u0))
  )
)

;; @desc is-token-approved
;; @params token
;; @returns bool
(define-read-only (is-token-approved (token principal))
  (is-some (map-get? approved-tokens token))
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

;; @desc get-user-id
;; @params token
;; @params user
;; @returns (some user-id) or none
(define-read-only (get-user-id (token principal) (user principal))
  (map-get? user-ids {token: token, user: user})
)

;; @desc get-registered-users-nonce-or-default
;; @params token
;; @returns uint
(define-read-only (get-registered-users-nonce-or-default (token principal))
  (default-to u0 (get-registered-users-nonce token))
)

;; returns (some number of registered users), used for activation and tracking user IDs, or none
;; @desc get-registered-users-nonce
;; @params token
;; @returns (optional (tuple))
(define-read-only (get-registered-users-nonce (token principal))
  (map-get? users-nonce token)
)

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
    (asserts! (or (is-ok (check-is-self)) (is-ok (check-is-approved)) (is-ok (check-is-owner))) ERR-NOT-AUTHORIZED)
    (ok (map-set reserve token (+ amount (get-balance token))))
  )
)

;; @desc remove-from-balance
;; @params token
;; @params amount
;; @returns (response bool)
(define-public (remove-from-balance (token principal) (amount uint))
  (begin
    (asserts! (or (is-ok (check-is-self)) (is-ok (check-is-approved)) (is-ok (check-is-owner))) ERR-NOT-AUTHORIZED)
    (asserts! (<= amount (get-balance token)) ERR-AMOUNT-EXCEED-RESERVE)
    (ok (map-set reserve token (- (get-balance token) amount)))
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

;; calls function to claim staking reward in active logic contract
;; @desc claim-staking-reward
;; @params token-trait; ft-trait
;; @params target-cycle
;; @returns (response tuple)
(define-public (claim-staking-reward (token-trait <ft-trait>) (target-cycle uint))
  (begin
    (try! (check-is-approved-token (contract-of token-trait)))
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
      (user-id (unwrap! (get-user-id token user) ERR-USER-ID-NOT-FOUND))
      (to-return (get to-return (get-staker-at-cycle-or-default token target-cycle user-id)))
    )
    (asserts! (> block-height (get-activation-block-or-default token)) ERR-CONTRACT-NOT-ACTIVATED)
    (asserts! (default-to false (map-get? approved-tokens token)) ERR-INVALID-TOKEN)
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

    (and (> to-return u0) (as-contract (try! (contract-call? .sata-vault transfer-ft token-trait to-return user))) (as-contract (try! (remove-from-balance (contract-of token-trait) to-return))))
    (ok { to-return: to-return })
  )
)