;; Title: aBTC-aUSD ALEX Wrapper
;; Description: Wraps ALEX AMM pool with Dexterity interface

;; Traits
(impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dexterity-traits-v0.liquidity-pool-trait)
(impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-traits-v1.sip010-ft-trait)

;; Constants
(define-constant ERR_INVALID_OPERATION (err u400))
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ALEX-FACTOR u100000000)       ;; ALEX pool factor
(define-constant AMOUNT-FACTOR (pow u10 u0))   ;; Amount scaling factor
(define-constant POOL-ID u104)                 ;; ALEX STX-CHA pool ID

(define-constant TOKEN-NAME "Shishi Guardians")
(define-constant TOKEN-SYMBOL "JADE")
(define-constant TOKEN-URI (some u"https://charisma.rocks/api/v0/metadata/SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.shishi-guardians"))

;; Opcodes
(define-constant OP_SWAP_A_TO_B 0x00)       ;; Swap token A for B
(define-constant OP_SWAP_B_TO_A 0x01)       ;; Swap token B for A
(define-constant OP_LOOKUP_RESERVES 0x04)   ;; Read pool reserves

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
    (ok TOKEN-NAME))

(define-read-only (get-symbol)
    (ok TOKEN-SYMBOL))

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
    (ok TOKEN-URI))

;; Core Functions
(define-public (execute (amount uint) (opcode (optional (buff 16))))
    (let (
        (operation (get-byte opcode u0)))
        (if (is-eq operation OP_SWAP_A_TO_B) (swap-a-to-b amount)
        (if (is-eq operation OP_SWAP_B_TO_A) (swap-b-to-a amount)
        ERR_INVALID_OPERATION))))

(define-read-only (quote (amount uint) (opcode (optional (buff 16))))
    (let (
        (operation (get-byte opcode u0)))
        (if (is-eq operation OP_SWAP_A_TO_B) (ok (get-swap-quote amount opcode))
        (if (is-eq operation OP_SWAP_B_TO_A) (ok (get-swap-quote amount opcode))
        (if (is-eq operation OP_LOOKUP_RESERVES) (ok (get-reserves-quote))
        ERR_INVALID_OPERATION)))))

;; Execute Functions
(define-private (swap-a-to-b (amount uint))
    (let (
        (sender tx-sender)
        (delta (get-swap-quote amount (some OP_SWAP_A_TO_B))))
        (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper
            'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc
            'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt
            ALEX-FACTOR
            (* amount AMOUNT-FACTOR)
            none))
        (ok delta)))

(define-private (swap-b-to-a (amount uint))
    (let (
        (sender tx-sender)
        (delta (get-swap-quote amount (some OP_SWAP_B_TO_A))))
        (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper
            'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt
            'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc
            ALEX-FACTOR
            (* amount AMOUNT-FACTOR)
            none))
        (ok delta)))

;; Helper Functions
(define-private (get-byte (opcode (optional (buff 16))) (position uint))
    (default-to 0x00 (element-at? (default-to 0x00 opcode) position)))

;; Quote Functions
(define-read-only (get-swap-quote (amount uint) (opcode (optional (buff 16))))
    (let (
        (operation (get-byte opcode u0))
        (is-a-in (is-eq operation OP_SWAP_A_TO_B))
        (alex-out (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper
            (if is-a-in 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt)
            (if is-a-in 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc)
            ALEX-FACTOR
            (* amount AMOUNT-FACTOR)))))
        {
            dx: amount,
            dy: (/ alex-out AMOUNT-FACTOR),
            dk: u0
        }))

(define-read-only (get-reserves-quote)
    (let (
        (balances (unwrap-panic (contract-call? 
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 
            get-pool-details
            'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc
            'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt
            ALEX-FACTOR))))
        {
            dx: (/ (get balance-x balances) AMOUNT-FACTOR),
            dy: (/ (get balance-y balances) AMOUNT-FACTOR),
            dk: (unwrap-panic (get-total-supply))
        }))