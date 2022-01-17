;; the fee structure is defined by the calling client
;; this is to avoid duplication of the protocol just with adjusted fee structure
;; it is the responsibility of the client to adjust the post conditions accordingly
(define-trait fees-trait
  ((get-fees (uint) (response uint uint))
  (hold-fees (uint) (response bool uint))
  (release-fees (uint) (response bool uint))
  (pay-fees (uint) (response bool uint))))

(define-constant expiry u100)
(define-map swaps uint {ustx: uint, stx-sender: principal, nft-ids: (list 200 uint), nft-sender: (optional principal), when: uint, open: bool, fees: principal})
(define-data-var next-id uint u0)

;; scoped variables for trnsfr
(define-data-var ctx-nft-sender principal tx-sender)
(define-data-var ctx-nft-recipient principal tx-sender)

;; helper function to transfer stx to a principal with memo
(define-private (stx-transfer-to (ustx uint) (to principal) (memo (buff 34)))
  (begin
    (try! (stx-transfer? ustx tx-sender to))
    (print memo)
    (ok true)))

;; create a swap between btc and fungible token
(define-public (create-swap (ustx uint) (nft-ids (list 200 uint)) (nft-sender (optional principal)) (fees <fees-trait>))
  (let ((id (var-get next-id)))
    (asserts! (map-insert swaps id
      {ustx: ustx, stx-sender: tx-sender, nft-ids: nft-ids, nft-sender: nft-sender,
         when: block-height, open: true, fees: (contract-of fees)}) ERR_INVALID_ID)
    (var-set next-id (+ id u1))
    (try! (contract-call? fees hold-fees ustx))
    (match (stx-transfer-to ustx (as-contract tx-sender) 0x636174616d6172616e2073776170)
      success (ok id)
      error (err (* error u100)))))

;; any user can cancle the swap after the expiry period
(define-public (cancel (id uint) (fees <fees-trait>))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (ustx (get ustx swap)))
      (asserts! (is-eq (contract-of fees) (get fees swap)) ERR_INVALID_FEES_TRAIT)
      (asserts! (< (+ (get when swap) expiry) block-height) ERR_TOO_EARLY)
      (asserts! (get open swap) ERR_ALREADY_DONE)
      (asserts! (map-set swaps id (merge swap {open: false})) ERR_NATIVE_FAILURE)
      (try! (contract-call? fees release-fees ustx))
      (match (as-contract (stx-transfer-to
                ustx (get stx-sender swap)
                0x72657665727420636174616d6172616e2073776170))
        success (ok success)
        error (err (* error u100)))))

(define-private (check-err (transfer-result (response bool uint)) (result (response bool uint)))
  (if (is-err result) result transfer-result))

(define-private (trnsfr (id uint))
  (contract-call? 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2 transfer id (var-get ctx-nft-sender) (var-get ctx-nft-recipient)))

(define-private (transfer-many (nft-ids (list 200 uint)) (sender principal) (recipient principal))
  (begin
    (var-set ctx-nft-sender sender)
    (var-set ctx-nft-recipient recipient)
    (fold check-err (map trnsfr nft-ids) (ok true))))

;; any user can submit a tx that contains the swap
(define-public (submit-swap
    (id uint)
    (fees <fees-trait>))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (ustx (get ustx swap))
    (stx-receiver (default-to tx-sender (get nft-sender swap))))
      (asserts! (get open swap) ERR_ALREADY_DONE)
      (asserts! (is-eq (contract-of fees) (get fees swap)) ERR_INVALID_FEES_TRAIT)
      (asserts! (map-set swaps id (merge swap {open: false})) ERR_NATIVE_FAILURE)
      (asserts! (is-eq tx-sender stx-receiver) ERR_INVALID_STX_RECEIVER)
      (try! (contract-call? fees pay-fees ustx))
      (match (transfer-many
          (get nft-ids swap) stx-receiver (get stx-sender swap))
        success-nft (begin
            (asserts! success-nft ERR_NATIVE_FAILURE)
            (match (as-contract (stx-transfer-to
                (get ustx swap) stx-receiver
                0x636174616d6172616e2073776170))
              success-stx (ok success-stx)
              error-stx (err (* error-stx u100))))
        error-nft (err (* error-nft u1000)))))

(define-constant ERR_INVALID_ID (err u3))
(define-constant ERR_TOO_EARLY (err u4))
(define-constant ERR_ALREADY_DONE (err u7))
(define-constant ERR_INVALID_FUNGIBLE_TOKEN (err u8))
(define-constant ERR_INVALID_STX_RECEIVER (err u9))
(define-constant ERR_INVALID_FEES (err u10))
(define-constant ERR_INVALID_FEES_TRAIT (err u11))
(define-constant ERR_NATIVE_FAILURE (err u99))