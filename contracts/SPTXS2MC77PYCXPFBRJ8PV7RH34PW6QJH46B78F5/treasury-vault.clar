(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Define the contract owner
(define-constant contract-owner tx-sender)

;; Define the whitelist
(define-map whitelist principal bool)

;; Define the withdrawal queue with an additional field for token amount
(define-map withdrawal-queue uint {user: principal, share-amount: uint, token-amount: uint, withdrawal-completed: bool})

;; Define the current-withdrawal-request variable
(define-data-var current-withdrawal-request uint u0)


;; Define the total number of withdrawal requests
(define-data-var total-withdrawal-requests uint u0)


;; Define the global total treasury NAV and shares issued
(define-data-var global-total-treasury-nav uint u0)
(define-data-var global-total-shares-issued uint u0)

(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

;; No maximum supply!
(define-fungible-token ustb-token)

;; Define the admin-only function
(define-private (admin-only)
  (if (is-eq tx-sender contract-owner)
    (ok true)
    (err "Only admin can call this function")
  )
)

;; Define the deposit-for-user function

(define-public (deposit-for-user (user principal) (amount uint))
  (begin
    (asserts! (is-some (map-get? whitelist  user)) (err "Not whitelisted"))
    (asserts! (> amount u0) (err "Amount must be greater than zero"))
    (asserts! (is-ok (admin-only)) (err "Only admin can call this function"))
    (let ((shares (calculate-shares amount)))
       (if (is-ok (ft-mint? ustb-token shares user))
        (begin
          (var-set global-total-shares-issued (+ (var-get global-total-shares-issued) shares))
          (var-set global-total-treasury-nav (+ (var-get global-total-treasury-nav) amount))
          (ok true)
        )
        (err "Failed to mint tokens")
      )
    )
  )
)

;; Define the request-withdrawal function
(define-public (request-withdrawal (share-amount uint))
  (begin
    (asserts! (> share-amount u0) (err "Share amount must be greater than zero"))
    (asserts! (>= (ft-get-balance ustb-token tx-sender) share-amount) (err "Insufficient shares"))
    (unwrap-panic (ft-burn? ustb-token share-amount tx-sender))
    (map-set withdrawal-queue (var-get total-withdrawal-requests) {user: tx-sender, share-amount: share-amount, token-amount: u0, withdrawal-completed: false})
    (var-set total-withdrawal-requests (+ (var-get total-withdrawal-requests) u1))
    (ok true)
  )
)

;; Define the process-withdrawal function
(define-public (process-withdrawal)
  (begin
    (asserts! (is-ok (admin-only)) (err "Only admin can call this function"))
    (let ((current-withdrawal (var-get current-withdrawal-request)))
      (let ((current-request (unwrap! (map-get? withdrawal-queue current-withdrawal) (err "no withdrawal found"))))
        (asserts! (not ( get withdrawal-completed current-request )) (err "withdrawal allready completed"))
        (let ((token-amount (calculate-tokens (get share-amount current-request))))
          (map-set withdrawal-queue current-withdrawal {user: (get user current-request), share-amount: (get share-amount current-request), token-amount: token-amount, withdrawal-completed: true})
        )
      )
      (var-set current-withdrawal-request (+ current-withdrawal u1))
    )
    (ok true)
  )
)

;; Define the get-withdrawal function
(define-read-only (get-withdrawal (id uint))
  (match (map-get? withdrawal-queue id)
    entry (ok entry)
    (err "No withdrawal found with this ID")
  )
)

;; Define the calculate-shares function
(define-read-only (calculate-shares (amount uint))
  (if (or (is-eq (var-get global-total-shares-issued) u0) (is-eq (var-get global-total-treasury-nav) u0))
    amount
    (/ (* amount (var-get global-total-shares-issued)) (var-get global-total-treasury-nav))
  )
)

;; Define the calculate-tokens function
(define-read-only (calculate-tokens (share-amount uint))
  (if (is-eq (ft-get-supply ustb-token) u0)
    u0
    (/ (* share-amount (var-get global-total-treasury-nav)) (ft-get-supply ustb-token))
  )
)

;; Define the add-whitelist function
(define-public (add-whitelist (user principal))
  (begin
    (asserts! (is-ok (admin-only)) (err "Only admin can call this function"))
    (map-set whitelist  user true)
    (ok true)
  )
)

;; Define the remove-whitelist function
(define-public (remove-whitelist (user principal))
  (begin
    (asserts! (is-ok (admin-only)) (err "Only admin can call this function"))
    (map-delete whitelist user)
    (ok true)
  )
)

;; Define the is-whitelisted function
(define-read-only  (is-whitelisted (user principal))
  (ok (is-some (map-get? whitelist user)))
)

(define-read-only (get-global-total-treasury-nav)
  (ok (var-get global-total-treasury-nav))
)

(define-read-only (get-global-total-shares-issued)
  (ok (var-get global-total-shares-issued))
)

;; Define the set-global-total-treasury-nav function
(define-public (set-global-total-treasury-nav (new-value uint))
  (begin
    (asserts! (is-ok (admin-only)) (err "Only admin can call this function"))
    (var-set global-total-treasury-nav new-value)
    (ok true)
  )
)

;; Define the increment-global-total-treasury-nav function
(define-public (increment-global-total-treasury-nav (amount uint))
  (begin
    (asserts! (is-ok (admin-only)) (err "Only admin can call this function"))
    (var-set global-total-treasury-nav (+ (var-get global-total-treasury-nav) amount))
    (ok true)
  )
)

;; Define the set-global-total-shares-issued function
(define-public (set-global-total-shares-issued (amount uint))
  (begin
    (asserts! (is-ok (admin-only)) (err "Only admin can call this function"))
    (var-set global-total-shares-issued amount)
    (ok true)
  )
)

;; Define the increment-global-total-shares-issued function
(define-public (increment-global-total-shares-issued (amount uint))
  (begin
    (asserts! (is-ok (admin-only)) (err "Only admin can call this function"))
    (var-set global-total-shares-issued (+ (var-get global-total-shares-issued) amount))
    (ok true)
  )
)

;; sip-010 implementation
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(asserts! (is-eq tx-sender sender) err-not-token-owner)
		(try! (ft-transfer? ustb-token amount sender recipient))
		(match memo to-print (print to-print) 0x)
		(ok true)
	)
)

(define-read-only (get-name)
	(ok "USTB")
)

(define-read-only (get-symbol)
	(ok "USTB")
)

(define-read-only (get-decimals)
	(ok u0)
)

(define-read-only (get-balance (who principal))
	(ok (ft-get-balance ustb-token who))
)

(define-read-only (get-total-supply)
	(ok (ft-get-supply ustb-token))
)

(define-read-only (get-token-uri)
	(ok none)
)

(define-public (mint (amount uint) (recipient principal))
	(begin
		(asserts! (is-eq tx-sender contract-owner) err-owner-only)
		(ft-mint? ustb-token amount recipient)
	)
)