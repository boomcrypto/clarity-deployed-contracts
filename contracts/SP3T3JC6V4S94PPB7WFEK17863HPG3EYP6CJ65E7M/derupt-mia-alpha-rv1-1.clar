;; Derupt MIA Alpha Refactored v1.1

(define-constant APP_DEV 'SP3T3JC6V4S94PPB7WFEK17863HPG3EYP6CJ65E7M)

(define-private (get-balance (recipient principal))
  (contract-call? 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2 get-balance recipient)
)

(define-public (send-message (content (string-utf8 256)) (attachment-uri (optional (string-utf8 256))) (thumbnail-uri (optional (string-utf8 256))) (reply-to (optional (string-utf8 66))))
  (begin 
    (print { content: content, publisher: tx-sender, attachment-uri: attachment-uri, thumbnail-uri: thumbnail-uri, reply-to: reply-to })
    (transfer-miamicoin u100000000 APP_DEV)
  )
  
)
  
(define-public (like-message (liker principal) (relative-txid (string-utf8 66)))
  (begin   
    (print { liker: liker, relative-txid: relative-txid })
    (transfer-miamicoin u100000000 liker)
  )
  
)

(define-public (dislike-message (disliker principal) (relative-txid (string-utf8 66)))
  (begin   
    (print { disliker: disliker, relative-txid: relative-txid })
    (transfer-miamicoin u100000000 APP_DEV)
  )
  
)

;; Other Contract Interactions
(define-public (transfer-miamicoin (amount uint) (recipient principal))
  (contract-call? 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2 transfer amount tx-sender recipient none)
)