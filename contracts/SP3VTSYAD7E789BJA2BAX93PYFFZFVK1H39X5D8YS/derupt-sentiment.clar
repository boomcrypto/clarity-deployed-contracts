;; .derupt-sentiment Contract
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
;; (use-trait sip-010-trait 'ST1NXBK3K5YYMD6FD41MVNP3JS1GABZ8TRVX023PT.sip-010-trait-ft-standard.sip-010-trait)

(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-NOTFOUND (err u101))

;; Get Derupt core contract
(define-read-only (get-derupt-core-contract)  
  (contract-call? .derupt-feed get-derupt-core-contract)
)

;; Log Like Message
(define-public (log-like-message 
  (liker principal)
  (author-principal principal) (like-ft-total uint) (liked-txid (string-utf8 256)) 
  (contractId <sip-010-trait>)
  (pay-dev bool) 
  (pay-gaia bool) 
  (dev-ft-total uint) 
  (gaia-ft-total uint)
  (dev-principal (optional principal)) 
  (gaia-principal (optional principal))
  )
  (let 
    (
      (derupt-core-contract (unwrap! (get-derupt-core-contract) ERR-NOTFOUND))
    ) 
    (asserts! (is-eq contract-caller derupt-core-contract) ERR-UNAUTHORIZED)
    (print 
      {
        event: "like-message", liker: liker, author-principal: author-principal,  like-ft-total: like-ft-total, liked-txid: liked-txid,
        contractId: contractId,
        pay-dev: pay-dev, pay-gaia: pay-gaia, dev-principal: dev-principal, gaia-principal: gaia-principal, dev-ft-total: dev-ft-total, gaia-ft-total: gaia-ft-total
      }
    )
    (ok true)
  )
)

;; Log Dislike Message
(define-public (log-dislike-message 
  (disliker principal)
  (author-principal principal) 
  (dislike-ft-total uint) 
  (lockPeriod uint)
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
  (let 
    (
      (derupt-core-contract (unwrap! (get-derupt-core-contract) ERR-NOTFOUND))
    ) 
    (asserts! (is-eq contract-caller derupt-core-contract) ERR-UNAUTHORIZED)
    (print 
      {
        event: "dislike-message", disliker: disliker, author-principal: author-principal, dislike-ft-total: dislike-ft-total, disliked-txid: disliked-txid,
        cityName: cityName, contractId: contractId,
        pay-dev: pay-dev, pay-gaia: pay-gaia, dev-principal: dev-principal, gaia-principal: gaia-principal, dev-ft-total: dev-ft-total, gaia-ft-total: gaia-ft-total
      }
    )
    (ok true)
  )
)