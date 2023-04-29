;; .derupt-sentiment Contract
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant unauthorized-user (err 100))
(define-constant notfound (err 101))

;; Get Derupt core contract
(define-read-only (get-derupt-core-contract)  
  (contract-call? .derupt-feed get-derupt-core-contract)
)

;; Log Like Message
(define-public (log-like-message (author-principal principal) (like-amount uint) (liked-txid (string-utf8 256)) (contractId <sip-010-trait>))
  (let 
    (
      (derupt-core-contract (unwrap! (get-derupt-core-contract) notfound))
    ) 
    (asserts! (is-eq contract-caller derupt-core-contract) unauthorized-user)
    (ok (print {event: "like-message", author-principal: author-principal, contractId: contractId, like-amount: like-amount, liked-txid: liked-txid}))
  )
)

;; Log Dislike Message
(define-public (log-dislike-message (author-principal principal) (cityName (string-ascii 10)) (dislike-amount uint) (disliked-txid (string-utf8 256)))
  (let 
    (
      (derupt-core-contract (unwrap! (get-derupt-core-contract) notfound))
    ) 
    (asserts! (is-eq contract-caller derupt-core-contract) unauthorized-user)
    (ok (print {event: "dislike-message", author-principal: author-principal, cityName: cityName, dislike-amount: dislike-amount, disliked-txid: disliked-txid}))
  )
)