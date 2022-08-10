(define-constant ERR-UNAUTHORIZED (err u601))
(define-constant ERR-INTERNAL-ERROR (err u602))

(define-constant ERR-INCORRECT-ID (err u501))
(define-constant ERR-INCORRECT-STATE (err u502))
(define-constant ERR-INCORRECT-DATA (err u401))

(define-constant ERR-NOT-ENOUGH-BALANCE (err u301))
(define-constant ERR-NOT-ENOUGH-TIME (err u302))

(define-constant CONTRACT-OWNER tx-sender)

(define-constant STX1 u1000000)
(define-constant MIN-DEPOSIT (* STX1 u2))
(define-constant MIN-SERVICE-AMOUNT STX1)

(define-constant WITHDRAW-BLOCK-TIMEOUT u20)
(define-constant CANCEL-BLOCK-TIMEOUT u20)
(define-constant SERVICE-BLOCK-TIMEOUT u6000)
(define-constant SERVICE-COST-MAX-PCT u5)

(define-constant GAME-RESULT-NONE u0) 
(define-constant GAME-RESULT-FIRST-WON u1) 
(define-constant GAME-RESULT-SECOND-WON u2)
(define-constant GAME-RESULT-DRAW u3)
(define-constant GAME-RESULT-CANCELED u1000) ;; canceled

(define-data-var feePrincipal principal tx-sender)
(define-data-var feePct uint u500) ;; 5.0%  (in pct * 100)

(define-data-var prizePoolPrincipal principal tx-sender)
(define-data-var prizePoolPct uint u100) ;; 1.0%  (in pct * 100)

(define-map games
    (buff 8)
    {
        cost: uint,
        block: uint,
        p1: principal,
        p2: principal,
        result: uint
	}
)

(define-map players
    principal
    {
        balance: uint,
        block: uint,
	}
)    

(define-map serviceCost
    principal
    {
        block: uint,
	}
)  

(define-read-only (get-service-cost-block (player principal))
	(let
    (
       (serviceCostData (map-get? serviceCost player))
       (block (get block serviceCostData))
    )
       (default-to u0 block)
    )
) 

(define-read-only (get-balance (player principal))
	(let
    (
       (playerData (map-get? players player))
       (balance (get balance playerData))
    )
       (default-to u0 balance)
    )
) 

(define-read-only (get-my-balance)
	(let
    (
       (playerData (map-get? players tx-sender))
       (balance (get balance playerData))
    )
       (default-to u0 balance)
    )
) 

(define-read-only (get-last-action-block (player principal))
	(let
    (
       (playerData (map-get? players player))
       (block (get block playerData))
    )
       (default-to u0 block)
    )
) 

(define-public (set-fee-data (newFeePrincipal principal) (newFeePct uint) (newPrizePoolPrincipal principal) (newPrizePoolPct uint))
    (begin
       (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
 
       (var-set feePrincipal newFeePrincipal)
       (var-set feePct newFeePct)
       (var-set prizePoolPrincipal newPrizePoolPrincipal)
       (var-set prizePoolPct newPrizePoolPct)

       (ok true)
    ) 
)

(define-public (deposit (amount uint))
    (let 
    (
        (fee (calc-fee amount))
        (amountMinusFee (- amount fee))
    )
        (asserts! (>= amount MIN-DEPOSIT) ERR-INCORRECT-DATA) 

        (try! (stx-transfer? amountMinusFee tx-sender (contract-address)))
        (try! (stx-transfer? fee tx-sender (var-get feePrincipal)))
         
        (map-set players tx-sender {   
          balance: (+ (get-balance tx-sender) amountMinusFee),
          block: block-height
        })

        (ok true)
    )
)

(define-public (withdraw (amount uint))
    (let
    (
        (p tx-sender)
        (player (unwrap! (map-get? players p) ERR-INCORRECT-ID))
        (balance (get balance player))
        (block (get block player))
    )   
        (asserts! (>= balance amount) ERR-NOT-ENOUGH-BALANCE) 
        (asserts! (>= block-height (+ block WITHDRAW-BLOCK-TIMEOUT)) ERR-NOT-ENOUGH-TIME) 

        (unwrap! (as-contract (stx-transfer? amount tx-sender p)) ERR-INTERNAL-ERROR) 
         
        ;; allow to call withdraw without limitations
        (remove-from-player-balance p amount block) 

        (ok true)
    )
)

(define-public (apply-service-cost (p principal))
    (let
    (
        (player (unwrap! (map-get? players p) ERR-INCORRECT-ID))
        (balance (get balance player))
        (block (get block player))
        (lastServiceBlock (get-service-cost-block p))
        (maxBlock (max block lastServiceBlock))
        (minBlock (min block lastServiceBlock))
        (blockDeltaMax (- block-height maxBlock))
        (blockDeltaMin (- block-height minBlock))
        (cost (calc-service-cost balance blockDeltaMin))
    )
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
        (asserts! (>= balance MIN-SERVICE-AMOUNT) ERR-NOT-ENOUGH-BALANCE) 
        (asserts! (>= blockDeltaMax SERVICE-BLOCK-TIMEOUT) ERR-NOT-ENOUGH-TIME) 

        (unwrap! (as-contract (stx-transfer? cost tx-sender (var-get feePrincipal))) ERR-INTERNAL-ERROR) 
        (remove-from-player-balance p cost block) 

        (map-set serviceCost p {   
          block: block-height,
        })

        (ok true)
    )
)

(define-public (cancel-game (uid (buff 8)))
    (let
    (
        (game (unwrap! (map-get? games uid) ERR-INCORRECT-ID))
        (blockDelta (- block-height (get block game)))
    )
        (if (>= blockDelta CANCEL-BLOCK-TIMEOUT) 
            (complete-game uid GAME-RESULT-CANCELED)
            ERR-NOT-ENOUGH-TIME
        )
    )
)

(define-public (start-game (uid (buff 8)) (p1 principal) (p2 principal) (cost uint))
    (let
    (
        (player1Balance (get-balance p1))
        (player2Balance (get-balance p2))
    )
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)

        (asserts! (>= player1Balance cost) ERR-NOT-ENOUGH-BALANCE) 
        (asserts! (>= player2Balance cost) ERR-NOT-ENOUGH-BALANCE) 

        (remove-from-player-balance p1 cost block-height) 
        (remove-from-player-balance p2 cost block-height) 

        (map-set games uid {   
          block: block-height,
          cost: cost,
          p1: p1,
          p2: p2,
          result: GAME-RESULT-NONE
        })

        (ok true)
    )
)

(define-public (set-result (uid (buff 8)) (result uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
        (complete-game uid result)    
    )
)

(define-private (remove-from-player-balance (p principal) (amount uint) (block uint))
    (map-set players p {   
          balance: (- (get-balance p) amount),
          block: block 
    })
)

(define-private (add-to-player-balance (p principal) (amount uint) (block uint))
    (map-set players p {   
          balance: (+ (get-balance p) amount),
          block: block 
    })
)

(define-private (complete-game (uid (buff 8)) (result uint))
    (let
    (
        (game (unwrap! (map-get? games uid) ERR-INCORRECT-ID))
        (totalReward (* (get cost game) u2))
        (currentResult (get result game))
        (p1 (get p1 game))
        (p2 (get p2 game))
        (isWin (or (is-eq result GAME-RESULT-FIRST-WON) (is-eq result GAME-RESULT-SECOND-WON)))
        (prizePoolAmount (if isWin (calc-prize-pool totalReward) u0))
        (totalRewardMinusPrizePool (- totalReward prizePoolAmount))
    )
        (asserts! (is-eq currentResult GAME-RESULT-NONE) ERR-INCORRECT-STATE)
        (asserts! (not (is-eq result GAME-RESULT-NONE)) ERR-INCORRECT-DATA)

        (if (> prizePoolAmount u0) 
            (unwrap! (as-contract (stx-transfer? prizePoolAmount tx-sender (var-get prizePoolPrincipal))) ERR-INTERNAL-ERROR) 
        false)

        (send-rewards result totalRewardMinusPrizePool p1 p2)

        (map-set games uid (merge game {   
          result: result
        }))

        (ok true)
    )
)

(define-private (send-rewards (result uint) (totalReward uint) (p1 principal) (p2 principal))
    (let
        (
            (firstPlayerReward (if (is-eq result GAME-RESULT-FIRST-WON) totalReward (if (is-eq result GAME-RESULT-SECOND-WON) u0 (/ totalReward u2))))
            (secondPlayerReward (- totalReward firstPlayerReward))
        )

        (if (> firstPlayerReward u0)
            (add-to-player-balance p1 firstPlayerReward block-height)
            true
        )
        (if (> secondPlayerReward u0)
            (add-to-player-balance p2 secondPlayerReward block-height)
            true
        )
    )
)

(define-private (calc-fee (amount uint)) 
    (/ (* amount (var-get feePct)) u10000)
)

(define-private (calc-prize-pool (amount uint)) 
    (/ (* amount (var-get prizePoolPct)) u10000)
)

(define-private (calc-service-cost (amount uint) (blockDelta uint)) 
    (let 
    (
        (periods (/ blockDelta SERVICE-BLOCK-TIMEOUT))
        (pct (min periods SERVICE-COST-MAX-PCT))
    )
        (/ (* pct amount) u100)
    )
)

(define-private (contract-address) (as-contract tx-sender))

(define-private (max (a uint) (b uint)) (if (> a b) a b))
(define-private (min (a uint) (b uint)) (if (< a b) a b))
