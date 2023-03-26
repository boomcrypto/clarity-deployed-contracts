;;
;;
;; Trait to define betting contract
;; ================================
;; 
(define-trait bet-trait
    (
     ;; create is called by a player who creates the competion
     (create (;; Input parameters: 
              ;; - game-id is any ASCII string identifying the competition
              ;;   could be a key to competition metadata or URL to its
              ;;   lobby.
              (string-ascii 256) 
              ;; - bet amount in uSTX
              uint
              ;; - deadline for result submission to be considered valid
              uint
              )
             (response;; Output:
              bool   ;; - true means that competition has been created
              uint)  ;; - error code in case of failure
             )
     

     ;; activate bet - called by trusted third party to submit
     ;; player A result in the game.
     (activate ( ;; Input parameters:
                ;; - game-id: id of the competition for which result
                ;;            is submited
                (string-ascii 256)
                ;; - score:   numeric value representing game result
                uint 
                ;; - timestamp: time when the game was played
                uint
                )
               (response ;; Output:
                bool     ;; - always true if call was successful
                uint)    ;; - error code in case of failure
               
               )


     ;; accept - called by player wanting to join a bet
     (accept ( ;; Input parameters:
              ;; - game-id: id of the competition intended to be joined
              (string-ascii 256)
              )
             (response ;; Output:
              bool     ;; - always true in case of success
              uint)    ;; - error code on failure
             )
     ;; expire - called by operator to clean up a bet after game
     ;;          expiration time
     (expire ( ;; Input parameters:
               ;; - game-id: id of the competition to be expired
              (string-ascii 256)
              )
             (response ;; Output:
              bool     ;; - true in case of succesful cleanup
              uint)    ;; - error code on failure
             )

     ;; complete - called by the operator to complete the competition,
     ;;            i.e. submit player B result to the game.
     ;;            Calling this triggers asset distribution according
     ;;            to bet result.
     (complete ( ;;  Input parameters:
                 ;;  - game-id: id of the competition which is being completed
                (string-ascii 256)
                ;; - player: principal of the player for which result is 
                ;;   being submitted
                principal
                ;; - score: score of this player
                uint
                ;; - time: time when score has been recorded
                uint
                )        
               (response
                bool
                uint)
               )
     )
  )
