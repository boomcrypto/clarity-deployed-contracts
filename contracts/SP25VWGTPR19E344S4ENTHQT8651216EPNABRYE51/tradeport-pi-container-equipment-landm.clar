;; tradeport-project-indigo-comission-container-equipment-landmark
(define-public (pay (id uint) (price uint)) 
    (begin 
        ;; Tradeport (1%)
        (try! (stx-transfer? (/ (* price u100) u10000) tx-sender 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C))

        ;; Team (5%)
        ;; Karel (1.25%)
        (try! (stx-transfer? (/ (* price u125) u10000) tx-sender 'SP1AD4C22XFTYTV12G0MCGSPGC1B6KP2H1FBJKHWE))

        ;; Project Fund (2.45%)
        (try! (stx-transfer? (/ (* price u245) u10000) tx-sender 'SP2DADKD5KK22MHMVN3DCSKS10T17CM7PDTC6WQV8))

        ;; Jon (1.30%)
        (try! (stx-transfer? (/ (* price u130) u10000) tx-sender 'SP18J677R5GRD7EKK0S096WVQW19SDPWTC0TCBTGV))

        (ok true)
    )
)