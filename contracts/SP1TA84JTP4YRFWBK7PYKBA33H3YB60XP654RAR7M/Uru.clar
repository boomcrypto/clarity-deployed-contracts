;; Mint Fungible Tokens via Dapparatus with max supply sent to minter
(define-constant minter 'SP1TA84JTP4YRFWBK7PYKBA33H3YB60XP654RAR7M) 
(define-fungible-token Uru u21000000) 
(ft-mint? Uru u21000000 minter) 

;; traits of contract for function calls against it 
(define-trait ft-trait 
  ( 
    ;; Transfer from caller to new principal 
    (transfer (uint principal principal) (response bool uint)) 

    ;; Additonal Gets 
    (get-name () (response (string-ascii 32) uint)) 
    (get-symbol () (response (string-ascii 32) uint)) 
    (get-decimals () (response uint uint)) 
    (get-balance-of (principal) (response uint uint)) 
    (get-total-supply () (response uint uint)) 
    (get-token-uri () (response (optional (string-utf8 256)) uint)) 
  ) 
)