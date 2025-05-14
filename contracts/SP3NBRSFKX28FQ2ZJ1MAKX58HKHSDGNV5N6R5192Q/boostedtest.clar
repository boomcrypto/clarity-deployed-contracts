
(define-data-var contract-owner (optional principal) none)

(define-read-only (get-owner)
     (var-get contract-owner)
)

(define-map deposits principal {deadline:uint, amount: uint, expiration:uint, borrower: principal, dailyprice:uint})

;; expiration, borrower,

(define-public (set-owner )
(begin
    (asserts! (is-eq tx-sender contract-caller) (err "mismatch caller"))
    (asserts! (is-eq (var-get contract-owner) none) (err "owner already set"))
    (var-set contract-owner (some tx-sender))
    (ok true)
)
)

(define-public (deposit (amount uint) )
    (begin
        (map-set deposits tx-sender {deadline: u0, amount: amount, expiration:u0, borrower:tx-sender, dailyprice:u0})
        (stx-transfer? amount tx-sender (as-contract tx-sender))
    )
)

(define-read-only (get-user-deposit (user principal))
     (get amount (unwrap-panic (map-get? deposits user) ))
)

(define-read-only (get-new-deposit (user principal) (withdrawal uint))
     (- (get amount (unwrap-panic (map-get? deposits user) )) withdrawal )
)

(define-public (claim)
    (begin
        (asserts! (is-eq (some contract-caller) (var-get contract-owner)) (err u104))
        (as-contract (stx-transfer? (stx-get-balance tx-sender) tx-sender (unwrap-panic (var-get contract-owner))))
    )
)

(define-public (withdraw (amount uint) )
    (begin 
    (asserts! (> (get-new-deposit tx-sender amount) u0) (err u10))
    (map-set deposits tx-sender {deadline:u0, amount: (get-new-deposit tx-sender amount), expiration:u0,borrower:tx-sender,dailyprice:u0})
    (stx-transfer? amount (as-contract tx-sender) tx-sender)
    )
)

(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)


(define-private (transfer-ft (token-contract <ft-trait>) (amount uint) (sender principal) (recipient principal))
    (contract-call? token-contract transfer amount sender recipient none)
)

;; to add the trait clarinet requirements add SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard

(define-constant sbtc-token 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)





(define-private (update-map (days uint) (borrower principal) (owner principal))
    (map-set deposits owner {deadline: (+ (get deadline (unwrap-panic (map-get? deposits owner) )) u144), amount: (get amount (unwrap-panic (map-get? deposits owner) )), expiration: (get expiration (unwrap-panic (map-get? deposits owner) )) , borrower:borrower , dailyprice:u10000})
)

(define-private (get-cost (days uint) (borrower principal) (owner principal))
    (* (* (get amount (unwrap-panic (map-get? deposits owner) )) days) u10000)
)


(define-private (get-expiration (owner principal))
    (get expiration (unwrap-panic (map-get? deposits owner) ))
)

(define-private (get-deadline (owner principal))
    (get deadline (unwrap-panic (map-get? deposits owner) ))
)

(define-private (get-new-deadline (days uint) )
    (+ burn-block-height (* days u144))
)

;;TODO, add a check, I cannot set the deposit if I have already lent out actively
(define-public (deposit_sbt (amount uint) )
    (begin
        (map-set deposits tx-sender {deadline: u0, amount: amount, expiration:(+ burn-block-height u4320) , borrower:tx-sender , dailyprice:u10000})
        (transfer-ft sbtc-token amount tx-sender (as-contract tx-sender))
    )
)


(define-public (withdraw_sbtc (amount uint) )
    (begin 
    (asserts! (> (get-new-deposit tx-sender amount) u0) (err u10))
    (asserts! (< (get deadline (unwrap-panic (map-get? deposits tx-sender) )) burn-block-height) (err u11))
    (map-set deposits tx-sender {deadline:u0, amount: (get-new-deposit tx-sender amount), expiration:u0 , borrower:tx-sender , dailyprice:u10000})  ;;let's provide liquidity for one month
    (transfer-ft sbtc-token amount (as-contract tx-sender) tx-sender)
    )
)


(define-read-only (get-deposits (owner principal) )
(unwrap-panic (map-get? deposits owner))
)

;;I can borrow only if new deadline is before expiration
;;I can borrow if deadline is the past
;;I pay the right amount
(define-public (borrow_stacking (owner principal) (days uint) )
    (begin
        (asserts! (> (get-expiration owner) (get-new-deadline days)) (err u22))
        (asserts! (< (get-deadline owner) burn-block-height ) (err u22))
        (update-map days tx-sender owner)
        (stx-transfer? (get-cost days tx-sender owner) tx-sender owner)
    )
)