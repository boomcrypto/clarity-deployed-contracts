(define-constant ERR-PERMISSION-DENIED (err u4000))
(define-constant ERR-PRECONDITION-FAILED (err u4001))
(define-constant ERR-ZERO-AMOUNT (err u4002))
(define-constant ERR-CONTRACT-LOCKED (err u4999))
(define-data-var minimum-stx uint u1000000)  
(define-data-var minimum-btf uint u100000000)  
(define-data-var fee-rate uint u2) 
(define-public (buy-btf (stx-amount uint))
    (begin
        (asserts! (as-contract (contract-call? .btf-protocol-cpc-001 is-contract-unlocked tx-sender)) ERR-CONTRACT-LOCKED)
        (asserts! (>= stx-amount (var-get minimum-stx)) ERR-PRECONDITION-FAILED)  
        (let (
            (amounts (unwrap-panic (get-btf-for-stx-after-fee stx-amount)))
            (user tx-sender)
        )
            (try! (contract-call? .stx-treasury-002 deposit-stx stx-amount))
            (try! (as-contract (contract-call? .btf-token-001 mint (get btf-to-user amounts) user)))
            (try! (as-contract (contract-call? .btf-treasury-002 mint-and-pay-fee (get fee-amount amounts))))
            (ok true)
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
        )
            (try! (contract-call? .btf-treasury-002 pay-fee (get fee-amount amounts)))
            (try! (contract-call? .btf-token-001 burn (get btf-to-burn amounts)))
            (try! (as-contract (contract-call? .stx-treasury-002 withdraw-stx (get stx-amount amounts) user)))
            (ok true)
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
            (try! (contract-call? .stx-treasury-002 deposit-stx stx-amount))
            (try! (as-contract (contract-call? .btf-token-001 mint btf-amount recipient)))
            (ok true)
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
            (try! (contract-call? .btf-token-001 burn btf-amount))
            (try! (as-contract (contract-call? .stx-treasury-002 withdraw-stx stx-amount recipient)))
            (ok true)
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
(contract-call? .btf-protocol-cpc-001 add-manager 'SP3QZNX3CGT6V7PE1PBK17FCRK1TP1AT02ZHQCMVJ.stx-fund-003 u1)