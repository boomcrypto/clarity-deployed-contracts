---
title: "Trait hello-stacks"
draft: true
---
```

(define-data-var contract-owner (optional principal) none)

(define-read-only (get-owner)
     (var-get contract-owner)
)

(define-public (set-owner )
(begin
    (asserts! (is-eq tx-sender contract-caller) (err "mismatch caller"))
    (asserts! (is-eq (var-get contract-owner) none) (err "owner already set"))
    (var-set contract-owner (some tx-sender))
    (ok true)
)
)

(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)


(define-private (transfer-ft (token-contract <ft-trait>) (amount uint) (sender principal) (recipient principal))
    (contract-call? token-contract transfer amount sender recipient none)
)

;; to add the trait clarinet requirements add SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard

(define-constant sbtc-token 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)

;;TODO, add a check, I cannot set the deposit if I have already lent out actively


;;TODO the u10000 is wrong, too much 7% APR is like 7000 sats every 100 000 000 yearly borrowed, so 19/100000000 sats every day for lovelace 2 cents/100000000 ogni giorno, 0.016 STX/100000000 per BTC ogni giorno


(define-map lenders principal { amount: uint, expiration:uint, dailyprice:uint, borrowers: (list 100 {owner: principal, borrower:principal, amount:uint, deadline: uint, days:uint})})
(define-map borrowers principal { borrowers: (list 100 {owner: principal, borrower:principal, amount:uint, deadline: uint, days:uint})})

(define-read-only (get-lenders (owner principal) )
(unwrap-panic (map-get? lenders owner))
)

(define-read-only (get-borrowers (owner principal) )
(unwrap-panic (map-get? borrowers owner))
)



(define-private (increase-lender-amount (owner principal) (amount uint))
    (map-set lenders owner {expiration: (get expiration (unwrap-panic (map-get? lenders owner))), amount: ( + (get amount (unwrap-panic (map-get? lenders owner) )) amount), borrowers: (remove-expired-loans owner) , dailyprice:(get dailyprice (unwrap-panic (map-get? lenders owner) ))})
)
;;this action should delete the old inactive loans if any
(define-private (decrease-lender-amount (owner principal) (amount uint))
    (map-set lenders owner {expiration: (get expiration (unwrap-panic (map-get? lenders owner))), amount: ( - (get amount (unwrap-panic (map-get? lenders owner) )) amount), borrowers: (remove-expired-loans owner) , dailyprice:(get dailyprice (unwrap-panic (map-get? lenders owner) ))})
)
(define-private (decrease-lender-amount-borrower (owner principal) (amount uint) (borrower principal) (deadline uint) (days uint))
    (map-set lenders owner {expiration: (get expiration (unwrap-panic (map-get? lenders owner))), amount:(get amount (unwrap-panic (map-get? lenders owner) )), borrowers: (unwrap-panic (as-max-len? (concat (remove-expired-loans owner) (list {owner: owner, borrower:borrower, amount:amount, deadline: deadline, days:days})) u100)), dailyprice:(get dailyprice (unwrap-panic (map-get? lenders owner) ))})
)

(define-private (is-not-expired (loan {owner: principal, borrower:principal, amount:uint, deadline: uint, days:uint}))
    (> (get deadline loan) burn-block-height )
)


(define-private (remove-expired-loans (owner principal))
    (filter is-not-expired (get borrowers (unwrap-panic (map-get? lenders owner))))
)

(define-private (get-amount-loan (loan {owner: principal, borrower:principal, amount:uint, deadline: uint, days:uint}))
     (get amount loan) 
)

(define-private (get-available-liquidity (owner principal))
     (+ (get amount (unwrap-panic (map-get? lenders owner))) (fold + (map get-amount-loan (filter is-not-expired (get borrowers (unwrap-panic (map-get? lenders owner))))) u0))
)


(define-private (no-used-liquidity (owner principal))
    (is-eq (fold + (map get-amount-loan (filter is-not-expired (get borrowers (unwrap-panic (map-get? lenders owner))))) u0) u0)
)


;;TODO, add a check, I cannot set the deposit if I have already lent out actively
(define-public (deposit_final (amount uint) (days  uint) (dailyprice uint) )
    (begin
        (if (is-eq (map-get? lenders tx-sender) none)
            (map-set lenders tx-sender {amount: amount, expiration:(+ burn-block-height (* u144 days)) ,  dailyprice:dailyprice , borrowers: (list ) })
            (increase-lender-amount tx-sender amount)
        )
        (transfer-ft sbtc-token amount tx-sender (as-contract tx-sender))
    )
)

;;expiration here is wrong TODO FIX
(define-public (withdraw_final (amount uint) )
    (begin 
    (>= (get-available-liquidity tx-sender) amount)
    (decrease-lender-amount tx-sender amount)
    (transfer-ft sbtc-token amount (as-contract tx-sender) tx-sender)
    )
)


(define-private (get-expiration-lender (owner principal))
    (get expiration (unwrap-panic (map-get? lenders owner) ))
)
(define-private (get-cost-borrow (days uint) (borrower principal) (owner principal) (amount uint))
    (* (* (get dailyprice (unwrap-panic (map-get? lenders owner) )) days) amount)
)

;;payout function that everyone can actually call, claim rewards and payout
;;enroll function

;;expiration here is wrong TODO FIX
(define-public (borrow_final (lender principal) (amount uint) (days uint) )
    (begin 
    (>= (get-available-liquidity lender) amount)
    (decrease-lender-amount-borrower lender amount tx-sender (+ (* u144 days) burn-block-height) days)
    (asserts! (> (get-expiration-lender lender) (+ (* u144 days) burn-block-height)) (err u22))
    (if (is-eq (map-get? borrowers tx-sender) none)
        (map-set borrowers tx-sender {borrowers:(unwrap-panic 
            (as-max-len? (list {owner: lender, borrower:tx-sender, amount:amount, deadline: (+ (* u144 days) burn-block-height), days:days})
             u100))})
        (map-set borrowers tx-sender {borrowers: (unwrap-panic 
            (as-max-len? (concat (get borrowers (unwrap-panic (map-get? borrowers tx-sender))) (list {owner: lender, borrower:tx-sender, amount:amount, deadline: (+ (* u144 days) burn-block-height), days:days})
            ) u100 )  )}
        )
    )
    (stx-transfer? (get-cost-borrow days tx-sender lender amount) tx-sender lender)
    
    )
)
        


    
```
