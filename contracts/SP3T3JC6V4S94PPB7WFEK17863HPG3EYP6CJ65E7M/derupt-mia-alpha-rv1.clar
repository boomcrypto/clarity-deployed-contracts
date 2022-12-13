;; Derupt MIA Alpha Refactored v1

(define-constant APP_DEV 'SP3T3JC6V4S94PPB7WFEK17863HPG3EYP6CJ65E7M)

(define-private (get-balance (recipient principal))
  (contract-call? 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2 get-balance recipient)
)

(define-public (send-message (content (string-utf8 256)) (attachment-uri (optional (string-utf8 256))) (thumbnail-uri (optional (string-utf8 256))) (reply-to (optional (string-utf8 66))))
  (transfer-miamicoin u100000000 APP_DEV)
)
  
(define-public (like-message (author-principal principal) (relative-txid (string-utf8 66)))
  (transfer-miamicoin u100000000 author-principal)
)

(define-public (dislike-message (author-principal principal) (relative-txid (string-utf8 66)))
  (transfer-miamicoin u100000000 APP_DEV)
)

;; Other Contract Interactions
(define-public (transfer-miamicoin (amount uint) (recipient principal))
  (contract-call? 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2 transfer amount tx-sender recipient none)
)