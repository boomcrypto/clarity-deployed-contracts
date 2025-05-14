---
title: "Trait hannaobt-lp-token"
draft: true
---
```
;; Title: Hanna-OBT LP Token
;; Version: 1.0.0
;; Description: 
;;   Implementation of the standard trait interface for liquidity pools on the Stacks blockchain.
;;   Provides automated market making functionality between two SIP-010 compliant tokens.
;;   Implements SIP-010 fungible token standard for LP token compatibility.

;; Traits
(impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-traits-v1.sip010-ft-trait)
(impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dexterity-traits-v0.liquidity-pool-trait)

;; Constants
(define-constant DEPLOYER tx-sender)
(define-constant CONTRACT (as-contract tx-sender))
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_INVALID_OPERATION (err u400))
(define-constant PRECISION u1000000)
(define-constant LP_REBATE u24200)

;; Opcodes
(define-constant OP_SWAP_A_TO_B 0x00)      ;; Swap token A for B
(define-constant OP_SWAP_B_TO_A 0x01)      ;; Swap token B for A
(define-constant OP_ADD_LIQUIDITY 0x02)    ;; Add liquidity
(define-constant OP_REMOVE_LIQUIDITY 0x03) ;; Remove liquidity
(define-constant OP_LOOKUP_RESERVES 0x04)  ;; Read pool reserves

;; Define LP token
(define-fungible-token Hanna-OBT)
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://charisma.rocks/api/v0/metadata/SP16YY4E2FK8PRZS1S9W2BPF8J2T8D4V61EB6TWNT.hannaobt-lp-token"))

;; --- SIP10 Functions ---

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq tx-sender sender) ERR_UNAUTHORIZED)
        (try! (ft-transfer? Hanna-OBT amount sender recipient))
        (match memo to-print (print to-print) 0x0000)
        (ok true)))

(define-read-only (get-name)
    (ok "Hanna-OBT LP Token"))

(define-read-only (get-symbol)
    (ok "Hanna-OBT"))

(define-read-only (get-decimals)
    (ok u6))

(define-read-only (get-balance (who principal))
    (ok (ft-get-balance Hanna-OBT who)))

(define-read-only (get-total-supply)
    (ok (ft-get-supply Hanna-OBT)))

(define-read-only (get-token-uri)
    (ok (var-get token-uri)))

(define-public (set-token-uri (uri (string-utf8 256)))
    (if (is-eq contract-caller DEPLOYER)
        (ok (var-set token-uri (some uri))) 
        ERR_UNAUTHORIZED))

;; --- Core Functions ---

(define-public (execute (amount uint) (opcode (optional (buff 16))))
    (let (
        (sender tx-sender)
        (operation (get-byte opcode u0)))
        (if (is-eq operation OP_SWAP_A_TO_B) (swap-a-to-b amount)
        (if (is-eq operation OP_SWAP_B_TO_A) (swap-b-to-a amount)
        (if (is-eq operation OP_ADD_LIQUIDITY) (add-liquidity amount)
        (if (is-eq operation OP_REMOVE_LIQUIDITY) (remove-liquidity amount)
        ERR_INVALID_OPERATION))))))

(define-read-only (quote (amount uint) (opcode (optional (buff 16))))
    (let (
        (operation (get-byte opcode u0)))
        (if (is-eq operation OP_SWAP_A_TO_B) (ok (get-swap-quote amount opcode))
        (if (is-eq operation OP_SWAP_B_TO_A) (ok (get-swap-quote amount opcode))
        (if (is-eq operation OP_ADD_LIQUIDITY) (ok (get-liquidity-quote amount))
        (if (is-eq operation OP_REMOVE_LIQUIDITY) (ok (get-liquidity-quote amount))
        (if (is-eq operation OP_LOOKUP_RESERVES) (ok (get-reserves-quote))
        ERR_INVALID_OPERATION)))))))

;; --- Execute Functions ---

(define-public (swap-a-to-b (amount uint))
    (let (
        (sender tx-sender)
        (delta (get-swap-quote amount (some OP_SWAP_A_TO_B))))
        ;; Transfer token A to pool
        (try! (contract-call? 'SP16YY4E2FK8PRZS1S9W2BPF8J2T8D4V61EB6TWNT.hanna-labs transfer amount sender CONTRACT none))
        ;; Transfer token B to sender
        (try! (as-contract (contract-call? 'SP3BJ0KSAF04HGFSBKHW4TMJ5MGAAADAHDFPPHF8M.orbit-ai-stxcity transfer (get dy delta) CONTRACT sender none)))
        (ok delta)))

(define-public (swap-b-to-a (amount uint))
    (let (
        (sender tx-sender)
        (delta (get-swap-quote amount (some OP_SWAP_B_TO_A))))
        ;; Transfer token B to pool
        (try! (contract-call? 'SP3BJ0KSAF04HGFSBKHW4TMJ5MGAAADAHDFPPHF8M.orbit-ai-stxcity transfer amount sender CONTRACT none))
        ;; Transfer token A to sender
        (try! (as-contract (contract-call? 'SP16YY4E2FK8PRZS1S9W2BPF8J2T8D4V61EB6TWNT.hanna-labs transfer (get dy delta) CONTRACT sender none)))
        (ok delta)))

(define-public (add-liquidity (amount uint))
    (let (
        (sender tx-sender)
        (delta (get-liquidity-quote amount)))
        (try! (contract-call? 'SP16YY4E2FK8PRZS1S9W2BPF8J2T8D4V61EB6TWNT.hanna-labs transfer (get dx delta) sender CONTRACT none))
        (try! (contract-call? 'SP3BJ0KSAF04HGFSBKHW4TMJ5MGAAADAHDFPPHF8M.orbit-ai-stxcity transfer (get dy delta) sender CONTRACT none))
        (try! (ft-mint? Hanna-OBT (get dk delta) sender))
        (ok delta)))

(define-public (remove-liquidity (amount uint))
    (let (
        (sender tx-sender)
        (delta (get-liquidity-quote amount)))
        (try! (ft-burn? Hanna-OBT (get dk delta) sender))
        (try! (as-contract (contract-call? 'SP16YY4E2FK8PRZS1S9W2BPF8J2T8D4V61EB6TWNT.hanna-labs transfer (get dx delta) CONTRACT sender none)))
        (try! (as-contract (contract-call? 'SP3BJ0KSAF04HGFSBKHW4TMJ5MGAAADAHDFPPHF8M.orbit-ai-stxcity transfer (get dy delta) CONTRACT sender none)))
        (ok delta)))

;; --- Helper Functions ---

(define-private (get-byte (opcode (optional (buff 16))) (position uint))
    (default-to 0x00 (element-at? (default-to 0x00 opcode) position)))

(define-private (get-reserves)
    { 
      a: (unwrap-panic (contract-call? 'SP16YY4E2FK8PRZS1S9W2BPF8J2T8D4V61EB6TWNT.hanna-labs get-balance CONTRACT)), 
      b: (unwrap-panic (contract-call? 'SP3BJ0KSAF04HGFSBKHW4TMJ5MGAAADAHDFPPHF8M.orbit-ai-stxcity get-balance CONTRACT))
    })

;; --- Quote Functions ---

(define-read-only (get-swap-quote (amount uint) (opcode (optional (buff 16))))
    (let (
        (reserves (get-reserves))
        (operation (get-byte opcode u0))
        (is-a-in (is-eq operation OP_SWAP_A_TO_B))
        (x (if is-a-in (get a reserves) (get b reserves)))
        (y (if is-a-in (get b reserves) (get a reserves)))
        (dx (/ (* amount (- PRECISION LP_REBATE)) PRECISION))
        (numerator (* dx y))
        (denominator (+ x dx))
        (dy (/ numerator denominator)))
        {
          dx: dx,
          dy: dy,
          dk: u0
        }))

(define-read-only (get-liquidity-quote (amount uint))
    (let (
        (k (ft-get-supply Hanna-OBT))
        (reserves (get-reserves)))
        {
          dx: (if (> k u0) (/ (* amount (get a reserves)) k) amount),
          dy: (if (> k u0) (/ (* amount (get b reserves)) k) amount),
          dk: amount
        }))

(define-read-only (get-reserves-quote)
    (let (
        (reserves (get-reserves))
        (supply (ft-get-supply Hanna-OBT)))
        {
          dx: (get a reserves),
          dy: (get b reserves),
          dk: supply
        }))

;; --- Initialization ---
(begin
    ;; Add initial balanced liquidity (handles both token transfers at 1:1)
    (try! (add-liquidity u895000000000))
    
    ;; Transfer additional token A to achieve desired ratio
    (try! (contract-call? 'SP16YY4E2FK8PRZS1S9W2BPF8J2T8D4V61EB6TWNT.hanna-labs transfer u705000000000 tx-sender CONTRACT none)))
```
