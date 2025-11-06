(define-data-var admin principal tx-sender)
(define-data-var removing-code (string-ascii 30) "")
(define-map referral-codes (string-ascii 30) principal)
(define-map address-to-codes principal (list 50 (string-ascii 30)))
(define-constant ERR-EXISTING-CODE u100)
(define-constant ERR-LIST-OVERFLOW u101)
(define-constant ERR-NOT-ADMIN u401)
(define-constant ERR-NOT-OWNER u403)
(define-constant ERR-NOT-FOUND u404)

;; Private function to filter out a code from a list
(define-private (remove-code-from-list (c (string-ascii 30)))
  (not (is-eq c (var-get removing-code))))

;; Add a referral code for a user
(define-public (generate-referral-code (code (string-ascii 30)))
  (begin
    (asserts! (is-none (map-get? referral-codes code)) (err ERR-EXISTING-CODE))
    (let (
        (sender tx-sender)
        (codes (unwrap-panic (as-max-len? (append (get-referral-codes sender) code) u50)))
      )
      (map-set referral-codes code sender)
      (map-set address-to-codes sender codes)
      (ok true))))

;; Get the owner of a referral code
(define-read-only (get-referral-address (code (string-ascii 30)))
  (map-get? referral-codes code))

;; Get all referral codes for a user
(define-read-only (get-referral-codes (addr principal))
  (default-to (list ) (map-get? address-to-codes addr)))
  
;; Remove a referral code
(define-public (delete-referral-code (code (string-ascii 30)))
  (let (
    (owner-opt (map-get? referral-codes code))
    (some-owner (unwrap! owner-opt (err ERR-NOT-FOUND)))
    (existing (default-to (list) (map-get? address-to-codes some-owner)))
    )
    (asserts! (is-some owner-opt) (err ERR-NOT-FOUND))
    (asserts! (is-eq some-owner tx-sender) (err ERR-NOT-OWNER))
    (var-set removing-code code)
    (map-delete referral-codes code)
    (map-set address-to-codes some-owner (filter remove-code-from-list existing))
    (ok true)))

;; Remove a referral code (admin only)
(define-public (admin-delete-referral-code (code (string-ascii 30)))
    (let (
      (owner-opt (map-get? referral-codes code))
      (some-owner (unwrap! owner-opt (err ERR-NOT-FOUND)))
      (existing (default-to (list) (map-get? address-to-codes some-owner)))
      )
      (asserts! (is-some owner-opt) (err ERR-NOT-FOUND))
      (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-ADMIN))
      (var-set removing-code code)      
      (map-delete referral-codes code)
      (map-set address-to-codes some-owner (filter remove-code-from-list existing))
      (ok true)))