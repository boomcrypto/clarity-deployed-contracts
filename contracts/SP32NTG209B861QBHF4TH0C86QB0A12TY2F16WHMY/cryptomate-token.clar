(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(impl-trait 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.restricted-token-trait.restricted-token-trait)

(define-constant PERMISSION_DENIED_ERROR u4203)

(define-data-var token-name (string-ascii 32) "")
(define-data-var token-symbol (string-ascii 32) "")
(define-data-var token-decimals uint u0)

(define-data-var deployer-principal principal 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY)
(define-data-var is-initialized bool false)

(define-fungible-token cmt)


(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance cmt owner)))

(define-read-only (get-name)
  (ok (var-get token-name))
)

(define-read-only (get-symbol)
  (ok (var-get token-symbol)))

(define-read-only (get-decimals)
  (ok (var-get token-decimals)))

(define-read-only (get-total-supply)
  (ok (ft-get-supply cmt)))

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq from tx-sender) (err PERMISSION_DENIED_ERROR))
    (if (is-some memo)
      (print memo)
      none
    )
    (ft-transfer? cmt amount from to)
  )
)

(define-constant OWNER_ROLE u0) 
(define-constant MINTER_ROLE u1) 
(define-constant BURNER_ROLE u2) 
(define-constant REVOKER_ROLE u3) 
(define-constant BLACKLISTER_ROLE u4) 
(define-map roles { role: uint, account: principal } { allowed: bool })

(define-read-only (has-role (role-to-check uint) (principal-to-check principal))
  (default-to false (get allowed (map-get? roles {role: role-to-check, account: principal-to-check}))))

(define-public (add-principal-to-role (role-to-add uint) (principal-to-add principal))
   (begin
    (asserts! (has-role OWNER_ROLE contract-caller) (err PERMISSION_DENIED_ERROR))
    (ok (map-set roles { role: role-to-add, account: principal-to-add } { allowed: true }))))

(define-public (remove-principal-from-role (role-to-remove uint) (principal-to-remove principal))
   (begin
    (asserts! (has-role OWNER_ROLE contract-caller) (err PERMISSION_DENIED_ERROR))
    (ok (map-set roles { role: role-to-remove, account: principal-to-remove } { allowed: false }))))

(define-data-var uri (string-utf8 256) u"")

(define-read-only (get-token-uri)
  (ok (some (var-get uri))))

(define-public (set-token-uri (updated-uri (string-utf8 256)))
  (begin
    (asserts! (has-role OWNER_ROLE contract-caller) (err PERMISSION_DENIED_ERROR))
    (ok (var-set uri updated-uri))))

(define-public (revoke-tokens (revoke-amount uint) (revoke-from principal) (revoke-to principal) )
  (begin
    (asserts! (has-role REVOKER_ROLE contract-caller) (err PERMISSION_DENIED_ERROR))
    (ft-transfer? cmt revoke-amount revoke-from revoke-to)))


(define-map blacklist { account: principal } { blacklisted: bool })

(define-read-only (is-blacklisted (principal-to-check principal))
  (default-to false (get blacklisted (map-get? blacklist { account: principal-to-check }))))

(define-public (update-blacklisted (principal-to-update principal) (set-blacklisted bool))
  (begin
    (asserts! (has-role BLACKLISTER_ROLE contract-caller) (err PERMISSION_DENIED_ERROR))
    (ok (map-set blacklist { account: principal-to-update } { blacklisted: set-blacklisted }))))

(define-constant RESTRICTION_NONE u0) 
(define-constant RESTRICTION_BLACKLIST u1)

(define-read-only (detect-transfer-restriction (amount uint) (sender principal) (recipient principal))
  (if (or (is-blacklisted sender) (is-blacklisted recipient))
    (err RESTRICTION_BLACKLIST)
    (ok RESTRICTION_NONE)))

(define-read-only (message-for-restriction (restriction-code uint))
  (if (is-eq restriction-code RESTRICTION_NONE)
    (ok "No Restriction Detected")
    (if (is-eq restriction-code RESTRICTION_BLACKLIST)
      (ok "Sender or recipient is on the blacklist and prevented from transacting")
      (ok "Unknown Error Code"))))

(define-public (initialize (name-to-set (string-ascii 32)) (symbol-to-set (string-ascii 32) ) (decimals-to-set uint) (initial-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get deployer-principal)) (err PERMISSION_DENIED_ERROR))
    (asserts! (not (var-get is-initialized)) (err PERMISSION_DENIED_ERROR))
    (var-set is-initialized true)
    (var-set token-name name-to-set)
    (var-set token-symbol symbol-to-set)
    (var-set token-decimals decimals-to-set)
    (map-set roles { role: OWNER_ROLE, account: initial-owner } { allowed: true })
    (ok true)))


(define-public (mint-for-dao (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq contract-caller 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-dao) (err PERMISSION_DENIED_ERROR))
    (ft-mint? cmt amount recipient)
  )
)

(define-public (burn-for-dao (amount uint) (sender principal)) (begin
    (asserts! (is-eq contract-caller 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-dao) (err PERMISSION_DENIED_ERROR))
    (ft-burn? cmt amount sender)
  )
)


(initialize "CryptoMate Token" "CMT" u6 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY)
(ft-mint? cmt u1000000000000000 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY)
