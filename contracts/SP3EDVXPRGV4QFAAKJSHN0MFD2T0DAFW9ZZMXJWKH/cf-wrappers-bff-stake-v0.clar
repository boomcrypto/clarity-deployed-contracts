(define-constant ERR_INVALID_INSTRUCTIONS (err u500))
(use-trait bff-lp-stake 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-staking-trait-v-1-2.stableswap-staking-trait)

(define-private (deserialize-stake-params (instructions (buff 4096)))
    (from-consensus-buff? {
        amount: uint,
        cycles: uint,
        func: (string-ascii 32),
    }
        instructions
    )
)

(define-public (router-wrapper
        (name (string-ascii 128))
        (instructions (buff 4096))
    )
    ;; #[filter(instructions)]
    (let ((params-deserialized (unwrap! (deserialize-stake-params instructions) ERR_INVALID_INSTRUCTIONS)))
        (if (is-eq (get func params-deserialized) "stake-aeusdc-usdh-lp-tokens")
            ;; #[filter(instructions)]
            (try! (stake-lp-tokens
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-staking-aeusdc-usdh-v-1-2
                instructions
            ))
            false
        )
        (if (is-eq (get func params-deserialized) "unstake-aeusdc-usdh-lp-tokens")
            ;; #[filter(instructions)]
            (try! (unstake-lp-tokens
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-staking-aeusdc-usdh-v-1-2
                instructions
            ))
            false
        )
        (if (is-eq (get func params-deserialized) "stake-stx-ststx-lp-tokens")
            ;; #[filter(instructions)]
            (try! (stake-lp-tokens
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-staking-stx-ststx-v-1-4
                instructions
            ))
            false
        )
        (if (is-eq (get func params-deserialized) "unstake-stx-ststx-lp-tokens")
            ;; #[filter(instructions)]
            (try! (unstake-lp-tokens
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-staking-stx-ststx-v-1-4
                instructions
            ))
            false
        )
        (if (is-eq (get func params-deserialized) "stake-stx-aeusdc-lp-tokens")
            ;; #[filter(instructions)]
            (try! (stake-lp-tokens
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-staking-stx-aeusdc-v-1-2
                instructions
            ))
            false
        )
        (if (is-eq (get func params-deserialized) "unstake-stx-aeusdc-lp-tokens")
            ;; #[filter(instructions)]
            (try! (unstake-lp-tokens
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-staking-stx-aeusdc-v-1-2
                instructions
            ))
            false
        )
        (if (is-eq (get func params-deserialized) "stake-sbtc-stx-lp-tokens")
            ;; #[filter(instructions)]
            (try! (stake-lp-tokens
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-staking-sbtc-stx-v-1-2
                instructions
            ))
            false
        )
        (if (is-eq (get func params-deserialized) "unstake-sbtc-stx-lp-tokens")
            ;; #[filter(instructions)]
            (try! (unstake-lp-tokens
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-staking-sbtc-stx-v-1-2
                instructions
            ))
            false
        )
        ;; default
        (ok true)
    )
)

;; Wrapper function
(define-private (stake-lp-tokens
        (staking-contract <bff-lp-stake>)
        (params (buff 4096))
    )
    (let (
            (params-deserialized (unwrap! (deserialize-stake-params params) ERR_INVALID_INSTRUCTIONS))
            (params-amount (get amount params-deserialized))
            (params-cycles (get cycles params-deserialized))
        )
        (begin
            (try! (contract-call? staking-contract stake-lp-tokens params-amount
                params-cycles
            ))
            (ok true)
        )
    )
)

(define-private (unstake-lp-tokens
        (staking-contract <bff-lp-stake>)
        (params (buff 4096))
    )
    (begin
        (try! (contract-call? staking-contract unstake-lp-tokens))
        (ok true)
    )
)
