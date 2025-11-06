(define-data-var admin principal tx-sender)
(define-data-var removing-code (string-ascii 30) "")
(define-map referral-codes (string-ascii 30) principal)
(define-map address-to-codes principal (list 10 (string-ascii 30)))
(define-constant ERR-EXISTING-CODE u100)
(define-constant ERR-NOT-ADMIN u101)
(define-constant ERR-MAX-CODES-REACHED u102)
(define-constant ERR-NOT-OWNER u103)
(define-constant ERR-NOT-FOUND u104)
(define-constant ERR-CODE-TOO-SHORT u105)
(define-constant ERR-CODE-TOO-LONG u106)

;; Get current admin
(define-read-only (get-admin)
  (var-get admin))

;; Get the owner of a referral code
(define-read-only (get-referral-address (code (string-ascii 30)))
  (map-get? referral-codes code))

;; Get all referral codes for a user
(define-read-only (get-referral-codes (addr principal))
  (default-to (list ) (map-get? address-to-codes addr)))

;; Private function to filter out a code from a list
(define-private (remove-code-from-list (c (string-ascii 30)))
  (not (is-eq c (var-get removing-code))))

;; Add a referral code for a user
(define-public (generate-referral-code (code (string-ascii 30)))
  (begin
    (asserts! (>= (len code) u3) (err ERR-CODE-TOO-SHORT))
    (asserts! (<= (len code) u30) (err ERR-CODE-TOO-LONG))
    (asserts! (is-none (map-get? referral-codes code)) (err ERR-EXISTING-CODE))
    (let (
        (sender tx-sender)
        (current-codes (get-referral-codes sender))
        (codes-count (len current-codes))
      )
      (asserts! (< codes-count u10) (err ERR-MAX-CODES-REACHED))
      (let (
          (new-codes (unwrap-panic (as-max-len? (append current-codes code) u10)))
        )
        (map-set referral-codes code sender)
        (map-set address-to-codes sender new-codes)
        (print {
          event: "referral-code-generated",
          code: code,
          owner: sender
        })
        (ok true)))))
  
;; Remove a referral code for a user
(define-public (delete-referral-code (code (string-ascii 30)))
  (let (
    (owner-opt (map-get? referral-codes code))
    (some-owner (unwrap! owner-opt (err ERR-NOT-FOUND)))
    (existing (default-to (list) (map-get? address-to-codes some-owner)))
    )
    (asserts! (is-eq some-owner tx-sender) (err ERR-NOT-OWNER))
    (var-set removing-code code)
    (map-delete referral-codes code)
    (map-set address-to-codes some-owner (filter remove-code-from-list existing))
    (print {
      event: "referral-code-deleted",
      code: code,
      owner: some-owner,
      deleted-by: tx-sender
    })
    (ok true)))

;; Remove any referral code (admin only)
(define-public (admin-delete-referral-code (code (string-ascii 30)))
    (let (
      (owner-opt (map-get? referral-codes code))
      (some-owner (unwrap! owner-opt (err ERR-NOT-FOUND)))
      (existing (default-to (list) (map-get? address-to-codes some-owner)))
      )
      (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-ADMIN))
      (var-set removing-code code)      
      (map-delete referral-codes code)
      (map-set address-to-codes some-owner (filter remove-code-from-list existing))
      (print {
        event: "referral-code-deleted",
        code: code,
        owner: some-owner,
        deleted-by: tx-sender,
        admin-action: true
      })
      (ok true)))

;; Change admin (only current admin can do this)
(define-public (change-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-ADMIN))
    (var-set admin new-admin)
    (ok true)))