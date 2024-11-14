---
title: "Trait add-vesting-63"
draft: true
---
```
(impl-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.proposal-trait.proposal-trait)
(define-constant ONE_8 u100000000)
(define-constant address-63 'SP1KE61KVRMKSCZ48WHM5J2DQVXQRK7KESHFAB9AZ)
(define-constant name-63 "TM")
(define-constant schedule-63 (list
{ vesting-id: u1, vesting-timestamp: u1698796800, amount: u62500000000000 }
{ vesting-id: u2, vesting-timestamp: u1701388800, amount: u62500000000000 }
{ vesting-id: u3, vesting-timestamp: u1704067200, amount: u62500000000000 }
{ vesting-id: u4, vesting-timestamp: u1706745600, amount: u62500000000000 }
{ vesting-id: u5, vesting-timestamp: u1709251200, amount: u93750000000000 }
{ vesting-id: u6, vesting-timestamp: u1711929600, amount: u93750000000000 }
{ vesting-id: u7, vesting-timestamp: u1714521600, amount: u37500000000000 }
{ vesting-id: u8, vesting-timestamp: u1717200000, amount: u37500000000000 }
{ vesting-id: u9, vesting-timestamp: u1719792000, amount: u37500000000000 }
{ vesting-id: u10, vesting-timestamp: u1722470400, amount: u37500000000000 }
{ vesting-id: u11, vesting-timestamp: u1725148800, amount: u40625000000000 }
{ vesting-id: u12, vesting-timestamp: u1727740800, amount: u40625000000000 }
{ vesting-id: u13, vesting-timestamp: u1730419200, amount: u34375000000000 }
{ vesting-id: u14, vesting-timestamp: u1733011200, amount: u34375000000000 }
{ vesting-id: u15, vesting-timestamp: u1767225600, amount: u34375000000000 }
{ vesting-id: u16, vesting-timestamp: u1769904000, amount: u34375000000000 }
{ vesting-id: u17, vesting-timestamp: u1772323200, amount: u34375000000000 }
{ vesting-id: u18, vesting-timestamp: u1775001600, amount: u34375000000000 }
{ vesting-id: u19, vesting-timestamp: u1777593600, amount: u34375000000000 }
{ vesting-id: u20, vesting-timestamp: u1780272000, amount: u34375000000000 }
{ vesting-id: u21, vesting-timestamp: u1782864000, amount: u34375000000000 }
{ vesting-id: u22, vesting-timestamp: u1785542400, amount: u34375000000000 }
{ vesting-id: u23, vesting-timestamp: u1788220800, amount: u34375000000000 }
{ vesting-id: u24, vesting-timestamp: u1790812800, amount: u34375000000000 }
{ vesting-id: u25, vesting-timestamp: u1793491200, amount: u34375000000000 }
{ vesting-id: u26, vesting-timestamp: u1796083200, amount: u34375000000000 }
{ vesting-id: u27, vesting-timestamp: u1798761600, amount: u34375000000000 }
{ vesting-id: u28, vesting-timestamp: u1801440000, amount: u34375000000000 }
{ vesting-id: u29, vesting-timestamp: u1803859200, amount: u34375000000000 }
{ vesting-id: u30, vesting-timestamp: u1806537600, amount: u34375000000000 }
{ vesting-id: u31, vesting-timestamp: u1809129600, amount: u34375000000000 }
{ vesting-id: u32, vesting-timestamp: u1811808000, amount: u34375000000000 }
{ vesting-id: u33, vesting-timestamp: u1814400000, amount: u34375000000000 }
{ vesting-id: u34, vesting-timestamp: u1817078400, amount: u34375000000000 }
{ vesting-id: u35, vesting-timestamp: u1819756800, amount: u34375000000000 }
{ vesting-id: u36, vesting-timestamp: u1822348800, amount: u34375000000000 }
{ vesting-id: u37, vesting-timestamp: u1825027200, amount: u34375000000000 }
{ vesting-id: u38, vesting-timestamp: u1827619200, amount: u34375000000000 }
{ vesting-id: u39, vesting-timestamp: u1830297600, amount: u34375000000000 }
{ vesting-id: u40, vesting-timestamp: u1832976000, amount: u34375000000000 }
{ vesting-id: u41, vesting-timestamp: u1835481600, amount: u3125000000000 }
{ vesting-id: u42, vesting-timestamp: u1838160000, amount: u3125000000000 }
{ vesting-id: u43, vesting-timestamp: u1840752000, amount: u3125000000000 }
{ vesting-id: u44, vesting-timestamp: u1843430400, amount: u3125000000000 }
{ vesting-id: u45, vesting-timestamp: u1846022400, amount: u3125000000000 }
{ vesting-id: u46, vesting-timestamp: u1848700800, amount: u3125000000000 }
))
(define-public (execute (sender principal))
    (let 
        (
(recipient-63 (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age009-token-lock set-recipient address-63 name-63)))
(vesting-63 (generate-schedule-many recipient-63 schedule-63)))
(unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age009-token-lock set-vesting-schedule-many vesting-63))
(ok true)))
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
```
