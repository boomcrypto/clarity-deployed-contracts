;; By iFlames
;; community-hello-world
;; contract thet provide a simple community billboard, readable by anyone but only updateable by Admins permission

;;;;;;;;;;;;;;;;;;;;;;;;
;; Cons, Vars, & maps ;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; Constant that sets develoyer principal as admin
(define-constant admin tx-sender)

;; Error messages
(define-constant ERR-TX-SENDER-NOT-NEXT-USER (err u0))
(define-constant UPDATED-USER-NAME-IS-EMPTY (err u1))
(define-constant TX-SENDER-IS-ADMIN (err u2))
(define-constant UPDATED-USER-PRINCIPAL-IS-ADMIN (err u3))
(define-constant UPDATED-USER-PRINCIPAL-IS-CURRENT-NEXT-USER (err u4))


;; Variable that keeps track of the user that will introduce themselves / write to the billboard
(define-data-var next-user principal tx-sender)

;; Variable
(define-data-var
	billboard {
		new-user-principal: principal,
		new-user-name: (string-ascii 24)
	}
	{new-user-principal: tx-sender,
	new-user-name: ""}
)

;;;;;;;;;;;;;;;;;;;
;; Read Function ;;
;;;;;;;;;;;;;;;;;;;

;; Get community billboard
(define-read-only (get-billboard)
	(var-get billboard)
)

;; Get next user
(define-read-only (get-next-user)
	(var-get next-user)
)

;;;;;;;;;;;;;;;;;;;;
;; Write Function ;;
;;;;;;;;;;;;;;;;;;;;

;; Update Billboard
;; @desc - function used by next-user to update the  community billboard
;; @param - new-user-name: (string-ascii 24)

(define-public
	(update-billboard (update-user-name (string-ascii 24)))
	(begin
		;; Assert that tx-sender is next-user (approved by admin)
		(asserts! (is-eq tx-sender (var-get next-user)) ERR-TX-SENDER-NOT-NEXT-USER)

		;; Assert that updated user-name is not empty
		(asserts!
			(not (is-eq update-user-name ""))
			UPDATED-USER-NAME-IS-EMPTY
		)

		;; Var-set billboard with new keys
		(ok (var-set billboard {
			new-user-principal: tx-sender,
			new-user-name: update-user-name
			}
		))
	)
)


;; Admin set new user
;; @desc - function user by sdmn to set / give permission to next user
;; @param - updated-user-principal: principal
(define-public
	(admin-set-new-user (updated-user-principal principal))
	(begin
		;; Assert tx-sender is admin
		(asserts! (is-eq tx-sender admin) TX-SENDER-IS-ADMIN)

		;; Assert that Updated-user-principal is NOT admin
		(asserts! (not (is-eq tx-sender updated-user-principal)) UPDATED-USER-PRINCIPAL-IS-ADMIN)

		;; Assert that updated-user-principal is NOT current next-user
		(asserts! (not (is-eq updated-user-principal (var-get next-user))) UPDATED-USER-PRINCIPAL-IS-CURRENT-NEXT-USER)

		;; Var-set next-user with updated updated-user-principal
		(ok (var-set next-user updated-user-principal))
	)
)
