
;; 023558319c5c9062783f7973e103f0dc25c1ed607854a731ed7fbd5e82d296b6
;; aipes Powered By Faktory.fun v1.0 

(impl-trait 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.faktory-trait-v1.sip-010-trait)

(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-NOT-OWNER u402)

(define-fungible-token AIPES MAX)
(define-constant MAX u1000000000000000)
(define-data-var contract-owner principal tx-sender) 
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://szigdtxfspmofhxoytra.supabase.co/storage/v1/object/public/uri/s06csdnl-metadata.json"))

;; SIP-10 Functions
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
       (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
       (match (ft-transfer? AIPES amount sender recipient)
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
  (ok (ft-get-balance AIPES account))
)

(define-read-only (get-name)
  (ok "Save the aipes")
)

(define-read-only (get-symbol)
  (ok "AIPES")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply AIPES))
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
    (try! (ft-mint? AIPES u995575221018678 'SP2R3CHRAP1HE4M64X1NZXHZT41JG3XGNHJW4HX2W.save-the-aipes-faktory-dex)) ;; supply-left
    (try! (ft-mint? AIPES u4424778981322 tx-sender)) ;; ft-amount-bought


    
      ;; STX distribution (first buy premium fee)
      (try! (stx-transfer-to 'SP2R3CHRAP1HE4M64X1NZXHZT41JG3XGNHJW4HX2W.save-the-aipes-faktory-dex u6666667)) ;; stx-in-dex
      (try! (stx-transfer-to 'SMH8FRN30ERW1SX26NJTJCKTDR3H27NRJ6W75WQE u3333333)) ;; premium-first-buy
    

    ;; deploy fixed fee
    (try! (stx-transfer-to 'SMH8FRN30ERW1SX26NJTJCKTDR3H27NRJ6W75WQE u1000000)) 

    (print { 
        type: "faktory-trait-v1", 
        name: "Save the aipes",
        symbol: "AIPES",
        token-uri: u"https://szigdtxfspmofhxoytra.supabase.co/storage/v1/object/public/uri/s06csdnl-metadata.json", 
        tokenContract: (as-contract tx-sender),
        supply: MAX, 
        decimals: u6, 
        targetStx: u6000000000,
        tokenToDex: u995575221018678,
        tokenToDeployer: u4424778981322,
        stxToDex: u6666667,
        stxBuyFirstFee: u3333333,
    })
)