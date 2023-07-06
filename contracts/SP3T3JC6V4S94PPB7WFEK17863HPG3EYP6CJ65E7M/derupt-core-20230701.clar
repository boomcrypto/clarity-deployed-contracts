;; .derupt-core Contract
(impl-trait 'SP3T3JC6V4S94PPB7WFEK17863HPG3EYP6CJ65E7M.derupt-core-trait.derupt-core-trait)
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Error
(define-constant notfound (err u101))
(define-constant insufficient-balance (err u102))

;; Constant Equals Versioning via Contract Naming Convention
(define-constant derupt-core-yyyymmdd (as-contract tx-sender))

;; Deployer principal
(define-constant APP_DEV tx-sender)

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
(define-private (log-stack (cityName (string-ascii 10)) (dislike-amount uint) (lockPeriod uint)) 
  (contract-call? .derupt-stackers log-stack cityName dislike-amount lockPeriod)
)

;; Log Mining
(define-private (log-mine (miner principal) (cityName (string-ascii 10)) (mine-amount uint)) 
  (contract-call? .derupt-miners log-mine tx-sender cityName mine-amount)
)

;; Log Send Message
(define-private (log-send-message 
  (content (string-utf8 256)) (attachment-uri (optional (string-utf8 256))) 
  (thumbnail-uri (optional (string-utf8 256))) (reply-to (optional (string-utf8 256))) 
  (cityName (string-ascii 10)) (alt-origin (optional (string-utf8 256)))
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
) 
  (contract-call? .derupt-feed log-send-message content attachment-uri thumbnail-uri reply-to cityName alt-origin extras)
)

;; Log Like Message
(define-private (log-like-message (author-principal principal) (like-amount uint) (liked-txid (string-utf8 256)) (contractId <sip-010-trait>)) 
  (contract-call? .derupt-sentiments log-like-message author-principal like-amount liked-txid contractId)
)

;; Log Dislike Message
(define-private (log-dislike-message (author-principal principal) (cityName (string-ascii 10)) (stacked-amount uint) (disliked-txid (string-utf8 256))) 
  (contract-call? .derupt-sentiments log-dislike-message author-principal cityName stacked-amount disliked-txid)
)

;; CityCoin Transfering
(define-public (transfer-citycoin (amount uint) (recipient principal) (contractId <sip-010-trait>))
  (contract-call? contractId transfer amount tx-sender recipient none)
)

;; CityCoin Mining
(define-public (mine-citycoin (cityName (string-ascii 10)) (amounts (list 200 uint)))
  (begin 
    (is-ok (contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd006-citycoin-mining-v2 mine cityName amounts))
    (ok true)
  )
)

;; CityCoin Mine Reward Claim
(define-public (claim-mining-reward (cityName (string-ascii 10)) (claimHeight uint)) 
  (begin 
    (is-ok (contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd006-citycoin-mining-v2 claim-mining-reward cityName claimHeight))
    (is-ok (contract-call? .derupt-miners log-mining-reward-claim cityName claimHeight))
    (ok true)
  )
)

;; CityCoin Stacking
(define-public (stack-citycoin (cityName (string-ascii 10)) (amount uint) (lockPeriod uint))
  (begin 
    (is-ok (contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd007-citycoin-stacking stack cityName amount lockPeriod))
    (is-ok (log-stack cityName amount lockPeriod))
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

;; Core Operation Send Message
(define-public (send-message 
  (content (string-utf8 256)) (attachment-uri (optional (string-utf8 256))) 
  (thumbnail-uri (optional (string-utf8 256))) (reply-to (optional (string-utf8 256))) 
  (cityName (string-ascii 10)) (alt-origin (optional (string-utf8 256)))
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
)
  (let 
    ((chime-amount (unwrap! (get-chime-amount) notfound)) (mine-amount (unwrap! (get-mine-amount) notfound))) 
      (is-ok (mine-citycoin cityName (list mine-amount)))
      (is-ok (stx-transfer? chime-amount tx-sender APP_DEV))
      (is-ok (log-send-message content attachment-uri thumbnail-uri reply-to cityName alt-origin extras))
      (is-ok (log-mine tx-sender cityName mine-amount))
      (ok true)
  )
)

;; Core Operation Like Message
(define-public (like-message (author-principal principal) (liked-txid (string-utf8 256)) (contractId <sip-010-trait>))
  (let
    (
      (like-amount (unwrap! (get-like-amount) notfound))
      (user-balance (unwrap! (contract-call? contractId get-balance tx-sender) notfound))
    )    
      (asserts! (> user-balance like-amount) insufficient-balance)  
      (is-ok (transfer-citycoin like-amount author-principal contractId))
      (is-ok (log-like-message author-principal like-amount liked-txid contractId))
      (ok true)
  )
)

;; Core Operation Dislike Message
(define-public (dislike-message (author-principal principal) (disliked-txid (string-utf8 256)) (cityName (string-ascii 10)))
  (let
    ((dislike-amount (unwrap! (get-dislike-amount) notfound)))
      (is-ok (stack-citycoin cityName dislike-amount u1))
      (is-ok (log-dislike-message author-principal cityName dislike-amount disliked-txid))      
      (ok true)
  )
)

;; Core Operation Favorable Reply Message
(define-public (favorable-reply-message 
  (content (string-utf8 256)) (author-principal principal) (attachment-uri (optional (string-utf8 256))) 
  (thumbnail-uri (optional (string-utf8 256))) (reply-to (optional (string-utf8 256))) 
  (liked-txid (string-utf8 256)) (cityName (string-ascii 10)) (alt-origin (optional (string-utf8 256))) 
  (contractId <sip-010-trait>)
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
)
    (begin
      (is-ok (send-message content attachment-uri thumbnail-uri reply-to cityName alt-origin extras))
      (is-ok (like-message author-principal liked-txid contractId))
      (ok true)
    )
)

;; Core Operation Unfavorable Reply Message
(define-public (unfavorable-reply-message 
  (content (string-utf8 256)) (author-principal principal) (attachment-uri (optional (string-utf8 256))) 
  (thumbnail-uri (optional (string-utf8 256))) (reply-to (optional (string-utf8 256)))   
  (disliked-txid (string-utf8 256)) (cityName (string-ascii 10)) (alt-origin (optional (string-utf8 256)))
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
)
    (begin
      (is-ok (send-message content attachment-uri thumbnail-uri reply-to cityName alt-origin extras))
      (is-ok (dislike-message author-principal disliked-txid cityName))
      (ok true)
    )
)

;; Set the derupt-core-yyyymmdd version in derupt-feed contract as a data variable
(contract-call? .derupt-feed set-derupt-core-contract derupt-core-yyyymmdd)