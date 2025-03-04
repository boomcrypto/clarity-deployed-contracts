;; Title: STX-CHA ALEX Wrapper
;; Description: Wraps ALEX AMM pool with Dexterity interface

;; Traits
(impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-traits-v1.sip010-ft-trait)

;; Constants
(define-constant ERR_INVALID_OPERATION (err u400))
(define-constant ERR_UNAUTHORIZED (err u403))

;; Pool Configuration
(define-constant ALEX-FACTOR (pow u10 u8))      ;; ALEX pool factor
(define-constant AMOUNT-FACTOR (pow u10 u2))    ;; Amount scaling factor

;; Opcodes
(define-constant OP_SWAP_A_TO_B 0x00)      ;; Swap token A for B
(define-constant OP_SWAP_B_TO_A 0x01)      ;; Swap token B for A
(define-constant OP_LOOKUP_RESERVES 0x04)   ;; Read pool reserves

;; Pool ID
(define-constant POOL-ID u109)

;; SIP-010 Functions
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq tx-sender sender) ERR_UNAUTHORIZED)
        (contract-call? 
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 
            transfer-fixed 
            POOL-ID 
            amount 
            sender 
            recipient)))

(define-read-only (get-name)
    (contract-call? 
        'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 
        get-name 
        POOL-ID))

(define-read-only (get-symbol)
    (contract-call? 
        'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 
        get-symbol 
        POOL-ID))

(define-read-only (get-decimals)
    (contract-call? 
        'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 
        get-decimals 
        POOL-ID))

(define-read-only (get-balance (who principal))
    (contract-call? 
        'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 
        get-balance-fixed 
        POOL-ID 
        who))

(define-read-only (get-total-supply)
    (contract-call? 
        'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 
        get-total-supply-fixed 
        POOL-ID))

(define-read-only (get-token-uri)
    (contract-call? 
        'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 
        get-token-uri 
        POOL-ID))