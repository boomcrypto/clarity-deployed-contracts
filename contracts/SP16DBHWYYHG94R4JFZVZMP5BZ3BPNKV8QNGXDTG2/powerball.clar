;; Reference: https://www.nhlottery.com/About-Us/Games-Rules#a-powerball
;; Terms:
;; bv(Ball Value) = (white1 + 100 * white2 + (100**2)*white3 + (100**3)*white4 + (100**4)*white5 + (100**5)*red). white1-white5 is in ascending order.
;; pbv(Power-play Ball Value) = BV + (100**6)*(powerball?1:0)
;; wv(Win Value) = PBV + (100**7)*win_stx
;; p = player

(define-constant ERR_DEPOSIT_COUNT_INVALID 1001)
(define-constant ERR_BALANCE_NOT_ENOUGH 1002)
(define-constant ERR_TRANSFER_STX 1003)
(define-constant ERR_NO_AUTHORITY 1004)
(define-constant ERR_CANNOT_CANCEL_INVEST_NOW 1005)
(define-constant ERR_NO_BET 1006)
(define-constant ERR_WAIT_TO_DRAW 1007)
(define-constant ERR_INVALID_STATE 1008)
(define-constant ERR_INVALID_PRICE 1009)
(define-constant ERR_NOT_ALLOW_WITHDRAW 1010)
(define-constant ERR_INVALID_REWARD 1011)
(define-constant ERR_CANNOT_MANUAL_SKIP_DRAW_NOW 1012)

;;
(define-constant OWNER tx-sender)
(define-constant LIST_5 (list u1 u2 u3 u4 u5))
(define-constant LIST_1_10 (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10))
(define-constant LIST_11_20 (list u11 u12 u13 u14 u15 u16 u17 u18 u19 u20))
(define-constant LIST_20 (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20))
(define-constant LIST_69 (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40 u41 u42 u43 u44 u45 u46 u47 u48 u49 u50 u51 u52 u53 u54 u55 u56 u57 u58 u59 u60 u61 u62 u63 u64 u65 u66 u67 u68 u69))
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
(define-constant BUNCH_NUM_LIST (list
  u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40 u41 u42 u43 u44 u45 u46 u47 u48 u49 u50
  u51 u52 u53 u54 u55 u56 u57 u58 u59 u60 u61 u62 u63 u64 u65 u66 u67 u68 u69 u70 u71 u72 u73 u74 u75 u76 u77 u78 u79 u80 u81 u82 u83 u84 u85 u86 u87 u88 u89 u90 u91 u92 u93 u94 u95 u96 u97 u98 u99 u100
  u101 u102 u103 u104 u105 u106 u107 u108 u109 u110 u111 u112 u113 u114 u115 u116 u117 u118 u119 u120 u121 u122 u123 u124 u125 u126 u127 u128 u129 u130 u131 u132 u133 u134 u135 u136 u137 u138 u139 u140 u141 u142 u143 u144 u145 u146 u147 u148 u149 u150
  u151 u152 u153 u154 u155 u156 u157 u158 u159 u160 u161 u162 u163 u164 u165 u166 u167 u168 u169 u170 u171 u172 u173 u174 u175 u176 u177 u178 u179 u180 u181 u182 u183 u184 u185 u186 u187 u188 u189 u190 u191 u192 u193 u194 u195 u196 u197 u198 u199 u200
))
(define-constant BUNCH_CAPACITY (len BUNCH_NUM_LIST))
;;
(define-constant STATE_FUNDING u1)
(define-constant STATE_BET u2)
(define-constant STATE_WAIT_DRAW u3)
(define-constant STATE_DRAW u4)
(define-constant BLOCKS_PER_ROUND u288) ;; 2 day
(define-constant DRAW_CD_BLOCKS u6)     ;; 1 hour (MUST >= 4). after round end, wait 1 hour to draw
(define-constant DEFAULT_JACKPOT_FACTOR u20000000)          ;; $2 => $40000000
(define-constant MIN_AWARD_POOL_FACTOR u22500000)           ;; $2 => $45000000, if award pool is less than this, wait the owner to deposit
(define-constant POWER_PLAY_10x_THRESHOLD_FACTOR u75000000) ;; $2 => $150000000, when jackpot>75000000*price, no 10x power play
(define-constant AL (list u0 u0 u0 u35 u500 u5000000 u20 u20 u35 u500 u250000)) ;; index=(red-same?1:0)*6 + white-same-count. value=multiply-factor. award = price * multiply-factor / 10
(define-constant BET_COUNT_THRERSHOLD_TO_WITHDRAW u1000)    ;; if bet-count<=500, owner can withdraw after round finishes if want
(define-constant UPDATE_PRICE_COST u1000000)
(define-constant MANUAL_SKIP_DRAW_BLOCKS u288)              ;; if not draw finish after 2 days since round-end, probably due to encounter error during draw. The owner can manually skip draw, otherwise the contract will die.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Data maps and vars ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-data-var m_state uint u0)
(define-data-var m_round uint u0)
(define-data-var m_start_at uint u0)
(define-data-var m_end_at uint u0)
(define-data-var m_price uint u0)
(define-data-var m_jackpot uint u0)
(define-data-var m_start_balance uint u0)       ;; contract balance when round start
(define-data-var m_draw_caller_reward uint u0)  ;; when someone call step_draw, reward it to cover its fee
(define-data-var m_new_price uint u0)           ;; if not equal to 0, will change bet price after draw finish
(define-data-var m_need_withdrawal bool false)  ;; if true, owner will withdraw all the remain balance after draw finish
(define-data-var m_omit_times uint u0)          ;; loop logic use only

;;;; bet related
;; round => total_bet_count
(define-map map_total_bet_count
  uint
  uint
)
;; round => bet_bunch_count
(define-map map_bet_bunch_count
  uint
  uint
)
;; (round, bet_bunch_index) => (player, pbv)
(define-map map_bet_bunch
  { round: uint, index: uint }
  (list 200 {
      p: principal,
      pbv: uint
    }
  )
)

;;;; player related
;; (round, player) => player_bet_bunch_count
(define-map map_player_bet_bunch_count
  { round: uint, p: principal }
  uint
)
;; (round, player, player_bunch_index) => pbv list
(define-map map_player_bet_bunch
  { round: uint, p: principal, index: uint }
  (list 200 uint)
)

;;;; draw related
(define-data-var m_draw_ball_value uint u0) ;; jackpot BV
(define-data-var m_draw_white uint u0)
(define-data-var m_draw_power_play uint u0)
(define-data-var m_draw_bunch_index uint u0)
(define-data-var m_draw_jackpot_reward_index uint u0)
(define-data-var m_draw_jackpot_ave_award uint u0)    ;; if more than 1 player win the jackpot, they share it. Each one get the jackpot-average-award.

;; white-ball => is this ball already in award pool
(define-map map_white uint bool)

;; round => win count (not include jackpot)
(define-map map_draw_win_count
  uint
  uint
)
;; (round, index) => (player, wv)
(define-map map_draw_win
  { round: uint, index: uint }
  {
    p: principal,
    wv: uint
  }
)

;; round => jackpot count
(define-map map_draw_jackpot_count
  uint
  uint
)
;; (round, index) => jackpot-player
(define-map map_draw_jackpot
  { round: uint, index: uint }
  principal
)

;; round => round summary
(define-map map_history_summary
  uint
  {
    start_at: uint,
    end_at: uint,
    price: uint,
    bet_count: uint,
    win_count: uint,
    jackpot_count: uint,
    ball_value: uint,
    power_play: uint,
    draw_bunch_index: uint,
    success: bool,    ;; whether the round is drawn successfully
  }
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; bet related begin ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; each element is PBV
(define-public (bet (bet_list (list 200 uint)))
  (let
    (
      (round (var-get m_round))
      (bet_item_list (map build_bet_item bet_list))
      (bet_count (len bet_item_list))
      (power_play_count (fold is_power_play bet_list u0))
      (bet_cost (/ (* (+ bet_count bet_count power_play_count) (var-get m_price)) u2))
      (bet_bunch_count (default-to u0 (map-get? map_bet_bunch_count round)))
      (bet_bunch_index (if (> bet_bunch_count u0) bet_bunch_count u1))
      (bet_bunch (default-to (list) (map-get? map_bet_bunch { round: round, index: bet_bunch_index })))
      (bunch_len (len bet_bunch))
      (new_total_bet_count (+ (default-to u0 (map-get? map_total_bet_count round)) bet_count))
      (player_bet_bunch_count (default-to u0 (map-get? map_player_bet_bunch_count { p: tx-sender, round: round })))
      (player_bet_bunch_index (if (> player_bet_bunch_count u0) player_bet_bunch_count u1))
      (player_bet_bunch (default-to (list) (map-get? map_player_bet_bunch { p: tx-sender, round: round, index: player_bet_bunch_index })))
      (player_bet_bunch_len (len player_bet_bunch))
    )
    (asserts! (is-eq (var-get m_state) STATE_BET) (err ERR_INVALID_STATE))
    (asserts! (> bet_count u0) (err ERR_NO_BET))
    (asserts! (>= (stx-get-balance tx-sender) bet_cost) (err ERR_BALANCE_NOT_ENOUGH))
    
    ;; deduct
    (unwrap! (stx-transfer? bet_cost tx-sender (as-contract tx-sender)) (err ERR_TRANSFER_STX))
    
    (map-set map_total_bet_count round new_total_bet_count)
    (and (is-eq new_total_bet_count bet_count)
          (var-set m_start_at block-height)
          (map-set map_bet_bunch_count round u1)
    )
    
    ;; note bet related data
    (if (<= (+ bunch_len bet_count) BUNCH_CAPACITY)
      (map-set map_bet_bunch { round: round, index: bet_bunch_index } (map get_bet_item_element (concat bet_bunch bet_item_list) BUNCH_NUM_LIST))
      (let
        (
          (next_bet_bunch_index (+ bet_bunch_index u1))
        )
        (map-set map_bet_bunch_count round next_bet_bunch_index)
        (if (is-eq bunch_len BUNCH_CAPACITY)
          (map-set map_bet_bunch { round: round, index: next_bet_bunch_index } bet_item_list)
          (begin
            (map-set map_bet_bunch { round: round, index: bet_bunch_index } (map get_bet_item_element (concat bet_bunch bet_item_list) BUNCH_NUM_LIST))
            (var-set m_omit_times (- BUNCH_CAPACITY bunch_len))
            (map-set map_bet_bunch { round: round, index: next_bet_bunch_index } (filter sub_bet_item_list_loop bet_item_list))
          )
        )
      )
    )

    ;; note player related data
    (and (is-eq player_bet_bunch_count u0)
          (map-set map_player_bet_bunch_count { p: tx-sender, round: round } u1)
    )

    (if (<= (+ player_bet_bunch_len bet_count) BUNCH_CAPACITY)
      (map-set map_player_bet_bunch
        { p: tx-sender, round: round, index: player_bet_bunch_index }
        (map get_bet_value_element (concat player_bet_bunch bet_list) BUNCH_NUM_LIST)
      )
      (let
        (
          (new_player_bet_bunch_count (+ player_bet_bunch_count u1))
        )
        (map-set map_player_bet_bunch_count { p: tx-sender, round: round } new_player_bet_bunch_count)
        (if (is-eq player_bet_bunch_len BUNCH_CAPACITY)
          (map-set map_player_bet_bunch { p: tx-sender, round: round, index: new_player_bet_bunch_count } bet_list)
          (begin
            (map-set map_player_bet_bunch 
              { p: tx-sender, round: round, index: player_bet_bunch_index } 
              (map get_bet_value_element (concat player_bet_bunch bet_list) BUNCH_NUM_LIST)
            )
            (var-set m_omit_times (- BUNCH_CAPACITY player_bet_bunch_len))
            (map-set map_player_bet_bunch 
              { p: tx-sender, round: round, index: new_player_bet_bunch_count } 
              (filter sub_bet_value_list_loop bet_list)
            )
          )
        )
      )
    )

    ;; if has started 2 day, enter wait-draw state
    (and (>= (- block-height (var-get m_start_at)) BLOCKS_PER_ROUND)
         (var-set m_state STATE_WAIT_DRAW)
         (var-set m_end_at block-height)
    )

    ;;
    (ok bet_count)
  )
)

(define-private (is_power_play (pbv uint) (count uint))
  (if (>= pbv u1000000000000) (+ count u1) count)
)

(define-private (build_bet_item (pbv uint))
  {
    p: tx-sender,
    pbv: pbv
  }
)

(define-private (get_bet_item_element (element { p: principal, pbv: uint }) (index uint))
  element
)

(define-private (sub_bet_item_list_loop (element { p: principal, pbv: uint }))
  (let
    (
      (omit_times (var-get m_omit_times))
    )
    (if (> omit_times u0)
      (and
        (var-set m_omit_times (- omit_times u1))
        false
      )
      true
    )
  )
)

(define-private (get_bet_value_element (element uint) (index uint))
  element
)

(define-private (sub_bet_value_list_loop (element uint))
  (let
    (
      (omit_times (var-get m_omit_times))
    )
    (if (> omit_times u0)
      (and
        (var-set m_omit_times (- omit_times u1))
        false
      )
      true
    )
  )
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; bet related end ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; draw related begin ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-public (step_draw)
  (if (is-eq (var-get m_state) STATE_DRAW)
    (ok (handle_step_draw))
    (if (is-eq (var-get m_state) STATE_WAIT_DRAW)
      (if (> block-height (+ (var-get m_end_at) DRAW_CD_BLOCKS))
        (let
          (
            (round (var-get m_round))
          )
          (var-set m_state STATE_DRAW)
          ;; safely reset
          (var-set m_omit_times u0)
          (var-set m_draw_ball_value (calc_draw_ball_value))
          (var-set m_draw_power_play (calc_power_play))
          (var-set m_draw_bunch_index u1)
          (var-set m_draw_jackpot_reward_index u1)
          (var-set m_draw_jackpot_ave_award u0)
          (map-set map_draw_win_count round u0)
          (map-set map_draw_jackpot_count round u0)
          (ok (handle_step_draw))
        )
        (err ERR_WAIT_TO_DRAW)
      )
      (err ERR_INVALID_STATE)
    )
  )
)

(define-private (calc_power_play)
  (let ((rand_num (get-random-by-block-height (+ (var-get m_end_at) u4))) (can_10x (<= (var-get m_jackpot) (* (var-get m_price) POWER_PLAY_10x_THRESHOLD_FACTOR))) (target_num (+ (mod (/ rand_num u10) (if can_10x u43 u42)) u1))) (if (<= target_num u24) u2 (if (<= target_num u37) u3 (if (<= target_num u40) u4 (if (<= target_num u42) u5 u10))))))

(define-private (calc_draw_ball_value)
  (let
    (
      (end_at (var-get m_end_at))
      (rand_1 (get-random-by-block-height (+ end_at u1)))
      (rand_2 (get-random-by-block-height (+ end_at u2)))
      (rand_3 (get-random-by-block-height (+ end_at u3)))
      (w1 (+ (mod (/ rand_1 u100) u69) u1))
      (t1 (map-set map_white w1 true))
      (w2 (if (begin (var-set m_draw_white u0) (fold G1 LIST_1_10 rand_2) (> (var-get m_draw_white) u0)) (var-get m_draw_white) (begin (fold G2 LIST_5 true) (var-get m_draw_white))))
      (w3 (if (begin (var-set m_draw_white u0) (fold G1 LIST_1_10 rand_3) (> (var-get m_draw_white) u0)) (var-get m_draw_white) (begin (fold G2 LIST_5 true) (var-get m_draw_white))))
      (w4 (if (begin (var-set m_draw_white u0) (fold G1 LIST_11_20 rand_1) (> (var-get m_draw_white) u0)) (var-get m_draw_white) (begin (fold G2 LIST_5 true) (var-get m_draw_white))))
      (w5 (if (begin (var-set m_draw_white u0) (fold G1 LIST_11_20 rand_2) (> (var-get m_draw_white) u0)) (var-get m_draw_white) (begin (fold G2 LIST_5 true) (var-get m_draw_white))))
      ;;
      (wl (list w1 w2 w3 w4 w5))
      ;; bubble sort white balls
      (res_1 (fold S wl { i: u0, m: u70, mi: u0, ov: u0 })) ;; i(index), m(min_value), mi(min_index), ov(omit_value)
      (res_2 (fold S wl { i: u0, m: u70, mi: u0, ov: (+ (get ov res_1) (pow u10 (get mi res_1)))}))
      (res_3 (fold S wl { i: u0, m: u70, mi: u0, ov: (+ (get ov res_2) (pow u10 (get mi res_2)))}))
      (res_4 (fold S wl { i: u0, m: u70, mi: u0, ov: (+ (get ov res_3) (pow u10 (get mi res_3)))}))
      (res_5 (fold S wl { i: u0, m: u70, mi: u0, ov: (+ (get ov res_4) (pow u10 (get mi res_4)))}))
      (red (+ (mod (/ rand_3 u1000000) u26) u1))
    )
    (filter R LIST_69)
    (+ (get m res_1)
       (* (get m res_2) u100)
       (* (get m res_3) u10000)
       (* (get m res_4) u1000000)
       (* (get m res_5) u100000000)
       (* red u10000000000)
    )
  )
)

(define-private (G1 (i uint) (r uint))
  (if (is-eq r u0) u0 (let ((d (/ r (pow u10 i))) (w (+ (mod d u69) u1))) (if (and (is-none (map-get? map_white w)) (> d u0)) (begin (map-set map_white w true) (var-set m_draw_white w) u0) r))))

(define-private (G2 (w uint) (b bool))
  (if (and b (is-none (map-get? map_white w))) (begin (map-set map_white w true) (var-set m_draw_white w) false) b))

(define-private (R (i uint))
  (map-delete map_white i))

;; bubble sort white balls loop. i(index), m(min_value), mi(min_index), ov(omit_value)
(define-private (S (num uint) (user_data { i: uint, m: uint, mi: uint, ov: uint }))
  (let
    (
      (i (get i user_data))
      (ov (get ov user_data))
    )
    (if (and (is-eq (mod (/ ov (pow u10 i)) u10) u0)
             (< num (get m user_data)))
      (merge user_data {
        i: (+ i u1),
        m: num,
        mi: i,
      })
      (merge user_data {
        i: (+ i u1)
      })
    )
  )
)

(define-private (handle_step_draw)
  (let
    (
      (round (var-get m_round))
      (bet_bunch_count (unwrap-panic (map-get? map_bet_bunch_count round)))
      (draw_bunch_index (var-get m_draw_bunch_index))
      (contract_balance (stx-get-balance (as-contract tx-sender)))
      (draw_caller_reward (var-get m_draw_caller_reward))
      (caller tx-sender)
      (comb_value (+ (* (var-get m_price) u1000000000000) (var-get m_draw_ball_value)))
    )

    ;; reward the caller to cover its fee cost
    (and (>= contract_balance draw_caller_reward)
         (unwrap! (as-contract (stx-transfer? draw_caller_reward tx-sender caller)) false)
    )
    
    ;; draw 3 bunch
    (fold D
      (default-to (list) (map-get? map_bet_bunch { round: round, index: draw_bunch_index }))
      (+ (* contract_balance u10000000000000000000) comb_value)
    )
    (fold D
      (default-to (list) (map-get? map_bet_bunch { round: round, index: (+ draw_bunch_index u1) }))
      (+ (* (stx-get-balance (as-contract tx-sender)) u10000000000000000000) comb_value)  ;; DON't use contract_balance, not real-time
    )
    (fold D
      (default-to (list) (map-get? map_bet_bunch { round: round, index: (+ draw_bunch_index u2) }))
      (+ (* (stx-get-balance (as-contract tx-sender)) u10000000000000000000) comb_value)
    )
    (fold D
      (default-to (list) (map-get? map_bet_bunch { round: round, index: (+ draw_bunch_index u3) }))
      (+ (* (stx-get-balance (as-contract tx-sender)) u10000000000000000000) comb_value)
    )
    (fold D
      (default-to (list) (map-get? map_bet_bunch { round: round, index: (+ draw_bunch_index u4) }))
      (+ (* (stx-get-balance (as-contract tx-sender)) u10000000000000000000) comb_value)
    )
    
    (var-set m_draw_bunch_index (+ draw_bunch_index u5))

    ;; Distribute jackpot award when draw finish as the jackpot may be shared by more than 1 players.
    ;; The contract balance may be unenough at this moment (very rare, reward the remain balance to it/them).
    (if (and (>= (var-get m_draw_bunch_index) bet_bunch_count)
             (is-eq (len (default-to (list) (map-get? map_bet_bunch { round: round, index: (var-get m_draw_bunch_index)}))) u0))
      (if (> (default-to u0 (map-get? map_draw_jackpot_count round)) u0)
        (step_reward_jackpot round)
        (draw_end true)
      )
      true
    )
  )
)

;; D(draw_one_loop), b(bet_info), d(draw_bv), a(award_mul), r(round), ba(balance), u(user_value)=contract_balance * 10000000000000000000 + bet_price * 1000000000000 + draw_ball_value. Contract balance may be unenough during draw process, will not reward the player in this very rare situation.
(define-private (D (b { p: principal, pbv: uint }) (u uint))
  (let ((pbv (get pbv b)) (d (mod u u1000000000000)))
    (match (element-at AL (+ (if (is-eq (/ d u10000000000) (mod (/ pbv u10000000000) u100)) u6 u0) (mod (/ (fold L 0x000000000000000000 (+ (* pbv u1000000000000000) (* d u1000))) u100) u10))) a ;; red*6 + white-same-count
      (if (> a u0)
        (let ((r (var-get m_round)) (n (+ (default-to u0 (map-get? map_draw_win_count r)) u1)) (ba (/ u u10000000000000000000)) (award (/ (* a (/ (mod u u10000000000000000000) u1000000000000) (if (> pbv u1000000000000) (if (is-eq a u5000000) u2 (var-get m_draw_power_play)) u1)) u10)))
        (if (>= ba award) (begin (unwrap! (as-contract (stx-transfer? award tx-sender (get p b))) u) (map-set map_draw_win_count r n) (map-set map_draw_win {round: r, index: n} {p: (get p b), wv: (+ (get pbv b) (* award u100000000000000)) }) (- u (* award u10000000000000000000))) u))
      u)
      ;; jackpot
      (let ((r (var-get m_round)) (n (+ (default-to u0 (map-get? map_draw_jackpot_count r)) u1))) (map-set map_draw_jackpot_count r n) (map-set map_draw_jackpot { round: r, index: n } (get p b) ) u))))

;; loop to check how many same white balls the player bet with draw result. u(user_value) = pbv*1000000000000000 + draw_bv*1000 + same_count*100 + pbv_index*10 + draw_bv_index
(define-private (L (e (buff 1)) (u uint))
  (if (and (< (mod u u10) u5) (< (mod u u100) u50)) (let ((p (mod (/ (/ u u1000000000000000) (pow u100 (mod (/ u u10) u10))) u100)) (d (mod (/ (mod (/ u u1000) u1000000000000) (pow u100 (mod u u10))) u100))) (if (< p d) (+ u u10) (if (> p d) (+ u u1) (+ u u111)))) u))

(define-private (step_reward_jackpot (round uint))
  (let
    (
      (jackpot_index (var-get m_draw_jackpot_reward_index))
      (jackpot_count (unwrap-panic (map-get? map_draw_jackpot_count round)))
    )
    (if (is-eq jackpot_index u1)
      (let
        (
          (remain_for_caller (* (var-get m_draw_caller_reward) u1000))
          (contract_balance (stx-get-balance (as-contract tx-sender)))
          (max_award (if (> contract_balance remain_for_caller) (- contract_balance remain_for_caller) u0))
          (origin_jackpot (var-get m_jackpot))
          (jackpot_reward (if (>= max_award origin_jackpot) origin_jackpot max_award))
        )
        (var-set m_draw_jackpot_ave_award (/ jackpot_reward jackpot_count))
        (fold reward_jackpot_loop LIST_20 u1)
        (if (<= jackpot_count u20)
          (draw_end true)
          (var-set m_draw_jackpot_reward_index u21)  ;; too many jackpot players, reward them in next step_draw call.
        )
      )
      ;; jackpot players > 20, nearly impossible, but we still need deal this situation
      (begin
        (fold reward_jackpot_loop BUNCH_NUM_LIST jackpot_index)
        (fold reward_jackpot_loop BUNCH_NUM_LIST (+ jackpot_index BUNCH_CAPACITY))
        (fold reward_jackpot_loop BUNCH_NUM_LIST (+ jackpot_index BUNCH_CAPACITY BUNCH_CAPACITY))
        (if (>= (+ jackpot_index (* BUNCH_CAPACITY u3)) jackpot_count)
          (draw_end true)
          (var-set m_draw_jackpot_reward_index (+ jackpot_index (* BUNCH_CAPACITY u3)))
        )
      )
    )
  )
)

(define-private (reward_jackpot_loop (element uint) (index uint))
  (let
    (
      (ave_award (var-get m_draw_jackpot_ave_award))
    )
    (match (map-get? map_draw_jackpot { round: (var-get m_round), index: index }) player
      (begin
        (and (> ave_award u0)
             (unwrap! (as-contract (stx-transfer? ave_award tx-sender player)) index)
        )
        (+ index u1)
      )
      index
    )
  )
)

(define-private (draw_end (success bool))
  (let
    (
      (round (var-get m_round))
      (start_balance (var-get m_start_balance))
      (cur_balance (stx-get-balance (as-contract tx-sender)))
    )
    (map-set map_history_summary
      round
      {
        start_at: (default-to u0 (get-block-info? time (var-get m_start_at))),
        end_at: (default-to u0 (get-block-info? time (var-get m_end_at))),
        price: (var-get m_new_price),
        bet_count: (default-to u0 (map-get? map_total_bet_count round)),
        win_count: (default-to u0 (map-get? map_draw_win_count round)),
        jackpot_count: (default-to u0 (map-get? map_draw_jackpot_count round)),
        ball_value: (var-get m_draw_ball_value),
        power_play: (var-get m_draw_power_play),
        draw_bunch_index: (var-get m_draw_bunch_index),
        success: success,
      }
    )

    (if success
      (print "draw end successfully")
      (print "draw end due to some error")
    )

    ;; whether need withdraw
    (and (var-get m_need_withdrawal)
         (var-set m_need_withdrawal false)
         (handle_withdraw)
    )

    ;; whether need update price
    (and (> (var-get m_new_price) u0)
         (var-set m_jackpot (/ (* (var-get m_jackpot) (var-get m_new_price)) (var-get m_price)))
         (var-set m_price (var-get m_new_price))
         (var-set m_new_price u0)
    )

    ;; if (balance >= MIN_AWARD_POOL) then
    ;;   if success then
    ;;     if has-profit then
    ;;       reward owner, increase jackpot
    ;;     else
    ;;       if jackpot-is-rewarded then
    ;;         reset-jackpot
    ;;       else
    ;;         jackpot = min(jackpot, balance)
    ;;       end
    ;;     end
    ;;   else
    ;;     jackpot = min(jackpot, balance)
    ;;   end
    ;;   start-next-round
    ;; else
    ;;   start-next-round, wait owner to deposit
    (if (>= cur_balance (* (var-get m_price) MIN_AWARD_POOL_FACTOR))
      (begin
        (if success
          (if (> cur_balance start_balance) ;; has-profit
            (begin
              (unwrap! (as-contract (stx-transfer? (/ (* (- cur_balance start_balance) u50) u100) tx-sender OWNER)) false)
              (var-set m_jackpot (+ (var-get m_jackpot) (/ (* (- cur_balance start_balance) u20) u100)))
            )
            (if (> (unwrap-panic (map-get? map_draw_jackpot_count round)) u0)
              (var-set m_jackpot (* (var-get m_price) DEFAULT_JACKPOT_FACTOR))
              (and (< cur_balance (var-get m_jackpot)) (var-set m_jackpot cur_balance))
            )
          )
          ;; not success
          (and (< cur_balance (var-get m_jackpot)) (var-set m_jackpot cur_balance))
        )
        ;; start next round for bet
        (var-set m_state STATE_BET)
        (var-set m_round (+ round u1))
        (var-set m_start_balance (stx-get-balance (as-contract tx-sender)))
      )
      ;; balance unenough
      (begin
        (var-set m_state STATE_FUNDING)
        (var-set m_round (+ round u1))
      )
    )

    ;; clean up
    (var-set m_start_at u0)
    (var-set m_end_at u0)
    (var-set m_omit_times u0)
    (reset_draw_members)
  )
)

(define-private (reset_draw_members)
  (begin
    (var-set m_draw_white u0)
    (var-set m_draw_power_play u0)
    (var-set m_draw_ball_value u0)
    (var-set m_draw_bunch_index u0)
    (var-set m_draw_jackpot_reward_index u1)
    (var-set m_draw_jackpot_ave_award u0)
  )
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; draw related end ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; deposit/withdraw related begin ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-public (deposit (deposit_count uint))
  (let
    (
      (min_award_pool (* (var-get m_price) MIN_AWARD_POOL_FACTOR))
      (cur_balance (stx-get-balance (as-contract tx-sender)))
      (min_need_depot (if (>= cur_balance min_award_pool) u0 (- min_award_pool cur_balance)))
    )
    (asserts! (is-eq tx-sender OWNER) (err ERR_NO_AUTHORITY))
    (asserts! (is-eq (var-get m_state) STATE_FUNDING) (err ERR_INVALID_STATE))
    (asserts! (and (> deposit_count u0) (>= deposit_count min_need_depot)) (err ERR_DEPOSIT_COUNT_INVALID))
    (asserts! (>= (stx-get-balance tx-sender) deposit_count) (err ERR_BALANCE_NOT_ENOUGH))
    ;;
    (unwrap! (stx-transfer? deposit_count tx-sender (as-contract tx-sender)) (err ERR_TRANSFER_STX))
    ;; safely reset
    (var-set m_state STATE_BET)
    (var-set m_start_at u0)
    (var-set m_end_at u0)
    (var-set m_start_balance (stx-get-balance (as-contract tx-sender)))
    (var-set m_omit_times u0)
    (reset_draw_members)
    ;;
    (ok true)
  )
)

(define-public (withdraw)
  (let
    (
      (round (var-get m_round))
      (state (var-get m_state))
      (last_round_bets (default-to u0 (map-get? map_total_bet_count (- round u1))))
    )
    (asserts! (is-eq tx-sender OWNER) (err ERR_NO_AUTHORITY))
    ;; if last round has enough bets, not allow withdraw
    (asserts! (<= last_round_bets BET_COUNT_THRERSHOLD_TO_WITHDRAW) (err ERR_NOT_ALLOW_WITHDRAW))

    (print (var-get m_state))

    (if (is-eq state STATE_FUNDING)
      (ok (handle_withdraw))
      (if (and (is-eq state STATE_BET) (is-eq (default-to u0 (map-get? map_total_bet_count round)) u0))
        (begin
          (handle_withdraw)
          (var-set m_state STATE_FUNDING)
          (ok true)
        )
        (ok (var-set m_need_withdrawal true)) ;; wait for draw finish
      )
    )
  )
)

(define-private (handle_withdraw)
  (let
    (
      (balance (stx-get-balance (as-contract tx-sender)))
    )
    (and (> balance u0) (unwrap! (as-contract (stx-transfer? balance tx-sender OWNER)) false))
  )
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; deposit/withdraw related end ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; misc begin ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-public (update_price (price uint))
  (let
    (
      (state (var-get m_state))
      (round (var-get m_round))
      (last_round_bets (default-to u0 (map-get? map_total_bet_count (- round u1))))
      (cur_price (var-get m_price))
    )
    (asserts! (is-eq tx-sender OWNER) (err ERR_NO_AUTHORITY))
    (asserts! (<= price u2000000) (err ERR_INVALID_PRICE))
    (unwrap! (stx-burn? UPDATE_PRICE_COST tx-sender) (err ERR_BALANCE_NOT_ENOUGH))

    (if (is-eq (var-get m_state) STATE_FUNDING)
      (and
        (var-set m_jackpot (/ (* (var-get m_jackpot) price) (var-get m_price)))
        (var-set m_price price)
      )
      (var-set m_new_price price)
    )
    
    (ok true)
  )
)

(define-public (update_draw_caller_reward (reward uint))
  (begin
    (asserts! (is-eq tx-sender OWNER) (err ERR_NO_AUTHORITY))
    (asserts! (and (< reward u100000)) (err ERR_INVALID_REWARD))
    (var-set m_draw_caller_reward reward)
    (ok true)
  )
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; misc end ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; random generator begin ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; reference: https://github.com/citycoins/citycoin/tree/main/contracts
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

(define-read-only (get-random-by-block-height (block-index uint))
  (buff-to-uint-le (lower-16-le (unwrap-panic (get-block-info? burnchain-header-hash block-index))))
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; random generator end ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; web use begin ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-read-only (get_summary (player_opt (optional principal)))
  (let
    (
      (round (var-get m_round))
      (start_at (var-get m_start_at))
      (end_at (var-get m_end_at))
      (player_bet_bunch_count
        (if (is-some player_opt)
          (default-to u0 (map-get? map_player_bet_bunch_count { round: round, p: (unwrap-panic player_opt)}))
          u0    
        )
      )
      (player_latest_bet_bunch
        (if (is-some player_opt)
          (map-get? map_player_bet_bunch { round: round, p: (unwrap-panic player_opt), index: player_bet_bunch_count })
          none
        )
      )
    )
    {
      state: (var-get m_state),
      round: round,
      ;; start_at: start_at,
      start_time: (default-to u0 (get-block-info? time start_at)),
      end_at: end_at,
      end_time: (default-to u0 (get-block-info? time end_at)),
      price: (var-get m_price),
      jackpot: (var-get m_jackpot),
      total_bet_count: (default-to u0 (map-get? map_total_bet_count round)),
      bet_bunch_count: (default-to u0 (map-get? map_bet_bunch_count round)),
      player_bet_bunch_count: player_bet_bunch_count,
      player_latest_bet_bunch: player_latest_bet_bunch,
      block_height: block-height,
      draw_cd: DRAW_CD_BLOCKS,
      draw_caller_reward: (var-get m_draw_caller_reward),
      draw_power_play: (var-get m_draw_power_play),
      draw_ball_value: (var-get m_draw_ball_value),
      draw_bunch_index: (var-get m_draw_bunch_index),
      balance: (stx-get-balance (as-contract tx-sender)),
    }
  )
)

(define-read-only (get_history_summary (round uint))
  (map-get? map_history_summary round)
)

(define-read-only (get_bet_bunch_count (round uint))
  (map-get? map_bet_bunch_count round)
)

(define-read-only (get_bet_bunch (round uint) (index uint))
  (map-get? map_bet_bunch { round: round, index: index })
)

(define-read-only (get_win_count (round uint))
  (map-get? map_draw_win_count round)
)

(define-read-only (get_win_list (key_list (list 25 { round: uint, index: uint })))
  (map get_win_item key_list)
)
(define-read-only (get_win_item (key { round: uint, index: uint }))
  (map-get? map_draw_win key)
)

(define-read-only (get_jackpot_count (round uint))
  (map-get? map_draw_jackpot_count round)
)
(define-read-only (get_jackpot_list (key_list (list 25 { round: uint, index: uint })))
  (map get_jackpot_item key_list)
)
(define-read-only (get_jackpot_item (key { round: uint, index: uint }))
  (map-get? map_draw_jackpot key)
)

(define-read-only (get_player_bet_bunch_count (round uint) (player principal))
  (default-to u0 (map-get? map_player_bet_bunch_count { round: round, p: player }))
)

(define-read-only (get_player_bet_bunch (round uint) (player principal) (index uint))
  (map-get? map_player_bet_bunch { round: round, p: player, index: index })
)

(define-public (manual_skip_draw)
  (begin
    (asserts! (is-eq tx-sender OWNER) (err ERR_NO_AUTHORITY))
    (asserts! (or (is-eq (var-get m_state) STATE_WAIT_DRAW) (is-eq (var-get m_state) STATE_DRAW)) (err ERR_INVALID_STATE))
    (asserts! (> block-height (+ (var-get m_end_at) MANUAL_SKIP_DRAW_BLOCKS)) (err ERR_CANNOT_MANUAL_SKIP_DRAW_NOW))
    (ok (draw_end false))
  )
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; web use end ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; initialize related begin ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-private (initialize)
  (begin
    (print "initialize")
    (var-set m_state STATE_FUNDING)
    (var-set m_round u1)
    (var-set m_price u20)
    (var-set m_draw_caller_reward u500)
    (var-set m_jackpot (* (var-get m_price) DEFAULT_JACKPOT_FACTOR))
  )
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; initialize related end ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(initialize)
