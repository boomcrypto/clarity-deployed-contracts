;; .derupt-profile Contract
(impl-trait 'SP28JH8V6E3VPC79EAG0XXT51YR9YJF6BG1RXAQM4.derupt-profile-trait.derupt-profile-trait)

;; Using sip-010-trait for dynamically transfering CityCoins and derupt-core-trait for validation purposes
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait derupt-core-trait 'SP28JH8V6E3VPC79EAG0XXT51YR9YJF6BG1RXAQM4.derupt-core-trait.derupt-core-trait)
(use-trait derupt-profile-trait 'SP28JH8V6E3VPC79EAG0XXT51YR9YJF6BG1RXAQM4.derupt-profile-trait.derupt-profile-trait)

;; User Principal
(define-constant APP_USER tx-sender)

;; Error constants
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-NOTFOUND (err u101))
(define-constant ERR-VALIDATION-FAILED (err u102))
(define-constant ERR-INSUFFICIENT-BALANCE (err u104))
(define-constant ERR-UNAUTHORIZED-CONTRACT (err u105))

;; Member activation map
(define-map member-status principal bool)

;; Get Derupt-core contract
(define-private (get-derupt-core-contract)
  (contract-call? 'SP28JH8V6E3VPC79EAG0XXT51YR9YJF6BG1RXAQM4.derupt-feed get-derupt-core-contract) 
)

(define-private (get-chime-amount)
  (contract-call? 'SP28JH8V6E3VPC79EAG0XXT51YR9YJF6BG1RXAQM4.derupt-feed get-chime-amount)  
)

(define-private (get-mine-amount)
  (contract-call? 'SP28JH8V6E3VPC79EAG0XXT51YR9YJF6BG1RXAQM4.derupt-feed get-mine-amount)
)

(define-private (get-like-amount)
  (contract-call? 'SP28JH8V6E3VPC79EAG0XXT51YR9YJF6BG1RXAQM4.derupt-feed get-like-amount)
)

(define-private (get-dislike-amount)
  (contract-call? 'SP28JH8V6E3VPC79EAG0XXT51YR9YJF6BG1RXAQM4.derupt-feed get-dislike-amount)
)

;; validatation of core contract
(define-private (validate-core-contract (contract principal))
  (contract-call? 'SP28JH8V6E3VPC79EAG0XXT51YR9YJF6BG1RXAQM4.derupt-feed validate-core-contract contract)
)

;; Member activation
(define-public (registration-activation (member principal))
  (let 
    (
      (caller (unwrap! (get name (unwrap! (principal-destruct? contract-caller) ERR-NOTFOUND)) ERR-NOTFOUND))
    ) 
      (asserts! (is-eq tx-sender member) ERR-UNAUTHORIZED)
      (asserts! (is-eq caller "derupt-profiles") ERR-UNAUTHORIZED)
      (map-set member-status APP_USER true)
      (ok true)
  )
)

;; Get status via chain change
(define-public (get-activation-status (member principal))
  (begin
    (asserts! (is-eq tx-sender member) ERR-UNAUTHORIZED)
    (ok (unwrap! (map-get? member-status APP_USER) ERR-NOTFOUND))
  )
)

;; Get status via api
(define-read-only (activation-status)
  (ok (unwrap! (map-get? member-status APP_USER) ERR-NOTFOUND))
)

(define-public (activate-member (contract-address <derupt-profile-trait>)) 
  (contract-call? 'SP28JH8V6E3VPC79EAG0XXT51YR9YJF6BG1RXAQM4.derupt-profiles activate-member contract-address)
)

;; User Operation Gifting
(define-public (gift-message (chime-author principal) (amount uint) 
  (via-id (string-utf8 256)) (is-stx bool) (contractId <sip-010-trait>)
  (core-contract <derupt-core-trait>) (memo (optional (buff 34)))
)
  (let 
    (
      (profile-balance-ft (unwrap! (contract-call? contractId get-balance tx-sender) ERR-INSUFFICIENT-BALANCE))
      (profile-balance-stx (stx-get-balance tx-sender))
    ) 
      (if is-stx
        (begin 
          (asserts! (>= profile-balance-stx amount) ERR-INSUFFICIENT-BALANCE)
          (if (is-some memo) 
            (try! (stx-transfer-memo? amount tx-sender chime-author (unwrap! memo ERR-NOTFOUND)))
            (try! (stx-transfer? amount tx-sender chime-author))
          )          
          (try! (contract-call? core-contract gift-message tx-sender chime-author is-stx contractId amount memo))
          (print {event: "gift-message", chime-author: chime-author, amount: amount, via-id: via-id, is-stx: true, memo: memo})
          (ok true)
        )
        (begin 
          (asserts! (>= profile-balance-ft amount) ERR-INSUFFICIENT-BALANCE)
          (try! (contract-call? contractId transfer amount tx-sender chime-author memo))
          (try! (contract-call? core-contract gift-message tx-sender chime-author is-stx contractId amount memo))
          (print {event: "gift-message", chime-author: chime-author, amount: amount, via-id: via-id, is-stx: false, contractId: contractId, memo: memo})
          (ok true)
        )
      )
    )
)

;; User Operation Send Message
(define-public (send-message 
  (content (string-utf8 256)) 
  (attachment-uri (optional (string-utf8 256))) 
  (thumbnail-uri (optional (string-utf8 256))) 
  (reply-to (optional (string-utf8 256))) 
  (cityName (string-ascii 10)) 
  (alt-origin (optional (string-utf8 256)))
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
  (pay-dev bool) 
  (pay-gaia bool) 
  (dev-amount uint) 
  (gaia-amount uint)
  (dev-principal (optional principal)) 
  (gaia-principal (optional principal)) 
)           
  (let 
    (
      (derupt-core-contract (unwrap! (get-derupt-core-contract) ERR-NOTFOUND))
      (mine-amount (unwrap! (get-mine-amount) ERR-NOTFOUND))
      (chime-amount (unwrap! (get-chime-amount) ERR-NOTFOUND))
      (chime-stx-total (/ (* mine-amount chime-amount) u100))
      (dev-stx-total (/ (* mine-amount dev-amount) u100))
      (gaia-stx-total (/ (* mine-amount gaia-amount) u100))
      (inputed-core-contract (contract-of core-contract))
    )            
    (asserts! (is-eq tx-sender APP_USER) ERR-UNAUTHORIZED)
    (asserts! (unwrap! (validate-core-contract inputed-core-contract) ERR-VALIDATION-FAILED) ERR-UNAUTHORIZED-CONTRACT)
    (try! (contract-call? core-contract send-message content attachment-uri thumbnail-uri reply-to cityName alt-origin extras pay-dev pay-gaia dev-amount gaia-amount dev-principal gaia-principal))   
    (print 
      { 
        event: "send-message", content: content, attachment-uri: attachment-uri, thumbnail-uri: thumbnail-uri, reply-to: reply-to, 
        cityName: cityName, alt-origin: alt-origin, extras: extras, 
        mine-total: mine-amount,
        chime-stx-total: chime-stx-total,
        dev-stx-total: dev-stx-total, gaia-stx-total: gaia-stx-total,
        dev-principal: dev-principal, gaia-principal: gaia-principal
      }
    )
    (ok true)
  )
)

;; User Operation Like Message
(define-public (like-message 
    (author-principal principal) 
    (liked-txid (string-utf8 256)) 
    (contractId <sip-010-trait>) 
    (core-contract <derupt-core-trait>)
    (pay-dev bool) 
    (pay-gaia bool) 
    (dev-amount uint) 
    (gaia-amount uint)
    (dev-principal (optional principal)) 
    (gaia-principal (optional principal)) 
  )    
  (let 
    (
      (derupt-core-contract (unwrap! (get-derupt-core-contract) ERR-NOTFOUND))
      (like-amount (unwrap! (get-like-amount) ERR-NOTFOUND))
      (chime-amount (unwrap! (get-chime-amount) ERR-NOTFOUND))
      (chime-ft-total (/ (* like-amount chime-amount) u100))
      (dev-ft-total (/ (* like-amount dev-amount) u100))
      (gaia-ft-total (/ (* like-amount gaia-amount) u100))
      (inputed-core-contract (contract-of core-contract))
    )
    (asserts! (is-eq tx-sender APP_USER) ERR-UNAUTHORIZED)      
    (asserts! (unwrap! (validate-core-contract inputed-core-contract) ERR-VALIDATION-FAILED) ERR-UNAUTHORIZED-CONTRACT)
    (try! (contract-call? core-contract like-message author-principal liked-txid contractId pay-dev pay-gaia dev-amount gaia-amount dev-principal gaia-principal))
    (print 
      { 
        event: "like-message", author-principal: author-principal, liked-txid: liked-txid, 
        contractId: contractId,
        like-total: like-amount,
        chime-ft-total: chime-ft-total,
        pay-dev: pay-dev,
        pay-gaia: pay-gaia,
        dev-ft-total: dev-ft-total, 
        gaia-ft-total: gaia-ft-total,
        dev-principal: dev-principal, 
        gaia-principal: gaia-principal
      }
    )
    (ok true)
  )
)

;; User Operation Dislike Message
(define-public (dislike-message 
    (author-principal principal) 
    (disliked-txid (string-utf8 256)) 
    (cityName (string-ascii 10)) 
    (contractId <sip-010-trait>) 
    (core-contract <derupt-core-trait>)
    (pay-dev bool) 
    (pay-gaia bool) 
    (dev-amount uint) 
    (gaia-amount uint)
    (dev-principal (optional principal)) 
    (gaia-principal (optional principal)) 
  ) 
  (let 
    (
      (derupt-core-contract (unwrap! (get-derupt-core-contract) ERR-NOTFOUND))
      (dislike-amount (unwrap! (get-dislike-amount) ERR-NOTFOUND))
      (chime-amount (unwrap! (get-chime-amount) ERR-NOTFOUND))
      (chime-ft-total (/ (* dislike-amount chime-amount) u100))
      (dev-ft-total (/ (* dislike-amount dev-amount) u100))
      (gaia-ft-total (/ (* dislike-amount gaia-amount) u100))
      (inputed-core-contract (contract-of core-contract))      
    )
    (asserts! (is-eq tx-sender APP_USER) ERR-UNAUTHORIZED)
    (asserts! (unwrap! (validate-core-contract inputed-core-contract) ERR-VALIDATION-FAILED) ERR-UNAUTHORIZED-CONTRACT)
    (try! (contract-call? core-contract dislike-message author-principal disliked-txid cityName contractId pay-dev pay-gaia dev-amount gaia-amount dev-principal gaia-principal))
    (print 
      { 
        event: "dislike-message", author-principal: author-principal, disliked-txid: disliked-txid,
        cityName: cityName, contractId: contractId,
        dislike-total: dislike-amount,
        chime-ft-total: chime-ft-total,
        pay-dev: pay-dev,
        pay-gaia: pay-gaia,
        dev-ft-total: dev-ft-total, 
        gaia-ft-total: gaia-ft-total,
        dev-principal: dev-principal, 
        gaia-principal: gaia-principal
      }
    )
    (ok true)  
  )           
)

;; User Operation Favorable Reply Message
(define-public (favorable-reply-message 
    (content (string-utf8 256)) 
    (attachment-uri (optional (string-utf8 256))) 
    (thumbnail-uri (optional (string-utf8 256))) 
    (reply-to (string-utf8 256)) 
    (author-principal principal) 
    (liked-txid (string-utf8 256)) 
    (cityName (string-ascii 10)) 
    (alt-origin (optional (string-utf8 256))) 
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
    (core-contract <derupt-core-trait>)
    (pay-dev bool) 
    (pay-gaia bool) 
    (dev-amount uint) 
    (gaia-amount uint)
    (dev-principal (optional principal)) 
    (gaia-principal (optional principal))
  )
  (let 
    (
      (derupt-core-contract (unwrap! (get-derupt-core-contract) ERR-NOTFOUND))
      (mine-amount (unwrap! (get-mine-amount) ERR-NOTFOUND))
      (like-amount (unwrap! (get-like-amount) ERR-NOTFOUND))
      (chime-amount (unwrap! (get-chime-amount) ERR-NOTFOUND))
      (chime-stx-total (/ (* mine-amount chime-amount) u100))
      (dev-stx-total (/ (* mine-amount dev-amount) u100))
      (gaia-stx-total (/ (* mine-amount gaia-amount) u100))
      (chime-ft-total (/ (* like-amount chime-amount) u100))
      (dev-ft-total (/ (* like-amount dev-amount) u100))
      (gaia-ft-total (/ (* like-amount gaia-amount) u100))
      (inputed-core-contract (contract-of core-contract))
    )
      (asserts! (is-eq tx-sender APP_USER) ERR-UNAUTHORIZED)      
      (asserts! (unwrap! (validate-core-contract inputed-core-contract) ERR-VALIDATION-FAILED) ERR-UNAUTHORIZED-CONTRACT)
      (try! (contract-call? core-contract favorable-reply-message content author-principal attachment-uri thumbnail-uri reply-to liked-txid cityName alt-origin extras contractId pay-dev pay-gaia dev-amount gaia-amount dev-principal gaia-principal))
      (print 
        { 
          event: "favorable-reply-message", content: content, publisher: author-principal, attachment-uri: attachment-uri, thumbnail-uri: thumbnail-uri, reply-to: reply-to, 
          cityName: cityName, contractId: contractId,
          alt-origin: alt-origin, extras: extras,
          mine-total: mine-amount,
          like-total: like-amount,
          chime-stx-total: chime-stx-total,
          chime-ft-total: chime-ft-total,
          pay-dev: pay-dev,
          pay-gaia: pay-gaia,
          dev-stx-total: dev-stx-total, 
          gaia-stx-total: gaia-stx-total,
          dev-ft-total: dev-ft-total, 
          gaia-ft-total: gaia-ft-total,
          dev-principal: dev-principal, 
          gaia-principal: gaia-principal
        }
      )
      (ok true)
  )
)

;; User Operation Favorable Reply Message
(define-public (unfavorable-reply-message 
    (content (string-utf8 256)) 
    (attachment-uri (optional (string-utf8 256))) 
    (thumbnail-uri (optional (string-utf8 256))) 
    (reply-to (string-utf8 256)) 
    (author-principal principal) 
    (disliked-txid (string-utf8 256)) 
    (cityName (string-ascii 10))
    (alt-origin (optional (string-utf8 256))) 
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
    (core-contract <derupt-core-trait>)
    (pay-dev bool) 
    (pay-gaia bool) 
    (dev-amount uint) 
    (gaia-amount uint)
    (dev-principal (optional principal)) 
    (gaia-principal (optional principal))
  )
  (let 
    (
      (derupt-core-contract (unwrap! (get-derupt-core-contract) ERR-NOTFOUND))
      (mine-amount (unwrap! (get-mine-amount) ERR-NOTFOUND))
      (dislike-amount (unwrap! (get-dislike-amount) ERR-NOTFOUND))
      (chime-amount (unwrap! (get-chime-amount) ERR-NOTFOUND))
      (chime-stx-total (/ (* mine-amount chime-amount) u100))
      (dev-stx-total (/ (* mine-amount dev-amount) u100))
      (gaia-stx-total (/ (* mine-amount gaia-amount) u100))
      (chime-ft-total (/ (* dislike-amount chime-amount) u100))
      (dev-ft-total (/ (* dislike-amount dev-amount) u100))
      (gaia-ft-total (/ (* dislike-amount gaia-amount) u100))
      (inputed-core-contract (contract-of core-contract))
    )
    (asserts! (is-eq tx-sender APP_USER) ERR-UNAUTHORIZED)
    (asserts! (unwrap! (validate-core-contract inputed-core-contract) ERR-VALIDATION-FAILED) ERR-UNAUTHORIZED-CONTRACT)     
    (try! (contract-call? core-contract unfavorable-reply-message content author-principal attachment-uri thumbnail-uri reply-to disliked-txid cityName alt-origin extras contractId pay-dev pay-gaia dev-amount gaia-amount dev-principal gaia-principal))
    (print 
      { 
        event: "unfavorable-reply-message", content: content, publisher: author-principal, attachment-uri: attachment-uri, thumbnail-uri: thumbnail-uri, reply-to: reply-to, 
        cityName: cityName, contractId: contractId, 
        alt-origin: alt-origin, extras: extras,
        mine-total: mine-amount,
        dislike-total: dislike-amount,
        chime-stx-total: chime-stx-total,
        chime-ft-total: chime-ft-total,
        pay-dev: pay-dev,
        pay-gaia: pay-gaia,
        dev-stx-total: dev-stx-total, 
        gaia-stx-total: gaia-stx-total,
        dev-ft-total: dev-ft-total, 
        gaia-ft-total: gaia-ft-total,
        dev-principal: dev-principal, 
        gaia-principal: gaia-principal
      }
    )
    (ok true)
  )
)

(map-insert member-status APP_USER false)