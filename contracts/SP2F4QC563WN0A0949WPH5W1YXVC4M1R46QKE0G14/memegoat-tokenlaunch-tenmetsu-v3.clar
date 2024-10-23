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
(define-constant ALEX u0)
(define-constant ONE_8 u100000000)
(define-constant ONE_6 u1000000) 
(define-constant pre_launch u12931400000)
(define-constant listing-allocation u3000000000000000)
(define-constant LAUNCHPAD-TOKEN 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC.tenmetsu)
(define-constant LAUNCHPAD-ADDRESS (as-contract tx-sender))
(define-constant ALEX-LP-TOKEN 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01)
(define-constant GOAT-TREASURY 'SP2F4QC563WN0A0949WPH5W1YXVC4M1R46QKE0G14.memegoat-treasury)

(define-data-var initialized bool true)
(define-data-var deployer principal tx-sender)
(define-data-var stx-pool uint u750000000)
(define-data-var no-of-participants uint u88)
(define-data-var token-pool uint u4250000000000000)
(define-data-var listing-pool uint u0)
(define-data-var presale-hardcap uint u40000000000)
(define-data-var presale-softcap uint u5000000000)
(define-data-var min-buy uint u10000000) 
(define-data-var max-buy uint u500000000)
(define-data-var start-block uint u166219)
(define-data-var end-block uint u168235)
(define-data-var burn-lp bool false)
(define-data-var exchange-id uint u1)
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
      total-stx-deposited: (+ pre_launch (var-get stx-pool)),
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
  (let
    (
      (old-deposit (contract-call? .memegoat-tokenlaunch-tenmetsu get-user-deposits user-addr))
      (old-deposit-v2 (contract-call? .memegoat-tokenlaunch-tenmetsu-v2 get-user-deposits user-addr))
    )
    (+ old-deposit old-deposit-v2 (default-to u0 (map-get? users-deposits {user-addr: user-addr})))
  )
)

(define-read-only (get-user-deposits-curr (user-addr principal)) 
  (default-to u0 (map-get? users-deposits {user-addr: user-addr}))
)

(define-read-only (calculate-allocation (user-addr principal))
  (let
    ((user-deposit (get-user-deposits user-addr)))
    (* (get-stx-quote) user-deposit) 
  )
)

(define-read-only (get-stx-quote)
  (if (> (+ pre_launch (var-get stx-pool)) u0)
    (/ (var-get token-pool) (+ pre_launch (var-get stx-pool)))
    u0
  )
)

(define-read-only (check-if-claimed (user-addr principal)) 
  (default-to false (map-get? user-claimed { user-addr: user-addr }))
)

(define-public (withdraw (token-trait <ft-trait>) (recipient principal))
  (let
    (
      (remaining-bal (try! (contract-call? token-trait get-balance LAUNCHPAD-ADDRESS)))
      (hardcap (var-get presale-hardcap))
    )
    (try! (check-is-deployer))
    (as-contract (contract-call? token-trait transfer remaining-bal tx-sender recipient none))
  )
)

;; PUBLIC CALLS
(define-public 
  (initialize 
    (token-trait <ft-trait>)
  )
  (begin
    (try! (check-is-deployer))
    (asserts! (is-eq (contract-of token-trait) LAUNCHPAD-TOKEN) ERR-INVALID-TOKEN)
    ;; transfer token to LAUNCHPAD ADDRESS
    (try! (contract-call? token-trait transfer (var-get token-pool) tx-sender LAUNCHPAD-ADDRESS none))
    (ok (var-set initialized true))
  )
)

(define-public (deposit-stx (amount uint))
  (let
    (
      (stx-pool-balance (+ pre_launch (var-get stx-pool)))
      (exists (is-some (map-get? users-deposits { user-addr: tx-sender })))
      (user-deposit-total (get-user-deposits tx-sender))
      (user-deposit (get-user-deposits-curr tx-sender))
      (participants (var-get no-of-participants))
      
    )
    (try! (check-is-initialized))
    (asserts! (>= amount (var-get min-buy)) ERR-INSUFFICIENT-AMOUNT)
    (asserts! (> (var-get end-block) block-height) ERR-PRESALE-ENDED)
    ;; check that hardcap has not been reached
    (asserts! (<= (+ amount stx-pool-balance) (var-get presale-hardcap)) ERR-HARDCAP-EXCEEDED)
    ;; check that user has not exceeded max deposit
    (asserts! (<= (+ user-deposit-total amount) (var-get max-buy)) ERR-MAX-DEPOSIT-EXCEEDED)
    ;; user send stx to launchpad
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    ;; increment pool balance
    (var-set stx-pool (+ (var-get stx-pool) amount))
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
      (stx-pool-balance (+ pre_launch (var-get stx-pool)))
      (recipient tx-sender)
      (softcap (var-get presale-softcap))
      (hardcap (var-get presale-hardcap))
      (end-block- (var-get end-block))
      (exists (is-some (map-get? users-deposits {user-addr: recipient})))
      (user-deposit-total (get-user-deposits recipient))
      (user-deposit (get-user-deposits-curr recipient))
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