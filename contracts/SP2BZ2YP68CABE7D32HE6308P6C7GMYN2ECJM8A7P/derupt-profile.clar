;; .derupt-profile Contract
(impl-trait 'SP3T3JC6V4S94PPB7WFEK17863HPG3EYP6CJ65E7M.derupt-profile-trait.derupt-profile-trait)
;; Using sip-010-trait for dynamically transfering CityCoins and derupt-core-trait for validation purposes
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait derupt-core-trait 'SP2BZ2YP68CABE7D32HE6308P6C7GMYN2ECJM8A7P.derupt-core-trait.derupt-core-trait)
(use-trait derupt-profile-trait 'SP3T3JC6V4S94PPB7WFEK17863HPG3EYP6CJ65E7M.derupt-profile-trait.derupt-profile-trait)

;; User Principal
(define-constant APP_USER tx-sender)

;; Error constants
(define-constant unauthorized-user (err 100))
(define-constant notfound (err 101))
(define-constant validation-failed (err 102))
(define-constant unauthorized-contract (err 103))
(define-constant insufficient-balance (err 104))
(define-constant failed-request (err 105))

;; Member activation map
(define-map member-status principal bool)

;; Get Derupt-core contract
(define-private (get-derupt-core-contract)
  (contract-call? 'SP3T3JC6V4S94PPB7WFEK17863HPG3EYP6CJ65E7M.derupt-feed get-derupt-core-contract) 
)

(define-private (get-chime-amount)
  (contract-call? 'SP3T3JC6V4S94PPB7WFEK17863HPG3EYP6CJ65E7M.derupt-feed get-chime-amount)  
)

(define-private (get-mine-amount)
  (contract-call? 'SP3T3JC6V4S94PPB7WFEK17863HPG3EYP6CJ65E7M.derupt-feed get-mine-amount)
)

(define-private (get-like-amount)
  (contract-call? 'SP3T3JC6V4S94PPB7WFEK17863HPG3EYP6CJ65E7M.derupt-feed get-like-amount)
)

(define-private (get-dislike-amount)
  (contract-call? 'SP3T3JC6V4S94PPB7WFEK17863HPG3EYP6CJ65E7M.derupt-feed get-dislike-amount)
)
;; validatation of core contract
(define-private (validate-core-contract (contract principal))
  (contract-call? 'SP3T3JC6V4S94PPB7WFEK17863HPG3EYP6CJ65E7M.derupt-feed validate-core-contract contract)
)

;; Member activation
(define-public (registration-activation (member principal))
  (let 
    (
      (caller (unwrap! (get name (unwrap! (principal-destruct? contract-caller) notfound)) notfound))
    ) 
      (asserts! (is-eq tx-sender member) unauthorized-user)
      (asserts! (is-eq caller "derupt-profiles") unauthorized-user)
      (map-set member-status APP_USER true)
      (ok true)
  )
)

;; Get status via chain change
(define-public (get-activation-status (member principal))
  (begin
    (asserts! (is-eq tx-sender member) unauthorized-user)
    (ok (unwrap! (map-get? member-status APP_USER) notfound))
  )
)

;; Get status via api
(define-read-only (activation-status)
  (ok (unwrap! (map-get? member-status APP_USER) notfound))
)

(define-public (activate-member (contract-address <derupt-profile-trait>)) 
  (contract-call? 'SP3T3JC6V4S94PPB7WFEK17863HPG3EYP6CJ65E7M.derupt-profiles activate-member contract-address)
)

;; User Operation Gifting
(define-public (gifting-message (chime-author principal) (amount uint) (via-id (string-utf8 256)) (is-stx bool) (contractId <sip-010-trait>))
  (let 
    (
      (profile-balance-ft (unwrap! (contract-call? contractId get-balance tx-sender) failed-request))
      (profile-balance-stx (stx-get-balance tx-sender))
    ) 
      (if is-stx
        (begin 
          (asserts! (>= profile-balance-stx amount) insufficient-balance)
          (is-ok (stx-transfer? amount tx-sender chime-author))
          (print {event: "gifting-message", chime-author: chime-author, amount: amount, via-id: via-id, is-stx: true, contractId: ""})
          (ok true)
        )
        (begin 
          (asserts! (>= profile-balance-ft amount) insufficient-balance)
          (is-ok (contract-call? contractId transfer amount tx-sender chime-author none))
          (print {event: "gifting-message", chime-author: chime-author, amount: amount, via-id: via-id, is-stx: false, contractId: contractId})
          (ok true)
        )
      )
    )
)

;; User Operation Send Message
(define-public (send-message 
  (content (string-utf8 256)) (attachment-uri (optional (string-utf8 256))) 
  (thumbnail-uri (optional (string-utf8 256))) (reply-to (optional (string-utf8 256))) 
  (cityName (string-ascii 10)) (alt-origin (optional (string-utf8 256)))
  (extras 
    (optional 
      { 
        arg0: (optional (string-utf8 256)),
        arg1: (optional (string-utf8 256)),
        arg2: (optional (string-utf8 256)),
        arg3: (optional (string-utf8 256)),
        arg4: (optional (string-utf8 256)),
        arg5: (optional (string-utf8 256)),
        arg6: (optional (string-utf8 256)),
        arg7: (optional (string-utf8 256)),
        arg8: (optional (string-utf8 256)),
        arg9: (optional (string-utf8 256))
      }
    )
  )
  (core-contract <derupt-core-trait>)
)           
  (let 
    (
      (derupt-core-contract (unwrap! (get-derupt-core-contract) notfound))
      (chime-amount (unwrap! (get-chime-amount) notfound))
      (mine-amount (unwrap! (get-mine-amount) notfound))
      (inputed-core-contract (contract-of core-contract))
    )            
    (asserts! (is-eq tx-sender APP_USER) unauthorized-user)
    (asserts! (unwrap! (validate-core-contract inputed-core-contract) validation-failed) unauthorized-contract)     
    (is-ok (contract-call? core-contract send-message content attachment-uri thumbnail-uri reply-to cityName alt-origin extras))   
    (print { event: "send-message", content: content, attachment-uri: attachment-uri, thumbnail-uri: thumbnail-uri, reply-to: reply-to, cityName: cityName, alt-origin: alt-origin, extras: extras, chime-amount: chime-amount, mine-amount: mine-amount})
    (ok true)
  )
)

;; User Operation Like Message
(define-public (like-message 
  (author-principal principal) (liked-txid (string-utf8 256)) 
  (contractId <sip-010-trait>) (core-contract <derupt-core-trait>))    
  (let 
    (
      (derupt-core-contract (unwrap! (get-derupt-core-contract) notfound))
      (like-amount (unwrap! (get-like-amount) notfound))
      (inputed-core-contract (contract-of core-contract))
    )      
    (asserts! (unwrap! (validate-core-contract inputed-core-contract) validation-failed) unauthorized-contract)                
    (is-ok (contract-call? core-contract like-message author-principal liked-txid contractId))
    (print { event: "like-message", author-principal: author-principal, liked-txid: liked-txid, like-amount: like-amount })
    (ok true)
  )
)

;; User Operation Dislike Message
(define-public (dislike-message 
  (author-principal principal) (disliked-txid (string-utf8 256)) 
  (cityName (string-ascii 10)) (contractId <sip-010-trait>) (core-contract <derupt-core-trait>)) 
  (let 
    (
      (derupt-core-contract (unwrap! (get-derupt-core-contract) notfound))
      (inputed-core-contract (contract-of core-contract))
      (dislike-amount (unwrap! (get-dislike-amount) notfound))
    )
    (asserts! (unwrap! (validate-core-contract inputed-core-contract) validation-failed) unauthorized-contract)      
    (is-ok (contract-call? core-contract dislike-message author-principal disliked-txid cityName contractId))
    (print { event: "dislike-message", author-principal: author-principal, disliked-txid: disliked-txid, dislike-amount: dislike-amount })
    (ok true)  
  )           
)

;; User Operation Favorable Reply Message
(define-public (favorable-reply-message 
  (content (string-utf8 256)) (attachment-uri (optional (string-utf8 256))) 
  (thumbnail-uri (optional (string-utf8 256))) (reply-to (optional (string-utf8 256))) 
  (author-principal principal) (liked-txid (string-utf8 256)) 
  (cityName (string-ascii 10)) (alt-origin (optional (string-utf8 256))) 
  (extras 
    (optional 
      { 
        arg0: (optional (string-utf8 256)),
        arg1: (optional (string-utf8 256)),
        arg2: (optional (string-utf8 256)),
        arg3: (optional (string-utf8 256)),
        arg4: (optional (string-utf8 256)),
        arg5: (optional (string-utf8 256)),
        arg6: (optional (string-utf8 256)),
        arg7: (optional (string-utf8 256)),
        arg8: (optional (string-utf8 256)),
        arg9: (optional (string-utf8 256))
      }
    )
  )
  (contractId <sip-010-trait>) 
  (core-contract <derupt-core-trait>))
  (let 
    (
      (derupt-core-contract (unwrap! (get-derupt-core-contract) notfound)) 
      (inputed-core-contract (contract-of core-contract))
    )
      (asserts! (unwrap! (validate-core-contract inputed-core-contract) validation-failed) unauthorized-contract)     
      (is-ok (contract-call? core-contract favorable-reply-message content tx-sender  attachment-uri thumbnail-uri reply-to liked-txid cityName alt-origin contractId extras))
      (print { event: "favorable-reply-message", content: content, publisher: tx-sender, attachment-uri: attachment-uri, thumbnail-uri: thumbnail-uri, reply-to: reply-to, cityName: cityName, alt-origin: alt-origin, contractId: contractId, extras: extras })
      (ok true)
  )
)

;; User Operation Favorable Reply Message
(define-public (unfavorable-reply-message 
  (content (string-utf8 256)) (attachment-uri (optional (string-utf8 256))) 
  (thumbnail-uri (optional (string-utf8 256))) (reply-to (optional (string-utf8 256))) 
  (author-principal principal) (liked-txid (string-utf8 256)) 
  (cityName (string-ascii 10)) (alt-origin (optional (string-utf8 256))) 
  (extras 
    (optional 
      { 
        arg0: (optional (string-utf8 256)),
        arg1: (optional (string-utf8 256)),
        arg2: (optional (string-utf8 256)),
        arg3: (optional (string-utf8 256)),
        arg4: (optional (string-utf8 256)),
        arg5: (optional (string-utf8 256)),
        arg6: (optional (string-utf8 256)),
        arg7: (optional (string-utf8 256)),
        arg8: (optional (string-utf8 256)),
        arg9: (optional (string-utf8 256))
      }
    )
  )
  (contractId <sip-010-trait>) 
  (core-contract <derupt-core-trait>))
  (let 
    (
      (derupt-core-contract (unwrap! (get-derupt-core-contract) notfound)) 
      (inputed-core-contract (contract-of core-contract))
    )
    (asserts! (unwrap! (validate-core-contract inputed-core-contract) validation-failed) unauthorized-contract)      
    (is-ok (contract-call? core-contract unfavorable-reply-message content tx-sender  attachment-uri thumbnail-uri reply-to liked-txid cityName alt-origin contractId extras))
    (print { event: "unfavorable-reply-message", content: content, publisher: tx-sender, attachment-uri: attachment-uri, thumbnail-uri: thumbnail-uri, reply-to: reply-to, cityName: cityName, alt-origin: alt-origin, contractId: contractId, extras: extras })
    (ok true)
  )
)

(map-insert member-status APP_USER false)