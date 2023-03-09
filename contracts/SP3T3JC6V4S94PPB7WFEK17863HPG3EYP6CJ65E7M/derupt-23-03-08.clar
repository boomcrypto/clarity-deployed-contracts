;; Derupt Refactored v23-03-08
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant APP_DEV tx-sender)
(define-map cost principal { chime-cost: (optional uint), mine-cost: (optional uint), like-cost: (optional uint), dislike-cost: (optional uint) })
(define-constant unauthorized-user (err 100))
(define-constant notfound (err 101))

(define-public (set-cost (chime-cost (optional uint)) (mine-cost (optional uint)) (like-cost (optional uint)) (dislike-cost (optional uint))) 
  (let 
    (
      (prev-chime-cost (unwrap! (get chime-cost (map-get? cost APP_DEV)) notfound))
      (prev-mine-cost (unwrap! (get mine-cost (map-get? cost APP_DEV)) notfound))
      (prev-like-cost (unwrap! (get like-cost (map-get? cost APP_DEV)) notfound))
      (prev-dislike-cost (unwrap! (get dislike-cost (map-get? cost APP_DEV)) notfound))
    ) 
      (asserts! (is-eq APP_DEV tx-sender) unauthorized-user)
      (match chime-cost value (map-set cost tx-sender { chime-cost:  (some value), mine-cost:  prev-mine-cost, like-cost:  prev-like-cost, dislike-cost:  prev-dislike-cost }) false)
      (match mine-cost value (map-set cost tx-sender { chime-cost:  prev-chime-cost, mine-cost:  (some value), like-cost:  prev-like-cost, dislike-cost:  prev-dislike-cost }) false)
      (match like-cost value (map-set cost tx-sender { chime-cost:  prev-chime-cost, mine-cost:  prev-mine-cost, like-cost:  (some value), dislike-cost:  prev-dislike-cost }) false)
      (match dislike-cost value (map-set cost tx-sender { chime-cost:  prev-chime-cost, mine-cost:  prev-mine-cost, like-cost:  prev-like-cost, dislike-cost:  (some value) }) false)
      (ok true)
  )
)

(define-read-only (view-cost) 
  (ok (map-get? cost APP_DEV))
)

(define-read-only (get-derupt-uri)
  (ok (some u"bns://derupt.json"))
)

;; Other Contract Interactions
(define-public (transfer-citycoin (amount uint) (recipient principal) (contractName <sip-010-trait>))
  (contract-call? contractName transfer amount tx-sender recipient none)
)

(define-public (mine-citycoin (cityName (string-ascii 10)) (amounts (list 200 uint)))
    (contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd006-citycoin-mining mine cityName amounts)
)

(define-public (stack-citycoin (cityName (string-ascii 10)) (amount uint) (lockPeriod uint))
    (contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd007-citycoin-stacking stack cityName amount lockPeriod)
)

(define-public (send-message (content (string-utf8 256)) (attachment-uri (optional (string-utf8 256))) (thumbnail-uri (optional (string-utf8 256))) (reply-to (optional (string-utf8 66))) (city-name (string-ascii 10)))
  (let 
    (
      (cost-amount (unwrap! (unwrap! (get chime-cost (map-get? cost APP_DEV)) notfound) notfound))
      (mine-amount (unwrap! (unwrap! (get mine-cost (map-get? cost APP_DEV)) notfound) notfound))
    ) 
    (print { content: content, publisher: tx-sender, attachment-uri: attachment-uri, thumbnail-uri: thumbnail-uri, reply-to: reply-to, city-name: city-name})
    (begin 
        (is-ok (mine-citycoin city-name (list (/ mine-amount))))
        (ok (stx-transfer? cost-amount tx-sender APP_DEV))
    )
  )   
)
  
(define-public (like-message (author-principal principal) (liked-txid (string-utf8 66)) (contractName <sip-010-trait>))
  (let 
    (
      (cost-amount (unwrap! (unwrap! (get like-cost (map-get? cost APP_DEV)) notfound) notfound))
    ) 
    (print { author-principal: author-principal, liked-txid: liked-txid, show: cost-amount })
    (ok (transfer-citycoin cost-amount author-principal contractName))
  ) 
)

(define-public (dislike-message (author-principal principal) (disliked-txid (string-utf8 66)) (cityName (string-ascii 10)))
  (let 
    (
      (cost-amount (unwrap! (unwrap! (get dislike-cost (map-get? cost APP_DEV)) notfound) notfound))
    ) 
    (print { author-principal: author-principal, disliked-txid: disliked-txid })
    (ok (stack-citycoin cityName cost-amount u1))
  )   
)

;; Replies with Sentiment
(define-public (favorable-reply-message (content (string-utf8 256)) (attachment-uri (optional (string-utf8 256))) (thumbnail-uri (optional (string-utf8 256))) (reply-to (optional (string-utf8 66))) (author-principal principal) (liked-txid (string-utf8 66)) (cityName (string-ascii 10)) (contractName <sip-010-trait>))
    (begin 
        (is-ok (send-message content attachment-uri thumbnail-uri reply-to cityName))
        (is-ok (like-message author-principal liked-txid contractName))
        (ok true) 
    )
)

(define-public (unfavorable-reply-message (content (string-utf8 256)) (attachment-uri (optional (string-utf8 256))) (thumbnail-uri (optional (string-utf8 256))) (reply-to (optional (string-utf8 66))) (author-principal principal) (disliked-txid (string-utf8 66)) (cityName (string-ascii 10)))
    (begin 
        (is-ok (send-message content attachment-uri thumbnail-uri reply-to cityName))
        (is-ok (dislike-message author-principal disliked-txid cityName))
        (ok true)
    ) 
)

;; Default Costs
(map-insert cost APP_DEV { chime-cost:  (some u10000), mine-cost:  (some u100000), like-cost:  (some u100000000), dislike-cost:  (some u100000000) })