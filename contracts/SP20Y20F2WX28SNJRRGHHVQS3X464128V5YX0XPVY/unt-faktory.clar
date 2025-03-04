
;; 4b820c6690f45148ed19e84bdd338ec49aede11819c3ccb3528b0192f037ce1c
;; unt Powered By Faktory.fun v1.0 

(impl-trait 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.faktory-trait-v1.sip-010-trait)
(impl-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.token)

(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-NOT-OWNER u402)

(define-fungible-token UNT MAX)
(define-constant MAX u1000000000000000)
(define-data-var contract-owner principal 'SP20Y20F2WX28SNJRRGHHVQS3X464128V5YX0XPVY.unt-token-owner)
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://bncytzyfafclmdxrwpgq.supabase.co/storage/v1/object/public/tokens/711b7147-36e9-4add-a346-ae8e91453ba8.json"))

;; SIP-10 Functions
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
       (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
       (match (ft-transfer? UNT amount sender recipient)
          response (begin
            (print memo)
            (ok response))
          error (err error)
        )
    )
)

(define-public (set-token-uri (value (string-utf8 256)))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
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

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance UNT account))
)

(define-read-only (get-name)
  (ok "Bitunity")
)

(define-read-only (get-symbol)
  (ok "UNT")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply UNT))
)

(define-read-only (get-token-uri)
    (ok (var-get token-uri))
)

(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (print {new-owner: new-owner})
    (ok (var-set contract-owner new-owner))
  )
)

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

;; ---------------------------------------------------------

(define-private (stx-transfer-to (recipient principal) (amount uint))
  (stx-transfer? amount tx-sender recipient)
)

(begin 
    ;; ft distribution
    (try! (ft-mint? UNT (/ (* MAX u80) u100) 'SP20Y20F2WX28SNJRRGHHVQS3X464128V5YX0XPVY.unt-treasury)) ;; 80% treasury
    (try! (ft-mint? UNT (/ (* MAX u20) u100) 'SP20Y20F2WX28SNJRRGHHVQS3X464128V5YX0XPVY.unt-faktory-dex)) ;; 20% dex

    ;; deploy fixed fee
    (try! (stx-transfer-to 'SMH8FRN30ERW1SX26NJTJCKTDR3H27NRJ6W75WQE u500000)) 

    (print { 
        type: "faktory-trait-v1", 
        name: "Bitunity",
        symbol: "UNT",
        token-uri: u"https://bncytzyfafclmdxrwpgq.supabase.co/storage/v1/object/public/tokens/711b7147-36e9-4add-a346-ae8e91453ba8.json", 
        tokenContract: (as-contract tx-sender),
        supply: MAX, 
        decimals: u6, 
        targetStx: u2000000000,
        tokenToDex: (/ (* MAX u20) u100),
        tokenToDeployer: u0,
        stxToDex: u0,
        stxBuyFirstFee: u0,
    })
)