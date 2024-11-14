---
title: "Trait memegoat-x-tenmetsu-v2"
draft: true
---
```
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait ft-trait-ext 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)
(use-trait ft-velar-lp 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.ft-plus-trait.ft-plus-trait)
(use-trait ft-alex-lp 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-semi-fungible.semi-fungible-trait)

;; ERRS
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-INITIALIZED (err u1001))
(define-constant ERR-NOT-INITIALIZED (err u1001))
(define-constant ERR-INSUFFICIENT-AMOUNT (err u5001))
(define-constant ERR-BELOW-MIN-PERIOD (err u6000))
(define-constant ERR-PRESALE-ENDED (err u7002))
(define-constant ERR-NOT-PARTICIPANT (err u7004))
(define-constant ERR-ALREADY-CLAIMED (err u7005))
(define-constant ERR-POOL-NOT-FUNDED (err u8000))
(define-constant ERR-MAX-DEPOSIT-EXCEEDED (err u8001))
(define-constant ERR-HARDCAP-EXCEEDED (err u8002))
(define-constant ERR-MIN-TARGET-NOT-REACHED (err u8003))
(define-constant ERR-NOT-LISTED-ON-VELAR (err u4001))
(define-constant ERR-NOT-LISTED-ON-ALEX (err u4002))
(define-constant ERR-ALEX-REQUEST-ID-NOT-SET (err u4003))
(define-constant ERR-ZERO-AMOUNT (err u5002))
(define-constant ERR-INVALID-AMOUNT (err u5003))
(define-constant ERR-INVALID-ADDRESS (err u5005))
(define-constant ERR-INVALID-TOKEN (err u7001))
(define-constant ERR-INVALID-LP-TOKEN (err u7002))
(define-constant ERR-TOKEN-LAUNCH-NOT-ENDED (err u7003))
(define-constant ERR-BELOW-MINIMUM-POOL-ALLOCATION (err u9000))
(define-constant ERR-BELOW-MINIMUM-LISTING-ALLOCATION (err u9001))
(define-constant ERR-INVALID-EXCHANGE (err u9005))
(define-constant ERR-TOKEN-ALREADY-LISTED (err u9006))
(define-constant ERR-INVALID-BLOCK-TIMES (err u9007))


;; STORAGE
(define-constant VELAR u1)
(define-constant ALEX u2)
(define-constant ONE_8 u100000000)
(define-constant ONE_6 u1000000) 
(define-constant LAUNCHPAD-TOKEN 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC.tenmetsu)
(define-constant LAUNCHPAD-ADDRESS (as-contract tx-sender))
(define-constant ALEX-LP-TOKEN 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01)
(define-constant GOAT-TREASURY 'SP2F4QC563WN0A0949WPH5W1YXVC4M1R46QKE0G14.memegoat-treasury)

(define-data-var initialized bool false)
(define-data-var deployer principal tx-sender)
(define-data-var stx-pool uint u0)
(define-data-var no-of-participants uint u0)
(define-data-var token-pool uint u0)
(define-data-var listing-pool uint u0)
(define-data-var presale-hardcap uint u0)
(define-data-var presale-softcap uint u0)
(define-data-var min-buy uint u0) 
(define-data-var max-buy uint u0)
(define-data-var start-block uint u0)
(define-data-var end-block uint u0)
(define-data-var burn-lp bool false)
(define-data-var exchange-id uint u0)
(define-data-var is-vested bool false)
(define-data-var request-id (optional uint) none)
(define-data-var is-listed bool false)

(define-map users-deposits
    { user-addr: principal }
    uint
)

(define-map user-claimed 
  { user-addr : principal }
  bool
)

;; READ ONLY CALLS

(define-read-only (get-launchpad-info)
  (ok 
    {
      initialized: (var-get initialized),
      pool-amount: (var-get token-pool),
      hardcap: (var-get presale-hardcap),
      softcap: (var-get presale-softcap),
      total-stx-deposited: (var-get  stx-pool),
      no-of-participants: (var-get no-of-participants),
      min-buy: (var-get min-buy),
      max-buy: (var-get max-buy),
      start-block: (var-get start-block),
      end-block: (var-get end-block),
      deployer: (var-get deployer),
      is-vested: (var-get is-vested),
      is-listed: (var-get is-listed),
      listing-pool: (var-get listing-pool),
      lp-burn: (var-get burn-lp),
      exchange-id: (var-get exchange-id),
      token: LAUNCHPAD-TOKEN
    }
  )
)

(define-read-only (get-user-deposits (user-addr principal)) 
  (default-to u0 (map-get? users-deposits {user-addr: user-addr}))
)

(define-read-only (calculate-allocation (user-addr principal))
  (let
    ((user-deposit (get-user-deposits user-addr)))
    (* (get-stx-quote) user-deposit) 
    
  )
)

(define-read-only (get-stx-quote)
  (if (> (var-get stx-pool) u0)
    (/ (var-get token-pool) (var-get stx-pool))
    u0
  )
)

(define-read-only (check-if-claimed (user-addr principal)) 
  (default-to false (map-get? user-claimed { user-addr: user-addr }))
)

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .memegoat-community-dao) (contract-call? .memegoat-community-dao is-extension contract-caller)) ERR-NOT-AUTHORIZED))
)

;; DAO ACTION
(define-public (emergency-withdraw (token-trait <ft-trait>) (recipient principal))
  (let
    (
      (remaining-bal (try! (contract-call? token-trait get-balance LAUNCHPAD-ADDRESS)))
    )
    (try! (is-dao-or-extension))
    (as-contract (contract-call? token-trait transfer remaining-bal tx-sender recipient none))
  )
)

;; MANAGEMENT CALLS
(define-public (finalize-listing-velar
    (token-launch-id uint) 
    (token-x <ft-trait>) 
    (token-y <ft-trait>)
    (lp-token-velar <ft-velar-lp>) 
  )
  (begin
    (let
      (
        (recipient tx-sender)
        (total-stx-deposited (var-get stx-pool))
        (softcap (var-get presale-softcap))
        (hardcap (var-get presale-hardcap))
        (endblock (var-get end-block))
        (listing-allocation (var-get listing-pool))
        (fee (get-fee total-stx-deposited))
        (list-amount-stx (- total-stx-deposited fee))
        (exchange (var-get exchange-id))
        (req-id (var-get request-id))
        (pool-id (unwrap! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core get-pool-id (contract-of token-x) (contract-of token-y)) ERR-NOT-LISTED-ON-VELAR))
        (pool (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool pool-id))
      )
      (asserts! (or (is-ok (is-dao-or-extension)) (try! (check-is-deployer))) ERR-NOT-AUTHORIZED)
      (asserts! (>= total-stx-deposited softcap) ERR-MIN-TARGET-NOT-REACHED)
      (asserts! (or (< endblock block-height) (is-eq total-stx-deposited hardcap)) ERR-TOKEN-LAUNCH-NOT-ENDED)
      (asserts! (is-eq LAUNCHPAD-TOKEN (contract-of token-y)) ERR-INVALID-TOKEN)
      (asserts! (is-eq (get lp-token pool) (contract-of lp-token-velar)) ERR-INVALID-LP-TOKEN)

      (try! (as-contract (stx-transfer? list-amount-stx tx-sender recipient)))
      (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router add-liquidity pool-id token-x token-y lp-token-velar list-amount-stx listing-allocation (calc-4-percent list-amount-stx) (calc-4-percent listing-allocation)))
        
      (if (var-get burn-lp) 
        (let
          (
            (lp-balance (try! (contract-call? lp-token-velar get-balance tx-sender)))
          )
          (try! (contract-call? lp-token-velar transfer lp-balance tx-sender .memegoat-dead-wallet none))
        )  
        true
      )

      ;; transfer fee to treasury
      (try! (as-contract (stx-transfer? fee tx-sender GOAT-TREASURY)))
    )
    (ok true)
  )
)

(define-public (make-listing-request-alex
    (token-launch-id uint) 
    (token-x <ft-trait-ext>) 
    (token-y <ft-trait-ext>) 
  )
  (let
    (
      (sender tx-sender)
      (total-stx-deposited (var-get stx-pool))
      (softcap (var-get presale-softcap))
      (hardcap (var-get presale-hardcap))
      (endblock (var-get end-block))
      (list-amount-stx (calc-4-percent total-stx-deposited))
      (listing-allocation (var-get listing-pool))
      (exchange (var-get exchange-id))
    )
    (asserts! (is-eq  exchange ALEX) ERR-INVALID-EXCHANGE)
    (asserts! (or (is-ok (is-dao-or-extension)) (try! (check-is-deployer))) ERR-NOT-AUTHORIZED)
    (asserts! (>= total-stx-deposited softcap) ERR-MIN-TARGET-NOT-REACHED)
    (asserts! (or (< endblock block-height) (is-eq total-stx-deposited hardcap)) ERR-TOKEN-LAUNCH-NOT-ENDED)
    (asserts! (is-eq LAUNCHPAD-TOKEN (contract-of token-y)) ERR-INVALID-TOKEN)

    (let 
      (
        (req-id 
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
      )
      (var-set request-id (some req-id))
    )
    (ok true)
  )
)

(define-public (finalize-listing-alex
    (token-launch-id uint) 
    (token-x <ft-trait-ext>) 
    (token-y <ft-trait-ext>)
    (lp-token-alex <ft-alex-lp>) 
  )
  (let
    (
      (sender tx-sender)
      (total-stx-deposited (var-get stx-pool))
      (softcap (var-get presale-softcap))
      (hardcap (var-get presale-hardcap))
      (endblock (var-get end-block))
      (exchange (var-get exchange-id))
      (req-id (unwrap! (var-get request-id) ERR-ALEX-REQUEST-ID-NOT-SET))
    )
    
    (asserts! (is-eq  exchange ALEX) ERR-INVALID-EXCHANGE)
    (asserts! (or (is-ok (is-dao-or-extension)) (try! (check-is-deployer))) ERR-NOT-AUTHORIZED)
    (asserts! (>= total-stx-deposited softcap) ERR-MIN-TARGET-NOT-REACHED)
    (asserts! (or (< endblock block-height) (is-eq total-stx-deposited hardcap)) ERR-TOKEN-LAUNCH-NOT-ENDED)

    (asserts! (is-eq ALEX-LP-TOKEN (contract-of lp-token-alex)) ERR-INVALID-LP-TOKEN)

    (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.self-listing-helper-v2-01 finalize-request req-id token-x token-y))

    (if (var-get burn-lp) 
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

    (var-set is-listed true)
    ;; transfer fee to treasury
    (as-contract (contract-call? .memegoat-launchpad-vault transfer-stx (get-fee total-stx-deposited) GOAT-TREASURY))
  )
)

;; PUBLIC CALLS
(define-public 
  (initialize 
    (token-trait <ft-trait>)
    (pool-amount uint)
    (hardcap uint)
    (softcap uint)
    (startblock uint)
    (endblock uint)
    (min-stx-deposit uint)
    (max-stx-deposit uint)
    (vested bool)
    (listing-allocation uint)
    (burn bool)
    (exchange uint)
  )
  (let
    (
      (total-supply (try! (contract-call? token-trait get-total-supply)))
      (min-pool-amount (/ (* total-supply u40) u100))
      (min-listing-allocation (/ (* total-supply u25) u100))
      (total-to-send (+ pool-amount listing-allocation))
      (duration (- endblock startblock))
    )

    (try! (check-is-deployer))
    (try! (check-not-initialized))
    (asserts! (> hardcap softcap) ERR-INVALID-AMOUNT)
    (asserts! (> pool-amount u0) ERR-ZERO-AMOUNT)
    (asserts! (> listing-allocation u0) ERR-ZERO-AMOUNT)
    (asserts! (and (> min-stx-deposit u0) (> max-stx-deposit u0)) ERR-ZERO-AMOUNT)
    (asserts! (or (is-eq exchange VELAR) (is-eq  exchange ALEX)) ERR-INVALID-EXCHANGE)
    (asserts! (and (> startblock block-height) (> endblock startblock)) ERR-INVALID-BLOCK-TIMES)
    (asserts! (is-eq (contract-of token-trait) LAUNCHPAD-TOKEN) ERR-INVALID-TOKEN)
    (asserts! (>= duration u144) ERR-BELOW-MIN-PERIOD)
    (asserts! (>= pool-amount min-pool-amount) ERR-BELOW-MINIMUM-POOL-ALLOCATION)
    (asserts! (>= listing-allocation min-listing-allocation) ERR-BELOW-MINIMUM-LISTING-ALLOCATION)

    (var-set token-pool pool-amount)
    (var-set listing-pool listing-allocation)
    (var-set presale-hardcap hardcap)
    (var-set presale-softcap softcap)
    (var-set min-buy min-stx-deposit)
    (var-set max-buy max-stx-deposit)
    (var-set start-block startblock)
    (var-set end-block endblock)
    (var-set burn-lp burn)
    (var-set is-vested vested)
    (var-set exchange-id exchange)

    ;; transfer token to LAUNCHPAD ADDRESS
    (try! (contract-call? token-trait transfer total-to-send tx-sender LAUNCHPAD-ADDRESS none))
    (ok (var-set initialized true))
  )
)

(define-public (deposit-stx (amount uint))
  (let
    (
      (stx-pool-balance (var-get stx-pool))
      (exists (is-some (map-get? users-deposits { user-addr: tx-sender })))
      (user-deposit (get-user-deposits tx-sender))
      (participants (var-get no-of-participants))
      
    )
    (try! (check-is-initialized))
    (asserts! (>= amount (var-get min-buy)) ERR-INSUFFICIENT-AMOUNT)
    (asserts! (> (var-get end-block) block-height) ERR-PRESALE-ENDED)
    ;; check that hardcap has not been reached
    (asserts! (<= (+ amount stx-pool-balance) (var-get presale-hardcap)) ERR-HARDCAP-EXCEEDED)
    ;; check that user has not exceeded max deposit
    (asserts! (<= (+ user-deposit amount) (var-get max-buy)) ERR-MAX-DEPOSIT-EXCEEDED)
    ;; user send stx to launchpad
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    ;; increment pool balance
    (var-set stx-pool (+ stx-pool-balance amount))
    ;; update user deposits
    (map-set users-deposits {user-addr:tx-sender} (+ user-deposit amount))
    ;; update no of participants
    (if exists
      (ok (var-set no-of-participants participants))
      (ok (var-set no-of-participants (+ participants u1)))
    )
  )
)

;; claim launchpad token
(define-public (claim-token (token-trait <ft-trait>)) 
  (let
    (
      (stx-pool-balance (var-get stx-pool))
      (recipient tx-sender)
      (softcap (var-get presale-softcap))
      (hardcap (var-get presale-hardcap))
      (end-block- (var-get end-block))
      (exists (is-some (map-get? users-deposits {user-addr: recipient})))
      (user-deposit (get-user-deposits recipient))
      (user-allocation (calculate-allocation recipient))
      (claimed (check-if-claimed recipient))
    )
    (try! (check-is-initialized))
    (asserts! (or (< end-block- block-height) (is-eq stx-pool-balance hardcap)) ERR-TOKEN-LAUNCH-NOT-ENDED)
    (asserts! exists ERR-NOT-PARTICIPANT)
    (asserts! (is-eq LAUNCHPAD-TOKEN (contract-of token-trait)) ERR-INVALID-TOKEN)
    (asserts! (not claimed) ERR-ALREADY-CLAIMED)

    ;; check if softcap is met or refund users
    (if (>= stx-pool-balance softcap)
      (if (var-get is-vested)
        true   ;; to do create lock for user if vested      
        (try! (as-contract (contract-call? token-trait transfer user-allocation tx-sender recipient none)))
      )
      (try! (as-contract (stx-transfer? user-deposit tx-sender recipient)))
    )
    ;; set user status to claimed 
    (ok (map-set user-claimed { user-addr: recipient } true))
  )
)

;; PRIVATE CALLS
(define-private (check-is-deployer)
  (ok (asserts! (is-eq tx-sender (var-get deployer)) ERR-NOT-AUTHORIZED))
)

(define-private (check-not-initialized)
  (ok (asserts! (not (var-get initialized)) ERR-INITIALIZED))
)

(define-private (check-is-initialized)
  (ok (asserts! (var-get initialized) ERR-NOT-INITIALIZED))
)

(define-private (calc-4-percent (amount uint))
  (let
    ((percent (/ (* amount u4) u100)))
    (- amount percent)
  )
)

(define-private (calc-8-percent (amount uint))
  (let
    ((percent (/ (* amount u8) u100)))
    (- amount percent)
  )
)

(define-private (get-fee (amount uint))
  (/ (* amount u4) u100)
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
