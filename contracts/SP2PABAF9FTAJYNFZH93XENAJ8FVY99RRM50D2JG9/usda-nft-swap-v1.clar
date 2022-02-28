(use-trait non-fungible-token .nft-trait.nft-trait)

;; the fee structure is defined by the calling client
;; this is to avoid duplication of the protocol just with adjusted fee structure
;; it is the responsibility of the client to adjust the post conditions accordingly
(define-trait fees-trait
  ((get-fees (uint) (response uint uint))
  (hold-fees (uint) (response bool uint))
  (release-fees (uint) (response bool uint))
  (pay-fees (uint) (response bool uint))))

(define-constant expiry u100)
(define-map swaps uint {usda: uint, buyer: principal, nft-id: uint, nft-sender: (optional principal), when: uint, open: bool, nft: principal, fees: principal})
(define-data-var next-id uint u0)

;; helper function to transfer usda to a principal with memo
(define-private (usda-transfer-to (amount uint) (to principal) (memo (buff 34)))
  (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token  
    transfer amount tx-sender to (some memo)))

;; create a swap between btc and fungible token
(define-public (create-swap (usda uint) (nft-id uint) (nft-sender (optional principal)) (nft <non-fungible-token>) (fees <fees-trait>))
  (let ((id (var-get next-id)))
    (asserts! (map-insert swaps id
      {usda: usda, buyer: tx-sender, nft-id: nft-id, nft-sender: nft-sender,
         when: block-height, open: true, nft: (contract-of nft), fees: (contract-of fees)}) ERR_INVALID_ID)
    (var-set next-id (+ id u1))
    (try! (contract-call? fees hold-fees usda))
    (match (usda-transfer-to usda (as-contract tx-sender) 0x636174616d6172616e2073776170)
      success (ok id)
      error (err (* error u100)))))

;; any user can cancle the swap after the expiry period
(define-public (cancel (id uint) (nft <non-fungible-token>) (fees <fees-trait>))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (usda (get usda swap)))
      (asserts! (is-eq (contract-of nft) (get nft swap)) ERR_INVALID_FUNGIBLE_TOKEN)
      (asserts! (is-eq (contract-of fees) (get fees swap)) ERR_INVALID_FEES_TRAIT)
      (asserts! (< (+ (get when swap) expiry) block-height) ERR_TOO_EARLY)
      (asserts! (get open swap) ERR_ALREADY_DONE)
      (asserts! (map-set swaps id (merge swap {open: false})) ERR_NATIVE_FAILURE)
      (try! (contract-call? fees release-fees usda))
      (match (as-contract (usda-transfer-to
                usda (get buyer swap)
                0x72657665727420636174616d6172616e2073776170))
        success (ok success)
        error (err (* error u100)))))

;; any user can submit a tx that contains the swap
(define-public (submit-swap
    (id uint)
    (nft <non-fungible-token>)
    (fees <fees-trait>))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (usda (get usda swap))
    (receiver (default-to tx-sender (get nft-sender swap))))
      (asserts! (get open swap) ERR_ALREADY_DONE)
      (asserts! (is-eq (contract-of nft) (get nft swap)) ERR_INVALID_FUNGIBLE_TOKEN)
      (asserts! (is-eq (contract-of fees) (get fees swap)) ERR_INVALID_FEES_TRAIT)
      (asserts! (map-set swaps id (merge swap {open: false})) ERR_NATIVE_FAILURE)
      (asserts! (is-eq tx-sender receiver) ERR_INVALID_RECEIVER)
      (try! (contract-call? fees pay-fees usda))
      (match (contract-call? nft transfer
          (get nft-id swap) receiver (get buyer swap))
        success-nft (begin
            (asserts! success-nft ERR_NATIVE_FAILURE)
            (match (as-contract (usda-transfer-to
                (get usda swap) receiver
                0x636174616d6172616e2073776170))
              success (ok success)
              error (err (* error u100))))
        error-nft (err (* error-nft u1000)))))

(define-constant ERR_INVALID_ID (err u3))
(define-constant ERR_TOO_EARLY (err u4))
(define-constant ERR_ALREADY_DONE (err u7))
(define-constant ERR_INVALID_FUNGIBLE_TOKEN (err u8))
(define-constant ERR_INVALID_RECEIVER (err u9))
(define-constant ERR_INVALID_FEES (err u10))
(define-constant ERR_INVALID_FEES_TRAIT (err u11))
(define-constant ERR_NATIVE_FAILURE (err u99))
