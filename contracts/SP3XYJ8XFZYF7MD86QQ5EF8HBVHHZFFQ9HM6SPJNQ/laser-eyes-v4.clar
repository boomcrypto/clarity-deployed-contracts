(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant ERR_NO_AUTHORITY u1001)
(define-constant ERR_CID_INVALID u1002)
(define-constant ERR_DESTRUCT_ERROR u1003)
(define-constant ERR_MINT_NO_REMAIN u1004)
(define-constant ERR_META_NOT_EXIST u1005)
(define-constant ERR_TOKEN_NOT_EXIST u1006)
(define-constant ERR_OWNER_NOT_MATCH u1007)
(define-constant ERR_OWNER_NOT_FOUND u1008)
(define-constant ERR_BALANCE_NOT_ENOUGH u1009)
(define-constant ERR_UNAUTHORIZED_CONTRACT u1010)
(define-constant ERR_ACCOUNT_NOT_ASSOCIATED u1011)
(define-constant ERR_ACCOUNT_ALREAYD_ASSOCIATED u1012)
(define-constant ERR_NAME_EMPTY u2001)
(define-constant ERR_NAME_ALREADY_TAKEN u2002)
(define-constant ERR_NAME_MINORNAME_NOT_MATCH u2003)
(define-constant ERR_MINOR_NAME_ALREADY_TAKEN u2004)

(define-constant FOUNDER 'SPTNZVEAGSBMVCY00PGHDAR3CDP5ND14XAC9CEDT)
(define-constant MAX_TOKEN_ID u10000)
(define-constant MINT_PRICE u30000000)
(define-constant AWARD_FOUNDER_PERCENT u50)
(define-constant UPDATE_NAME_PRICE u30000000)
(define-constant UPDATE_CID_AND_BIO_PRICE u8000000)
(define-constant LIST_AWARD (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20))
(define-constant AWARD_HOLDERS_COUNT (len LIST_AWARD))
(define-constant LIST_NAME_INDEX (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24))

(define-non-fungible-token LaserEyes uint)

(define-data-var m_petrify bool false)
(define-data-var m_mint_last_id uint u0)
(define-data-var m_award_step uint u20090103)
(define-data-var m_market_contract (optional principal) none)

(define-map map_meta
  uint
  {
    name: (buff 25),
    minor_name: (buff 25),
    cid: (string-ascii 64),
    bio: (buff 80),
    ud: uint,
  }
)

(define-map map_ext_data
  uint  ;; tid(token-id)
  uint
)

(define-map map_name2id
  (buff 25)
  uint
)

(define-map map_player2id
  principal
  uint
)

(define-map map_id2player
  uint
  principal
)

(define-map map_ext_contracts
  principal
  bool
)

(define-map map_u2l ;; ascii upper => lower
  (buff 1)
  (buff 1)
)

(define-public (mint (name (buff 25)) (minor_name (buff 25)) (cid (string-ascii 64)) (bio (buff 80)))
  (real_mint name minor_name cid bio tx-sender block-height)
)

(define-public (mint_for_reborn (name (buff 25)) (minor_name (buff 25)) (cid (string-ascii 64)) (bio (buff 80)) (receiver principal) (bh uint))
  (begin
    (asserts! (not (var-get m_petrify)) (err ERR_NO_AUTHORITY))
    (real_mint name minor_name cid bio receiver bh)
  )
)

(define-public (update (cid (string-ascii 64)) (bio (buff 80)))
  (let
    (
      (tid (unwrap! (map-get? map_player2id tx-sender) (err ERR_ACCOUNT_NOT_ASSOCIATED)))
      (logic_owner (unwrap! (map-get? map_id2player tid) (err ERR_OWNER_NOT_FOUND)))
      (sys_owner (unwrap! (nft-get-owner? LaserEyes tid) (err ERR_TOKEN_NOT_EXIST)))
      (meta (unwrap! (map-get? map_meta tid) (err ERR_META_NOT_EXIST)))
    )
    (asserts! (is-eq tx-sender sys_owner logic_owner) (err ERR_NO_AUTHORITY))
    ;;
    (try! (deduct UPDATE_CID_AND_BIO_PRICE))
    (map-set map_meta tid (merge meta {
      cid: cid,
      bio: bio,
    }))
    (ok true)
  )
)

(define-public (transfer (tid uint) (sender principal) (recipient principal))
  (let
    (
      (sender_tid (unwrap! (map-get? map_player2id sender) (err ERR_TOKEN_NOT_EXIST)))
      (logic_owner (unwrap! (map-get? map_id2player tid) (err ERR_OWNER_NOT_FOUND)))
    )
    (asserts! (is-eq sender tx-sender logic_owner) (err ERR_NO_AUTHORITY))
    ;; if contract-caller isn't marketplace, it must NOT be a contract
    (or
      (is_market contract-caller)
      (let
        (
          (des_info (unwrap! (principal-destruct? contract-caller) (err ERR_DESTRUCT_ERROR)))
        )
        (asserts! (is-none (get name des_info)) (err ERR_UNAUTHORIZED_CONTRACT))
      )
    )
    ;; if recipient isn't marketplace, it must NOT be a contract
    (or
      (is_market recipient)
      (let
        (
          (des_info (unwrap! (principal-destruct? contract-caller) (err ERR_DESTRUCT_ERROR)))
        )
        (asserts! (is-none (get name des_info)) (err ERR_UNAUTHORIZED_CONTRACT))
      )
    )
    (asserts! (is-eq sender_tid tid) (err ERR_OWNER_NOT_MATCH))
    (asserts! (is-none (map-get? map_player2id recipient)) (err ERR_ACCOUNT_ALREAYD_ASSOCIATED))
    ;;
    (try! (nft-transfer? LaserEyes tid sender recipient))
    (post_on_transfer tid sender recipient)
  )
)

(define-public (update_name (name (buff 25)) (minor_name (buff 25)))
  (let
    (
      (tid (unwrap! (map-get? map_player2id tx-sender) (err ERR_ACCOUNT_NOT_ASSOCIATED)))
      (logic_owner (unwrap! (map-get? map_id2player tid) (err ERR_OWNER_NOT_FOUND)))
      (sys_owner (unwrap! (nft-get-owner? LaserEyes tid) (err ERR_TOKEN_NOT_EXIST)))
      (meta (unwrap! (map-get? map_meta tid) (err ERR_META_NOT_EXIST)))
      (lower_origin_name (get result (fold loop_lower LIST_NAME_INDEX { name: (get name meta), result: 0x })))
      (lower_origin_minor_name (get result (fold loop_lower LIST_NAME_INDEX { name: (get minor_name meta), result: 0x })))
      (lower_name (get result (fold loop_lower LIST_NAME_INDEX { name: name, result: 0x })))
      (lower_minor_name (get result (fold loop_lower LIST_NAME_INDEX { name: minor_name, result: 0x })))
      (b_minor_name (> (len lower_minor_name) u0))
    )
    (asserts! (is-eq tx-sender sys_owner logic_owner) (err ERR_NO_AUTHORITY))
    (asserts! (is-none (map-get? map_name2id lower_name)) (err ERR_NAME_ALREADY_TAKEN))
    (if b_minor_name
      (begin
        (asserts! (is-none (map-get? map_name2id lower_minor_name)) (err ERR_MINOR_NAME_ALREADY_TAKEN))
        (if (> (len lower_name) (len lower_minor_name))
          (asserts! (get flag (fold loop_match LIST_NAME_INDEX { long_name: lower_name, short_name: lower_minor_name, flag: true })) (err ERR_NAME_MINORNAME_NOT_MATCH))
          (asserts! (get flag (fold loop_match LIST_NAME_INDEX { long_name: lower_minor_name, short_name: lower_name, flag: true })) (err ERR_NAME_MINORNAME_NOT_MATCH))
        )
      )
      true
    )
    (try! (deduct UPDATE_NAME_PRICE))
    (map-delete map_name2id lower_origin_name)
    (map-delete map_name2id lower_origin_minor_name)
    (map-set map_name2id lower_name tid)
    (and b_minor_name (map-set map_name2id lower_minor_name tid))
    (ok (map-set map_meta tid (merge meta {
      name: name,
      minor_name: minor_name,
    })))
  )
)

(define-public (deduct (amount uint))
  (let
    (
      (founder_award (/ (* amount AWARD_FOUNDER_PERCENT) u100))
      (per_holder_award (/ (- amount founder_award) AWARD_HOLDERS_COUNT))
      (last_stamp (unwrap-panic (get-block-info? time (- block-height u2027))))
      (base (+ (* (/ stx-liquid-supply u100000) u31) (* burn-block-height burn-block-height u997) (* last_stamp last_stamp u49957)))
    )
    (asserts! (>= (stx-get-balance tx-sender) amount) (err ERR_BALANCE_NOT_ENOUGH))
    (try! (stx-transfer? founder_award tx-sender FOUNDER))
    (if (<= (var-get m_mint_last_id) u1)
      (ok true)
      (begin
        (fold loop_award LIST_AWARD { index: base, step: (var-get m_award_step), award: per_holder_award, last_id: (var-get m_mint_last_id) })
        (var-set m_award_step (+ (mod last_stamp u57) u1))
        (ok true)
      )
    )
  )
)

(define-public (burn (tid uint))
  (let
    (
      (meta (unwrap! (map-get? map_meta tid) (err ERR_TOKEN_NOT_EXIST)))
      (lower_name (get result (fold loop_lower LIST_NAME_INDEX { name: (get name meta), result: 0x })))
      (lower_minor_name (get result (fold loop_lower LIST_NAME_INDEX { name: (get minor_name meta), result: 0x })))
    )
    (asserts! (is-eq (unwrap-panic (nft-get-owner? LaserEyes tid)) tx-sender) (err ERR_NO_AUTHORITY))
    (asserts! (is-eq (unwrap-panic (map-get? map_id2player tid)) tx-sender) (err ERR_OWNER_NOT_MATCH))
    (try! (nft-burn? LaserEyes tid tx-sender))
    (map-delete map_name2id lower_name)
    (map-delete map_name2id lower_minor_name)
    (map-delete map_meta tid)
    (map-delete map_id2player tid)
    (map-delete map_player2id tx-sender)
    (ok true)
  )
)

(define-public (set_ext_contract (ext_contract principal))
  (begin
    (asserts! (not (var-get m_petrify)) (err ERR_NO_AUTHORITY))
    (ok (map-set map_ext_contracts ext_contract true))
  )
)

(define-public (set_ext (tid uint) (from uint) (bit_len uint) (value uint))
  (let
    (
      (cur_value (default-to u0 (map-get? map_ext_data tid)))
      (max_value (- (pow u10 bit_len) u1))
      (left_value (* (/ cur_value (pow u10 (+ from bit_len))) (pow u10 (+ from bit_len))))
      (right_value (mod cur_value (pow u10 from)))
      (bound_value (if (> value max_value) max_value value))
      (mid_value (* bound_value (pow u10 from)))
    )
    (asserts! (is-some (map-get? map_ext_contracts contract-caller)) (err ERR_UNAUTHORIZED_CONTRACT))
    (map-set map_ext_data tid (+ left_value mid_value right_value))
    (and (> value max_value) (begin (print "ext warning: exceed") false))
    (ok true)
  )
)

(define-public (set_market_contract (market_contract principal))
  (ok
    (and 
      (asserts! (is-none (var-get m_market_contract)) (err ERR_NO_AUTHORITY))
      (var-set m_market_contract (some market_contract))
      (try! (set_ext_contract market_contract))
    )
  )
)

(define-public (transfer_by_market_list (tid uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is_market contract-caller) (err ERR_UNAUTHORIZED_CONTRACT))
    (nft-transfer? LaserEyes tid sender recipient)
  )
)

(define-public (transfer_by_market_trade (tid uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is_market contract-caller) (err ERR_UNAUTHORIZED_CONTRACT))
    (try! (nft-transfer? LaserEyes tid contract-caller recipient))
    (post_on_transfer tid sender recipient)
  )
)

(define-public (set_ud (tid uint) (from uint) (bit_len uint) (value uint))
  (let
    (
      (meta (unwrap! (map-get? map_meta tid) (err ERR_TOKEN_NOT_EXIST)))
      (cur_value (get ud meta))
      (max_value (- (pow u10 bit_len) u1))
      (left_value (* (/ cur_value (pow u10 (+ from bit_len))) (pow u10 (+ from bit_len))))
      (right_value (mod cur_value (pow u10 from)))
      (bound_value (if (> value max_value) max_value value))
      (mid_value (* bound_value (pow u10 from)))
    )
    (asserts! (is-some (map-get? map_ext_contracts contract-caller)) (err ERR_UNAUTHORIZED_CONTRACT))
    (map-set map_meta tid (merge meta {
      ud: (+ left_value mid_value right_value)
    }))
    (and (> value max_value) (begin (print "warning: exceed") false))
    (ok true)
  )
)

(define-public (set_petrify)
  (ok (and (asserts! (not (var-get m_petrify)) (err ERR_NO_AUTHORITY)) (var-set m_petrify true)))
)

(define-read-only (get-owner (tid uint))
  (ok (nft-get-owner? LaserEyes tid))
)

(define-read-only (get-last-token-id)
  (ok (var-get m_mint_last_id))
)

(define-read-only (get-token-uri (tid uint))
  (ok (get cid (map-get? map_meta tid)))
)

(define-read-only (get_summary (player (optional principal)) (name (optional (buff 25))) (tid uint))
  (let
    (
      (ptid (if (is-some player) (default-to u0 (map-get? map_player2id (unwrap-panic player))) u0))
      (ntid (if (is-some name) (default-to u0 (map-get? map_name2id (unwrap-panic name))) u0))
    )
    {
      petrify: (var-get m_petrify),
      last_id: (var-get m_mint_last_id),
      ptid: ptid,
      pmeta: (if (> ptid u0) (map-get? map_meta ptid) none),
      pext: (if (> ptid u0) (default-to u0 (map-get? map_ext_data ptid)) u0),
      ntid: ntid,
      nmeta: (if (> ntid u0) (map-get? map_meta ntid) none),
      next: (if (> ntid u0) (default-to u0 (map-get? map_ext_data ntid)) u0),
      tmeta: (if (> tid u0) (map-get? map_meta tid) none),
      text: (if (> tid u0) (default-to u0 (map-get? map_ext_data tid)) u0),
    }
  )
)

(define-read-only (get_player_summary (player principal))
  (let
    (
      (tid (default-to u0 (map-get? map_player2id player)))
      (meta (if (> tid u0) (map-get? map_meta tid) none))
      (owner_opt (nft-get-owner? LaserEyes tid))
    )
  {
    last_id: (var-get m_mint_last_id),
    tid: tid,
    meta: meta,
    ext: (if (> tid u0) (default-to u0 (map-get? map_ext_data tid)) u0),
    time: (if (is-some meta) (get-block-info? time (mod (unwrap-panic (get ud meta)) u100000000)) none),
    bown: (and (is-some owner_opt) (is-eq player (unwrap-panic owner_opt))),
}))

(define-read-only (get_members (tid_list (list 25 uint)))
  (map get_member tid_list)
)

(define-read-only (get_member (tid uint))
  (map-get? map_meta tid)
)

(define-read-only (get_id_by_player (player principal))
  (map-get? map_player2id player)
)

(define-read-only (get_player_by_id (tid uint))
  (map-get? map_id2player tid)
)

(define-read-only (resolve_tid (tid uint))
  {
    player: (map-get? map_id2player tid),
    ud: (get ud (map-get? map_meta tid)),
  }
)

(define-read-only (resolve_player (player principal))
  (let
    (
      (tid (default-to u0 (map-get? map_player2id player)))
    )
    {
      tid: tid,
      meta: (map-get? map_meta tid),
    }
  )
)

(define-read-only (resolve_name (name (buff 25)))
  (let
    (
      (lower_name (get result (fold loop_lower LIST_NAME_INDEX { name: name, result: 0x })))
      (tid (default-to u0 (map-get? map_name2id lower_name)))
    )
    {
      tid: tid,
      meta: (map-get? map_meta tid),
    }
  )
)

(define-read-only (can_name_be_minted (name (buff 25)))
  (let
    (
      (lower_name (get result (fold loop_lower LIST_NAME_INDEX { name: name, result: 0x })))
    )
    (and (> (len lower_name) u0) (is-none (map-get? map_name2id lower_name)))
  )
)

(define-read-only (get_pre_act_info (player principal) (name (buff 25)) (minor_name (buff 25)))
  {
    own: (is-some (map-get? map_player2id player)),
    balance: (stx-get-balance player),
    name: (and (> (len name) u0) (is-none (map-get? map_name2id name))),
    minor_name: (or (is-eq (len minor_name) u0) (is-none (map-get? map_name2id minor_name))),
  }
)

(define-read-only (get_ud (tid uint) (from uint) (bit_len uint))
  (match (map-get? map_meta tid) meta
    (some (/ (mod (get ud meta) (pow u10 (+ from bit_len))) (pow u10 from)))
    none
  )
)

(define-read-only (get_ext (tid uint) (from uint) (bit_len uint))
  (match (map-get? map_ext_data tid) ext_value
    (some (/ (mod ext_value (pow u10 (+ from bit_len))) (pow u10 from)))
    none
  )
)

(define-private (real_mint (name (buff 25)) (minor_name (buff 25)) (cid (string-ascii 64)) (bio (buff 80)) (receiver principal) (bh uint))
  (let
    (
      (tid (+ u1 (var-get m_mint_last_id)))
      (lower_name (get result (fold loop_lower LIST_NAME_INDEX { name: name, result: 0x })))
      (lower_minor_name (get result (fold loop_lower LIST_NAME_INDEX { name: minor_name, result: 0x })))
      (b_minor_name (> (len lower_minor_name) u0))
      (des_info (unwrap! (principal-destruct? receiver) (err ERR_DESTRUCT_ERROR)))
    )
    (asserts! (<= tid MAX_TOKEN_ID) (err ERR_MINT_NO_REMAIN))
    (asserts! (is-none (map-get? map_player2id receiver)) (err ERR_ACCOUNT_ALREAYD_ASSOCIATED))
    (asserts! (> (len lower_name) u0) (err ERR_NAME_EMPTY))
    (asserts! (is-none (map-get? map_name2id lower_name)) (err ERR_NAME_ALREADY_TAKEN))
    (asserts! (is-none (get name des_info)) (err ERR_UNAUTHORIZED_CONTRACT))
    (and
      b_minor_name
      (asserts! (is-none (map-get? map_name2id lower_minor_name)) (err ERR_MINOR_NAME_ALREADY_TAKEN))
      (if (> (len lower_name) (len lower_minor_name))
        (asserts! (get flag (fold loop_match LIST_NAME_INDEX { long_name: lower_name, short_name: lower_minor_name, flag: true })) (err ERR_NAME_MINORNAME_NOT_MATCH))
        (asserts! (get flag (fold loop_match LIST_NAME_INDEX { long_name: lower_minor_name, short_name: lower_name, flag: true })) (err ERR_NAME_MINORNAME_NOT_MATCH))
      )
    )
    (asserts! (> (len cid) u40) (err ERR_CID_INVALID))
    ;;
    (and (> tid u6) (try! (deduct MINT_PRICE))) ;; u6 for recovery
    (try! (contract-call? .laser-token-v4 reward_minter receiver))
    (try! (nft-mint? LaserEyes tid receiver))
    (var-set m_mint_last_id tid)
    (map-set map_name2id lower_name tid)
    (and b_minor_name (map-set map_name2id lower_minor_name tid))
    (map-set map_player2id receiver tid)
    (map-set map_id2player tid receiver)
    (map-set map_meta tid {
      name: name,
      minor_name: minor_name,
      cid: cid,
      bio: bio,
      ud: bh,
    })
    (ok true)
  )
)

(define-private (loop_lower (i uint) (ud { name: (buff 25), result: (buff 25) }))
  (match (element-at (get name ud) i) ch
    (merge ud {
      result: (unwrap-panic (as-max-len? (concat (get result ud) (default-to ch (map-get? map_u2l ch))) u25))
    })
    ud
  )
)

(define-private (loop_award (i uint) (ud { index: uint, step: uint, award: uint, last_id: uint }))
  (let
    (
      (tid (+ (mod (+ (get index ud) (* i (+ i u1991) (+ i u2021))) (get last_id ud)) u1))
      (holder_opt (map-get? map_id2player tid))
      (holder_balance (if (is-some holder_opt) (/ (stx-get-balance (unwrap-panic holder_opt)) u10000) u0))
    )
    (or
      (is-none holder_opt)
      (is-eq (unwrap-panic holder_opt) tx-sender)
      (is-ok (stx-transfer? (get award ud) tx-sender (unwrap-panic holder_opt)))
    )
    (merge ud {
      index: (+ (get index ud) (get step ud)),
      step: (+ (get step ud) holder_balance),
    })
  )
)

(define-private (loop_match (i uint) (ud { long_name: (buff 25), short_name: (buff 25), flag: bool }))
  (if (get flag ud)
    (let
      (
        (ch_opt (element-at (get short_name ud) i))
        (b_ok (or (is-none ch_opt) (is-some (index-of (get long_name ud) (unwrap-panic ch_opt)))))
      )
      (if b_ok
        ud
        (merge ud {
          flag: false
        })
      )
    )
    ud
  )
)

(define-private (post_on_transfer (tid uint) (sender principal) (recipient principal))
  (begin
    (map-delete map_player2id sender)
    (map-set map_player2id recipient tid)
    (map-set map_id2player tid recipient)
    (ok true)
  )
)

(define-private (is_market (p principal))
  (is-eq p (unwrap-panic (var-get m_market_contract)))
)

(define-private (init)
  (begin
    (map-set map_u2l 0x41 0x61) (map-set map_u2l 0x42 0x62) (map-set map_u2l 0x43 0x63) (map-set map_u2l 0x44 0x64) (map-set map_u2l 0x45 0x65)
    (map-set map_u2l 0x46 0x66) (map-set map_u2l 0x47 0x67) (map-set map_u2l 0x48 0x68) (map-set map_u2l 0x49 0x69) (map-set map_u2l 0x4a 0x6a)
    (map-set map_u2l 0x4b 0x6b) (map-set map_u2l 0x4c 0x6c) (map-set map_u2l 0x4d 0x6d) (map-set map_u2l 0x4e 0x6e) (map-set map_u2l 0x4f 0x6f)
    (map-set map_u2l 0x50 0x70) (map-set map_u2l 0x51 0x71) (map-set map_u2l 0x52 0x72) (map-set map_u2l 0x53 0x73) (map-set map_u2l 0x54 0x74)
    (map-set map_u2l 0x55 0x75) (map-set map_u2l 0x56 0x76) (map-set map_u2l 0x57 0x77) (map-set map_u2l 0x58 0x78) (map-set map_u2l 0x59 0x79)
    (map-set map_u2l 0x5a 0x7a)
    ;;
    (print "init finish")
  )
)

(init)
