
(define-constant one-12 u1000000000000)
(define-constant sats-to-precision u10000)

(define-constant deployer tx-sender)

(define-public (reclaim-btc (btcz-amount uint))
	(let (
		(sender contract-caller)
        (redeemable-btc (get-redeemable-btc-by-amount btcz-amount))
    )
		(try! (contract-call? .token-btc burn btcz-amount sender))
        (try!
            (as-contract
                (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer
                    redeemable-btc
                    tx-sender
                    sender
                    none
                )
            )
        )
		(ok redeemable-btc)
	)
)

(define-public (withdraw-sbtc
    (sbtc-amount uint)
    (receiver principal)
    )
    (begin
        (asserts! (is-eq tx-sender deployer) (err u401))
        (try!
            (as-contract
                (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer
                    sbtc-amount
                    tx-sender
                    receiver
                    none
                )
            )
        )
        (ok sbtc-amount)
    )
)

(define-read-only (get-redeemable-btc-by-amount (btcz-amount uint))
	(mul-btcz-with-ratio-to-sats btcz-amount one-12))

(define-read-only (mul-btcz-with-ratio-to-sats (btcz uint) (ratio uint))
	(/ (/ (* btcz ratio) one-12) sats-to-precision))
