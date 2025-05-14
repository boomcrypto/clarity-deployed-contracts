(define-constant ONE_8 u100000000) ;; 8 decimal places

(define-private (mul-down (a uint) (b uint))
	(/ (* a b) ONE_8))

(define-read-only (get-helper-with-fee (token-x principal) (token-y principal) (factor uint) (dx uint))
    (let (
            (fee-rate (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 fee-helper token-x token-y factor)))
            (dx-net-fees (mul-down dx (- ONE_8 fee-rate)))
        )
        (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper token-x token-y factor dx-net-fees)))

(define-read-only (get-helper-with-fee-a (token-x principal) (token-y principal) (token-z principal) (factor-x uint) (factor-y uint) (dx uint))
    (get-helper-with-fee token-y token-z factor-y (try! (get-helper-with-fee token-x token-y factor-x dx))))

(define-read-only (get-helper-with-fee-b
        (token-x principal) (token-y principal) (token-z principal) (token-w principal)
        (factor-x uint) (factor-y uint) (factor-z uint)
        (dx uint))
    (get-helper-with-fee token-z token-w factor-z (try! (get-helper-with-fee-a token-x token-y token-z factor-x factor-y dx))))

(define-read-only (get-helper-with-fee-c
        (token-x principal) (token-y principal) (token-z principal) (token-w principal) (token-v principal)
        (factor-x uint) (factor-y uint) (factor-z uint) (factor-w uint)
        (dx uint))
    (get-helper-with-fee-a token-z token-w token-v factor-z factor-w (try! (get-helper-with-fee-a token-x token-y token-z factor-x factor-y dx))))