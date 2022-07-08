;; errors
(define-constant ERR-UNAUTHORIZED (err u601))
(define-constant ERR-INTERNAL-ERROR (err u602))
(define-constant ERR-DLC-ERROR (err u603))
(define-constant ERR-INCORRECT-ID (err u501))
(define-constant ERR-INCORRECT-STATE (err u502))
(define-constant ERR-INCORRECT-DATA (err u401))
(define-constant ERR-NOT-ENOUGH-BALANCE (err u301))
(define-constant ERR-NOT-ENOUGH-TIME (err u302))

;; CONTRACT OWNER - mm platform
(define-constant CONTRACT-OWNER tx-sender)

;; game states 
(define-constant GAME-STATE-MM u0) ;; first player started to search for an opponent
(define-constant GAME-STATE-STARTED u1) ;; second player accepted the bet
(define-constant GAME-STATE-COMPLETED u2) ;; game results are ready 
(define-constant GAME-STATE-RESOLVED u3) ;; rewards are resolved 

(define-constant GAME-RESULT-NONE u0) ;; result not known
(define-constant GAME-RESULT-FIRST-WON u1) ;; first player won
(define-constant GAME-RESULT-SECOND-WON u2) ;; second player won
(define-constant GAME-RESULT-DRAW u3) ;; draw

(define-constant STX1 u1000000)

(define-constant MIN-COST STX1) ;; 1 STX
(define-constant MAX-FEE (* u5 STX1)) ;; 5 STX
(define-constant MAX-FEE-PCT u200) ;; 2.0%
(define-constant REFUND-TIME-DELTA-S u36000) ;; 10 hours

(define-data-var feePrincipal principal tx-sender)
(define-data-var feePct uint u100) ;; 1.0%  (in pct * 100)

(define-map games
    (buff 8) ;; uid
    {
        cost: uint,
        creationTime: uint,
        player1: principal,
        player2: principal,
        gameState: uint,
        gameResult: uint
	})


;; controlled by owner
(define-public (set-fee-data (newFeePrincipal principal) (newFeePct uint))
    (begin
      (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
      (asserts! (<= newFeePct MAX-FEE-PCT) ERR-INCORRECT-DATA) ;; never ask for more than 2%
      (var-set feePrincipal newFeePrincipal)
      (var-set feePct newFeePct)
      (ok true)
    ) 
)

;; must be initiated by player1
(define-public (start-mm (uid (buff 8)) (cost uint))
    (let
      (
          (time (get-timestamp))
      )
      ;;(asserts! (> startTime last-block-time) ERR-INCORECT-DATA)  
      ;;(asserts! (> waitUntil startTime) ERR-INCORECT-DATA) 
      (asserts! (>= cost MIN-COST) ERR-INCORRECT-DATA) 

      (asserts! (is-none (map-get? games uid)) ERR-INCORRECT-ID) 
      (unwrap! (stx-transfer? cost tx-sender (contract-address)) ERR-NOT-ENOUGH-BALANCE) 
         
      (map-set games uid {   
         creationTime: time,
         ;;waitUntil: waitUntil,
         cost: cost,
         player1: tx-sender,
         player2: tx-sender,
         gameState: GAME-STATE-MM,
         gameResult: GAME-RESULT-NONE
      })

      (ok true)
    )
)

;; must be initiated by player1
(define-public (cancel-mm (uid (buff 8)))
    (let
    (
        (gameData (unwrap! (map-get? games uid) ERR-INCORRECT-ID))
        (gameState (get gameState gameData))
        (cost (get cost gameData))
        (player1 (get player1 gameData))
    ) 

    (asserts! (is-eq gameState GAME-STATE-MM) ERR-INCORRECT-STATE) 
    (asserts! (is-eq player1 tx-sender) ERR-UNAUTHORIZED) 

    
    (unwrap! (as-contract (stx-transfer? cost tx-sender player1)) ERR-INTERNAL-ERROR) 
        
    (map-set games uid 
        (merge gameData {
            gameState: GAME-STATE-RESOLVED
        })
    )

    (ok true)
    ) 
)

;; must be initiated by player2
(define-public (accept-mm (uid (buff 8)))
    (let
    (
        (gameData (unwrap! (map-get? games uid) ERR-INCORRECT-ID))
        (gameState (get gameState gameData))
        (cost (get cost gameData))
        (player2Balance (stx-get-balance tx-sender))
    ) 

    (asserts! (is-eq gameState GAME-STATE-MM) ERR-INCORRECT-STATE) 
    (asserts! (> player2Balance cost) ERR-NOT-ENOUGH-BALANCE) 

    (unwrap! (stx-transfer? cost tx-sender (contract-address)) ERR-NOT-ENOUGH-BALANCE) 
        
    (map-set games uid 
        (merge gameData {
            player2: tx-sender,
            gameState: GAME-STATE-STARTED
        })
    )

    (ok true)
    )
)

;; controlled by owner
(define-public (set-result (uid (buff 8)) (result uint))
    (let
    (
        (gameData (unwrap! (map-get? games uid) ERR-INCORRECT-ID))
        (gameState (get gameState gameData))
        (cost (get cost gameData))
        (player1 (get player1 gameData))
    ) 

    (asserts! (is-eq gameState GAME-STATE-STARTED) ERR-INCORRECT-STATE) 
    (asserts! (is-eq CONTRACT-OWNER tx-sender) ERR-UNAUTHORIZED) 
    
    (asserts! (or (is-eq result GAME-RESULT-FIRST-WON) (is-eq result GAME-RESULT-SECOND-WON) (is-eq result GAME-RESULT-DRAW)) ERR-INCORRECT-DATA) 

    (map-set games uid 
        (merge gameData {
            gameResult: result,
            gameState: GAME-STATE-COMPLETED
        })
    )

    (resolve-rewards uid)
    )
)

;; can be called by anyone
;; should be called by mm-platform
;; or by player if something is wrong with mm-platform at the moment
(define-public (resolve-rewards (uid (buff 8)))
    (let
    (
        (gameData (unwrap! (map-get? games uid) ERR-INCORRECT-ID))
        (gameState (get gameState gameData))
        (creationTime (get creationTime gameData))
        (cost (get cost gameData))
        (player1 (get player1 gameData))
        (player2 (get player2 gameData))
        (gameResult (get gameResult gameData))
        (totalReward (* cost u2))
        (fee (calc-fee totalReward))
        (finalReward (- totalReward fee))
        (time (get-timestamp))
        (timeDelta (- time creationTime))
    ) 
     
        (asserts! (or (is-eq gameState GAME-STATE-STARTED) (is-eq gameState GAME-STATE-COMPLETED)) ERR-INCORRECT-STATE) 

        (try! (try-to-resolve-money gameState gameResult timeDelta player1 player2 finalReward))
       
        (if (is-err (as-contract (stx-transfer? (- totalReward finalReward) tx-sender (var-get feePrincipal)))) ;; ignore fee transfer errors
            u0 u0
        )

        (map-set games uid 
            (merge gameData {
                gameState: GAME-STATE-RESOLVED
            })
        )

        (ok gameData)
    )
)

(define-private (try-to-resolve-money (gameState uint) (gameResult uint) (timeDelta uint) (player1 principal) (player2 principal) (finalReward uint))
    (if (is-eq gameState GAME-STATE-COMPLETED)
        (send-rewards gameResult finalReward player1 player2)

        (if (>= timeDelta REFUND-TIME-DELTA-S) 
            (refund (/ finalReward u2) player1 player2)
            ERR-NOT-ENOUGH-TIME
        )
    )
)

(define-private (send-rewards (gameResult uint) (totalReward uint) (player1 principal) (player2 principal))
    (let
        (
            (firstPlayerReward (if (is-eq gameResult GAME-RESULT-FIRST-WON) totalReward (if (is-eq gameResult GAME-RESULT-DRAW) (/ totalReward u2) u0)))
            (secondPlayerReward (- totalReward firstPlayerReward))
        )

        (if (> firstPlayerReward u0)
            (unwrap! (as-contract (stx-transfer? firstPlayerReward tx-sender player1)) ERR-INTERNAL-ERROR)
            true
        )
        (if (> secondPlayerReward u0)
            (unwrap! (as-contract (stx-transfer? secondPlayerReward tx-sender player2)) ERR-INTERNAL-ERROR) 
            true
        )

        (ok true)
    )
)

(define-private (calc-fee (totalReward uint)) 
    (let
        (
            (fee (/ (* totalReward (var-get feePct)) u10000))
            (finalFee (if (< fee MAX-FEE) fee MAX-FEE))
        )
        finalFee
    )
)

(define-private (refund (amount uint) (player1 principal) (player2 principal))
    (begin
        (unwrap! (as-contract (stx-transfer? amount tx-sender player1)) ERR-INTERNAL-ERROR)
        (unwrap! (as-contract (stx-transfer? amount tx-sender player2)) ERR-INTERNAL-ERROR) 
        (ok true)
    )
)

(define-private (get-timestamp)
    (default-to u0 (get-block-info? time (- block-height u1)))
)

(define-private (contract-address) (as-contract tx-sender)) 