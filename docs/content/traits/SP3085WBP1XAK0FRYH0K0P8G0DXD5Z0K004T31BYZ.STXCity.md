---
title: "Trait STXCity"
draft: true
---
```
;; Define Constants
(define-constant err-unauthozized (err u401))
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-max-supply (err u102))
(define-constant contract-creator tx-sender)

;; Define Token
(define-fungible-token stxcity)

;; Define Data Var
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://bafkreiax4hi7vb5rdqmbg4jcll4c25mvbpu7vyh5fjxzhf7jtvepjkupzm.ipfs.nftstorage.link"))

;; Define Trait
(impl-trait 'SP28NB976TJHHGF4218KT194NPWP9N1X3WY516Z1P.sip-010-trait-standard.sip-010-trait)

;; Read Only Name
(define-read-only (get-name)
    (ok "STXCity"))

;; Read Only Symbol
(define-read-only (get-symbol)
    (ok "STXCity"))

;; Read Only Decimals
(define-read-only (get-decimals)
    (ok u0))

;; Read Only Balance
(define-read-only (get-balance (user principal))
    (ok (ft-get-balance stxcity user)))

;; Read Only Total Supply
(define-read-only (get-total-supply)
    (ok (ft-get-supply stxcity)))

;; Read Only Torken Uri
(define-read-only (get-token-uri)
    (ok (var-get token-uri)))

;; Public Transfer
(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq from tx-sender) err-unauthozized)
        (ft-transfer? stxcity amount from to)))

;; Public Set Token Uri
(define-public (set-token-uri (value (string-utf8 256)))
    (begin
        (asserts! (is-eq tx-sender contract-creator) err-unauthozized)
        (var-set token-uri (some value))
        (ok (print {
              notification: "token-metadata-update",
              payload: {
                contract-id: (as-contract tx-sender),
                token-class: "ft"
              }
            }))))

;; Public Send Many
(define-public (send-many (recipients (list 100 { to: principal, amount: uint, memo: (optional (buff 34)) })))
  (fold check-err (map send-token recipients) 
  (ok true)))

;; Private Check Error
(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value 
  (err err-value)))


;; Private Send Token
(define-private (send-token (recipient { to: principal, amount: uint, memo: (optional (buff 34)) }))
  (send-token-with-memo (get amount recipient) (get to recipient) (get memo recipient)))


;; Private Send Token With Memo
(define-private (send-token-with-memo (amount uint) (to principal) (memo (optional (buff 34))))
  (let ((transferOk (try! (transfer amount tx-sender to memo))))
    (ok transferOk)))

;; Mint
(begin
  (try! (ft-mint? stxcity u1000000000 contract-creator)))
```
