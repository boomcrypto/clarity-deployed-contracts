(define-constant ERR_NO_AUTHORITY u6001)
(define-constant ERR_FEE_INVALID u6002)
(define-constant ERR_TRANSFER_STX u6003)
(define-constant ERR_PRICE_INVALID u6004)
(define-constant ERR_PRICE_NOT_SAME u6005)
(define-constant ERR_BALANCE_UNENOUGH u6006)
(define-constant ERR_TOKEN_NOT_EXIST u6101)
(define-constant ERR_LIST_NOT_FOUND u6102)
(define-constant ERR_ACCOUNT_ALREADY_ASSOCIATED u6103)
(define-constant ERR_BID_EXPIRED u6201)
(define-constant ERR_BID_TOO_MANY u6202)
(define-constant ERR_BID_NOT_FOUND u6203)
(define-constant ERR_BID_POS_NOT_SAME u6204)
(define-constant ERR_BID_PRICE_TOO_LOW u6205)
(define-constant ERR_BID_PERIOD_INVALID u6206)
(define-constant ERR_BID_DEPOSIT_UNENOUGH u6207)

(define-constant LIST_TOKEN_BIDS (list u1 u2 u3))
(define-constant LIST_PLAYER_BIDS (list u1 u2 u3 u4 u5))
(define-constant MAX_STAT_COUNT u1000)
(define-constant FEE u50)
(define-constant MIN_PRICE u1000000)
(define-constant MAX_PRICE u9999999000000)
(define-constant MIN_BID_DAYS u1)
(define-constant MAX_BID_DAYS u100)

(define-data-var m_tmp_t uint u0)
(define-data-var m_tmp_tid (optional uint) none)
(define-data-var m_tmp_p uint u0)
(define-data-var m_tmp_player (optional principal) none)

(define-map map_list_info
  uint
  {
    price: uint,
    owner: principal,
  }
)

(define-map map_token_bid
  { tid: uint, index: uint }
  {
    player: principal,
    price: uint,
    at: uint,
    expiration: uint,
  }
)

(define-map map_player_bid
  { player: principal, index: uint }
  {
    tid: uint,
    price: uint,
    at: uint,
    expiration: uint,
  }
)

(define-map map_bidder_deposit
  principal
  uint
)

(define-data-var m_stat_list_index uint u1)
(define-data-var m_stat_list_shift uint u0)
(define-map map_stat_list
  uint
  uint
)

(define-data-var m_stat_trade_index uint u1)
(define-data-var m_stat_trade_shift uint u0)
(define-map map_stat_trade
  uint
  uint
)

(define-public (list_nft (tid uint) (price uint))
  (let
    (
      (sys_owner (unwrap! (unwrap-panic (contract-call? .laser-eyes-v5 get-owner tid)) (err ERR_TOKEN_NOT_EXIST)))
      (caller tx-sender)
    )
    (asserts! (is-eq sys_owner tx-sender) (err ERR_NO_AUTHORITY))
    (asserts! (and (>= price MIN_PRICE) (<= price MAX_PRICE)) (err ERR_PRICE_INVALID))
    (map-set map_list_info tid {
      price: price,
      owner: sys_owner,
    })
    (stat_list tid price)
    (contract-call? .laser-eyes-v5 transfer_by_market_list tid sys_owner (as-contract tx-sender))
  )
)

(define-public (update_list_price (tid uint) (price uint))
  (let
    (
      (list_info (unwrap! (map-get? map_list_info tid) (err ERR_LIST_NOT_FOUND)))
    )
    (asserts! (is-eq (get owner list_info) tx-sender) (err ERR_NO_AUTHORITY))
    (asserts! (and (>= price MIN_PRICE) (<= price MAX_PRICE)) (err ERR_PRICE_INVALID))
    (map-set map_list_info tid (merge list_info {
      price: price
    }))
    (stat_list tid price)
    (ok true)
  )
)

(define-public (cancel_list (tid uint))
  (let
    (
      (owner (unwrap! (get owner (map-get? map_list_info tid)) (err ERR_LIST_NOT_FOUND)))
    )
    (asserts! (is-eq owner tx-sender) (err ERR_NO_AUTHORITY))
    (map-delete map_list_info tid)
    (stat_list tid u0)
    (contract-call? .laser-eyes-v5 transfer_by_market_list tid (as-contract tx-sender) owner)
  )
)

;; Don't need a price param, safe due to post conditions
(define-public (accept_bid (tid uint) (bidder principal))
  (let
    (
      (owner (unwrap! (contract-call? .laser-eyes-v5 get_player_by_id tid) (err ERR_TOKEN_NOT_EXIST)))
      (pos_t (get pos (fold loop_t2 LIST_TOKEN_BIDS { p: bidder, tid: tid, pos: u0 })))
      (pos_p (get pos (fold loop_p1 LIST_PLAYER_BIDS { p: bidder, tid: tid, pos: u0 })))
      (token_bid_info (unwrap! (map-get? map_token_bid { tid: tid, index: pos_t }) (err ERR_BID_NOT_FOUND)))
      (player_bid_info (unwrap! (map-get? map_player_bid { player: bidder, index: pos_p }) (err ERR_BID_NOT_FOUND)))
      (price (get price token_bid_info))
      (list_data_opt (map-get? map_list_info tid))
      (b_list (is-some list_data_opt))
      (fee (/ (* price FEE) u1000))
      (seller_get (- price fee))
      (deposit (default-to u0 (map-get? map_bidder_deposit bidder)))
      (caller tx-sender)
      (bh block-height)
    )
    (asserts! (is-none (contract-call? .laser-eyes-v5 get_id_by_player bidder)) (err ERR_ACCOUNT_ALREADY_ASSOCIATED))
    (asserts! (is-eq owner caller) (err ERR_NO_AUTHORITY))
    (asserts! (and (<= bh (get expiration token_bid_info)) (<= bh (get expiration player_bid_info))) (err ERR_BID_EXPIRED))
    (asserts! (is-eq price (get price player_bid_info)) (err ERR_PRICE_NOT_SAME))
    (asserts! (>= deposit price) (err ERR_BID_DEPOSIT_UNENOUGH))
    (try! (as-contract (stx-transfer? seller_get tx-sender caller)))
    (try! (as-contract (contract-call? .laser-eyes-v5 deduct fee)))
    ;;
    (if b_list
      (try! (contract-call? .laser-eyes-v5 transfer_by_market_trade tid tx-sender bidder))
      (try! (contract-call? .laser-eyes-v5 transfer tid tx-sender bidder))
    )
    (if (is-eq deposit price)
      (map-delete map_bidder_deposit bidder)
      (map-set map_bidder_deposit bidder (- deposit price))
    )
    (map-delete map_list_info tid)
    (map-delete map_token_bid { tid: tid, index: pos_t })
    (map-delete map_player_bid { player: bidder, index: pos_p })
    (and (stat_list tid u0) (stat_trade tid price))
    (ok true)
  )
)

(define-public (buy (tid uint))
  (let
    (
      (list_info (unwrap! (map-get? map_list_info tid) (err ERR_LIST_NOT_FOUND)))
      (price (get price list_info))
      (fee (/ (* price FEE) u1000))
      (seller_get (- price fee))
      (caller tx-sender)
      (pos_t (get pos (fold loop_t2 LIST_TOKEN_BIDS { p: caller, tid: tid, pos: u0 })))
      (pos_p (get pos (fold loop_p1 LIST_PLAYER_BIDS { p: caller, tid: tid, pos: u0 })))
      (deposit (default-to u0 (map-get? map_bidder_deposit caller)))
    )
    (asserts! (is-none (contract-call? .laser-eyes-v5 get_id_by_player caller)) (err ERR_ACCOUNT_ALREADY_ASSOCIATED))
    (asserts! (>= (stx-get-balance caller) price) (err ERR_BALANCE_UNENOUGH))
    (unwrap! (stx-transfer? seller_get caller (get owner list_info)) (err ERR_TRANSFER_STX))
    (try! (contract-call? .laser-eyes-v5 deduct fee))
    ;;
    (try! (contract-call? .laser-eyes-v5 transfer_by_market_trade tid (get owner list_info) caller))
    ;;
    (map-delete map_list_info tid)
    (and (> pos_t u0) (map-delete map_token_bid { tid: tid, index: pos_t }))
    (and (> pos_p u0) (map-delete map_player_bid { player: caller, index: pos_p }))
    (and (stat_list tid u0) (stat_trade tid price))
    (ok true)
  )
)

(define-public (bid (tid uint) (price uint) (days uint))
  (let
    (
      (deposit (default-to u0 (map-get? map_bidder_deposit tx-sender)))
      (bh block-height)
      (expiration (+ bh (* days u144)))
      (result_t (fold loop_t1 LIST_TOKEN_BIDS { p: tx-sender, tid: tid, pos: u0, ip: u0, ep: u0, up: u0, ap: u0, mbp: u0, mb: u0 }))
      (result_p (fold loop_p2 LIST_PLAYER_BIDS { p: tx-sender, tid: tid, pos: u0, ip: u0, ep: u0 }))
      (bid_pos_t (get pos result_t))
      (bid_pos_p (get pos result_p))
    )
    (asserts! (is-some (contract-call? .laser-eyes-v5 get_player_by_id tid)) (err ERR_TOKEN_NOT_EXIST))
    (asserts! (is-none (contract-call? .laser-eyes-v5 get_id_by_player tx-sender)) (err ERR_ACCOUNT_ALREADY_ASSOCIATED))
    (asserts! (and (>= price MIN_PRICE) (<= price MAX_PRICE)) (err ERR_PRICE_INVALID))
    (asserts! (and (>= days MIN_BID_DAYS) (<= days MAX_BID_DAYS)) (err ERR_BID_PERIOD_INVALID))
    (asserts! (or (and (is-eq bid_pos_p u0) (is-eq bid_pos_t u0)) (and (> bid_pos_p u0) (> bid_pos_t u0))) (err ERR_BID_POS_NOT_SAME))
    ;;
    (and (> price deposit)
      (try! (stx-transfer? (- price deposit) tx-sender (as-contract tx-sender)))
      (map-set map_bidder_deposit tx-sender price)
    )
    (var-set m_tmp_t u0)
    (var-set m_tmp_tid none)
    (var-set m_tmp_p u0)
    (var-set m_tmp_player none)
    (if (> bid_pos_t u0)
      (begin
        (var-set m_tmp_t bid_pos_t)
        (var-set m_tmp_p bid_pos_p)
      )
      (begin
        (if (> (get ip result_t) u0)
          (var-set m_tmp_t (get ip result_t))
          (and
            (if (> (get ep result_t) u0) (var-set m_tmp_t (get ep result_t))
              (if (> (get up result_t) u0) (var-set m_tmp_t (get up result_t))
                (if (> (get ap result_t) u0) (var-set m_tmp_t (get ap result_t))
                  (if (> price (get mb result_t)) (var-set m_tmp_t (get mbp result_t)) (asserts! false (err ERR_BID_PRICE_TOO_LOW))))))
            (var-set m_tmp_player (get player (map-get? map_token_bid { tid: tid, index: (var-get m_tmp_t) })))
          )
        )
        (if (> (get ip result_p) u0)
          (var-set m_tmp_p (get ip result_p))
          (and
            (if (> (get ep result_p) u0)
              (var-set m_tmp_p (get ep result_p))
              (asserts! false (err ERR_BID_TOO_MANY))
            )
            (var-set m_tmp_tid (get tid (map-get? map_player_bid { player: tx-sender, index: (var-get m_tmp_p) })))
          )
        )
      )
    )
    ;;
    (map-set map_token_bid
      { tid: tid, index: (var-get m_tmp_t) }
      {
        player: tx-sender,
        price: price,
        at: bh,
        expiration: expiration,
      }
    )
    (map-set map_player_bid 
      { player: tx-sender, index: (var-get m_tmp_p) }
      {
        tid: tid,
        price: price,
        at: bh,
        expiration: expiration,
      }
    )
    ;;
    (match (var-get m_tmp_player) rm_player
      (map-delete map_player_bid { player: rm_player, index: (get pos (fold loop_p1 LIST_PLAYER_BIDS { p: rm_player, tid: tid, pos: u0 })) })
      false
    )
    (match (var-get m_tmp_tid) rm_tid
      (map-delete map_token_bid { tid: rm_tid, index: (get pos (fold loop_t2 LIST_TOKEN_BIDS { p: tx-sender, tid: rm_tid, pos: u0 })) })
      false
    )
    (ok true)
  )
)

(define-public (cancel_bid (tid uint))
  (let
    (
      (pos_t (get pos (fold loop_t2 LIST_TOKEN_BIDS { p: tx-sender, tid: tid, pos: u0 })))
      (pos_p (get pos (fold loop_p1 LIST_PLAYER_BIDS { p: tx-sender, tid: tid, pos: u0 })))
    )
    (asserts! (and (> pos_p u0) (> pos_t u0)) (err ERR_BID_NOT_FOUND))
    ;;
    (map-delete map_token_bid { tid: tid, index: pos_t })
    (map-delete map_player_bid { player: tx-sender, index: pos_p })
    (ok true)
  )
)

(define-public (withdraw)
  (let
    (
      (deposit (default-to u0 (map-get? map_bidder_deposit tx-sender)))
      (caller tx-sender)
    )
    (filter loop_p3 LIST_PLAYER_BIDS)
    (map-delete map_bidder_deposit tx-sender)
    (ok (and (> deposit u0) (unwrap! (as-contract (stx-transfer? deposit tx-sender caller)) (err ERR_TRANSFER_STX))))
  )
)

(define-read-only (get_stat_lists (index_list (list 25 uint))) (map ll index_list))
(define-read-only (ll (i uint)) (map-get? map_stat_list i))
(define-read-only (get_stat_trades (index_list (list 25 uint))) (map lt index_list))
(define-read-only (lt (i uint)) (map-get? map_stat_trade i))

(define-read-only (get_summary (player_opt (optional principal)))
  (match player_opt player
    (let
      (
        (resolve_info (contract-call? .laser-eyes-v5 resolve_player player))
        (tid (get tid resolve_info))
      )
      {
        bh: block-height,
        balance: (stx-get-balance player),
        deposit: (default-to u0 (map-get? map_bidder_deposit player)),
        tid: tid,
        ;; meta: (get meta resolve_info),
        ;; list_price: (if (is-eq tid u0) u0 (default-to u0 (get price (map-get? map_list_info tid)))),
        stat_index: (var-get m_stat_list_index),
        trade_index: (var-get m_stat_trade_index),
      }
    )
    {
      bh: block-height,
      balance: u0,
      deposit: u0,
      tid: u0,
      ;; meta: none,
      ;; list_price: u0,
      stat_index: (var-get m_stat_list_index),
      trade_index: (var-get m_stat_trade_index),
    }
  )
)

(define-read-only (get_brief_summary (player principal))
  {
    balance: (stx-get-balance player),
    deposit: (default-to u0 (map-get? map_bidder_deposit player)),
  }
)

(define-read-only (get_brief_mine (player principal))
  (let
    (
        (resolve_info (contract-call? .laser-eyes-v5 resolve_player player))
        (tid (get tid resolve_info))
    )
    {
      bh: block-height,
      meta: (get meta resolve_info),
      list_price: (if (is-eq tid u0) u0 (default-to u0 (get price (map-get? map_list_info tid)))),
      bid_list: (if (is-eq tid u0) (list) (get r (fold loop_t4 LIST_TOKEN_BIDS { tid: tid, r: (list) }))),
    }
  )
)

(define-read-only (get_token_brief (tid uint))
  (let
    (
      (info (contract-call? .laser-eyes-v5 resolve_tid tid))
      (ud (get ud info))
    )
    {
      bh: block-height,
      player: (get player info),
      list_info: (map-get? map_list_info tid),
      bid_list: (get r (fold loop_t4 LIST_TOKEN_BIDS { tid: tid, r: (list) })),
      time: (if (is-some ud) (get-block-info? time (mod (unwrap-panic ud) u1000000)) none),
    }
  )
)

(define-read-only (get_pre_act_info (player principal))
  {
    tid: (contract-call? .laser-eyes-v5 get_id_by_player player),
    deposit: (default-to u0 (map-get? map_bidder_deposit player)),
  }
)

(define-read-only (get_bidder_deposit (player principal))
  (default-to u0 (map-get? map_bidder_deposit player))
)

(define-read-only (get_player_bid_data (player principal))
  {
    deposit: (default-to u0 (map-get? map_bidder_deposit player)),
    bids: (fold loop_p4 LIST_PLAYER_BIDS { p: player, r: (list) })
  }
)

(define-read-only (get_token_list_info (tid uint))
  (map-get? map_list_info tid)
)

(define-private (loop_t4 (i uint) (ud { tid: uint, r: (list 3 { player: principal, price: uint, at: uint, expiration: uint }) }))
  (match (map-get? map_token_bid { tid: (get tid ud), index: i }) bi
    (merge ud {
      r: (unwrap-panic (as-max-len? (append (get r ud) bi) u3)) 
    })
    ud
  )
)

(define-read-only (loop_p4 (i uint) (ud { p: principal, r: (list 5 { tid: uint, price: uint, at: uint, expiration: uint }) }))
  (match (map-get? map_player_bid { player: (get p ud), index: i }) bi 
    (merge ud {
      r: (unwrap-panic (as-max-len? (append (get r ud) bi) u5)) 
    }) 
    ud
  )
)

(define-private (loop_p1 (i uint) (ud { p: principal, tid: uint, pos: uint }))
  (if (> (get pos ud) u0)
    ud
    (match (map-get? map_player_bid { player: (get p ud), index: i }) bi 
      (if (is-eq (get tid bi) (get tid ud)) 
        (merge ud {pos: i}) 
        ud
      ) 
      ud
    )
  )
)

(define-private (loop_p2 (i uint) (ud { p: principal, tid: uint, pos: uint, ip: uint, ep: uint }))
  (if (> (get pos ud) u0)
    ud
    (match (map-get? map_player_bid { player: (get p ud), index: i }) bi
      (if (is-eq (get tid bi) (get tid ud))
        (merge ud { pos: i })
        (if (and (is-eq (get ep ud) u0) (> block-height (get expiration bi)))
          (merge ud { ep: i }) 
          ud
        )
      )
      (if (is-eq (get ip ud) u0)
        (merge ud { ip: i })
        ud
      )
    )
  )
)

(define-private (loop_t1 (i uint) (ud { p: principal, tid: uint, pos: uint, ip: uint, ep: uint, up: uint, ap: uint, mbp: uint, mb: uint }))
  (if (> (get pos ud) u0)
    ud
    (match (map-get? map_token_bid { tid: (get tid ud), index: i }) bi
      (if (is-eq (get player bi) (get p ud))
        (merge ud { pos: i }) 
        (if (> (get ep ud) u0)
          ud
          (if (> block-height (get expiration bi))
            (merge ud { ep: i })
            (if (> (get up ud) u0) ud
              (if (< (default-to u0 (map-get? map_bidder_deposit (get player bi))) (get price bi))
                (merge ud { up: i })
                (if (> (get ap ud) u0)
                  ud
                  (if (is-some (contract-call? .laser-eyes-v5 get_id_by_player (get player bi)))
                    (merge ud { ap: i }) 
                    (if (or (is-eq (get mbp ud) u0) (< (get price bi) (get mb ud)))
                      (merge ud { mbp: i, mb: (get price bi) })
                      ud
                    )
                  )
                )
              )
            )
          )
        )
      )
      (if (> (get ip ud) u0)
        ud 
        (merge ud { ip: i })
      )
    )
  )
)

(define-private (loop_t2 (i uint) (ud { p: principal, tid: uint, pos: uint }))
  (if (> (get pos ud) u0)
    ud
    (match (map-get? map_token_bid { tid: (get tid ud), index: i }) bi
      (if (is-eq (get player bi) (get p ud))
        (merge ud { pos: i })
        ud
      )
      ud
    )
  )
)

(define-private (loop_p3 (i uint))
  (match (map-get? map_player_bid { player: tx-sender, index: i }) bi
    (begin
      (map-delete map_player_bid { player: tx-sender, index: i }) 
      (fold loop_t3 LIST_TOKEN_BIDS { tid: (get tid bi), f: false })
      false)
    false
  )
)

(define-private (loop_t3 (i uint) (ud { tid: uint, f: bool }))
  (if (get f ud)
    ud 
    (let
      (
        (tid (get tid ud))
        (bi (map-get? map_token_bid { tid: tid, index: i }))
      )
      (if (and (is-some bi) (is-eq (unwrap-panic (get player bi)) tx-sender))
        (begin
          (map-delete map_token_bid { tid: tid, index: i })
          (merge ud { f: true })
        )
        ud
      )
    )
  )
)

(define-private (stat_list (tid uint) (price uint))
  (let
    (
      (comb (+ tid (* u10000 (/ price u10000))))
      (index (var-get m_stat_list_index))
      (shift (var-get m_stat_list_shift))
    )
    (if (< shift u3)
      (and
        (map-set map_stat_list index (+ (* comb (pow u10 (* u12 shift))) (default-to u0 (map-get? map_stat_list index))))
        (var-set m_stat_list_shift (+ shift u1))
      )
      (and
        (var-set m_stat_list_index (if (< index MAX_STAT_COUNT) (+ index u1) u1))
        (var-set m_stat_list_shift u1)
        (map-set map_stat_list (if (< index MAX_STAT_COUNT) (+ index u1) u1) comb)
      )
    )
  )
)

(define-private (stat_trade (tid uint) (price uint))
  (let
    (
      (comb (+ tid (* u10000 (/ price u10000))))
      (index (var-get m_stat_trade_index))
      (shift (var-get m_stat_trade_shift))
    )
    (if (< shift u3)
      (and
        (map-set map_stat_trade index (+ (* comb (pow u10 (* u12 shift))) (default-to u0 (map-get? map_stat_trade index))))
        (var-set m_stat_trade_shift (+ shift u1))
      )
      (and
        (var-set m_stat_trade_index (if (< index MAX_STAT_COUNT) (+ index u1) u1))
        (var-set m_stat_trade_shift u1)
        (map-set map_stat_trade (if (< index MAX_STAT_COUNT) (+ index u1) u1) comb)
      )
    )
  )
)