
;; title: Tip 1 STX
;; version: v 0.001
;; summary: A simple tipping contract. Doesn't take any fees. 
;; description: Sends 1 STX to a recipient. The sender can not be the recipient. Collaboration between @garyriger & Abdul Somad (@abd_somod1)

;; Constant 
(define-constant tip-amount u1000000) ;; 1stx in microSTX

;; Private function to log details of the tip
(define-private (tip-log (sender principal) (recipient principal) (amount uint))
    (print {event: "tip", sender: sender, recipient: recipient, amount: amount})
)

;; Main tipping function
(define-public (tip (recipient principal))
    (begin
        ;;check if the sender is not the same as the recipient
        (asserts! (not (is-eq tx-sender recipient)) (err u100))
        ;;transfer exactly 1 stx to the recipient
        (asserts! (is-ok (stx-transfer? tip-amount tx-sender recipient)) (err u101))
        ;; log the tip transaction
        (tip-log tx-sender recipient tip-amount)
        ;;return success
        (ok {status: "Tip Successful!", sender: tx-sender, recipient: recipient, amount: tip-amount})
    )
)