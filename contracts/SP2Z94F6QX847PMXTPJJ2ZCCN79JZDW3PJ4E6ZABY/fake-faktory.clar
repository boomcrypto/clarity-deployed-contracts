
;; 2a0e98cfc781129d295c8a7106b37e6e171c23c39cb144bc2c8dd0ce9eb95ee6
;; fake Powered By Faktory.fun v1.0 

(impl-trait 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.faktory-trait-v1.sip-010-trait)
(impl-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.token)

(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-NOT-OWNER u402)

(define-fungible-token fake MAX)
(define-constant MAX u100000000000000000)
(define-data-var contract-owner principal 'SP2Z94F6QX847PMXTPJJ2ZCCN79JZDW3PJ4E6ZABY.fake-token-owner)
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://mkkhfmcrbwyuutcvtier.supabase.co/storage/v1/object/public/tokens//251.json"))

;; SIP-10 Functions
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
       (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
       (match (ft-transfer? fake amount sender recipient)
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
  (ok (ft-get-balance fake account))
)

(define-read-only (get-name)
  (ok "fake")
)

(define-read-only (get-symbol)
  (ok "fake")
)

(define-read-only (get-decimals)
  (ok u8)
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply fake))
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
    (try! (ft-mint? fake (/ (* MAX u80) u100) 'SP2Z94F6QX847PMXTPJJ2ZCCN79JZDW3PJ4E6ZABY.fake-treasury)) ;; 80% treasury
    (try! (ft-mint? fake (/ (* MAX u16) u100) 'SP2Z94F6QX847PMXTPJJ2ZCCN79JZDW3PJ4E6ZABY.fake-faktory-dex))
    (try! (ft-mint? fake (/ (* MAX u4) u100) 'SP2Z94F6QX847PMXTPJJ2ZCCN79JZDW3PJ4E6ZABY.fake-pre-faktory))

    (print { 
        type: "faktory-trait-v1", 
        name: "fake",
        symbol: "fake",
        token-uri: u"https://mkkhfmcrbwyuutcvtier.supabase.co/storage/v1/object/public/tokens//251.json", 
        tokenContract: (as-contract tx-sender),
        supply: MAX, 
        decimals: u8, 
        targetStx: u5000000,
        tokenToDex: (/ (* MAX u16) u100),
        tokenToDeployer: (/ (* MAX u4) u100),
        stxToDex: u250000,
        stxBuyFirstFee: u150000,
    })
)