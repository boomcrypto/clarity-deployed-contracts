(use-trait fungible-token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
;; The road to prosperity is often a roundabout journey, where detours and indirect routes reveal the most valuable insights and innovations.
(define-constant THIS-CONTRACT (as-contract tx-sender))

;; Define the two allowed fee contracts
(define-constant YIN-FEES .yin)
(define-constant YANG-FEES .yang)

;; the fee structure is defined by the calling client
(define-trait fees-trait
  ((get-fees (uint) (response uint uint))
  (hold-fees (uint) (response bool uint))
  (release-fees (uint) (response bool uint))
  (pay-fees (uint) (response bool uint))))

(define-map swaps uint {ustx: uint, stx-sender: principal, amount: uint, ft-sender: (optional principal), open: bool, ft: principal, fees: principal})
(define-data-var next-id uint u0)

;; read-only function to get swap details by id
(define-read-only (get-swap (id uint))
  (match (map-get? swaps id)
    swap (ok swap)
    (err ERR_INVALID_ID)))

;; helper function to transfer stx to a principal with memo
(define-private (stx-transfer-to (ustx uint) (to principal) (memo (buff 34)))
  (contract-call? 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.send-many-memo send-many
    (list {to: to,
            ustx: ustx,
            memo: memo}))) 

(define-private (is-valid-fees (fees <fees-trait>))
  (or (is-eq (contract-of fees) YIN-FEES)
      (is-eq (contract-of fees) YANG-FEES)))

;; create a swap between btc and fungible token
(define-public (offer (ustx uint) (amount uint) (ft-sender (optional principal)) (ft <fungible-token>) (fees <fees-trait>))
  (let ((id (var-get next-id)))
    (asserts! (is-valid-fees fees) ERR_INVALID_FEES)
    (asserts! (map-insert swaps id
      {ustx: ustx, stx-sender: tx-sender, amount: amount, ft-sender: ft-sender,
         open: true, ft: (contract-of ft), fees: (contract-of fees)}) ERR_INVALID_ID)
        (print 
      {
        type: "offer",
        swap_type: "STX-FT",
        contract_address: THIS-CONTRACT,
        swap-id: id, 
        creator: tx-sender,
        counterparty: ft-sender,
        open: true,
        fees: (contract-of fees),
        in_contract: "STX",
        in_amount: ustx,
        in_decimals: u6,
        out_contract: (contract-of ft), 
        out-amount: amount,
        out-decimals: (unwrap! (contract-call? ft get-decimals) ERR_FT_FAILURE),
      }
    )
    (var-set next-id (+ id u1))
    (try! (contract-call? fees hold-fees ustx))
    (match (stx-transfer-to ustx (as-contract tx-sender) 0x636174616d6172616e2073776170)
      success (ok id)
      error (err (* error u100)))))

;; only stx-sender can cancel the swap after and get the fees back
(define-public (cancel (id uint) (ft <fungible-token>) (fees <fees-trait>))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (ustx (get ustx swap)))
      (asserts! (is-eq (contract-of ft) (get ft swap)) ERR_INVALID_FUNGIBLE_TOKEN)
      (asserts! (is-eq (contract-of fees) (get fees swap)) ERR_INVALID_FEES_TRAIT)
      (asserts! (is-eq tx-sender (get stx-sender swap)) ERR_NOT_STX_SENDER)
      (asserts! (get open swap) ERR_ALREADY_DONE) 
      (asserts! (map-set swaps id (merge swap {open: false})) ERR_NATIVE_FAILURE)
      (try! (contract-call? fees release-fees ustx)) 
    (print 
      {
        type: "cancel",
        swap_type: "STX-FT",
        contract_address: THIS-CONTRACT,
        swap-id: id, 
        creator: tx-sender,
        counterparty: (get ft-sender swap),
        open: false,
        fees: (contract-of fees),
        in_contract: "STX",
        in_amount: ustx,
        in_decimals: u6,
        out_contract: (contract-of ft), 
        out-amount: (get amount swap),
        out-decimals: (unwrap! (contract-call? ft get-decimals) ERR_FT_FAILURE),
      }
    )
      (match (as-contract (stx-transfer-to
                ustx (get stx-sender swap)
                0x72657665727420636174616d6172616e2073776170))
        success (ok success)
        error (err (* error u100)))))

;; any user can submit a tx that contains the swap
(define-public (submit-swap
    (id uint)
    (ft <fungible-token>)
    (fees <fees-trait>))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (ustx (get ustx swap))
    (stx-receiver (default-to tx-sender (get ft-sender swap)))
    (ft-amount (get amount swap)))
      (asserts! (get open swap) ERR_ALREADY_DONE)
      (asserts! (is-eq (contract-of ft) (get ft swap)) ERR_INVALID_FUNGIBLE_TOKEN)
      (asserts! (is-eq (contract-of fees) (get fees swap)) ERR_INVALID_FEES_TRAIT)
      (asserts! (map-set swaps id (merge swap {open: false})) ERR_NATIVE_FAILURE)
      (asserts! (is-eq tx-sender stx-receiver) ERR_INVALID_STX_RECEIVER) ;; assert out if the receiver is predetermined 
      (try! (contract-call? fees pay-fees ustx))
      (print 
        {
            type: "swap",
            swap_type: "STX-FT",
            contract_address: THIS-CONTRACT,
            swap-id: id, 
            creator: (get stx-sender swap),
            counterparty: tx-sender,
            open: false,
            fees: (contract-of fees),
            in_contract: "STX",
            in_amount: ustx,
            in_decimals: u6,
            out_contract: (contract-of ft), 
            out-amount: ft-amount,
            out-decimals: (unwrap! (contract-call? ft get-decimals) ERR_FT_FAILURE),
        }
      )
      (match (contract-call? ft transfer
          ft-amount stx-receiver (get stx-sender swap)
          (some 0x636174616d6172616e2073776170))
        success-ft (begin
            (asserts! success-ft ERR_NATIVE_FAILURE)
            (match (as-contract (stx-transfer-to
                (get ustx swap) stx-receiver
                0x636174616d6172616e2073776170))
              success-stx (ok success-stx)
              error-stx (err (* error-stx u100))))
        error-ft (err (* error-ft u1000)))))

(define-constant ERR_INVALID_ID (err u6))
(define-constant ERR_ALREADY_DONE (err u7))
(define-constant ERR_INVALID_FUNGIBLE_TOKEN (err u8))
(define-constant ERR_INVALID_STX_RECEIVER (err u9))
(define-constant ERR_INVALID_FEES (err u10))
(define-constant ERR_INVALID_FEES_TRAIT (err u11))
(define-constant ERR_NOT_STX_SENDER (err u12))
(define-constant ERR_FT_FAILURE (err u13))
(define-constant ERR_NATIVE_FAILURE (err u99))