;; hello-world contract
  

(define-fungible-token h) 

(define-data-var token-uri (string-utf8 256) u"") 

(define-read-only (get-total-supply) (ok (ft-get-supply h))) 

(define-read-only (get-name) (ok "A")) 
(define-read-only (get-symbol) (ok "G")) 
(define-read-only (get-decimals) (ok u6)) 
(define-read-only (get-balance (account principal)) (ok (ft-get-balance h account))) 
(define-read-only (get-token-uri) (ok (some (var-get token-uri)))) 
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34)))) (begin (asserts! (is-eq tx-sender sender) (err u0)) (match (ft-transfer? h amount sender recipient) response (begin (print memo) (ok response)) error (err error)))) 

(ft-mint? h u1000000000000000000 tx-sender)

(define-public (mint)
  (ft-mint? h u1000000000000000000 tx-sender)
)