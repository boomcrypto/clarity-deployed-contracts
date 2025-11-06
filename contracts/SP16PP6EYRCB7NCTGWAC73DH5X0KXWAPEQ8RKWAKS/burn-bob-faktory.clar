;; Daily BOB Burn Leaderboard Contract
;; Tracks daily burns of 1 BOB token to cant-be-evil.stx using epochs

;; Constants
(define-constant BURN-ADDRESS 'SP000000000000000000002Q6VF78) ;; cant-be-evil.stx actual address
(define-constant DAILY-BURN-AMOUNT u1000000) ;; 1 BOB with 6 decimals
(define-constant THIS-CONTRACT (as-contract tx-sender))

;; Epoch system using Bitcoin block timing (burn-block-height)
(define-constant EPOCH-LENGTH u144) ;; ~1 day at ~10min/block (Bitcoin timing)
(define-constant GENESIS-BLOCK burn-block-height)
(define-constant GENESIS-EPOCH u0) ;; Always epoch 0

;; Error constants
(define-constant ERR-UNAUTHORIZED (err u401))
(define-constant ERR-INVALID-AMOUNT (err u402))
(define-constant ERR-ALREADY-BURNED-TODAY (err u403))
(define-constant ERR-TOKEN-TRANSFER-FAILED (err u404))

;; Data structures
(define-map epoch-burns 
  { user: principal, epoch: uint } 
  { block-height: uint, burned: bool }  ;; block-height = Bitcoin block when burn happened
)

(define-map user-stats 
  principal 
  { 
    epoch: uint,        ;; last epoch user was active
    total-burns: uint,  ;; total epochs user has burned
    streak-start: uint, ;; EPOCH when current streak started
    streak-end: uint,   ;; EPOCH when current streak last continued  
    max-streak: uint    ;; longest streak ever (in epochs)
  }
)

(define-map epoch-participants uint (list 1000 principal))

;; Helper functions
(define-read-only (current-epoch) (calc-epoch burn-block-height))

(define-read-only (calc-epoch (block uint))
  (/ (- block GENESIS-BLOCK) EPOCH-LENGTH))

(define-read-only (calc-epoch-start (epoch uint))
  (+ GENESIS-BLOCK (* EPOCH-LENGTH epoch)))

(define-read-only (calc-epoch-end (epoch uint))
  (- (+ GENESIS-BLOCK (* EPOCH-LENGTH (+ epoch u1))) u1))

(define-read-only (get-user-stats (user principal))
  (default-to 
    { epoch: GENESIS-EPOCH, total-burns: u0, streak-start: u0, streak-end: u0, max-streak: u0 }
    (map-get? user-stats user)
  )
)

(define-read-only (has-burned-this-epoch (user principal))
  (let ((current-epoch (current-epoch)))
    (is-some (map-get? epoch-burns { user: user, epoch: current-epoch }))
  )
)

;; come back to this later
(define-read-only (get-current-streak (user principal))
  (let ((stats (get-user-stats user))
        (current (current-epoch)))
    (if (and (> (get streak-end stats) u0)
             (or (is-eq (get streak-end stats) current)
                 (is-eq (get streak-end stats) (- current u1))))
        (+ (- (get streak-end stats) (get streak-start stats)) u1)
        u0)
  )
)

(define-read-only (get-epoch-participants (epoch uint))
  (default-to (list) (map-get? epoch-participants epoch))
)

(define-read-only (get-burn-record (user principal) (epoch uint))
  (map-get? epoch-burns { user: user, epoch: epoch })
)

;; Get blocks until next epoch
(define-read-only (get-blocks-until-next-epoch)
  (let ((current-epoch-start (calc-epoch-start (current-epoch))))
    (- (+ current-epoch-start EPOCH-LENGTH) burn-block-height)
  )
)

;; Main burn function
(define-public (daily-burn)
  (let (
    (current (current-epoch))
    (user tx-sender)
    (current-stats (get-user-stats user))
    (participants (get-epoch-participants current))
  )
    ;; Check if user already burned this epoch
    (asserts! (not (has-burned-this-epoch user)) ERR-ALREADY-BURNED-TODAY)
    
    ;; Transfer 1 BOB to burn address
    (try! (contract-call? 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G.built-on-bitcoin-stxcity transfer 
           DAILY-BURN-AMOUNT 
           user 
           BURN-ADDRESS 
           (some 0x6461696c792d626f622d6275726e))) ;; "daily-bob-burn" in hex
    
    ;; Record the burn  
    (map-set epoch-burns 
      { user: user, epoch: current }
      { block-height: burn-block-height, burned: true }
    )
    
    ;; Update epoch participants
    (map-set epoch-participants current (unwrap-panic (as-max-len? (append participants user) u1000)))
    
    ;; Calculate new streak
    (let (
      (last-active-epoch (get streak-end current-stats))
      (is-continuing-streak (is-eq last-active-epoch (- current u1)))
      (new-streak-start (if is-continuing-streak 
                           (get streak-start current-stats)
                           current))
      (new-streak-end current)
      (current-streak-length (+ (- new-streak-end new-streak-start) u1))
      (new-max-streak (max (get max-streak current-stats) current-streak-length))
      (new-total-burns (+ (get total-burns current-stats) u1))
    )
      ;; Update user stats
      (map-set user-stats user {
        epoch: current,
        total-burns: new-total-burns,
        streak-start: new-streak-start,
        streak-end: new-streak-end,
        max-streak: new-max-streak
      })
      
      ;; Emit event
      (print {
        contract: THIS-CONTRACT,
        token-contract: 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G.built-on-bitcoin-stxcity,
        event: "daily-burn",
        user: user,
        epoch: current,
        block-height: burn-block-height,
        total-burns: new-total-burns,
        current-streak: current-streak-length,
        max-streak: new-max-streak
      })
      
      (ok true)
    )
  )
)

;; Utility function
(define-read-only (max (x uint) (y uint)) (if (>= x y) x y))