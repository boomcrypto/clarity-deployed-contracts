
;; @title Bonding Curve Token by STX.CITY
;; @version 2.0
;; @hash dw2j-hArg-_fzzfLoFOMrg:q1b5gr9I_aU8q8KsPmXSyA:oPVBBpPmUVCzTmPlvRxAohZZDIcx34tdvt3ZyvrnLCJJn1Cq2B5tMTvn4RWwKHgrMQ97FhLXToB2dVPt5PLHt3UnF_WssdoOWYvxTrwm_j8
;; @targetstx 5000

;; Errors 
(define-constant ERR-UNAUTHORIZED u401)
(define-constant ERR-NOT-OWNER u402)
(define-constant ERR-INVALID-PARAMETERS u403)
(define-constant ERR-NOT-ENOUGH-FUND u101)

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Constants
(define-constant MAXSUPPLY u1000000000000000)

;; Variables
(define-fungible-token BOB MAXSUPPLY)
(define-data-var contract-owner principal tx-sender) 



;; SIP-10 Functions
(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq from tx-sender) (err ERR-UNAUTHORIZED))
        (ft-transfer? BOB amount from to)
    )
)


;; DEFINE METADATA
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://pdakhjpwkuwtadzmpnjm.supabase.co/storage/v1/object/public/uri/IUgDusEr-bitcoin-bob-0-decimals.json"))

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
  (ok "Bitcoin BOB")
)

(define-read-only (get-symbol)
  (ok "BOB")
)

(define-read-only (get-decimals)
  (ok u6)
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
    (try! (send-stx 'SP11WRT9TPPKP5492X3VE81CM1T74MD13SPFT527D u500000))
    (try! (ft-mint? BOB u998003992015968 'SP2QWYSBQZA5KSWFKCRP2C6YG66MP5N06R8C2E42N.bitcoin-bob-stxcity-dex))
    (try! (ft-mint? BOB u1996007984032 'SP2QWYSBQZA5KSWFKCRP2C6YG66MP5N06R8C2E42N))
    
    (try! (send-stx 'SP2QWYSBQZA5KSWFKCRP2C6YG66MP5N06R8C2E42N.bitcoin-bob-stxcity-dex u2000000))
    (try! (send-stx 'SP1WTA0YBPC5R6GDMPPJCEDEA6Z2ZEPNMQ4C39W6M u1000000))
 
)
