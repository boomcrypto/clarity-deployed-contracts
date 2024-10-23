(use-trait fungible-token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; the fee structure is defined by the calling client
(define-trait fees-trait
  ((get-fees (uint uint <fungible-token>) (response uint uint)) 
  (hold-fees (uint uint <fungible-token>) (response bool uint))
  (release-fees (uint uint <fungible-token>) (response bool uint))
  (pay-fees (uint uint <fungible-token>) (response bool uint))))

(define-constant expiry u432)
(define-data-var next-id uint u0)
(define-map swaps 
    uint 
    {
      ft-amount: uint,
      ft-sender: principal,
      ft: principal,  
      invader-id: (optional uint), 
      invader-sender: (optional principal), 
      when: uint, 
      open: bool, 
      fees: principal
    }
)

(define-private (ft-transfer-to (amount uint) (ft <fungible-token>) (to principal) (memo (buff 34)))
  (begin
    (try! (contract-call? ft transfer amount tx-sender to (some memo)))
    (ok true)))

(define-private (invader-transfer-to (invader-id-uint uint) (from principal) (to principal) (memo (buff 34)))
  (begin
    (try! (contract-call? 'SPV8C2N59MA417HYQNG6372GCV0SEQE01EV4Z1RQ.stacks-invaders-v0 transfer
      invader-id-uint from to))
    (print memo)
    (ok true)))

(define-public (offer (ft-amount uint) (ft <fungible-token>) (invader-id (optional uint)) (invader-sender (optional principal)) (fees <fees-trait>))
  (let (
        (id (var-get next-id))
        (ft-decimals (unwrap! (contract-call? ft get-decimals) ERR_FT_FAILURE))
        )
    (asserts! (map-insert swaps id
      {invader-id: invader-id, invader-sender: invader-sender, ft-amount: ft-amount, ft-sender: tx-sender,
         when: block-height, open: true, ft: (contract-of ft), fees: (contract-of fees)}) ERR_INVALID_ID)
    (print 
      {
        type: "offer",
        ft-amount: ft-amount,
        ft: (contract-of ft), 
        ft-decimals: ft-decimals,
        invader-id: invader-id,
        swap-id: id, 
        expiration: (+ block-height expiry), 
      }
    )
    (var-set next-id (+ id u1))
    (try! (contract-call? fees hold-fees ft-amount ft-decimals ft))
    (try! (contract-call? .neon-inv mint-light id invader-id)) 
    (match (ft-transfer-to ft-amount ft (as-contract tx-sender) 0x636174616d6172616e2073776170)
      success (ok id)
      error (err (* error u100)))))

(define-public (cancel (id uint) (ft <fungible-token>) (fees <fees-trait>))
  (let (
        (swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
        (ft-amount (get ft-amount swap))
        (ft-decimals (unwrap! (contract-call? ft get-decimals) ERR_FT_FAILURE))
        )
      (asserts! (is-eq (contract-of ft) (get ft swap)) ERR_INVALID_FUNGIBLE_TOKEN)
      (asserts! (is-eq (contract-of fees) (get fees swap)) ERR_INVALID_FEES_TRAIT)
      (asserts! (< (+ (get when swap) expiry) block-height) ERR_TOO_EARLY)
      (asserts! (get open swap) ERR_ALREADY_DONE)
      (asserts! (map-set swaps id (merge swap {open: false})) ERR_NATIVE_FAILURE)
      (try! (contract-call? .neon-inv blow-light id))
      (try! (contract-call? fees release-fees ft-amount ft-decimals ft))
      (print 
        {
          type: "cancel",
          ft-amount: ft-amount,
          ft: (contract-of ft), 
          ft-decimals: (unwrap! (contract-call? ft get-decimals) ERR_FT_FAILURE),
          swap-id: id,
        }
      )
      (match (as-contract (ft-transfer-to 
                ft-amount ft (get ft-sender swap)
                0x72657665727420636174616d6172616e2073776170))
        success (ok success)
        error (err (* error u100)))))

(define-public (revoke (id uint) (ft <fungible-token>) (fees <fees-trait>))
  (let (
        (swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
        (ft-amount (get ft-amount swap))
        (ft-decimals (unwrap! (contract-call? ft get-decimals) ERR_FT_FAILURE))
        )
      (asserts! (is-eq (contract-of ft) (get ft swap)) ERR_INVALID_FUNGIBLE_TOKEN)
      (asserts! (is-eq (contract-of fees) (get fees swap)) ERR_INVALID_FEES_TRAIT)
      (asserts! (is-eq tx-sender (get ft-sender swap)) ERR_INVALID_SENDER)
      (asserts! (get open swap) ERR_ALREADY_DONE)
      (asserts! (map-set swaps id (merge swap {open: false})) ERR_NATIVE_FAILURE)
      (try! (contract-call? .neon-inv blow-light id))
      (try! (contract-call? fees release-fees ft-amount ft-decimals ft))
      (print 
        {
          type: "revoke",
          ft-amount: ft-amount,
          ft: (contract-of ft), 
          ft-decimals: (unwrap! (contract-call? ft get-decimals) ERR_FT_FAILURE),
          swap-id: id, 
        }
      )
      (match (as-contract (ft-transfer-to 
                ft-amount ft (get ft-sender swap)
                0x72657665727420636174616d6172616e2073776170))
        success (ok success)
        error (err (* error u100)))))

(define-public (swap-invader
    (id uint)
    (invader-id-uint uint)
    (ft <fungible-token>)
    (fees <fees-trait>))
  (let (
    (swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (ft-receiver (default-to tx-sender (get invader-sender swap)))
    (invader-uint (default-to invader-id-uint (get invader-id swap)))
    (ft-amount (get ft-amount swap))
    (ft-decimals (unwrap! (contract-call? ft get-decimals) ERR_FT_FAILURE))
    )
      (asserts! (get open swap) ERR_ALREADY_DONE)
      (asserts! (is-eq (contract-of ft) (get ft swap)) ERR_INVALID_FUNGIBLE_TOKEN)
      (asserts! (is-eq (contract-of fees) (get fees swap)) ERR_INVALID_FEES_TRAIT)
      (asserts! (is-eq invader-uint invader-id-uint) ERR_INVALID_INVADER_ID)
      (asserts! (map-set swaps id (merge swap {open: false, invader-id: (some invader-uint), invader-sender: (some tx-sender)})) ERR_NATIVE_FAILURE)
      (try! (contract-call? .neon-inv blow-light id))
      (try! (contract-call? fees pay-fees ft-amount ft-decimals ft))
        (print 
        {
            type: "swap",
            ft-amount: ft-amount,
            ft: (contract-of ft), 
            ft-decimals: (unwrap! (contract-call? ft get-decimals) ERR_FT_FAILURE),
            invader-id: (some invader-uint),
            swap-id: id, 
        }
        )
      (match (invader-transfer-to invader-id-uint ft-receiver (get ft-sender swap) 0x636174616d6172616e2073776170)
        success-invader (begin
            (asserts! success-invader ERR_NATIVE_FAILURE)
            (match (as-contract (ft-transfer-to ft-amount ft
                ft-receiver 0x636174616d6172616e2073776170))
              success-ft (ok success-ft)
              error-ft (err (* error-ft u100))))
        error-invader (err (* error-invader u1000)))))

(define-read-only (get-swap (id uint))
  (match (map-get? swaps id)
    swap (ok swap)
    (err ERR_INVALID_ID)))

(define-constant ERR_INVALID_ID (err u3))
(define-constant ERR_TOO_EARLY (err u4))
(define-constant ERR_ALREADY_DONE (err u7))
(define-constant ERR_INVALID_FUNGIBLE_TOKEN (err u8))
(define-constant ERR_INVALID_RECEIVER (err u9))
(define-constant ERR_INVALID_FEES_TRAIT (err u11))
(define-constant ERR_NATIVE_FAILURE (err u99))
(define-constant ERR_INVALID_SENDER (err u12))
(define-constant ERR_FT_FAILURE (err u13))
(define-constant ERR_INVALID_INVADER_ID (err u14))
(define-constant ERR_OWNERS_FETCH_FAILED (err u15))