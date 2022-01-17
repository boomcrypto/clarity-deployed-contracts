(define-constant ERR_BET_TYPE 1001)
(define-constant ERR_ROUND_NOT_RIGHT 1002)
(define-constant ERR_INVALID_COST 1003)
(define-constant ERR_EXCEED_MAX_PLAYERS_PER_ROUND_COUNT 1004)
(define-constant ERR_HAS_BET_CURRENT_ROUND 1005)
(define-constant ERR_INVALID_BET_VALUE 1006)
(define-constant ERR_BALANCE_UNENOUGH 1007)
(define-constant ERR_TRANSFER_STX_ERR 1008)
(define-constant ERR_ROUND_NOT_FOUND 1009)
(define-constant ERR_ROUND_NOT_CURRENT 1010)
(define-constant ERR_CANCAL_IN_CD 1011)
(define-constant ERR_NO_BET 1012)
(define-constant ERR_ALREADY_DRAW 1013)
(define-constant ERR_NO_AUTHORITY 1014)
;; 
(define-constant OWNER tx-sender)
(define-constant BET_TYPE_LIST (list u1 u2 u3))
(define-constant MAX_PLAYERS_PER_ROUND u360)
(define-constant MIN_BET_COUNT_PER_ROUND u10)
(define-constant HIT_SHARES u1000000)
(define-constant SHARES_PER_MSTX u1000)
(define-constant MAX_BLOCKS_PER_ROUND u3) ;;TODO u36 6 hours
(define-constant DRAW_CD_BLOCKS u2)       ;; 0.5 hour
(define-constant CANCEL_CD_BLOCKS u72)    ;; 12 hours
(define-constant UPDATE_PRICE_COST u5000000)
(define-constant MAPPING_21_30_LIST (list u1 u1 u2 u3 u4 u47 u48 u49 u50 u50))
(define-constant MAPPING_71_80_LIST (list u51 u51 u52 u53 u54 u97 u98 u99 u100 u100))

(define-constant BUFF_TO_BYTE (list 
  0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x0a 0x0b 0x0c 0x0d 0x0e 0x0f
  0x10 0x11 0x12 0x13 0x14 0x15 0x16 0x17 0x18 0x19 0x1a 0x1b 0x1c 0x1d 0x1e 0x1f
  0x20 0x21 0x22 0x23 0x24 0x25 0x26 0x27 0x28 0x29 0x2a 0x2b 0x2c 0x2d 0x2e 0x2f
  0x30 0x31 0x32 0x33 0x34 0x35 0x36 0x37 0x38 0x39 0x3a 0x3b 0x3c 0x3d 0x3e 0x3f
  0x40 0x41 0x42 0x43 0x44 0x45 0x46 0x47 0x48 0x49 0x4a 0x4b 0x4c 0x4d 0x4e 0x4f
  0x50 0x51 0x52 0x53 0x54 0x55 0x56 0x57 0x58 0x59 0x5a 0x5b 0x5c 0x5d 0x5e 0x5f
  0x60 0x61 0x62 0x63 0x64 0x65 0x66 0x67 0x68 0x69 0x6a 0x6b 0x6c 0x6d 0x6e 0x6f
  0x70 0x71 0x72 0x73 0x74 0x75 0x76 0x77 0x78 0x79 0x7a 0x7b 0x7c 0x7d 0x7e 0x7f
  0x80 0x81 0x82 0x83 0x84 0x85 0x86 0x87 0x88 0x89 0x8a 0x8b 0x8c 0x8d 0x8e 0x8f
  0x90 0x91 0x92 0x93 0x94 0x95 0x96 0x97 0x98 0x99 0x9a 0x9b 0x9c 0x9d 0x9e 0x9f
  0xa0 0xa1 0xa2 0xa3 0xa4 0xa5 0xa6 0xa7 0xa8 0xa9 0xaa 0xab 0xac 0xad 0xae 0xaf
  0xb0 0xb1 0xb2 0xb3 0xb4 0xb5 0xb6 0xb7 0xb8 0xb9 0xba 0xbb 0xbc 0xbd 0xbe 0xbf
  0xc0 0xc1 0xc2 0xc3 0xc4 0xc5 0xc6 0xc7 0xc8 0xc9 0xca 0xcb 0xcc 0xcd 0xce 0xcf
  0xd0 0xd1 0xd2 0xd3 0xd4 0xd5 0xd6 0xd7 0xd8 0xd9 0xda 0xdb 0xdc 0xdd 0xde 0xdf
  0xe0 0xe1 0xe2 0xe3 0xe4 0xe5 0xe6 0xe7 0xe8 0xe9 0xea 0xeb 0xec 0xed 0xee 0xef
  0xf0 0xf1 0xf2 0xf3 0xf4 0xf5 0xf6 0xf7 0xf8 0xf9 0xfa 0xfb 0xfc 0xfd 0xfe 0xff
))
(define-constant LIST_360 (list
  u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 
  u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40 u41 u42 u43 u44 u45 u46 u47 u48 u49 u50 
  u51 u52 u53 u54 u55 u56 u57 u58 u59 u60 u61 u62 u63 u64 u65 u66 u67 u68 u69 u70 u71 u72 u73 u74 u75 
  u76 u77 u78 u79 u80 u81 u82 u83 u84 u85 u86 u87 u88 u89 u90 u91 u92 u93 u94 u95 u96 u97 u98 u99 u100 
  u101 u102 u103 u104 u105 u106 u107 u108 u109 u110 u111 u112 u113 u114 u115 u116 u117 u118 u119 u120 u121 u122 u123 u124 u125 
  u126 u127 u128 u129 u130 u131 u132 u133 u134 u135 u136 u137 u138 u139 u140 u141 u142 u143 u144 u145 u146 u147 u148 u149 u150 
  u151 u152 u153 u154 u155 u156 u157 u158 u159 u160 u161 u162 u163 u164 u165 u166 u167 u168 u169 u170 u171 u172 u173 u174 u175 
  u176 u177 u178 u179 u180 u181 u182 u183 u184 u185 u186 u187 u188 u189 u190 u191 u192 u193 u194 u195 u196 u197 u198 u199 u200 
  u201 u202 u203 u204 u205 u206 u207 u208 u209 u210 u211 u212 u213 u214 u215 u216 u217 u218 u219 u220 u221 u222 u223 u224 u225 
  u226 u227 u228 u229 u230 u231 u232 u233 u234 u235 u236 u237 u238 u239 u240 u241 u242 u243 u244 u245 u246 u247 u248 u249 u250 
  u251 u252 u253 u254 u255 u256 u257 u258 u259 u260 u261 u262 u263 u264 u265 u266 u267 u268 u269 u270 u271 u272 u273 u274 u275 
  u276 u277 u278 u279 u280 u281 u282 u283 u284 u285 u286 u287 u288 u289 u290 u291 u292 u293 u294 u295 u296 u297 u298 u299 u300 
  u301 u302 u303 u304 u305 u306 u307 u308 u309 u310 u311 u312 u313 u314 u315 u316 u317 u318 u319 u320 u321 u322 u323 u324 u325 
  u326 u327 u328 u329 u330 u331 u332 u333 u334 u335 u336 u337 u338 u339 u340 u341 u342 u343 u344 u345 u346 u347 u348 u349 u350 
  u351 u352 u353 u354 u355 u356 u357 u358 u359 u360
))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; data maps and vars ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-map bet-round-map
  uint ;; bet-type
  uint ;; round
)

(define-map bet-summary-map
  { bet-type: uint, round: uint }
  {
    start-at: uint,     ;; round start block
    end-at: uint,       ;; round end block
    player-num: uint,   ;; player number cur round
    v-num: uint,        ;; bet v times (v means left side [1-50])
    s-num: uint,        ;; bet s times (s means right side [51-100])
    rand-num: uint,     ;; the result random number
    total-shares: uint  ;; total shares of the winners
  }
)

(define-map bet-record-map
  { bet-type: uint, round: uint, index: uint } ;; index start from 1
  {
    player: principal,
    bet-value: uint,    ;; 101*v+s
    shares: uint,
    win-num: int        ;; 0 means not draw yet, >0 means win, <0 means lose
  }
)

;; compress so that per round data can be fetched by single function call
(define-map bet-records-compress-map
  { bet-type: uint, round: uint }
  (list 360 { p: principal, v: int }) ;; (bet-value + shares*10000 + |win-num|*10000000000) * (win-num>0 ? 1 : -1)
)

(define-map player-times-map
  { player: principal, bet-type: uint }
  uint  ;; times
)

(define-map player-record-map
  { player: principal, bet-type: uint, index: uint } ;; index start from 1
  {
    round: uint,
    bet-value: uint,  ;; 101*v+s
    win-num: int      ;; 0 means not draw yet, >0 means win, <0 means lose
  }
)

(define-data-var price-list (list 3 uint) (list u100 u200 u300)) ;;TODO:
(define-data-var tips (string-utf8 128) u"I WISH YOU WIN!")

;; draw logic related
(define-data-var draw-bet-type uint u0)
(define-data-var draw-round uint u0)
(define-data-var draw-bet-price uint u0)
(define-data-var draw-rand-num uint u0)
(define-data-var draw-rand-is-v bool false)
(define-data-var draw-total-shares uint u0)
(define-data-var draw-award-pool-num uint u0)
(define-data-var draw-award-per-mshare uint u0) ;; award per micro share
(define-map will-draw-map
  uint ;; bet-type
  uint ;; round-will-draw
)

;; compress logic used
(define-data-var compress-bet-type uint u0)
(define-data-var compress-round uint u0)
(define-map will-compress-map
  uint ;; bet-type
  uint ;; round-will-compress
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; bet-round = 0 means always current round
(define-public (bet (bet-type uint) (bet-round uint) (bet-v uint) (bet-s uint) (stx-cost uint))
  (let
    (
      (cur-round (unwrap! (map-get? bet-round-map bet-type) (err ERR_BET_TYPE)))
      (player-times (default-to u0 (map-get? player-times-map { player: tx-sender, bet-type: bet-type })))
      (player-record-opt-tuple (map-get? player-record-map { player: tx-sender, bet-type: bet-type, index: player-times }))
      (bet-v-flag (and (>= bet-v u1) (<= bet-v u50)))
      (bet-s-flag (and (>= bet-s u51) (<= bet-s u100)))
      (bet-price (* (unwrap-panic (element-at (var-get price-list) (- bet-type u1))) (if (and bet-v-flag bet-s-flag) u2 u1)))
      (bet-summary-tuple (unwrap-panic (map-get? bet-summary-map { bet-type: bet-type, round: cur-round })))
      (player-num (+ (get player-num bet-summary-tuple) u1))
      (v-num (+ (get v-num bet-summary-tuple) (if bet-v-flag u1 u0)))
      (s-num (+ (get s-num bet-summary-tuple) (if bet-s-flag u1 u0)))
      (is-first-player (is-eq player-num u1))
      (start-at (if is-first-player block-height (get start-at bet-summary-tuple)))
    )
    (asserts! (or (is-eq bet-round u0) (is-eq cur-round bet-round)) (err ERR_ROUND_NOT_RIGHT))
    (asserts! (or (is-none player-record-opt-tuple) (not (is-eq (unwrap-panic (get round player-record-opt-tuple)) cur-round))) (err ERR_HAS_BET_CURRENT_ROUND))
    (asserts! (<= player-num MAX_PLAYERS_PER_ROUND) (err ERR_EXCEED_MAX_PLAYERS_PER_ROUND_COUNT))
    (asserts! (or (is-eq bet-v u0) (or (and (>= bet-v u1) (<= bet-v u20)) (and (>= bet-v u31) (<= bet-v u50)))) (err ERR_INVALID_BET_VALUE))
    (asserts! (or (is-eq bet-s u0) (or (and (>= bet-s u51) (<= bet-s u70)) (and (>= bet-s u81) (<= bet-s u100)))) (err ERR_INVALID_BET_VALUE))
    (asserts! (or bet-v-flag bet-s-flag) (err ERR_INVALID_BET_VALUE))
    (asserts! (is-eq stx-cost bet-price) (err ERR_INVALID_COST))
    (asserts! (>= (stx-get-balance tx-sender) bet-price) (err ERR_BALANCE_UNENOUGH))

    ;; deduct
    (unwrap! (stx-transfer? bet-price tx-sender (as-contract tx-sender)) (err ERR_TRANSFER_STX_ERR))

    (let
      (
        (bet-value (+ (* u101 bet-v) bet-s))
      )
      ;; note bet related map
      (map-set bet-summary-map
        { bet-type: bet-type, round: cur-round }
        (merge bet-summary-tuple {
          start-at: start-at,
          player-num: player-num,
          v-num: v-num,
          s-num: s-num
        })
      )
      (map-set bet-record-map
        { bet-type: bet-type, round: cur-round, index: player-num }
        {
          player: tx-sender,
          bet-value: bet-value,
          shares: u0,
          win-num: 0
        }
      )
      ;; note player related map
      (map-set player-times-map
        { player: tx-sender, bet-type: bet-type }
        (+ player-times u1)
      )
      (map-set player-record-map
        { player: tx-sender, bet-type: bet-type, index: (+ player-times u1) }
        {
          round: cur-round,
          bet-value: bet-value,
          win-num: 0
        }
      )
    )

    ;; if ((player-num >= MAX_PLAYERS_PER_ROUND) or
    ;;     ((has passed 6 hours since start) and (total-bets >= 10) and (small-side-count*2 > big-side-count))) then
    ;;    (end cur round, start next round)
    (if
      (or
        (>= player-num MAX_PLAYERS_PER_ROUND)
        (and
          (> block-height (+ start-at MAX_BLOCKS_PER_ROUND))
          (>= (+ v-num s-num) MIN_BET_COUNT_PER_ROUND)
          (> (* v-num u2) s-num)
          (> (* s-num u2) v-num)
        )
      )
      (let
        (
          (cur-bet-summary-tuple (unwrap-panic (map-get? bet-summary-map { bet-type: bet-type, round: cur-round }))) ;; DO NOT use bet-summary-tuple as it has been modified
        )
        (map-set bet-summary-map
          { bet-type: bet-type, round: cur-round }
          (merge cur-bet-summary-tuple {
            end-at: block-height
          })
        )
        (restart-round bet-type (+ cur-round u1))
      )
      true
    )

    ;; if ((has round-will-draw) and (has passed 0.5 hour since round-will-draw end-time)):
    ;;    draw round-will-draw
    ;; elseif ((has round-will-compress) and (round-will-compress has draw):
    ;;    compress round-will-compress
    (let
      (
        (round-will-draw (unwrap-panic (map-get? will-draw-map bet-type)))
        (will-draw-bet-summary-tuple (unwrap-panic (map-get? bet-summary-map { bet-type: bet-type, round: round-will-draw })))
        (round-will-compress (unwrap-panic (map-get? will-compress-map bet-type)))
        (will-compress-bet-summary-tuple (unwrap-panic (map-get? bet-summary-map { bet-type: bet-type, round: round-will-compress })))
      )
      (if (and (< round-will-draw cur-round) (> block-height (+ (get end-at will-draw-bet-summary-tuple) DRAW_CD_BLOCKS)))  ;; use cur-round is ok, though the real-time round may be cur-round + 1
        (draw bet-type round-will-draw)
        (if (and (< round-will-compress cur-round) (> (get rand-num will-compress-bet-summary-tuple) u0))
          (compress-records bet-type round-will-compress)
          true
        )
      )
    )

    ;;
    (ok true)
  )
)

(define-private (draw (bet-type uint) (round uint))
  (let
    (
      (bet-summary-tuple (unwrap-panic (map-get? bet-summary-map { bet-type: bet-type, round: round })))
      (crf-rand-num (calc-round-rand-num bet-type round))
      (rand-num (process-crf-rand-num crf-rand-num))
      (is-v (< rand-num u51))
    )

    (print {
      title: "draw",
      bet-type: bet-type,
      round: round,
    })

    ;;
    (map-set will-draw-map bet-type (+ round u1))
    (var-set draw-bet-type bet-type)
    (var-set draw-round round)
    (var-set draw-rand-num rand-num)
    (var-set draw-rand-is-v is-v)
    (var-set draw-total-shares u0)
    (var-set draw-bet-price (unwrap-panic (element-at (var-get price-list) (- bet-type u1))))
    (var-set draw-award-pool-num
      (*
        (var-get draw-bet-price)
        (if is-v (get s-num bet-summary-tuple) (get v-num bet-summary-tuple))
      )
    )

    ;; calc each player's shares
    (filter calc-shares-loop LIST_360)

    ;; calc each award per micro share
    (if (> (var-get draw-total-shares) u0)
      (var-set draw-award-per-mshare (/ (* (var-get draw-award-pool-num) SHARES_PER_MSTX) (var-get draw-total-shares)))
      (var-set draw-award-per-mshare u0)
    )

    (map-set bet-summary-map
      { bet-type: bet-type, round: round }
      (merge bet-summary-tuple {
        rand-num: rand-num,
        total-shares: (var-get draw-total-shares)
      })
    )

    ;; distribute award
    (filter award-loop LIST_360)

    ;; remain is the fee
    (unwrap! (as-contract (stx-transfer? (var-get draw-award-pool-num) tx-sender OWNER)) false)
    
    ;; finish
    true
  )
)

(define-private (process-crf-rand-num (num uint))
  (if (and (>= num u21) (<= num u30))
    (unwrap-panic (element-at MAPPING_21_30_LIST (- num u21)))
    (if (and (>= num u71) (<= num u80))
      (unwrap-panic (element-at MAPPING_71_80_LIST (- num u71)))
      num
    )
  )
)

(define-private (restart-round (bet-type uint) (round uint))
  (begin
    (print {
      title: "restart-round",
      bet-type: bet-type,
      round: round
    })
    (map-set bet-round-map bet-type round)
    (map-set bet-summary-map
      { bet-type: bet-type, round: round }
      {
        start-at: u0,
        end-at: u0,
        player-num: u0,
        v-num: u0,
        s-num: u0,
        rand-num: u0,
        total-shares: u0
      }
    )
  )
)

(define-public (update-tips (in-tips (string-utf8 128)))
  (begin
    (asserts! (is-eq OWNER tx-sender) (err ERR_NO_AUTHORITY))
    (ok (var-set tips in-tips))
  )
)

;;;;;;;; calc-shares-loop begin ;;;;;;;;
(define-private (calc-shares-loop (index uint))
  (let
    (
      (bet-type (var-get draw-bet-type))
      (round (var-get draw-round))
      (rand-num (var-get draw-rand-num))
    )
    (match (map-get? bet-record-map { bet-type: bet-type, round: round, index: index }) bet-record-tuple
      (let
        (
          (bet-value (get bet-value bet-record-tuple))
          (bet-v (/ bet-value u101))
          (bet-s (mod bet-value u101))
          (shares (
            if (<= rand-num u50)
              (if (is-eq bet-v u0)
                u0
                (if (>= bet-v rand-num)
                  (/ HIT_SHARES (+ (- bet-v rand-num) u10))
                  (/ HIT_SHARES (+ (- rand-num bet-v) u10))
                )
              )
              (if (is-eq bet-s u0)
                u0
                (if (>= bet-s rand-num)
                  (/ HIT_SHARES (+ (- bet-s rand-num) u10))
                  (/ HIT_SHARES (+ (- rand-num bet-s) u10))
                )
              )
            )
          )
        )
        (var-set draw-total-shares (+ (var-get draw-total-shares) shares))
        (map-set bet-record-map
          { bet-type: bet-type, round: round, index: index }
          (merge bet-record-tuple {
            shares: shares
          })
        )
        false
      )
      false
    )
  )
)
;;;;;;;; calc-shares-loop end ;;;;;;;;

;;;;;;;; award-loop begin ;;;;;;;;
(define-private (award-loop (index uint))
  (let
    (
      (bet-type (var-get draw-bet-type))
      (round (var-get draw-round))
    )
    (match (map-get? bet-record-map { bet-type: bet-type, round: round, index: index }) bet-record-tuple
      (let
        (
          (bet-price (var-get draw-bet-price))
          (award (/ (* (get shares bet-record-tuple) (var-get draw-award-per-mshare)) SHARES_PER_MSTX))
          (player (get player bet-record-tuple))
          (bet-value (get bet-value bet-record-tuple))
          (is-bet-both-side (and (> bet-value u101) (> (mod bet-value u101) u0)))
          (win-num
            (if is-bet-both-side
              (- (to-int award) (to-int bet-price))
              (if (> award u0) (to-int award) (- 0 (to-int bet-price)))
            )
          )
          (player-times (unwrap-panic (map-get? player-times-map { player: player, bet-type: bet-type })))
          (player-record (unwrap-panic (map-get? player-record-map { player: player, bet-type: bet-type, index: player-times })))
        )
        
        (and
          (> award u0)
          (unwrap! (as-contract (stx-transfer? (+ award bet-price) tx-sender player)) false)
          (var-set draw-award-pool-num (- (var-get draw-award-pool-num) award))
        )
        ;;
        (map-set bet-record-map
          { bet-type: bet-type, round: round, index: index }
          (merge bet-record-tuple {
            win-num: win-num
          })
        )
        ;;
        (map-set player-record-map
          { player: player, bet-type: bet-type, index: player-times }
          (merge player-record {
            win-num: win-num
          })
        )
        false
      )
      false
    )
  )
)
;;;;;;;; award-loop end ;;;;;;;;

(define-private (calc-round-rand-num (bet-type uint) (round uint))
  (let
    (
      (end-block (get end-at (unwrap-panic (map-get? bet-summary-map { bet-type: bet-type, round: round }))))
      (vrf-rand-num (get-rand-uint-at-block (+ end-block DRAW_CD_BLOCKS)))
    )
    (+ (mod (/ vrf-rand-num u10) u100) u1)
  )
)

;;;;;;;; cancel round begin ;;;;;;;;
(define-public (cancel (bet-type uint) (round uint))
  (let
    (
      (cur-round (unwrap! (map-get? bet-round-map bet-type) (err ERR_BET_TYPE)))
      (bet-summary-tuple (unwrap! (map-get? bet-summary-map { bet-type: bet-type, round: round }) (err ERR_ROUND_NOT_FOUND)))
    )
    (asserts! (is-eq cur-round round) (err ERR_ROUND_NOT_CURRENT))
    (asserts! (> block-height (+ (get start-at bet-summary-tuple) CANCEL_CD_BLOCKS)) (err ERR_CANCAL_IN_CD))
    (asserts! (> (get player-num bet-summary-tuple) u0) (err ERR_NO_BET))
    (asserts! (is-eq (get rand-num bet-summary-tuple) u0) (err ERR_ALREADY_DRAW))
    (ok (cancel-round bet-type round))
  )
)

(define-private (cancel-round (bet-type uint) (round uint))
  (let
    (
      (bet-summary-tuple (unwrap-panic (map-get? bet-summary-map { bet-type: bet-type, round: round })))
    )
    (var-set draw-bet-type bet-type)
    (var-set draw-round round)
    (var-set draw-bet-price (unwrap-panic (element-at (var-get price-list) (- bet-type u1))))

    ;; cancel each player
    (filter cancel-loop LIST_360)

    ;; reset current round for each bet-type
    (restart-round bet-type round)
  )
)

(define-private (cancel-loop (index uint))
  (let
    (
      (bet-type (var-get draw-bet-type))
      (round (var-get draw-round))
    )
    (match (map-get? bet-record-map { bet-type: bet-type, round: round, index: index }) bet-record-tuple
      (let 
        (
          (bet-value (get bet-value bet-record-tuple))
          (bet-v-flag (>= bet-value u101))
          (bet-s-flag (> (mod bet-value u101) u0))
          (player (get player bet-record-tuple))
          (player-times (default-to u0 (map-get? player-times-map { player: player, bet-type: bet-type })))
        )
        ;;
        (map-delete bet-record-map { bet-type: bet-type, round: round, index: index })
        ;;
        (if (> player-times u1)
          (map-set player-times-map
            { player: player, bet-type: bet-type }
            (- player-times u1)
          )
          (map-delete player-times-map { player: player, bet-type: bet-type })
        )
        (map-delete player-record-map { player: player, bet-type: bet-type, index: player-times })
        ;;
        (unwrap! (as-contract (stx-transfer? (* (var-get draw-bet-price) (if (and bet-v-flag bet-s-flag) u2 u1)) tx-sender player)) false)
        ;;
        false
      )
      false
    )
  )
)
;;;;;;;; cancel round end ;;;;;;;;

;;;;;;;; update price begin ;;;;;;;;
(define-public (update-price (in-price-list (list 3 uint)))
  (begin
    (asserts! (is-eq OWNER tx-sender) (err ERR_NO_AUTHORITY))
    (unwrap! (stx-burn? UPDATE_PRICE_COST tx-sender) (err ERR_BALANCE_UNENOUGH))
    (let
      (
        (cancel-ok-list (filter force-cancel-bet-type BET_TYPE_LIST))
      )
      (var-set price-list in-price-list)
      (ok (is-eq (len cancel-ok-list) (len BET_TYPE_LIST)))
    )
  )
)

(define-private (force-cancel-bet-type (bet-type uint))
  (let
    (
      (cur-round (unwrap-panic (map-get? bet-round-map bet-type)))
    )
    (match (map-get? bet-summary-map { bet-type: bet-type, round: cur-round }) bet-summary-tuple
      (if
        (and
          (> (get player-num bet-summary-tuple) u0)
          (> (get start-at bet-summary-tuple) u0)
          (is-eq (get rand-num bet-summary-tuple) u0)
        )
        (cancel-round bet-type cur-round)
        true
      )
      true
    )
  )
)
;;;;;;;; update price end ;;;;;;;;

;;;;;;;; compress begin ;;;;;;;;
(define-private (compress-records (bet-type uint) (round uint))
  (begin
    (print {
      title: "compress",
      bet-type: bet-type,
      round: round,
    })

    (map-set will-compress-map bet-type (+ round u1))
    (var-set compress-bet-type bet-type)
    (var-set compress-round round)
    (let
      (
        (record-opt-list (map compress-record LIST_360))
        (record-some-list (filter s-is-some record-opt-list))
        (record-list (map s-unwrap record-some-list))
      )
      (map-set bet-records-compress-map { bet-type: bet-type, round: round } record-list)
      (map delete-record LIST_360)
      true
    )
  )
)

(define-private (s-is-some (a (optional { p: principal, v: int })))
  (is-some a)
)

(define-private (s-unwrap (a (optional { p: principal, v: int })))
  (unwrap-panic a)
)

(define-private (compress-record (index uint))
  (match (map-get? bet-record-map { bet-type: (var-get compress-bet-type), round: (var-get compress-round), index: index }) bet-record-tuple
    (let
      (
        (ori-win-num (get win-num bet-record-tuple))
        (flag (if (>= ori-win-num 0) 1 -1))
        (abs-win-num (if (>= ori-win-num 0) ori-win-num (* -1 ori-win-num)))
      )
      (some
        {
          p: (get player bet-record-tuple),
          v: (* flag (+ (to-int (get bet-value bet-record-tuple)) (* 10000 (to-int (get shares bet-record-tuple))) (* 10000000000 abs-win-num)))
        }
      )
    )
    none
  )
)

(define-private (delete-record (index uint))
  (map-delete bet-record-map { bet-type: (var-get compress-bet-type), round: (var-get compress-round), index: index })
)
;;;;;;;; compress end ;;;;;;;;

;;;;;;;; web use begin ;;;;;;;;
(define-read-only (get-summary (player-opt (optional principal)))
  (ok {
    summarys: (map get-cur-bet-summary BET_TYPE_LIST),
    extra-summarys: (map get-extra-summary BET_TYPE_LIST),
    player-bet-infos: (map get-cur-player-bet-info BET_TYPE_LIST (list player-opt player-opt player-opt)),
    price-list: (var-get price-list),
    block-height: block-height,
    tips: (var-get tips),
  })
)

(define-read-only (get-extra-summary (bet-type uint))
  {
    will-draw: (unwrap-panic (map-get? will-draw-map bet-type)),
    will-compress: (unwrap-panic (map-get? will-compress-map bet-type)),
  }
)

(define-read-only (get-cur-bet-summary (bet-type uint))
  (let
    (
      (round (unwrap-panic (map-get? bet-round-map bet-type)))
    )
    (get-bet-summary bet-type round)
  )
)

(define-read-only (get-bet-summary (bet-type uint) (round uint))
  (let
    (
      (bet-summary (map-get? bet-summary-map { bet-type: bet-type, round: round }))
      (start-at (default-to u0 (get start-at bet-summary)))
      (start-time (default-to u0 (get-block-info? time start-at)))
      (end-at (default-to u0 (get end-at bet-summary)))
      (end-time (default-to u0 (get-block-info? time end-at)))
    )
    {
      bet-type: bet-type,
      round: round,
      summary: bet-summary,
      start-time: start-time,
      end-time: end-time,
    }
  )
)

(define-read-only (get-cur-player-bet-info (bet-type uint) (player-opt (optional principal)))
  (match player-opt player
    (match (map-get? player-times-map { player: player, bet-type: bet-type }) player-times
      (match (map-get? player-record-map { player: player, bet-type: bet-type, index: player-times }) player-record
        (let
          (
            (cur-round (unwrap-panic (map-get? bet-round-map bet-type)))
          )
          (if (is-eq cur-round (get round player-record))
            (ok player-record)
            (err none)
          )
        )
        (err none)
      )
      (err none)
    )
    (err none)
  )
)

(define-read-only (get-player-times (player principal) (bet-type uint))
  (default-to u0 (map-get? player-times-map { player: player, bet-type: bet-type }))
)

(define-read-only (get-player-bet-infos (key-list (list 25 { player: principal, bet-type: uint, index: uint })))
  (map get-player-bet-info key-list)
)

(define-read-only (get-player-bet-info (key { player: principal, bet-type: uint, index: uint }))
  (map-get? player-record-map key)
)

(define-read-only (get-compress-bet-records (bet-type uint) (round uint))
  (map-get? bet-records-compress-map { bet-type: bet-type, round: round })
)

(define-read-only (get-bet-records (key-list (list 25 { bet-type: uint, round: uint, index: uint })))
  (map get-bet-record key-list)
)

(define-read-only (get-bet-record (key { bet-type: uint, round: uint, index: uint }))
  (map-get? bet-record-map key)
)
;;;;;;;; web use end ;;;;;;;;

;;;;;;;; borrow from citycoins begin ;;;;;;;;
;; (https://github.com/citycoins/citycoin/tree/main/contracts)
(define-private (buff-to-u8 (byte (buff 1)))
  (unwrap-panic (index-of BUFF_TO_BYTE byte))
)

(define-private (buff-to-uint-le (word (buff 16)))
  (get acc
    (fold add-and-shift-uint-le (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15) { acc: u0, data: word })
  )
)

(define-private (add-and-shift-uint-le (idx uint) (input { acc: uint, data: (buff 16) }))
  (let (
    (acc (get acc input))
    (data (get data input))
    (byte (buff-to-u8 (unwrap-panic (element-at data idx))))
  )
  {
    ;; acc = byte * (2**(8 * (15 - idx))) + acc
    acc: (+ (* byte (pow u2 (* u8 (- u15 idx)))) acc),
    data: data
  })
)

(define-private (lower-16-le (input (buff 32)))
  (get acc
    (fold lower-16-le-closure (list u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31) { acc: 0x, data: input })
  )
)

(define-private (lower-16-le-closure (idx uint) (input { acc: (buff 16), data: (buff 32) }))
  (let (
    (acc (get acc input))
    (data (get data input))
    (byte (unwrap-panic (element-at data idx)))
  )
  {
    acc: (unwrap-panic (as-max-len? (concat acc byte) u16)),
    data: data
  })
)

(define-read-only (get-rand-uint-at-block (block-index uint))
  (buff-to-uint-le (lower-16-le (unwrap-panic (get-block-info? vrf-seed block-index))))
)
;;;;;;;; borrow from citycoins end ;;;;;;;;

;;;;;;;; initialize begin ;;;;;;;;
(define-private (init-bet-type (bet-type uint))
  (begin
    (restart-round bet-type u1)
    (map-set will-draw-map bet-type u1)
    (map-set will-compress-map bet-type u1)
  )
)

(map init-bet-type BET_TYPE_LIST)
;;;;;;;; initialize end ;;;;;;;;
