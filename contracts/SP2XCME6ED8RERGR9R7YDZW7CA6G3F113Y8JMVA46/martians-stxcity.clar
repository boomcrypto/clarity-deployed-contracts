;; @title Bonding Curve Token by STX.CITY
;; @version 2.0
;; @hash t5SiUc4aFThflz4_HRQOQg:QBLymcJXFrdztmsIuDGlfw:LN99xLupHQjGoHgjmcnDgdrJgbhCZADRd3Jbk1g33mwBYnqME3X6elG4rmBCBzc-dTaYQ59U34gcweXjRgtlbQ 
;; @targetstx 2000 

;; Traits
(impl-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.token)
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Errors 
(define-constant ERR-UNAUTHORIZED u401)
(define-constant ERR-NOT-OWNER u402)
(define-constant ERR-INVALID-PARAMETERS u403)
(define-constant ERR-NOT-ENOUGH-FUND u101)

;; Constants
(define-constant MAXSUPPLY u1000000000000000)

;; Variables
(define-fungible-token MARTIANS MAXSUPPLY)
(define-data-var contract-owner principal 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.martians-token-owner) 

;; SIP-10 Functions
(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq from tx-sender) (err ERR-UNAUTHORIZED))
        (ft-transfer? MARTIANS amount from to)
    )
)

;; Define token metadata
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://bncytzyfafclmdxrwpgq.supabase.co/storage/v1/object/public/tokens/60360b67-5f2e-4dfb-adc4-f8bf7c9aab85.json?"))

;; Set token uri
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

;; Read-Only Functions
(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance MARTIANS owner))
)
(define-read-only (get-name)
  (ok "Martians")
)
(define-read-only (get-symbol)
  (ok "MARTIANS")
)
(define-read-only (get-decimals)
  (ok u6)
)
(define-read-only (get-total-supply)
  (ok (ft-get-supply MARTIANS))
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

(begin
  ;; Send STX fees
  (try! (send-stx 'SP11WRT9TPPKP5492X3VE81CM1T74MD13SPFT527D u500000))
  ;; mint tokens to the dex_contract (20%)
  (try! (ft-mint? MARTIANS (/ (* MAXSUPPLY u20) u100) 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.martians-stxcity-dex))
  ;; mint tokens to the treasury (80%)
  (try! (ft-mint? MARTIANS (/ (* MAXSUPPLY u80) u100) 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.martians-treasury))
)