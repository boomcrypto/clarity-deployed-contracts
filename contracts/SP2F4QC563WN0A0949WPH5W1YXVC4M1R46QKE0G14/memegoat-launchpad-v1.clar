(use-trait ft-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait)

;; ERRS

(define-constant ERR-INSUFFICIENT-AMOUNT (err u5001))
(define-constant ERR-NOT-AUTHORIZED (err u5009))
(define-constant ERR-BELOW-MIN-PERIOD (err u6000))
(define-constant ERR-PRESALE-STARTED (err u7000))
(define-constant ERR-PRESALE-NOT-STARTED (err u7001))
(define-constant ERR-PRESALE-ENDED (err u7002))
(define-constant ERR-PRESALE-NOT-ENDED (err u7003))
(define-constant ERR-NOT-PARTICIPANT (err u7004))
(define-constant ERR-ALREADY-CLAIMED (err u7005))
(define-constant ERR-POOL-NOT-FUNDED (err u8000))
(define-constant ERR-MAX-DEPOSIT-EXCEEDED (err u8001))
(define-constant ERR-HARDCAP-EXCEEDED (err u8002))
(define-constant ERR-MIN-TARGET-NOT-REACHED (err u8003))

(define-constant ONE_8 u100000000)
(define-constant ONE_6 u1000000)

;; DATA MAPS AND VARS

;; set caller as contract owner
(define-data-var contract-owner principal tx-sender)

;; amount allocated for presale
(define-constant MEMEGOAT-POOL u1350000000000000) ;; 1.35 Biliion Memegoat

;; hardcap
(define-constant PRESALE-HARDCAP u50000000000) ;; 50K STX 

;; softcap
(define-constant PRESALE-SOFTCAP u25000000000) ;; 25K STX

;; stx pool
(define-data-var stx-pool uint u0)

;; check for testnet
(define-data-var min-stx-deposit uint u20000000) ;; 20 STX
(define-data-var max-stx-deposit uint u200000000) ;; 200 STX

(define-data-var presale-started bool false)
(define-data-var no-of-participants uint u0)
(define-data-var duration uint u0)
(define-data-var release-block uint u0)
(define-data-var vault-funded bool false)

(define-map users-deposits
    { user-addr: principal }
    uint
)

(define-map user-claimed 
  { user-addr : principal }
  bool
)

;; MANAGEMENT CALLS

(define-public (set-contract-owner (owner principal))
  (begin
    (try! (check-is-owner)) 
    (ok (var-set contract-owner owner))
  )
)

(define-public (set-duration (no-of-blocks uint))
  (begin
    (try! (check-is-owner))
    (asserts! (not (var-get presale-started)) ERR-PRESALE-STARTED)
    (asserts! (>= no-of-blocks u144) ERR-BELOW-MIN-PERIOD) ;; rough estimate of one day
    (ok (var-set duration no-of-blocks))
  )
)

(define-public (fund-launchpad)
  (begin
    (try! (check-is-owner))
    (asserts! (not (var-get presale-started)) ERR-PRESALE-STARTED)
    (try! (contract-call? .memegoatstx transfer-fixed (decimals-to-fixed MEMEGOAT-POOL) tx-sender .memegoat-vault-v1 none))
    (var-set vault-funded true)
    (ok true)
  )
)

(define-public (start-presale)
  (begin
    (try! (check-is-owner))
    (asserts! (>= (var-get duration) u144) ERR-BELOW-MIN-PERIOD)
    ;; (asserts! (is-eq MEMEGOAT-POOL (try! (contract-call? .memegoat-vault-v1 get-balance .memegoatstx))) ERR-POOL-NOT-FUNDED)
    (asserts! (var-get vault-funded) ERR-POOL-NOT-FUNDED)
    (var-set presale-started true)
    (ok (var-set release-block (+ (var-get duration) block-height)))
  )
)

;; READ ONLY CALLS

(define-read-only (get-user-deposits (user-addr principal)) 
  (default-to u0 (map-get? users-deposits {user-addr: user-addr}))
)

(define-read-only (calculate-allocation (user-addr principal))
  (let
    ((user-deposit (get-user-deposits user-addr)))
    (* (get-stx-quote) user-deposit) 
  )
)

(define-read-only (check-if-claimed (user-addr principal)) 
  (default-to false (map-get? user-claimed { user-addr: user-addr }))
)

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

(define-read-only (get-stx-quote)
  (/ MEMEGOAT-POOL (var-get stx-pool))
)

(define-read-only (get-hardcap)
  (ok PRESALE-HARDCAP)
)

(define-read-only (get-softcap)
  (ok PRESALE-SOFTCAP)
)

(define-read-only (get-memegoatpool)
  (ok MEMEGOAT-POOL)
)

(define-read-only (get-stx-pool)
  (ok (var-get stx-pool))
)

(define-read-only (get-no-of-participants)
  (ok (var-get no-of-participants))
)

(define-read-only (get-release-block)
  (ok (var-get release-block))
)

(define-read-only (get-duration)
  (ok (var-get duration))
)

;; PRIVATE CALLS

(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)

(define-private (decimals-to-fixed (amount uint)) 
  (/ (* amount ONE_8) ONE_6)
)

;; depositStx
(define-public (deposit-stx (amount uint))
  (begin
    (asserts! (>= amount (var-get min-stx-deposit)) ERR-INSUFFICIENT-AMOUNT)
    (asserts! (var-get presale-started) ERR-PRESALE-NOT-STARTED)
    (asserts! (> (var-get release-block) block-height) ERR-PRESALE-ENDED)
    (let
      (
        (stx-pool-balance (var-get stx-pool))
        (exists (is-some (map-get? users-deposits { user-addr: tx-sender })))
        (user-deposit (get-user-deposits tx-sender))
        (participants (var-get no-of-participants))
      )

      ;; check that hardcap has not been reached
      (asserts! (<= (+ amount stx-pool-balance) PRESALE-HARDCAP) ERR-HARDCAP-EXCEEDED)

      ;; check that user has not exceeded max deposit
      (asserts! (<= (+ user-deposit amount) (var-get max-stx-deposit)) ERR-MAX-DEPOSIT-EXCEEDED)
    
      ;; transfer stx to vault
      (try! (stx-transfer? amount tx-sender .memegoat-vault-v1))

      ;; increment pool balance
      (var-set stx-pool (+ stx-pool-balance amount))

      ;; update user deposits
      (map-set users-deposits {user-addr:tx-sender} (+ user-deposit amount))

      ;; update no of participants
      (if exists
        (var-set no-of-participants participants)
        (var-set no-of-participants (+ participants u1))
      )
    )
    (ok (get-user-deposits tx-sender))
  )
)

;; claim memegoat
(define-public (claim-token)
  (begin
    (asserts! (var-get presale-started) ERR-PRESALE-NOT-STARTED)
    (asserts! (< (var-get release-block) block-height) ERR-PRESALE-NOT-ENDED)
    (let
      (
        (stx-pool-balance (var-get stx-pool))
        (sender tx-sender)
        (exists (is-some (map-get? users-deposits {user-addr: sender})))
        (user-allocation (calculate-allocation sender))
        (claimed (check-if-claimed sender))
      )

      (asserts! (>= stx-pool-balance PRESALE-SOFTCAP) ERR-MIN-TARGET-NOT-REACHED)

      (asserts! exists ERR-NOT-PARTICIPANT)
      (asserts! (not claimed) ERR-ALREADY-CLAIMED)
          
      ;; transfer token from vault
      (as-contract (try! (contract-call? .memegoat-vault-v1 transfer-ft .memegoatstx (decimals-to-fixed user-allocation) sender)))      
      
      ;; set user status to claimed 
      (map-set user-claimed { user-addr: sender } true)
    )
    (ok true)
  )
)

