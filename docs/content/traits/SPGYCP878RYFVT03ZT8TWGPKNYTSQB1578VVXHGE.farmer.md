---
title: "Trait farmer"
draft: true
---
```
;; Title: Multi Swap Caller Contract

;; Execute 1 swap
(define-public (execute-1-swap)
    (let 
        (
            (amount-to-swap u100000000)
            (swap-hop {
                opcode: (some 0x00000000000000000000000000000000),
                pool: 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.hooter-farm-rewards
            })
            ;; First tap for energy
            (tap-result (try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.perseverantia-omnia-vincit-hold-to-earn tap)))
            ;; Then execute swap
            (result-1 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
        )
        (ok (list result-1))
    )
)

;; Execute 2 swaps
(define-public (execute-2-swaps)
    (let 
        (
            (amount-to-swap u100000000)
            (swap-hop {
                opcode: (some 0x00000000000000000000000000000000),
                pool: 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.hooter-farm-rewards
            })
            (tap-result (try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.perseverantia-omnia-vincit-hold-to-earn tap)))
            (result-1 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-2 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
        )
        (ok (list result-1 result-2))
    )
)

;; Execute 3 swaps
(define-public (execute-3-swaps)
    (let 
        (
            (amount-to-swap u100000000)
            (swap-hop {
                opcode: (some 0x00000000000000000000000000000000),
                pool: 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.hooter-farm-rewards
            })
            (tap-result (try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.perseverantia-omnia-vincit-hold-to-earn tap)))
            (result-1 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-2 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-3 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
        )
        (ok (list result-1 result-2 result-3))
    )
)

;; Execute 4 swaps
(define-public (execute-4-swaps)
    (let 
        (
            (amount-to-swap u100000000)
            (swap-hop {
                opcode: (some 0x00000000000000000000000000000000),
                pool: 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.hooter-farm-rewards
            })
            (tap-result (try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.perseverantia-omnia-vincit-hold-to-earn tap)))
            (result-1 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-2 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-3 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-4 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
        )
        (ok (list result-1 result-2 result-3 result-4))
    )
)

;; Execute 5 swaps
(define-public (execute-5-swaps)
    (let 
        (
            (amount-to-swap u100000000)
            (swap-hop {
                opcode: (some 0x00000000000000000000000000000000),
                pool: 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.hooter-farm-rewards
            })
            (tap-result (try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.perseverantia-omnia-vincit-hold-to-earn tap)))
            (result-1 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-2 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-3 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-4 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-5 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
        )
        (ok (list result-1 result-2 result-3 result-4 result-5))
    )
)

;; Execute 6 swaps
(define-public (execute-6-swaps)
    (let 
        (
            (amount-to-swap u100000000)
            (swap-hop {
                opcode: (some 0x00000000000000000000000000000000),
                pool: 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.hooter-farm-rewards
            })
            (tap-result (try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.perseverantia-omnia-vincit-hold-to-earn tap)))
            (result-1 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-2 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-3 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-4 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-5 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-6 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
        )
        (ok (list result-1 result-2 result-3 result-4 result-5 result-6))
    )
)

;; Execute 7 swaps
(define-public (execute-7-swaps)
    (let 
        (
            (amount-to-swap u100000000)
            (swap-hop {
                opcode: (some 0x00000000000000000000000000000000),
                pool: 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.hooter-farm-rewards
            })
            (tap-result (try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.perseverantia-omnia-vincit-hold-to-earn tap)))
            (result-1 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-2 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-3 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-4 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-5 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-6 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-7 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
        )
        (ok (list result-1 result-2 result-3 result-4 result-5 result-6 result-7))
    )
)

;; Execute 8 swaps
(define-public (execute-8-swaps)
    (let 
        (
            (amount-to-swap u100000000)
            (swap-hop {
                opcode: (some 0x00000000000000000000000000000000),
                pool: 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.hooter-farm-rewards
            })
            (tap-result (try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.perseverantia-omnia-vincit-hold-to-earn tap)))
            (result-1 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-2 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-3 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-4 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-5 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-6 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-7 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-8 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
        )
        (ok (list result-1 result-2 result-3 result-4 result-5 result-6 result-7 result-8))
    )
)

;; Execute 9 swaps
(define-public (execute-9-swaps)
    (let 
        (
            (amount-to-swap u100000000)
            (swap-hop {
                opcode: (some 0x00000000000000000000000000000000),
                pool: 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.hooter-farm-rewards
            })
            (tap-result (try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.perseverantia-omnia-vincit-hold-to-earn tap)))
            (result-1 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-2 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-3 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-4 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-5 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-6 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-7 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-8 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-9 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
        )
        (ok (list result-1 result-2 result-3 result-4 result-5 result-6 result-7 result-8 result-9))
    )
)

;; Execute 10 swaps
(define-public (execute-10-swaps)
    (let 
        (
            (amount-to-swap u100000000)
            (swap-hop {
                opcode: (some 0x00000000000000000000000000000000),
                pool: 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.hooter-farm-rewards
            })
            (tap-result (try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.perseverantia-omnia-vincit-hold-to-earn tap)))
            (result-1 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-2 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-3 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-4 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-5 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-6 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-7 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-8 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-9 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-10 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
        )
        (ok (list result-1 result-2 result-3 result-4 result-5 result-6 result-7 result-8 result-9 result-10))
    )
)
```
