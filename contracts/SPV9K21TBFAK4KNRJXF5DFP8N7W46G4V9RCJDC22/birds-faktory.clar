
;; 49125cc15c6a38ef126cea3edba9337bd1e13fc96a968c09a3c22f0ab6185ac5
;; birds Powered By Faktory.fun v1.0 

(impl-trait 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.faktory-trait-v1.sip-010-trait)
(impl-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.token)

(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-NOT-OWNER u402)

(define-fungible-token BIRDS MAX)
(define-constant MAX u100000000000000000)
(define-data-var contract-owner principal 'SP2EXJYQG612FXBH0J2800K2HHD3Z9P1J48WW39V6)
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://szigdtxfspmofhxoytra.supabase.co/storage/v1/object/public/uri/7frmdyaj-metadata.json"))

;; SIP-10 Functions
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
       (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
       (match (ft-transfer? BIRDS amount sender recipient)
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
  (ok (ft-get-balance BIRDS account))
)

(define-read-only (get-name)
  (ok "Bitcoin Birds")
)

(define-read-only (get-symbol)
  (ok "BIRDS")
)

(define-read-only (get-decimals)
  (ok u8)
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply BIRDS))
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

(begin 
    ;; ft distribution
    (try! (ft-mint? BIRDS (/ (* MAX u80) u100) 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.birds-faktory-dex))
    (try! (ft-mint? BIRDS (/ (* MAX u20) u100) 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.birds-pre-faktory))

    (print { 
        type: "faktory-trait-v1", 
        name: "Bitcoin Birds",
        symbol: "BIRDS",
        token-uri: u"https://szigdtxfspmofhxoytra.supabase.co/storage/v1/object/public/uri/7frmdyaj-metadata.json", 
        tokenContract: (as-contract tx-sender),
        supply: MAX, 
        decimals: u8, 
        targetStx: u21000000,
        tokenToDex: (/ (* MAX u80) u100),
        tokenToDeployer: (/ (* MAX u20) u100),
        stxToDex: u1000000,
        stxBuyFirstFee: u380000,
    })
)