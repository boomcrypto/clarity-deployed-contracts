
;; 5cf802ebb6bc72a1627694b4bcc0a7d7eac68264dc9b989987ed9266342a220e
;; slack Powered By Faktory.fun v1.0 

(impl-trait 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.faktory-trait-v1.sip-010-trait)

(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-NOT-OWNER u402)

(define-fungible-token SLACK MAX)
(define-constant MAX u21000000000000)
(define-data-var contract-owner principal tx-sender) 
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://szigdtxfspmofhxoytra.supabase.co/storage/v1/object/public/uri/jni87skb-metadata.json"))

;; SIP-10 Functions
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
       (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
       (match (ft-transfer? SLACK amount sender recipient)
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
        (print {
              notification: "uri-update",
              contract-id: (as-contract tx-sender),
              token-uri: value})
        (ok true)
    )
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance SLACK account))
)

(define-read-only (get-name)
  (ok "SLACK")
)

(define-read-only (get-symbol)
  (ok "SLACK")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply SLACK))
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
  (begin
    (try! (stx-transfer? amount tx-sender recipient))
    (ok true) 
  )
)

(begin 
    
    ;; ft distribution (first buy)
    (try! (ft-mint? SLACK u20997333670582 'SP31ER8WTA6RM08Z0GNTY786T4PW6SYKFTNMTPRSV.slack-faktory-dex)) ;; supply-left
    (try! (ft-mint? SLACK u2666329418 tx-sender)) ;; ft-amount-bought


    
      ;; STX distribution (first buy premium fee)
      (try! (stx-transfer-to 'SP31ER8WTA6RM08Z0GNTY786T4PW6SYKFTNMTPRSV.slack-faktory-dex u666667)) ;; stx-in-dex
      (try! (stx-transfer-to 'SMH8FRN30ERW1SX26NJTJCKTDR3H27NRJ6W75WQE u333333)) ;; premium-first-buy
    

    ;; deploy fixed fee
    (try! (stx-transfer-to 'SMH8FRN30ERW1SX26NJTJCKTDR3H27NRJ6W75WQE u1000000)) 

    (print { 
        type: "faktory-trait-v1", 
        name: "SLACK",
        symbol: "SLACK",
        token-uri: u"https://szigdtxfspmofhxoytra.supabase.co/storage/v1/object/public/uri/jni87skb-metadata.json", 
        tokenContract: (as-contract tx-sender),
        supply: MAX, 
        decimals: u6, 
        targetStx: u21000000000,
        tokenToDex: u20997333670582,
        tokenToDeployer: u2666329418,
        stxToDex: u666667,
        stxBuyFirstFee: u333333,
    })
)