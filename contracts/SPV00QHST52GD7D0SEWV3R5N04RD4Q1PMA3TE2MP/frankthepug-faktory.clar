
;; 25860f57153ffba6f6bf991db5fa8abc82f4189eeec5c69827b6d183257d6761
;; pug Powered By Faktory.fun v1.0 

(impl-trait 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.faktory-trait-v1.sip-010-trait)

(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-NOT-OWNER u402)

(define-fungible-token PUG MAX)
(define-constant MAX u1000000000000000)
(define-data-var contract-owner principal tx-sender) 
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://szigdtxfspmofhxoytra.supabase.co/storage/v1/object/public/uri/7j2b2hw9-metadata.json"))

;; SIP-10 Functions
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
       (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
       (match (ft-transfer? PUG amount sender recipient)
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
  (ok (ft-get-balance PUG account))
)

(define-read-only (get-name)
  (ok "frankthepug")
)

(define-read-only (get-symbol)
  (ok "PUG")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply PUG))
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
    (try! (ft-mint? PUG u1000000000000000 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP.frankthepug-faktory-dex)) ;; supply-left
    


    

    ;; deploy fixed fee
    (try! (stx-transfer-to 'SMH8FRN30ERW1SX26NJTJCKTDR3H27NRJ6W75WQE u1000000)) 

    (print { 
        type: "faktory-trait-v1", 
        name: "frankthepug",
        symbol: "PUG",
        token-uri: u"https://szigdtxfspmofhxoytra.supabase.co/storage/v1/object/public/uri/7j2b2hw9-metadata.json", 
        tokenContract: (as-contract tx-sender),
        supply: MAX, 
        decimals: u6, 
        targetStx: u6000000000,
        tokenToDex: u1000000000000000,
        tokenToDeployer: u0,
        stxToDex: u0,
        stxBuyFirstFee: u0,
    })
)