;; gamma-project-indigo-comission-wastelander-v3
(define-public (pay (id uint) (price uint)) 
    (begin 
        ;; Gamma (2%)
        (try! (stx-transfer? (/ (* price u200) u10000) tx-sender 'SP2C6Z66YMR97NNZYAPMQX7336W4CM9DRJCSDDAM9))

        ;; Team (5%)
        ;; Jon (2%)
        (try! (stx-transfer? (/ (* price u200) u10000) tx-sender 'SP18J677R5GRD7EKK0S096WVQW19SDPWTC0TCBTGV))

        ;; Tim (1.8%)
        (try! (stx-transfer? (/ (* price u180) u10000) tx-sender 'SP2H2ZB08EW097TPDQPDPPJ6B73YAZS4V2KNSDC04))

        ;; Project Fund (1.20%)
        (try! (stx-transfer? (/ (* price u120) u10000) tx-sender 'SP2DADKD5KK22MHMVN3DCSKS10T17CM7PDTC6WQV8))

        (ok true)
    )
)