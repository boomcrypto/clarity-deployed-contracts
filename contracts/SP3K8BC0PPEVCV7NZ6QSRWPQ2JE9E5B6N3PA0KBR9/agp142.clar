(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 u100000000)
(define-constant address-44 'SP3NCDQN5EEP6GA7M2KD8QNZC6CKAK980N4PAXXGG)
(define-constant name-44 "Catcher Venture Capital Limited")
(define-constant schedule-44 (list
{ vesting-id: u1, vesting-timestamp: u1667174400, amount: u3537025000000 }
{ vesting-id: u2, vesting-timestamp: u1669766400, amount: u3537025000000 }
{ vesting-id: u3, vesting-timestamp: u1672444800, amount: u3537025000000 }
{ vesting-id: u4, vesting-timestamp: u1675123200, amount: u3537025000000 }
{ vesting-id: u5, vesting-timestamp: u1677542400, amount: u5305537500000 }
{ vesting-id: u6, vesting-timestamp: u1680220800, amount: u5305537500000 }
{ vesting-id: u7, vesting-timestamp: u1682812800, amount: u1768512500000 }
{ vesting-id: u8, vesting-timestamp: u1685491200, amount: u1768512500000 }
{ vesting-id: u9, vesting-timestamp: u1688083200, amount: u1768512500000 }
{ vesting-id: u10, vesting-timestamp: u1690761600, amount: u1768512500000 }
{ vesting-id: u11, vesting-timestamp: u1693440000, amount: u1768512500000 }
{ vesting-id: u12, vesting-timestamp: u1696032000, amount: u1768512500000 }
{ vesting-id: u13, vesting-timestamp: u1698710400, amount: u1768512500000 }
{ vesting-id: u14, vesting-timestamp: u1701302400, amount: u1768512500000 }
{ vesting-id: u15, vesting-timestamp: u1703980800, amount: u1768512500000 }
{ vesting-id: u16, vesting-timestamp: u1706659200, amount: u1768512500000 }
{ vesting-id: u17, vesting-timestamp: u1709164800, amount: u1768512500000 }
{ vesting-id: u18, vesting-timestamp: u1711843200, amount: u1768512500000 }
{ vesting-id: u19, vesting-timestamp: u1714435200, amount: u1768512500000 }
{ vesting-id: u20, vesting-timestamp: u1717113600, amount: u1768512500000 }
{ vesting-id: u21, vesting-timestamp: u1719705600, amount: u1768512500000 }
{ vesting-id: u22, vesting-timestamp: u1722384000, amount: u1768512500000 }
{ vesting-id: u23, vesting-timestamp: u1725062400, amount: u1768512500000 }
{ vesting-id: u24, vesting-timestamp: u1727654400, amount: u1768512500000 }
{ vesting-id: u25, vesting-timestamp: u1730332800, amount: u1768512500000 }
{ vesting-id: u26, vesting-timestamp: u1732924800, amount: u1768512500000 }
{ vesting-id: u27, vesting-timestamp: u1735603200, amount: u1768512500000 }
{ vesting-id: u28, vesting-timestamp: u1738281600, amount: u1768512500000 }
{ vesting-id: u29, vesting-timestamp: u1740700800, amount: u1768512500000 }
{ vesting-id: u30, vesting-timestamp: u1743379200, amount: u1768512500000 }
{ vesting-id: u31, vesting-timestamp: u1745971200, amount: u1768512500000 }
{ vesting-id: u32, vesting-timestamp: u1748649600, amount: u1768512500000 }
{ vesting-id: u33, vesting-timestamp: u1751241600, amount: u1768512500000 }
{ vesting-id: u34, vesting-timestamp: u1753920000, amount: u1768512500000 }
{ vesting-id: u35, vesting-timestamp: u1756598400, amount: u1768512500000 }
{ vesting-id: u36, vesting-timestamp: u1759190400, amount: u1768512500000 }
{ vesting-id: u37, vesting-timestamp: u1761868800, amount: u1768512500000 }
{ vesting-id: u38, vesting-timestamp: u1764460800, amount: u1768512500000 }
{ vesting-id: u39, vesting-timestamp: u1767139200, amount: u1768512500000 }
{ vesting-id: u40, vesting-timestamp: u1769817600, amount: u1768512500000 }
))
(define-public (execute (sender principal))
    (let 
        (
(recipient-44 (try! (contract-call? .age009-token-lock set-recipient address-44 name-44)))
(vesting-44 (generate-schedule-many recipient-44 schedule-44))
        )
(unwrap-panic (contract-call? .age009-token-lock set-vesting-schedule-many vesting-44))
        (ok true)
    )
)
(define-private (generate-schedule-iter (recipient-id uint) (item { vesting-id: uint, vesting-timestamp: uint, amount: uint }))
    { recipient-id: recipient-id, vesting-id: (get vesting-id item), vesting-timestamp: (get vesting-timestamp item), amount: (get amount item) }
)
(define-private (generate-schedule-many (recipient-id uint) (items (list 50 { vesting-id: uint, vesting-timestamp: uint, amount: uint })))
    (map generate-schedule-iter 
        (list 
            recipient-id	recipient-id	recipient-id	recipient-id	recipient-id	recipient-id	recipient-id	recipient-id	recipient-id	recipient-id
            recipient-id	recipient-id	recipient-id	recipient-id	recipient-id	recipient-id	recipient-id	recipient-id	recipient-id	recipient-id
            recipient-id	recipient-id	recipient-id	recipient-id	recipient-id	recipient-id	recipient-id	recipient-id	recipient-id	recipient-id
            recipient-id	recipient-id	recipient-id	recipient-id	recipient-id	recipient-id	recipient-id	recipient-id	recipient-id	recipient-id
            recipient-id	recipient-id	recipient-id	recipient-id	recipient-id	recipient-id	recipient-id	recipient-id	recipient-id	recipient-id
        )
        items
    )
)