;; Gary Riger taking 100 Days of Clarity by Jesus Najera WAGMI

;; community-hello-world 
;; contract that provides a simple community billboard readable by anoyone but only updateable the admin's permission

;;;;;;;;;;;;;;;;;;;;;;;;
;; Cons, Vars, & Maps ;;
;;;;;;;;;;;;;;;;;;;;;;;;


;;Error messages 
(define-constant ERR-TX-SENDER-NOT-NEXT-USER (err u0))
(define-constant ERR-UPDATED-USER-NOT-EMPTY (err u1))
(define-constant ERR-TX-SENDER-IS-NOT-ADMIN (err u2))
(define-constant ERR-UPDATED-USER-IS-ADMIN (err u3))
(define-constant ERR-UPDATED-USER-NOT-NEXT-USER (err u4))

;; Constant that sets deplopyer principal as admin ;;
(define-constant admin tx-sender)

;; Variable that keeps track of the next user that'll introduce themselves / write to the billboards;;
(define-data-var next-user principal tx-sender)

;; Variable tuple that contains new member info ;;
(define-data-var billboard {new-user-principal: principal, new-user-name: (string-ascii 24)} {
    new-user-principal: tx-sender, 
    new-user-name: "" 
    }
)
;;;;;;;;;;;;;;;;;;;;;;;;)
;;   Read Functions s ;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; Get community Billboard

(define-read-only (get-billboard) 
    (var-get billboard))

(define-read-only (get-next-user) 
    (var-get next-user))



;;;;;;;;;;;;;;;;;;;;;;;;
;;  Write Functions s ;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; Update Billboard
;; @desc - function used by next-user to update the community billboard
;; @param - new-user-name: (string-ascii 24)

(define-public (update-billboard (updated-user-name (string-ascii 24))) 
    (begin 


;; Assert that tx-sender is not-user (approved by admin)
    (asserts! (is-eq tx-sender (var-get next-user)) ERR-TX-SENDER-NOT-NEXT-USER)

;; Assert that updated user-name is not empty
    (asserts! (not (is-eq updated-user-name  "")) ERR-UPDATED-USER-NOT-EMPTY)


;; Var-set billboard with new keys
    (ok (var-set billboard {  
      new-user-principal: tx-sender, 
      new-user-name: updated-user-name
    }))
    )
)



;; Admin Set New User
;; @desc - function used by admin to set / give permission to next user

(define-public (admin-set-new-user (updated-user-principal principal)) 
    (begin

    ;; Assert that tx-sender is admin
    (asserts!  (is-eq tx-sender admin) ERR-TX-SENDER-IS-NOT-ADMIN)

    ;; Assert that updated-user-principal is NOT admin
    (asserts! (not (is-eq tx-sender updated-user-principal)) ERR-UPDATED-USER-IS-ADMIN)

    ;; Assert that updated-user-principal is NOT current next-user
    (asserts! (not (is-eq updated-user-principal (var-get next-user))) ERR-UPDATED-USER-NOT-NEXT-USER)

    ;; Var-set next-user with updated-user-principal
    (ok (var-set next-user updated-user-principal))
    )
)