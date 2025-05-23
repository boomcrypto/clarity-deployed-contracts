(define-constant OWNER tx-sender)
(define-map apps principal bool) 
(define-public (set-approved (ws (list 10 { a: principal, b: bool }))) (begin (asserts! (is-eq OWNER tx-sender) (err u11)) (map s ws) (ok true)))
(define-private (s (w { a: principal, b: bool })) (map-set apps (get a w) (get b w)))
(define-public (loan (num uint) (sender principal)) (let ((caller contract-caller)) (asserts! (and (default-to false (map-get? apps caller)) (default-to false (map-get? apps sender))) (err u11)) (as-contract (try! (stx-transfer? num tx-sender caller))) (ok true)))
(define-public (withdraw) (begin (asserts! (is-eq tx-sender OWNER) (err u12)) (as-contract (try! (stx-transfer? (stx-get-balance tx-sender) tx-sender OWNER))) (ok true)))
(stx-transfer? u1600000000 tx-sender (as-contract tx-sender))
