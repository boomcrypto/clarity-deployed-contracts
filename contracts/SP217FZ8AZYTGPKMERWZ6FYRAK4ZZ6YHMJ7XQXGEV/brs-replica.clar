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
        (subscriber (unwrap-panic (contract-call? 'SP1N057R0S5BBAQKTW0GF2J7BXKFHY2GQV9MP2BEN.bitcoin-bears-spoints-subscriber get-item-subscriber id)))
    )
    (asserts! (is-eq tx-sender admin) ERR-NOT-AUTHORIZED)
    (if (not (or (is-none subscriber) (get-id-checked id))) 
        (begin
            (try! (contract-call? .bitcoin-bears-spoints-subscriber admin-subscribe 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bear-multipliers id (unwrap-panic subscriber))) 
            (map-set id-checked id true)
            (if (not (get-address-checked (unwrap-panic subscriber)))
                (begin  
                    (try! (contract-call? .bitcoin-bears-spoints-subscriber allocate-balance (unwrap-panic (contract-call? 'SP1N057R0S5BBAQKTW0GF2J7BXKFHY2GQV9MP2BEN.bitcoin-bears-spoints-subscriber get-collect (unwrap-panic subscriber))) (unwrap-panic subscriber)))
                    (map-set address-checked (unwrap-panic subscriber) true)
                    (ok true))
                (ok true)
            )
        ) 
        (ok true))))

(subscriptions-transfer (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40 u41 u42 u43 u44 u45 u46 u47 u48 u49 u50 u51 u52 u53 u54 u55 u56 u57 u58 u59 u60 u61 u62 u63 u64 u65 u66 u67 u68 u69 u70 u71 u72 u73 u74 u75 u76 u77 u78 u79 u80 u81 u82 u83 u84 u85 u86 u87 u88 u89 u90 u91 u92 u93 u94 u95 u96 u97 u98 u99 u100 u101 u102 u103 u104 u105 u106 u107 u108 u109 u110 u111 u112 u113 u114 u115 u116 u117 u118 u119 u120 u121 u122 u123 u124 u125 u126 u127 u128 u129 u130 u131 u132 u133 u134 u135 u136 u137 u138 u139 u140 u141 u142 u143 u144 u145 u146 u147 u148 u149 u150 u151 u152 u153 u154 u155 u156 u157 u158 u159 u160 u161 u162 u163 u164 u165 u166 u167 u168 u169 u170 u171 u172 u173 u174 u175 u176 u177 u178 u179 u180 u181 u182 u183 u184 u185 u186 u187 u188 u189 u190 u191 u192 u193 u194 u195 u196 u197 u198 u199 u200 u201 u202 u203 u204 u205 u206 u207 u208 u209 u210 u211 u212 u213 u214 u215 u216 u217 u218 u219 u220 u221 u222 u223 u224 u225 u226 u227 u228 u229 u230 u231 u232 u233 u234 u235 u236 u237 u238 u239 u240 u241 u242 u243 u244 u245 u246 u247 u248 u249 u250 u251 u252 u253 u254 u255 u256 u257 u258 u259 u260 u261 u262 u263 u264 u265 u266 u267 u268 u269 u270 u271 u272 u273 u274 u275 u276 u277 u278 u279 u280 u281 u282 u283 u284 u285 u286 u287 u288 u289 u290 u291 u292 u293 u294 u295 u296 u297 u298 u299 u300 u301 u302 u303 u304 u305 u306 u307 u308 u309 u310 u311 u312 u313 u314 u315 u316 u317 u318 u319 u320 u321 u322 u323 u324 u325 u326 u327 u328 u329 u330 u331 u332 u333 u334 u335 u336 u337 u338 u339 u340 u341 u342 u343 u344 u345 u346 u347 u348 u349 u350 u351 u352 u353 u354 u355 u356 u357 u358 u359 u360 u361 u362 u363 u364 u365 u366 u367 u368 u369 u370 u371 u372 u373 u374 u375 u376 u377 u378 u379 u380 u381 u382 u383 u384 u385 u386 u387 u388 u389 u390 u391 u392 u393 u394 u395 u396 u397 u398 u399 u400))