
;; ---------------------------------------------------------
;; MEMEGOAT X STXPIRATES LAUNCH
;; ---------------------------------------------------------

(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; ERRS
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-NOT-INITIALIZED (err u1001))
(define-constant ERR-INSUFFICIENT-AMOUNT (err u2001))
(define-constant ERR-NOT-PARTICIPANT (err u7004))
(define-constant ERR-ALREADY-CLAIMED (err u7005))
(define-constant ERR-MAX-DEPOSIT-EXCEEDED (err u8001))
(define-constant ERR-HARDCAP-EXCEEDED (err u8002))
(define-constant ERR-MIN-TARGET-NOT-REACHED (err u8003))
(define-constant ERR-INVALID-TOKEN (err u7001))
(define-constant ERR-PRESALE-ENDED (err u3001))
(define-constant ERR-PRESALE-NOT-ENDED (err u3002))

;; LAUNCHPAD DATA
(define-constant LISTING-ALLOCATION u300000000000)
(define-constant SALE-ALLOCATION u600000000000)
(define-constant LAUNCHPAD-TOKEN 'SP1X15DCKFMKX6X2HAJ29W5G06S67YSSWDEJKT7P4.gold-pirate)
(define-constant LAUNCHPAD-ADDRESS (as-contract tx-sender))
(define-constant LISTING-SIG-WALLET 'SM2VBB92G9AM8ZY5T369C99HAB8T6KGVZVZYCS5WB)
(define-constant MIN-BUY u1000000)
(define-constant MAX-BUY u10000000)
(define-constant HARD-CAP u10000000) 
(define-constant SOFT-CAP u1000000)
(define-constant START-BLOCK u167477)
(define-constant END-BLOCK u167909)

(define-data-var initialized bool false)
(define-data-var stx-sent bool false)
(define-data-var deployer principal tx-sender)
(define-data-var stx-pool uint u0)
(define-data-var no-of-participants uint u0)

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
      pool-amount: SALE-ALLOCATION,
      hardcap: HARD-CAP,
      softcap: SOFT-CAP,
      total-stx-deposited: (var-get stx-pool),
      no-of-participants: (var-get no-of-participants),
      min-buy: MIN-BUY,
      max-buy: MAX-BUY,
      start-block: START-BLOCK,
      end-block: END-BLOCK,
      deployer: (var-get deployer),
      listing-pool: LISTING-ALLOCATION,
      token: LAUNCHPAD-TOKEN,
      is-stx-sent: (var-get stx-sent)
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
    (/ SALE-ALLOCATION (var-get stx-pool))
    u0
  )
)

(define-read-only (check-if-claimed (user-addr principal)) 
  (default-to false (map-get? user-claimed { user-addr: user-addr }))
)

(define-read-only (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender 'SP2F4QC563WN0A0949WPH5W1YXVC4M1R46QKE0G14.memegoat-community-dao) (contract-call? 'SP2F4QC563WN0A0949WPH5W1YXVC4M1R46QKE0G14.memegoat-community-dao is-extension contract-caller)) ERR-NOT-AUTHORIZED))
)

(define-public (emergency-withdraw (token-trait <ft-trait>) (recipient principal))
  (let
    (
      (remaining-bal (try! (contract-call? token-trait get-balance LAUNCHPAD-ADDRESS)))
    )
    (try! (is-dao-or-extension))
    (as-contract (contract-call? token-trait transfer remaining-bal tx-sender recipient none))
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
    (asserts! (>= amount MIN-BUY) ERR-INSUFFICIENT-AMOUNT)
    (asserts! (> END-BLOCK block-height) ERR-PRESALE-ENDED)
    ;; check that hardcap has not been reached
    (asserts! (<= (+ amount stx-pool-balance) HARD-CAP) ERR-HARDCAP-EXCEEDED)
    ;; check that user has not exceeded max deposit
    (asserts! (<= (+ user-deposit amount) MAX-BUY) ERR-MAX-DEPOSIT-EXCEEDED)
    ;; user send stx to listing sig wallet
    (try! (stx-transfer? amount tx-sender LAUNCHPAD-ADDRESS))
    ;; increment pool balance
    (var-set stx-pool (+ (var-get stx-pool) amount))
    ;; update user deposits
    (map-set users-deposits {user-addr:tx-sender} (+ user-deposit amount))
    ;; update no of participants
    (if exists
      (var-set no-of-participants participants)
      (var-set no-of-participants (+ participants u1))
    )
    ;; send stx to listing wallet
    (if (and (>= (var-get stx-pool) HARD-CAP) (not (var-get stx-sent)))
      (send-stx)
      (ok true)
    )
  )
)

;; claim launchpad token
(define-public (claim-token (token-trait <ft-trait>)) 
  (let
    (
      (stx-pool-balance (var-get stx-pool))
      (recipient tx-sender)
      (exists (is-some (map-get? users-deposits {user-addr: recipient})))
      (user-deposit (get-user-deposits recipient))
      (user-allocation (calculate-allocation recipient))
      (claimed (check-if-claimed recipient))
    )
    (try! (check-is-initialized))
    (asserts! (or (< END-BLOCK block-height) (is-eq stx-pool-balance HARD-CAP)) ERR-PRESALE-NOT-ENDED)
    (asserts! exists ERR-NOT-PARTICIPANT)
    (asserts! (is-eq LAUNCHPAD-TOKEN (contract-of token-trait)) ERR-INVALID-TOKEN)
    (asserts! (not claimed) ERR-ALREADY-CLAIMED)

    ;; check if softcap is met or refund users
    (if (>= stx-pool-balance SOFT-CAP)  
      (begin 
        (try! (as-contract (contract-call? token-trait transfer user-allocation tx-sender recipient none)))
        (if (not (var-get stx-sent))
          (try! (send-stx))
          true
        )
      ) 
      (try! (as-contract (stx-transfer? user-deposit tx-sender recipient)))
    )
    ;; set user status to claimed 
    (ok (map-set user-claimed { user-addr: recipient } true))
  )
)

;; PRIVATE CALLS
(define-private (check-is-initialized)
  (ok (asserts! (var-get initialized) ERR-NOT-INITIALIZED))
)

(define-private (initialize)
  ;; sends token to address and sig wallet
  (begin
    ;; update this to be token trait of launchpad token
    (try! (contract-call? 'SP1X15DCKFMKX6X2HAJ29W5G06S67YSSWDEJKT7P4.gold-pirate transfer LISTING-ALLOCATION tx-sender LISTING-SIG-WALLET none))
    (try! (contract-call? 'SP1X15DCKFMKX6X2HAJ29W5G06S67YSSWDEJKT7P4.gold-pirate transfer SALE-ALLOCATION tx-sender LAUNCHPAD-ADDRESS none))
    (ok (var-set initialized true))
  )
)

(define-private (send-stx) 
  (let 
    (
      (balance (stx-get-balance LAUNCHPAD-ADDRESS))
    )
    (try! (as-contract (stx-transfer? balance tx-sender LISTING-SIG-WALLET)))
    (ok (var-set stx-sent true))
  )
)

(begin 
  (initialize)
)
