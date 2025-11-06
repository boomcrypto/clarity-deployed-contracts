;; FillGate - Simplified MVP for Stacks

;; ===========================================
;; Traits (for external contract calls)
;; ===========================================

;; SIP-010 Fungible Token Trait (for sBTC, etc)
(define-trait sip-010-trait
  (
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))
  )
)

;; ===========================================
;; Constants
;; ===========================================

(define-constant CONTRACT-OWNER tx-sender)

;; Status constants (using uint for simplicity)
(define-constant STATUS-UNKNOWN u0)
(define-constant STATUS-FILLED u1)

;; Grace period (5 minutes = 50 blocks, assuming ~6 sec blocks on Stacks)
(define-constant FILL-GRACE-PERIOD u50)

;; Error codes
(define-constant ERR-ORDER-ALREADY-FILLED (err u100))
(define-constant ERR-DEADLINE-EXCEEDED (err u101))
(define-constant ERR-INCORRECT-AMOUNT (err u102))
(define-constant ERR-TRANSFER-FAILED (err u103))
(define-constant ERR-INVALID-TOKEN (err u104))

;; ===========================================
;; Data Maps
;; ===========================================

;; Track order status: orderId => status
(define-map order-status uint uint)

;; Track source chain: orderId => chainId
(define-map order-source-chain uint uint)

;; ===========================================
;; Read-Only Functions
;; ===========================================

(define-read-only (get-order-status (order-id uint))
  (default-to STATUS-UNKNOWN (map-get? order-status order-id))
)

(define-read-only (get-order-source-chain (order-id uint))
  (map-get? order-source-chain order-id)
)

;; ===========================================
;; Public Functions
;; ===========================================

(define-public (fill-native
    (order-id uint)
    (amount-out uint)
    (recipient principal)
    (solver-origin-address (string-ascii 42))
    (fill-deadline uint)
    (source-chain-id uint))
  (let (
    (current-status (get-order-status order-id))
  )
    ;; Validation 1: Order not filled yet
    (asserts! (is-eq current-status STATUS-UNKNOWN) ERR-ORDER-ALREADY-FILLED)
    
    ;; Validation 2: Deadline check with grace period
    (asserts! (<= block-height (+ fill-deadline FILL-GRACE-PERIOD)) ERR-DEADLINE-EXCEEDED)
    
    ;; Update state BEFORE transfer (CEI pattern)
    (map-set order-status order-id STATUS-FILLED)
    (map-set order-source-chain order-id source-chain-id)
    
    ;; Transfer STX to recipient
    (try! (stx-transfer? amount-out tx-sender recipient))
    
    ;; Emit event via print
    (print {
      event: "order-filled",
      order-id: order-id,
      solver: tx-sender,
      token-out: "native",
      amount-out: amount-out,
      recipient: recipient,
      solver-origin-address: solver-origin-address,
      fill-deadline: fill-deadline,
      source-chain-id: source-chain-id
    })
    
    (ok true)
  )
)

(define-public (fill-token
    (order-id uint)
    (token-out <sip-010-trait>)
    (amount-out uint)
    (recipient principal)
    (solver-origin-address (string-ascii 42))
    (fill-deadline uint)
    (source-chain-id uint))
  (let (
    (current-status (get-order-status order-id))
  )
    ;; Validation 1: Order not filled yet
    (asserts! (is-eq current-status STATUS-UNKNOWN) ERR-ORDER-ALREADY-FILLED)
    
    ;; Validation 2: Deadline check with grace period
    (asserts! (<= block-height (+ fill-deadline FILL-GRACE-PERIOD)) ERR-DEADLINE-EXCEEDED)
    
    ;; Update state BEFORE transfer (CEI pattern)
    (map-set order-status order-id STATUS-FILLED)
    (map-set order-source-chain order-id source-chain-id)
    
    ;; Transfer SIP-010 token (sBTC, etc) to recipient
    ;; Note: Solver must have already approved this contract
    (try! (contract-call? token-out transfer amount-out tx-sender recipient none))
    
    ;; Emit event
    (print {
      event: "order-filled",
      order-id: order-id,
      solver: tx-sender,
      token-out: token-out,
      amount-out: amount-out,
      recipient: recipient,
      solver-origin-address: solver-origin-address,
      fill-deadline: fill-deadline,
      source-chain-id: source-chain-id
    })
    
    (ok true)
  )
)
