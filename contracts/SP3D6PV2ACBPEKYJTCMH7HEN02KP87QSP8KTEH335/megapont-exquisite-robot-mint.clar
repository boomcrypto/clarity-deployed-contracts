;; constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))

;; public functions
(define-public (mint-robot (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (try! (contract-call? .megapont-exquisite-robot-nft mint new-owner))
    (ok true)))

(contract-call? .megapont-exquisite-robot-nft approve-minter)
