(impl-trait .arkadiko-job-cost-calculation-trait-v1.cost-calculation-trait)

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED u403)

(define-data-var cost-in-diko uint u10000000) ;; 10 DIKO

;; TODO: make cost dynamic in future cost calculator
;; perhaps based on costs-2 smart contract?
;; https://explorer.stacks.co/txid/0xece8e369310b5ff9b92ef11181ae0d2457ac0c821376d4a96c4998763e22ad04?chain=mainnet
;; currently a static amount of DIKO is charged, which can be changed by deployer
(define-public (calculate-cost (contract principal))
  (ok (var-get cost-in-diko))
)

(define-public (set-cost-in-diko (diko uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))

    (ok (var-set cost-in-diko diko))
  )
)
