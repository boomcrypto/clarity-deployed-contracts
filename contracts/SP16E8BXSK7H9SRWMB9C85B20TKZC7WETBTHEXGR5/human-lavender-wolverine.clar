(define-data-var owner principal tx-sender)
(define-map userBalances principal uint)
(define-map userStats principal (tuple (wins uint) (losses uint)))
(define-map lastFlipResult principal bool)
(define-data-var flipResult bool false)

;; Owner functions
(define-public (deposit-into-contract (amount uint))
    (begin
        (asserts! (is-eq tx-sender (var-get owner)) (err u1))
        (let ((currentBalance (default-to u0 (map-get? userBalances tx-sender))))
            (map-set userBalances tx-sender (+ currentBalance amount))
            (ok amount)
        )
    )
)

(define-public (withdraw-from-contract (amount uint))
    (begin
        (asserts! (is-eq tx-sender (var-get owner)) (err u1))
        (let ((currentBalance (default-to u0 (map-get? userBalances tx-sender))))
            (asserts! (>= currentBalance amount) (err u3))
            (map-set userBalances tx-sender (- currentBalance amount))
            (ok amount)
        )
    )
)

;; User deposit and withdraw functions
(define-public (deposit (amount uint))
    (begin
        (let ((currentBalance (default-to u0 (map-get? userBalances tx-sender))))
            (map-set userBalances tx-sender (+ currentBalance amount))
            (ok amount)
        )
    )
)

(define-public (withdraw (amount uint))
    (begin
        (let ((currentBalance (default-to u0 (map-get? userBalances tx-sender))))
            (asserts! (>= currentBalance amount) (err u4))
            (map-set userBalances tx-sender (- currentBalance amount))
            (ok amount)
        )
    )
)

;; Private random number generator function
(define-private (generate-random-number)
  (let ((block-timestamp (unwrap-panic (get-block-info? time u0))))
    (+ (mod block-timestamp u50) u1)
  )
)

;; Modified place bet and flip coin function
(define-public (placeBetAndFlipCoin (betAmount uint))
    (begin
        (let ((currentBalance (default-to u0 (map-get? userBalances tx-sender))))
            (asserts! (>= currentBalance betAmount) (err u5))
            (let ((randomNumber (generate-random-number)))
                (let ((randomResult (is-eq (mod randomNumber u2) u0))) ;; even for heads, odd for tails
                    (var-set flipResult randomResult)
                    (map-set lastFlipResult tx-sender randomResult)
                    (let ((currentUserStats (default-to (tuple (wins u0) (losses u0)) 
                                                        (map-get? userStats tx-sender))))
                        (if randomResult
                            (begin
                                (map-set userStats tx-sender 
                                         (tuple (wins (+ (get wins currentUserStats) u1)) 
                                                (losses (get losses currentUserStats))))
                                (map-set userBalances tx-sender (+ currentBalance betAmount)))
                            (begin
                                (map-set userStats tx-sender 
                                         (tuple (wins (get wins currentUserStats)) 
                                                (losses (+ (get losses currentUserStats) u1))))
                                (map-set userBalances tx-sender (- currentBalance betAmount))))
                    )
                    (ok (tuple (betAmount betAmount) (flipResult randomResult)))
                )
            )
        )
    )
)

;; Function to get user stats
(define-read-only (getUserStats (user principal))
    (default-to (tuple (wins u0) (losses u0)) (map-get? userStats user))
)

;; Function to get last flip result
(define-read-only (getLastFlipResult (user principal))
    (map-get? lastFlipResult user)
)

;; Function to get user balance
(define-read-only (getUserBalance (user principal))
    (default-to u0 (map-get? userBalances user))
)