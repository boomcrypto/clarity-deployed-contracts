;; .derupt-core-yyyymmdd Contract
(impl-trait 'SP28JH8V6E3VPC79EAG0XXT51YR9YJF6BG1RXAQM4.derupt-core-trait.derupt-core-trait)
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Error
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-NOTFOUND (err u101))

;; Constant Equals Versioning via Contract Naming Convention
(define-constant derupt-core-yyyymmdd (as-contract tx-sender))

;; Get Costs
(define-read-only (get-chime-amount)  
  (contract-call? .derupt-feed get-chime-amount)
)

(define-read-only (get-mine-amount)
  (contract-call? .derupt-feed get-mine-amount)
)

(define-read-only (get-like-amount)
  (contract-call? .derupt-feed get-like-amount)
)

(define-read-only (get-dislike-amount)
  (contract-call? .derupt-feed get-dislike-amount)
)

;; Log Stacking
(define-private (log-stack (stacker principal) (cityName (string-ascii 10)) (dislike-amount uint) (lockPeriod uint)) 
  (contract-call? .derupt-stackers log-stack tx-sender cityName dislike-amount lockPeriod)
)

;; Log Mining
(define-private (log-mine (miner principal) (cityName (string-ascii 10)) (mine-amount uint)) 
  (contract-call? .derupt-miners log-mine tx-sender cityName mine-amount)
)

;; Log Gifting
(define-private (log-gift (sender principal) (recipient principal) (is-stx bool) (contractId <sip-010-trait>) (amount uint) (memo (optional (buff 34)))) 
  (contract-call? .derupt-gifts log-gift sender recipient is-stx contractId amount memo)
)

;; Log Send Message
(define-private (log-send-message 
  (content (string-utf8 256)) 
  (attachment-uri (optional (string-utf8 256))) 
  (thumbnail-uri (optional (string-utf8 256))) 
  (reply-to (optional (string-utf8 256))) 
  (cityName (string-ascii 10)) 
  (alt-origin (optional (string-utf8 256)))
  (extras 
    (optional 
      (tuple 
        (arg0 (optional (string-utf8 256)))
        (arg1 (optional (string-utf8 256))) 
        (arg2 (optional (string-utf8 256))) 
        (arg3 (optional (string-utf8 256)))   
        (arg4 (optional (string-utf8 256))) 
        (arg5 (optional (string-utf8 256))) 
        (arg6 (optional (string-utf8 256)))
        (arg7 (optional (string-utf8 256))) 
        (arg8 (optional (string-utf8 256))) 
        (arg9 (optional (string-utf8 256)))
      )
    )
  )
  (pay-dev bool) 
  (pay-gaia bool) 
  (dev-amount uint) 
  (gaia-amount uint)
  (dev-principal (optional principal)) 
  (gaia-principal (optional principal))
  ) 
  (contract-call? .derupt-feed log-send-message content attachment-uri thumbnail-uri reply-to cityName alt-origin extras pay-dev pay-gaia dev-amount gaia-amount dev-principal gaia-principal)
)

;; Log Like Message
(define-private (log-like-message 
  (author-principal principal) (like-total uint) (liked-txid (string-utf8 256)) 
  (contractId <sip-010-trait>)
  (pay-dev bool)
  (pay-gaia bool) 
  (dev-total uint) 
  (gaia-total uint)
  (dev-principal (optional principal)) 
  (gaia-principal (optional principal))
  ) 
  (contract-call? .derupt-sentiments log-like-message author-principal like-total liked-txid contractId pay-dev pay-gaia dev-total gaia-total dev-principal gaia-principal)
)

;; Log Dislike Message
(define-private (log-dislike-message 
  (author-principal principal) (dislike-total uint) (disliked-txid (string-utf8 256)) 
  (cityName (string-ascii 10)) (contractId <sip-010-trait>)
  (pay-dev bool) 
  (pay-gaia bool) 
  (dev-total uint) 
  (gaia-total uint)
  (dev-principal (optional principal)) 
  (gaia-principal (optional principal))
  ) 
  (contract-call? .derupt-sentiments log-dislike-message author-principal dislike-total disliked-txid cityName contractId pay-dev pay-gaia dev-total gaia-total dev-principal gaia-principal)
)

;; CityCoin Mine Reward Claim
(define-public (claim-mining-reward (cityName (string-ascii 10)) (claimHeight uint)) 
  (begin 
    (is-ok (contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd006-citycoin-mining-v2 claim-mining-reward cityName claimHeight))
    (is-ok (contract-call? .derupt-miners log-mining-reward-claim cityName claimHeight))
    (ok true)
  )
)

;; CityCoin Stack Reward Claim
(define-public (claim-stacking-reward (cityName (string-ascii 10)) (cycleId uint)) 
  (begin 
    (is-ok (contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd007-citycoin-stacking claim-stacking-reward cityName cycleId))
    (is-ok (contract-call? .derupt-stackers log-stacking-reward-claim cityName cycleId))
    (ok true)
  )
)

(define-public (gift-message (sender principal) 
    (recipient principal) (is-stx bool) 
    (contractId <sip-010-trait>) (amount uint)
    (memo (optional (buff 34)))
  ) 
  (begin 
    (is-ok (log-gift sender recipient is-stx contractId amount memo))
    (ok true)
  )
)

;; Core Operation Send Message
(define-public (send-message 
  (content (string-utf8 256)) 
  (attachment-uri (optional (string-utf8 256))) 
  (thumbnail-uri (optional (string-utf8 256))) 
  (reply-to (optional (string-utf8 256))) 
  (cityName (string-ascii 10)) 
  (alt-origin (optional (string-utf8 256)))
  (extras 
    (optional 
      (tuple 
        (arg0 (optional (string-utf8 256)))
        (arg1 (optional (string-utf8 256))) 
        (arg2 (optional (string-utf8 256))) 
        (arg3 (optional (string-utf8 256)))   
        (arg4 (optional (string-utf8 256))) 
        (arg5 (optional (string-utf8 256))) 
        (arg6 (optional (string-utf8 256)))
        (arg7 (optional (string-utf8 256))) 
        (arg8 (optional (string-utf8 256))) 
        (arg9 (optional (string-utf8 256)))
      )
    )
  )
  (pay-dev bool) 
  (pay-gaia bool) 
  (dev-amount uint) 
  (gaia-amount uint)
  (dev-principal (optional principal)) 
  (gaia-principal (optional principal))
)
  (let 
    (
      (mine-cost (unwrap! (get-mine-amount) ERR-NOTFOUND))
      (dev-total (/ (* mine-cost dev-amount) u100))
      (gaia-total (/ (* mine-cost gaia-amount) u100))
      (mine-amount (unwrap! (get-mine-amount) ERR-NOTFOUND))
    ) 
      (try! (contract-call? .derupt-feed pay-stx cityName pay-dev pay-gaia dev-amount gaia-amount dev-principal gaia-principal))
      (is-ok (log-send-message content attachment-uri thumbnail-uri reply-to cityName alt-origin extras pay-dev pay-gaia dev-total gaia-total dev-principal gaia-principal))
      (is-ok (log-mine tx-sender cityName mine-amount))
      (ok true)
  )
)

;; Core Operation Like Message
(define-public (like-message 
  (author-principal principal) (liked-txid (string-utf8 256)) 
  (contractId <sip-010-trait>)
  (pay-dev bool) 
  (pay-gaia bool) 
  (dev-amount uint) 
  (gaia-amount uint)
  (dev-principal (optional principal)) 
  (gaia-principal (optional principal))
)
  (let
    (
      (like-total (unwrap! (get-like-amount) ERR-NOTFOUND))
      (dev-total (/ (* like-total dev-amount) u100))
      (gaia-total (/ (* like-total gaia-amount) u100))
    )    
      (asserts! (not (is-eq tx-sender author-principal)) ERR-UNAUTHORIZED)
      (try! (contract-call? .derupt-feed pay-ft-like author-principal pay-dev pay-gaia dev-total gaia-total dev-principal gaia-principal contractId))
      (is-ok (log-like-message author-principal like-total liked-txid contractId pay-dev pay-gaia dev-total gaia-total dev-principal gaia-principal))
      (ok true)
  )
)

;; Core Operation Dislike Message
(define-public (dislike-message 
  (author-principal principal) (disliked-txid (string-utf8 256)) 
  (cityName (string-ascii 10)) (contractId <sip-010-trait>)
  (pay-dev bool) 
  (pay-gaia bool) 
  (dev-amount uint) 
  (gaia-amount uint)
  (dev-principal (optional principal)) 
  (gaia-principal (optional principal))
)
  (let
    (
      (dislike-total (unwrap! (get-dislike-amount) ERR-NOTFOUND))
      (dev-total (/ (* dislike-total dev-amount) u100))
      (gaia-total (/ (* dislike-total gaia-amount) u100))
    )
      (asserts! (not (is-eq tx-sender author-principal)) ERR-UNAUTHORIZED)
      (try! (contract-call? .derupt-feed pay-ft-dislike cityName pay-dev pay-gaia dev-total gaia-total dev-principal gaia-principal contractId))      
      (is-ok (log-dislike-message author-principal dislike-total disliked-txid cityName contractId pay-dev pay-gaia dev-total gaia-total dev-principal gaia-principal))      
      (is-ok (log-stack tx-sender cityName dislike-total u1))
      (ok true)
  )
)

;; Core Operation Favorable Reply Message
(define-public (favorable-reply-message 
  (content (string-utf8 256)) 
  (author-principal principal) 
  (attachment-uri (optional (string-utf8 256))) 
  (thumbnail-uri (optional (string-utf8 256))) 
  (reply-to (string-utf8 256)) 
  (liked-txid (string-utf8 256)) 
  (cityName (string-ascii 10)) 
  (alt-origin (optional (string-utf8 256)))   
  (extras 
    (optional 
      (tuple 
        (arg0 (optional (string-utf8 256)))
        (arg1 (optional (string-utf8 256))) 
        (arg2 (optional (string-utf8 256))) 
        (arg3 (optional (string-utf8 256)))   
        (arg4 (optional (string-utf8 256))) 
        (arg5 (optional (string-utf8 256))) 
        (arg6 (optional (string-utf8 256)))
        (arg7 (optional (string-utf8 256))) 
        (arg8 (optional (string-utf8 256))) 
        (arg9 (optional (string-utf8 256)))
      )
    )
  )
  (contractId <sip-010-trait>)
  (pay-dev bool) 
  (pay-gaia bool) 
  (dev-amount uint) 
  (gaia-amount uint)
  (dev-principal (optional principal)) 
  (gaia-principal (optional principal))
)
    (begin
      (asserts! (not (is-eq tx-sender author-principal)) ERR-UNAUTHORIZED)
      (try! (send-message content attachment-uri thumbnail-uri (some reply-to) cityName alt-origin extras pay-dev pay-gaia dev-amount gaia-amount dev-principal gaia-principal))
      (try! (like-message author-principal liked-txid contractId pay-dev pay-gaia dev-amount gaia-amount dev-principal gaia-principal))
      (ok true)
    )
)

;; Core Operation Unfavorable Reply Message
(define-public (unfavorable-reply-message 
  (content (string-utf8 256)) 
  (author-principal principal) 
  (attachment-uri (optional (string-utf8 256))) 
  (thumbnail-uri (optional (string-utf8 256))) 
  (reply-to (string-utf8 256))   
  (disliked-txid (string-utf8 256)) 
  (cityName (string-ascii 10)) 
  (alt-origin (optional (string-utf8 256)))  
  (extras 
    (optional 
      (tuple 
        (arg0 (optional (string-utf8 256)))
        (arg1 (optional (string-utf8 256))) 
        (arg2 (optional (string-utf8 256))) 
        (arg3 (optional (string-utf8 256)))   
        (arg4 (optional (string-utf8 256))) 
        (arg5 (optional (string-utf8 256))) 
        (arg6 (optional (string-utf8 256)))
        (arg7 (optional (string-utf8 256))) 
        (arg8 (optional (string-utf8 256))) 
        (arg9 (optional (string-utf8 256)))
      )
    )
  )
  (contractId <sip-010-trait>)
  (pay-dev bool) 
  (pay-gaia bool) 
  (dev-amount uint) 
  (gaia-amount uint)
  (dev-principal (optional principal)) 
  (gaia-principal (optional principal))
)
    (begin
      (asserts! (not (is-eq tx-sender author-principal)) ERR-UNAUTHORIZED)
      (is-ok (send-message content attachment-uri thumbnail-uri (some reply-to) cityName alt-origin extras pay-dev pay-gaia dev-amount gaia-amount dev-principal gaia-principal))
      (is-ok (dislike-message author-principal disliked-txid cityName contractId pay-dev pay-gaia dev-amount gaia-amount dev-principal gaia-principal))
      (ok true)
    )
)

;; Set the derupt-core-yyyymmdd version in derupt-feed contract as a data variable
(contract-call? .derupt-feed set-derupt-core-contract derupt-core-yyyymmdd)