;; Title: STX-stSTX DEX Wrapper
;; Description: Wraps XYK DEX with Dexterity interface

;; Traits
;; (impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dexterity-traits-v0.liquidity-pool-trait)
(impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-traits-v1.sip010-ft-trait)

;; Constants
(define-constant ERR_INVALID_OPERATION (err u400))
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant BPS u10000)

(define-constant TOKEN-NAME "The Tesseract")
(define-constant TOKEN-SYMBOL "TSRT")
(define-constant TOKEN-URI (some u"https://charisma.rocks/api/v0/metadata/SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.the-tesseract"))

;; Opcodes
(define-constant OP_SWAP_A_TO_B 0x00)       ;; Swap token A for B
(define-constant OP_SWAP_B_TO_A 0x01)       ;; Swap token B for A
(define-constant OP_LOOKUP_RESERVES 0x04)   ;; Read pool reserves

;; SIP-010 Functions
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq tx-sender sender) ERR_UNAUTHORIZED)
        (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
            transfer amount sender recipient memo)))

(define-read-only (get-name)
    (ok TOKEN-NAME))

(define-read-only (get-symbol)
    (ok TOKEN-SYMBOL))

(define-read-only (get-decimals)
    (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2 get-decimals))

(define-read-only (get-balance (who principal))
    (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2 get-balance who))

(define-read-only (get-total-supply)
    (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2 get-total-supply))

(define-read-only (get-token-uri)
    (ok TOKEN-URI))

;; Core Functions
;; (define-public (execute (amount uint) (opcode (optional (buff 16))))
;;     (let (
;;         (operation (get-byte opcode u0)))
;;         (if (is-eq operation OP_SWAP_A_TO_B) (ok (swap-a-to-b amount))
;;         (if (is-eq operation OP_SWAP_B_TO_A) (ok (swap-b-to-a amount))
;;         ERR_INVALID_OPERATION))))

;; (define-read-only (quote (amount uint) (opcode (optional (buff 16))))
;;     (let (
;;         (operation (get-byte opcode u0)))
;;         (if (is-eq operation OP_SWAP_A_TO_B) (ok (get-quote amount opcode))
;;         (if (is-eq operation OP_SWAP_B_TO_A) (ok (get-quote amount opcode))
;;         (if (is-eq operation OP_LOOKUP_RESERVES) (ok (get-reserves))
;;         ERR_INVALID_OPERATION)))))

;; Helper Functions
(define-private (swap-a-to-b (amount uint))
    (let (
        (dy (unwrap-panic (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 swap-x-for-y 
            'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
            'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
            amount 
            u1))))
        {
            dx: amount,
            dy: dy,
            dk: u0
        }))

(define-private (swap-b-to-a (amount uint))
    (let (
        (dy (unwrap-panic (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 swap-y-for-x
            'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
            'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
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
    (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 get-pair-data
        'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
        'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2))

(define-read-only (quote-a-to-b (x-amount uint))
    (unwrap-panic (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 get-dy
        'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
        'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
        x-amount)))

(define-read-only (quote-b-to-a (y-amount uint))
    (unwrap-panic (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 get-dx
        'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
        'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
        y-amount)))

;; (define-private (get-quote (amount uint) (opcode (optional (buff 16))))
;;     (let (
;;         (operation (get-byte opcode u0))
;;         (amt-out (if (is-eq operation OP_SWAP_A_TO_B)
;;             (quote-a-to-b amount)
;;             (quote-b-to-a amount))))
;;         {
;;             dx: amount,
;;             dy: amt-out,
;;             dk: u0
;;         }))

(define-read-only (get-reserves)
    (let (
        (pool (unwrap-panic (get-pool))))
        {
            dx: (get balance-x pool),
            dy: (get balance-y pool),
            dk: (get total-shares pool)
        }))