---
title: "Trait theyre-taking-our-jerbs"
draft: true
---
```
;; Title: STX-sAI DEX Wrapper
;; Description: Wraps UniV2-style DEX with Dexterity interface

;; Traits
(impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dexterity-traits-v0.liquidity-pool-trait)
(impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-traits-v1.sip010-ft-trait)

;; Constants
(define-constant ERR_INVALID_OPERATION (err u400))
(define-constant ERR_UNAUTHORIZED (err u403))

(define-constant TOKEN-NAME "They're Taking Our Jerbs")
(define-constant TOKEN-SYMBOL "JERBS")
(define-constant TOKEN-URI (some u"https://charisma.rocks/api/v0/metadata/SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.theyre-taking-our-jerbs"))

;; Opcodes
(define-constant OP_SWAP_A_TO_B 0x00)       ;; Swap token A for B
(define-constant OP_SWAP_B_TO_A 0x01)       ;; Swap token B for A
(define-constant OP_LOOKUP_RESERVES 0x04)   ;; Read pool reserves

;; SIP-010 Functions
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq tx-sender sender) ERR_UNAUTHORIZED)
        (contract-call? 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-lp-token-v1_0_0-0049 
            transfer amount sender recipient memo)))

(define-read-only (get-name)
    (ok TOKEN-NAME))

(define-read-only (get-symbol)
    (ok TOKEN-SYMBOL))

(define-read-only (get-decimals)
    (contract-call? 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-lp-token-v1_0_0-0049 get-decimals))

(define-read-only (get-balance (who principal))
    (contract-call? 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-lp-token-v1_0_0-0049 get-balance who))

(define-read-only (get-total-supply)
    (contract-call? 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-lp-token-v1_0_0-0049 get-total-supply))

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
        (res (unwrap-panic (contract-call? 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-pool-v1_0_0-0049 swap
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
            'SP3M31QFF6S96215K4Y2Z9K5SGHJN384NV6YM6VM8.satoshai
            'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-fees-v1_0_0-0049
            amount
            u1))))
        (ok {
          dx: amount,
          dy: (get amt-out res),
          dk: u0
        })))

(define-private (swap-b-to-a (amount uint))
    (let (
        (res (unwrap-panic (contract-call? 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-pool-v1_0_0-0049 swap
            'SP3M31QFF6S96215K4Y2Z9K5SGHJN384NV6YM6VM8.satoshai
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
            'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-fees-v1_0_0-0049
            amount
            u1))))
        (ok {
          dx: amount,
          dy: (get amt-out res),
          dk: u0
        })))

;; Helper Functions
(define-private (quote-a-to-b (amount uint))
    (unwrap-panic (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-math find-dx
        (get dx (get-reserves-quote))
        (get dy (get-reserves-quote))
        amount)))

(define-private (quote-b-to-a (amount uint))
    (unwrap-panic (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-math find-dx
        (get dy (get-reserves-quote))
        (get dx (get-reserves-quote))
        amount)))

(define-private (get-byte (opcode (optional (buff 16))) (position uint))
    (default-to 0x00 (element-at? (default-to 0x00 opcode) position)))

;; Quote Functions
(define-read-only (get-swap-quote (amount uint) (opcode (optional (buff 16))))
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

(define-read-only (get-reserves-quote)
    (let (
        (pool (contract-call? 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-pool-v1_0_0-0049 do-get-pool)))
        {
            dx: (get reserve0 pool),
            dy: (get reserve1 pool),
            dk: (unwrap-panic (get-total-supply))
        }))
```
