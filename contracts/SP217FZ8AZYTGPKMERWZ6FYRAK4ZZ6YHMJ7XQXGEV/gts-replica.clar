(define-constant ERR-NOT-FOUND (err u801))
(define-constant ERR-NOT-AUTHORIZED (err u804))
(define-constant admin tx-sender)
(define-map address-checked principal bool)
(define-map id-checked uint bool)

(define-read-only (get-address-checked (address principal)) (default-to false (map-get? address-checked address)))
(define-read-only (get-id-checked (id uint)) (default-to false (map-get? id-checked id)))

(define-public (subscriptions-transfer (ids (list 1000 uint)))
    (ok (map subscription-transfer ids))
)

(define-private (subscription-transfer (id uint)) 
    (let (
        (subscriber (unwrap-panic (contract-call? 'SP1N057R0S5BBAQKTW0GF2J7BXKFHY2GQV9MP2BEN.bitcoin-goats-spoints-subscriber get-item-subscriber id)))
    )
    (asserts! (is-eq tx-sender admin) ERR-NOT-AUTHORIZED)
    (if (not (or (is-none subscriber) (get-id-checked id))) 
        (begin
            (try! (contract-call? .bitcoin-goats-spoints-subscriber admin-subscribe 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.goat-multipliers id (unwrap-panic subscriber))) 
            (map-set id-checked id true)
            (if (not (get-address-checked (unwrap-panic subscriber)))
                (begin  
                    (try! (contract-call? .bitcoin-goats-spoints-subscriber allocate-balance (unwrap-panic (contract-call? 'SP1N057R0S5BBAQKTW0GF2J7BXKFHY2GQV9MP2BEN.bitcoin-goats-spoints-subscriber get-collect (unwrap-panic subscriber))) (unwrap-panic subscriber)))
                    (map-set address-checked (unwrap-panic subscriber) true)
                    (ok true))
                (ok true)
            )
        ) 
        (ok true))))

(subscriptions-transfer (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40 u41 u42 u43 u44 u45 u46 u47 u48 u49 u50 u51 u52 u53 u54 u55 u56 u57 u58 u59 u60 u61 u62 u63 u64 u65 u66 u67 u68 u69 u70 u71 u72 u73 u74 u75 u76 u77 u78 u79 u80 u81 u82 u83 u84 u85 u86 u87 u88 u89 u90 u91 u92 u93 u94 u95 u96 u97 u98 u99 u100 u101 u102 u103 u104 u105 u106 u107 u108 u109 u110 u111 u112 u113 u114 u115 u116 u117 u118 u119 u120 u121 u122 u123 u124 u125 u126 u127 u128 u129 u130 u131 u132 u133 u134 u135 u136 u137 u138 u139 u140 u141 u142 u143 u144 u145 u146 u147 u148 u149 u150 u151 u152 u153 u154 u155 u156 u157 u158 u159 u160 u161 u162 u163 u164 u165 u166 u167 u168 u169 u170 u171 u172 u173 u174 u175 u176 u177 u178 u179 u180 u181 u182 u183 u184 u185 u186 u187 u188 u189 u190 u191 u192 u193 u194 u195 u196 u197 u198 u199 u200))