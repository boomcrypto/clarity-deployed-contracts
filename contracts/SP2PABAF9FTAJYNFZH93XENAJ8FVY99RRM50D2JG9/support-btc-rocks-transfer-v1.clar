;; @contract Support for BTC Rock transfers
;; @version 1
(define-map sponsor-balances principal uint)

;; Sponsors can deposit any amount to the contract.
;; The balance is stored
;; @post stx: amount will be transferred from the sender
(define-public (deposit (amount uint))
  (let ((balance (default-to u0 (map-get? sponsor-balances tx-sender))))
    (map-set sponsor-balances tx-sender (+ balance amount))
    (stx-transfer? amount tx-sender (as-contract tx-sender))))
 
;; If the contract holds a positive balance at any time, 
;; the sponsor can withdraw up to the deposited amount.
;; @post stx: amount will be transferred from this contract
(define-public (withdraw (amount uint))
  (let ((balance (default-to u0 (map-get? sponsor-balances tx-sender)))
        (sponsor tx-sender))
    (asserts! (>= balance amount) (err u500))
    (map-set sponsor-balances tx-sender (- balance amount))
    (as-contract (stx-transfer? amount tx-sender sponsor))))
 
;; A rock owner can use the total sponsored amount in the contract to pay 
;; all or parts of the transfer fees.
;; @post stx: total balance will be transferred from this contract if positive
;; @post 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.btc-rocks::rock: rock-id will be transferred from the sender
;; @post stx: less or equal than inital total balance will be transferred from sender
(define-public (sponsored-transfer (rock-id uint) (recipient principal))
  (let ((rock-owner tx-sender)
        (balance (stx-get-balance rock-owner))
        (sponsored-amount (stx-get-balance (as-contract tx-sender))))
    ;; transfer sponsored amount
    (and (> sponsored-amount u0)
        (try! (as-contract (stx-transfer? sponsored-amount tx-sender rock-owner))))
    ;; transfer BTC Rock
    (try! (contract-call? 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.btc-rocks transfer rock-id tx-sender recipient))
    ;; return unused sponsored amount
    (let ((new-balance (stx-get-balance rock-owner))
           (extra-amount (if (< new-balance u1000000) u0 (if (> new-balance (+ sponsored-amount u1000000)) sponsored-amount (- new-balance u1000000)))))
        (and (> extra-amount u0)            
            (try! (stx-transfer? extra-amount tx-sender (as-contract tx-sender))))
        (ok true))))
  
(define-read-only (get-sponsor-amount (sponsor principal))
  (map-get? sponsor-balances sponsor))

