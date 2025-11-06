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
        ;; repay aeusdc with STX collateral
        (try! (contract-call? asset transfer amount receiver (as-contract tx-sender) none))
        (as-contract 
            (try!
                (contract-call?
                    ;; 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.borrow-helper-v2-1-0
                    'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.borrow-helper-v2-1-3
                    liquidation-call
                    ;; assets
                    assets-mainnet
                    'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zwstx-v2-0
                    'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.wstx
                    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
                    ;; switch for stx-btc-oracle-v1
                    ;; 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.stx-oracle-v1-0
                    'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.stx-btc-oracle-v1
                    'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.aeusdc-oracle-v1-0
                    (var-get liquidated-user)
                    amount
                    false
                    (some
                        0x504e41550100000003b801000000040d005fef5c5eb23d0b65282ceec67c45ea6384ba9d3e44e352773207b7d86644a2f10d82a6931eeaed59cef027e2fdb7d6b9bd3d9de5182a08dba5637db4d3a3f97301033760cffae03ce0add19ab0e3086350e381cb1ec9a13ee617a4fc1362272bff315d2e39af0ff9a845aa4ee3041e159a3b3e9e1f839b56deb7e733b83d2088488c0004389ccb5473ab97666d22f5dcb215d946a935e48c78ed0bb12bb06282a083f9a70cb7faf1ed0c19e957805aa6b0e0dc5430fc8eb4d8ca10b7a5ed2cd5fe778c6e0006045946d87920d6c65788f84dc4dfb437873e5c7f869acff67675473efe3b8e357103b2290ba79d8c409078ddc161c73e4ccedaeb178d67e0d7df2cffac7ce35201087ee4a00444aafd6760eb33d61ee510948d1a71fabfed9e0e14b4c9bca6a70f687b61324570a1e1f0025ae211cb916e78d523566e6d1846b941cf24f003bb9abc000ad731edb000af1937d83af90d699a1612448a8891ca281cd33928080928cd9f3c6c05bd223d574d393b35a1848f8bc17d2d1299b849cdf7a14b347f7f039deda6010b3827819727a4736b27d7b8ae87a888b3ca913aba2d5b17f68dd0e66083dde5a20752eaa4a4384c6de2dbcfa4d8818dff442dc134fd9fbe8b62a2c2cf5fa30ea5000c7179b471240d34ed50f09621f8071058a3499d694d3632774883502913d811161af463e4a16a4c3abb8334e91cd75f2c552e7df1e16712bc853f0355cd84e441000d45f5e30df29b5d0e374e543e54fc271e134453cb375b9b9dc45b89b00ecef7f121b014b2a1c8a2bfb1eef7648f78dc761332848d862676e124b8357ec349fe51010ed5ebdbce25c1bd15f94ee021d05b3a92c7f3ceda64c40e4a7b1bd89a8b79d631526f4927288fbb773cec3b77035fef2abaeed0a27ddb2eb99cf1db8b3ee304cd010feccc161e13c459355196b1a3ae8638ef1d9a59c50d0993da9afa4c5c847d5a2273744ab48ab2d0604693c3854fb1986b13fe758874b64f5d8ee8cf3264a6c5d50110ef17c33f9abffaf60ac970dadb472e19ea65b7468f01c6e17a309f4089db8a812ec72923bc2b5d2f6d668083506f872d404010d5cabe9e41b76461cc9b94ee160011f75041c10cf74c74289472a1050bde3f6d071eec75cc39443f2369315181c0f22e633106fe97d08e9d8fd4344aa436a6bcf6876cb4766ec1ad3dd01f48d6d304006826456e00000000001ae101faedac5851e32b9b23b5f9411a8c2bac4aae3ed4dd7b811dd1a72ea4aa710000000007e39958014155575600000000000cf117cf0000271063ff4081fff43abc63213c8cfa87f3a84569ffec02005500ec7a775f46379b5e943c3526b1c8d54cd49749176b0b98e02dde68d1bd335c1700000000055b302d0000000000022266fffffff8000000006826456e000000006826456e000000000558b41b00000000000203fa0c8b98fe53710e4e16f1196cb5ec5d88a1795347052185fd7c01a4ad56936b7c2db0718c1831ce635d29d4ef3a5d8aa359de1626695f309410e7fa25b198e062b2e5e64e985c9f11c7e52f85f2f6faa9c59bf59c36d2513181bd28025a8bab12c8ad56a416cec22ca64d795f29dfbea094052cab345621155449a16b92a769d8090032f39ed89b61c510c2a8de8c86c22c64bb95b3501af23f15bd3b2462776eb0456ff6cef987baee34b807b9fd0fffa64e31aa168e8b6a9c6ad8346dd34101519994523c50a1cf56e81638e268ccca27180812c1cadea12aed8f68a3538f6dea2870cfb03dfa6e24704e6a3c4a3f06a7005500e62df6c8b4a85fe1a67db44dc12de5db330f7ac66b72dc658afedf0f4a415b4300000961b27489ce000000010f3a80cefffffff8000000006826456e000000006826456e00000962e8e7082000000000df4abbc40c7272ae238e43abf428b9189dfe77ee8e6f384acefce1d42aed9566811525e6dd7127062daec11230ee431958c4e76987e8a51b463bd7fa683cd69be05369d2c2789006bd56a7901064d72b475f673475bb6977878d947a984ec011fc50e913bbc25a381f1fac36207a61654e83f833d1c431a3098d5b36cb49a16b92a769d8090032f39ed89b61c510c2a8de8c86c22c64bb95b3501af23f15bd3b2462776eb0456ff6cef987baee34b807b9fd0fffa64e31aa168e8b6a9c6ad8346dd34101519994523c50a1cf56e81638e268ccca27180812c1cadea12aed8f68a3538f6dea2870cfb03dfa6e24704e6a3c4a3f06a7
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


