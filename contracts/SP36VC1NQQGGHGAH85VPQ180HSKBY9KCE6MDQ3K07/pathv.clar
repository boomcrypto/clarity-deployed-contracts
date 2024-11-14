;; Contract Management
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-swap-failed (err u102))

;; Execute the complete sequence
(define-public (swap-4)
    (begin
        ;; First set of amounts (higher values)
        (try! (contract-call? 'SP36VC1NQQGGHGAH85VPQ180HSKBY9KCE6MDQ3K07.path-part0 set-all-swap-amounts 
            u15000000  ;; amount1
            u75000000  ;; amount2
            u150000000 ;; amount3
            u75000000  ;; amount4
            u75000000  ;; amount5
            u75000000  ;; amount6
        ))

        ;; Execute swap-3
        (try! (contract-call? 'SP36VC1NQQGGHGAH85VPQ180HSKBY9KCE6MDQ3K07.path-part0 swap-3))

        ;; Second set of amounts (lower values)
        (try! (contract-call? 'SP36VC1NQQGGHGAH85VPQ180HSKBY9KCE6MDQ3K07.path-part0 set-all-swap-amounts 
            u5000000   ;; amount1
            u25000000  ;; amount2
            u50000000  ;; amount3
            u25000000  ;; amount4
            u25000000  ;; amount5
            u25000000  ;; amount6
        ))

        ;; Return success
        (ok true)))