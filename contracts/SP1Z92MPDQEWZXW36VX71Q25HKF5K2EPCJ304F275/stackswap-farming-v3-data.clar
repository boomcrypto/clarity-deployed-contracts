(use-trait liquidity-token .liquidity-token-trait-v4c.liquidity-token-trait)
(define-constant ERR_PERMISSION_DENIED u4305)
(define-data-var logic-contract principal .stackswap-farming-v3-logic)
(define-public (change-logic (new-contract principal)) (begin (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "farmingv3-update"))) (err ERR_PERMISSION_DENIED)) (var-set logic-contract new-contract) (ok true)))

(define-map Group
    uint ;;group
    {
        CurRewardAmt: uint,
    }
)
(define-read-only (getGroupOrDefault (group uint)) (default-to {CurRewardAmt: u0} (map-get? Group group)))
(define-public (setGroup (group uint) (data {CurRewardAmt: uint}))
    (begin 
        (asserts! (is-eq contract-caller (var-get logic-contract)) (err ERR_PERMISSION_DENIED)) 
        (ok (map-set Group group data))
    )
)
(define-public (deleteGroup (group uint)) 
    (begin 
        (asserts! (is-eq contract-caller (var-get logic-contract)) (err ERR_PERMISSION_DENIED))
        (ok (map-delete Group group))
    )
)

(define-map LP
    principal ;;LP
    {
        Group: uint,
        CurWeight: uint,
        QuoteSide: bool,
        QuoteToken: (string-ascii 12),
    }
)
(define-read-only (getLPOrDefault (lp principal)) 
    (default-to     
    {
        Group: u0,
        CurWeight: u0,
        QuoteSide: false,
        QuoteToken: "",
    } (map-get? LP lp)))
(define-public (setLP (lp principal) (data {
        Group: uint,
        CurWeight: uint,
        QuoteSide: bool,
        QuoteToken: (string-ascii 12),
    }))
    (begin 
        (asserts! (is-eq contract-caller (var-get logic-contract)) (err ERR_PERMISSION_DENIED)) 
        (ok (map-set LP lp data))
    )
)
(define-public (deleteLP (lp principal)) 
    (begin 
        (asserts! (is-eq contract-caller (var-get logic-contract)) (err ERR_PERMISSION_DENIED))
        (ok (map-delete LP lp))
    )
)

(define-map GroupHistory
    {
        group: uint,
        round: uint,
    }
    {
        GroupWeightedTVL: uint,
        GroupRewardAmt: uint,
    }
)
(define-read-only (getGroupHistoryOrDefault (group uint) (round uint)) 
    (default-to     
    {
        GroupWeightedTVL: u0,
        GroupRewardAmt: u0,
    } (map-get? GroupHistory {group: group, round: round})))
(define-public (setGroupHistory (group uint) (round uint) (data {
        GroupWeightedTVL: uint,
        GroupRewardAmt: uint,
    }))
    (begin 
        (asserts! (is-eq contract-caller (var-get logic-contract)) (err ERR_PERMISSION_DENIED)) 
        (ok (map-set GroupHistory {group: group, round: round} data))
    )
)
(define-public (deleteGroupHistory (group uint) (round uint)) 
    (begin 
        (asserts! (is-eq contract-caller (var-get logic-contract)) (err ERR_PERMISSION_DENIED))
        (ok (map-delete GroupHistory {group: group, round: round}))
    )
)

(define-map LPHistory
    {
        lp: principal,
        round: uint,
    }
    {
        LockedAmt: uint,
        NextWithdrawAmt: uint,
        NextDepositAmt: uint,
        Price: uint,
        Weight: uint,
        WeightedTVL: uint,
    }
)
(define-read-only (getLPHistoryOrDefault (lp principal) (round uint))
    (default-to 
        (if (>= round u1)
            (let (
                (lpHistoryExRound 
                    (default-to     
                        {
                            LockedAmt: u0,
                            NextWithdrawAmt: u0,
                            NextDepositAmt: u0,
                            Price: u0,
                            Weight: u0,
                            WeightedTVL: u0,
                        } (map-get? LPHistory {lp: lp, round: (- round u1)}))))
                {
                    LockedAmt: (- (+ (get LockedAmt lpHistoryExRound) (get NextDepositAmt lpHistoryExRound)) (get NextWithdrawAmt lpHistoryExRound)),
                    NextWithdrawAmt: u0,
                    NextDepositAmt: u0,
                    Price: u0,
                    Weight: u0,
                    WeightedTVL: u0,
                }        
            )
            {
                LockedAmt: u0,
                NextWithdrawAmt: u0,
                NextDepositAmt: u0,
                Price: u0,
                Weight: u0,
                WeightedTVL: u0,
            }
        )
        (map-get? LPHistory {lp: lp, round: round})
    )
)
(define-public (setLPHistory (lp principal) (round uint) (data {
        LockedAmt: uint,
        NextWithdrawAmt: uint,
        NextDepositAmt: uint,
        Price: uint,
        Weight: uint,
        WeightedTVL: uint,
    }))
    (begin 
        (asserts! (is-eq contract-caller (var-get logic-contract)) (err ERR_PERMISSION_DENIED)) 
        (ok (map-set LPHistory {lp: lp, round: round} data))
    )
)
(define-public (deleteLPHistory (lp principal) (round uint)) 
    (begin 
        (asserts! (is-eq contract-caller (var-get logic-contract)) (err ERR_PERMISSION_DENIED))
        (ok (map-delete LPHistory {lp: lp, round: round}))
    )
)

(define-map LPUser
    {
        lp: principal,
        user: principal
    }
    {
        ViewAmt: uint,
        StakingLockedAmt: uint,
        StartRound: uint,
        StartRoundAmt: uint,
        WithdrawEndRound: uint,
        WithdrawAmt: uint,
    }
)
(define-read-only (getLPUserOrDefault (lp principal) (user principal)) 
    (default-to     
    {
        ViewAmt: u0,
        StakingLockedAmt: u0,
        StartRound: u0,
        StartRoundAmt: u0,
        WithdrawEndRound: u0,
        WithdrawAmt: u0,
    } (map-get? LPUser {lp: lp, user: user})))


(define-public (setLPUser (lp principal) (user principal) (data {
        ViewAmt: uint,
        StakingLockedAmt: uint,
        StartRound: uint,
        StartRoundAmt: uint,
        WithdrawEndRound: uint,
        WithdrawAmt: uint,
    }))
    (begin 
        (asserts! (is-eq contract-caller (var-get logic-contract)) (err ERR_PERMISSION_DENIED)) 
        (ok (map-set LPUser {lp: lp, user: user} data))
    )
)
(define-public (deleteLPUser (lp principal) (user principal)) 
    (begin 
        (asserts! (is-eq contract-caller (var-get logic-contract)) (err ERR_PERMISSION_DENIED))
        (ok (map-delete LPUser {lp: lp, user: user}))
    )
)

(define-private (is-dao (user principal)) 
    (ok (asserts! (is-eq user (contract-call? .stackswap-dao-v5k get-dao-owner)) (err ERR_PERMISSION_DENIED))))

(define-read-only (isFarmAvailable (pool principal)) (is-some (map-get? LP pool)))

(define-public (transferReward (user principal) (amount uint))
    (begin 
        (asserts! (is-eq contract-caller (var-get logic-contract)) (err ERR_PERMISSION_DENIED)) 
        (try! (as-contract (contract-call? .stsw-token-v4a transfer amount tx-sender user none))) 
        (ok true)
    )
)
(define-public (transferAsset (pool <liquidity-token>) (user principal) (amount uint)) 
    (begin 
        (asserts! (is-eq contract-caller (var-get logic-contract)) (err ERR_PERMISSION_DENIED)) 
        (try! (as-contract (contract-call? pool transfer amount tx-sender user none))) 
        (ok true))
)