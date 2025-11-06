(define-constant ERR_INVALID_INSTRUCTIONS (err u500))
(use-trait stable-swap-pool-trait-v-1-2 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-trait-v-1-2.stableswap-pool-trait)
(use-trait stable-swap-pool-trait-v-1-4 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-trait-v-1-4.stableswap-pool-trait)
(use-trait xyk-pool-trait-v-1-2 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-trait-v-1-2.xyk-pool-trait)
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-private (deserialize-liquidity-params (instructions (buff 4096)))
    (from-consensus-buff? {
        x-amount: uint,
        y-amount: uint,
        min-dlp: uint,
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
    (let ((params-deserialized (unwrap! (deserialize-liquidity-params instructions)
            ERR_INVALID_INSTRUCTIONS
        )))
        (if (is-eq (get func params-deserialized) "add-liquidity-aeusdc-usdh")
            (try! (add-liquidity-stableswap-core-v-1-2
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-aeusdc-usdh-v-1-2
                'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
                'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1
                instructions
            ))
            false
        )
        (if (is-eq (get func params-deserialized) "remove-liquidity-aeusdc-usdh")
            (try! (remove-liquidity-stableswap-core-v-1-2
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-aeusdc-usdh-v-1-2
                'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
                'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1
                instructions
            ))
            false
        )
        (if (is-eq (get func params-deserialized) "add-liquidity-stx-aeusdc")
            (try! (add-liquidity-xyk-v-1-2
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-stx-aeusdc-v-1-2
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
                'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
                instructions
            ))
            false
        )
        (if (is-eq (get func params-deserialized) "remove-liquidity-stx-aeusdc")
            (try! (remove-liquidity-xyk-v-1-2
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-stx-aeusdc-v-1-2
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
                'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
                instructions
            ))
            false
        )
        (if (is-eq (get func params-deserialized) "add-liquidity-stx-ststx")
            (try! (add-liquidity-stableswap-core-v-1-4
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-stx-ststx-v-1-4
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
                'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                instructions
            ))
            false
        )
        (if (is-eq (get func params-deserialized) "remove-liquidity-stx-ststx")
            (try! (remove-liquidity-stableswap-core-v-1-4
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-stx-ststx-v-1-4
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
                'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                instructions
            ))
            false
        )
        (if (is-eq (get func params-deserialized) "add-liquidity-sbtc-stx")
            (try! (add-liquidity-xyk-v-1-2
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1
                'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
                instructions
            ))
            false
        )
        (if (is-eq (get func params-deserialized) "remove-liquidity-sbtc-stx")
            (try! (remove-liquidity-xyk-v-1-2
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1
                'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
                instructions
            ))
            false
        )
        (ok true)
    )
)

;; lib

(define-private (add-liquidity-xyk-v-1-2
        (pool-contract <xyk-pool-trait-v-1-2>)
        (x-contract <sip-010-trait>)
        (y-contract <sip-010-trait>)
        (params (buff 4096))
    )
    (let ((params-deserialized (unwrap! (deserialize-liquidity-params params) ERR_INVALID_INSTRUCTIONS)))
        (begin
            (try! (contract-call?
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2
                add-liquidity pool-contract x-contract y-contract
                (get x-amount params-deserialized)
                (get min-dlp params-deserialized)
            ))
            (ok true)
        )
    )
)
(define-private (remove-liquidity-xyk-v-1-2
        (pool-contract <xyk-pool-trait-v-1-2>)
        (x-contract <sip-010-trait>)
        (y-contract <sip-010-trait>)
        (params (buff 4096))
    )
    (let ((params-deserialized (unwrap! (deserialize-liquidity-params params) ERR_INVALID_INSTRUCTIONS)))
        (begin
            (try! (contract-call?
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2
                withdraw-liquidity pool-contract x-contract y-contract
                (get min-dlp params-deserialized)
                (get x-amount params-deserialized)
                (get y-amount params-deserialized)
            ))
            (ok true)
        )
    )
)

(define-private (add-liquidity-stableswap-core-v-1-2
        (pool-contract <stable-swap-pool-trait-v-1-2>)
        (x-contract <sip-010-trait>)
        (y-contract <sip-010-trait>)
        (params (buff 4096))
    )
    (let ((params-deserialized (unwrap! (deserialize-liquidity-params params) ERR_INVALID_INSTRUCTIONS)))
        (begin
            (try! (contract-call?
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-2
                add-liquidity pool-contract x-contract y-contract
                (get x-amount params-deserialized)
                (get y-amount params-deserialized)
                (get min-dlp params-deserialized)
            ))
            (ok true)
        )
    )
)

(define-private (remove-liquidity-stableswap-core-v-1-2
        (pool-contract <stable-swap-pool-trait-v-1-2>)
        (x-contract <sip-010-trait>)
        (y-contract <sip-010-trait>)
        (params (buff 4096))
    )
    (let (
            (params-deserialized (unwrap! (deserialize-liquidity-params params)
                ERR_INVALID_INSTRUCTIONS
            ))
            (params-amount (get min-dlp params-deserialized))
            (params-min-x-amount (get x-amount params-deserialized))
            (params-min-y-amount (get y-amount params-deserialized))
        )
        (begin
            (try! (contract-call?
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-2
                withdraw-liquidity pool-contract x-contract y-contract
                params-amount params-min-x-amount params-min-y-amount
            ))
            (ok true)
        )
    )
)

(define-private (add-liquidity-stableswap-core-v-1-4
        (pool-contract <stable-swap-pool-trait-v-1-4>)
        (x-contract <sip-010-trait>)
        (y-contract <sip-010-trait>)
        (params (buff 4096))
    )
    (let ((params-deserialized (unwrap! (deserialize-liquidity-params params) ERR_INVALID_INSTRUCTIONS)))
        (begin
            (try! (contract-call?
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-4
                add-liquidity pool-contract x-contract y-contract
                (get x-amount params-deserialized)
                (get y-amount params-deserialized)
                (get min-dlp params-deserialized)
            ))
            (ok true)
        )
    )
)

(define-private (remove-liquidity-stableswap-core-v-1-4
        (pool-contract <stable-swap-pool-trait-v-1-4>)
        (x-contract <sip-010-trait>)
        (y-contract <sip-010-trait>)
        (params (buff 4096))
    )
    (let (
            (params-deserialized (unwrap! (deserialize-liquidity-params params)
                ERR_INVALID_INSTRUCTIONS
            ))
            (params-amount (get min-dlp params-deserialized))
            (params-min-x-amount (get x-amount params-deserialized))
            (params-min-y-amount (get y-amount params-deserialized))
        )
        (begin
            (try! (contract-call?
                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-4
                withdraw-proportional-liquidity pool-contract x-contract
                y-contract params-amount params-min-x-amount
                params-min-y-amount
            ))
            (ok true)
        )
    )
)
