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
                        0x504e41550100000003b801000000040d0062da09cc6cdc2528482aba7b5be3d8af64612fd9fbb8cf111181373c064bcb7600b5945766bc6575d390028e0157d7be5198703a64cf5e6dd79cc7d2c0ced31f00029efe1719a15a1b95e531b84bfa95f2c1ce91c40394f2201214ec8416f8f884184a13141ee94a00220fa244421b469cfe24214fff8de5a7d0329a2ff197f515bd010367cc6b93d6e743db07ab89d7a0d03357d00e4b7986abafd46cb62c24fc3a82243e19d73c6ecb41c12847d3f59892a73da7a2f640c0733c285773a9021f2eae55000471d89de0e4d9b1b5d7de0733a21e82da8c6a2ba33651464486dcb71850ab68360ab6fabbc1a14c70f240ec7485eb3ac530e56b89568ad229bc7aaf97648dee470108368d39b5904c668d4f87eeaecd98626c4ffc178d0c71fe0dba317737363263ca334baaa49f796819cc09777e46472467b5fd2683486a2f8207a5485e1349178c010a1d78237566d8b48081a3e4a8636c0f1b0e5cd67368231fe194d65cb4947b16db319950cf65a313694d4b3d9d767484a5e166934661b5dd47da8d843aa670e083000bdbd06a90fcea6eee7ce788b8dc54b9a663407d378d3b0b9875685738f37b3d5e0c079d7852b96d00224f781535d8b72a2f3441125b865829e02639fac632664d010cf5043984a652c13c5cd12ebd138668b2a54d2f1b0d1dca1d1b4a6bd9d0d3574016e8037c91d41217051590fcaa108481c5cfe9b8bd8f5331e805a27b671a2389000d3dc992f8071d6d51e3bc123dfb3f65a55e3f7e45e6dc31d69ea0b7b0e11425d7498dffeff61a4838a22955c36a9a700787cfbe6fdaf95719941804be700cf6bb000e8b73d733febdc51fe9ffe3aa63d303b6f37f3563d1ac609ab8bdc1d714806e6842275d67d6892fe3a2ba9cf87d0d88019d36c09e0ed176b3c8054d7e7294caf6000f68b7d8cd9ddb5c50ed461216c9db813e093503f377d2b9fced2c9092036d1c487184c1f507640b5b208dc3597b3026c0be533b1a44846b0606e80d424eab3d0401101bb90160a4c1543cabc8b0c7912feebdc06c171dae0e15306515eaeb641c2c03682d56bea1c980ff093bfa111a78b2237f881077b2952784d312374d2a2191c80011e7db81adefee9660258103e5c6ad705ebc31f1fb1ad3b100397c6ac3b839760b2ad4c1764966267938b96d187d5e86b12b579da4ac152c5968145b46be568dea016826460200000000001ae101faedac5851e32b9b23b5f9411a8c2bac4aae3ed4dd7b811dd1a72ea4aa710000000007e39ac2014155575600000000000cf119390000271064266a096303d66c4157118d8acb9baeab82ee2f02005500ec7a775f46379b5e943c3526b1c8d54cd49749176b0b98e02dde68d1bd335c1700000000055ad3c4000000000001e822fffffff800000000682646020000000068264601000000000558c73500000000000204b00ce2292c2e24e34a6fd089b927fa48db74f189653e89adeebcf5b603628047e7c81c3c7e61764c733142ff7062d01e159b56ed935dfa79133b1633697fc2c30583d773fbc8574fa6d6478523d71bb335e06dcd42595254830e2c566c696bdf1ed23f9b4cd949f2e435d2734de095a936fa18fb0e900a1c9f1e6663df556f53fea2f2a3f46d14e599ddcb05a488d3c1515f8a52b6f7e465b0c40ef4796914b85a37b262355415e906ca1fcdf546c25bfedb9f289fb742cbf95e996a3955c3390bafe7beaeb67b987651f2c86e9a3bc926e0744f1434c1612ee5923a432b44dd3a0fd59ac740e31ca57540f39547622785f7005500e62df6c8b4a85fe1a67db44dc12de5db330f7ac66b72dc658afedf0f4a415b43000009628ec944c000000000c76022bdfffffff80000000068264602000000006826460100000962df0cc10000000000df6a5ab00ce832be126a72883fb190b71bf4ac75969f0e4052b06d861c80e9d9527b848ffd438bcf5aaec93a7f8bc58de7850941e59cff75dd02b25a4747acce81787515f117d0cdf14defbcfc58b46362cdf5617484228ff3e0979100682cb9119221f77fd531c743b7e37863cceaa4c72aebb3ca3e2abc351e76a59b6663df556f53fea2f2a3f46d14e599ddcb05a488d3c1515f8a52b6f7e465b0c40ef4796914b85a37b262355415e906ca1fcdf546c25bfedb9f289fb742cbf95e996a3955c3390bafe7beaeb67b987651f2c86e9a3bc926e0744f1434c1612ee5923a432b44dd3a0fd59ac740e31ca57540f39547622785f7
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


