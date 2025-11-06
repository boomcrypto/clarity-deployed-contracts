(impl-trait 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.flash-loan-trait.flash-loan-trait)
(use-trait flash-ft-trait 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.ft-trait.ft-trait)

(define-constant deployer tx-sender)

(define-data-var bps uint u400)

(define-public (set-bps (new-bps uint))
    (begin
        (asserts! (is-eq tx-sender deployer) (err u401))
        (ok (var-set bps new-bps))
    )
)

(define-public (execute (asset <flash-ft-trait>) (receiver principal) (amount uint))
    (begin
        (try! (swap asset receiver amount))
        (ok true)
    )
)

(define-private (swap (asset <flash-ft-trait>) (receiver principal) (amount uint))
    (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stableswap-xyk-multihop-v-1-4
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
