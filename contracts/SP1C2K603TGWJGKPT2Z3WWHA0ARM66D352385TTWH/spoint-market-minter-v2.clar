;;spoint-market-minter-v2

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


(define-public (fulfil-order-welsh-anthem-claim (spc-id uint) (receiver-id uint) (purchase-amount uint)) 
    (begin 
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-spoint-market fulfil-order spc-id receiver-id purchase-amount))
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.welsh-anthem spoints-claim receiver-id))
        (ok true)
    ))

(define-public (fulfil-order-not-punk-claim (spc-id uint) (receiver-id uint) (purchase-amount uint)) 
    (begin 
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-spoint-market fulfil-order spc-id receiver-id purchase-amount))
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.not-punk spoints-claim receiver-id))
        (ok true)
    ))

(define-public (fulfil-order-not-punk-claim-two (spc-id uint) (receiver-id uint) (purchase-amount uint)) 
    (begin 
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-spoint-market fulfil-order spc-id receiver-id purchase-amount))
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.not-punk spoints-claim-two receiver-id))
        (ok true)
    ))

(define-public (fulfil-order-not-punk-claim-three (spc-id uint) (receiver-id uint) (purchase-amount uint)) 
    (begin 
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-spoint-market fulfil-order spc-id receiver-id purchase-amount))
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.not-punk spoints-claim-three receiver-id))
        (ok true)
    ))
(define-public (fulfil-order-not-punk-claim-four (spc-id uint) (receiver-id uint) (purchase-amount uint)) 
    (begin 
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-spoint-market fulfil-order spc-id receiver-id purchase-amount))
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.not-punk spoints-claim-four receiver-id))
        (ok true)
    ))
(define-public (fulfil-order-not-punk-claim-five (spc-id uint) (receiver-id uint) (purchase-amount uint)) 
    (begin 
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-spoint-market fulfil-order spc-id receiver-id purchase-amount))
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.not-punk spoints-claim-five receiver-id))
        (ok true)
    ))
(define-public (fulfil-order-not-punk-claim-six (spc-id uint) (receiver-id uint) (purchase-amount uint)) 
    (begin 
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-spoint-market fulfil-order spc-id receiver-id purchase-amount))
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.not-punk spoints-claim-six receiver-id))
        (ok true)
    ))
(define-public (fulfil-order-not-punk-claim-seven (spc-id uint) (receiver-id uint) (purchase-amount uint)) 
    (begin 
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-spoint-market fulfil-order spc-id receiver-id purchase-amount))
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.not-punk spoints-claim-seven receiver-id))
        (ok true)
    ))
(define-public (fulfil-order-not-punk-claim-eight (spc-id uint) (receiver-id uint) (purchase-amount uint)) 
    (begin 
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-spoint-market fulfil-order spc-id receiver-id purchase-amount))
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.not-punk spoints-claim-eight receiver-id))
        (ok true)
    ))
(define-public (fulfil-order-not-punk-claim-nine (spc-id uint) (receiver-id uint) (purchase-amount uint)) 
    (begin 
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-spoint-market fulfil-order spc-id receiver-id purchase-amount))
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.not-punk spoints-claim-nine receiver-id))
        (ok true)
    ))
(define-public (fulfil-order-not-punk-claim-ten (spc-id uint) (receiver-id uint) (purchase-amount uint)) 
    (begin 
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-spoint-market fulfil-order spc-id receiver-id purchase-amount))
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.not-punk spoints-claim-ten receiver-id))
        (ok true)
    ))