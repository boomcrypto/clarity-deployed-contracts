
;; @title Bonding Curve Token by STX.CITY
;; @version 2.0
;; @hash gw8bCgGKW6u6-izcs3LVKw:LAnGEZB9Ex7Wqn9AITGDDA:J_ojZT_VVPxV7vJB9TR7gTa5wSCPxEVDMJCqN3A_HESZckEIsDzxjBgnzedOchwCLZlkrBTpWVruxqQr8bzerUfAms2T1L4mx5QIG-k1DM8
;; @targetstx 4000

;; Errors 
(define-constant ERR-UNAUTHORIZED u401)
(define-constant ERR-NOT-OWNER u402)
(define-constant ERR-INVALID-PARAMETERS u403)
(define-constant ERR-NOT-ENOUGH-FUND u101)

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Constants
(define-constant MAXSUPPLY u1000000000000000)

;; Variables
(define-fungible-token POWLAB MAXSUPPLY)
(define-data-var contract-owner principal tx-sender) 



;; SIP-10 Functions
(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq from tx-sender) (err ERR-UNAUTHORIZED))
        (ft-transfer? POWLAB amount from to)
    )
)


;; DEFINE METADATA
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://pdakhjpwkuwtadzmpnjm.supabase.co/storage/v1/object/public/uri/OkcmUVaw-proof-of-work-labs-0-decimals.json"))

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
  (ok (ft-get-balance POWLAB owner))
)
(define-read-only (get-name)
  (ok "Proof of Work Labs")
)

(define-read-only (get-symbol)
  (ok "POWLAB")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply POWLAB))
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
    (try! (ft-mint? POWLAB u734140080674734 'SP2Q4ZRTYSN7YE7BKNX986J4XKSNWM66AVFEDHTA1.proof-of-work-labs-stxcity-dex))
    (try! (ft-mint? POWLAB u265859919325266 'SP2Q4ZRTYSN7YE7BKNX986J4XKSNWM66AVFEDHTA1))
    
    (try! (send-stx 'SP2Q4ZRTYSN7YE7BKNX986J4XKSNWM66AVFEDHTA1.proof-of-work-labs-stxcity-dex u289710290))
    (try! (send-stx 'SP1WTA0YBPC5R6GDMPPJCEDEA6Z2ZEPNMQ4C39W6M u289710))
 
)
