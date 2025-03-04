;; Title: sBTC-STX DEX Wrapper
;; Description: Wraps XYK DEX with Dexterity interface

;; Traits
(impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dexterity-traits-v0.liquidity-pool-trait)
(impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-traits-v1.sip010-ft-trait)

;; Constants
(define-constant ERR_INVALID_OPERATION (err u400))
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant BPS u10000)

(define-constant TOKEN-NAME "Nakamoto Flow")
(define-constant TOKEN-SYMBOL "NKMF")
(define-constant TOKEN-URI (some u"https://charisma.rocks/api/v0/metadata/SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.nakamoto-flow"))

;; Opcodes
(define-constant OP_SWAP_A_TO_B 0x00)       ;; Swap token A for B
(define-constant OP_SWAP_B_TO_A 0x01)       ;; Swap token B for A
(define-constant OP_LOOKUP_RESERVES 0x04)   ;; Read pool reserves

;; SIP-010 Functions
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq tx-sender sender) ERR_UNAUTHORIZED)
        (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1 
            transfer amount sender recipient memo)))

(define-read-only (get-name)
    (ok TOKEN-NAME))

(define-read-only (get-symbol)
    (ok TOKEN-SYMBOL))

(define-read-only (get-decimals)
    (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1 get-decimals))

(define-read-only (get-balance (who principal))
    (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1 get-balance who))

(define-read-only (get-total-supply)
    (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1 get-total-supply))

(define-read-only (get-token-uri)
    (ok TOKEN-URI))

;; Core Functions
(define-public (execute (amount uint) (opcode (optional (buff 16))))
    (let (
        (operation (get-byte opcode u0)))
        (if (is-eq operation OP_SWAP_A_TO_B) (ok (swap-a-to-b amount))
        (if (is-eq operation OP_SWAP_B_TO_A) (ok (swap-b-to-a amount))
        ERR_INVALID_OPERATION))))

(define-read-only (quote (amount uint) (opcode (optional (buff 16))))
    (let (
        (operation (get-byte opcode u0)))
        (if (is-eq operation OP_SWAP_A_TO_B) (ok (get-quote amount opcode))
        (if (is-eq operation OP_SWAP_B_TO_A) (ok (get-quote amount opcode))
        (if (is-eq operation OP_LOOKUP_RESERVES) (ok (get-reserves))
        ERR_INVALID_OPERATION)))))

;; Helper Functions
(define-private (swap-a-to-b (amount uint))
    (let (
        (dy (unwrap-panic (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 swap-x-for-y 
            'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1
            'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
            'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
            amount 
            u1))))
        {
            dx: amount,
            dy: dy,
            dk: u0
        }))

(define-private (swap-b-to-a (amount uint))
    (let (
        (dy (unwrap-panic (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 swap-y-for-x
            'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1
            'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
            'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
            amount 
            u1))))
        {
            dx: amount,
            dy: dy,
            dk: u0
        }))

(define-private (get-byte (opcode (optional (buff 16))) (position uint))
    (default-to 0x00 (element-at? (default-to 0x00 opcode) position)))

(define-private (get-pool)
    (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1 get-pool))

(define-read-only (quote-a-to-b (x-amount uint))
    (let (
        (pool (unwrap-panic (get-pool)))
        (x-protocol-fee (get x-protocol-fee pool))
        (x-provider-fee (get x-provider-fee pool))
        (x-balance (get x-balance pool))
        (y-balance (get y-balance pool))
        (x-amount-fees-protocol (/ (* x-amount x-protocol-fee) BPS))
        (x-amount-fees-provider (/ (* x-amount x-provider-fee) BPS))
        (x-amount-fees-total (+ x-amount-fees-protocol x-amount-fees-provider))
        (dx (- x-amount x-amount-fees-total))
        (updated-x-balance (+ x-balance dx)))
        (/ (* y-balance dx) updated-x-balance)))

(define-read-only (quote-b-to-a (y-amount uint))
    (let (
        (pool (unwrap-panic (get-pool)))
        (y-protocol-fee (get y-protocol-fee pool))
        (y-provider-fee (get y-provider-fee pool))
        (x-balance (get x-balance pool))
        (y-balance (get y-balance pool))
        (y-amount-fees-protocol (/ (* y-amount y-protocol-fee) BPS))
        (y-amount-fees-provider (/ (* y-amount y-provider-fee) BPS))
        (y-amount-fees-total (+ y-amount-fees-protocol y-amount-fees-provider))
        (dy (- y-amount y-amount-fees-total))
        (updated-y-balance (+ y-balance dy)))
        (/ (* x-balance dy) updated-y-balance)))

(define-private (get-quote (amount uint) (opcode (optional (buff 16))))
    (let (
        (operation (get-byte opcode u0))
        (amt-out (if (is-eq operation OP_SWAP_A_TO_B)
            (quote-a-to-b amount)
            (quote-b-to-a amount))))
        {
            dx: amount,
            dy: amt-out,
            dk: u0
        }))

(define-read-only (get-reserves)
    (let (
        (pool (unwrap-panic (get-pool))))
        {
            dx: (get x-balance pool),
            dy: (get y-balance pool),
            dk: (get total-shares pool)
        }))