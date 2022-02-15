(use-trait fungible-token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; the fee structure is defined by the calling client
;; this is to avoid duplication of the protocol just with adjusted fee structure
;; it is the responsibility of the client to adjust the post conditions accordingly
(define-trait fees-trait
  ((get-fees (uint) (response uint uint))
  (hold-fees (uint) (response bool uint))
  (release-fees (uint) (response bool uint))
  (pay-fees (uint) (response bool uint))))

(define-constant expiry u100)
(define-map swaps uint {satoshible-id: uint, satoshible-sender: principal, ft-amount: uint, ft-sender: (optional principal), when: uint, open: bool, ft: principal, fees: principal})
(define-data-var next-id uint u0)

;; helper function to transfer satoshible from tx-sender to a principal with memo
(define-private (satoshible-transfer-to (satoshible-id uint) (to principal) (memo (buff 34)))
  (begin
    (try! (contract-call? 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.satoshibles transfer    
      satoshible-id tx-sender to))
    (print memo)
    (ok true)))

;; create a swap between satoshible and fungible token
(define-public (create-swap (satoshible-id uint) (ft-amount uint) (ft-sender (optional principal)) (ft <fungible-token>) (fees <fees-trait>))
  (let ((id (var-get next-id)))
    (asserts! (map-insert swaps id
      {satoshible-id: satoshible-id, satoshible-sender: tx-sender, ft-amount: ft-amount, ft-sender: ft-sender,
         when: block-height, open: true, ft: (contract-of ft), fees: (contract-of fees)}) ERR_INVALID_ID)
    (var-set next-id (+ id u1))
    (try! (contract-call? fees hold-fees satoshible-id))
    (match (satoshible-transfer-to satoshible-id (as-contract tx-sender) 0x636174616d6172616e2073776170)
      success (ok id)
      error (err (* error u100)))))

;; any user can cancle the swap after the expiry period
(define-public (cancel (id uint) (ft <fungible-token>) (fees <fees-trait>))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (satoshible-id (get satoshible-id swap)))
      (asserts! (is-eq (contract-of ft) (get ft swap)) ERR_INVALID_FUNGIBLE_TOKEN)
      (asserts! (is-eq (contract-of fees) (get fees swap)) ERR_INVALID_FEES_TRAIT)
      (asserts! (< (+ (get when swap) expiry) block-height) ERR_TOO_EARLY)
      (asserts! (get open swap) ERR_ALREADY_DONE)
      (asserts! (map-set swaps id (merge swap {open: false})) ERR_NATIVE_FAILURE)
      (try! (contract-call? fees release-fees satoshible-id))
      (match (as-contract (satoshible-transfer-to
                satoshible-id (get satoshible-sender swap)
                0x72657665727420636174616d6172616e2073776170))
        success (ok success)
        error (err (* error u100)))))

;; any user can submit a tx that contains the swap
(define-public (submit-swap
    (id uint)
    (ft <fungible-token>)
    (fees <fees-trait>))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (satoshible-id (get satoshible-id swap))
    (satoshible-receiver (default-to tx-sender (get ft-sender swap))))
      (asserts! (get open swap) ERR_ALREADY_DONE)
      (asserts! (is-eq (contract-of ft) (get ft swap)) ERR_INVALID_FUNGIBLE_TOKEN)
      (asserts! (is-eq (contract-of fees) (get fees swap)) ERR_INVALID_FEES_TRAIT)
      (asserts! (map-set swaps id (merge swap {open: false})) ERR_NATIVE_FAILURE)
      (asserts! (is-eq tx-sender satoshible-receiver) ERR_INVALID_RECEIVER)
      (try! (contract-call? fees pay-fees satoshible-id))
      (match (contract-call? ft transfer
          (get ft-amount swap) satoshible-receiver (get satoshible-sender swap) (some 0x636174616d6172616e2073776170))
        success-ft (begin
            (asserts! success-ft ERR_NATIVE_FAILURE)
            (match (as-contract (satoshible-transfer-to
                (get satoshible-id swap) satoshible-receiver
                0x636174616d6172616e2073776170))
              success-stx (ok success-stx)
              error-stx (err (* error-stx u100))))
        error-ft (err (* error-ft u1000)))))

(define-constant ERR_INVALID_ID (err u3))
(define-constant ERR_TOO_EARLY (err u4))
(define-constant ERR_ALREADY_DONE (err u7))
(define-constant ERR_INVALID_FUNGIBLE_TOKEN (err u8))
(define-constant ERR_INVALID_RECEIVER (err u9))
(define-constant ERR_INVALID_FEES (err u10))
(define-constant ERR_INVALID_FEES_TRAIT (err u11))
(define-constant ERR_NATIVE_FAILURE (err u99))
