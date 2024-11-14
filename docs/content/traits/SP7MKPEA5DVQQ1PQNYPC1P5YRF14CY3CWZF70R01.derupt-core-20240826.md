---
title: "Trait derupt-core-20240826"
draft: true
---
```
;; .derupt-core-yyyymmdd Contract
;; (impl-trait 'ST1ZK0A249B4SWAHVXD70R13P6B5HNKZAA0WNTJTR.derupt-core-trait.derupt-core-trait)
(impl-trait 'SP7MKPEA5DVQQ1PQNYPC1P5YRF14CY3CWZF70R01.derupt-core-trait.derupt-core-trait)

;; (use-trait derupt-ext-trait 'ST1ZK0A249B4SWAHVXD70R13P6B5HNKZAA0WNTJTR.derupt-ext-trait.derupt-ext)
(use-trait derupt-ext-trait 'SP7MKPEA5DVQQ1PQNYPC1P5YRF14CY3CWZF70R01.derupt-ext-trait.derupt-ext)

;; (use-trait sip-010-trait 'ST3D8PX7ABNZ1DPP9MRRCYQKVTAC16WXJ7VCN3Z97.sip-010-trait-ft-standard.sip-010-trait)
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

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
(define-private (log-stack (stacker principal) (dislike-ft-total uint) (lockPeriod uint)) 
  (contract-call? .derupt-stackers log-stack tx-sender dislike-ft-total lockPeriod)
)

;; Log Mining
(define-private (log-mine (miner principal) (mine-amounts (list 200 uint))) 
  (contract-call? .derupt-miners log-mine tx-sender mine-amounts)
)

;; Log Gifting
(define-private (log-gift 
  (sender principal) 
  (recipient principal) 
  (is-stx bool) 
  (contractId <sip-010-trait>) 
  (amount uint) 
  (memo (optional (buff 34)))
  (ext (optional <derupt-ext-trait>))
) 
  (contract-call? .derupt-gifts log-gift sender recipient is-stx contractId amount memo ext)
)

;; Log Send Message
(define-private (log-send-message 
  (content (string-utf8 256)) 
  (attachment-uri (optional (string-utf8 256))) 
  (thumbnail-uri (optional (string-utf8 256))) 
  (reply-to (optional (string-utf8 256))) 
  (mine-amounts (list 200 uint)) 
  (alt-origin (string-utf8 256))
  (ext (optional <derupt-ext-trait>))
  (pay-dev bool) 
  (pay-gaia bool) 
  (dev-stx-amount uint) 
  (gaia-stx-amount uint)
  (dev-principal (optional principal)) 
  (gaia-principal (optional principal))
) 
  (contract-call? .derupt-feed log-send-message content attachment-uri thumbnail-uri reply-to mine-amounts alt-origin ext pay-dev pay-gaia dev-stx-amount gaia-stx-amount dev-principal gaia-principal)
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
  (ext (optional <derupt-ext-trait>))
) 
  (contract-call? .derupt-sentiment log-like-message tx-sender author-principal like-ft-total liked-txid contractId pay-dev pay-gaia dev-ft-total gaia-ft-total dev-principal gaia-principal ext)
)

;; Log Dislike Message
(define-private (log-dislike-message 
  (author-principal principal) 
  (dislike-ft-total uint) 
  (lock-period uint) 
  (disliked-txid (string-utf8 256)) 
  (contractId <sip-010-trait>)
  (pay-dev bool) 
  (pay-gaia bool) 
  (dev-ft-total uint) 
  (gaia-ft-total uint)
  (dev-principal (optional principal)) 
  (gaia-principal (optional principal))
  (ext (optional <derupt-ext-trait>))
) 
  (contract-call? .derupt-sentiment log-dislike-message tx-sender author-principal dislike-ft-total lock-period disliked-txid contractId pay-dev pay-gaia dev-ft-total gaia-ft-total dev-principal gaia-principal ext)
)

;; Mine Reward Claim
(define-private (claim-mining-reward (minerBlockHeight uint)) 
  (contract-call? .cryptocash-core claim-mining-reward minerBlockHeight)
)
(define-public (claim-mining-reward-list (claimHeights (list 200 uint))) 
  (begin 
    (map claim-mining-reward claimHeights)
    (try! (contract-call? .derupt-miners log-mining-reward-claim claimHeights))
    (ok true)
  )
)

;; Stack Reward Claim
(define-private (claim-stacking-reward (targetCycle uint)) 
  (contract-call? .cryptocash-core claim-stacking-reward targetCycle)
)
(define-public (claim-stacking-reward-list (targetCycles (list 32 uint))) 
  (begin 
    (map claim-stacking-reward targetCycles)
    (try! (contract-call? .derupt-stackers log-stacking-reward-claim targetCycles))
    (ok true)
  )
)

(define-public (gift-message (sender principal) 
    (recipient principal) (is-stx bool) 
    (contractId <sip-010-trait>) (amount uint)
    (memo (optional (buff 34)))
    (ext (optional <derupt-ext-trait>))
    (extras (optional (list 10 
      {
        stringutf8: (optional (string-utf8 256)), 
        stringascii: (optional (string-ascii 256)), 
        uint: (optional uint), 
        int: (optional int), 
        principal: (optional principal), 
        bool: (optional bool),
        buff: (optional (buff 34)),
        proxy: (optional (buff 2048))
      }))
    )    
  ) 
  (begin    

    ;; Executes extention contract function if defined
    (if (not (is-none ext))
      (let 
        ((targetContract (unwrap! ext ERR-NOTFOUND))) 
        (try! (contract-call? targetContract exec-ext-func extras))
        true
      )
      false
    )

    (is-ok (log-gift sender recipient is-stx contractId amount memo ext))
    (ok true)
  )
)

;; Core Operation Send Message
(define-public (send-message 
  (content (string-utf8 256)) 
  (attachment-uri (optional (string-utf8 256))) 
  (thumbnail-uri (optional (string-utf8 256))) 
  (reply-to (optional (string-utf8 256))) 
  (mine-amounts (list 200 uint)) 
  (alt-origin (string-utf8 256))
  (ext (optional <derupt-ext-trait>))
  (extras (optional (list 10 
    {
      stringutf8: (optional (string-utf8 256)), 
      stringascii: (optional (string-ascii 256)), 
      uint: (optional uint), 
      int: (optional int), 
      principal: (optional principal), 
      bool: (optional bool),
      buff: (optional (buff 34)),
      proxy: (optional (buff 2048))
    }))
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
      (try! (contract-call? .derupt-feed pay-stx mine-amounts pay-dev pay-gaia dev-stx-amount gaia-stx-amount dev-principal gaia-principal))

      ;; Executes extention contract function if defined
      (if (not (is-none ext))
        (let 
          ((targetContract (unwrap! ext ERR-NOTFOUND))) 
          (try! (contract-call? targetContract exec-ext-func extras))
          true
        )
        false
      )

      (is-ok (log-send-message content attachment-uri thumbnail-uri reply-to mine-amounts alt-origin ext pay-dev pay-gaia dev-stx-total gaia-stx-total dev-principal gaia-principal))
      (is-ok (log-mine tx-sender mine-amounts))
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
  (ext (optional <derupt-ext-trait>))
  (extras (optional (list 10 
    {
      stringutf8: (optional (string-utf8 256)), 
      stringascii: (optional (string-ascii 256)), 
      uint: (optional uint), 
      int: (optional int), 
      principal: (optional principal), 
      bool: (optional bool),
      buff: (optional (buff 34)),
      proxy: (optional (buff 2048))
    }))
  )
)
  (let
    (
      (like-ft-total like-ft-amount)
      (dev-ft-total dev-ft-amount)
      (gaia-ft-total gaia-ft-amount)
    )    
      (asserts! (not (is-eq tx-sender author-principal)) ERR-UNAUTHORIZED)
      (try! (contract-call? .derupt-feed pay-ft-like author-principal like-ft-total pay-dev pay-gaia dev-ft-total gaia-ft-total dev-principal gaia-principal contractId))

      ;; Executes extention contract function if defined
      (if (not (is-none ext))
        (let 
          ((targetContract (unwrap! ext ERR-NOTFOUND))) 
          (try! (contract-call? targetContract exec-ext-func extras))
          true
        )
        false
      )

      (is-ok (log-like-message author-principal like-ft-total liked-txid contractId pay-dev pay-gaia dev-ft-total gaia-ft-total dev-principal gaia-principal ext))
      (ok true)
  )
)

;; Core Operation Dislike Message
(define-public (dislike-message 
  (author-principal principal) 
  (disliked-txid (string-utf8 256)) 
  (contractId <sip-010-trait>)
  (dislike-ft-amount uint)
  (lockPeriod uint) 
  (pay-dev bool) 
  (pay-gaia bool) 
  (dev-ft-amount uint) 
  (gaia-ft-amount uint)
  (dev-principal (optional principal)) 
  (gaia-principal (optional principal))
  (ext (optional <derupt-ext-trait>))
  (extras (optional (list 10 
    {
      stringutf8: (optional (string-utf8 256)), 
      stringascii: (optional (string-ascii 256)), 
      uint: (optional uint), 
      int: (optional int), 
      principal: (optional principal), 
      bool: (optional bool),
      buff: (optional (buff 34)),
      proxy: (optional (buff 2048))
    }))
  )
)
  (let
    (
      (dislike-ft-total dislike-ft-amount)
      (dev-ft-total dev-ft-amount)
      (gaia-ft-total gaia-ft-amount)
    )
      (asserts! (not (is-eq tx-sender author-principal)) ERR-UNAUTHORIZED)
      (try! (contract-call? .derupt-feed pay-ft-dislike dislike-ft-total lockPeriod pay-dev pay-gaia dev-ft-total gaia-ft-total dev-principal gaia-principal contractId))
      
      ;; Executes extention contract function if defined
      (if (not (is-none ext))
        (let 
          ((targetContract (unwrap! ext ERR-NOTFOUND))) 
          (try! (contract-call? targetContract exec-ext-func extras))
          true
        )
        false
      )

      (is-ok (log-dislike-message author-principal dislike-ft-total lockPeriod disliked-txid contractId pay-dev pay-gaia dev-ft-total gaia-ft-total dev-principal gaia-principal ext))      
      (is-ok (log-stack tx-sender dislike-ft-total lockPeriod))
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
  (mine-amounts (list 200 uint)) 
  (alt-origin (string-utf8 256))
  (ext (optional <derupt-ext-trait>)) 
  (extras (optional (list 10 
    {
      stringutf8: (optional (string-utf8 256)), 
      stringascii: (optional (string-ascii 256)), 
      uint: (optional uint), 
      int: (optional int), 
      principal: (optional principal), 
      bool: (optional bool),
      buff: (optional (buff 34)),
      proxy: (optional (buff 2048))
    }))
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
      (try! (send-message content attachment-uri thumbnail-uri (some reply-to) mine-amounts alt-origin none none pay-dev pay-gaia dev-stx-amount gaia-stx-amount dev-principal gaia-principal))
      (try! (like-message author-principal liked-txid contractId like-ft-amount pay-dev pay-gaia dev-ft-amount gaia-ft-amount dev-principal gaia-principal none none))

      ;; Executes extention contract function if defined
      (if (not (is-none ext))
        (let 
          ((targetContract (unwrap! ext ERR-NOTFOUND))) 
          (try! (contract-call? targetContract exec-ext-func extras))
          true
        )
        false
      )

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
  (mine-amounts (list 200 uint))  
  (alt-origin (string-utf8 256))
  (ext (optional <derupt-ext-trait>))  
  (extras (optional (list 10 
    {
      stringutf8: (optional (string-utf8 256)), 
      stringascii: (optional (string-ascii 256)), 
      uint: (optional uint), 
      int: (optional int), 
      principal: (optional principal), 
      bool: (optional bool),
      buff: (optional (buff 34)),
      proxy: (optional (buff 2048))
    }))
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
      (try! (send-message content attachment-uri thumbnail-uri (some reply-to) mine-amounts alt-origin none none pay-dev pay-gaia dev-stx-amount gaia-stx-amount dev-principal gaia-principal))
      (try! (dislike-message author-principal disliked-txid contractId dislike-ft-amount lockPeriod pay-dev pay-gaia dev-ft-amount gaia-ft-amount dev-principal gaia-principal none none))

      ;; Executes extention contract function if defined
      (if (not (is-none ext))
        (let 
          ((targetContract (unwrap! ext ERR-NOTFOUND))) 
          (try! (contract-call? targetContract exec-ext-func extras))
          true
        )
        false
      )
      
      (ok true)
    )
)

;; Set the derupt-core-yyyymmdd version in derupt-feed contract as a data variable
(contract-call? .derupt-feed set-derupt-core-contract derupt-core-yyyymmdd)
```
