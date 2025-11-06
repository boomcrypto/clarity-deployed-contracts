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

(define-data-var sell (string-ascii 256) "stx")
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
            (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.borrow-helper-v2-1-3
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
                    0x504e41550100000003b801000000040d00a85a7e5478ecf3f03acec75e8352b4a560a1ade704ed494c68e8bcd0ae52c2196fee25f97593988138511a6c0cb85f061428b911a5288e487aa312e0df6df1da0102635603109ae35fcf4cb1c970df55a72693389a645c2979b05804b45da7e35600591ef0ab2235f5c256b83a09ea67539055308e1b0efb38675733ad688335f45a01039e52cd37f7a2751d16dcee0e25bd2f9ae86aa8588df74706cc91bad198ec623d2c84714e8157368767caa27cf8d8b084ef3c22302344ce3a8b002a60a64eb6410004c9dde6ed6cfd1003f20d865bcdc6d6fb079473b31c9ec6510fabbc9bd04dd97c7c701542e7bf1ee1a1fa8a64e306196e2fa592e8e11fe02cc8b422153f9e76a301067eb52e322976f8e9449958009e0c9593e21c4dc01eb5c5f1c341252b64735c3d24fda91fcfd9480e50533d42abb0e5dc44dbd50a38b255a3fdbf590c69e3e555000845e8c0fde824d2bfc976a4e69454b0da12579d9ff720cd8e5b444a1b9a20bc126330fd9174cfb3c71511e2dfb2a3895777673876b3654976b3ecd8af751a757a000aba66ba66b33e382f6fb7fd4ac251115cf241d13171689327e26eae22fb28b7841e3a916b294fceef2d0f098d7e5ad5e203714ce92d028b734dd07144de67ef5f000ba9a00ab3a63cbff6c37e8ad4c475e340aa3c5b091bb4d76ae7550fb6caac76045b34f7539c14ce0ad2defc7534edf15ea84c48544573d41035b2840ec6f7b1d5010c68ab3043bab73b6427371cf348df481dd7052f5e84e5eceaaa90e8a6698d658d3e8ef21d8adcccc34e3895a3d26c57f98aade8b1c1266f9daa1629d42ab61d17010d6dc1890238cff3e93747eb1a8681aef1ac6a64610d26c825a10473931a1b944f77dbe0532d4998dd7c6dbd6ed52728c7483a5bcfbef5a06d9fc7424017cc48f7000f445210d10c9027538d44bc2ef53dd61475d5e7b58a6cee2277b485062c7312f84f6bdc2c8609799f2be0b43b56a657407dc8bec9da3554091191f1c81fdbcd080010ede39e536dc52252c1771859ecd9198a33d07395a482f8a41abe7a738e432d7613dbf0f613ccb15d57689bfde92bcf5e6124e639af1516ebee0977d75885c9f80011d83906f44f133c54981cf64b4601620fe05eca9ef5b1117ca587d4f7bc6332ec37e4fe7637b0e94a0583bc8b27dd8315cd93b2abfd72b1a51c14175e21a6a71f016826424b00000000001ae101faedac5851e32b9b23b5f9411a8c2bac4aae3ed4dd7b811dd1a72ea4aa710000000007e391b7014155575600000000000cf1102e00002710c03253f4e8987ab9f061216b02ee145cbada317302005500ec7a775f46379b5e943c3526b1c8d54cd49749176b0b98e02dde68d1bd335c17000000000554f979000000000002149cfffffff8000000006826424b000000006826424a000000000559154000000000000205920c5f5f63e71d0b96d98497b28c4b8440f9140c4d644225551f1ff7812b84e2b01153ec7e210f9e21a0cac29a5114dddf7abd7d23541cbbea72ddf2959ccd709fee0a388e2b7b5c7483488158152ac96acc971118efddce0e77463fd53c7c9dee090f3b1cd6a2184de9ba0b02b3f2fd646ae991987ae86026033b43629e47ca4555e5cc0cb1183f7b0b2c2f501c27fc5b49bf6e6989f98130e8df35acb30ca2d31848a044402e8ede3b0c6d9266d64cb87c302b109900c502d6030c40ae7f2d50b164aef69cb81acf273693e4b51184f7e77c98983aac7a7338380ce7ee95592d352d9b15fb8d1848bd42a3416ec7a76b29005500e62df6c8b4a85fe1a67db44dc12de5db330f7ac66b72dc658afedf0f4a415b430000095f59cab53f00000000e1563cd1fffffff8000000006826424b000000006826424a00000963b44da64000000000e084ad4c0c919ff359f83208b32c5b131f1debed1c36ff73362643af28d553ae685441c7517d73546ae958ce3a90e36a14dc542a2c31c1b337096370bf252bddf5ef14e07026a904b925dd15f50f12e38789a774b8295d808745e48d725b6fc9ec93dda416a197a1e972da31515c5ed1682d00bacff755c70c64fc33553b43629e47ca4555e5cc0cb1183f7b0b2c2f501c27fc5b49bf6e6989f98130e8df35acb30ca2d31848a044402e8ede3b0c6d9266d64cb87c302b109900c502d6030c40ae7f2d50b164aef69cb81acf273693e4b51184f7e77c98983aac7a7338380ce7ee95592d352d9b15fb8d1848bd42a3416ec7a76b29
                )
            ))
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


