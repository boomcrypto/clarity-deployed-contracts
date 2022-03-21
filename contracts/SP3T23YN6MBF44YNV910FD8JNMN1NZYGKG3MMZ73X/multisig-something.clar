;; A multi-signature wallet

(use-trait executor-trait 'SP3XD84X3PE79SHJAZCDW1V5E9EA8JSKRBPEKAEK7.multisig-traits.executor-trait)
(use-trait wallet-trait 'SP3XD84X3PE79SHJAZCDW1V5E9EA8JSKRBPEKAEK7.multisig-traits.wallet-trait)

(impl-trait 'SP3XD84X3PE79SHJAZCDW1V5E9EA8JSKRBPEKAEK7.multisig-traits.wallet-trait)

;; errors
(define-constant ERR-CALLER-MUST-BE-SELF (err u100))
(define-constant ERR-OWNER-ALREADY-EXISTS (err u110))
(define-constant ERR-OWNER-NOT-EXISTS (err u120))
(define-constant ERR-UNAUTHORIZED-SENDER (err u130))
(define-constant ERR-TX-NOT-FOUND (err u140))
(define-constant ERR-TX-ALREADY-CONFIRMED (err u150))
(define-constant ERR-TX-INVALID-EXECUTOR (err u160))
(define-constant ERR-INVALID-WALLET (err u170))


;; version
(define-constant VERSION "0.0.1.alpha")

(define-read-only (get-version)
    VERSION
)

;; principal of the deployed contract
(define-data-var self principal (as-contract tx-sender))


;; owners
(define-data-var owners (list 50 principal) (list)) 

(define-read-only (get-owners)
    (var-get owners)
)

(define-private (add-owner-internal (owner principal))
    (var-set owners (unwrap-panic (as-max-len? (append (var-get owners) owner) u50)))
)

(define-public (add-owner (owner principal))
    (begin
        (asserts! (is-eq tx-sender (var-get self)) ERR-CALLER-MUST-BE-SELF)
        (asserts! (is-none (index-of (var-get owners) owner)) ERR-OWNER-ALREADY-EXISTS)
        (ok (add-owner-internal owner))
    )
)

(define-data-var rem-owner principal tx-sender)

(define-private (remove-owner-filter (o principal)) (not (is-eq o (var-get rem-owner))))

(define-public (remove-owner (owner principal))
    (begin
        (asserts! (is-eq tx-sender (var-get self)) ERR-CALLER-MUST-BE-SELF)
        (asserts! (not ( is-none (index-of (var-get owners) owner) )) ERR-OWNER-NOT-EXISTS)
        (var-set rem-owner owner)
        (ok (var-set owners (unwrap-panic (as-max-len? (filter remove-owner-filter (var-get owners)) u50))))
    )
)


;; minimum confirmation requirement 
(define-data-var min-confirmation uint u0)

(define-read-only (get-min-confirmation)
    (var-get min-confirmation)
)

(define-private (set-min-confirmation-internal (value uint))
    (var-set min-confirmation value)
)

(define-public (set-min-confirmation (value uint))
    (begin
        (asserts! (is-eq tx-sender (var-get self)) ERR-CALLER-MUST-BE-SELF) 
        (ok (set-min-confirmation-internal value))
    )
)

;; nonce
(define-data-var nonce uint u0)

(define-read-only (get-nonce)
    (var-get nonce)
)

(define-private (increase-nonce)
    (var-set nonce (+ (var-get nonce) u1))
)

;; transactions
(define-map transactions 
    uint 
    {
        executor: principal,
        confirmations: (list 50 principal),
        confirmed: bool,
        arg-p: principal,
        arg-u: uint
    }
)

(define-private (add (executor <executor-trait>) (arg-p principal) (arg-u uint))
    (let 
        (
            (tx-id (get-nonce))
        ) 
        (map-insert transactions tx-id {executor: (contract-of executor), confirmations: (list), confirmed: false, arg-p: arg-p, arg-u: arg-u})
        (increase-nonce)
        tx-id
    )
)

(define-read-only (get-transaction (tx-id uint))
    (unwrap-panic (map-get? transactions tx-id))
)

(define-read-only (get-transactions (tx-ids (list 20 uint)))
    (map get-transaction tx-ids)
)

(define-public (confirm (tx-id uint) (executor <executor-trait>) (wallet <wallet-trait>))
    (begin
        (asserts! (not (is-none (index-of (var-get owners) tx-sender))) ERR-UNAUTHORIZED-SENDER)
        (asserts! (is-eq (contract-of wallet) (var-get self)) ERR-INVALID-WALLET) 
        (let
            (
                (tx (unwrap! (map-get? transactions tx-id) ERR-TX-NOT-FOUND))
                (confirmations (get confirmations tx))
            )

            (asserts! (is-none (index-of confirmations tx-sender)) ERR-TX-ALREADY-CONFIRMED)
            (asserts! (is-eq (get executor tx) (contract-of executor)) ERR-TX-INVALID-EXECUTOR)
            
            (let 
                (
                    (new-confirmations (unwrap-panic (as-max-len? (append confirmations tx-sender) u50)))
                    (confirmed (>= (len new-confirmations) (var-get min-confirmation)))
                    (new-tx (merge tx {confirmations: new-confirmations, confirmed: confirmed}))
                )
                (map-set transactions tx-id new-tx)
                (if confirmed 
                    (try! (as-contract (contract-call? executor execute wallet (get arg-p tx) (get arg-u tx))))
                    false
                )
                (ok confirmed)
            )
        )
    )
)

(define-public (submit (executor <executor-trait>) (wallet <wallet-trait>) (arg-p principal) (arg-u uint))
    (begin
        (asserts! (not (is-none (index-of (var-get owners) tx-sender))) ERR-UNAUTHORIZED-SENDER)
        (asserts! (is-eq (contract-of wallet) (var-get self)) ERR-INVALID-WALLET) 
        (let
            ((tx-id (add executor arg-p arg-u)))
            (unwrap-panic (confirm tx-id executor wallet))
            (ok tx-id)
        )
    )
)


;; init
(define-private (init (o (list 50 principal)) (m uint))
    (begin
        (map add-owner-internal o)
        (set-min-confirmation-internal u2)
    )
)

(init (list 
    'SP3T23YN6MBF44YNV910FD8JNMN1NZYGKG3MMZ73X 
    'SP222SW5C3H6HRDJZ2H6R6P7NQMN1J0YYQKDSZXHW 
    'SP197WWCM834XPAZKBJSSQDZTJ0EBHGD2F6G42PEN
) u2)