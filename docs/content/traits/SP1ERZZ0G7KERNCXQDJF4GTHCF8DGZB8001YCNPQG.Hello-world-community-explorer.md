---
title: "Trait Hello-world-community-explorer"
draft: true
---
```

;; title: community-hello-world
;; description: A contract that provides a simple community billborad,
;; readable by anyone and can only be updated by an admin

;;;;;;;;;;;;;;;;;;;;;
;; cons, vars, maps;;
;;;;;;;;;;;;;;;;;;;;;

;; Error Messages
(define-constant ERR-TX-SENDER-NOT-NEXT-USER (err u0))
(define-constant ERR-UPDATED-USER-NAME-EMPTY (err u1))
(define-constant ERR-UPDATED-USER-PRINCIPAL-IS-ADMIN (err u2))
(define-constant ERR-TX-SENDER-IS-N0T-ADMIN (err u3))
(define-constant ERR-UPDATED-USER-PRINCIPAL-IS-NEXT-USER (err u4))

;; Constants that sets deployers principal as admin
(define-constant admin tx-sender)

;; Variable that keeps track of the *next* user that will introduce themselves / write to the billboard
(define-data-var next-user principal tx-sender)

;; Variable tuple that contains new members info
(define-data-var billboard {new-user-principal: principal, new-user-name: (string-ascii 24)}
    {new-user-principal: tx-sender,
     new-user-name:""
    }
)

;;;;;;;;;;;;;;;;;;;;;
;; Read functions;;
;;;;;;;;;;;;;;;;;;;;;

;; Get Community Billboard
(define-read-only (get-billboard) 
   (var-get billboard)
)

;; Get next User
(define-read-only (get-next-user) 
    (var-get next-user)
)

;;;;;;;;;;;;;;;;;;;;;
;; Write functions;;
;;;;;;;;;;;;;;;;;;;;;

;; Update Billboard
;; @desc - a function that allows next-user to update community billboard
;; Param - new-user-name: (string-ascii 24)

(define-public (update-billboard (updated-user-name (string-ascii 24))) 
  (begin
    ;; Assert that tx-sender is next-user (approved by admin)
     (asserts! (is-eq tx-sender (var-get next-user)) ERR-TX-SENDER-NOT-NEXT-USER)
    ;; Assert that updated-user-name is not empty
     (asserts! (not (is-eq updated-user-name "")) ERR-UPDATED-USER-NAME-EMPTY)
    ;; Var-Set Billboard with new keys
     (ok (var-set billboard 
         {new-user-principal: tx-sender,
          new-user-name:updated-user-name
         }
     ))
  )
)

;; Admin set next user
;; @desc - Function that allows admin set / give permission to next-user
;; Param - updated-user-principal: Principal

(define-public (admin-set-next-user (updated-user-principal principal)) 
  (begin
    ;; Assert that Updated-user-principal is NOT admin
     (asserts! (not (is-eq updated-user-principal admin)) ERR-UPDATED-USER-PRINCIPAL-IS-ADMIN)
    ;; Assert that tx-sender is admin
     (asserts! (is-eq tx-sender admin) ERR-TX-SENDER-IS-N0T-ADMIN)
    ;; Assert that Updated-user-principal is NOT next-user
     (asserts! (not (is-eq updated-user-principal (var-get next-user))) ERR-UPDATED-USER-PRINCIPAL-IS-NEXT-USER)
    ;; Var-Set next-user with Updated-user-principal
     (ok (var-set next-user updated-user-principal))
  )
)
```
