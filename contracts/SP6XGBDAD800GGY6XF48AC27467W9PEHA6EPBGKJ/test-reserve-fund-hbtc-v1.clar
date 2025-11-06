;; @contract Reserve Fund
;; @version 1

(use-trait ft .sip-010-trait.sip-010-trait)

(define-constant ERR_INSUFFICIENT_BALANCE (err u108001))

;;-------------------------------------
;; Transfer
;;-------------------------------------

(define-public (transfer (asset <ft>) (amount uint) (recipient principal) (memo (optional (buff 34))))
  (let (
    (balance (try! (contract-call? asset get-balance (as-contract tx-sender))))
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-protocol contract-caller))
    (asserts! (>= balance amount) ERR_INSUFFICIENT_BALANCE)
    (print { action: "transfer", user: contract-caller, contract: .test-reserve-fund-hbtc-v1, data: { asset: asset, amount: amount, recipient: recipient, balance: balance }})
    (ok (try! (as-contract (contract-call? asset transfer amount tx-sender recipient memo))))
  )
)