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

(define-map swaps uint {amount: uint, ft-sender: principal, ustx: uint, stx-sender: (optional principal), open: bool, ft: principal, fees: principal})
(define-data-var next-id uint u0)

;; read-only function to get swap details by id
(define-read-only (get-swap (id uint))
  (match (map-get? swaps id)
    swap (ok swap)
    (err ERR_INVALID_ID)))

(define-private (ft-transfer-to (amount uint) (ft <fungible-token>) (to principal) (memo (buff 34)))
  (begin
    (try! (contract-call? ft transfer amount tx-sender to (some memo)))
    (ok true)))

(define-private (stx-transfer-to (ustx uint) (to principal) (memo (buff 34)))
  (contract-call? 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.send-many-memo send-many
    (list {to: to,
            ustx: ustx,
            memo: memo})))

(define-private (is-valid-fees (fees <fees-trait>))
  (or (is-eq (contract-of fees) YIN-FEES)
      (is-eq (contract-of fees) YANG-FEES)))

(define-public (offer (amount uint) (ustx uint) (stx-sender (optional principal)) (ft <fungible-token>) (fees <fees-trait>))
  (let ((id (var-get next-id)))
    (asserts! (is-valid-fees fees) ERR_INVALID_FEES)
    (asserts! (map-insert swaps id
      {amount: amount, ft-sender: tx-sender, ustx: ustx, stx-sender: stx-sender,
         open: true, ft: (contract-of ft), fees: (contract-of fees)}) ERR_INVALID_ID)
        (print 
      {
        type: "offer",
        swap_type: "FT-STX",
        contract_address: THIS-CONTRACT,
        swap-id: id, 
        creator: tx-sender,
        counterparty: stx-sender,
        open: true,
        fees: (contract-of fees),
        in_contract: (contract-of ft),
        in_amount: amount,
        in_decimals: (unwrap! (contract-call? ft get-decimals) ERR_FT_FAILURE),
        out_contract: "STX", 
        out-amount: ustx,
        out-decimals: u6,
      }
    )
    (var-set next-id (+ id u1))
    (try! (contract-call? fees hold-fees ustx))
    (match (ft-transfer-to amount ft (as-contract tx-sender) 0x636174616d6172616e2073776170)
      success (ok id)
      error (err (* error u100)))))

;; only ft-sender can cancel the swap and get the fees back
(define-public (cancel (id uint) (ft <fungible-token>) (fees <fees-trait>))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (amount (get amount swap))
    (ustx (get ustx swap)))
      (asserts! (is-eq (contract-of ft) (get ft swap)) ERR_INVALID_FUNGIBLE_TOKEN)
      (asserts! (is-eq (contract-of fees) (get fees swap)) ERR_INVALID_FEES_TRAIT)
      (asserts! (is-eq tx-sender (get ft-sender swap)) ERR_NOT_FT_SENDER)
      (asserts! (get open swap) ERR_ALREADY_DONE) 
      (asserts! (map-set swaps id (merge swap {open: false})) ERR_NATIVE_FAILURE)
      (try! (contract-call? fees release-fees ustx)) 
    (print 
      {
        type: "cancel",
        swap_type: "FT-STX",
        contract_address: THIS-CONTRACT,
        swap-id: id, 
        creator: tx-sender,
        counterparty: (get stx-sender swap),
        open: false,
        fees: (contract-of fees),
        in_contract: (contract-of ft),
        in_amount: amount,
        in_decimals: (unwrap! (contract-call? ft get-decimals) ERR_FT_FAILURE),
        out_contract: "STX",
        out-amount: ustx,
        out-decimals: u6
      }
    )
    (match (as-contract (ft-transfer-to 
                amount ft (get ft-sender swap)
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
    (ft-receiver (default-to tx-sender (get stx-sender swap)))
    (amount (get amount swap)))
      (asserts! (get open swap) ERR_ALREADY_DONE)
      (asserts! (is-eq (contract-of ft) (get ft swap)) ERR_INVALID_FUNGIBLE_TOKEN)
      (asserts! (is-eq (contract-of fees) (get fees swap)) ERR_INVALID_FEES_TRAIT)
      (asserts! (map-set swaps id (merge swap {open: false})) ERR_NATIVE_FAILURE)
      (asserts! (is-eq tx-sender ft-receiver) ERR_INVALID_FT_RECEIVER) ;; ft-receiver is tx-sender  / assert out if the receiver is predetermined 
      (try! (contract-call? fees pay-fees ustx))
      (print 
        {
            type: "swap",
            swap_type: "FT-STX",
            contract_address: THIS-CONTRACT,
            swap-id: id, 
            creator: (get ft-sender swap),
            counterparty: tx-sender,
            open: false,
            fees: (contract-of fees),
            in_contract: (contract-of ft),
            in_amount: amount,
            in_decimals: (unwrap! (contract-call? ft get-decimals) ERR_FT_FAILURE),
            out_contract: "STX",
            out-amount: ustx,
            out-decimals: u6,
        }
      )
      (match (stx-transfer-to ustx (get ft-sender swap) 0x636174616d6172616e2073776170)
        success-stx (begin
            (asserts! success-stx ERR_NATIVE_FAILURE)
            (match (as-contract (ft-transfer-to amount ft
                ft-receiver 0x636174616d6172616e2073776170))
              success-ft (ok success-ft)
              error-ft (err (* error-ft u100))))
        error-stx (err (* error-stx u1000)))))

(define-constant ERR_INVALID_ID (err u6))
(define-constant ERR_ALREADY_DONE (err u7))
(define-constant ERR_INVALID_FUNGIBLE_TOKEN (err u8))
(define-constant ERR_INVALID_FT_RECEIVER (err u9))
(define-constant ERR_INVALID_FEES (err u10))
(define-constant ERR_INVALID_FEES_TRAIT (err u11))
(define-constant ERR_NOT_FT_SENDER (err u12))
(define-constant ERR_FT_FAILURE (err u13))
(define-constant ERR_NATIVE_FAILURE (err u99))
;; (err u1) -- sender does not have enough balance to transfer 
;; (err u2) -- sender and recipient are the same principal 
;; (err u3) -- amount to send is non-positive