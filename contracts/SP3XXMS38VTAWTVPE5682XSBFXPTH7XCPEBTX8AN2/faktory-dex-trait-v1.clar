(use-trait faktory-token .faktory-trait-v1.sip-010-trait) 

(define-trait dex-trait
  (
    ;; buy from the bonding curve dex
    (buy (<faktory-token> uint) (response bool uint))

    ;; sell from the bonding curve dex
    (sell (<faktory-token> uint) (response bool uint))

    ;; the status of the dex
    (get-open () (response bool uint))

    ;; data to inform a buy 
    (get-in (uint) (response {
        stx-in: uint,      
        fee: uint,         
        tokens-out: uint,  
        ft-balance: uint,  
        new-ft: uint,      
        total-stx: uint,   
        new-stx: uint,     
        stx-to-grad: uint  
    } uint))

    ;; data to inform a sell
    (get-out (uint) (response {
        amount-in: uint,
        stx-out: uint,
        fee: uint,
        stx-to-receiver: uint,
        total-stx: uint,
        new-stx: uint,
        ft-balance: uint,
        new-ft: uint
    } uint))
  )
)