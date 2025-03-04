(define-constant ERR-PERMISSION-DENIED (err u4000))
(define-constant ERR-PRECONDITION-FAILED (err u4001))
(define-constant ERR-ZERO-AMOUNT (err u4002))
(define-constant ERR-CONTRACT-LOCKED (err u4999))
(define-data-var minimum-stx uint u1000000)  
(define-data-var minimum-btf uint u100000000)  
(define-data-var fee-rate uint u2) 
(define-data-var fee-burn-percentage uint u50) 
(define-public (buy-btf (stx-amount uint))
    (begin
        (asserts! (as-contract (contract-call? .btf-protocol-cpc-001 is-contract-unlocked tx-sender)) ERR-CONTRACT-LOCKED)
        (asserts! (>= stx-amount (var-get minimum-stx)) ERR-PRECONDITION-FAILED)  
        (let (
            (amounts (unwrap-panic (get-btf-for-stx-after-fee stx-amount)))
            (user tx-sender)
            (burn-amount (/ (* (get fee-amount amounts) (var-get fee-burn-percentage)) u100))
            (treasury-amount (- (get fee-amount amounts) burn-amount))
            (btf-to-mint (+ (get btf-to-user amounts) treasury-amount))
        )
            (try! (stx-transfer? stx-amount tx-sender .stx-treasury-002))
            (try! (as-contract (contract-call? .btf-token-001 mint btf-to-mint tx-sender)))
            (try! (as-contract (contract-call? .btf-token-001 transfer (get btf-to-user amounts) tx-sender user none)))  
            (try! (as-contract (contract-call? .btf-treasury-001 pay-fee treasury-amount)))
            (ok (get btf-to-user amounts))
        )
    )
)
(define-public (sell-btf (btf-amount uint))
    (begin
        (asserts! (as-contract (contract-call? .btf-protocol-cpc-001 is-contract-unlocked tx-sender)) ERR-CONTRACT-LOCKED)
        (asserts! (>= btf-amount (var-get minimum-btf)) ERR-PRECONDITION-FAILED)  
        (let (
            (amounts (unwrap-panic (get-stx-for-btf-after-fee btf-amount)))
            (user tx-sender)
            (burn-fee (/ (* (get fee-amount amounts) (var-get fee-burn-percentage)) u100))
            (treasury-amount (- (get fee-amount amounts) burn-fee))
            (burn-amount (+ (get btf-to-burn amounts) burn-fee))
        )
            (try! (contract-call? .btf-token-001 transfer btf-amount tx-sender (as-contract tx-sender) none))
            (try! (as-contract (contract-call? .btf-token-001 burn burn-amount)))
            (try! (as-contract (contract-call? .btf-treasury-001 pay-fee treasury-amount)))
            (try! (as-contract (contract-call? .stx-treasury-002 withdraw-stx (get stx-amount amounts) user)))
            (ok (get stx-amount amounts))
        )
    )
)
(define-public (convert-stx-to-btf (stx-amount uint) (recipient principal))
    (begin
        (asserts! (as-contract (contract-call? .btf-protocol-cpc-001 is-contract-unlocked tx-sender)) ERR-CONTRACT-LOCKED)
        (asserts! (contract-call? .btf-protocol-cpc-001 has-permission contract-caller u1) ERR-PERMISSION-DENIED)
        (asserts! (> stx-amount u0) ERR-ZERO-AMOUNT)
        (let (
            (btf-amount (calculate-btf-for-stx stx-amount))
        )
            (try! (stx-transfer? stx-amount tx-sender .stx-treasury-002))
            (try! (as-contract (contract-call? .btf-token-001 mint btf-amount recipient)))
            (ok btf-amount)
        )
    )
)
(define-public (convert-btf-to-stx (btf-amount uint) (recipient principal))
    (begin
        (asserts! (as-contract (contract-call? .btf-protocol-cpc-001 is-contract-unlocked tx-sender)) ERR-CONTRACT-LOCKED)
        (asserts! (contract-call? .btf-protocol-cpc-001 has-permission contract-caller u1) ERR-PERMISSION-DENIED)
        (asserts! (> btf-amount u0) ERR-ZERO-AMOUNT)
        (let (
            (stx-amount (calculate-stx-for-btf btf-amount))
        )
            (try! (contract-call? .btf-token-001 transfer btf-amount tx-sender (as-contract tx-sender) none))
            (try! (as-contract (contract-call? .btf-token-001 burn btf-amount)))
            (try! (as-contract (contract-call? .stx-treasury-002 withdraw-stx stx-amount recipient)))
            (ok stx-amount)
        )
    )
)
(define-read-only (get-current-price)
    (calculate-btf-price)
)
(define-read-only (get-fee-rate)
    (ok (var-get fee-rate))
)
(define-read-only (get-btf-for-stx-after-fee (stx-amount uint))
    (let (
        (btf-amount (calculate-btf-for-stx stx-amount))
        (fee-amount (/ (* btf-amount (var-get fee-rate)) u100))
    )
    (ok {
        btf-amount: btf-amount, 
        fee-amount: fee-amount, 
        btf-to-user: (- btf-amount fee-amount)    
    }))
)
(define-read-only (get-stx-for-btf-after-fee (btf-amount uint))
    (let (
        (fee-amount (/ (* btf-amount (var-get fee-rate)) u100))
        (btf-after-fee (- btf-amount fee-amount))
        (stx-amount (calculate-stx-for-btf btf-after-fee))
    )
    (ok {
        stx-amount: stx-amount, 
        fee-amount: fee-amount, 
        btf-to-burn: btf-after-fee   
    }))
)
(define-read-only (calculate-btf-price)
    (let (
        (stx-balance (contract-call? .stx-treasury-002 get-total-treasury))
        (btf-supply (unwrap-panic (contract-call? .btf-token-001 get-total-supply)))
    )
    (if (is-eq btf-supply u0)
        (ok u100000) 
        (ok (/ (* stx-balance u100000000) btf-supply)) 
    ))
)
(define-read-only (calculate-btf-for-stx (stx-amount uint))
    (let (
        (price (unwrap-panic (calculate-btf-price)))
    )
    (/ (* stx-amount u100000000) price)
    )
)
(define-read-only (calculate-stx-for-btf (btf-amount uint))
    (let (
        (price (unwrap-panic (calculate-btf-price)))
    )
    (/ (* btf-amount price) u100000000)
    )
)
(define-public (set-fee-rate (new-rate uint))
    (begin
        (asserts! (contract-call? .btf-protocol-cpc-001 has-permission contract-caller u10) ERR-PERMISSION-DENIED)
        (var-set fee-rate new-rate)
        (ok true)
    )
)
(define-public (set-fee-burn-percentage (new-percentage uint))
    (begin
        (asserts! (contract-call? .btf-protocol-cpc-001 has-permission contract-caller u10) ERR-PERMISSION-DENIED)
        (asserts! (<= new-percentage u100) ERR-PRECONDITION-FAILED)
        (var-set fee-burn-percentage new-percentage)
        (ok true)
    )
)
(define-read-only (get-fee-burn-percentage)
    (ok (var-get fee-burn-percentage))
)
(define-read-only (get-minimum-stx)
  (var-get minimum-stx)
)
(define-read-only (get-minimum-btf)
  (var-get minimum-btf)
)
(define-public (set-minimum-stx (new-minimum-stx uint))
  (begin
    (asserts! (contract-call? .btf-protocol-cpc-001 has-permission contract-caller u10) ERR-PERMISSION-DENIED)
    (var-set minimum-stx new-minimum-stx)
    (ok true)
  )
)
(define-public (set-minimum-btf (new-minimum-btf uint))
  (begin
    (asserts! (contract-call? .btf-protocol-cpc-001 has-permission contract-caller u10) ERR-PERMISSION-DENIED)
    (var-set minimum-btf new-minimum-btf)
    (ok true)
  )
)