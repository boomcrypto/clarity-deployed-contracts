;; Bitcoin decides whether members can win pk.btc with only 1 $ORDI.
;; https://lasereye.vip

(define-constant ERROR_INVALID_STATE 1001)
(define-constant ERROR_END_BET 1002)
(define-constant ERROR_HAS_BET 1003)
(define-constant ERR_NOT_MEMBER 1004)
(define-constant ERR_TRANSFER_ORDI 1005)
(define-constant ERROR_SLICE 1006)
(define-constant ERROR_AS_MAX_LEN 1007)
(define-constant ERROR_BET_COUNT_TOO_LESS 1008)
(define-constant ERROR_EXCEED_MAX_BET_COUNT 1009)
(define-constant ERROR_DRAW_CD 1010)
(define-constant ERROR_GET_BLOCK_INFO 1011)
(define-constant ERROR_RETURN_NAME 1012)
(define-constant ERROR_BTC_HEIGHT_TOO_SMALL 1013)
(define-constant ERROR_BTC_HEIGHT_TOO_BIG 1014)

(define-constant ORDI_PRICE_PER_BET u100000000)         ;; 1 $ORDI/bet
(define-constant MIN_BET_TO_START_ROUND u5)             ;; Min 5 bets to start a round
(define-constant MAX_TOTAL_BET_PER_ROUND u30000)        ;; Max 30,000 bets per round
(define-constant BET_BLOCKS u124)                       ;; 1) 124 blocks(about 21 hours) for users to bet
(define-constant WAIT_TO_END_BET_BLOCKS u6)             ;; 2) Wait for 6 blocks(do nothing), then user can call end_bet to enter wait-for-draw state
(define-constant WAIT_TO_DRAW_BLOCKS u14)               ;; 3) Wait 14 blocks, then user can call draw
(define-constant BYTE_INDEX_FOR_GEN_JACKPOT u25)        ;; Use header-hash's 51th character(25th byte) to generate jockpot
(define-constant RETURN_NAME_MIN_BLOCK u111111)         ;; Can get back name after this block
(define-constant RETURN_NAME_MAX_ROUND_BLOCKS u1000)    ;; If round still not over after 1000 blocks since start, founder can get back name
(define-constant RETURN_NAME_ADDRESS 'SP1NJV4CNF5GHCP9PMCDH5FG6X5V1XM2JCF8811WA)
(define-constant FOUNDER 'SP1NJV4CNF5GHCP9PMCDH5FG6X5V1XM2JCF8811WA)

(define-constant STATE_IDLE u1)
(define-constant STATE_BET u2)
(define-constant STATE_WAIT_TO_DRAW u3)
(define-constant STATE_HAS_WINNER u4)
(define-constant STATE_FREEZED u5)
(define-constant BUNCH_CAPACITY u200)
(define-constant LIST_13 (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13))
(define-constant HEX_CHARS "0123456789abcdef")
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

(define-data-var m_round uint u1)
(define-data-var m_state uint STATE_IDLE)
(define-data-var m_stx_start_at uint u0)
(define-data-var m_stx_end_at uint u0)
(define-data-var m_btc_end_at uint u0)

;; round => total-bet-count
(define-map map_bet_count
  uint
  uint
)

(define-map map_bet_bunch
  { round: uint, index: uint }  ;; starts from 0
  (list 200 {
      p: principal,
      dv: (string-ascii 5)
    }
  )
)

(define-map map_user_bet
  { round: uint, p: principal }
  (list 200 (string-ascii 5))
)

(define-map map_bet_2_users
  { round: uint, dv: (string-ascii 5) }
  (list 3 principal)
)

(define-map map_history
  uint
  {
    start_at_stx: uint,
    end_at_stx: uint,
    end_at_btc: uint, 
    jackpot: (string-ascii 5),
    bet_count: uint,
    hashes: (list 5 (buff 32)),
    winners: (list 3 principal),
  }
)

(define-public (bet (bet_list (list 200 (string-ascii 5))))
  (let
    (
      (caller contract-caller)
      (bh block-height)
      (state (var-get m_state))
      (round (var-get m_round))
      (round_bet_count (default-to u0 (map-get? map_bet_count round)))
      (bet_item_list (map build_bet_item bet_list))
      (item_count (len bet_item_list))
      (tid (default-to u0 (contract-call? .laser-eyes-v5 get_id_by_player caller)))
      (ordi_cost (* item_count ORDI_PRICE_PER_BET))
      (bunch_index (/ round_bet_count BUNCH_CAPACITY))
      (cur_bunch (default-to (list) (map-get? map_bet_bunch { round: round, index: bunch_index })))
      (cur_bunch_len (len cur_bunch))
      (new_round_bet_count (+ (default-to u0 (map-get? map_bet_count round)) item_count))
    )
    (if (is-eq state STATE_IDLE)
      (and
        (var-set m_state STATE_BET)
        (var-set m_stx_start_at bh)
        (asserts! (>= item_count MIN_BET_TO_START_ROUND) (err ERROR_BET_COUNT_TOO_LESS))
      )
      (if (is-eq state STATE_BET)
        (and
          (asserts! (<= bh (+ (var-get m_stx_start_at) BET_BLOCKS)) (err ERROR_END_BET))
          (asserts! (>= item_count u1) (err ERROR_BET_COUNT_TOO_LESS))
        )
        (asserts! false (err ERROR_INVALID_STATE))
      )
    )
    (asserts! (> tid u0) (err ERR_NOT_MEMBER))
    (asserts! (<= new_round_bet_count MAX_TOTAL_BET_PER_ROUND) (err ERROR_EXCEED_MAX_BET_COUNT))
    (asserts! (is-none (map-get? map_user_bet { round: round, p: caller })) (err ERROR_HAS_BET))
    (unwrap! (contract-call? .ordi transfer ordi_cost caller FOUNDER none) (err ERR_TRANSFER_ORDI))
    (map-set map_bet_count round new_round_bet_count)
    (if (<= (+ cur_bunch_len item_count) BUNCH_CAPACITY)
      (map-set map_bet_bunch
        { round: round, index: bunch_index }
        (unwrap! (as-max-len? (concat cur_bunch bet_item_list) u200) (err ERROR_AS_MAX_LEN))
      )
      (let
        (
          (combine_list (unwrap! (as-max-len? (concat cur_bunch bet_item_list) u400) (err ERROR_AS_MAX_LEN)))
        )
        (map-set map_bet_bunch
          { round: round, index: bunch_index }
          (unwrap! (as-max-len? (unwrap! (slice? combine_list u0 BUNCH_CAPACITY) (err ERROR_SLICE)) u200) (err ERROR_AS_MAX_LEN))
        )
        (map-set map_bet_bunch
          { round: round, index: (+ bunch_index u1) }
          (unwrap! (as-max-len? (unwrap! (slice? combine_list BUNCH_CAPACITY (len combine_list)) (err ERROR_SLICE)) u200) (err ERROR_AS_MAX_LEN))
        )
      )
    )
    (map-set map_user_bet { round: round, p: caller } bet_list)
    (fold walk_user_bet bet_item_list round)
    (ok item_count)
  )
)

(define-public (end_bet (btc_height uint))
  (let
    (
      (caller contract-caller)
      (bh block-height)
    )
    (asserts! (is-eq (var-get m_state) STATE_BET) (err ERROR_INVALID_STATE))
    (asserts! (> bh (+ (var-get m_stx_start_at) BET_BLOCKS WAIT_TO_END_BET_BLOCKS)) (err ERROR_END_BET))
    (asserts! (is-none (get-burn-block-info? header-hash (+ btc_height u7))) (err ERROR_BTC_HEIGHT_TOO_SMALL))
    (asserts! (is-some (get-burn-block-info? header-hash (- btc_height u7))) (err ERROR_BTC_HEIGHT_TOO_BIG))
    (var-set m_btc_end_at (fold f LIST_13 (+ btc_height u6))) ;; search the latest dealt bitcoin height in [btc_height - 6, btc_height + 6]
    (var-set m_stx_end_at bh)
    (var-set m_state STATE_WAIT_TO_DRAW)
    (ok true)
  )
)

(define-public (draw)
  (let
    (
      (caller contract-caller)
      (end_at_btc (var-get m_btc_end_at))
      (hash1 (unwrap! (get-burn-block-info? header-hash (+ end_at_btc u6)) (err ERROR_GET_BLOCK_INFO)))
      (hash2 (unwrap! (get-burn-block-info? header-hash (+ end_at_btc u7)) (err ERROR_GET_BLOCK_INFO)))
      (hash3 (unwrap! (get-burn-block-info? header-hash (+ end_at_btc u8)) (err ERROR_GET_BLOCK_INFO)))
      (hash4 (unwrap! (get-burn-block-info? header-hash (+ end_at_btc u9)) (err ERROR_GET_BLOCK_INFO)))
      (hash5 (unwrap! (get-burn-block-info? header-hash (+ end_at_btc u10)) (err ERROR_GET_BLOCK_INFO)))
      (jackpot (fold gen_ascii (list hash1 hash2 hash3 hash4 hash5) ""))
      (winners (default-to (list) (map-get? map_bet_2_users { round: (var-get m_round), dv: jackpot })))
    )
    (asserts! (is-eq (var-get m_state) STATE_WAIT_TO_DRAW) (err ERROR_INVALID_STATE))
    (asserts! (>= block-height (+ (var-get m_stx_end_at) WAIT_TO_DRAW_BLOCKS)) (err ERROR_DRAW_CD))
    (print {
      title: "draw",
      jackpot: jackpot,
      winners: winners,
    })
    (map-set map_history (var-get m_round) {
      start_at_stx: (var-get m_stx_start_at),
      end_at_stx: (var-get m_stx_end_at),
      end_at_btc: end_at_btc,
      jackpot: jackpot,
      bet_count: (default-to u0 (map-get? map_bet_count (var-get m_round))),
      hashes: (list hash1 hash2 hash3 hash4 hash5),
      winners: winners,
    })
    (if (> (len winners) u0)
      (begin
        (try! (contract-call? .lottery-episode-2-prize set_winners winners))
        (var-set m_state STATE_HAS_WINNER)
      )
      (begin
        (var-set m_round (+ (var-get m_round) u1))
        (var-set m_state STATE_IDLE)
        (var-set m_stx_start_at u0)
        (var-set m_stx_end_at u0)
        (var-set m_btc_end_at u0)
      )
    )
    (ok true)
  )
)

;; Can return name in two situations:
;; 1. Block height exceeds RETURN_NAME_MIN_BLOCK, and in idle state. Only RETURN_NAME_ADDRESS can call(in case that rounder wants to continue, but someone break).
;; 2. 1000 blocks passed since round-start. Probably stuck due to bug, allow return name to rescue. Anyone can call.
(define-public (return_name)
  (if (or (is-eq (var-get m_state) STATE_HAS_WINNER) (is-eq (var-get m_state) STATE_FREEZED))
    (err ERROR_RETURN_NAME)
    (if (is-eq (var-get m_state) STATE_IDLE)
      (if (>= block-height RETURN_NAME_MIN_BLOCK)
        (begin
          (asserts! (is-eq contract-caller RETURN_NAME_ADDRESS) (err ERROR_RETURN_NAME))
          (var-set m_state STATE_FREEZED)
          (contract-call? .lottery-episode-2-prize return_name RETURN_NAME_ADDRESS)
        )
        (err ERROR_RETURN_NAME)
      )
      (if (>= block-height (+ (var-get m_stx_start_at) RETURN_NAME_MAX_ROUND_BLOCKS)) ;; stuck
        (begin
          (var-set m_state STATE_FREEZED)
          (contract-call? .lottery-episode-2-prize return_name RETURN_NAME_ADDRESS)
        )
        (err ERROR_RETURN_NAME)
      )
    )
  )
)

(define-read-only (get_summary)
  {
    bh: block-height,
    round: (var-get m_round),
    state: (var-get m_state),
    start_at: (var-get m_stx_start_at),
    end_at: (var-get m_stx_end_at),
    end_at_btc: (var-get m_btc_end_at),
    bet_count: (default-to u0 (map-get? map_bet_count (var-get m_round))),
  }
)

(define-read-only (get_summary_with_user (user principal))
  {
    base: (get_summary),
    tid: (contract-call? .laser-eyes-v5 get_id_by_player user),
    stx: (stx-get-balance user),
    ordi: (unwrap-panic (contract-call? .ordi get-balance user)),
    user_bet: (map-get? map_user_bet { round: (var-get m_round), p: user }),
  }
)

(define-read-only (get_bet_bunch (round uint) (index uint))
  (map-get? map_bet_bunch { round: round, index: index })
)

(define-read-only (get_user_bet (round uint) (user principal))
  (map-get? map_user_bet { round: round, p: user })
)

(define-read-only (get_same_bet_players (round uint) (dv (string-ascii 5)))
  (map-get? map_bet_2_users { round: round, dv: dv })
)

;; round = 0 means current round
(define-read-only (get_history (round uint))
  (let
    (
      (target_round (if (> round u0) round (var-get m_round)))
    )
    {
      t: target_round,
      v: (map-get? map_history target_round),
    }
  )
)

(define-read-only (get_history_with_user (round uint) (user principal))
  {
    base: (get_history round),
    user_bet: (map-get? map_user_bet { round: (if (> round u0) round (var-get m_round)), p: user }),
  }
)

(define-private (build_bet_item (dv (string-ascii 5)))
  { p: contract-caller, dv: dv }
)

(define-private (walk_user_bet (item { p: principal, dv: (string-ascii 5) }) (round uint))
  (begin
    (match (map-get? map_bet_2_users { round: round, dv: (get dv item) }) pList
      (if (< (len pList) u3)
        (map-set map_bet_2_users
          { round: round, dv: (get dv item) }
          (unwrap-panic (as-max-len? (concat pList (list (get p item))) u3)))
        false
      )
      (map-set map_bet_2_users { round: round, dv: (get dv item) } (list (get p item)))
    )
    round
  )
)

(define-private (gen_ascii (seed (buff 32)) (result (string-ascii 5)))
  (match (element-at? seed BYTE_INDEX_FOR_GEN_JACKPOT) byte
    (match (index-of BUFF_TO_BYTE byte) index
      (unwrap-panic (as-max-len? (concat result (unwrap-panic (element-at? HEX_CHARS (/ index u16)))) u5))
      result
    )
    result
  )
)

(define-private (f (index uint) (cur_btc_height uint))
  (match (get-burn-block-info? header-hash cur_btc_height) hash
    cur_btc_height
    (- cur_btc_height u1)
  )
)

(contract-call? .lottery-episode-2-prize set_lottery_contract (as-contract tx-sender))
