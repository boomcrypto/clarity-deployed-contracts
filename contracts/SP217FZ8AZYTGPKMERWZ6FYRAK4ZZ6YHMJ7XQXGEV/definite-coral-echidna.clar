(define-data-var admin principal tx-sender)
(define-data-var removing-code (string-ascii 30) "")
(define-map referral-codes (string-ascii 30) principal)
(define-map address-to-codes principal (list 50 (string-ascii 30)))
(define-constant ERR-LIST-OVERFLOW u102)

;; Admin address
;; Variable used to store the code to be removed from a list
;; Map: referral code -> owner
;; Map: address -> list of referral codes
;; Error constant for list overflow

;; Private function to filter out a code from a list
(define-private (remove-code-from-list (c (string-ascii 30)))
  (not (is-eq c (var-get removing-code))))

;; Add a referral code for a user
(define-public (generate-referral-code (code (string-ascii 30)))
  (begin
    (asserts! (is-none (map-get? referral-codes code)) (err u100))
    (let ((sender tx-sender))
      (map-set referral-codes code sender)
      (let ((existing (default-to (list) (map-get? address-to-codes sender))))
        (begin
          (asserts! (< (len existing) u50) (err u101))
          ;; Aggiungi in fondo alla lista, controllando overflow
          (map-set address-to-codes sender
            (unwrap! (as-max-len? (append existing code) u50) (err ERR-LIST-OVERFLOW)))
          (ok true))))))

;; Get the owner of a referral code
(define-read-only (get-referral-address (code (string-ascii 30)))
  (map-get? referral-codes code))

;; Get all referral codes for a user
(define-read-only (get-referral-codes (addr principal))
  (map-get? address-to-codes addr))

;; Remove a referral code (admin only)
(define-public (admin-delete-referral-code (code (string-ascii 30)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u401))
    (let ((owner-opt (map-get? referral-codes code)))
      (match owner-opt some-owner
        (begin
          (var-set removing-code code)
          (let (
              (existing (default-to (list) (map-get? address-to-codes some-owner)))
              (filtered (filter remove-code-from-list existing))
            )
            (begin
              (map-delete referral-codes code)
              (map-set address-to-codes some-owner filtered)
              (ok true))))
        (err u404)))))