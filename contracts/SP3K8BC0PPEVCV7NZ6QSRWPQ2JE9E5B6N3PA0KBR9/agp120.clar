(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 u100000000)
(define-constant amount u1500000)
(define-public (execute (sender principal))
    (begin
        (try! (contract-call? .age000-governance-token mint-fixed (* amount ONE_8) 'SPC7TY5JGGGA8HS4HGTTWXBN8NJ28XH2JR9HCXN4))
        (ok true)
    )
)