(impl-trait .sip-010-v1a.sip-010-trait)

(impl-trait .restricted-token-trait-v1a.restricted-token-trait)

(impl-trait .initializable-trait-v1b.initializable-sip010-token-trait)

(define-constant ERR_PERMISSION_DENIED u4251)
(define-constant ERR_UNAUTHORIZED u4252)
(define-constant ERR_ALREADY_INITIALIZED u4253)

(define-constant STACKSWAP_ACCOUNT 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275)

(define-data-var token-name (string-ascii 32) "")
(define-data-var token-symbol (string-ascii 32) "")
(define-data-var token-decimals uint u0)

(define-data-var deployer-principal principal tx-sender)
(define-data-var is-initialized bool false)

(define-fungible-token tokensoft-token)


(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance tokensoft-token owner)))

(define-read-only (get-name)
  (ok (var-get token-name)))

(define-read-only (get-symbol)
  (ok (var-get token-symbol)))

(define-read-only (get-decimals)
  (ok (var-get token-decimals)))

(define-read-only (get-total-supply)
  (ok (ft-get-supply tokensoft-token)))


(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq from tx-sender) (err ERR_PERMISSION_DENIED))
    (try! (ft-transfer? tokensoft-token amount from to))
	(match memo to-print (print to-print) 0x)
	(ok true)
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
    (asserts! (has-role OWNER_ROLE contract-caller) (err ERR_PERMISSION_DENIED))
    (print { action: "add-principal-to-role", role-to-add: role-to-add, principal-to-add: principal-to-add })
    (ok (map-set roles { role: role-to-add, account: principal-to-add } { allowed: true }))))

(define-public (remove-principal-from-role (role-to-remove uint) (principal-to-remove principal))
   (begin
    (asserts! (has-role OWNER_ROLE contract-caller) (err ERR_PERMISSION_DENIED))
    (print { action: "remove-principal-from-role", role-to-remove: role-to-remove, principal-to-remove: principal-to-remove })
    (ok (map-set roles { role: role-to-remove, account: principal-to-remove } { allowed: false }))))


;; Token URI
;; --------------------------------------------------------------------------

;; Variable for URI storage
(define-data-var uri (string-utf8 256) u"")

;; Public getter for the URI
(define-read-only (get-token-uri)
  (ok (some (var-get uri))))

;; Setter for the URI - only the owner can set it
(define-public (set-token-uri (updated-uri (string-utf8 256)))
  (begin
    (asserts! (has-role OWNER_ROLE contract-caller) (err ERR_PERMISSION_DENIED))
    ;; Print the action for any off chain watchers
    (print { action: "set-token-uri", updated-uri: updated-uri })
    (ok (var-set uri updated-uri))))


;; Token Website
;; --------------------------------------------------------------------------

;; Variable for website storage
(define-data-var website (string-utf8 256) u"")

;; Public getter for the website
(define-read-only (get-token-website)
  (ok (some (var-get website))))

;; Setter for the website - only the owner can set it
(define-public (set-token-website (updated-website (string-utf8 256)))
  (begin
    (asserts! (has-role OWNER_ROLE contract-caller) (err ERR_PERMISSION_DENIED))
    ;; Print the action for any off chain watchers
    (print { action: "set-token-website", updated-website: updated-website })
    (ok (var-set website updated-website))))



;; Minting and Burning
;; --------------------------------------------------------------------------

;; Mint tokens to the target address
;; Only existing principals with the MINTER_ROLE can mint tokens
(define-public (mint-tokens (mint-amount uint) (mint-to principal) )
  (begin
    (asserts! (has-role MINTER_ROLE contract-caller) (err ERR_PERMISSION_DENIED))
    ;; Print the action for any off chain watchers
    (print { action: "mint-tokens", mint-amount: mint-amount, mint-to: mint-to  })
    (ft-mint? tokensoft-token mint-amount mint-to)))

;; Burn tokens from the target address
;; Only existing principals with the BURNER_ROLE can mint tokens
(define-public (burn-tokens (burn-amount uint) (burn-from principal) )
  (begin
    (asserts! (has-role BURNER_ROLE contract-caller) (err ERR_PERMISSION_DENIED))
    ;; Print the action for any off chain watchers
    (print { action: "burn-tokens", burn-amount: burn-amount, burn-from : burn-from  })
    (ft-burn? tokensoft-token burn-amount burn-from)))


;; Revoking Tokens
;; --------------------------------------------------------------------------

;; Moves tokens from one account to another
;; Only existing principals with the REVOKER_ROLE can revoke tokens
(define-public (revoke-tokens (revoke-amount uint) (revoke-from principal) (revoke-to principal) )
  (begin
    (asserts! (has-role REVOKER_ROLE contract-caller) (err ERR_PERMISSION_DENIED))
    ;; Print the action for any off chain watchers
    (print { action: "revoke-tokens", revoke-amount: revoke-amount, revoke-from: revoke-from, revoke-to: revoke-to })
    (ft-transfer? tokensoft-token revoke-amount revoke-from revoke-to)))

;; Blacklisting Principals
;; --------------------------------------------------------------------------

;; Blacklist mapping.  If an account has blacklisted = true then no transfers in or out are allowed
(define-map blacklist { account: principal } { blacklisted: bool })

;; Checks if an account is blacklisted
(define-read-only (is-blacklisted (principal-to-check principal))
  (default-to false (get blacklisted (map-get? blacklist { account: principal-to-check }))))

;; Updates an account's blacklist status
;; Only existing principals with the BLACKLISTER_ROLE can update blacklist status
(define-public (update-blacklisted (principal-to-update principal) (set-blacklisted bool))
  (begin
    (asserts! (has-role BLACKLISTER_ROLE contract-caller) (err ERR_PERMISSION_DENIED))
    ;; Print the action for any off chain watchers
    (print { action: "update-blacklisted", principal-to-update: principal-to-update, set-blacklisted: set-blacklisted })
    (ok (map-set blacklist { account: principal-to-update } { blacklisted: set-blacklisted }))))

;; Transfer Restrictions
;; --------------------------------------------------------------------------
(define-constant RESTRICTION_NONE u0) ;; No restriction detected
(define-constant RESTRICTION_BLACKLIST u1) ;; Sender or receiver is on the blacklist

;; Checks to see if a transfer should be restricted.  If so returns an error code that specifies restriction type.
(define-read-only (detect-transfer-restriction (amount uint) (sender principal) (recipient principal))
  (if (or (is-blacklisted sender) (is-blacklisted recipient))
    (err RESTRICTION_BLACKLIST)
    (ok RESTRICTION_NONE)))

;; Returns the user viewable string for a specific transfer restriction
(define-read-only (message-for-restriction (restriction-code uint))
  (if (is-eq restriction-code RESTRICTION_NONE)
    (ok "No Restriction Detected")
    (if (is-eq restriction-code RESTRICTION_BLACKLIST)
      (ok "Sender or recipient is on the blacklist and prevented from transacting")
      (ok "Unknown Error Code"))))



(define-public (initialize (name-to-set (string-ascii 32)) (symbol-to-set (string-ascii 32)) (decimals-to-set uint) 
    (uri-to-set (string-utf8 256)) (website-to-set (string-utf8 256)) (initial-owner principal) (initial-amount uint))
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5j get-qualified-name-by-name "one-step-mint"))) (err ERR_PERMISSION_DENIED))
    (asserts! (not (var-get is-initialized)) (err ERR_ALREADY_INITIALIZED))
    (var-set is-initialized true) ;; Set to true so that this can't be called again
    (var-set token-name name-to-set)
    (var-set token-symbol symbol-to-set)
    (var-set token-decimals decimals-to-set)
    (var-set uri uri-to-set)
    (var-set website website-to-set)
    (map-set roles { role: OWNER_ROLE, account: initial-owner } { allowed: true })
    (map-set roles { role: MINTER_ROLE, account: initial-owner } { allowed: true })
    (unwrap-panic (ft-mint? tokensoft-token (contract-call? .stackswap-one-step-mint-fee-v1a get-owner-amount initial-amount) initial-owner))
    (unwrap-panic (ft-mint? tokensoft-token (contract-call? .stackswap-one-step-mint-fee-v1a get-stackswap-amount initial-amount) STACKSWAP_ACCOUNT))
    (ok u0)
))

;; Variable for approve
(define-data-var approved bool false)

;; Public getter for the approve
(define-read-only (get-is-approved)
  (ok (some (var-get approved))))


(define-public (approve (is-approved bool))
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5j get-qualified-name-by-name "one-step-mint"))) (err ERR_PERMISSION_DENIED))
    (ok (var-set approved is-approved))
  )
)
