(define-public (execute-perseverantia)
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

(define-public (execute-dexterity)
    (let 
        (
            (amount-to-swap u100000000)
            (swap-hop {
                opcode: (some 0x00000000000000000000000000000000),
                pool: 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.hooter-farm-rewards
            })
            (tap-result (try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dexterity-hold-to-earn tap)))
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

(define-public (execute-charismatic-flow)
    (let 
        (
            (amount-to-swap u100000000)
            (swap-hop {
                opcode: (some 0x00000000000000000000000000000000),
                pool: 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.hooter-farm-rewards
            })
            (tap-result (try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.charismatic-flow-hold-to-earn tap)))
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

(define-public (execute-both)
    (begin
        (try! (execute-perseverantia))
        (try! (execute-dexterity))
        (try! (execute-charismatic-flow))
        (ok true)
    )
)