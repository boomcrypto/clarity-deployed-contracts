---
title: "Trait ssgt9"
draft: true
---
```
;; Errors
(define-constant ERR_INVALID_BLOCK_HEIGHT u0)
(define-constant ERR_BET_TYPE u1)
(define-constant ERR_NOT_ENOUGH_BALANCE u2)
(define-constant ERR_EXPECT_PRICE_SHOULD_BE_MORE_THAN_0 u3)
(define-constant ERR_ALREADY_PARTICIPATED u4)
(define-constant ERR_TRANSFER_STX u5)
(define-constant ERR_NOT_BET_ON_DRAW_PERIOD u6)
(define-constant ERR_NOT_AUTHORIZED u7)
(define-constant ERR_NOT_INITIALIZED u8)
(define-constant ERR_NOT_INITIALIZED_SUMMARY u9)
(define-constant ERR_NOT_INITIALIZED_RECORD u10)
(define-constant ERR_LIMIT_BET_PLAYER u11)
(define-constant ERR_CLAIM_VIOLATION u12)
(define-constant ERR_NON_EXIST_RECORD u13)
(define-constant ERR_NON_EXIST_SUMMARY u14)
(define-constant ERR_SHOULD_CLAIM_BY_WINNER u15)
(define-constant ERR_BET_CORE_RUNTIME u16)


;; Global constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant FEE_WALLET 'ST1PQBH05EKJNMDDZAC19J9RQX4C45WVBK56DK9B1)
(define-constant BET_FEE u1)
(define-constant ROUND_LENGTH u50)
(define-constant PLAYER_LIMIT u500)
(define-constant BET_TYPE_1 u0)
(define-constant BET_TYPE_2 u1)
(define-constant BET_TYPE_3 u2)

(define-constant LIST_500
    (list 
    u0 u1 u2 u3 u4 u5 u6 u7 u8 u9
    u10 u11 u12 u13 u14 u15 u16 u17 u18 u19
    u20 u21 u22 u23 u24 u25 u26 u27 u28 u29
    u30 u31 u32 u33 u34 u35 u36 u37 u38 u39
    u40 u41 u42 u43 u44 u45 u46 u47 u48 u49
    u50 u51 u52 u53 u54 u55 u56 u57 u58 u59
    u60 u61 u62 u63 u64 u65 u66 u67 u68 u69
    u70 u71 u72 u73 u74 u75 u76 u77 u78 u79
    u80 u81 u82 u83 u84 u85 u86 u87 u88 u89
    u90 u91 u92 u93 u94 u95 u96 u97 u98 u99
    u100 u101 u102 u103 u104 u105 u106 u107 u108 u109
    u110 u111 u112 u113 u114 u115 u116 u117 u118 u119
    u120 u121 u122 u123 u124 u125 u126 u127 u128 u129
    u130 u131 u132 u133 u134 u135 u136 u137 u138 u139
    u140 u141 u142 u143 u144 u145 u146 u147 u148 u149
    u150 u151 u152 u153 u154 u155 u156 u157 u158 u159
    u160 u161 u162 u163 u164 u165 u166 u167 u168 u169
    u170 u171 u172 u173 u174 u175 u176 u177 u178 u179
    u180 u181 u182 u183 u184 u185 u186 u187 u188 u189
    u190 u191 u192 u193 u194 u195 u196 u197 u198 u199
    u200 u201 u202 u203 u204 u205 u206 u207 u208 u209
    u210 u211 u212 u213 u214 u215 u216 u217 u218 u219
    u220 u221 u222 u223 u224 u225 u226 u227 u228 u229
    u230 u231 u232 u233 u234 u235 u236 u237 u238 u239
    u240 u241 u242 u243 u244 u245 u246 u247 u248 u249
    u250 u251 u252 u253 u254 u255 u256 u257 u258 u259
    u260 u261 u262 u263 u264 u265 u266 u267 u268 u269
    u270 u271 u272 u273 u274 u275 u276 u277 u278 u279
    u280 u281 u282 u283 u284 u285 u286 u287 u288 u289
    u290 u291 u292 u293 u294 u295 u296 u297 u298 u299
    u300 u301 u302 u303 u304 u305 u306 u307 u308 u309
    u310 u311 u312 u313 u314 u315 u316 u317 u318 u319
    u320 u321 u322 u323 u324 u325 u326 u327 u328 u329
    u330 u331 u332 u333 u334 u335 u336 u337 u338 u339
    u340 u341 u342 u343 u344 u345 u346 u347 u348 u349
    u350 u351 u352 u353 u354 u355 u356 u357 u358 u359
    u360 u361 u362 u363 u364 u365 u366 u367 u368 u369
    u370 u371 u372 u373 u374 u375 u376 u377 u378 u379
    u380 u381 u382 u383 u384 u385 u386 u387 u388 u389
    u390 u391 u392 u393 u394 u395 u396 u397 u398 u399
    u400 u401 u402 u403 u404 u405 u406 u407 u408 u409
    u410 u411 u412 u413 u414 u415 u416 u417 u418 u419
    u420 u421 u422 u423 u424 u425 u426 u427 u428 u429
    u430 u431 u432 u433 u434 u435 u436 u437 u438 u439
    u440 u441 u442 u443 u444 u445 u446 u447 u448 u449
    u450 u451 u452 u453 u454 u455 u456 u457 u458 u459
    u460 u461 u462 u463 u464 u465 u466 u467 u468 u469
    u470 u471 u472 u473 u474 u475 u476 u477 u478 u479
    u480 u481 u482 u483 u484 u485 u486 u487 u488 u489
    u490 u491 u492 u493 u494 u495 u496 u497 u498 u499
    )
)

;; maps
(define-map bet-round-map
  uint ;; bet-type
  uint ;; round
)

(define-map bet-summary-map
  { bet-type: uint, round: uint }
  {
    start-at: uint,     
    end-at: uint,       
    end-time: uint,     
    player-num: uint,
    result-price: uint,
    bet-total: uint,
    min-predict: uint,
    max-predict: uint,
  }
)

(define-map bet-record-map
  { bet-type: uint, round: uint, index: uint } 
  {
    player: principal,
    bet-stx: uint,
    expect-price: uint,
    stacks-block: uint,
    winner: bool
  }
)

(define-map player-record-map
  { player: principal, bet-type: uint, round: uint } 
  {
    bet-stx: uint,
    expect-price: uint,
    winner: bool,
    claimed: bool
  }
)


(begin
    (map-set bet-round-map BET_TYPE_1 u1)
    (map-set bet-round-map BET_TYPE_2 u1)
    (map-set bet-round-map BET_TYPE_3 u1)
    (map-set bet-summary-map 
        { bet-type: u0, round: u1 }
        {
            start-at: u0,
            end-at: u0,       
            end-time: u0,     
            player-num: u0,
            result-price: u0,
            bet-total: u0,
            min-predict: u0,
            max-predict: u0,
        }
    )
    (map-set bet-summary-map 
        { bet-type: u1, round: u1 }
        {
            start-at: u0,
            end-at: u0,       
            end-time: u0,     
            player-num: u0,
            result-price: u0,
            bet-total: u0,
            min-predict: u0,
            max-predict: u0,
        }
    )
    (map-set bet-summary-map 
        { bet-type: u2, round: u1 }
        {
            start-at: u0,
            end-at: u0,       
            end-time: u0,     
            player-num: u0,
            result-price: u0,
            bet-total: u0,
            min-predict: u0,
            max-predict: u0,
        }
    )
)

(define-read-only (get-bet-round (bet-type uint)) 
    (map-get? bet-round-map bet-type)
)

(define-read-only (get-round-summary (bet-type uint) (round uint)) 
    (map-get? bet-summary-map { bet-type: bet-type, round: round})
)

(define-read-only (get-player-record (bet-type uint) (round uint) (account principal))
    (map-get? player-record-map { bet-type: bet-type, round: round, player: account})
)

(define-read-only (get-bet-record (bet-type uint) (round uint) (index uint))
    (map-get? bet-record-map { bet-type: bet-type, round: round, index: index})
)

(define-private (go-next-round (bet-type uint)) 
    (let
        (
            (cur-round (unwrap-panic (map-get? bet-round-map bet-type))) 
            (next-round (+ cur-round u1))
            (bet-summary-tuple (unwrap-panic (map-get? bet-summary-map { bet-type: bet-type, round: cur-round })))
        )

        (map-set bet-round-map bet-type next-round)
        (map-set bet-summary-map 
            { bet-type: bet-type, round: next-round} 
            {
                start-at: u0, 
                end-at: u0,       
                end-time: u0,     
                player-num: u0,
                result-price: u0,
                bet-total: u0,
                min-predict: u0,
                max-predict: u0,
            }
        )
    )
)

;; get end blockHeight if draw period, or u0
(define-read-only (get-end-block-of-draw-period (bet-type uint)) 
    (let
        (
            
            (cur-round (unwrap! (map-get? bet-round-map bet-type) (err ERR_BET_TYPE))) 
            (bet-summary-tuple (unwrap-panic (map-get? bet-summary-map { bet-type: bet-type, round: cur-round })))
            (is-first-player (is-eq (get start-at bet-summary-tuple) u0)) 
            (start-at (if is-first-player block-height (get start-at bet-summary-tuple)))
            (end-at (+ start-at ROUND_LENGTH))
            (is-draw-period (> block-height end-at))
        )

        (if (is-eq is-draw-period true)
            (ok end-at)
            (ok u0)
        )
    )
)

(define-private (get-bet-amount-by-type (bet-type uint)) 
    (if (is-eq bet-type BET_TYPE_1)
        u10000000
        (if (is-eq bet-type BET_TYPE_2)
            u100000000
            (if (is-eq bet-type BET_TYPE_3)
                u1000000000
                u0
            )
        )
    )
)

(define-read-only (can-bet (bet-type uint)) 
    (let
        (
            (cur-round (unwrap-panic (map-get? bet-round-map bet-type)))
            (bet-summary-tuple (unwrap-panic (map-get? bet-summary-map { bet-type: bet-type, round: cur-round })))
            (player-num (get player-num bet-summary-tuple))
        )

        (< player-num (- PLAYER_LIMIT u1))
    )
)

(define-public (gazua (bet-type uint) (expect-price uint)) 
    (begin
        (asserts! (or (is-eq bet-type BET_TYPE_1) (is-eq bet-type BET_TYPE_2) (is-eq bet-type BET_TYPE_3)) (err ERR_BET_TYPE))
        (asserts! (> expect-price u0) (err ERR_EXPECT_PRICE_SHOULD_BE_MORE_THAN_0))

        (let
            (
                (base-bet-amount (get-bet-amount-by-type bet-type))
                (fee (/ base-bet-amount (* BET_FEE u100)))
                (cur-round (unwrap! (map-get? bet-round-map bet-type) (err ERR_BET_TYPE))) 
                (bet-summary-tuple (unwrap-panic (map-get? bet-summary-map { bet-type: bet-type, round: cur-round })))
                (is-first-player (is-eq (get start-at bet-summary-tuple) u0))
                (min-predict (if is-first-player expect-price (get min-predict bet-summary-tuple)))
                (max-predict (if is-first-player expect-price (get max-predict bet-summary-tuple)))
                (new-min-predict (if (< expect-price min-predict) expect-price min-predict))
                (new-max-predict (if (> expect-price max-predict) expect-price max-predict))
                (bet-total (get bet-total bet-summary-tuple))
                (player-num (get player-num bet-summary-tuple))
                (bet-record-opt-tuple (map-get? bet-record-map { bet-type: bet-type, round: cur-round, index: player-num }))
                (player-record-opt-tuple (map-get? player-record-map { player: tx-sender, bet-type: bet-type, round: cur-round}))
                (start-at (if is-first-player block-height (get start-at bet-summary-tuple)))
                (end-at (+ start-at ROUND_LENGTH))
                (is-draw-period (> block-height end-at))
                (end-time (if (is-eq is-draw-period true) 
                    (default-to u0 (get-block-info? time end-at)) 
                    u0))
            )

            (asserts! (>= (stx-get-balance tx-sender) (+ base-bet-amount fee)) (err ERR_NOT_ENOUGH_BALANCE))
            (asserts! (< player-num (- PLAYER_LIMIT u1)) (err ERR_LIMIT_BET_PLAYER))
            (asserts! (is-eq is-draw-period false) (err ERR_NOT_BET_ON_DRAW_PERIOD))
            (asserts! (is-none player-record-opt-tuple) (err ERR_ALREADY_PARTICIPATED))
        
            (begin
                (map-set bet-summary-map 
                    { bet-type: bet-type, round: cur-round} 
                    (merge bet-summary-tuple
                    {
                        start-at: start-at,
                        end-at: end-at,   
                        end-time: end-time,
                        min-predict: new-min-predict,
                        max-predict: new-max-predict,
                        player-num: (+ player-num u1),
                        bet-total : (+ bet-total base-bet-amount)
                    })
                )

                (map-set bet-record-map 
                    {bet-type: bet-type, round: cur-round, index: player-num} 
                    {
                        player: tx-sender,
                        bet-stx: base-bet-amount,
                        expect-price: expect-price,
                        stacks-block: block-height,
                        winner: false
                    }
                )

                (map-set player-record-map 
                    { player: tx-sender, bet-type: bet-type, round: cur-round} 
                    { 
                        bet-stx: base-bet-amount, 
                        expect-price: expect-price,
                        winner: false,
                        claimed: false
                    }
                )     
            )

            (try! (stx-transfer? base-bet-amount tx-sender (as-contract  tx-sender)))
            (stx-transfer? fee tx-sender FEE_WALLET)
        )
    )
)

(define-private (check-winner 
    (index uint) 
    (bet-record 
        {
            record-index: uint,
            player: principal,
            bet-stx: uint,
            expect-price: uint,
            stacks-block: uint,
            winner: bool,
            cur-round: uint,
            player-num: uint,
            bet-type: uint,
            result-price: uint})
    )
    (let
        (
            (player-num (get player-num bet-record))
            (is-valid-index (> player-num (+ index u1)))
            (result-price (get result-price bet-record))
            (prev-expect-price (get expect-price bet-record))
            (prev-result-offset 
                (if (> result-price prev-expect-price)
                    (- result-price prev-expect-price)
                    (- prev-expect-price result-price)
                )) 
        )

        (if (is-eq is-valid-index true)
            (let
                (
                    (bet-type (get bet-type bet-record))
                    (cur-round (get cur-round bet-record))
                    (cur-record-index (+ index u1))
                    (cur-bet-record-tuple (unwrap-panic (map-get? bet-record-map {bet-type: bet-type, round: cur-round, index: cur-record-index})))
                    (cur-expect-price (get expect-price cur-bet-record-tuple))
                    (cur-result-offset 
                    (if (> result-price cur-expect-price)
                        (- result-price cur-expect-price)
                        (- cur-expect-price result-price)
                    )) 

                    (winner
                        (if (<= prev-result-offset cur-result-offset)
                            bet-record
                            {
                                record-index: cur-record-index,
                                player: (get player cur-bet-record-tuple),
                                bet-stx: (get bet-stx cur-bet-record-tuple),
                                expect-price: cur-expect-price,
                                stacks-block: (get stacks-block cur-bet-record-tuple),
                                winner: (get winner cur-bet-record-tuple),
                                cur-round: cur-round,
                                player-num: player-num,
                                bet-type: bet-type,
                                result-price: result-price
                            }
                        )
                    )
                )
                winner
            )
            bet-record
        )
    )   
)

;; calc winner and set next round
(define-private (draw-core (bet-type uint) (result-price uint)) 
    (let
        (
            (cur-round (unwrap! (map-get? bet-round-map bet-type) (err ERR_BET_TYPE))) 
            (bet-summary-tuple (unwrap! (map-get? bet-summary-map { bet-type: bet-type, round: cur-round }) (err ERR_NOT_INITIALIZED_SUMMARY)))
            (player-num (get player-num bet-summary-tuple))
            (bet-record-tuple (unwrap! (map-get? bet-record-map {bet-type: bet-type, round: cur-round, index: u0}) (err ERR_NOT_INITIALIZED_RECORD)))
            (cur-player (get player bet-record-tuple))
            (cur-expect-price (get expect-price bet-record-tuple))
            (winner {
                record-index: u0,
                player: (get player bet-record-tuple),
                bet-stx: (get bet-stx bet-record-tuple),
                expect-price: (get expect-price bet-record-tuple),
                stacks-block: (get stacks-block bet-record-tuple),
                winner: (get winner bet-record-tuple),
                cur-round: cur-round,
                player-num: player-num,
                bet-type: bet-type,
                result-price: result-price
            })
            
            (final-winner (fold check-winner LIST_500 winner))
            (console-winner {
                    record-index: (get record-index final-winner),
                    player: (get player final-winner),
                    bet-stx: (get bet-stx final-winner),
                    expect-price: (get expect-price final-winner),
                    stacks-block: (get stacks-block final-winner),
                    winner: true,
                    cur-round: (get cur-round final-winner),
                    player-num: (get player-num final-winner),
                    bet-type: (get bet-type final-winner),
                    result-price: (get result-price final-winner)
                })
        )

        ;; save record for winner and go next round
        (let
            (
                (winner-index (get record-index final-winner))
                (winner-player (get player final-winner))
                (winner-bet-record-tuple (unwrap! (map-get? bet-record-map {bet-type: bet-type, round: cur-round, index: winner-index}) (err ERR_NOT_INITIALIZED_RECORD)))
                (winner-player-record-tuple (unwrap! (map-get? player-record-map {bet-type: bet-type, round: cur-round, player: winner-player}) (err ERR_NOT_INITIALIZED_RECORD))) 
                (end-at (get start-at bet-summary-tuple))
                (end-time (default-to u0 (get-block-info? time end-at)))
            )

            (map-set bet-summary-map 
                { bet-type: bet-type, round: cur-round }
                (merge bet-summary-tuple
                {
                    result-price: result-price,
                    end-time: end-time
                })
            )

            (map-set bet-record-map 
                { bet-type: bet-type, round: cur-round, index: winner-index }
                (merge winner-bet-record-tuple
                {
                    winner: true
                })
            )

            (map-set player-record-map 
                { player: winner-player, bet-type: bet-type, round: cur-round } 
                (merge winner-player-record-tuple
                {
                    winner: true
                })
            )

            (go-next-round bet-type)
        )
        (print console-winner)
        (ok true)
    )
)

(define-public (draw (bet-type uint) (result-price uint))
    (if (and (is-authorized-owner) (> result-price u0) (check-valid-bet-type bet-type))
        (let 
            (
                (end-block (try! (get-end-block-of-draw-period bet-type)))
            )

            (if (not (is-eq end-block u0))
                (try!  (draw-core bet-type result-price))
                (begin
                    (print "it's not on draw period.")
                    false
                )
            )
            
            (ok true)
        )
        (err ERR_NOT_AUTHORIZED)
    )
)

(define-read-only (can-claim-reward (bet-type uint) (round uint) (account principal)) 
    (let
        (
            (is-valid-bet-type (check-valid-bet-type bet-type))
        )
        
        (if (is-eq is-valid-bet-type true)
            (let
                (
                    (player-record-opt-tuple (map-get? player-record-map { player: account, bet-type: bet-type, round: round}))
                )

                (if (is-none player-record-opt-tuple)
                    false
                    (let
                        (
                            (player-record-tuple (unwrap-panic player-record-opt-tuple))
                            (claimed (get claimed player-record-tuple))
                            (winner (get winner player-record-tuple))
                        )
                        (and (not claimed) winner)
                    )
                )
            )

            false
        )
    )
)

(define-public (claim-reward (bet-type uint) (round uint) (account principal))
    (let
        (
            (can-claim (can-claim-reward bet-type round account))
        )

        (asserts! (is-eq tx-sender account) (err ERR_SHOULD_CLAIM_BY_WINNER))
        (asserts! (is-eq can-claim true) (err ERR_CLAIM_VIOLATION))
        (unwrap-panic  (set-reward-claimed bet-type round account))
        (ok true)
    )
)

(define-read-only (get-reward-amount (bet-type uint) (round uint))
    (let
        (
            (bet-summary-tuple (unwrap-panic (map-get? bet-summary-map { bet-type: bet-type, round: round})))
        )
        
        (get bet-total bet-summary-tuple)
    )
)

(define-private (set-reward-claimed (bet-type uint) (round uint) (account principal))
    (let
        (
            (player-record-tuple (unwrap! (map-get? player-record-map { player: account, bet-type: bet-type, round: round}) (err ERR_NON_EXIST_RECORD)))
            (bet-summary-tuple (unwrap! (map-get? bet-summary-map { bet-type: bet-type, round: round}) (err ERR_NON_EXIST_SUMMARY)))
            (reward-amount (get bet-total bet-summary-tuple))
        )

        (map-set player-record-map 
            { player: account, bet-type: bet-type, round: round}
            (merge player-record-tuple
            {
                claimed: true
            })
        )

        (permit-reward reward-amount account)
    )
)

(define-private (permit-reward (amount uint) (recipient principal))
    (as-contract (stx-transfer? amount tx-sender recipient))
)

(define-private (is-authorized-owner)
  (is-eq contract-caller CONTRACT_OWNER)
)

(define-read-only (check-valid-bet-type (bet-type uint)) 
    (if (or (is-eq bet-type BET_TYPE_1) (is-eq bet-type BET_TYPE_2) (is-eq bet-type BET_TYPE_3))
        true
        false
    )
)

(define-read-only (get-block-time (stacks-block uint))
    (get-block-info? time stacks-block)
)
```
