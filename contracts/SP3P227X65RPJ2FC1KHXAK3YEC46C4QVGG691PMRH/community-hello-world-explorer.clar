;; community hello world
;; This is a contract that provides a simple community billboard readable by anyone but only updateable by admin

;; Constants, Vars, & maps
(define-constant admin tx-sender)

;; variable that keeps track of the next user that will introduce themselves / write to the billboard
(define-data-var next-user principal tx-sender)

(define-data-var billboard {new-user-principal: principal, new-user-name: (string-ascii 24)} 
    {new-user-principal: tx-sender, new-user-name: ""}
)

;; Read functions
(define-read-only (get-billboard)
    (var-get billboard)
)

(define-read-only (get-next-user)
    (var-get next-user)
)

;; Write functions

;; Update billboard
;; @desc - function by next-user to update the community billboard
;; @param - new-user-name: (string-ascii 24)

(define-public (update-billboard (updated-user-name (string-ascii 24)))
    (begin 
        (asserts! (is-eq (var-get next-user) tx-sender) (err u1))
        (asserts! (not (is-eq updated-user-name "")) (err u2))
        (ok (var-set billboard {
            new-user-principal: tx-sender, 
            new-user-name: updated-user-name
        }))
    )
)

;; Admin set new user

(define-public (set-next-user (who principal))
    (begin
        (asserts! (is-eq admin tx-sender) (err u3))
        (asserts! (not (is-eq admin who)) (err u4))
        (asserts! (not (is-eq (var-get next-user) who)) (err u5))
        (var-set next-user who)
        (ok true)
    )
) 
