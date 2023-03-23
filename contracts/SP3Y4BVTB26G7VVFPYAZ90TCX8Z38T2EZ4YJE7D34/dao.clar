(define-constant ERR_NO_AUTHORITY 30001)
(define-constant ERR_INVALID_VOTE_DURATION 30002)
(define-constant ERR_INVALID_ACTION_TYPE 30003)
(define-constant ERR_INVALID_PARAM_UINT1 30004)
(define-constant ERR_INVALID_PARAM_UINT2 30005)
(define-constant ERR_INVALID_PARAM_P1 30006)
(define-constant ERR_INVALID_PARAM_P2 30007)
(define-constant ERR_INVALID_PARAM_PRICE 30008)
(define-constant ERR_TRANSFER_STX 30009)
(define-constant ERR_CALL_REVOKE_PRICE_EDITION_ERR 30010)
(define-constant ERR_IMPOSSIBLE 30011)
(define-constant ERR_SELL_NOT_SET_BUYER 30101)
(define-constant ERR_SELL_NOT_BUYER 30102)
(define-constant ERR_SELL_INVALID_PRICE 30103)
(define-constant ERR_SELL_EXPIRED 30104)
(define-constant ERR_VOTE_INVALID_ACT_ID 30201)
(define-constant ERR_VOTE_FINISHED 30202)
(define-constant ERR_VOTE_EXPIRED 30203)
(define-constant ERR_VOTE_HAS_VOTED 30204)

;; Action types
(define-constant ACTION_TYPE_CHANGE_OWNER_AND_FEE_COLLECTOR u1)
(define-constant ACTION_TYPE_CHANGE_PRICE u2)
(define-constant ACTION_TYPE_REVOKE_PRICE_EDITION u3)
(define-constant ACTION_TYPE_SELL u4)

(define-constant MAX_VOTE_DURATION_BLOCKS u4320)  ;; One month
(define-constant VOTE_PASS_THERESHOLD u60)        ;; Vote pass if >=60% shares agree

(define-data-var m_act_id uint u0)
(define-data-var m_tmp_end_block uint u0)
(define-data-var m_sell_info { buyer: (optional principal), price: uint, deadline_block: uint } { buyer: none, price: u0, deadline_block: u0 })

(define-map map_vote
  uint  ;; action-id
  {
    b_finish: bool,
    start_block: uint,
    end_block: uint,
    agree_shares: uint,
    act_type: uint,
    param_uint1: (optional uint),
    param_uint2: (optional uint),
    param_p1: (optional principal),
    param_p2: (optional principal),
    param_price: (optional { buckets: (list 16 uint), base: uint, coeff: uint, nonalpha_discount: uint, no_vowel_discount: uint }),
  }
)

(define-map map_vote_flag
  { act_id: uint, user: principal }
  bool  ;; voted?
)

(define-public (new_vote (duration_blocks uint) (act_type uint) (param_uint1 (optional uint)) (param_uint2 (optional uint)) (param_p1 (optional principal)) (param_p2 (optional principal)) (param_price (optional { buckets: (list 16 uint), base: uint, coeff: uint, nonalpha_discount: uint, no_vowel_discount: uint })))
  (let
    (
      (new_act_id (+ (var-get m_act_id) u1))
      (shares (contract-call? .vault get_shares contract-caller))
      (end_block (+ block-height duration_blocks))
    )
    (asserts! (> shares u0) (err ERR_NO_AUTHORITY))
    (asserts! (<= duration_blocks MAX_VOTE_DURATION_BLOCKS) (err ERR_INVALID_VOTE_DURATION))
    (var-set m_act_id new_act_id)
    (var-set m_tmp_end_block end_block)
    (try! (verify_vote_params act_type param_uint1 param_uint2 param_p1 param_p2 param_price))
    (map-set map_vote_flag { act_id: new_act_id, user: contract-caller } true)
    (map-set map_vote new_act_id {
      b_finish: false,
      start_block: block-height,
      end_block: end_block,
      agree_shares: shares,
      act_type: act_type,
      param_uint1: param_uint1,
      param_uint2: param_uint2,
      param_p1: param_p1,
      param_p2: param_p2,
      param_price: param_price,
    })
    (ok true)
  )
)

(define-public (vote (act_id uint) (agree bool))
  (let
    (
      (caller contract-caller)
      (vote_info (unwrap! (map-get? map_vote act_id) (err ERR_VOTE_INVALID_ACT_ID)))
      (shares (contract-call? .vault get_shares caller))
      (new_agree_shares (+ (get agree_shares vote_info) (if agree shares u0)))
      (total_shares (contract-call? .vault get_total_shares))
      (min_pass_shares (/ (* VOTE_PASS_THERESHOLD total_shares) u100))
      (act_type (get act_type vote_info))
    )
    (asserts! (> shares u0) (err ERR_NO_AUTHORITY))
    (asserts! (not (get b_finish vote_info)) (err ERR_VOTE_FINISHED))
    (asserts! (<= block-height (get end_block vote_info)) (err ERR_VOTE_EXPIRED))
    (asserts! (is-none (map-get? map_vote_flag { act_id: act_id, user: caller })) (err ERR_VOTE_HAS_VOTED))
    (print {
      title: "vote",
      act_id: act_id,
      shares: shares,
      agree: agree,
      total_shares: total_shares,
      total_agree_shares: new_agree_shares,
    })
    (map-set map_vote_flag { act_id: act_id, user: caller } agree)
    (asserts! agree (ok true))  ;; Early return if not agree
    (map-set map_vote act_id (merge vote_info { agree_shares: new_agree_shares }))
    (asserts! (>= new_agree_shares min_pass_shares) (ok true))  ;; Early return if not through vote-pass-thereshould yet
    (map-set map_vote act_id (merge vote_info { agree_shares: new_agree_shares, b_finish: true }))
    (print "Vote pass, handle its action")
    (if (is-eq act_type ACTION_TYPE_CHANGE_OWNER_AND_FEE_COLLECTOR)
      (try! (handle_action1 act_id))
      (if (is-eq act_type ACTION_TYPE_CHANGE_PRICE)
        (try! (handle_action2 act_id))
        (if (is-eq act_type ACTION_TYPE_REVOKE_PRICE_EDITION)
          (try! (handle_action3 act_id))
          (if (is-eq act_type ACTION_TYPE_SELL)
            (try! (handle_action4 act_id))
            (asserts! false (err ERR_INVALID_ACTION_TYPE))
          )
        )
      )
    )
    (ok true)
  )
)

(define-public (buy (price uint))
  (let
    (
      (sell_info (var-get m_sell_info))
      (buyer (unwrap! (get buyer sell_info) (err ERR_SELL_NOT_SET_BUYER)))
    )
    (asserts! (is-eq contract-caller buyer) (err ERR_SELL_NOT_BUYER))
    (asserts! (>= price (get price sell_info)) (err ERR_SELL_INVALID_PRICE))
    (asserts! (<= block-height (get deadline_block sell_info)) (err ERR_SELL_EXPIRED))
    (unwrap! (stx-transfer? price contract-caller .vault) (err ERR_TRANSFER_STX))
    (var-set m_sell_info { buyer: none, price: u0, deadline_block: u0 })  ;; Clean up
    (contract-call? .namespace change_owner_and_fee_collector contract-caller contract-caller)
  )
)

(define-read-only (get_info)
  {
    bh: block-height,
    act_id: (var-get m_act_id),
    sell_info: (var-get m_sell_info),
  }
)

(define-read-only (get_vote (act_id uint))
  (map-get? map_vote act_id)
)

(define-read-only (get_vote_flag (act_id uint) (user principal))
  (map-get? map_vote_flag { act_id: act_id, user: user })
)

(define-private (verify_vote_params (act_type uint) (param_uint1 (optional uint)) (param_uint2 (optional uint)) (param_p1 (optional principal)) (param_p2 (optional principal)) (param_price (optional { buckets: (list 16 uint), base: uint, coeff: uint, nonalpha_discount: uint, no_vowel_discount: uint })))
  (begin
    (if (is-eq act_type ACTION_TYPE_CHANGE_OWNER_AND_FEE_COLLECTOR)
      (try! (verify_action1_params param_uint1 param_uint2 param_p1 param_p2 param_price))
      (if (is-eq act_type ACTION_TYPE_CHANGE_PRICE)
        (try! (verify_action2_params param_uint1 param_uint2 param_p1 param_p2 param_price))
        (if (is-eq act_type ACTION_TYPE_REVOKE_PRICE_EDITION)
          (try! (verify_action3_params param_uint1 param_uint2 param_p1 param_p2 param_price))
          (if (is-eq act_type ACTION_TYPE_SELL)
            (try! (verify_action4_params param_uint1 param_uint2 param_p1 param_p2 param_price))
            (asserts! false (err ERR_INVALID_ACTION_TYPE))
          )
        )
      )
    )
    (ok true)
  )
)

;; @desc Action type is ACTION_TYPE_CHANGE_OWNER_AND_FEE_COLLECTOR
;; @param_p1: new_owner
;; @param_p2: new_fee_collector
(define-private (verify_action1_params (param_uint1 (optional uint)) (param_uint2 (optional uint)) (param_p1 (optional principal)) (param_p2 (optional principal)) (param_price (optional { buckets: (list 16 uint), base: uint, coeff: uint, nonalpha_discount: uint, no_vowel_discount: uint })))
  (begin
    (asserts! (is-none param_uint1) (err ERR_INVALID_PARAM_UINT1))
    (asserts! (is-none param_uint2) (err ERR_INVALID_PARAM_UINT2))
    (asserts! (is-none param_price) (err ERR_INVALID_PARAM_PRICE))
    (print {
      action: "change owner and fee-collector",
      act_id: (var-get m_act_id),
      start_block: block-height,
      end_block: (var-get m_tmp_end_block),
      new_owner: (unwrap! param_p1 (err ERR_INVALID_PARAM_P1)),
      new_fee_collector: (unwrap! param_p2 (err ERR_INVALID_PARAM_P2)),
    })
    (ok true)
  )
)

(define-private (handle_action1 (act_id uint))
  (let
    (
      (vote_info (unwrap! (map-get? map_vote act_id) (err ERR_VOTE_INVALID_ACT_ID)))
      (new_owner (unwrap! (get param_p1 vote_info) (err ERR_INVALID_PARAM_P1)))
      (new_fee_collector (unwrap! (get param_p2 vote_info) (err ERR_INVALID_PARAM_P2)))
    )
    (contract-call? .namespace change_owner_and_fee_collector new_owner new_fee_collector)
  )
)

;; @desc Action type is ACTION_TYPE_CHANGE_PRICE
;; @param_price: new price config
(define-private (verify_action2_params (param_uint1 (optional uint)) (param_uint2 (optional uint)) (param_p1 (optional principal)) (param_p2 (optional principal)) (param_price (optional { buckets: (list 16 uint), base: uint, coeff: uint, nonalpha_discount: uint, no_vowel_discount: uint })))
  (let
    (
      (price_cfg (unwrap! param_price (err ERR_INVALID_PARAM_PRICE)))
    )
    (asserts! (is-none param_uint1) (err ERR_INVALID_PARAM_UINT1))
    (asserts! (is-none param_uint2) (err ERR_INVALID_PARAM_UINT2))
    (asserts! (is-none param_p1) (err ERR_INVALID_PARAM_P1))
    (asserts! (is-none param_p2) (err ERR_INVALID_PARAM_P2))
    (asserts! (is-eq (len (get buckets price_cfg)) u16) (err ERR_INVALID_PARAM_PRICE))
    (print {
      action: "change price",
      act_id: (var-get m_act_id),
      start_block: block-height,
      end_block: (var-get m_tmp_end_block),
      price_cfg: price_cfg,
    })    
    (ok true)
  )
)

(define-private (handle_action2 (act_id uint))
  (let
    (
      (vote_info (unwrap! (map-get? map_vote act_id) (err ERR_VOTE_INVALID_ACT_ID)))
      (price_cfg (unwrap! (get param_price vote_info) (err ERR_INVALID_PARAM_PRICE)))
    )
    (contract-call? .namespace change_price (get base price_cfg) (get coeff price_cfg) (get buckets price_cfg) (get nonalpha_discount price_cfg) (get no_vowel_discount price_cfg))
  )
)

;; @desc Action type is ACTION_TYPE_REVOKE_PRICE_EDITION
(define-private (verify_action3_params (param_uint1 (optional uint)) (param_uint2 (optional uint)) (param_p1 (optional principal)) (param_p2 (optional principal)) (param_price (optional { buckets: (list 16 uint), base: uint, coeff: uint, nonalpha_discount: uint, no_vowel_discount: uint })))
  (begin
    (asserts! (is-none param_uint1) (err ERR_INVALID_PARAM_UINT1))
    (asserts! (is-none param_uint2) (err ERR_INVALID_PARAM_UINT2))
    (asserts! (is-none param_p1) (err ERR_INVALID_PARAM_P1))
    (asserts! (is-none param_p2) (err ERR_INVALID_PARAM_P2))
    (asserts! (is-none param_price) (err ERR_INVALID_PARAM_PRICE))
    (print {
      action: "revoke price edition",
      act_id: (var-get m_act_id),
      start_block: block-height,
      end_block: (var-get m_tmp_end_block),
    })    
    (ok true)
  )
)

(define-private (handle_action3 (act_id uint))
  (if (unwrap! (contract-call? .namespace revoke_price_edition) (err ERR_IMPOSSIBLE)) (ok true) (err ERR_CALL_REVOKE_PRICE_EDITION_ERR))
)

;; @desc Action type is ACTION_TYPE_SELL
;; @param param_uint1 sell-price
;; @param param_uint2 deadline-block
;; @param param_p1 buyer (can be none, which means not want to sell anymore)
(define-private (verify_action4_params (param_uint1 (optional uint)) (param_uint2 (optional uint)) (param_p1 (optional principal)) (param_p2 (optional principal)) (param_price (optional { buckets: (list 16 uint), base: uint, coeff: uint, nonalpha_discount: uint, no_vowel_discount: uint })))
  (begin
    (asserts! (is-none param_p2) (err ERR_INVALID_PARAM_P2))
    (asserts! (is-none param_price) (err ERR_INVALID_PARAM_PRICE))
    (print {
      action: "sell",
      act_id: (var-get m_act_id),
      start_block: block-height,
      end_block: (var-get m_tmp_end_block),
      buyer: param_p1,
      price: param_uint1,
      deadline_block: param_uint2,
    })
    (ok true)
  )
)

(define-private (handle_action4 (act_id uint))
  (let
    (
      (vote_info (unwrap! (map-get? map_vote act_id) (err ERR_VOTE_INVALID_ACT_ID)))
    )
    (var-set m_sell_info {
      buyer: (get param_p1 vote_info),
      price: (default-to u0 (get param_uint1 vote_info)),
      deadline_block: (default-to u0 (get param_uint2 vote_info)),
    })
    (ok true)
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Startup ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(contract-call? .vault change_owner (as-contract tx-sender))
(contract-call? .vault set_shares 'SPFYPNNV6VC7R36W9VQK8AE6ZJXK3XA0PHSSWH6R u100)
(contract-call? .vault set_shares 'SP54YVYSV9DZG9356HCCWGX58HJCTNZES2YDFWE2  u100)
(contract-call? .vault set_shares 'SP2DXTCDYVDETRM0SVY70VGF5NYNRK9HZ3QYA4FC2 u100)
(contract-call? .vault set_shares 'SP2EKGYFCK3W22HDJ6Z4Q29P1DW8SCPZ4RQS3J8J4 u100)
(contract-call? .vault set_shares 'SPF121FTAMNYS0KECBDANN94SADWE4JE4XSX1S88 u100)
(contract-call? .vault set_shares 'SP8MSFJ4V018PAHV1TAHQ6GKEWTV5RBTGHBQDXRF u100)
(contract-call? .vault set_shares 'SP1Z6R9Q563GQ8AQHNB2YEDY8DTJX23C58HNWQJG1 u100)
(contract-call? .vault set_shares 'SPJ9YXZ9D3RS3NVSRATCQE6TY7CCBGP6R4H9FWW3 u100)
(contract-call? .vault set_shares 'SPS9CGPE7F2X4DSMZKWC11RQA5PNJHXT55B3QQD1 u100)
(contract-call? .vault set_shares 'SP27XYVR19RYBE2ME299J4XFFMPSDKX1AMHX6M65R u100)

(contract-call? .namespace change_owner_and_fee_collector (as-contract tx-sender) .vault)
(contract-call? .namespace register_namespace 0x6f7264696e616c73 u52560 u0 u640000000)
