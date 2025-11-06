;; PEPE Burn-to-Play Competition Contract
;; Daily competition where highest burner wins 90% of total burned
;; 10% gets permanently burned, 1% taken as fee

;; Constants
(define-constant BURN-ADDRESS 'SP000000000000000000002Q6VF78) 
(define-constant THIS-CONTRACT (as-contract tx-sender))
(define-constant FAKTORY 'SM3NY5HXXRNCHS1B65R78CYAC1TQ6DEMN3C0DN74S) 

;; Epoch system using Bitcoin block timing
(define-constant EPOCH-LENGTH u144) ;; ~1 day at ~10min/block
(define-constant GENESIS-BLOCK burn-block-height)

;; Percentages (basis points for precision)
(define-constant WINNER-PERCENTAGE u9000) ;; 90%
(define-constant BASIS-POINTS u10000)     ;; 100%

;; Error constants
(define-constant ERR-UNAUTHORIZED (err u401))
(define-constant ERR-INVALID-AMOUNT (err u402))
(define-constant ERR-NO-BURNS-THIS-EPOCH (err u403))
(define-constant ERR-ALREADY-SETTLED (err u404))
(define-constant ERR-TOKEN-TRANSFER-FAILED (err u405))
(define-constant ERR-INSUFFICIENT-PARTICIPANTS (err u406))
(define-constant ERR-EPOCH-NOT-ENDED (err u407))

;; Data structures
(define-map epoch-burns
  { user: principal, epoch: uint }
  { amount: uint, block-height: uint }
)

(define-map epoch-totals
  uint ;; epoch
  { 
    total-burned: uint,
    participant-count: uint,
    highest-burner: (optional principal),
    highest-amount: uint,
    settled: bool
  }
)

(define-map user-total-burns
  principal
  uint ;; total amount burned across all epochs
)

;; Helper functions
(define-read-only (current-epoch) 
  (/ (- burn-block-height GENESIS-BLOCK) EPOCH-LENGTH))

(define-read-only (calc-epoch-start (epoch uint))
  (+ GENESIS-BLOCK (* EPOCH-LENGTH epoch)))

(define-read-only (calc-epoch-end (epoch uint))
  (- (+ GENESIS-BLOCK (* EPOCH-LENGTH (+ epoch u1))) u1))

(define-read-only (is-epoch-ended (epoch uint))
  (> burn-block-height (calc-epoch-end epoch)))

(define-read-only (get-epoch-total (epoch uint))
  (default-to 
    { total-burned: u0, participant-count: u0, highest-burner: none, highest-amount: u0, settled: false }
    (map-get? epoch-totals epoch)))

(define-read-only (get-user-burn-for-epoch (user principal) (epoch uint))
  (default-to 
    { amount: u0, block-height: u0 }
    (map-get? epoch-burns { user: user, epoch: epoch })))

(define-read-only (get-user-total-burns (user principal))
  (default-to u0 (map-get? user-total-burns user)))

(define-read-only (get-blocks-until-epoch-end)
  (let ((current (current-epoch)))
    (if (>= burn-block-height (calc-epoch-end current))
        u0
        (- (calc-epoch-end current) burn-block-height))))

;; Main burn function
(define-public (burn-to-compete (amount uint))
  (let (
    (current (current-epoch))
    (user tx-sender)
    (existing-burn (get-user-burn-for-epoch user current))
    (epoch-data (get-epoch-total current))
  )

    ;; Check epoch isn't already settled
    (asserts! (not (get settled epoch-data)) ERR-ALREADY-SETTLED)

    ;; Must burn a positive amount
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    
    ;; Transfer PEPE tokens to this contract first
    (try! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz transfer 
           amount 
           user 
           THIS-CONTRACT 
           (some 0x6920676f7420746865206a75696365))) ;; "i got the juice"
    
    ;; Calculate new amounts
    (let (
      (previous-amount (get amount existing-burn))
      (new-total-amount (+ previous-amount amount))
      (new-epoch-total (+ (get total-burned epoch-data) amount))
      (new-participant-count (if (is-eq previous-amount u0) 
                                (+ (get participant-count epoch-data) u1)
                                (get participant-count epoch-data)))
      (is-new-highest (> new-total-amount (get highest-amount epoch-data)))
      (new-highest-burner (if is-new-highest (some user) (get highest-burner epoch-data)))
      (new-highest-amount (if is-new-highest new-total-amount (get highest-amount epoch-data)))
    )
      ;; Update user's burn for this epoch
      (map-set epoch-burns 
        { user: user, epoch: current }
        { amount: new-total-amount, block-height: burn-block-height })
      
      ;; Update epoch totals
      (map-set epoch-totals current {
        total-burned: new-epoch-total,
        participant-count: new-participant-count,
        highest-burner: new-highest-burner,
        highest-amount: new-highest-amount,
        settled: false
      })
      
      ;; Update user's total burns across all time
      (map-set user-total-burns user 
        (+ (get-user-total-burns user) amount))
      
      ;; Emit event
      (print {
        contract: THIS-CONTRACT,
        token-contract: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz,
        event: "burn-to-compete",
        user: user,
        epoch: current,
        amount: amount,
        total-user: new-total-amount,
        block-height: burn-block-height,
        is-leader: is-new-highest,
        total-burned: new-epoch-total,
        participant-count: new-participant-count,
        highest-burner: new-highest-burner,
        highest-amount: new-highest-amount,
        settled: false
      })
      
      (ok true)
    )
  )
)

;; Settle epoch - distribute rewards and burn tokens
(define-public (settle-epoch (epoch uint))
  (let (
    (epoch-data (get-epoch-total epoch))
    (total-burned (get total-burned epoch-data))
    (participant-count (get participant-count epoch-data))
    (highest-burner (get highest-burner epoch-data))
  )
    ;; Check that epoch actually had burns
    (asserts! (> total-burned u0) ERR-NO-BURNS-THIS-EPOCH)

    ;; Check epoch has ended
    (asserts! (is-epoch-ended epoch) ERR-EPOCH-NOT-ENDED)
    
    ;; Check not already settled
    (asserts! (not (get settled epoch-data)) ERR-ALREADY-SETTLED)
    
    ;; Check minimum participants (2)
    (asserts! (>= participant-count u2) ERR-INSUFFICIENT-PARTICIPANTS)
    
    ;; Check we have a highest burner
    (asserts! (is-some highest-burner) ERR-NO-BURNS-THIS-EPOCH)
    
    (let (
      (winner (unwrap-panic highest-burner))
      (winner-amount (/ (* total-burned WINNER-PERCENTAGE) BASIS-POINTS))
      (remaining-amount (- total-burned winner-amount))
      (fee-amount (/ remaining-amount u10))        ;; 10% of remaining = 1% of total
      (burn-amount (- remaining-amount fee-amount)) ;; 90% of remaining = 9% of total
    )
      ;; Send winner their reward (90%)
      (if (> winner-amount u0)
            (try! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz transfer 
                    winner-amount 
                    THIS-CONTRACT 
                    winner 
                    (some 0x6920676f7420746865206a75696365))))
            true) 
      
      ;; Burn tokens (9%)
      (if (> burn-amount u0)
            (try! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz transfer 
                    burn-amount 
                    THIS-CONTRACT 
                    BURN-ADDRESS 
                    (some 0x70657065206275726e)))) ;; "pepe burn"
            true) 
      
      ;; Send fee to contract owner (1%)
      (if (> fee-amount u0)
            (try! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz transfer 
                    fee-amount 
                    THIS-CONTRACT 
                    FAKTORY
                    (some 0x6920676f7420746865206a75696365)))) 
            true) 
      
      ;; Mark epoch as settled
      (map-set epoch-totals epoch 
        (merge epoch-data { settled: true }))
      
      ;; Emit settlement event
      (print {
        contract: THIS-CONTRACT,
        token-contract: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz,
        event: "epoch-settled",
        epoch: epoch,
        total-burned: total-burned,
        participant-count: participant-count,
        highest-burner: highest-burner,
        highest-amount: (get highest-amount epoch-data),
        settled: true,
        winner: winner,
        winner-amount: winner-amount,
        burn-amount: burn-amount,
        fee-amount: fee-amount,
        block-height: burn-block-height,
      })
      
      (ok true)
    )
  )
)

;; Refund function for epochs with only 1 participant
(define-public (refund-solo-epoch (epoch uint))
  (let (
    (epoch-data (get-epoch-total epoch))
    (total-burned (get total-burned epoch-data))
    (participant-count (get participant-count epoch-data))
    (highest-burner (get highest-burner epoch-data))
  )
    ;; Check that epoch actually had burns
    (asserts! (> total-burned u0) ERR-NO-BURNS-THIS-EPOCH)

    ;; Check epoch has ended
    (asserts! (is-epoch-ended epoch) ERR-EPOCH-NOT-ENDED)
    
    ;; Check not already settled
    (asserts! (not (get settled epoch-data)) ERR-ALREADY-SETTLED)
    
    ;; Check exactly 1 participant
    (asserts! (is-eq participant-count u1) ERR-INSUFFICIENT-PARTICIPANTS)
    
    ;; Check we have a highest burner
    (asserts! (is-some highest-burner) ERR-NO-BURNS-THIS-EPOCH)
    
    (let ((solo-user (unwrap-panic highest-burner)))
      ;; Refund all tokens to the solo participant
      (try! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz transfer 
             total-burned 
             THIS-CONTRACT 
             solo-user 
             (some 0x6920676f7420746865206a75696365))))
      
      ;; Mark epoch as settled
      (map-set epoch-totals epoch 
        (merge epoch-data { settled: true }))
      
      ;; Emit refund event
      (print {
        contract: THIS-CONTRACT,
        token-contract: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz,
        event: "epoch-refunded",
        epoch: epoch,
        solo-user: solo-user,
        total-burned: total-burned,
        participant-count: participant-count,
        highest-burner: highest-burner,
        highest-amount: (get highest-amount epoch-data),
        settled: true,
      })
      
      (ok true)
    )
  )
)