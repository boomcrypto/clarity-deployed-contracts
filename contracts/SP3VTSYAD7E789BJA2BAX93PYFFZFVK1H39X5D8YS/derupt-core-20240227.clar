;; .derupt-core-yyyymmdd Contract
(impl-trait 'SP3VTSYAD7E789BJA2BAX93PYFFZFVK1H39X5D8YS.derupt-core-trait.derupt-core-trait)
;; (impl-trait 'ST4YQYP4NGYAWFA6Z2FDPHBJ2DEM4FEEJPDVFT45.derupt-core-trait.derupt-core-trait)
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
;; (use-trait sip-010-trait 'ST1NXBK3K5YYMD6FD41MVNP3JS1GABZ8TRVX023PT.sip-010-trait-ft-standard.sip-010-trait)

;; Error
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-NOTFOUND (err u101))

;; Constant Equals Versioning via Contract Naming Convention
(define-constant derupt-core-yyyymmdd (as-contract tx-sender))

;; Get Costs
(define-read-only (get-chime-stx-amount)  
  (contract-call? .derupt-feed get-chime-stx-amount)
)

(define-read-only (get-chime-ft-amount)  
  (contract-call? .derupt-feed get-chime-ft-amount)
)

;; Log Stacking
(define-private (log-stack (stacker principal) (cityName (string-ascii 10)) (dislike-ft-total uint) (lockPeriod uint)) 
  (contract-call? .derupt-stackers log-stack tx-sender cityName dislike-ft-total lockPeriod)
)

;; Log Mining
(define-private (log-mine (miner principal) (cityName (string-ascii 10)) (mine-amounts (list 200 uint))) 
  (contract-call? .derupt-miners log-mine tx-sender cityName mine-amounts)
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
  (mine-amounts (list 200 uint)) 
  (alt-origin (string-utf8 256))
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
  (dev-stx-amount uint) 
  (gaia-stx-amount uint)
  (dev-principal (optional principal)) 
  (gaia-principal (optional principal))
  ) 
  (contract-call? .derupt-feed log-send-message content attachment-uri thumbnail-uri reply-to cityName mine-amounts alt-origin extras pay-dev pay-gaia dev-stx-amount gaia-stx-amount dev-principal gaia-principal)
)

;; Log Like Message
(define-private (log-like-message 
  (author-principal principal) 
  (like-ft-total uint) 
  (liked-txid (string-utf8 256)) 
  (contractId <sip-010-trait>)
  (pay-dev bool)
  (pay-gaia bool) 
  (dev-ft-total uint) 
  (gaia-ft-total uint)
  (dev-principal (optional principal)) 
  (gaia-principal (optional principal))
  ) 
  (contract-call? .derupt-sentiment log-like-message tx-sender author-principal like-ft-total liked-txid contractId pay-dev pay-gaia dev-ft-total gaia-ft-total dev-principal gaia-principal)
)

;; Log Dislike Message
(define-private (log-dislike-message 
  (author-principal principal) 
  (dislike-ft-total uint) 
  (lock-period uint) 
  (disliked-txid (string-utf8 256)) 
  (cityName (string-ascii 10)) 
  (contractId <sip-010-trait>)
  (pay-dev bool) 
  (pay-gaia bool) 
  (dev-ft-total uint) 
  (gaia-ft-total uint)
  (dev-principal (optional principal)) 
  (gaia-principal (optional principal))
  ) 
  (contract-call? .derupt-sentiment log-dislike-message tx-sender author-principal dislike-ft-total lock-period disliked-txid cityName contractId pay-dev pay-gaia dev-ft-total gaia-ft-total dev-principal gaia-principal)
)

;; CityCoin Mine Reward Claim
(define-public (claim-mining-reward (cityName (string-ascii 10)) (claimHeight uint)) 
  (begin 
    (try! (contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd006-citycoin-mining-v2 claim-mining-reward cityName claimHeight))
    ;; (try! (contract-call? 'ST355N8734E5PVX9538H2QGMFP38RE211D9E2B4X5.ccd006-city-mining claim-mining-block cityName claimHeight))
    (try! (contract-call? .derupt-miners log-mining-reward-claim cityName claimHeight))
    (ok true)
  )
)

;; CityCoin Stack Reward Claim
(define-public (claim-stacking-reward (cityName (string-ascii 10)) (cycleId uint)) 
  (begin 
    (try! (contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd007-citycoin-stacking claim-stacking-reward cityName cycleId))
    ;; (try! (contract-call? 'ST355N8734E5PVX9538H2QGMFP38RE211D9E2B4X5.ccd007-city-stacking claim-stacking-reward cityName cycleId))
    (try! (contract-call? .derupt-stackers log-stacking-reward-claim cityName cycleId))
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
  (mine-amounts (list 200 uint)) 
  (alt-origin (string-utf8 256))
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
  (dev-stx-amount uint) 
  (gaia-stx-amount uint)
  (dev-principal (optional principal)) 
  (gaia-principal (optional principal))
)
  (let 
    (
      (dev-stx-total dev-stx-amount) 
      (gaia-stx-total gaia-stx-amount) 
    ) 
      (try! (contract-call? .derupt-feed pay-stx cityName mine-amounts pay-dev pay-gaia dev-stx-amount gaia-stx-amount dev-principal gaia-principal))
      (is-ok (log-send-message content attachment-uri thumbnail-uri reply-to cityName mine-amounts alt-origin extras pay-dev pay-gaia dev-stx-total gaia-stx-total dev-principal gaia-principal))
      (is-ok (log-mine tx-sender cityName mine-amounts))
      (ok true)
  )
)

;; Core Operation Like Message
(define-public (like-message 
  (author-principal principal) 
  (liked-txid (string-utf8 256)) 
  (contractId <sip-010-trait>)
  (like-ft-amount uint) 
  (pay-dev bool) 
  (pay-gaia bool) 
  (dev-ft-amount uint) 
  (gaia-ft-amount uint)
  (dev-principal (optional principal)) 
  (gaia-principal (optional principal))
)
  (let
    (
      (like-ft-total like-ft-amount)
      (dev-ft-total dev-ft-amount)
      (gaia-ft-total gaia-ft-amount)
    )    
      (asserts! (not (is-eq tx-sender author-principal)) ERR-UNAUTHORIZED)
      (try! (contract-call? .derupt-feed pay-ft-like author-principal like-ft-total pay-dev pay-gaia dev-ft-total gaia-ft-total dev-principal gaia-principal contractId))
      (is-ok (log-like-message author-principal like-ft-total liked-txid contractId pay-dev pay-gaia dev-ft-total gaia-ft-total dev-principal gaia-principal))
      (ok true)
  )
)

;; Core Operation Dislike Message
(define-public (dislike-message 
  (author-principal principal) 
  (disliked-txid (string-utf8 256)) 
  (cityName (string-ascii 10)) 
  (contractId <sip-010-trait>)
  (dislike-ft-amount uint)
  (lockPeriod uint) 
  (pay-dev bool) 
  (pay-gaia bool) 
  (dev-ft-amount uint) 
  (gaia-ft-amount uint)
  (dev-principal (optional principal)) 
  (gaia-principal (optional principal))
)
  (let
    (
      (dislike-ft-total dislike-ft-amount)
      (dev-ft-total dev-ft-amount)
      (gaia-ft-total gaia-ft-amount)
    )
      (asserts! (not (is-eq tx-sender author-principal)) ERR-UNAUTHORIZED)
      (try! (contract-call? .derupt-feed pay-ft-dislike cityName dislike-ft-total lockPeriod pay-dev pay-gaia dev-ft-total gaia-ft-total dev-principal gaia-principal contractId))      
      (is-ok (log-dislike-message author-principal dislike-ft-total lockPeriod disliked-txid cityName contractId pay-dev pay-gaia dev-ft-total gaia-ft-total dev-principal gaia-principal))      
      (is-ok (log-stack tx-sender cityName dislike-ft-total lockPeriod))
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
  (mine-amounts (list 200 uint)) 
  (alt-origin (string-utf8 256))   
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
  (like-ft-amount uint)
  (pay-dev bool) 
  (pay-gaia bool) 
  (dev-stx-amount uint) 
  (gaia-stx-amount uint)
  (dev-ft-amount uint) 
  (gaia-ft-amount uint)
  (dev-principal (optional principal)) 
  (gaia-principal (optional principal))
)
    (begin
      (asserts! (not (is-eq tx-sender author-principal)) ERR-UNAUTHORIZED)
      (try! (send-message content attachment-uri thumbnail-uri (some reply-to) cityName mine-amounts alt-origin extras pay-dev pay-gaia dev-stx-amount gaia-stx-amount dev-principal gaia-principal))
      (try! (like-message author-principal liked-txid contractId like-ft-amount pay-dev pay-gaia dev-ft-amount gaia-ft-amount dev-principal gaia-principal))
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
  (mine-amounts (list 200 uint))  
  (alt-origin (string-utf8 256))  
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
  (dislike-ft-amount uint)
  (lockPeriod uint)
  (pay-dev bool) 
  (pay-gaia bool) 
  (dev-stx-amount uint) 
  (gaia-stx-amount uint)
  (dev-ft-amount uint) 
  (gaia-ft-amount uint)
  (dev-principal (optional principal)) 
  (gaia-principal (optional principal))
)
    (begin
      (asserts! (not (is-eq tx-sender author-principal)) ERR-UNAUTHORIZED)
      (try! (send-message content attachment-uri thumbnail-uri (some reply-to) cityName mine-amounts alt-origin extras pay-dev pay-gaia dev-stx-amount gaia-stx-amount dev-principal gaia-principal))
      (try! (dislike-message author-principal disliked-txid cityName contractId dislike-ft-amount lockPeriod pay-dev pay-gaia dev-ft-amount gaia-ft-amount dev-principal gaia-principal))
      (ok true)
    )
)

;; Set the derupt-core-yyyymmdd version in derupt-feed contract as a data variable
(contract-call? .derupt-feed set-derupt-core-contract derupt-core-yyyymmdd)