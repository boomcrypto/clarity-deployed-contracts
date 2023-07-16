
;; community-hello-world
;; contract that provides a simple community billboard, readable by anyone but only updateable by admins

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; cons, Vars, and Maps ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Constant that sets deployer principal as admin
(define-constant admin tx-sender)

;; Error Messages
(define-constant ERR-TX-SENDER-NOT-NEXT-USER (err u0))
(define-constant ERR-UPDATED-USER-NAME-EMPTY (err u1))
(define-constant ERR-UPDATED-USER-PRINCIPAL-NOT-ADMIN (err u2))
(define-constant ERR-UPDATED-USER-PRINCIPAL-TX-SENDER (err u3))
(define-constant ERR-UPDATED-USER-PRINCIPAL-NEXT-USER (err u4))

;; Variable that keeps track of the next user that'll introduce themselves/ write to the billboard
(define-data-var next-user principal tx-sender)

;; Variable tuple that contains new member info
(define-data-var billboard {new-user-principal: principal, new-user-name: (string-ascii 24)} {
    new-user-principal: tx-sender,
    new-user-name: ""
})

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   Read Functions     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Get community billboard
(define-read-only (get-billboard) 
    (var-get billboard)   
) 

(define-read-only (get-next-user) 
    (var-get next-user)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    Write Functions   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Update Billboard
;; @desc - updates the billboard with the next user's info
;; @param - new-user-name: string-ascii 24
(define-public (update-billboard (updated-user-name (string-ascii 24))) 
    (begin
        ;; Assert that tx-sender is next user (approved by admin)
        (asserts! (is-eq tx-sender (get-next-user)) ERR-TX-SENDER-NOT-NEXT-USER)

        ;; Assert that updated-user-name is not empty
        (asserts! (not (is-eq updated-user-name "")) ERR-UPDATED-USER-NAME-EMPTY)

        ;; Var-set billboard wit new keys
        (ok (var-set billboard {
            new-user-principal: tx-sender, 
            new-user-name: updated-user-name
        }))        
    )
)

;; Admin Set New User
;; @desc - function used by admin to set the next user
;; @param - new-user-principal: principal
(define-public (admin-set-new-user (updated-user-principal principal)) 
    (begin
        ;; Assert that tx-sender is admin
        (asserts! (is-eq tx-sender admin) ERR-UPDATED-USER-PRINCIPAL-NOT-ADMIN)

        ;; Assert that updated-user-principal is not Admin
        (asserts! (not (is-eq tx-sender updated-user-principal)) ERR-UPDATED-USER-PRINCIPAL-TX-SENDER)  

        ;; Assert that updated-user-principal is not next-user
        (asserts! (not (is-eq (get-next-user) updated-user-principal)) ERR-UPDATED-USER-PRINCIPAL-NEXT-USER)

        ;; Var-set next-user with updated-user-principal
        (ok (var-set next-user updated-user-principal))
       
    )
)