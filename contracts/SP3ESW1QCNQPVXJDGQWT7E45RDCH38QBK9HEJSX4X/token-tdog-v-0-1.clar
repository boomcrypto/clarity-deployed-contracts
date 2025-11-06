;; token-tdog-v-0-1

(impl-trait .sip-010-trait-ft-standard-v-0-0.sip-010-trait)

(define-fungible-token tDOG)

(define-constant ERR_USER_ALREADY_MINTED (err u9000))
(define-constant ERR_NOT_AUTHORIZED (err u9001))

(define-constant CONTRACT_DEPLOYER tx-sender)

(define-constant USER_MINT_AMOUNT u88980600000)
(define-constant DEPLOY_MINT_AMOUNT u100000000000000)

(define-map user-minted principal bool)

(define-read-only (get-name)
  (ok "Test DOG Token")
)

(define-read-only (get-symbol)
  (ok "tDOG")
)

(define-read-only (get-decimals)
  (ok u5)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance tDOG account))
)

(define-read-only (get-balance-simple (account principal))
  (ft-get-balance tDOG account)
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply tDOG))
)

(define-read-only (get-token-uri)
  (ok (some u""))
)

(define-read-only (get-user-minted (account principal))
  (ok (default-to false (map-get? user-minted account)))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) (err u1001))

    (match (ft-transfer? tDOG amount sender recipient)
      response (begin
        (print memo)
        (ok response)
      )
      error (err error)
    )
  )
)

(define-public (mint)
  (begin
    (asserts! (is-none (map-get? user-minted tx-sender)) ERR_USER_ALREADY_MINTED)
    (map-set user-minted tx-sender true)
    (ft-mint? tDOG USER_MINT_AMOUNT tx-sender)
  )
)

(define-public (admin-mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_DEPLOYER) ERR_NOT_AUTHORIZED)
    (ft-mint? tDOG amount recipient)
  )
)

(define-public (burn (amount uint))
  (begin
    (ft-burn? tDOG amount tx-sender)
  )
)

(ft-mint? tDOG DEPLOY_MINT_AMOUNT CONTRACT_DEPLOYER)