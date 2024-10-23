
;;spoint-market-minter-v0

(define-public (fulfil-order-bitcoin-bears-claim (spc-id uint) (receiver-id uint) (purchase-amount uint)) 
    (begin 
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-spoint-market fulfil-order spc-id receiver-id purchase-amount))
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-bears spoints-claim receiver-id))
        (ok true)
    ))

(define-public (fulfil-order-spaghettipunk-club-anthem-claim (spc-id uint) (receiver-id uint) (purchase-amount uint)) 
    (begin 
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-spoint-market fulfil-order spc-id receiver-id purchase-amount))
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club-anthem spoints-claim receiver-id))
        (ok true)
    ))
