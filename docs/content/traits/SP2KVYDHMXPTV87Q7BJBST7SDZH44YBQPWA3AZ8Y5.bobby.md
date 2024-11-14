---
title: "Trait bobby"
draft: true
---
```

;;  ---------------------------------------------------------
;; Imagine you're at home, enjoying some quality time with your significant other when suddenly there's a knock at the door. You open it expecting someone from next-door but instead find yourself face-to-face with none other than Bobby - that infamous "he is just a friend" guy.
;; 
;; Bobby has been known to steal girlfriends right out of their boyfriends' arms without anyone noticing until it's too late! His methods are sly and stealthy; one moment you're cuddling up close, the next he swoops in like a ghostly figure. 
;; 
;; Bobby has got game! He's slicker than an ice rink and twice as deadly when it comes to snatching up unsuspecting girlfriends from under their boyfriends' noses. His charm is making every girl thirsty. He picks up your wife and takes her out to dinner.
;; 
;; But don't worry - there might just be hope yet. For those who invest early into $BOB will get rewarded handsomely.
;; ---------------------------------------------------------

;; Errors 
(define-constant ERR-UNAUTHORIZED u401)
(define-constant ERR-NOT-OWNER u402)
(define-constant ERR-INVALID-PARAMETERS u403)
(define-constant ERR-NOT-ENOUGH-FUND u101)

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Constants
(define-constant MAXSUPPLY u69000000000)

;; Variables
(define-fungible-token BOB MAXSUPPLY)
(define-data-var contract-owner principal tx-sender) 



;; SIP-10 Functions
(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq from tx-sender)
            (err ERR-UNAUTHORIZED))
        ;; Perform the token transfer
        (ft-transfer? BOB amount from to)
    )
)


;; DEFINE METADATA
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://gaia.hiro.so/hub/1ACW3F8BC7VSFHw9mbHEcTbq3sGF33Xdmm/bobby-0-decimals.json"))

(define-public (set-token-uri (value (string-utf8 256)))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-UNAUTHORIZED))
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


(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance BOB owner))
)
(define-read-only (get-name)
  (ok "Bobby")
)

(define-read-only (get-symbol)
  (ok "BOB")
)

(define-read-only (get-decimals)
  (ok u0)
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply BOB))
)

(define-read-only (get-token-uri)
  (ok (var-get token-uri))
)

;; transfer ownership
(define-public (transfer-ownership (new-owner principal))
  (begin
    ;; Checks if the sender is the current owner
    (if (is-eq tx-sender (var-get contract-owner))
      (begin
        ;; Sets the new owner
        (var-set contract-owner new-owner)
        ;; Returns success message
        (ok "Ownership transferred successfully"))
      ;; Error if the sender is not the owner
      (err ERR-NOT-OWNER)))
)


;; ---------------------------------------------------------
;; Utility Functions
;; ---------------------------------------------------------
(define-public (send-many (recipients (list 200 { to: principal, amount: uint, memo: (optional (buff 34)) })))
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

(define-private (send-stx (recipient principal) (amount uint))
  (begin
    (try! (stx-transfer? amount tx-sender recipient))
    (ok true) 
  )
)

;; ---------------------------------------------------------
;; Mint
;; ---------------------------------------------------------
(begin
    (try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u3000000))
    (try! (ft-mint? BOB u68931000000 (var-get contract-owner)))
  (try! (ft-mint? BOB u69000000 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0))
  
)

```
