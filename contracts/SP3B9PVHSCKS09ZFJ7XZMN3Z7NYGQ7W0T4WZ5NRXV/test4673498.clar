
  ;; multi-token-transfer.clar
;; A contract that enables sending multiple SIP-010 tokens to a single recipient

;; Define the token trait
(define-trait contract-principle
  (
    ;; Transfer from the caller to a new principal
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))
  )
)

;; Error constants
(define-constant ERR-UNAUTHORIZED (err u1))
(define-constant ERR-EMPTY-LIST (err u2))
(define-constant ERR-TRANSFER-FAILED (err u3))

;; Main function to transfer multiple tokens to a single recipient
(define-public (send-multiple-token-by-token 
                (token1 <contract-principle>) (amount1 uint) 
                (token2 <contract-principle>) (amount2 uint)
                (recipient principal))
  (begin
    (try! (contract-call? token1 transfer amount1 tx-sender recipient none))
    (contract-call? token2 transfer amount2 tx-sender recipient none)
  )
)

;; Function to transfer three tokens to a single recipient
(define-public (send-multiple-three-tokens
                (token1 <contract-principle>) (amount1 uint) 
                (token2 <contract-principle>) (amount2 uint)
                (token3 <contract-principle>) (amount3 uint)
                (recipient principal))
  (begin
    (try! (contract-call? token1 transfer amount1 tx-sender recipient none))
    (try! (contract-call? token2 transfer amount2 tx-sender recipient none))
    (contract-call? token3 transfer amount3 tx-sender recipient none)
  )
)

;; Function to transfer four tokens to a single recipient
(define-public (send-multiple-four-tokens
                (token1 <contract-principle>) (amount1 uint) 
                (token2 <contract-principle>) (amount2 uint)
                (token3 <contract-principle>) (amount3 uint)
                (token4 <contract-principle>) (amount4 uint)
                (recipient principal))
  (begin
    (try! (contract-call? token1 transfer amount1 tx-sender recipient none))
    (try! (contract-call? token2 transfer amount2 tx-sender recipient none))
    (try! (contract-call? token3 transfer amount3 tx-sender recipient none))
    (contract-call? token4 transfer amount4 tx-sender recipient none)
  )
)
  