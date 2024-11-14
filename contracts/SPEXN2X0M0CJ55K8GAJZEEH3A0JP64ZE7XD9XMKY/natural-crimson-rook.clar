;; test-bridge-aeusdc-v-1-1

(define-constant ERR_NOT_AUTHORIZED (err u1001))
(define-constant ERR_INVALID_AMOUNT (err u1002))
(define-constant ERR_TOKEN_TRANSFER_FAILED (err u8002))

(define-constant CONTRACT_OWNER tx-sender)

(define-public (bridge-helper-a (amount uint) (recipient principal))
  (let (
    (caller tx-sender)
  )
    (asserts! (is-eq caller CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (try! (as-contract (transfer-aeusdc amount tx-sender recipient)))
    (print {action: "bridge-helper-a", caller: caller, data: {amount: amount, recipient: recipient}})
    (ok true)
  )
)

(define-private (transfer-aeusdc (amount uint) (sender principal) (recipient principal))
  (let (
    (call-a (unwrap! (contract-call?
                     'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc transfer
                     amount sender recipient none) ERR_TOKEN_TRANSFER_FAILED))
  )
    (ok call-a)
  )
)

(try! (transfer-aeusdc u1000000 tx-sender (as-contract tx-sender)))