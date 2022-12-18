;; Derupt MIA Alpha Refactored v1.6

(define-constant APP_DEV tx-sender)
(define-map cost principal { chime-cost: (optional uint), like-cost: (optional uint), dislike-cost: (optional uint) })
(define-constant unauthorized-user (err 100))
(define-constant notfound (err 101))

(define-public (set-cost (chime-cost (optional uint)) (like-cost (optional uint)) (dislike-cost (optional uint))) 
  (let 
    (
      (prev-chime-cost (unwrap! (get chime-cost (map-get? cost tx-sender)) notfound))
      (prev-like-cost (unwrap! (get like-cost (map-get? cost tx-sender)) notfound))
      (prev-dislike-cost (unwrap! (get dislike-cost (map-get? cost tx-sender)) notfound))
    ) 
      (asserts! (is-eq APP_DEV tx-sender) unauthorized-user)      
      (match chime-cost value (map-set cost tx-sender { chime-cost:  chime-cost, like-cost:  prev-like-cost, dislike-cost:  prev-like-cost }) false)
      (match like-cost value (map-set cost tx-sender { chime-cost:  prev-chime-cost, like-cost:  like-cost, dislike-cost:  prev-dislike-cost }) false)
      (match dislike-cost value (map-set cost tx-sender { chime-cost:  prev-chime-cost, like-cost:  prev-like-cost, dislike-cost:  dislike-cost }) false)
      (ok true)
  )
)

(define-read-only (view-cost) 
  (ok (map-get? cost tx-sender))
)

(define-read-only (get-derupt-uri)
  (ok (some u"gaia://derupt.json"))
)

;; Other Contract Interactions
(define-public (transfer-citycoin (amount uint) (recipient principal))
  (contract-call? 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2 transfer amount tx-sender recipient none)
)

(define-public (send-message (content (string-utf8 256)) (attachment-uri (optional (string-utf8 256))) (thumbnail-uri (optional (string-utf8 256))) (reply-to (optional (string-utf8 66))))
  (let 
    (
      (cost-amount (unwrap! (unwrap! (get chime-cost (map-get? cost tx-sender)) notfound) notfound))
    ) 
    (print { content: content, publisher: tx-sender, attachment-uri: attachment-uri, thumbnail-uri: thumbnail-uri, reply-to: reply-to })
    (ok (transfer-citycoin cost-amount APP_DEV))
  )   
)
  
(define-public (like-message (author-principal principal) (liked-txid (string-utf8 66)))
  (let 
    (
      (cost-amount (unwrap! (unwrap! (get like-cost (map-get? cost tx-sender)) notfound) notfound))
    ) 
    (print { author-principal: author-principal, liked-txid: liked-txid, show: cost-amount })
    (ok (transfer-citycoin cost-amount author-principal))
  ) 
)

(define-public (dislike-message (author-principal principal) (disliked-txid (string-utf8 66)))
  (let 
    (
      (cost-amount (unwrap! (unwrap! (get dislike-cost (map-get? cost tx-sender)) notfound) notfound))
    ) 
    (print { author-principal: author-principal, disliked-txid: disliked-txid })
    (ok (transfer-citycoin cost-amount APP_DEV))
  )   
)

;; Replies with Sentiment
(define-public (favorable-reply-message (content (string-utf8 256)) (attachment-uri (optional (string-utf8 256))) (thumbnail-uri (optional (string-utf8 256))) (reply-to (optional (string-utf8 66))) (author-principal principal) (liked-txid (string-utf8 66)))
    (begin 
        (is-ok (send-message content attachment-uri thumbnail-uri reply-to))
        (is-ok (like-message author-principal liked-txid))
        (ok true) 
    )
)

(define-public (unfavorable-reply-message (content (string-utf8 256)) (attachment-uri (optional (string-utf8 256))) (thumbnail-uri (optional (string-utf8 256))) (reply-to (optional (string-utf8 66))) (author-principal principal) (disliked-txid (string-utf8 66)))
    (begin 
        (is-ok (send-message content attachment-uri thumbnail-uri reply-to))
        (is-ok (dislike-message author-principal disliked-txid))
        (ok true)
    ) 
)

;; Default Costs
(map-insert cost APP_DEV { chime-cost:  (some u100000000), like-cost:  (some u100000000), dislike-cost:  (some u100000000) })