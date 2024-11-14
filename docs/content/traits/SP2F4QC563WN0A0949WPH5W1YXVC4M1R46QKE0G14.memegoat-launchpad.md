---
title: "Trait memegoat-launchpad"
draft: true
---
```
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait ft-trait-ext 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)
(use-trait ft-velar-lp 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.ft-plus-trait.ft-plus-trait)
(use-trait ft-alex-lp 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-semi-fungible.semi-fungible-trait)

;; ERRS

(define-constant ERR-NOT-LISTED-ON-VELAR (err u4001))
(define-constant ERR-NOT-LISTED-ON-ALEX (err u4002))
(define-constant ERR-ALEX-REQUEST-ID-NOT-SET (err u4003))
(define-constant ERR-INSUFFICIENT-AMOUNT (err u5001))
(define-constant ERR-ZERO-AMOUNT (err u5002))
(define-constant ERR-INVALID-AMOUNT (err u5003))
(define-constant ERR-INVALID-ID (err u5004))
(define-constant ERR-INVALID-ADDRESS (err u5005))
(define-constant ERR-NOT-QUALIFIED (err u5006))
(define-constant ERR-NOT-AUTHORIZED (err u5009))
(define-constant ERR-BELOW-MIN-PERIOD (err u6000))
(define-constant ERR-LAUNCHPAD-INACTIVE (err u7000))
(define-constant ERR-INVALID-TOKEN (err u7001))
(define-constant ERR-INVALID-LP-TOKEN (err u7002))
(define-constant ERR-TOKEN-LAUNCH-NOT-ENDED (err u7003))
(define-constant ERR-NOT-PARTICIPANT (err u7004))
(define-constant ERR-ALREADY-CLAIMED (err u7005))
(define-constant ERR-MAX-DEPOSIT-EXCEEDED (err u8001))
(define-constant ERR-HARDCAP-EXCEEDED (err u8002))
(define-constant ERR-MIN-TARGET-NOT-REACHED (err u8003))
(define-constant ERR-TOKEN-IS-VESTED (err u8004))
(define-constant ERR-BELOW-MINIMUM-POOL-ALLOCATION (err u9000))
(define-constant ERR-BELOW-MINIMUM-LISTING-ALLOCATION (err u9001))
(define-constant ERR-BELOW-MINIMUM-CAMPAIGN-ALLOCATION (err u9002))
(define-constant ERR-NO-CAMPAIGN-ALLOCATION (err u9003))
(define-constant ERR-REWARDS-NOT-SET (err u9004))
(define-constant ERR-INVALID-EXCHANGE (err u9004))


;; DATA MAPS AND VARS

(define-constant ONE_8 u100000000)
(define-constant ONE_6 u1000000)
(define-data-var contract-owner principal tx-sender)
(define-data-var launchpad-nonce uint u0)
(define-data-var min-goat-balance uint u0)
(define-data-var goat-token principal .memegoatstx)
(define-data-var paused bool false)
(define-data-var launchpad-fee uint u2)

(define-constant VELAR u1)
(define-constant ALEX u2)

;; @desc map to stop token launches
(define-map launchpad-map
  {token-launch-id: uint}
  {
    token: principal,
    pool-amount: uint,
    hardcap: uint,
    softcap: uint,
    total-stx-deposited: uint,
    no-of-participants: uint,
    min-stx-deposit: uint,
    max-stx-deposit: uint,
    duration: uint,
    start-block: uint,
    end-block: uint,
    owner: principal,
    is-vested: bool,
    is-listed: bool,
    listing-allocation: uint,
    campaign-allocation: (optional uint),
    campaign-rewards-set: bool,
    burn-lp: bool,
    exchange-id: uint,
    request-id: (optional uint),
  }
)

;; @desc map to store token-addr
(define-map launchpad-map-by-token-addr
  {token-addr: principal}
  uint
)

;; @desc map to store user deposits
(define-map users-deposits
    { user-addr: principal, token-launch-id: uint }
    uint
)

;; @desc map to store claim history
(define-map user-claimed 
  { user-addr : principal, token-launch-id: uint }
  bool
)

;; @desc map to store rewards
(define-map campaign-rewards
  { user-addr: principal, token-launch-id: uint } 
  uint
)

;; READ-ONLY CALLS

;; @desc is-paused: contract status
;; @returns (boolean)
(define-read-only (is-paused)
    (var-get paused)
)

;; @desc get-token-launch-by-id: gets the token launch by id
;; @params token-launch-id
;; @returns (response launchpad-record)
(define-read-only (get-token-launch-by-id (token-launch-id uint))
  (ok (unwrap! (map-get? launchpad-map {token-launch-id: token-launch-id}) ERR-INVALID-ID))
)

;; @desc get-token-id-launch-by-addr : gets the token id of a token-launch using the token address
;; @params token-addr
;; @returns (response uint)
(define-read-only (get-token-id-launch-by-addr (token-addr <ft-trait>))
  (ok (unwrap! (map-get? launchpad-map-by-token-addr {token-addr: (contract-of token-addr)}) ERR-INVALID-ADDRESS))
)

;; @desc get-user-deposits-exists: checks if user has deposited stx
;; @params user-addr
;; @params token-launch-id
;; @returns (response boolean)
(define-read-only (get-user-deposits-exists (user-addr principal) (token-launch-id uint))
  (map-get? users-deposits {user-addr: user-addr, token-launch-id: token-launch-id})
)

;; @desc get-user-deposits-exists: checks if user has deposited stx
;; @params user-addr
;; @params token-launch-id
;; @returns (response boolean)
(define-read-only (get-user-rewards (user-addr principal) (token-launch-id uint))
  (default-to u0 (map-get? campaign-rewards {user-addr: user-addr, token-launch-id: token-launch-id}))
)

;; @desc get-user-deposits: gets amount of stx deposited by user
;; @params user-addr
;; @params token-launch-id
;; @returns (response uint)
(define-read-only (get-user-deposits (user-addr principal) (token-launch-id uint)) 
  (default-to u0 (get-user-deposits-exists user-addr token-launch-id))
)

;; @desc calculate-allocation: gets the calculated amount of launch tokens allocated to the user
;; @params user-addr
;; @params token-launch-id
;; @returns (response uint)
(define-read-only (calculate-allocation (user-addr principal) (token-launch-id uint))
  (let
    ((user-deposit (get-user-deposits user-addr token-launch-id)))
    (if (> user-deposit u0) 
      (* (unwrap-panic (get-stx-quote token-launch-id)) user-deposit) 
      u0
    )
  )
)

;; @desc check-if-claimed: checks if user has claimed tokens
;; @params user-addr
;; @params token-launch-id
;; @returns (response boolean)
(define-read-only (check-if-claimed (user-addr principal) (token-launch-id uint)) 
  (default-to false (map-get? user-claimed { user-addr: user-addr, token-launch-id: token-launch-id}))
)

;; @desc get-contract-owner: gets owner address
;; @returns (response principal)
(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

;; @desc get-stx-quote: gets the current exchange rate of token
;; @params user-addr
;; @params token-launch-id
;; @returns (response uint)
(define-read-only (get-stx-quote (token-launch-id uint))
  (let
    (
      (token-launch (try! (get-token-launch-by-id token-launch-id)))
      (token-pool (get pool-amount token-launch))
      (stx-pool (get total-stx-deposited token-launch))
    )

    (if (> stx-pool u0)
      (ok (/ token-pool stx-pool))
      (ok u0)
    )
  )
)

;; @desc get-launchpad-fee: gets launchpad fee
;; @returns (response uint)
(define-read-only (get-launchpad-fee)
  (var-get launchpad-fee)
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

;; @desc set-launchpad-fee: updates the launchpad-fee
;; @requirement only callable by current owner
;; @params new-fee
;; @returns (response boolean)
(define-public (set-launchpad-fee (new-fee uint))
  (begin
    (try! (check-is-owner)) 
    (asserts! (> new-fee u0) ERR-ZERO-AMOUNT)
    (ok (var-set launchpad-fee new-fee))
  )
)

;; @desc set-min-goat-balance: updates the minimum balance of memegoat tokens required to participate
;; @requirement only callable by current owner
;; @params amount
;; @returns (response boolean)
(define-public (set-min-goat-balance (amount uint))
  (begin
    (try! (check-is-owner))
    (asserts! (> amount u0) ERR-ZERO-AMOUNT)
    (var-set min-goat-balance amount)
    (ok true)
  )
)

;; @desc finalize-listing-velar: transfers launch liquidity to velar
;; @requirement only callable by current owner or campaign creator
;; @params token-launch-id
;; @params token-x 
;; @params token-y
;; @param lp-token-velar
;; @returns (response boolean)
;; (lp-token-alex <ft-alex-lp>)
(define-public (finalize-listing-velar
    (token-launch-id uint) 
    (token-x <ft-trait>) 
    (token-y <ft-trait>)
    (lp-token-velar <ft-velar-lp>) 
  )
  (begin
    (asserts! (not (var-get paused)) ERR-LAUNCHPAD-INACTIVE)
    (let
      (
        (sender tx-sender)
        (token-launch (try! (get-token-launch-by-id token-launch-id)))
        (total-stx-deposited (get total-stx-deposited token-launch))
        (softcap (get softcap token-launch))
        (hardcap (get hardcap token-launch))
        (token (get token token-launch))
        (end-block (get end-block token-launch))
        (owner (get owner token-launch))
        (burn-lp (get burn-lp token-launch))
        (listing-allocation (get listing-allocation token-launch))
        (fee (get-fee total-stx-deposited))
        (list-amount-stx (- total-stx-deposited fee))
        (exchange-id (get exchange-id token-launch))
        (request-id (get request-id token-launch))
        (token-launch-updated (merge token-launch {
          is-listed: true,
        }))
        (pool-id (unwrap! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core get-pool-id (contract-of token-x) (contract-of token-y)) ERR-NOT-LISTED-ON-VELAR))
        (pool (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool pool-id))
      )
      (asserts! (or (is-eq owner sender) (try! (check-is-owner)))  ERR-NOT-AUTHORIZED)
      (asserts! (>= total-stx-deposited softcap) ERR-MIN-TARGET-NOT-REACHED)
      (asserts! (or (< end-block block-height) (is-eq total-stx-deposited hardcap)) ERR-TOKEN-LAUNCH-NOT-ENDED)
      (asserts! (is-eq token (contract-of token-y)) ERR-INVALID-TOKEN)
      (asserts! (is-eq (get lp-token pool) (contract-of lp-token-velar)) ERR-INVALID-LP-TOKEN)

      (try! (as-contract  (contract-call? .memegoat-launchpad-vault transfer-stx list-amount-stx tx-sender)))
      (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router add-liquidity pool-id token-x token-y lp-token-velar listing-allocation listing-allocation (calc-4-percent list-amount-stx) (calc-4-percent listing-allocation)))
        
      (if burn-lp 
        (let
          (
            (lp-balance (try! (contract-call? lp-token-velar get-balance tx-sender)))
          )
          (try! (contract-call? lp-token-velar transfer lp-balance tx-sender .memegoat-dead-wallet none))
        )  
        true
      )

      (map-set launchpad-map {token-launch-id: token-launch-id} token-launch-updated)
      ;; transfer fee to treasury
      (try! (as-contract (contract-call? .memegoat-launchpad-vault transfer-stx fee .memegoat-treasury)))
    )
    (ok true)
  )
)

;; @desc make-listing-request-alex: creates a listing request for alex
;; @requirement only callable by current owner or campaign creator
;; @params token-launch-id
;; @params token-x 
;; @params token-y
;; @returns (response boolean)
(define-public (make-listing-request-alex
    (token-launch-id uint) 
    (token-x <ft-trait-ext>) 
    (token-y <ft-trait-ext>) 
  )
  (let
    (
      (sender tx-sender)
      (token-launch (try! (get-token-launch-by-id token-launch-id)))
      (total-stx-deposited (get total-stx-deposited token-launch))
      (softcap (get softcap token-launch))
      (hardcap (get hardcap token-launch))
      (token (get token token-launch))
      (end-block (get end-block token-launch))
      (owner (get owner token-launch))
      (burn-lp (get burn-lp token-launch))
      (fee (get-fee total-stx-deposited))
      (list-amount-stx (- total-stx-deposited fee))
      (listing-allocation (get listing-allocation token-launch))
      (exchange-id (get exchange-id token-launch))
    )
    (asserts! (not (var-get paused)) ERR-LAUNCHPAD-INACTIVE)
    (asserts! (is-eq  exchange-id ALEX) ERR-INVALID-EXCHANGE)
    (asserts! (or (is-eq owner sender) (try! (check-is-owner)))  ERR-NOT-AUTHORIZED)
    (asserts! (>= total-stx-deposited softcap) ERR-MIN-TARGET-NOT-REACHED)
    (asserts! (or (< end-block block-height) (is-eq total-stx-deposited hardcap)) ERR-TOKEN-LAUNCH-NOT-ENDED)
    (asserts! (is-eq token (contract-of token-y)) ERR-INVALID-TOKEN)

    (let 
      (
        (request-id 
          (try! 
            (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.self-listing-helper-v2-01 request-create 
              {
                bal-x: (decimals-to-fixed-stx list-amount-stx),
                bal-y: (decimals-to-fixed listing-allocation token-y),
                factor: u100000000,
                fee-rate-x: u500000, 
                fee-rate-y: u500000, 
                max-in-ratio: u60000000, 
                max-out-ratio: u60000000, 
                memo: none,
                oracle-average: u99000000, 
                oracle-enabled: true,
                start-block: u0, 
                threshold-x: u0, 
                threshold-y: u0, 
                token-x: (contract-of token-x),
                token-y: (contract-of token-y),
              } 
              token-x
            )
          )
        )
        (token-launch-updated (merge token-launch {
          request-id: (some request-id)
        }))
      )
      (map-set launchpad-map {token-launch-id: token-launch-id} token-launch-updated)
    )
    (ok true)
  )
)


;; @desc finalize-listing-alex: transfers launch liquidity to alex
;; @requirement only callable by current owner or campaign creator
;; @params token-launch-id
;; @params token-x 
;; @params token-y
;; @param lp-token-velar
;; @returns (response boolean)
;; (lp-token-alex <ft-alex-lp>)
(define-public (finalize-listing-alex
    (token-launch-id uint) 
    (token-x <ft-trait-ext>) 
    (token-y <ft-trait-ext>)
    (lp-token-alex <ft-alex-lp>) 
  )
  (begin
    (asserts! (not (var-get paused)) ERR-LAUNCHPAD-INACTIVE)
    (let
      (
        (sender tx-sender)
        (token-launch (try! (get-token-launch-by-id token-launch-id)))
        (total-stx-deposited (get total-stx-deposited token-launch))
        (softcap (get softcap token-launch))
        (hardcap (get hardcap token-launch))
        (token (get token token-launch))
        (end-block (get end-block token-launch))
        (owner (get owner token-launch))
        (burn-lp (get burn-lp token-launch))
        (fee (get-fee total-stx-deposited))
        (exchange-id (get exchange-id token-launch))
        (request-id (get request-id token-launch))
        (req-id (unwrap! request-id ERR-ALEX-REQUEST-ID-NOT-SET))
        (token-launch-updated (merge token-launch {
          is-listed: true,
        }))
      )
      
      (asserts! (is-eq  exchange-id ALEX) ERR-INVALID-EXCHANGE)
      (asserts! (or (is-eq owner sender) (try! (check-is-owner)))  ERR-NOT-AUTHORIZED)
      (asserts! (>= total-stx-deposited softcap) ERR-MIN-TARGET-NOT-REACHED)
      (asserts! (or (< end-block block-height) (is-eq total-stx-deposited hardcap)) ERR-TOKEN-LAUNCH-NOT-ENDED)
      (asserts! (is-eq token (contract-of token-y)) ERR-INVALID-TOKEN)
      (asserts! (is-some request-id) ERR-ALEX-REQUEST-ID-NOT-SET)

      (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.self-listing-helper-v2-01 finalize-request req-id token-x token-y))

      (if burn-lp 
        (let
          (
            (request-details (try!  (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.self-listing-helper-v2-01 get-request-or-fail req-id)))
            (pool-details (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details (get token-x request-details) (get token-y request-details) (get factor request-details))))
            (pool-id (get pool-id pool-details))
            (lp-balance (try! (contract-call? lp-token-alex get-balance pool-id tx-sender)))
          )
          (try! (contract-call? lp-token-alex transfer lp-balance pool-id tx-sender .memegoat-dead-wallet))
        )  
        true
      )

      (map-set launchpad-map {token-launch-id: token-launch-id} token-launch-updated)
      ;; transfer fee to treasury
      (try! (as-contract (contract-call? .memegoat-launchpad-vault transfer-stx fee .memegoat-treasury)))
    )
    (ok true)
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

;; PUBLIC CALLS

;; @desc register-token-launch: creates a new token launch
;; @params token
;; @params pool-amount
;; @params hardcap
;; @params softcap
;; @params start-block
;; @params end-block
;; @params min-stx-deposit
;; @params max-stx-deposit
;; @params is-vested
;; @params listing-allocation
;; @params campaign-allocation
;; @returns (response boolean)
(define-public 
  (register-token-launch 
    (token <ft-trait>)
    (pool-amount uint)
    (hardcap uint)
    (softcap uint)
    (start-block uint)
    (end-block uint)
    (min-stx-deposit uint)
    (max-stx-deposit uint)
    (is-vested bool)
    (listing-allocation uint)
    (campaign-allocation (optional uint))
    (burn-lp bool)
    (exchange-id uint)
  )
  (begin

    (asserts! (not (var-get paused)) ERR-LAUNCHPAD-INACTIVE)
    (asserts! (> hardcap softcap) ERR-INVALID-AMOUNT)
    (asserts! (> pool-amount u0) ERR-ZERO-AMOUNT)
    (asserts! (and (> min-stx-deposit u0) (> max-stx-deposit u0)) ERR-ZERO-AMOUNT)
    (asserts! (or (is-eq exchange-id VELAR) (is-eq  exchange-id ALEX)) ERR-INVALID-EXCHANGE)

    (let
      (
        (total-supply (try! (contract-call? token get-total-supply)))
        (min-pool-amount (/ (* total-supply u40) u100))
        (min-listing-allocation (/ (* total-supply u25) u100))
        (min-campaign-allocation (/ (* total-supply u5) u100))
        (campaign-amount (if (is-some campaign-allocation) (unwrap-panic campaign-allocation) u0 ))
        (total-to-send (+ pool-amount listing-allocation campaign-amount))
        (duration (- end-block start-block))
        (next-launchpad-id (+ (var-get launchpad-nonce) u1))
      )

      (asserts! (>= pool-amount min-pool-amount ) ERR-BELOW-MINIMUM-POOL-ALLOCATION)
      (asserts! (>= listing-allocation min-listing-allocation ) ERR-BELOW-MINIMUM-LISTING-ALLOCATION)
      (asserts! (>= duration u144) ERR-BELOW-MIN-PERIOD) ;; rough estimate of one day
     
      (if (is-some campaign-allocation)
        (asserts! (>= campaign-amount min-campaign-allocation ) ERR-BELOW-MINIMUM-CAMPAIGN-ALLOCATION)
        (asserts! (is-eq  campaign-amount u0 ) ERR-INVALID-AMOUNT)
      )

      (map-set launchpad-map {token-launch-id: next-launchpad-id} {
        token: (contract-of token),
        pool-amount: pool-amount,
        hardcap: hardcap,
        softcap: softcap,
        total-stx-deposited: u0,
        no-of-participants: u0,
        min-stx-deposit: min-stx-deposit,
        max-stx-deposit: max-stx-deposit,
        duration: duration,
        start-block: start-block,
        end-block: end-block,
        owner: tx-sender,
        is-vested: is-vested,
        is-listed: false,
        listing-allocation: listing-allocation,
        campaign-allocation: campaign-allocation,
        campaign-rewards-set: false,
        burn-lp: burn-lp,
        exchange-id: exchange-id,
        request-id: none
      })

      (map-set launchpad-map-by-token-addr {token-addr: (contract-of token)} next-launchpad-id)

      (try! (contract-call? token transfer total-to-send tx-sender .memegoat-launchpad-vault none))

      (var-set launchpad-nonce next-launchpad-id)
    )
    (ok true)
  )
)

;; @desc deposit-stx: sends stx to get launch token
;; @requirement user has active stake in contract or holds a min amount of goat token.
;; @params amount
;; @params token-launch-id
;; @params goat-token-trait
;; @returns (response boolean)
(define-public (deposit-stx (amount uint) (token-launch-id uint) (goat-token-trait <ft-trait-ext>))
  (begin
    (asserts! (not (var-get paused)) ERR-LAUNCHPAD-INACTIVE)

    ;; check that token passed is goat token
    (asserts! (is-eq (var-get goat-token) (contract-of goat-token-trait)) ERR-INVALID-TOKEN)

    (let
      (
        (sender tx-sender)
        (has-stake (contract-call? .memegoat-staking-v1 get-user-stake-has-staked sender))
        (user-goat-balance (try! (contract-call? goat-token-trait get-balance sender)))
        (token-launch (try! (get-token-launch-by-id token-launch-id)))
        (total-stx-deposited (get total-stx-deposited token-launch))
        (participants (get no-of-participants token-launch))
        (min-stx-deposit (get min-stx-deposit token-launch))
        (max-stx-deposit (get max-stx-deposit token-launch))
        (exists (is-some (get-user-deposits-exists sender token-launch-id)))
        (user-deposit (get-user-deposits sender token-launch-id))
        (end-block (get end-block token-launch))
        (hardcap (get hardcap token-launch))
        (token-launch-updated (merge token-launch {
          total-stx-deposited: (+ total-stx-deposited amount),
          no-of-participants: (if exists participants (+ participants u1))
          }
        ))
      )

      ;; check that user has access
      (asserts! (or has-stake (>= user-goat-balance (var-get min-goat-balance))) ERR-NOT-QUALIFIED)

      (asserts! (>= amount min-stx-deposit) ERR-INSUFFICIENT-AMOUNT)

      ;; check that hardcap has not been reached
      (asserts! (<= (+ amount total-stx-deposited) hardcap) ERR-HARDCAP-EXCEEDED)

      ;; check that user has not exceeded max deposit
      (asserts! (<= (+ user-deposit amount) max-stx-deposit) ERR-MAX-DEPOSIT-EXCEEDED)
    
      ;; transfer stx to vault
      (try! (stx-transfer? amount tx-sender .memegoat-launchpad-vault))

      ;; updated user-deposits
      (map-set users-deposits {user-addr: sender, token-launch-id: token-launch-id} (+ user-deposit amount))

      ;; updated token-launch
      (map-set launchpad-map {token-launch-id: token-launch-id} token-launch-updated)
    )
    (ok true)
  )
)

;; @desc claim-token: allows users to claim the allocated tokens
;; @params token-launch-id
;; @params token-trait
;; @returns (response boolean)
(define-public (claim-token (token-launch-id uint) (token-trait <ft-trait>))
  (begin
    (asserts! (not (var-get paused)) ERR-LAUNCHPAD-INACTIVE)
    (let
      (
        (sender tx-sender)
        (token-launch (try! (get-token-launch-by-id token-launch-id)))
        (total-stx-deposited (get total-stx-deposited token-launch))
        (softcap (get softcap token-launch))
        (hardcap (get hardcap token-launch))
        (token (get token token-launch))
        (is-vested (get is-vested token-launch))
        (end-block (get end-block token-launch))
        (exists (is-some (get-user-deposits-exists sender token-launch-id)))
        (user-allocation (calculate-allocation sender token-launch-id))
        (claimed (check-if-claimed sender token-launch-id))
      )

      (asserts! (>= total-stx-deposited softcap) ERR-MIN-TARGET-NOT-REACHED)
      (asserts! (or (< end-block block-height) (is-eq total-stx-deposited hardcap)) ERR-TOKEN-LAUNCH-NOT-ENDED)
      (asserts! exists ERR-NOT-PARTICIPANT)
      (asserts! (not claimed) ERR-ALREADY-CLAIMED)
      (asserts! (is-eq token (contract-of token-trait)) ERR-INVALID-TOKEN)
      (asserts! (not is-vested) ERR-TOKEN-IS-VESTED)
          
      ;; transfer token from vault
      (as-contract (try! (contract-call? .memegoat-launchpad-vault transfer-ft token-trait user-allocation sender)))      
      
      ;; set user status to claimed 
      (map-set user-claimed { user-addr: sender, token-launch-id: token-launch-id } true)
    )
    (ok true)
  )
)

;; @desc claim-reward: allows users to claim campaign reward
;; @params token-launch-id
;; @params token-trait
;; @returns (response boolean)
(define-public (claim-rewards (token-launch-id uint) (token-trait <ft-trait>))
  (begin
    (asserts! (not (var-get paused)) ERR-LAUNCHPAD-INACTIVE)
    (let
      (
        (sender tx-sender)
        (token-launch (try! (get-token-launch-by-id token-launch-id)))
        (campaign-rewards-set (get campaign-rewards-set token-launch))
        (token (get token token-launch))
        (reward (get-user-rewards sender token-launch-id))
      )
      (asserts! campaign-rewards-set ERR-REWARDS-NOT-SET)
      (asserts! (> reward u0) ERR-ZERO-AMOUNT)
      (asserts! (is-eq token (contract-of token-trait)) ERR-INVALID-TOKEN)
      ;; transfer token from vault
      (as-contract (try! (contract-call? .memegoat-launchpad-vault transfer-ft token-trait reward sender)))   
      ;; remove records
      (map-delete campaign-rewards {user-addr: sender, token-launch-id: token-launch-id})   
    )
    (ok true)
  )
)

;; PRIVATE CALLS

(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)

(define-private (calc-4-percent (amount uint))
  (let
    ((percent (/ (* amount u4) u100)))
    (- amount percent)
  )
)

(define-private (get-fee (amount uint))
  (/ (* amount (var-get launchpad-fee)) u100)
)

(define-private (add-reward (recipient {addr: principal, points: uint}) (token-launch-id uint))
	(let
    (
      (addr (get addr recipient))
      (points (get points recipient))
    )
    (map-set campaign-rewards {user-addr: addr, token-launch-id: token-launch-id} points)
    token-launch-id
  )
)

(define-private (pow-decimals (token <ft-trait>))
  (pow u10 (unwrap-panic (contract-call? token get-decimals)))
)


(define-private (decimals-to-fixed (amount uint) (token <ft-trait>))
  (/ (* amount ONE_8) (pow-decimals token))
)

(define-private (decimals-to-fixed-stx (amount uint))
  (/ (* amount ONE_8) ONE_6)
)
```
