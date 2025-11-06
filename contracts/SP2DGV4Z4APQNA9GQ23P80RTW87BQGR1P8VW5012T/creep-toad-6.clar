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

(define-constant assets (list))

(define-constant assets-mainnet (list
                        (tuple
                            (asset 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
                            (lp-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-v2-0)
                            (oracle 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.stx-btc-oracle-v1))
                        (tuple
                            (asset 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)
                            (lp-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zaeusdc-v2-0)
                            (oracle 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.aeusdc-oracle-v1-0))
                        (tuple
                            (asset 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.wstx)
                            (lp-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zwstx-v2-0)
                            (oracle 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.stx-btc-oracle-v1))
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
                        (tuple
                            (asset 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)
                            (lp-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsbtc-v2-0)
                            (oracle 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.stx-btc-oracle-v1))
                        (tuple
                            (asset 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token)
                            (lp-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststxbtc-v2-0)
                            (oracle 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.stx-btc-oracle-v1))
                        (tuple
                            (asset 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex)
                            (lp-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zalex-v2-0)
                            (oracle 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.alex-oracle-v1-0))
                ))


(define-data-var swap-contract (string-ascii 256) "flash-loan-swap-v-1-1")
(define-data-var swap-function (string-ascii 256) "swap-helper-a")

(define-data-var sell (string-ascii 256) "ststx")
(define-data-var buy (string-ascii 256) "aeusdc")

(define-data-var liquidated-user principal 'SP36A56G05V2SZ9PJ81PNZRY4TXT50ZTFNA19DTE2)

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
        ;; repay aeusdc with stSTX collateral
        (try! (contract-call? asset transfer amount receiver (as-contract tx-sender) none))
        (try! (stx-transfer? u2 tx-sender (as-contract tx-sender)))
        (as-contract
            (try!
                (contract-call?
                    ;; 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.borrow-helper-v2-1-0
                    'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.borrow-helper-v2-1-3
                    liquidation-call
                    ;; assets
                    assets-mainnet
                    'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-v2-0
                    'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
                    ;; switch for stx-btc-oracle-v1
                    ;; 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.stx-oracle-v1-0
                    'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.stx-btc-oracle-v1
                    'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.aeusdc-oracle-v1-0
                    (var-get liquidated-user)
                    amount
                    false
                    (some
                        0x504e41550100000003b801000000040d00713502cc85be5ff96d9532328bc5801993b74fbe9d6617031635d14a985f97d9241a2d2fb76ade39cd0e562e1ac4ea8e4613066e0852033644652a9ebfd7fd1d01014f768dab534c790eac64cb800db79302c78b425e65497cf8f866098af50ccbbb7d1e18066f364262a7667c91ac0c294f983579cd65cc3be0505678f67030d06e000357e9ace101fc9e24b917725f4830c3b2d62a92141c421e72bc7e6fe5ea6abbc3012b6cefa664447bd1e3513d1f992da4b6043f3bf3a2c940f1226bfec64ff8f20004742039414be2399c7036493761101621ca9ccd16bc5ef6247e7954837e704bd76b9913e68ffec78202e719c332cb1d8fae9fba4de7b0bfc9e694155074f2e665000661c9d3ecd3a7843fbe4bc4935cb20e87f333312f17888223a2b928f72acef9847222aad0e8106b093d1c94639ac7f7a85b501aba2c76287c487daee4f47fe6c3000a0f91ac6c181a58083692d3d76bbb4b6a32d36913b91e8e4bf61f17d755ab5d072618e962293ec8db1551802a7d774db977a672823e9b304aa13fe0b2bdd4aaa8010b6ec9b32ab5b692ff0af8dfccd34f375dd1880c7c47bd6f4c5681b5563cd9b45f2813f51c2509b62dc401e71d8ea3fcf640c162565627bd3d781329abd9b6930e010c8f3d9396d8666ea8135bf2e39fd9da3670f5a4b4ff460295208b402621fe0c023f6e06a9de4907a0cda1a621e26a081b0f20abdd67d244431a3269e6ac8a98be010de7d54c73c0483f3c9ec1de959c962a8414c2ce34db65f563f8b8035b4de72098553a6f5b8445fee6b58c789222419ed01ca8caf5dd12d6bf3108cc4d4463ccc2010e49908ac08d4c24e2ec8e82ee92870a212a945d5c9083361604fe14bbce2729df2291dde6bd789d45c3c34463a75191cdea4e31b39eed88ffdbc3e1163e357734000f3688e6e939a74b165ae92fb7747552ecae885efb498a97c0882d99c62e9a187f2001e5435f00f2dde30cbf26000f77b1eb997db50dd8579a13e6dca1495e26a00010ce59d28843f8778b6ca07754d65af3e2126dcb47bf1b2829d4ec3d8f15cdf8877ce4c65711b766e042711511ff8282d3bf849e292021d4f4bacb22ea206e3636001143f0a48e5d6d8006aa4acb956d3412e5ba86da954ff0b73a0f5942f2c9c54efe3729616684805bf11e1b7893e94e8ace1739063e09d260c1f02f374804c188c2016826479900000000001ae101faedac5851e32b9b23b5f9411a8c2bac4aae3ed4dd7b811dd1a72ea4aa710000000007e39e9e014155575600000000000cf11d1500002710be308c87cdef5b5ea19a2608bc3e7a726c93bf8f02005500ec7a775f46379b5e943c3526b1c8d54cd49749176b0b98e02dde68d1bd335c17000000000558ca7d000000000001b893fffffff800000000682647990000000068264799000000000558c3eb00000000000204610c3f52bf041b265deb64f58d054ca850732e9f60e3b5c44bca913260491fc4112247b7734af2ef89392a87d6262c1a5b81cac08dbf5ca51530ca57a113a90218325cf2aad05dde92c9c51df352eff2a679fa93d27b75b97682d8e9cb94c80b298a42282826036416a7cf6f89938160b5ad2ddb7b82e63b711091f0dc4dd9fd38c9c21096c46c8212d2d288c889bf0f1dd88c0f73bb3a7eba3f6d984ea4bb54a50077bdb230a126653cd3ded73bff61f2edd5ff60fcf819b74395a6ea0387d96ed7e83608ae534e0a51a88fdc763b6d5803248fda1ecb7b3fb2b68e931a671b483668950a6ccf02cd0a2ee98b8760114c86005500e62df6c8b4a85fe1a67db44dc12de5db330f7ac66b72dc658afedf0f4a415b43000009625ba7330b000000009c5d2accfffffff80000000068264799000000006826479900000962bc52fbc000000000e0eab6000c9e17b266adc2366c0acc9270728b2006d93beddad929ce2e7e66837a6647a6a0a607004d5b38e6f290023d12c69a5a92fac11f3ddbfc333eed5fb41983cb05377881c6a08e60fb787c2858d7cbf591cf87724bb97cd0bd1be78d26594e0d46b78d312331444a5dbeee0db00ec402b54f6ea2bec265f57d4491f0dc4dd9fd38c9c21096c46c8212d2d288c889bf0f1dd88c0f73bb3a7eba3f6d984ea4bb54a50077bdb230a126653cd3ded73bff61f2edd5ff60fcf819b74395a6ea0387d96ed7e83608ae534e0a51a88fdc763b6d5803248fda1ecb7b3fb2b68e931a671b483668950a6ccf02cd0a2ee98b8760114c86
                    )
                )
            )
        )
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
            (if (is-eq (var-get sell) "ststx")
                (if (is-eq (var-get buy) "aeusdc")
                        (let ((result (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stableswap-xyk-multihop-v-1-4
                            swap-helper-a
                            amount
                            (/ (* amount (var-get bps)) u10000)
                            false
                            {
                                a: 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token,
                                b: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
                            }
                            {
                                a: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-stx-ststx-v-1-4
                            }
                            {
                                a: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2,
                                b: 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
                            }
                            {
                                a: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-stx-aeusdc-v-1-2
                            }
                            )
                            )
                        ))
                        (ok true)
                        )
                    (ok false)
                )
                (ok false)
            )
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


