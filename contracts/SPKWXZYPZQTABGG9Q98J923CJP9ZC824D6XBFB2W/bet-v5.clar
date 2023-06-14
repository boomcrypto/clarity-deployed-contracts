
;; bets-v5
;; version 2 of betting contract
(impl-trait .bet.bet-trait)

;;
;; =========
;; CONSTANTS
;; =========
;;

;; only contract owner is allowed to perform operation
(define-constant ERR-CONTRACT-OWNER-ONLY (err u1000))

;; only operator can perform this operation
(define-constant ERR-OPERATOR-ONLY (err u1001))

;; bet with this game-id already exists
(define-constant ERR-BET-EXISTS (err u1002))

;; game-id is invalid (i.e. too short)
(define-constant ERR-INVALID-GAME-ID (err u1003))

;; unable to retrieve timestamp for current block
(define-constant ERR-BLOCK-TIME-NOT-AVAILABLE (err u1004))

;; expiry time is in past
(define-constant ERR-EXPIRY-IN-PAST (err u1005))

;; bet amount is invalid (i.e. lower than current operator fee)
(define-constant ERR-INVALID-AMOUNT (err u1006))

;; unable to transfer operator comission
(define-constant ERR-OPERATOR-COMISSION (err u1007))

;; unsable to transfer STX amount ot the bet contract
(define-constant ERR-BET-TRANSFER (err u1008))

;; game with given id not found in list of bets
(define-constant ERR-NO-SUCH-BET (err u1009))

;; attempt to submit result to bet after its expiration time
(define-constant ERR-BET-EXPIRED (err u1010))

;; attempt to expire bet for which expiration time has not been
;; reached
(define-constant ERR-BET-NOT-EXPIRED (err u1011))

;; same user appears in both participant and creator role
;; for the bet
(define-constant ERR-SAME-USER (err u1012))

;; error transferring STX to reward pool
(define-constant ERR-REWARD-POOL-TRANSFER (err u1013))

;; error transferring STX to player wallet
(define-constant ERR-PLAYER-TRANSFER (err u1014))

;;
;; ==================
;; DATA MAPS AND VARS
;; ==================
;;
(define-data-var contract-owner principal tx-sender)
(define-data-var operator principal tx-sender)

(define-data-var operator-share uint u10)

(define-map created-bets (string-ascii 256)
  { creator: principal,
    amount: uint,
    expiry: uint })

(define-map active-bets (string-ascii 256)
  { creator: principal,
    amount: uint,
    expiry: uint,
    scoreA: uint,
    timeA: uint })

(define-map expired-bets (string-ascii 256)
  {
    creator: principal,
    amount: uint,
    expiry: uint,
    scoreA: (optional uint),
    timeA: (optional uint),
    participant: (optional principal)
  })

(define-map accepted-bets (string-ascii 256)
  {  creator: principal,
      amount: uint,
      expiry: uint,
      scoreA: uint,
       timeA: uint,
       participant: principal })

(define-map completed-bets (string-ascii 256)
  { creator: principal,
  amount: uint,
  expiry: uint,
  scoreA: uint,
  timeA: uint,
  participant: principal,
  scoreB: uint,
  timeB: uint
  })

  
  

;;
;; =================
;; PRIVATE FUNCTIONS
;; =================
;;

(define-private (assert-operator)
    (if (is-eq tx-sender (var-get operator))
        (ok true)
        ERR-OPERATOR-ONLY
        ))

(define-private (assert-contract-owner)
    (if (is-eq tx-sender (var-get contract-owner))
        (ok true)
        ERR-CONTRACT-OWNER-ONLY
        ))

(define-private (current-time)
    (default-to block-height (get-block-info? 
                              time block-height)))

(define-private (charge-operator-fee (amount uint))
    (let (
          (share (get-operator-share))
          (fee (/ (* amount share) u100))
          (oper (var-get operator))
          )
      (asserts! (> fee u0) ERR-OPERATOR-COMISSION)
      (stx-transfer? fee tx-sender oper)
      )
)

;;
;; ================
;; PUBLIC FUNCTIONS
;; ================
;;


;; Bet creation
(define-public (create (game-id (string-ascii 256))
                       (amount uint)
                       (expiry uint))
    (begin
      (asserts! (> (len game-id) u0) ERR-INVALID-GAME-ID)
      (asserts! (> amount u0) ERR-INVALID-AMOUNT)
      (asserts! (> expiry (current-time)) ERR-EXPIRY-IN-PAST)
      (asserts! (not (bet-exists game-id)) ERR-BET-EXISTS)

      (if (map-insert created-bets game-id
                      { creator: tx-sender,
                      amount: amount,
                      expiry: expiry })
          (begin
           (try! (charge-operator-fee amount))
           (unwrap! (stx-transfer? amount tx-sender 
                                   .bet-v5)
                    ERR-BET-TRANSFER)
           (ok true)
           )
          ERR-BET-EXISTS
          )
      )
  )


;; Check if given game-id is taken.
;; returns true if game-id represents a bet in any of
;; states. false it coresponding bet wasn't found.
(define-read-only (bet-exists (gameid (string-ascii 256)))
    (if (is-some (map-get? created-bets gameid))
        true
        (if (is-some (map-get? active-bets gameid))
            true
            (if (is-some (map-get? accepted-bets gameid))
                true
                (if (is-some (map-get? expired-bets gameid))
                    true
                    (if (is-some (map-get? completed-bets gameid))
                        true
                        false)
                    )
                )
            )
        )
  )

;; Return inactive bet (created, but not yet acted upon)
(define-read-only (get-inactive-bet (game-id (string-ascii 256)))
    (map-get? created-bets game-id))
                                   

;; Bet activation - returns true on success
(define-public (activate 
                 (game-id (string-ascii 256))
                 (score uint)
                 (timestamp uint))
    (let 
        (
         (entry (unwrap!
                 (map-get? created-bets game-id)
                 ERR-NO-SUCH-BET))
         )

      (try! (assert-operator))
      (asserts! (> (len game-id) u0) ERR-INVALID-GAME-ID)
      (asserts! (>= (get  expiry entry) timestamp) ERR-BET-EXPIRED)

     (map-insert active-bets game-id 
                 (merge entry
                         {
                         scoreA: score,
                         timeA: timestamp
                         }))
      (map-delete created-bets game-id)
      (ok true)
      )
  )


;; Get active bet
(define-read-only (get-active-bet (game-id (string-ascii 256)))
    (map-get? active-bets game-id))

;; Accepting the bet
(define-public (accept (game-id (string-ascii 256)))
    (let
        (
         (entry (unwrap!
                 (map-get? active-bets game-id)
                 ERR-NO-SUCH-BET))
         (creator (get creator entry))
         (amount (get amount entry))
         )
      (asserts! (>= (get expiry entry) (current-time))
                ERR-BET-EXPIRED)
      (asserts! (not (is-eq tx-sender creator))
                ERR-SAME-USER)
      (asserts! (> (len game-id) u0) ERR-INVALID-GAME-ID)
      (if (map-insert accepted-bets
                      game-id
                      (merge entry { participant: tx-sender }))
          (begin
           (try! (charge-operator-fee amount))
           (unwrap!
            (stx-transfer? amount tx-sender
                           .bet-v5)
            ERR-BET-TRANSFER)
           (ok (map-delete active-bets game-id))
           )
          ERR-BET-EXISTS)
      )
  )

;; Get accepted bet
(define-read-only (get-accepted-bet (game-id (string-ascii 256)))
    (map-get? accepted-bets game-id))



;; Operator can expire bet. As a result of this cleanup 
;; bet can transition either to expired or incomplete state,
;; initiating transfers accordingly.

(define-public (expire (game-id (string-ascii 256)))
    (let (
          (block-time (current-time))
          )
      (asserts! (> (len game-id) u0) ERR-INVALID-GAME-ID)
      (match 
       (map-get? created-bets game-id) inactive-bet
       (let (
             (amount (get amount inactive-bet))
             (expiry (get expiry inactive-bet))
             )
         (asserts! (> block-time expiry) ERR-BET-NOT-EXPIRED)
         (unwrap!
          (as-contract
           (contract-call?
            .creature-racer-reward-pool-v5
            receive-funds amount))
          ERR-REWARD-POOL-TRANSFER
          )
         (map-delete created-bets game-id)
         (ok (map-insert expired-bets game-id
                         (merge inactive-bet
                                { scoreA: none,
                                timeA: none,
                                participant: none })))
         )
       (match 
        (map-get? active-bets game-id) active-bet
        (let (
              (beneficary (get creator active-bet))
              (amount (get amount active-bet))
              (expiry (get expiry active-bet))
              )
          (asserts! (> block-time expiry) ERR-BET-NOT-EXPIRED)
          (unwrap!
           (as-contract
            (stx-transfer? amount tx-sender beneficary))
           ERR-PLAYER-TRANSFER)
          (map-delete active-bets game-id)
          (ok (map-insert expired-bets game-id
                          { creator: beneficary,
                          amount: amount,
                          expiry: (get expiry active-bet),
                          scoreA: (some (get scoreA active-bet)),
                          timeA: (some (get timeA active-bet)),
                          participant: none }))
          
          )
        (match
         (map-get? accepted-bets game-id) accepted-bet
         (let (
               (beneficary (get creator accepted-bet))
               (amount (get amount accepted-bet))
               (expiry (get expiry accepted-bet))
               )
           (asserts! (> block-time expiry) ERR-BET-NOT-EXPIRED)
           (unwrap!
            (as-contract
             (stx-transfer? (* u2 amount) tx-sender beneficary))
            ERR-PLAYER-TRANSFER)
           (map-delete accepted-bets game-id)
           (ok (map-insert expired-bets game-id
                           { creator: beneficary,
                           amount: amount,
                           expiry: (get expiry accepted-bet),
                           scoreA: (some (get scoreA accepted-bet)),
                           timeA: (some (get timeA accepted-bet)),
                           participant: (some (get participant
                                                   accepted-bet))
                           }
                           )
               )
           )
         ERR-NO-SUCH-BET)
        )
       )
      )
  )


;; Get expired bet
(define-read-only (get-expired-bet (game-id (string-ascii 256)))
    (map-get? expired-bets game-id))


;; Complete the competition and transfer the reward
;; needs to be called by operator
(define-public (complete (game-id (string-ascii 256))
                         (player principal)
                         (score uint)
                         (time uint))                         
    (let (
          (entry (unwrap! 
                  (map-get? accepted-bets game-id)
                  ERR-NO-SUCH-BET))
          (playerB (get participant entry))
          (scoreA (get scoreA entry))
          (playerA (get creator entry))
          (expiry (get expiry entry))
          (amount (get amount entry))
          )
      (asserts! (> (len game-id) u0) ERR-INVALID-GAME-ID)
      (asserts! (is-eq player playerB) ERR-NO-SUCH-BET)
      (asserts! (<= time expiry) ERR-BET-EXPIRED)
      (map-insert completed-bets game-id
                  (merge entry
                         { scoreB: score, 
                         timeB: time } ))
      (map-delete accepted-bets game-id)
      (if (> scoreA score)
          (as-contract
           (unwrap!
            (stx-transfer? (* u2 amount) tx-sender playerA)
            ERR-PLAYER-TRANSFER))
          (if (< scoreA score)
              (as-contract
               (unwrap!
                (stx-transfer? (* u2 amount) tx-sender playerB)
                ERR-PLAYER-TRANSFER))
              (as-contract
               (begin
                (unwrap!
                 (stx-transfer? amount tx-sender playerA) ERR-PLAYER-TRANSFER)
                (unwrap!
                 (stx-transfer? amount tx-sender playerB) ERR-PLAYER-TRANSFER)
                )
               )
              )
          )
      (ok true)
      )
  )

;; Get completed bet
(define-read-only (get-completed-bet (game-id (string-ascii 256)))
    (map-get? accepted-bets game-id))

;; return true if bet has expired as incomplete (i.e. had participant but no
;; participant's result has been submitted).
(define-read-only (is-bet-incomplete (game-id (string-ascii 256)))
    (let (
          (entry (unwrap! (map-get? expired-bets game-id) false))
          )
      (if (is-some (get participant entry)) true false)
      )
  )

;; Operator share
;; --------------

;; retrive current share
(define-read-only (get-operator-share)
    (var-get operator-share))

;; Setting new fee
;; can only be called by operator
;; Argument: new fee in microSTX
(define-public (set-operator-share (new-share uint))
    (begin
     (try! (assert-operator))
     (if (is-eq  new-share (get-operator-share))
         (ok false)
         (ok (var-set operator-share new-share)))
     )
  )




;; Roles management
(define-public (change-contract-owner (new-owner principal))
    (let ((current-owner (var-get contract-owner)))
     (try! (assert-contract-owner))
     (asserts! (not (is-eq current-owner new-owner))
               (ok false))
     (var-set contract-owner new-owner)
     (ok true)
     )
  )

(define-public (change-operator (new-operator principal))
    (let (
          (current-operator (var-get operator))
          )
      (try! (assert-contract-owner))
      (asserts! (not (is-eq current-operator new-operator))
                (ok false))
      (var-set operator new-operator)
      (ok true)
      )
  )
