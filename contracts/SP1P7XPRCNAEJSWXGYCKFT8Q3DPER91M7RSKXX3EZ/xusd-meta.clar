
;; constants
;;

(define-constant PERMISSION_DENIED_ERROR u403)
(define-constant OWNER_ROLE u0)  ;; Can manage RBAC
(define-constant MINTER_ROLE u1) ;; Can mint new tokens to any account
(define-constant BURNER_ROLE u2) ;; Can burn tokens from any account
(define-constant OWNER tx-sender)

;; wrapped-exchange
;; helper contract wrapping concrete token contracts to provide additional in-chain tracing.

(define-trait exchange
 (
   (mint-tokens (uint principal) (response bool uint) )
   (burn-tokens (uint principal) (response bool uint) )
 )
)

;; data maps and vars
;;
(define-map roles { role: uint, account: principal } { allowed: bool })

;; Track who deployed the token and whether it has been initialized
(define-data-var deployer-principal principal tx-sender)
(define-data-var is-initialized bool false)

;; private functions
;;

;; public functions
;;
;; Checks if an account has the specified role
(define-read-only (has-role (role-to-check uint) (principal-to-check principal))
  (default-to false (get allowed (map-get? roles {role: role-to-check, account: principal-to-check}))))

;; Add a principal to the specified role
;; Only existing principals with the OWNER_ROLE can modify roles
;; #[allow(unchecked_data)]
(define-public (add-principal-to-role (role-to-add uint) (principal-to-add principal))
   (begin
    ;; Check the contract-caller to verify they have the owner role
    (asserts! (has-role OWNER_ROLE contract-caller) (err PERMISSION_DENIED_ERROR))
    ;; Print the action for any off chain watchers
    (print { action: "add-principal-to-role", role-to-add: role-to-add, principal-to-add: principal-to-add })
    (ok (map-set roles { role: role-to-add, account: principal-to-add } { allowed: true }))))

;; Remove a principal from the specified role
;; Only existing principals with the OWNER_ROLE can modify roles
;; WARN: Removing all owners will irrevocably lose all ownership permissions
;; #[allow(unchecked_data)]
(define-public (remove-principal-from-role (role-to-remove uint) (principal-to-remove principal))
   (begin
    ;; Check the contract-caller to verify they have the owner role
    (asserts! (has-role OWNER_ROLE contract-caller) (err PERMISSION_DENIED_ERROR))
    ;; Print the action for any off chain watchers
    (print { action: "remove-principal-from-role", role-to-remove: role-to-remove, principal-to-remove: principal-to-remove })
    (ok (map-set roles { role: role-to-remove, account: principal-to-remove } { allowed: false }))))


;; Exchange to Stacks token from external transaction
;; #[allow(unchecked_data)]
(define-public (buy (exchange-contract <exchange>)
    (amount uint)
    (tier uint)
    (settlement-address principal)
    (order-chain-id uint)
    (order-tx (buff 256)) )
  (begin
    (asserts! (has-role MINTER_ROLE contract-caller) (err PERMISSION_DENIED_ERROR))
    (print { action: "buy", amount: amount, tier: tier, settlement-address: settlement-address, order-chain-id: order-chain-id, order-tx: order-tx})
    (contract-call? exchange-contract mint-tokens amount settlement-address)
  )
)

;; Exchange to Stacks token from external transaction
;; #[allow(unchecked_data)]
(define-public (sell (exchange-contract <exchange>)
    (amount uint)
    (tier uint)
    (settlement-chain-id uint)
    (withdrawal-tx (buff 256))
    (order-tx (buff 256))
    (burn-address principal) )
  (begin
    (asserts! (has-role BURNER_ROLE contract-caller) (err PERMISSION_DENIED_ERROR))
    (print { action: "sell", amount: amount, tier: tier, settlement-chain-id: settlement-chain-id, withdrawal-tx: withdrawal-tx, order-tx: order-tx})
    (contract-call? exchange-contract burn-tokens amount burn-address)
  )
)


;; Initialization
;; --------------------------------------------------------------------------

;; Check to ensure that the same account that deployed the contract is initializing it
;; Only allow this funtion to be called once by checking "is-initialized"
;; #[allow(unchecked_data)]
(define-public (initialize (initial-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get deployer-principal)) (err PERMISSION_DENIED_ERROR))
    (asserts! (not (var-get is-initialized)) (err PERMISSION_DENIED_ERROR))
    (var-set is-initialized true) ;; Set to true so that this can't be called again
    (map-set roles { role: OWNER_ROLE, account: initial-owner } { allowed: true })
    (ok true))
)
