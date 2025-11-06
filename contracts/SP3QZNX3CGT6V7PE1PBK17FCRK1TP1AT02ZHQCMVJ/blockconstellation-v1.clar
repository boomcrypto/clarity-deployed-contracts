;; Website: https://boltproto.org
(define-constant ERR-PRECONDITION-FAILED (err u412)) 
(define-constant ERR-PRINCIPAL-NOT-FOUND (err u404)) 
(define-constant ERR-PERMISSION-DENIED (err u403))   
(define-constant ERR-INVALID-VALUE (err u400))       
(define-constant ERR-CYCLE-NOT-FINISHED (err u4121)) 
(define-constant ERR-ALREADY-CLAIMED (err u4122))    
(define-constant ERR-NO-ALLOCATION (err u4123))      
(define-constant ERR-PRIZE-POOL-EMPTY (err u4124))   
(define-constant ERR-EXPIRATION-PERIOD-NOT-MET (err u4131)) 
(define-constant ERR-NO-UNCLAIMED-PRIZE (err u4132))       
(define-constant START-BLOCK tenure-height)          
(define-constant TOTAL-CONSTELLATIONS u24)           
(define-constant BLOCKS-PER-CYCLE u144)              
(define-data-var manager principal tx-sender)                 
(define-data-var min-allocation uint u1000)                
(define-data-var treasury-distribution-period uint u3)        
(define-data-var prize-expiration-period uint u5)             
(define-data-var reward-claim-fee uint u100)                  
(define-data-var treasury uint u0)                            
(define-data-var team-fee uint u0)                            
(define-data-var allocation-percentages
    {
        current-cycle: uint,    
        treasury: uint,         
        team-fee: uint,         
        referral-reward: uint   
    }
    {
        current-cycle: u30,     
        treasury: u40,          
        team-fee: u25,          
        referral-reward: u5     
    }
)
(define-map cycle uint 
    {
        prize: uint,                          
        prize-claimed: uint,                  
        constellation-allocation: (list 24 uint), 
        allocation-claimed: uint              
    })
(define-map allocated-by-user
    {
        cycle-id: uint,    
        user: principal    
    }
    {
        constellation-allocation: (list 24 uint), 
        claimed: bool      
    })
(define-map referral-reward principal
    {
        amount: uint,      
        block-update: uint 
    })
(define-read-only (get-manager)
  (var-get manager)
)
(define-public (set-manager (new-manager principal))
  (begin
    (asserts! (is-eq contract-caller (var-get manager)) ERR-PERMISSION-DENIED)
    (ok (var-set manager new-manager))
  )
)
(define-public (set-min-allocation (new-min-allocation uint))
  (begin
    (asserts! (is-eq contract-caller (var-get manager)) ERR-PERMISSION-DENIED)
    (asserts! (> new-min-allocation u0) ERR-INVALID-VALUE)
    (ok (var-set min-allocation new-min-allocation))
  )
)
(define-public (set-treasury-distribution-period (new-count uint))
  (begin
    (asserts! (is-eq contract-caller (var-get manager)) ERR-PERMISSION-DENIED)
    (asserts! (> new-count u0) ERR-INVALID-VALUE)
    (ok (var-set treasury-distribution-period new-count))
  )
)
(define-public (set-team-fee (new-fee uint))
  (begin
    (asserts! (is-eq contract-caller (var-get manager)) ERR-PERMISSION-DENIED)
    (asserts! (is-eq new-fee new-fee) ERR-INVALID-VALUE) 
    (ok (var-set team-fee new-fee))
  )
)
(define-public (set-reward-claim-fee (new-fee uint))
  (begin
    (asserts! (is-eq contract-caller (var-get manager)) ERR-PERMISSION-DENIED)
    (asserts! (> new-fee u0) ERR-INVALID-VALUE)
    (ok (var-set reward-claim-fee new-fee))
  )
)
(define-public (set-prize-expiration-period (new-count uint))
  (begin
    (asserts! (is-eq contract-caller (var-get manager)) ERR-PERMISSION-DENIED)
    (asserts! (> new-count u0) ERR-INVALID-VALUE)
    (ok (var-set prize-expiration-period new-count))
  )
)
(define-public (set-allocation-percentages (current-cycle-percent uint) (treasury-percent uint) (team-fee-percent uint) (referral-reward-percent uint) )
  (begin
    (asserts! (is-eq contract-caller (var-get manager)) ERR-PERMISSION-DENIED)
    (asserts! (is-eq (+ (+ (+ current-cycle-percent treasury-percent) team-fee-percent) referral-reward-percent) u100) ERR-PRECONDITION-FAILED)
    (ok (var-set allocation-percentages {
        current-cycle: current-cycle-percent,
        treasury: treasury-percent,
        team-fee: team-fee-percent,
        referral-reward: referral-reward-percent
    }))
  )
)
(define-read-only (get-random-number-from-block (block uint))
    (buff-to-uint-be (unwrap-panic (as-max-len? (unwrap-panic (slice? (unwrap-panic (get-tenure-info? vrf-seed block)) u16 u32)) u16)))
)
(define-read-only (get-blocks-per-cycle) 
    BLOCKS-PER-CYCLE
)
(define-read-only (get-start-block) 
    START-BLOCK
)
(define-read-only (get-treasury) 
    (var-get treasury)
)
(define-read-only (get-team-fee) 
    (var-get team-fee)
)
(define-read-only (get-treasury-distribution-period) 
    (var-get treasury-distribution-period)
)
(define-read-only (get-prize-expiration-period)
    (var-get prize-expiration-period)
)
(define-read-only (get-allocation-percentages) 
    (var-get allocation-percentages)
)
(define-read-only (get-min-allocation) 
    (var-get min-allocation)
)
(define-read-only (get-reward-claim-fee) 
    (var-get reward-claim-fee)
)
(define-read-only (get-current-cycle-id)
    (/ (- tenure-height START-BLOCK) BLOCKS-PER-CYCLE)
)
(define-read-only (get-constellation-block (cycle-id uint)) 
    (- (+ (* BLOCKS-PER-CYCLE (+ cycle-id u1)) START-BLOCK) u1)
)
(define-read-only (get-constellation (cycle-id uint))
    (mod (get-random-number-from-block (get-constellation-block cycle-id)) TOTAL-CONSTELLATIONS)
)
(define-read-only (get-referral-reward (user principal))
    (default-to
        {
            amount: u0,
            block-update: u0
        }
        (map-get? referral-reward user))
)
(define-read-only (get-allocated-by-user (cycle-id uint) (user principal))
    (default-to
        {
            constellation-allocation: (list u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0),
            claimed: false
        } 
        (map-get? allocated-by-user { cycle-id: cycle-id, user: user }))
)
(define-read-only (get-cycle (cycle-id uint))
    (default-to
        {
            prize: u0,
            prize-claimed: u0,
            constellation-allocation: (list u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0),
            allocation-claimed: u0
        }
        (map-get? cycle cycle-id))
)
(define-read-only (get-cycle-status (cycle-id uint))
    (let
        (
            (cycle-data (get-cycle cycle-id))
            (current-cycle-id (get-current-cycle-id))
            (cycle-end-block (get-constellation-block cycle-id))
        )
        (asserts! (< cycle-id current-cycle-id) ERR-PRECONDITION-FAILED)
        (ok
                {
                        cycle-prize: (get prize cycle-data),
                        cycle-prize-claimed: (get prize-claimed cycle-data),
                        cycle-constellation-allocation: (get constellation-allocation cycle-data),
                        cycle-allocation-claimed: (get allocation-claimed cycle-data),
                        cycle-winning-constellation: (get-constellation cycle-id),
                        cycle-end-block: cycle-end-block,
                        blockchain-stacks-height: stacks-block-height,
                        blockchain-tenure-height: tenure-height
                }
        )
    )
)
(define-read-only (get-cycle-user-status (cycle-id uint) (user principal))
  (let
    (
      (cycle-data (get-cycle cycle-id))
      (user-allocation-data (get-allocated-by-user cycle-id user))
      (current-cycle-id (get-current-cycle-id))
      (cycle-end-block (get-constellation-block cycle-id))
    )
    (asserts! (< cycle-id current-cycle-id) ERR-PRECONDITION-FAILED)
    (ok
        {
            cycle-prize: (get prize cycle-data),
            cycle-prize-claimed: (get prize-claimed cycle-data),
            cycle-constellation-allocation: (get constellation-allocation cycle-data),
            cycle-allocation-claimed: (get allocation-claimed cycle-data),
            cycle-winning-constellation: (get-constellation cycle-id),
            cycle-end-block: cycle-end-block,
            user-constellation-allocation: (get constellation-allocation user-allocation-data),
            user-claimed: (get claimed user-allocation-data),
            blockchain-stacks-height: stacks-block-height,
            blockchain-tenure-height: tenure-height
        }
    )
  )
)
(define-read-only (get-current-cycle-user-status (user principal))
    (let
        (
            (current-cycle-id (get-current-cycle-id))
            (cycle-data (get-cycle current-cycle-id))
            (user-allocation-data (get-allocated-by-user current-cycle-id user))
            (cycle-end-block (get-constellation-block current-cycle-id))
        )
        (ok
            {
                cycle-id: current-cycle-id,
                cycle-prize: 
                    (if (is-eq (get prize cycle-data) u0)
                        (/ (var-get treasury) (var-get treasury-distribution-period))
                        (get prize cycle-data)),
                cycle-prize-claimed: (get prize-claimed cycle-data),
                cycle-constellation-allocation: (get constellation-allocation cycle-data),
                cycle-allocation-claimed: (get allocation-claimed cycle-data),
                cycle-end-block: cycle-end-block,
                user-constellation-allocation: (get constellation-allocation user-allocation-data),
                blockchain-stacks-height: stacks-block-height,
                blockchain-tenure-height: tenure-height
            }
        )
    )
)
(define-read-only (get-current-cycle)
    (let
        (
            (current-cycle-id (get-current-cycle-id))
            (cycle-data (get-cycle current-cycle-id))
            (cycle-end-block (get-constellation-block current-cycle-id))
        )
        (ok
            {
                cycle-id: current-cycle-id,
                cycle-prize: 
                    (if (is-eq (get prize cycle-data) u0)
                        (/ (var-get treasury) (var-get treasury-distribution-period))
                        (get prize cycle-data)),
                cycle-prize-claimed: (get prize-claimed cycle-data),
                cycle-constellation-allocation: (get constellation-allocation cycle-data),
                cycle-allocation-claimed: (get allocation-claimed cycle-data),
                cycle-end-block: cycle-end-block,
                blockchain-stacks-height: stacks-block-height,
                blockchain-tenure-height: tenure-height
            }
        )
    )
)
(define-public (deposit-treasury (amount uint)) 
    (begin 
        (asserts! (> amount u0) ERR-INVALID-VALUE)
        (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer amount tx-sender (as-contract tx-sender) none))
        (var-set treasury (+ (var-get treasury) amount))
        (ok true)
    )
)
(define-public (withdraw-treasury (amount uint) (recipient principal))
    (begin
        (asserts! (is-eq contract-caller (var-get manager)) ERR-PERMISSION-DENIED)
        (asserts! (> amount u0) ERR-INVALID-VALUE)
        (let (
            (treasury-available (var-get treasury))
        )
            (asserts! (<= amount treasury-available) ERR-PRECONDITION-FAILED)
            (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer amount tx-sender recipient none)))
            (var-set treasury (- treasury-available amount))
            (ok true)
        )
    )
)
(define-public (withdraw-contract-funds (amount uint))
    (begin
        (asserts! (is-eq contract-caller (var-get manager)) ERR-PERMISSION-DENIED)
        (let (
                (fund-available (unwrap-panic (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance tx-sender ))))
            )
            (asserts! (<= amount fund-available) ERR-PRECONDITION-FAILED)
            (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer amount tx-sender (var-get manager) none)))
            (ok true)
        )
    )
)
(define-public (claim-reward (cycle-id uint))
    (begin 
        (asserts! (< cycle-id (get-current-cycle-id)) ERR-CYCLE-NOT-FINISHED)
        (let (
            (user contract-caller)
            (user-allocation (get-allocated-by-user cycle-id user))
            (cycle-data (get-cycle cycle-id))
            (winning-constellation (get-constellation cycle-id))
            (user-constellation-allocation (unwrap-panic (element-at? (get constellation-allocation user-allocation) winning-constellation)))
            (total-constellation-allocation (unwrap-panic (element-at? (get constellation-allocation cycle-data) winning-constellation)))
            (prize-remained (- (get prize cycle-data) (get prize-claimed cycle-data)))
            (constellation-allocation-remained (- total-constellation-allocation (get allocation-claimed cycle-data)))
            )
            (asserts! (not (get claimed user-allocation)) ERR-ALREADY-CLAIMED)
            (asserts! (> user-constellation-allocation u0) ERR-NO-ALLOCATION)
            (asserts! (> prize-remained u0) ERR-PRIZE-POOL-EMPTY)
            (let (
                    (user-prize (/ (* prize-remained user-constellation-allocation) constellation-allocation-remained))
                    (user-reward (if (> user-prize prize-remained) prize-remained user-prize))
                )
                (map-set cycle cycle-id 
                    (merge cycle-data { 
                        allocation-claimed: (+ (get allocation-claimed cycle-data) user-constellation-allocation),
                        prize-claimed: (+ (get prize-claimed cycle-data) user-reward)
                        }))   
                (map-set allocated-by-user { cycle-id: cycle-id, user: user } 
                    (merge user-allocation { claimed: true }))
                (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer user-reward tx-sender user none)))
                (ok true)
            )
        )
    )
)
(define-public (recover-expired-prizes (cycle-id uint))
    (begin 
        (let (
            (current-cycle-id (get-current-cycle-id))
            (expiration-period (get-prize-expiration-period))
        )
            (asserts! (>= (- current-cycle-id cycle-id) expiration-period) ERR-EXPIRATION-PERIOD-NOT-MET)
            (let (
                (cycle-data (get-cycle cycle-id))
                (unclaimed-prize (- (get prize cycle-data) (get prize-claimed cycle-data)))
            )
                (asserts! (> unclaimed-prize u0) ERR-NO-UNCLAIMED-PRIZE)
                (map-set cycle cycle-id 
                    (merge cycle-data { 
                        prize-claimed: (get prize cycle-data)
                    }))
                (var-set treasury (+ (var-get treasury) unclaimed-prize))
                (ok unclaimed-prize)
            )
        )
    )
)
(define-public (recover-zero-winner-cycle (cycle-id uint))
    (begin 
        (asserts! (< cycle-id (get-current-cycle-id)) ERR-CYCLE-NOT-FINISHED)
        (let (
            (cycle-data (get-cycle cycle-id))
            (winning-constellation (get-constellation cycle-id))
            (total-constellation-allocation (unwrap-panic (element-at? (get constellation-allocation cycle-data) winning-constellation)))
            (unclaimed-prize (- (get prize cycle-data) (get prize-claimed cycle-data)))
        )
            (asserts! (> unclaimed-prize u0) ERR-NO-UNCLAIMED-PRIZE)
            (asserts! (is-eq total-constellation-allocation u0) ERR-PRECONDITION-FAILED)
            (map-set cycle cycle-id 
                (merge cycle-data { 
                    prize-claimed: (get prize cycle-data)
                }))
            (var-set treasury (+ (var-get treasury) unclaimed-prize))
            (ok unclaimed-prize)
        )
    )
)
(define-public (allocate (amount uint) (constellation uint) (referral-user principal))
    (begin 
        (asserts! (>= amount (var-get min-allocation)) ERR-PRECONDITION-FAILED)
        (asserts! (< constellation TOTAL-CONSTELLATIONS) ERR-INVALID-VALUE)
        (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer amount tx-sender (as-contract tx-sender) none))
        (let
            (
                (current-cycle-id (get-current-cycle-id))
                (current-cycle (get-cycle current-cycle-id))
                (current-allocation-by-user (get-allocated-by-user current-cycle-id tx-sender))
            )
            (map-set cycle current-cycle-id 
                (merge current-cycle {
                    prize: (+ (calculate-prize-with-treasury-addition (get prize current-cycle)) (distribute-allocation amount referral-user)),
                    constellation-allocation: (update-constellation-allocation amount constellation (get constellation-allocation current-cycle))
                }))
            (map-set allocated-by-user { cycle-id: current-cycle-id, user: tx-sender } 
                { 
                    constellation-allocation: (update-constellation-allocation amount constellation (get constellation-allocation current-allocation-by-user)), 
                    claimed: false 
                })
            (ok true)
        )
    )
)
(define-public (claim-referral-reward)
    (let (
        (recipient tx-sender)
        (user-reward (get-referral-reward recipient))
        (reward-amount (get amount user-reward))
        (fee (var-get reward-claim-fee))
        (final-reward-amount (- reward-amount fee))
    )
        (asserts! (> reward-amount fee) ERR-PRECONDITION-FAILED)
        (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer final-reward-amount tx-sender recipient none)))
        (var-set team-fee (+ (var-get team-fee) fee))
        (map-set referral-reward recipient {
            amount: u0,
            block-update: stacks-block-height
        })
        (ok final-reward-amount)
    )
)
(define-public (claim-user-referral-reward (user principal))
    (begin
        (asserts! (is-eq contract-caller (var-get manager)) ERR-PERMISSION-DENIED)
        (let (
            (user-reward (get-referral-reward user))
            (reward-amount (get amount user-reward))
            (update-block (get block-update user-reward))
            (current-cycle-id (get-current-cycle-id))
            (expiration-period (var-get prize-expiration-period))
            (cycles-since-update (if (> update-block u0)
                                      (/ (- tenure-height update-block) BLOCKS-PER-CYCLE)
                                      u0))
        )
            (asserts! (> reward-amount u0) ERR-PRECONDITION-FAILED)
            (asserts! (>= cycles-since-update expiration-period) ERR-PRECONDITION-FAILED)
            (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer reward-amount tx-sender (var-get manager) none)))
            (map-set referral-reward user {
                amount: u0,
                block-update: stacks-block-height
            })
            (ok reward-amount)
        )
    )
)
(define-private (calculate-prize-with-treasury-addition (current-prize uint))
    (if (is-eq u0 current-prize)
        (let (
                (current-treasury (get-treasury))
                (prize (/ current-treasury (get-treasury-distribution-period)))
            )
            (var-set treasury (- current-treasury prize))
            prize
        )
        current-prize
    )
)
(define-private (update-constellation-allocation (amount uint) (constellation uint) (constellation-allocation (list 24 uint)))
    (let (
            (current-constellation-allocation (unwrap-panic (element-at? constellation-allocation constellation)))
            (new-constellation-allocation (unwrap-panic (replace-at? constellation-allocation constellation (+ current-constellation-allocation amount))))
        )
        new-constellation-allocation
    )
)
(define-private (distribute-allocation (amount uint) (referral-user principal))
    (let (
            (current-allocation-percentages (get-allocation-percentages))
            (current-cycle-allocation (/ (* amount (get current-cycle current-allocation-percentages)) u100))
            (treasury-allocation (/ (* amount (get treasury current-allocation-percentages)) u100))
            (referral-reward-allocation (/ (* amount (get referral-reward current-allocation-percentages)) u100))
            (team-fee-allocation (- (- (- amount current-cycle-allocation) treasury-allocation) referral-reward-allocation))
        )
        (var-set treasury (+ treasury-allocation (get-treasury)))
        (var-set team-fee (+ team-fee-allocation (get-team-fee)))
        (map-set referral-reward referral-user 
            {
                amount: (+ (get amount (get-referral-reward referral-user)) referral-reward-allocation), 
                block-update: stacks-block-height 
            })
        current-cycle-allocation
    )
)
