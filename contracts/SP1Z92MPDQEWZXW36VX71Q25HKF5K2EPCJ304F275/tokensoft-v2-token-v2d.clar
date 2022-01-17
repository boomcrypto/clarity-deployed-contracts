;; Implement the `ft-trait` trait defined in the `ft-trait` contract - SIP 10
;; This can use sugared syntax in real deployment (unit tests do not allow)
(impl-trait 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.sip-010-v1a.sip-010-trait)

;; ;; Implement the token restriction trait
(impl-trait 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.restricted-token-trait-v1a.restricted-token-trait)

;; ;; Implement the token restriction trait
(impl-trait 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.initializable-trait-v1a.initializable-token-trait)

;; SOFT_TOKEN ERRORS 4250~4269
(define-constant ERR_PERMISSION_DENIED u4251)
(define-constant ERR_UNAUTHORIZED u4252)
(define-constant ERR_ALREADY_INITIALIZED u4253)

(define-constant STACKSWAP_ACCOUNT 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275)

;; Data variables specific to the deployed token contract
(define-data-var token-name (string-ascii 32) "")
(define-data-var token-symbol (string-ascii 32) "")
(define-data-var token-decimals uint u0)

;; Track who deployed the token and whether it has been initialized
(define-data-var deployer-principal principal tx-sender)
(define-data-var is-initialized bool false)

;; Meta Read Only Functions for reading details about the contract - conforms to SIP 10
;; --------------------------------------------------------------------------

;; Defines built in support functions for tokens used in this contract
;; A second optional parameter can be added here to set an upper limit on max total-supply
(define-fungible-token tokensoft-token)


;; Get the token balance of the specified owner in base units
(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance tokensoft-token owner)))

;; Returns the token name
(define-read-only (get-name)
  (ok (var-get token-name)))

;; Returns the symbol or "ticker" for this token
(define-read-only (get-symbol)
  (ok (var-get token-symbol)))

;; Returns the number of decimals used
(define-read-only (get-decimals)
  (ok (var-get token-decimals)))

;; Returns the total number of tokens that currently exist
(define-read-only (get-total-supply)
  (ok (ft-get-supply tokensoft-token)))


;; Write function to transfer tokens between accounts - conforms to SIP 10
;; --------------------------------------------------------------------------

;; Transfers tokens to a recipient
;; The originator of the transaction (tx-sender) must be the 'sender' principal
;; Smart contracts can move tokens from their own address by calling transfer with the 'as-contract' modifier to override the tx-sender.
(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq from tx-sender) (err ERR_PERMISSION_DENIED))
    (try! (ft-transfer? tokensoft-token amount from to))
	(match memo to-print (print to-print) 0x)
	(ok true)
  )
)


;; Role Based Access Control
;; --------------------------------------------------------------------------
(define-constant OWNER_ROLE u0) ;; Can manage RBAC
(define-constant MINTER_ROLE u1) ;; Can mint new tokens to any account
(define-constant BURNER_ROLE u2) ;; Can burn tokens from any account
(define-constant REVOKER_ROLE u3) ;; Can revoke tokens and move them to any account
(define-constant BLACKLISTER_ROLE u4) ;; Can add principals to a blacklist that can prevent transfers

;; Each role will have a mapping of principal to boolean.  A true "allowed" in the mapping indicates that the principal has the role.
;; Each role will have special permissions to modify or manage specific capabilities in the contract.
;; Note that adding/removing roles could be optimized by having just 1 function, but since this is sensitive functionality, it was split
;;    into 2 separate functions to make it explicit.
;; See the Readme about more details on the RBAC setup.
(define-map roles { role: uint, account: principal } { allowed: bool })

;; Checks if an account has the specified role
(define-read-only (has-role (role-to-check uint) (principal-to-check principal))
  (default-to false (get allowed (map-get? roles {role: role-to-check, account: principal-to-check}))))

;; Add a principal to the specified role
;; Only existing principals with the OWNER_ROLE can modify roles
(define-public (add-principal-to-role (role-to-add uint) (principal-to-add principal))
   (begin
    ;; Check the contract-caller to verify they have the owner role
    (asserts! (has-role OWNER_ROLE contract-caller) (err ERR_PERMISSION_DENIED))
    ;; Print the action for any off chain watchers
    (print { action: "add-principal-to-role", role-to-add: role-to-add, principal-to-add: principal-to-add })
    (ok (map-set roles { role: role-to-add, account: principal-to-add } { allowed: true }))))

;; Remove a principal from the specified role
;; Only existing principals with the OWNER_ROLE can modify roles
;; WARN: Removing all owners will irrevocably lose all ownership permissions
(define-public (remove-principal-from-role (role-to-remove uint) (principal-to-remove principal))
   (begin
    ;; Check the contract-caller to verify they have the owner role
    (asserts! (has-role OWNER_ROLE contract-caller) (err ERR_PERMISSION_DENIED))
    ;; Print the action for any off chain watchers
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


;; Initialization
;; --------------------------------------------------------------------------
;; (define-public (add-principal-to-role (role-to-add uint) (principal-to-add principal))
;;    (begin
;;     ;; Check the contract-caller to verify they have the owner role
;;     (asserts! (has-role OWNER_ROLE contract-caller) (err ERR_PERMISSION_DENIED))
;;     ;; Print the action for any off chain watchers
;;     (print { action: "add-principal-to-role", role-to-add: role-to-add, principal-to-add: principal-to-add })
;;     (ok (map-set roles { role: role-to-add, account: principal-to-add } { allowed: true }))))
;; Check to ensure that the same account that deployed the contract is initializing it
;; Only allow this funtion to be called once by checking "is-initialized"

(define-public (initialize (name-to-set (string-ascii 32)) (symbol-to-set (string-ascii 32)) (decimals-to-set uint) 
    (uri-to-set (string-utf8 256)) (website-to-set (string-utf8 256)) (initial-owner principal) (initial-amount uint))
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v5d get-qualified-name-by-name "one-step-mint"))) (err ERR_PERMISSION_DENIED))
    (asserts! (not (var-get is-initialized)) (err ERR_ALREADY_INITIALIZED))
    (var-set is-initialized true) ;; Set to true so that this can't be called again
    (var-set token-name name-to-set)
    (var-set token-symbol symbol-to-set)
    (var-set token-decimals decimals-to-set)
    (var-set uri uri-to-set)
    (var-set website website-to-set)
    (map-set roles { role: OWNER_ROLE, account: initial-owner } { allowed: true })
    (map-set roles { role: MINTER_ROLE, account: initial-owner } { allowed: true })
    (unwrap-panic (ft-mint? tokensoft-token (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-one-step-mint-fee-v1a get-owner-amount initial-amount) initial-owner))
    (unwrap-panic (ft-mint? tokensoft-token (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-one-step-mint-fee-v1a get-stackswap-amount initial-amount) STACKSWAP_ACCOUNT))
    (ok u0)
))

;; Variable for approve
(define-data-var approved bool false)

;; Public getter for the approve
(define-read-only (get-is-approved)
  (ok (some (var-get approved))))


(define-public (approve (is-approved bool))
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v5d get-qualified-name-by-name "one-step-mint"))) (err ERR_PERMISSION_DENIED))
    (ok (var-set approved is-approved))
  )
)

(contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-one-step-mint-v5d add-soft-token (as-contract tx-sender))