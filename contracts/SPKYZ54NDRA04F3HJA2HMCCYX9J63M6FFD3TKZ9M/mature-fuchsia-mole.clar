
(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
  (begin
    (try! (contract-call? 'SPKYZ54NDRA04F3HJA2HMCCYX9J63M6FFD3TKZ9M.glad-apricot-blackbird set-extensions
      (list
        { extension: 'SPKYZ54NDRA04F3HJA2HMCCYX9J63M6FFD3TKZ9M.native-silver-python, enabled: true }
        { extension: 'SPKYZ54NDRA04F3HJA2HMCCYX9J63M6FFD3TKZ9M.promising-pink-muskox, enabled: true }
      )
    ))

    (try! (contract-call? 'SPKYZ54NDRA04F3HJA2HMCCYX9J63M6FFD3TKZ9M.promising-pink-muskox set-approver 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9 true))  
    (try! (contract-call? 'SPKYZ54NDRA04F3HJA2HMCCYX9J63M6FFD3TKZ9M.promising-pink-muskox set-approver 'SP3AJC728JY0Y43E8RT6K4VDWPT265RDMXJ8M0VH0 true))  
    (try! (contract-call? 'SPKYZ54NDRA04F3HJA2HMCCYX9J63M6FFD3TKZ9M.promising-pink-muskox set-approver 'SP2TZJYSK1RWP9DQ3N10E2M281RWHTSZ2NRN0TRGC true))  
    (try! (contract-call? 'SPKYZ54NDRA04F3HJA2HMCCYX9J63M6FFD3TKZ9M.promising-pink-muskox set-approver 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC true))  
    (try! (contract-call? 'SPKYZ54NDRA04F3HJA2HMCCYX9J63M6FFD3TKZ9M.promising-pink-muskox set-approver 'SP14FSJX1Q9EV6RA2GP2WZ3RNK6DX7057QNXC4Z9B true))

    (try! (contract-call? 'SPKYZ54NDRA04F3HJA2HMCCYX9J63M6FFD3TKZ9M.promising-pink-muskox set-signals-required u2))
    
    (try! (contract-call? 'SPKYZ54NDRA04F3HJA2HMCCYX9J63M6FFD3TKZ9M.native-silver-python set-allowed 'SPKYZ54NDRA04F3HJA2HMCCYX9J63M6FFD3TKZ9M.acid-hearts true))

    (print { message: "...to be a completely separate network and separate block chain, yet share CPU power with Bitcoin.", sender: sender })
    (ok true)
  )
)
