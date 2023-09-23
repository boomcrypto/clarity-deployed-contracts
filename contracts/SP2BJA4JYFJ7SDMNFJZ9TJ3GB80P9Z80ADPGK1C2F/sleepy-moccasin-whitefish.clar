;; stacker DB
(define-read-only (stackerdb-get-signer-slots)
    (ok (list
        {
            signer: 'SPHJQVVSFG47CKWPFKHBVKFHWKS80TG5CE0N9MG1,
            num-slots: u10
        }
        {
            signer: 'SPHHXB6WNZC86JZ8CZ1WQ6CT7BD1AAJHMT48YBN3,
            num-slots: u10
        }
        {
            signer: 'SP2NSF3JQ4ZV6WCCX0DW025TJX74M89RVPBGSJ2W8,
            num-slots: u10
        }
        {
            signer: 'SP3AK8DKXJYJ65TJ0A6E9SVQ2NAX9BGBCAH8DFY47,
            num-slots: u10
        }
        {
            signer: 'SP3RFT9PWQYHDBGCY81921WEM4VWHW7GZBACNMQAK,
            num-slots: u10
        }
        )))

(define-read-only (stackerdb-get-config)
    (ok {
        chunk-size: u4096,
        write-freq: u0,
        max-writes: u4096,
        max-neighbors: u32,
        hint-replicas: (list )
    }))