;; title: community-hello-world
;; contract that provide simple community billboard, readable by anyone but only updatable by admins permissions

;;;;;;;;;;;;;;;;;;;;;;
;; Cons, Var, & Maps;;
;;;;;;;;;;;;;;;;;;;;;;

;;constant that sets depoyer principal as admin
(define-constant admin tx-sender)

;; Variable that keeps tract of the *next* uset that'll introduce themselves / write to the billboard
(define-data-var next-user principal tx-sender)

;; Variable tuple that contains new member info
(define-data-var billboard {new-user-principal: principal, new-user-name: (string-ascii 24)} {
    new-user-principal: tx-sender,
    new-user-name: ""
})
(define-constant ERR-TX-SENDER-IS-NOT-NEXT-USER (err u0))
(define-constant ERR-UPDATED-USER-NAME-IS-EMPTY (err u1))                                                                                                                     
(define-constant ERR-UPDATED--USER-PRINCIPAL-IS-NOT-ADMIN (err u2))
(define-constant ERR-UPDATED--USER-PRINCIPAL-IS-CURRENT-USER (err u3))
(define-constant ERR-TX-SENDER-IS-NOTT-ADMIN (err u4))

;;;;;;;;;;;;;;;;;;;
;; Read Functions;;
;;;;;;;;;;;;;;;;;;;

;; Get community billoard
(define-read-only (get-billboard)
    (var-get billboard)
)

;; Get Next user
(define-read-only (get-next-user) 
    (var-get next-user)
)


;;;;;;;;;;;;;;;;;;;;
;; Write Functions;;
;;;;;;;;;;;;;;;;;;;;

;; Update Billboard
;; @desc - function used by next-user to update the community billboard
;; @param - new-user-name: (string-ascii 24)

(define-public (update-billboard (updated-user-name (string-ascii 24))) 
    (begin 
        ;; Assert that tx-sender is next-user (approved by admin)
        (asserts! (is-eq tx-sender (var-get next-user)) (err u0))
        ;; Assert that updated-user-name is not empty
        (asserts! (not (is-eq updated-user-name "")) (err u1))
        ;; Var-set billboard with new keys
        (ok (var-set billboard {
            new-user-principal: tx-sender,
            new-user-name: updated-user-name
        }))
    )
)

;; Admin Set New user
;; @desc - function used by admin to set / give permission to next user
;; @param - updated-user-principal: principal
(define-public (admin-set-new-user (updated-user-principal principal))
    (begin
        ;; Assert that tx-sender is admin
        (asserts! (is-eq tx-sender admin) (err u4))
        ;; Assert that updated-user-principal is NOT admin
        (asserts! (not (is-eq tx-sender updated-user-principal)) (err u2))
        ;; Assert that updated-user-principal is NOT current next-user
        (asserts! (not (is-eq updated-user-principal (var-get next-user))) (err u3))
        ;; Var-set next-user with updated-user-principal
        (ok (var-set next-user updated-user-principal))
        
    )
)