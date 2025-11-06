(use-trait ft-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.sip-010-trait-ft-standard-v-1-1.sip-010-trait)
(use-trait flash-ft-trait 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.ft-trait.ft-trait)


(define-constant deployer tx-sender)

(define-data-var request
    {
        price-feed: (optional (buff 8192)),
        usdh-requested: uint
    }
    {
        price-feed: none,
        usdh-requested: u0,
    }
)

(define-public (set-params
    (price-feed (optional (buff 8192)))
    (usdh-requested uint))
    (begin
        (asserts! (is-eq tx-sender deployer) (err u401))

        (var-set request
            {
                price-feed: price-feed,
                usdh-requested: usdh-requested
            }
        )
        (ok true)
    )
)

(define-public (execute (asset <flash-ft-trait>) (receiver principal) (amount uint))
    (begin
        (asserts! (is-eq tx-sender deployer) (err u401))

        (try! (contract-call? asset transfer amount receiver (as-contract tx-sender) none))
        (try! (stx-transfer? u1 tx-sender (as-contract tx-sender)))
        (as-contract
            (try!
                (contract-call? 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.minting-auto-v1
                    mint
                    'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
                    (get usdh-requested (var-get request))
                    u500
                    none
                    (get price-feed (var-get request))
                    {
                        pyth-decoder-contract: 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-pnau-decoder-v2,
                        pyth-storage-contract: 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-storage-v3,
                        wormhole-core-contract: 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.wormhole-core-v3
                    }
                )
            )
        )
        (ok true)
    )
)
