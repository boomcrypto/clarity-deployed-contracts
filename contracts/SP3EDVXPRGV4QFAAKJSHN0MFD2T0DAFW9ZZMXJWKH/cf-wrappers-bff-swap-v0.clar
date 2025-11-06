(define-constant ERR_INVALID_INSTRUCTIONS (err u500))

(define-public (router-wrapper
        (name (string-ascii 128))
        (instructions (buff 4096))
    )
    (let ((params-deserialized (unwrap!
            (from-consensus-buff? {
                amount: uint,
                min-receive: uint,
                func: (string-ascii 32),
            }
                instructions
            )
            ERR_INVALID_INSTRUCTIONS
        )))
        (if (is-eq (get func params-deserialized) "swap-stx-usdh")
            ;; #[filter(instructions)]
            (try! (swap-stx-usdh instructions))
            false
        )
        (if (is-eq (get func params-deserialized) "swap-usdh-stx")
            ;; #[filter(instructions)]
            (try! (swap-usdh-stx instructions))
            false
        )
        (ok true)
    )
)

(define-private (swap-stx-usdh (params (buff 4096)))
    (let (
            (params-deserialized (unwrap!
                (from-consensus-buff? {
                    amount: uint,
                    min-receive: uint,
                }
                    params
                )
                ERR_INVALID_INSTRUCTIONS
            ))
            (params-amount (get amount params-deserialized))
            (params-min-receive (get min-receive params-deserialized))
        )
        (begin
            (try! (contract-call?
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stableswap-xyk-v-1-3
                swap-helper-a params-amount params-min-receive none true {
                a: 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc,
                b: 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1,
            } { a: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-aeusdc-usdh-v-1-2 } {
                a: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-1,
                b: 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc,
            } { a: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-stx-aeusdc-v-1-1 }
            ))
            (ok true)
        )
    )
)

(define-private (swap-usdh-stx (params (buff 4096)))
    (let (
            (params-deserialized (unwrap!
                (from-consensus-buff? {
                    amount: uint,
                    min-receive: uint,
                }
                    params
                )
                ERR_INVALID_INSTRUCTIONS
            ))
            (params-amount (get amount params-deserialized))
            (params-min-receive (get min-receive params-deserialized))
        )
        (begin
            (try! (contract-call?
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stableswap-xyk-v-1-3
                swap-helper-a params-amount params-min-receive none false {
                a: 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1,
                b: 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc,
            } { a: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-aeusdc-usdh-v-1-2 } {
                a: 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc,
                b: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-1,
            } { a: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-stx-aeusdc-v-1-1 }
            ))
            (ok true)
        )
    )
)
