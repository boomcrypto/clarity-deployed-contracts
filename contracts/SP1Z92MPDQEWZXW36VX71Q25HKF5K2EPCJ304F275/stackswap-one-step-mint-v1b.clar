(use-trait sip-010-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.sip-010-v1a.sip-010-trait)
(use-trait liquidity-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-trait-v1a.liquidity-token-trait)
(use-trait initable-sip010 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.initializable-trait-v1a.initializable-token-trait)
(use-trait initable-poxl 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.initializable-trait-v1a.initializable-poxl-token-trait)
(use-trait initable-liquidity 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.initializable-trait-v1a.initializable-liquidity-token-trait)

;; Errors
(define-constant ERR-NO-TEMPLATE-TOKEN (err u4001))
(define-constant PERMISSION_DENIED_ERROR (err u4002))

(define-constant DEPLOYER_ROLE u0) ;; Can mint new tokens to any account

(define-map roles { role: uint, account: principal } { allowed: bool })

(define-data-var soft-token-list (list 200 principal) (list))
(define-data-var poxl-token-list (list 200 principal) (list))
(define-data-var liquidity-token-list (list 200 principal) (list))

(define-data-var rem-item principal tx-sender)

;; Checks if an account has the specified role
(define-read-only (has-role (role-to-check uint) (principal-to-check principal))
  (default-to false (get allowed (map-get? roles {role: role-to-check, account: principal-to-check}))))

(define-read-only (get-soft-token-list)
  (ok (var-get soft-token-list)))

(define-read-only (get-poxl-token-list)
  (ok (var-get poxl-token-list)))

(define-read-only (get-liquidity-token-list)
  (ok (var-get liquidity-token-list)))

(define-private (remove-filter (a principal)) (not (is-eq a (var-get rem-item))))


;; (contract-call? .listTest remove-user u2)
(define-public (remove-soft-token (ritem principal))
  (begin
    (asserts! (has-role DEPLOYER_ROLE contract-caller) (err PERMISSION_DENIED_ERROR))
    (var-set rem-item ritem)
    (ok (var-set soft-token-list (unwrap-panic (as-max-len? (filter remove-filter (var-get soft-token-list)) u200))))))

(define-public (remove-poxl-token (ritem principal))
  (begin
    (asserts! (has-role DEPLOYER_ROLE contract-caller) (err PERMISSION_DENIED_ERROR))
    (var-set rem-item ritem)
    (ok (var-set poxl-token-list (unwrap-panic (as-max-len? (filter remove-filter (var-get poxl-token-list)) u200))))))

(define-public (remove-liquidity-token (ritem principal))
  (begin
    (asserts! (has-role DEPLOYER_ROLE contract-caller) (err PERMISSION_DENIED_ERROR))
    (var-set rem-item ritem)
    (ok (var-set liquidity-token-list (unwrap-panic (as-max-len? (filter remove-filter (var-get liquidity-token-list)) u200))))))


;; (contract-call? .listTest remove-user u2)
(define-private (remove-soft-token-inner (ritem principal))
  (begin
    (var-set rem-item ritem)
    (ok (var-set soft-token-list (unwrap-panic (as-max-len? (filter remove-filter (var-get soft-token-list)) u200))))))

(define-private (remove-poxl-token-inner (ritem principal))
  (begin
    (var-set rem-item ritem)
    (ok (var-set poxl-token-list (unwrap-panic (as-max-len? (filter remove-filter (var-get poxl-token-list)) u200))))))

(define-private (remove-liquidity-token-inner (ritem principal))
  (begin
    (var-set rem-item ritem)
    (ok (var-set liquidity-token-list (unwrap-panic (as-max-len? (filter remove-filter (var-get liquidity-token-list)) u200))))))



(define-public (add-soft-token (new-token principal))
  (begin
    (asserts! (has-role DEPLOYER_ROLE contract-caller) (err PERMISSION_DENIED_ERROR))
    (ok (var-set soft-token-list (unwrap-panic (as-max-len? (append (var-get soft-token-list) new-token) u200))))))

(define-public (add-poxl-token (new-token principal))
  (begin
    (asserts! (has-role DEPLOYER_ROLE contract-caller) (err PERMISSION_DENIED_ERROR))
    (ok (var-set poxl-token-list (unwrap-panic (as-max-len? (append (var-get poxl-token-list) new-token) u200))))))

(define-public (add-liquidity-token (new-token principal))
  (begin
    (asserts! (has-role DEPLOYER_ROLE contract-caller) (err PERMISSION_DENIED_ERROR))
    (ok (var-set liquidity-token-list (unwrap-panic (as-max-len? (append (var-get liquidity-token-list) new-token) u200))))))


;; init token with stx(token-x), new token(token-y), liquidity-token(soft token), mint amount 'mint amount' and staking amount 'enter amount-stx' 'enter amount-y'
(define-public (create-pair-new-sip10-token-with-stx (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>) (pair-name (string-ascii 32)) (x uint) (y uint) (token-y-init-trait <initable-sip010>) (token-liquidity-soft <initable-liquidity>)  (name-to-set (string-ascii 32)) (symbol-to-set (string-ascii 32)) (decimals-to-set uint) (uri-to-set (string-utf8 256)) (website-to-set (string-utf8 256))  (initial-amount uint) )
  (begin
    (try! (contract-call? token-y-init-trait initialize name-to-set symbol-to-set decimals-to-set uri-to-set website-to-set tx-sender initial-amount))
    (try! (create-pair-new-liquidity-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v1b token-y-trait token-liquidity-trait pair-name x y token-liquidity-soft))
    (unwrap! (remove-soft-token-inner (contract-of token-y-trait)) ERR-NO-TEMPLATE-TOKEN)
    (ok true)
  )
)

;; init token with stx(token-x), new token(token-y), liquidity-token(soft token), mint amount 'mint amount' and staking amount 'enter amount-stx' 'enter amount-y'
(define-public (create-pair-new-poxl-token-with-stx (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>) (pair-name (string-ascii 32)) (x uint) (y uint) (token-y-init-trait <initable-poxl>) (token-liquidity-soft <initable-liquidity>)  (name-to-set (string-ascii 32)) (symbol-to-set (string-ascii 32)) (decimals-to-set uint) (uri-to-set (string-utf8 256)) (website-to-set (string-utf8 256))  (initial-amount uint)  (first-stacking-block-to-set uint) (reward-cycle-lengh-to-set uint) (token-reward-maturity-to-set uint) (coinbase-reward-to-set uint) )
  (begin
    (try! (contract-call? token-y-init-trait initialize name-to-set symbol-to-set decimals-to-set uri-to-set website-to-set initial-amount first-stacking-block-to-set reward-cycle-lengh-to-set token-reward-maturity-to-set coinbase-reward-to-set))
    (try! (create-pair-new-liquidity-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v1b token-y-trait token-liquidity-trait pair-name x y token-liquidity-soft))
    (unwrap! (remove-poxl-token-inner (contract-of token-y-trait)) ERR-NO-TEMPLATE-TOKEN)
    (ok true)
  )
)

;; (define-public (create-pair-new-token (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>) (pair-name (string-ascii 32)) (x uint) (y uint) (token-x-init-trait <initable-sip010>) (token-liquidity-soft <initable-liquidity>)  (name-to-set (string-ascii 32)) (symbol-to-set (string-ascii 32)) (decimals-to-set uint) (uri-to-set (string-utf8 256)) (initial-amount uint) )
;;   (begin
;;     (unwrap-panic (contract-call? token-x-init-trait initialize name-to-set symbol-to-set decimals-to-set uri-to-set tx-sender initial-amount))
;;     (try! (create-pair-new-liquidity-token token-x-trait token-y-trait token-liquidity-trait pair-name x y token-liquidity-soft))
;;     (ok true)
;;   )
;; )

(define-public (create-pair-new-liquidity-token (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>)  (token-liquidity <liquidity-token>) (pair-name (string-ascii 32)) (x uint) (y uint) (token-liquidity-soft <initable-liquidity>) )
  (begin
    ;; (unwrap-panic (contract-call? token-x-init-trait initialize name-to-set symbol-to-set decimals-to-set uri-to-set tx-sender initial-amount))
    (try! (contract-call? token-liquidity-soft initialize pair-name pair-name u6 u""))
    (try! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v2b create-pair token-x-trait token-y-trait token-liquidity pair-name x y))
    (unwrap! (remove-liquidity-token-inner (contract-of token-liquidity)) ERR-NO-TEMPLATE-TOKEN)
    (ok true)
  )
)

(define-public (add-principal-to-role (role-to-add uint) (principal-to-add principal))
   (begin
    ;; Check the contract-caller to verify they have the owner role
    (asserts! (is-eq tx-sender (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v1a get-dao-owner)) (err PERMISSION_DENIED_ERROR))
    ;; Print the action for any off chain watchers
    (print { action: "add-principal-to-role", role-to-add: role-to-add, principal-to-add: principal-to-add })
    (ok (map-set roles { role: role-to-add, account: principal-to-add } { allowed: true }))))

(add-principal-to-role DEPLOYER_ROLE tx-sender)
(add-principal-to-role DEPLOYER_ROLE 'SP23DAB333A5CPFXNK13E5YMX1DZJ07112QNZEBCF)