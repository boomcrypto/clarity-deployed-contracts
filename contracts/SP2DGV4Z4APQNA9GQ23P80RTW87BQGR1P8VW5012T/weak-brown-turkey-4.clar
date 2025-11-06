(use-trait ft-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.sip-010-trait-ft-standard-v-1-1.sip-010-trait)

(use-trait alex-ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(use-trait flash-ft-trait 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.ft-trait.ft-trait)


(use-trait xyk-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-trait-v-1-2.xyk-pool-trait)
(use-trait stableswap-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-trait-v-1-2.stableswap-pool-trait)

(impl-trait 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.flash-loan-trait.flash-loan-trait)


(define-constant deployer tx-sender)

(define-constant xyk-pool-stx-aeusdc 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-stx-aeusdc-v-1-2)

(define-constant stableswap-pool-aeusdc-usdh 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-aeusdc-usdh-v-1-2)


(define-constant token-stx 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2)
(define-constant token-ststx 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
(define-constant token-aeusdc 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)
(define-constant token-usdh 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1)

(define-constant assets (list
                        ;; (tuple
                        ;;     (asset 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
                        ;;     (lp-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-v2-0)
                        ;;     (oracle 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.stx-btc-oracle-v1))
                        (tuple
                            (asset 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)
                            (lp-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zaeusdc-v2-0)
                            (oracle 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.aeusdc-oracle-v1-0))
                        ;; (tuple
                        ;;     (asset 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.wstx)
                        ;;     (lp-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zwstx-v2-0)
                        ;;     (oracle 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.stx-btc-oracle-v1))
                        (tuple
                            (asset 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token)
                            (lp-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zdiko-v2-0)
                            (oracle 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.diko-oracle-v1-1))
                        (tuple
                            (asset 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1)
                            (lp-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusdh-v2-0)
                            (oracle 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.usdh-oracle-v1-0))
                        (tuple
                            (asset 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt)
                            (lp-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsusdt-v2-0)
                            (oracle 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.susdt-oracle-v1-0))
                        (tuple
                            (asset 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token)
                            (lp-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusda-v2-0)
                            (oracle 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.usda-oracle-v1-1))
                        ;; (tuple
                        ;;     (asset 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)
                        ;;     (lp-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsbtc-v2-0)
                        ;;     (oracle 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.stx-btc-oracle-v1))
                        ;; (tuple
                        ;;     (asset 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token)
                        ;;     (lp-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststxbtc-v2-0)
                        ;;     (oracle 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.stx-btc-oracle-v1))
                        (tuple
                            (asset 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex)
                            (lp-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zalex-v2-0)
                            (oracle 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.alex-oracle-v1-0))
                ))


(define-data-var swap-contract (string-ascii 256) "flash-loan-swap-v-1-1")
(define-data-var swap-function (string-ascii 256) "swap-helper-a")

(define-data-var sell (string-ascii 256) "stx")
(define-data-var buy (string-ascii 256) "aeusdc")

(define-data-var liquidated-user principal tx-sender)

(define-data-var bps uint u400)

(define-data-var router-xyk-stx-ststx-params
    {
        amount: uint,
        bps: uint,
        swap-reversed: bool,
        xyk-tokens: (tuple (a principal) (b principal)),
        xyk-pools: (tuple (a principal)),
        stx-ststx-tokens: (tuple (a principal) (b principal))
    }
    {
        amount: u0,
        bps: u400,
        swap-reversed: false,
        xyk-tokens: (tuple (a token-stx) (b token-stx)),
        xyk-pools: (tuple (a xyk-pool-stx-aeusdc)),
        stx-ststx-tokens: (tuple (a token-stx) (b token-stx))
    }
)

(define-public (execute (asset <flash-ft-trait>) (receiver principal) (amount uint))
    (begin
        (asserts! (is-eq tx-sender deployer) (err u123))
        ;; repay aeusdc with STX collateral
        (try! (contract-call? asset transfer amount receiver (as-contract tx-sender) none))
        ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-1
        ;;     liquidation-call
        ;;     assets
        ;;     'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zwstx-v2-0
        ;;     'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.wstx
        ;;     'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zaeusdc-v2-0
        ;;     ;; switch for stx-btc-oracle-v1
        ;;     'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.stx-oracle-v1-0
        ;;     ;; 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.stx-btc-oracle-v1
        ;;     'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.aeusdc-oracle-v1-0
        ;;     (var-get liquidated-user)
        ;;     amount
        ;;     false
        ;; ))
        (as-contract (try! (swap asset receiver amount)))
        (ok true)
    )
)


(define-private (swap (asset <flash-ft-trait>) (receiver principal) (amount uint))
    (begin
        (if (is-eq (var-get sell) "stx")
            (begin
                (if (is-eq (var-get buy) "aeusdc")
                    (let (
                        (result (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2
                                swap-x-for-y
                                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-stx-aeusdc-v-1-2
                                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
                                'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
                                amount
                                (/ (* amount (var-get bps)) u10000)))))
                        (as-contract (try! (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc transfer result tx-sender receiver none)))
                        (ok true)
                    )
                    (if (is-eq (var-get buy) "usdh")
                        (begin
                            (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-xyk-stableswap-v-1-1
                                swap-helper-a
                                amount
                                (/ (* amount (var-get bps)) u10000)
                                false
                                (tuple (a token-stx) (b token-aeusdc))
                                (tuple (a xyk-pool-stx-aeusdc))
                                (tuple (a token-aeusdc) (b token-usdh))
                                (tuple (a stableswap-pool-aeusdc-usdh))
                            ))
                            (ok true)
                        )
                        (if (is-eq (var-get buy) "usda")
                            (begin
                                (try! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.wrapper-arkadiko-v-1-1
                                    swap-x-for-y
                                    'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
                                    'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
                                    amount
                                    (/ (* amount (var-get bps)) u10000)
                                ))
                                (ok true)
                            )
                            (ok false)
                        )
                    )
                )
            )
            (ok false)
        )
    )
)

(define-read-only (find-pool (pool principal))
    (begin
        (if (is-eq pool xyk-pool-stx-aeusdc)
            'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-stx-aeusdc-v-1-2
            'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
        )
    )
)

(define-read-only (find-token (token principal))
    (begin
        (if (is-eq token token-stx)
            'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
            (if (is-eq token token-ststx)
                'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                (if (is-eq token token-aeusdc)
                    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
                    'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
                )
            )
        )
    )
)


(define-private (call-wrapper-alex
    (wrapper-alex (tuple
    (token-x-trait <alex-ft-trait>) (token-y-trait <alex-ft-trait>)
    (token-z-trait <alex-ft-trait>) (token-w-trait <alex-ft-trait>)
    (token-v-trait <alex-ft-trait>)
    (factor-x uint) (factor-y uint) (factor-z uint) (factor-w uint)
    (amount uint) (min (optional uint))
    (type (string-ascii 1))))
)
    (begin
        (if (is-eq (get type wrapper-alex) "_")
            (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.wrapper-alex-v-2-1
                swap-helper
                (get token-x-trait wrapper-alex)
                (get token-y-trait wrapper-alex)
                (get factor-x wrapper-alex)
                (get amount wrapper-alex)
                (get min wrapper-alex)
            )
            (if (is-eq (get type wrapper-alex) "a")
                (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.wrapper-alex-v-2-1
                    swap-helper-a
                    (get token-x-trait wrapper-alex)
                    (get token-y-trait wrapper-alex)
                    (get token-z-trait wrapper-alex)
                    (get factor-x wrapper-alex)
                    (get factor-y wrapper-alex)
                    (get amount wrapper-alex)
                    (get min wrapper-alex)
                )
                (if (is-eq (get type wrapper-alex) "b")
                    (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.wrapper-alex-v-2-1
                        swap-helper-b
                        (get token-x-trait wrapper-alex)
                        (get token-y-trait wrapper-alex)
                        (get token-z-trait wrapper-alex)
                        (get token-w-trait wrapper-alex)
                        (get factor-x wrapper-alex)
                        (get factor-y wrapper-alex)
                        (get factor-z wrapper-alex)
                        (get amount wrapper-alex)
                        (get min wrapper-alex)
                    )
                    (if (is-eq (get type wrapper-alex) "c")
                        (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.wrapper-alex-v-2-1
                            swap-helper-c
                            (get token-x-trait wrapper-alex)
                            (get token-y-trait wrapper-alex)
                            (get token-z-trait wrapper-alex)
                            (get token-w-trait wrapper-alex)
                            (get token-v-trait wrapper-alex)
                            (get factor-x wrapper-alex)
                            (get factor-y wrapper-alex)
                            (get factor-z wrapper-alex)
                            (get factor-w wrapper-alex)
                            (get amount wrapper-alex)
                            (get min wrapper-alex)
                        )
                        (ok u0)
                    )
                )
            )
        )
    )
)


(define-private (call-router-xyk-stx-ststx
    (router-xyk-stx-ststx (tuple    
        (amount uint) (min-received uint)
        (swaps-reversed bool)
        (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
        (xyk-pools (tuple (a <xyk-pool-trait>)))
        (stx-ststx-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
        ))
    )
    (begin
        (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-xyk-stx-ststx-v-1-1
            swap-helper-a
            (get amount router-xyk-stx-ststx)
            (get min-received router-xyk-stx-ststx)
            (get swaps-reversed router-xyk-stx-ststx)
            (get xyk-tokens router-xyk-stx-ststx)
            (get xyk-pools router-xyk-stx-ststx)
            (get stx-ststx-tokens router-xyk-stx-ststx)
        )
    )
)

(define-private (call-xyk-stableswap
    (xyk-stableswap (tuple
        (amount uint) (min-received uint)
        (swaps-reversed bool)
        (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
        (xyk-pools (tuple (a <xyk-pool-trait>)))
        (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
        (stableswap-pools (tuple (a <stableswap-pool-trait>))))))
    (begin
        (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-xyk-stableswap-v-1-1
            swap-helper-a
            (get amount xyk-stableswap)
            (get min-received xyk-stableswap)
            (get swaps-reversed xyk-stableswap)
            (get xyk-tokens xyk-stableswap)
            (get xyk-pools xyk-stableswap)
            (get stableswap-tokens xyk-stableswap)
            (get stableswap-pools xyk-stableswap)
        )
    )
)

(define-private (call-wrapper-arkadiko
    (wrapper-arkadiko (tuple (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (amount uint) (min uint) (x-for-y bool)))
)
    (begin
        (if (get x-for-y wrapper-arkadiko)
            (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.wrapper-arkadiko-v-1-1
                swap-x-for-y
                (get token-x-trait wrapper-arkadiko)
                (get token-y-trait wrapper-arkadiko)
                (get amount wrapper-arkadiko)
                (get min wrapper-arkadiko)
            )
            (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.wrapper-arkadiko-v-1-1
                swap-y-for-x
                (get token-x-trait wrapper-arkadiko)
                (get token-y-trait wrapper-arkadiko)
                (get amount wrapper-arkadiko)
                (get min wrapper-arkadiko)
            )
        )
    )
)

(define-private (call-xyk-core
    (xyk-core
        (tuple
            (pool-trait <xyk-pool-trait>)
            (x-token-trait <ft-trait>) (y-token-trait <ft-trait>)
            (amount uint) (min uint)
            (x-for-y bool)
        )
    ))
    (begin
        (if (get x-for-y xyk-core)
            (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2
                swap-x-for-y
                (get pool-trait xyk-core)
                (get x-token-trait xyk-core)
                (get y-token-trait xyk-core)
                (get amount xyk-core)
                (get min xyk-core)
            )
            (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2
                swap-y-for-x
                (get pool-trait xyk-core)
                (get x-token-trait xyk-core)
                (get y-token-trait xyk-core)
                (get amount xyk-core)
                (get min xyk-core)
            )
        )
    )
)


(define-private (call-xyk-swap-helper
    (xtk-swap-helper
        (tuple
            (amount uint) (min-received uint)
            (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>) (g <ft-trait>) (h <ft-trait>) (i <ft-trait>) (j <ft-trait>)))
            (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>) (c <xyk-pool-trait>) (d <xyk-pool-trait>) (e <xyk-pool-trait>)))
            (swaps uint)
        )
    )
    )
    (let (
        (xyk-tokens (get xyk-tokens xtk-swap-helper))
        (xyk-pools (get xyk-pools xtk-swap-helper))
    )
        ;; swap 1
        (if (is-eq (get swaps xtk-swap-helper) u1)
            (begin
                (contract-call?
                    'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2
                    swap-helper-a
                    (get amount xtk-swap-helper)
                    (get min-received xtk-swap-helper)
                    { a: (get a xyk-tokens), b: (get b xyk-tokens) }
                    { a: (get a xyk-pools) }
                )
            )
            ;; swap 2
            (if (is-eq (get swaps xtk-swap-helper) u2)
                (begin
                    (contract-call?
                        'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2
                        swap-helper-b
                        (get amount xtk-swap-helper)
                        (get min-received xtk-swap-helper)
                        { a: (get a xyk-tokens), b: (get b xyk-tokens), c: (get c xyk-tokens), d: (get d xyk-tokens) }
                        { a: (get a xyk-pools), b: (get b xyk-pools) }
                    )
                )
                (if (is-eq (get swaps xtk-swap-helper) u3)
                    (begin
                        (contract-call?
                            'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2
                            swap-helper-c
                            (get amount xtk-swap-helper)
                            (get min-received xtk-swap-helper)
                            { a: (get a xyk-tokens), b: (get b xyk-tokens), c: (get c xyk-tokens), d: (get d xyk-tokens), e: (get e xyk-tokens), f: (get f xyk-tokens) }
                            { a: (get a xyk-pools), b: (get b xyk-pools), c: (get c xyk-pools) }
                        )
                    )
                    (if (is-eq (get swaps xtk-swap-helper) u4)
                        (begin
                            (contract-call?
                                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2
                                swap-helper-d
                                (get amount xtk-swap-helper)
                                (get min-received xtk-swap-helper)
                                { a: (get a xyk-tokens), b: (get b xyk-tokens), c: (get c xyk-tokens), d: (get d xyk-tokens), e: (get e xyk-tokens), f: (get f xyk-tokens), g: (get g xyk-tokens), h: (get h xyk-tokens) }
                                { a: (get a xyk-pools), b: (get b xyk-pools), c: (get c xyk-pools), d: (get d xyk-pools) }
                            )
                        )    
                        (if (is-eq (get swaps xtk-swap-helper) u5)
                            (begin
                                (contract-call?
                                    'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2
                                    swap-helper-e
                                    (get amount xtk-swap-helper)
                                    (get min-received xtk-swap-helper)
                                    xyk-tokens
                                    xyk-pools
                                )
                            )
                            (ok u0)
                        )
                    )
                )
            )
        )
    )
)


