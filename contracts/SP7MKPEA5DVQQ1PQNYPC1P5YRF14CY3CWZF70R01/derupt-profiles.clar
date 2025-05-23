;; .derupt-profiles Contract
;; (use-trait derupt-profile-trait 'ST1ZK0A249B4SWAHVXD70R13P6B5HNKZAA0WNTJTR.derupt-profile-trait.derupt-profile-trait)
(use-trait derupt-profile-trait 'SP7MKPEA5DVQQ1PQNYPC1P5YRF14CY3CWZF70R01.derupt-profile-trait.derupt-profile-trait)

;; Errors
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-NOTFOUND (err u101))
(define-constant ERR-ALREADY-ACTIVATED (err u106))

(define-public (activate-member (contract-address <derupt-profile-trait>)) 
    (let 
        (
            (member-caller (unwrap! (get name (unwrap! (principal-destruct? contract-caller) ERR-NOTFOUND)) ERR-NOTFOUND))
            (member-status (unwrap! (contract-call? contract-address get-activation-status tx-sender) ERR-NOTFOUND))
        )
        (asserts! (is-eq member-caller "derupt-profile") ERR-UNAUTHORIZED)
        (asserts! (is-eq (contract-of contract-address) contract-caller) ERR-UNAUTHORIZED)
        (asserts! (is-eq member-status false) ERR-ALREADY-ACTIVATED)                                 
        (is-ok (contract-call? contract-address registration-activation tx-sender))
        (print {publisher: tx-sender, contract: contract-caller})
        (ok true)
    )
)