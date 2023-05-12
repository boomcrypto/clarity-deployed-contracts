;; .derupt-members Contract
(use-trait derupt-user-trait 'SP3T3JC6V4S94PPB7WFEK17863HPG3EYP6CJ65E7M.derupt-user-trait.derupt-user-trait)
(define-constant notfound (err 101))
(define-constant unauthorized-user (err 100))
(define-constant alreadyactivated (err 102))

(define-public (activate-member (contract-address <derupt-user-trait>)) 
    (let 
        (
            (member-caller (unwrap! (get name (unwrap! (principal-destruct? contract-caller) notfound)) notfound))
            (member-status (unwrap! (contract-call? contract-address get-activation-status tx-sender) notfound))
        )
        (asserts! (is-eq member-caller "derupt-user") unauthorized-user)
        (asserts! (is-eq (contract-of contract-address) contract-caller) unauthorized-user)
        (asserts! (is-eq member-status false) alreadyactivated)                                 
        (is-ok (contract-call? contract-address registration-activation tx-sender))
        (ok (print {publisher: tx-sender, contract: contract-caller}))
    )
)