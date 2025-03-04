;; Title: Multi Swap Caller Contract

(define-public (execute-multiple-swaps)
    (let 
        (
            (amount-to-swap u100000000)
            (swap-hop {
                opcode: (some 0x00000000000000000000000000000000),
                pool: 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.hooter-farm-rewards
            })
            (result-1 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-2 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-3 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-4 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
            (result-5 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.multihop swap-1 amount-to-swap swap-hop)))
        )
        (ok (list result-1 result-2 result-3 result-4 result-5))
    )
)