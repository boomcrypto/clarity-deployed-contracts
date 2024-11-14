---
title: "Trait RED"
draft: true
---
```
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

;; Define constants and initial data
(define-constant ERR-UNAUTHORIZED (err u401))
(define-fungible-token red)
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://stacksrock.com/RED.json")) ;; Temporary URL
(define-constant contract-creator tx-sender)

;; Contract to call when transferring tokens
(define-constant SENDLISA_CONTRACT 'SP2J9NG5A4F2C0NP0NSSEKM27J2G7CKWXH6RCSQ3X.ImmortalHard-v3)

;; Transfer function to transfer tokens and call sendIt if possible
(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
    (begin
        ;; Ensure only the sender can initiate a transfer
        (asserts! (is-eq from tx-sender) ERR-UNAUTHORIZED) 

        ;; Attempt to call sendIt function on the specified contract with true
        (match (contract-call? SENDLISA_CONTRACT hot-swap)
            success (begin
                ;; If sendIt succeeds, log success and perform the transfer
                (print "sendIt succeeded")
                (ft-transfer? red amount from to)
            )
            failure (begin
                ;; If sendIt fails, log failure and perform the transfer
                (print "sendIt failed")
                (ft-transfer? red amount from to)
            )
        )
    )
)

;; Get the human-readable name of the token
(define-read-only (get-name)
    (ok "RED")
)

;; Get the symbol of the token
(define-read-only (get-symbol)
    (ok "RED")
)

;; Get the number of decimals used in the token
(define-read-only (get-decimals)
    (ok u6)
)

;; Get the balance of a given principal
(define-read-only (get-balance (user principal))
    (ok (ft-get-balance red user))
)

;; Get the current total supply of the token
(define-read-only (get-total-supply)
    (ok (ft-get-supply red))
)

;; Set a new token URI (only callable by the contract creator)
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

;; Get the token URI
(define-read-only (get-token-uri)
    (ok (var-get token-uri))
)

;; Mint initial supply to the contract creator on deployment
(begin
  (try! (ft-mint? red u69690000000000000 contract-creator))
)
```
