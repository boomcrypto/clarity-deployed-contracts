;; Laser eyes clubs (visit https://onedotbtcus.bitbucket.io/ or 1.btc.us)

(define-constant ERR_NO_AUTHORITY u1001)
(define-constant ERR_BALANCE_NOT_ENOUGH u1002)
(define-constant ERR_ACCOUNT_NOT_ASSOCIATED u1003)
(define-constant ERR_CLUB_NOT_EXIST u2001)
(define-constant ERR_CLUB_NOT_ADMIN u2002)
(define-constant ERR_CLUB_NAME_EMPTY u2003)
(define-constant ERR_CLUB_MEMBERS_FULL u2004)
(define-constant ERR_CLUB_JOIN_MISMATCH u2005)
(define-constant ERR_CLUB_REMOVE_MEMBER u2006)
(define-constant ERR_CLUB_ALREADY_INVITE u2007)
(define-constant ERR_CLUB_MINT_NO_REMAIN u2008)
(define-constant ERR_CLUB_NO_SUCH_MEMBER u2009)
(define-constant ERR_CLUB_INVITE_TOO_MANY u2010)
(define-constant ERR_CLUB_APPLYED_TOO_MANY u2011)
(define-constant ERR_CLUB_ADMIN_CANNOT_EXIT u2012)
(define-constant ERR_CLUB_NOT_JOIN_MISMATCH u2013)
(define-constant ERR_CLUB_NAME_ALREADY_TAKEN u2014)
(define-constant ERR_CLUB_NO_SUCH_APPLY u2015)
(define-constant ERR_MEMBER_NOT_EXIST u3001)
(define-constant ERR_MEMBER_ALREADY_ADMIN u3002)
(define-constant ERR_MEMBER_JOIN_TOO_MANY u3003)
(define-constant ERR_MEMBER_APPLY_TOO_MANY u3004)
(define-constant ERR_MEMBER_ALREADY_APPLYED u3005)
(define-constant ERR_MEMBER_ALREADY_IN_CLUB u3006)
(define-constant ERR_MEMBER_INVITED_TOO_MANY u3007)
(define-constant ERR_MEMBER_NO_SUCH_INVITE u3008)
(define-constant ERR_JOIN_MISMATCH u4001)
(define-constant ERR_JOIN_INSERT_FAIL u4002)
(define-constant ERR_VOTE_EXPIRED u5001)
(define-constant ERR_VOTE_NOT_EXIST u5002)
(define-constant ERR_VOTE_DAYS_INVALID u5003)
(define-constant ERR_VOTE_ALREADY_VOTE u5004)
(define-constant ERR_VOTE_TITLE_INVALID u5005)
(define-constant ERR_VOTE_CHOICE_INVALID u5006)

(define-constant OWNER tx-sender)
(define-constant MAX_CLUB_ID u99)
(define-constant MAX_MEMBERS_COUNT u100)
(define-constant LIST_MEMBER_INDEX (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11))
(define-constant LIST_NAME_INDEX (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24))
(define-constant P4   (pow u10 u4))
(define-constant P8   (pow u10 u8))
(define-constant P10  (pow u10 u10))
(define-constant P12  (pow u10 u12))
(define-constant P16  (pow u10 u16))
(define-constant P20  (pow u10 u20))
(define-constant P24  (pow u10 u24))
(define-constant P28  (pow u10 u28))
(define-constant P32  (pow u10 u32))
(define-constant EVENTTYPE_MEMBER_ACCEPT_INVITE u1001)
(define-constant EVENTTYPE_MEMBER_DECLINE_INVITE u1002)
(define-constant EVENTTYPE_MEMBER_EXIT u1003)
(define-constant EVENTTYPE_CLUB_ACCEPT_APPLY u2001)
(define-constant EVENTTYPE_CLUB_DECLINE_APPLY u2002)
(define-constant EVENTTYPE_CLUB_TRANSFER u2003)
(define-constant EVENTTYPE_CLUB_KICKOUT u2004)

(define-data-var m_mint_last_id uint u0)
(define-data-var m_mint_price uint u20000000)
(define-data-var m_update_price uint u4000000)
(define-data-var m_launch_vote_price uint u2000000)
(define-data-var m_max_vote_days uint u30)
(define-data-var m_tmp uint u0)
(define-data-var m_tmp_index uint u0)

(define-map map_club_summary
  uint
  {
    name: (buff 25),
    cid: (string-ascii 64),
    bio: (buff 80),
    ud: uint
  }
)

(define-map map_club_detail
  uint
  {
    count: uint,
    members: (list 12 uint)
  }
)

(define-map map_admin
  uint
  uint
)

(define-map map_club_notice
  uint
  (buff 200)
)

(define-map map_name2ctid
  (buff 25)
  uint
)

(define-map map_u2l
  (buff 1)
  (buff 1)
)

(define-map map_member
  { tid: uint, ctid: uint }
  uint
)

(define-map map_join
  uint
  (list 5 uint)
)

(define-map map_member_apply
  uint
  (list 5 uint)
)

(define-map map_member_invited
  uint
  (list 5 uint)
)

(define-map map_club_invite
  uint
  (list 10 uint)
)

(define-map map_club_applyed
  uint
  (list 10 uint)
)

(define-map map_member_event_count
  uint
  uint
)

(define-map map_member_event
  uint
  uint
)

(define-map map_club_event_count
  uint
  uint
)

(define-map map_club_event
  uint
  uint
)

(define-map map_chat_ext
  uint
  uint
)

(define-map map_chat
  uint
  {
    ud: uint,
    msg: (buff 200)
  }
)

(define-map map_vote_count
  uint
  uint
)

(define-map map_vote
  uint
  {
    key: uint,
    start_at: uint,
    end_at: uint,
    launcher: uint,
    title: (buff 100),
    choices: (list 4 (buff 25)),
  }
)

(define-map map_vote_stat
  uint
  uint
)

(define-map map_vote_flag
  uint
  uint
)

(define-public (create_club (name (buff 25)) (cid (string-ascii 64)) (bio (buff 80)))
  (let
    (
      (sender tx-sender)
      (tid (unwrap! (contract-call? .laser-eyes-v3 get_id_by_player sender) (err ERR_ACCOUNT_NOT_ASSOCIATED)))
      (ctid (+ u1 (var-get m_mint_last_id)))
      (lower_name (get result (fold loop_lower LIST_NAME_INDEX { name: name, result: 0x })))
      (join_ctids (default-to (list) (map-get? map_join tid)))
      (mint_price (var-get m_mint_price))
    )
    (asserts! (<= ctid MAX_CLUB_ID) (err ERR_CLUB_MINT_NO_REMAIN))
    (asserts! (is-none (map-get? map_admin tid)) (err ERR_MEMBER_ALREADY_ADMIN))
    (asserts! (< (len join_ctids) u5) (err ERR_MEMBER_JOIN_TOO_MANY))
    (asserts! (> (len lower_name) u0) (err ERR_CLUB_NAME_EMPTY))
    (asserts! (is-none (map-get? map_name2ctid lower_name)) (err ERR_CLUB_NAME_ALREADY_TAKEN))
    (asserts! (>= (stx-get-balance sender) mint_price) (err ERR_BALANCE_NOT_ENOUGH))
    (try! (contract-call? .laser-eyes-v3 deduct mint_price))
    (var-set m_mint_last_id ctid)
    (map-set map_club_summary ctid {
      name: name,
      cid: cid,
      bio: bio,
      ud: (cb tid (get_time)),
    })
    (map-set map_club_detail ctid {
      count: u1,
      members: (list tid)
    })
    (map-set map_admin tid ctid)
    (map-set map_name2ctid lower_name ctid)
    (map-set map_member { tid: tid,  ctid: ctid} block-height)
    (map-set map_join tid (unwrap-panic (as-max-len? (append join_ctids ctid) u5)))
    (ok true)
  )
)

(define-public (update_summary (name (buff 25)) (cid (string-ascii 64)) (bio (buff 80)))
  (let
    (
      (sender tx-sender)
      (tid (unwrap! (contract-call? .laser-eyes-v3 get_id_by_player sender) (err ERR_ACCOUNT_NOT_ASSOCIATED)))
      (ctid (unwrap! (map-get? map_admin tid) (err ERR_CLUB_NOT_ADMIN)))
      (summary (unwrap! (map-get? map_club_summary ctid) (err ERR_CLUB_NOT_EXIST)))
      (lower_origin_name (get result (fold loop_lower LIST_NAME_INDEX { name: (get name summary), result: 0x })))
      (lower_name (get result (fold loop_lower LIST_NAME_INDEX { name: name, result: 0x })))
      (update_price (var-get m_update_price))
    )
    (asserts! (> (len lower_name) u0) (err ERR_CLUB_NAME_EMPTY))
    (asserts! (or (is-eq lower_name lower_origin_name) (is-none (map-get? map_name2ctid lower_name))) (err ERR_CLUB_NAME_ALREADY_TAKEN))
    (asserts! (>= (stx-get-balance sender) update_price) (err ERR_BALANCE_NOT_ENOUGH))
    (try! (contract-call? .laser-eyes-v3 deduct update_price))
    (map-set map_club_summary ctid (merge summary
      {
        name: name,
        cid: cid,
        bio: bio,
      }))
    (map-delete map_name2ctid lower_origin_name)
    (map-set map_name2ctid lower_name ctid)
    (ok true)
  )
)

(define-public (transfer (receiver_tid uint))
  (let
    (
      (tid (unwrap! (contract-call? .laser-eyes-v3 get_id_by_player tx-sender) (err ERR_ACCOUNT_NOT_ASSOCIATED)))
      (ctid (unwrap! (map-get? map_admin tid) (err ERR_CLUB_NOT_ADMIN)))
      (summary (unwrap! (map-get? map_club_summary ctid) (err ERR_CLUB_NOT_EXIST)))
      (club_event_index (+ (default-to u0 (map-get? map_club_event_count ctid)) u1))
    )
    (asserts! (is-some (contract-call? .laser-eyes-v3 get_player_by_id receiver_tid)) (err ERR_MEMBER_NOT_EXIST))
    (asserts! (is-none (map-get? map_admin receiver_tid)) (err ERR_MEMBER_ALREADY_ADMIN))
    (asserts! (is-some (map-get? map_member { tid: receiver_tid, ctid: ctid })) (err ERR_CLUB_NO_SUCH_MEMBER))
    (map-set map_club_summary ctid (merge summary
      {
        ud: (+ receiver_tid (* (/ (get ud summary) u10000) u10000))
      })
    )
    (map-delete map_admin tid)
    (map-set map_admin receiver_tid ctid)
    (map-set map_club_event_count ctid club_event_index)
    (map-set map_club_event
      (cb ctid club_event_index)
      (cbtime3 EVENTTYPE_CLUB_TRANSFER receiver_tid tid)
    )
    (ok true)
  )
)

(define-public (update_notice (notice (buff 200)))
  (let
    (
      (tid (unwrap! (contract-call? .laser-eyes-v3 get_id_by_player tx-sender) (err ERR_ACCOUNT_NOT_ASSOCIATED)))
      (ctid (unwrap! (map-get? map_admin tid) (err ERR_CLUB_NOT_ADMIN)))
    )
    (ok (map-set map_club_notice ctid notice))
  )
)

(define-public (member_apply (ctid uint))
  (let
    (
      (sender tx-sender)
      (tid (unwrap! (contract-call? .laser-eyes-v3 get_id_by_player sender) (err ERR_ACCOUNT_NOT_ASSOCIATED)))
      (join_ctids (default-to (list) (map-get? map_join tid)))
      (club_detail (unwrap! (map-get? map_club_detail ctid) (err ERR_CLUB_NOT_EXIST)))
      (member_apply_ctids (default-to (list) (map-get? map_member_apply tid)))
      (club_applyed_tids (default-to (list) (map-get? map_club_applyed ctid)))
    )
    (asserts! (is-none (map-get? map_member { tid: tid, ctid: ctid })) (err ERR_MEMBER_ALREADY_IN_CLUB))
    (asserts! (< (len join_ctids) u5) (err ERR_MEMBER_JOIN_TOO_MANY))
    (asserts! (< (get count club_detail) MAX_MEMBERS_COUNT) (err ERR_CLUB_MEMBERS_FULL))
    (asserts! (is-none (index-of member_apply_ctids ctid)) (err ERR_MEMBER_ALREADY_APPLYED))
    (asserts! (is-none (index-of club_applyed_tids tid)) (err ERR_MEMBER_ALREADY_APPLYED))
    (asserts! (< (len member_apply_ctids) u5) (err ERR_MEMBER_APPLY_TOO_MANY))
    (asserts! (< (len club_applyed_tids) u10) (err ERR_CLUB_APPLYED_TOO_MANY))
    (map-set map_member_apply tid (unwrap-panic (as-max-len? (append member_apply_ctids ctid) u5)))
    (map-set map_club_applyed ctid (unwrap-panic (as-max-len? (append club_applyed_tids tid) u10)))
    (ok true)
  )
)

(define-public (member_cancel_apply (ctid uint))
  (let
    (
      (tid (unwrap! (contract-call? .laser-eyes-v3 get_id_by_player tx-sender) (err ERR_ACCOUNT_NOT_ASSOCIATED)))
      (member_apply_ctids (default-to (list) (map-get? map_member_apply tid)))
      (club_applyed_tids (default-to (list) (map-get? map_club_applyed ctid)))
    )
    (asserts! (is-some (index-of club_applyed_tids tid)) (err ERR_CLUB_NO_SUCH_APPLY))
    (var-set m_tmp ctid)
    (map-set map_member_apply tid (filter not_tmp member_apply_ctids))
    (var-set m_tmp tid)
    (map-set map_club_applyed ctid (filter not_tmp club_applyed_tids))
    (ok true)
  )
)

(define-public (club_invite (tid uint))
  (let
    (
      (sender_tid (unwrap! (contract-call? .laser-eyes-v3 get_id_by_player tx-sender) (err ERR_ACCOUNT_NOT_ASSOCIATED)))
      (ctid (unwrap! (map-get? map_admin sender_tid) (err ERR_CLUB_NOT_ADMIN)))
      (club_detail (unwrap! (map-get? map_club_detail ctid) (err ERR_CLUB_NOT_EXIST)))
      (club_invite_tids (default-to (list) (map-get? map_club_invite ctid)))
      (member_invited_ctids (default-to (list) (map-get? map_member_invited tid)))
    )
    (asserts! (is-some (contract-call? .laser-eyes-v3 get_player_by_id tid)) (err ERR_MEMBER_NOT_EXIST))
    (asserts! (is-none (map-get? map_member { tid: tid, ctid: ctid })) (err ERR_MEMBER_ALREADY_IN_CLUB))
    (asserts! (is-none (index-of club_invite_tids tid)) (err ERR_CLUB_ALREADY_INVITE))
    (asserts! (is-none (index-of member_invited_ctids ctid)) (err ERR_CLUB_ALREADY_INVITE))
    (asserts! (< (get count club_detail) MAX_MEMBERS_COUNT) (err ERR_CLUB_MEMBERS_FULL))
    (asserts! (< (len club_invite_tids) u10) (err ERR_CLUB_INVITE_TOO_MANY))
    (asserts! (< (len member_invited_ctids) u5) (err ERR_MEMBER_INVITED_TOO_MANY))
    (map-set map_club_invite ctid (unwrap-panic (as-max-len? (append club_invite_tids tid) u10)))
    (map-set map_member_invited tid (unwrap-panic (as-max-len? (append member_invited_ctids ctid) u5)))
    (ok true)
  )
)

(define-public (club_cancel_invite (tid uint))
  (let
    (
      (sender_tid (unwrap! (contract-call? .laser-eyes-v3 get_id_by_player tx-sender) (err ERR_ACCOUNT_NOT_ASSOCIATED)))
      (ctid (unwrap! (map-get? map_admin sender_tid) (err ERR_CLUB_NOT_ADMIN)))
      (club_invite_tids (default-to (list) (map-get? map_club_invite ctid)))
      (member_invited_ctids (default-to (list) (map-get? map_member_invited tid)))
    )
    (asserts! (is-some (index-of member_invited_ctids ctid)) (err ERR_MEMBER_NO_SUCH_INVITE))
    (var-set m_tmp tid)
    (map-set map_club_invite ctid (filter not_tmp club_invite_tids))
    (var-set m_tmp ctid)
    (map-set map_member_invited tid (filter not_tmp member_invited_ctids))
    (ok true)
  )
)

(define-public (accept_club_invite (ctid uint))
  (match (contract-call? .laser-eyes-v3 get_id_by_player tx-sender) tid
    (tid_join_ctid tid ctid false)
    (err ERR_ACCOUNT_NOT_ASSOCIATED)
  )
)

(define-public (accept_member_apply (tid uint))
  (let
    (
      (sender_tid (unwrap! (contract-call? .laser-eyes-v3 get_id_by_player tx-sender) (err ERR_ACCOUNT_NOT_ASSOCIATED)))
      (ctid (unwrap! (map-get? map_admin sender_tid) (err ERR_CLUB_NOT_ADMIN)))
    )
    (asserts! (is-some (contract-call? .laser-eyes-v3 get_player_by_id tid)) (err ERR_MEMBER_NOT_EXIST))
    (tid_join_ctid tid ctid true)
  )
)

(define-public (decline_club_invite (ctid uint))
  (match (contract-call? .laser-eyes-v3 get_id_by_player tx-sender) tid
    (tid_not_join_ctid tid ctid false)
    (err ERR_ACCOUNT_NOT_ASSOCIATED)
  )
)

(define-public (decline_member_apply (tid uint))
  (let
    (
      (sender_tid (unwrap! (contract-call? .laser-eyes-v3 get_id_by_player tx-sender) (err ERR_ACCOUNT_NOT_ASSOCIATED)))
      (ctid (unwrap! (map-get? map_admin sender_tid) (err ERR_CLUB_NOT_ADMIN)))
    )
    (tid_not_join_ctid tid ctid true)
  )
)

(define-public (kick_out (tid uint))
  (let
    (
      (sender_tid (unwrap! (contract-call? .laser-eyes-v3 get_id_by_player tx-sender) (err ERR_ACCOUNT_NOT_ASSOCIATED)))
      (ctid (unwrap! (map-get? map_admin sender_tid) (err ERR_CLUB_NOT_ADMIN)))
    )
    (tid_exit_ctid tid ctid true)
  )
)

(define-public (exit (ctid uint))
  (match (contract-call? .laser-eyes-v3 get_id_by_player tx-sender) tid
    (tid_exit_ctid tid ctid false)
    (err ERR_ACCOUNT_NOT_ASSOCIATED)
  )
)

(define-read-only (get_member_apply (tid uint))
  (map-get? map_member_apply tid)
)

(define-read-only (get_member_invited (tid uint))
  (map-get? map_member_invited tid)
)

(define-read-only (get_club_invite (ctid uint))
  (map-get? map_club_invite ctid)
)

(define-read-only (get_club_applyed (ctid uint))
  (map-get? map_club_applyed ctid)
)

(define-private (tid_join_ctid (tid uint) (ctid uint) (b_club_accept_apply bool))
  (let
    (
      (join_ctids (default-to (list) (map-get? map_join tid)))
      (club_detail (unwrap! (map-get? map_club_detail ctid) (err ERR_CLUB_NOT_EXIST)))
      (club_invite_tids (default-to (list) (map-get? map_club_invite ctid)))
      (invite_index_opt (index-of club_invite_tids tid))
      (member_invited_ctids (default-to (list) (map-get? map_member_invited tid)))
      (invited_index_opt (index-of member_invited_ctids ctid))
      (b_invite (and (is-some invite_index_opt) (is-some invited_index_opt)))
      (member_apply_ctids (default-to (list) (map-get? map_member_apply tid)))
      (apply_index_opt (index-of member_apply_ctids ctid))
      (club_applyed_tids (default-to (list) (map-get? map_club_applyed ctid)))
      (applyed_index_opt (index-of club_applyed_tids tid))
      (b_apply (and (is-some apply_index_opt) (is-some applyed_index_opt)))
      (member_event_index (+ (default-to u0 (map-get? map_member_event_count tid)) u1))
      (club_event_index (+ (default-to u0 (map-get? map_club_event_count ctid)) u1))
      (insert_result (fold loop_1 LIST_MEMBER_INDEX { m: (get members club_detail), v_old: u0, v_new: tid, b_add: true, result: u0 }))
    )
    (asserts! (is-none (map-get? map_member { tid: tid, ctid: ctid })) (err ERR_MEMBER_ALREADY_IN_CLUB))
    (asserts! (< (len join_ctids) u5) (err ERR_MEMBER_JOIN_TOO_MANY))
    (asserts! (< (get count club_detail) MAX_MEMBERS_COUNT) (err ERR_CLUB_MEMBERS_FULL))
    (asserts! (or (and b_club_accept_apply b_apply) (and (not b_club_accept_apply) b_invite)) (err ERR_CLUB_JOIN_MISMATCH))
    (asserts! (or (is-eq (get result insert_result) u1) (is-eq (get result insert_result) u3)) (err ERR_JOIN_INSERT_FAIL))
    (and
      b_invite
      (var-set m_tmp tid)
      (map-set map_club_invite ctid (filter not_tmp club_invite_tids))
      (var-set m_tmp ctid)
      (map-set map_member_invited tid (filter not_tmp member_invited_ctids))
    )
    (and
      b_apply
      (var-set m_tmp ctid)
      (map-set map_member_apply tid (filter not_tmp member_apply_ctids))
      (var-set m_tmp tid)
      (map-set map_club_applyed ctid (filter not_tmp club_applyed_tids))
    )
    (if b_club_accept_apply
      (and
        (map-set map_member_event_count tid member_event_index)
        (map-set map_member_event
          (cb tid member_event_index)
          (cbtime3 EVENTTYPE_CLUB_ACCEPT_APPLY tid ctid)
        )
        (map-set map_club_event_count ctid club_event_index)
        (map-set map_club_event
          (cb ctid club_event_index)
          (cbtime3 EVENTTYPE_CLUB_ACCEPT_APPLY tid ctid)
        )
      )
      (and
        (map-set map_club_event_count ctid club_event_index)
        (map-set map_club_event
          (cb ctid club_event_index)
          (cbtime3 EVENTTYPE_MEMBER_ACCEPT_INVITE tid ctid)
        )
      )
    )
    (map-set map_club_detail ctid
      {
        count: (+ (get count club_detail) u1),
        members: (get m insert_result)
      })
    (map-set map_member { tid: tid, ctid: ctid } block-height)
    (map-set map_join tid (unwrap-panic (as-max-len? (append join_ctids ctid) u5)))
    (print {
      tid: tid,
      ctid: ctid,
      bcaa: b_club_accept_apply
    })
    (ok true)
  )
)

(define-private (tid_not_join_ctid (tid uint) (ctid uint) (b_club_decline_apply bool))
  (let
    (
      (club_invite_tids (default-to (list) (map-get? map_club_invite ctid)))
      (invite_index_opt (index-of club_invite_tids tid))
      (member_invited_ctids (default-to (list) (map-get? map_member_invited tid)))
      (invited_index_opt (index-of member_invited_ctids ctid))
      (b_invite (and (is-some invite_index_opt) (is-some invited_index_opt)))
      (member_apply_ctids (default-to (list) (map-get? map_member_apply tid)))
      (apply_index_opt (index-of member_apply_ctids ctid))
      (club_applyed_tids (default-to (list) (map-get? map_club_applyed ctid)))
      (applyed_index_opt (index-of club_applyed_tids tid))
      (b_apply (and (is-some apply_index_opt) (is-some applyed_index_opt)))
      (member_event_index (+ (default-to u0 (map-get? map_member_event_count tid)) u1))
      (club_event_index (+ (default-to u0 (map-get? map_club_event_count ctid)) u1))
    )
    (asserts! (or (and b_club_decline_apply b_apply) (and (not b_club_decline_apply) b_invite)) (err ERR_CLUB_NOT_JOIN_MISMATCH))
    (and
      b_invite
      (var-set m_tmp tid)
      (map-set map_club_invite ctid (filter not_tmp club_invite_tids))
      (var-set m_tmp ctid)
      (map-set map_member_invited tid (filter not_tmp member_invited_ctids))
    )
    (and
      b_apply
      (var-set m_tmp ctid)
      (map-set map_member_apply tid (filter not_tmp member_apply_ctids))
      (var-set m_tmp tid)
      (map-set map_club_applyed ctid (filter not_tmp club_applyed_tids))
    )
    (if b_club_decline_apply
      (and
        (map-set map_member_event_count tid member_event_index)
        (map-set map_member_event
          (cb tid member_event_index)
          (cbtime3 EVENTTYPE_CLUB_DECLINE_APPLY tid ctid)
        )
      )
      (and
        (map-set map_club_event_count ctid club_event_index)
        (map-set map_club_event
          (cb ctid club_event_index)
          (cbtime3 EVENTTYPE_MEMBER_DECLINE_INVITE tid ctid)
        )
      )
    )
    (ok true)
  )
)

(define-private (tid_exit_ctid (tid uint) (ctid uint) (b_kickout bool))
  (let
    (
      (summary (unwrap! (map-get? map_club_summary ctid) (err ERR_CLUB_NOT_EXIST)))
      (admin_tid (mod (get ud summary) u10000))
      (club_detail (unwrap! (map-get? map_club_detail ctid) (err ERR_CLUB_NOT_EXIST)))
      (join_ctids (default-to (list) (map-get? map_join tid)))
      (remove_result (fold loop_1 LIST_MEMBER_INDEX { m: (get members club_detail), v_old: tid, v_new: u0, b_add: false, result: u0 }))
      (member_event_index (+ (default-to u0 (map-get? map_member_event_count tid)) u1))
      (club_event_index (+ (default-to u0 (map-get? map_club_event_count ctid)) u1))
    )
    (asserts! (not (is-eq tid admin_tid)) (err ERR_CLUB_ADMIN_CANNOT_EXIT))
    (asserts! (is-some (map-get? map_member { tid: tid, ctid: ctid })) (err ERR_CLUB_NO_SUCH_MEMBER))
    (asserts! (is-eq (get result remove_result) u3) (err ERR_CLUB_REMOVE_MEMBER))
    (map-set map_club_detail ctid
      {
        count: (- (get count club_detail) u1),
        members: (get m remove_result)
      }
    )
    (map-delete map_member { tid: tid, ctid: ctid })
    (var-set m_tmp ctid)
    (map-set map_join tid (filter not_tmp join_ctids))
    (if b_kickout
      (and
        (map-set map_member_event_count tid member_event_index)
        (map-set map_member_event
          (cb tid member_event_index)
          (cbtime3 EVENTTYPE_CLUB_KICKOUT tid ctid)
        )
        (map-set map_club_event_count ctid club_event_index)
        (map-set map_club_event
          (cb ctid club_event_index)
          (cbtime3 EVENTTYPE_CLUB_KICKOUT tid ctid)
        )
      )
      (and
        (map-set map_club_event_count ctid club_event_index)
        (map-set map_club_event
          (cb ctid club_event_index)
          (cbtime3 EVENTTYPE_MEMBER_EXIT tid ctid)
        )
      )
    )
    (ok true)
  )
)

(define-private (loop_1 (i uint) (ud { m: (list 12 uint), v_old: uint, v_new: uint, b_add: bool, result: uint }))
  (if (> (get result ud) u0) ud (let ((mv (default-to u6401 (element-at (get m ud) i))) (o (get v_old ud)) (n (get v_new ud)))
  (if (is-eq mv u6401) (if (get b_add ud) (merge ud {m: (unwrap-panic (as-max-len? (append (get m ud) (get v_new ud)) u12)), result: u1 }) (merge ud { result: u2 }))
  (begin (if (if (is-eq (mod mv P4) o) (var-set m_tmp (+ (- mv o) n)) (if (is-eq (mod (/ mv P4) P4) o) (var-set m_tmp (+ (- mv (* o P4)) (* n P4))) (if (is-eq (mod (/ mv P8) P4) o)
  (var-set m_tmp (+ (- mv (* o P8)) (* n P8))) (if (is-eq (mod (/ mv P12) P4) o) (var-set m_tmp (+ (- mv (* o P12)) (* n P12))) (if (is-eq (mod (/ mv P16) P4) o)
  (var-set m_tmp (+ (- mv (* o P16)) (* n P16))) (if (is-eq (mod (/ mv P20) P4) o) (var-set m_tmp (+ (- mv (* o P20)) (* n P20))) (if (is-eq (mod (/ mv P24) P4) o)
  (var-set m_tmp (+ (- mv (* o P24)) (* n P24))) (if (is-eq (mod (/ mv P28) P4) o) (var-set m_tmp (+ (- mv (* o P28)) (* n P28))) (if (is-eq (mod (/ mv P32) P4) o)
  (var-set m_tmp (+ (- mv (* o P32)) (* n P32))) false))))))))) (begin (var-set m_tmp_index i) (merge ud { m: (map loop_2 LIST_MEMBER_INDEX (get m ud)), result: u3 })) ud)))))
)

(define-private (loop_2 (i uint) (v uint))
  (if (is-eq (var-get m_tmp_index) i) (var-get m_tmp) v)
)

(define-public (chat (ctid uint) (msg (buff 200)))
  (let
    (
      (tid (unwrap! (contract-call? .laser-eyes-v3 get_id_by_player tx-sender) (err ERR_ACCOUNT_NOT_ASSOCIATED)))
      (new_count (+ (/ (default-to u0 (map-get? map_chat_ext ctid)) P10) u1))
      (time (get_time))
    )
    (asserts! (is-some (map-get? map_member { tid: tid, ctid: ctid })) (err ERR_CLUB_NO_SUCH_MEMBER))
    (map-set map_chat_ext ctid (+ time (* new_count P10)))
    (map-set map_chat (cb ctid new_count)
      {
        msg: msg,
        ud: (cb tid time)
      }
    )
    (ok true)
  )
)

(define-read-only (get_chat_count (ctid uint))
  (/ (default-to u0 (map-get? map_chat_ext ctid)) P10)
)

(define-read-only (get_chats (keys (list 25 uint)))
  (map get_chat keys)
)

(define-read-only (get_chat (key uint))
  (map-get? map_chat key)
)

(define-public (launch_vote (ctid uint) (days uint) (title (buff 100)) (choices (list 4 (buff 25))))
  (let
    (
      (tid (unwrap! (contract-call? .laser-eyes-v3 get_id_by_player tx-sender) (err ERR_ACCOUNT_NOT_ASSOCIATED)))
      (new_vote_count (+ (default-to u0 (map-get? map_vote_count ctid)) u1))
      (vote_key (cb ctid new_vote_count))
    )
    (asserts! (is-some (map-get? map_club_summary ctid)) (err ERR_CLUB_NOT_EXIST))
    (asserts! (is-some (map-get? map_member { tid: tid, ctid: ctid })) (err ERR_CLUB_NO_SUCH_MEMBER))
    (asserts! (and (>= days u1) (<= days (var-get m_max_vote_days))) (err ERR_VOTE_DAYS_INVALID))
    (asserts! (> (len title) u0) (err ERR_VOTE_TITLE_INVALID))
    (asserts! (>= (len choices) u2) (err ERR_VOTE_CHOICE_INVALID))
    (or
      (is-eq (default-to u0 (map-get? map_admin tid)) ctid)
      (try! (contract-call? .laser-eyes-v3 deduct (var-get m_launch_vote_price)))
    )
    (map-set map_vote_count ctid new_vote_count)
    (map-set map_vote 
      vote_key
      {
        key: vote_key,
        start_at: (+ (get_time) (* block-height P10)),
        end_at: (+ block-height (* days u144)),
        launcher: tid,
        title: title,
        choices: choices
      }
    )
    (ok true)
  )
)

(define-public (vote (ctid uint) (index uint) (choice uint))
  (let
    (
      (tid (unwrap! (contract-call? .laser-eyes-v3 get_id_by_player tx-sender) (err ERR_ACCOUNT_NOT_ASSOCIATED)))
      (vote_key (cb ctid index))
      (vote_info (unwrap! (map-get? map_vote vote_key) (err ERR_VOTE_NOT_EXIST)))
      (vote_sn (+ ctid (* tid P4) (* index P8)))
      (stat_value (default-to u0 (map-get? map_vote_stat vote_key)))
    )
    (asserts! (<= block-height (get end_at vote_info)) (err ERR_VOTE_EXPIRED))
    (asserts! (is-some (map-get? map_member { tid: tid, ctid: ctid })) (err ERR_CLUB_NO_SUCH_MEMBER))
    (asserts! (is-none (map-get? map_vote_flag vote_sn)) (err ERR_VOTE_ALREADY_VOTE))
    (asserts! (and (>= choice u1) (<= choice (len (get choices vote_info)))) (err ERR_VOTE_CHOICE_INVALID))
    (map-set map_vote_flag vote_sn choice)
    (map-set map_vote_stat vote_key (+ stat_value (pow u10 (* u4 (- choice u1)))))
    (ok true)
  )
)

(define-read-only (get_vote_count (ctid uint))
  (default-to u0 (map-get? map_vote_count ctid))
)

(define-read-only (get_votes (keys (list 25 {k: uint, tid: uint})))
  (map get_vote keys)
)

(define-read-only (get_vote (key {k: uint, tid: uint}))
  (let ((k (get k key)) (t (get tid key))) {info: (map-get? map_vote k), stat: (default-to u0 (map-get? map_vote_stat k)), c: (if (is-eq t u0) u0 (default-to u0 (map-get? map_vote_flag (+ (mod k P4) (* t P4) (* (/ k P4) P8)))))})
)

(define-read-only (get_vote_choice (ctid uint) (tid uint) (index uint))
  (default-to u0 (map-get? map_vote_flag (+ ctid (* tid P4) (* index P8))))
)

(define-public (update_config (mint_price uint) (update_price uint) (vote_price uint) (max_vote_days uint))
  (ok (and
    (is-eq tx-sender OWNER)
    (var-set m_mint_price mint_price)
    (var-set m_update_price update_price)
    (var-set m_launch_vote_price vote_price)
    (var-set m_max_vote_days max_vote_days)
  ))
)

(define-read-only (get_config)
  {
    mint_price: (var-get m_mint_price),
    update_price: (var-get m_update_price),
    vote_price: (var-get m_launch_vote_price),
    max_vote_days: (var-get m_max_vote_days),
  }
)

(define-read-only (get_member_cb (player principal))
  (let
    (
      (tid (default-to u0 (contract-call? .laser-eyes-v3 get_id_by_player player)))
      (ctid (if (> tid u0) (default-to u0 (map-get? map_admin tid)) u0))
    )
    {
      last_id: (var-get m_mint_last_id),
      balance: (stx-get-balance player),
      tid: tid,
      ctid: ctid,
      event_count: (default-to u0 (map-get? map_member_event_count tid)),
      apply: (if (> tid u0) (map-get? map_member_apply tid) none),
      invited: (if (> tid u0) (map-get? map_member_invited tid) none),
      joins: (if (> tid u0) (map-get? map_join tid) none)
    }
  )
)

(define-read-only (get_club_cb (ctid uint) (player (optional principal)))
  (let
    (
      (tid (if (is-none player) u0 (default-to u0 (contract-call? .laser-eyes-v3 get_id_by_player (unwrap-panic player)))))
      (actid (if (> tid u0) (default-to u0 (map-get? map_admin tid)) u0))
    )
    {
      bh: block-height,
      tid: tid,
      actid: actid,
      b: (if (is-none player) u0 (stx-get-balance (unwrap-panic player))),
      apply: (if (> tid u0) (map-get? map_member_apply tid) none),
      joins: (if (> tid u0) (map-get? map_join tid) none),
      notice: (map-get? map_club_notice ctid),
      summary: (map-get? map_club_summary ctid),
      detail: (map-get? map_club_detail ctid),
      event_count: (default-to u0 (map-get? map_club_event_count ctid)),
      invite: (map-get? map_club_invite ctid),
      applyed: (map-get? map_club_applyed ctid),
      chat_ext: (default-to u0 (map-get? map_chat_ext ctid)),
      vote_count: (default-to u0 (map-get? map_vote_count ctid))
    }
  )
)

(define-read-only (get_club_bak (player principal))
  (let
    (
      (tid (default-to u0 (contract-call? .laser-eyes-v3 get_id_by_player player)))
      (actid (if (> tid u0) (default-to u0 (map-get? map_admin tid)) u0))
    )
    {
      tid: tid,
      actid: actid,
      b: (stx-get-balance player),
      apply: (if (> tid u0) (map-get? map_member_apply tid) none),
      joins: (if (> tid u0) (map-get? map_join tid) none),
    }
  )
)

(define-read-only (get_club_notice (ctid uint))
  (map-get? map_club_notice ctid)
)

(define-read-only (get_clubs_summary (ctids (list 25 uint)))
  (map get_club_summary ctids)
)

(define-read-only (get_club_summary (ctid uint))
  (map-get? map_club_summary ctid)
)

(define-read-only (get_clubs_name (keys (list 25 uint)))
  (map get_club_name keys)
)

(define-read-only (get_club_name (ctid uint))
  (get name (map-get? map_club_summary ctid))
)

(define-read-only (get_club_detail (ctid uint))
  (map-get? map_club_detail ctid)
)

(define-read-only (get_club_by_tid (tid uint))
  (map-get? map_admin tid)
)

(define-read-only (get_club_id_by_name (name (buff 25)))
  (map-get? map_name2ctid name)
)

(define-read-only (get_member (tid uint) (ctid uint))
  (map-get? map_member { tid: tid, ctid: ctid })
)

(define-read-only (get_joined_clubs (tid uint))
  (map-get? map_join tid)
)

(define-read-only (get_edit_club_check_info (name (buff 25)) (player principal))
  {
    bh: block-height,
    balance: (stx-get-balance player),
    taken: (is-some (map-get? map_name2ctid name))
  }
)

(define-read-only (get_apply_check_info (tid uint) (ctid uint))
  {
    mflag: (default-to u0 (map-get? map_member { tid: tid, ctid: ctid })),
    applys: (map-get? map_member_apply tid),
    applyed_count: (len (default-to (list) (map-get? map_club_applyed ctid))),
    member_count: (default-to u0 (get count (map-get? map_club_detail ctid)))
  }
)

(define-read-only (get_invite_check_info (tid uint) (ctid uint))
  {
    mflag: (default-to u0 (map-get? map_member { tid: tid, ctid: ctid })),
    invites: (map-get? map_club_invite ctid),
    invited_count: (len (default-to (list) (map-get? map_member_invited tid))),
    member_count: (default-to u0 (get count (map-get? map_club_detail ctid)))
  }
)

(define-read-only (get_member_event_count (tid uint))
  (default-to u0 (map-get? map_member_event_count tid))
)

(define-read-only (get_member_events (keys (list 25 uint)))
  (map get_member_event keys)
)

(define-read-only (get_member_event (key uint))
  (default-to u0 (map-get? map_member_event key))
)

(define-read-only (get_club_event_count (ctid uint))
  (default-to u0 (map-get? map_club_event_count ctid))
)

(define-read-only (get_club_events (keys (list 25 uint)))
  (map get_club_event keys)
)

(define-read-only (get_club_event (key uint))
  (default-to u0 (map-get? map_club_event key))
)

(define-private (get_time)
  (unwrap-panic (get-block-info? time (- block-height u1)))
)

(define-private (cb (a uint) (b uint))
  (+ a (* u10000 b))
)

(define-private (cbtime3 (a uint) (b uint) (c uint))
  (+ (unwrap-panic (get-block-info? time (- block-height u1))) (* a P12) (* b P16) (* c P20))
)

(define-private (not_tmp (val uint))
  (not (is-eq val (var-get m_tmp)))
)

(define-private (loop_lower (i uint) (ud { name: (buff 25), result: (buff 25) }))
  (match (element-at (get name ud) i) ch
    (merge ud {
      result: (unwrap-panic (as-max-len? (concat (get result ud) (default-to ch (map-get? map_u2l ch))) u25))
    })
    ud
  )
)

(map-set map_u2l 0x41 0x61) (map-set map_u2l 0x42 0x62) (map-set map_u2l 0x43 0x63) (map-set map_u2l 0x44 0x64) (map-set map_u2l 0x45 0x65) (map-set map_u2l 0x46 0x66) (map-set map_u2l 0x47 0x67) 
(map-set map_u2l 0x48 0x68) (map-set map_u2l 0x49 0x69) (map-set map_u2l 0x4a 0x6a) (map-set map_u2l 0x4b 0x6b) (map-set map_u2l 0x4c 0x6c) (map-set map_u2l 0x4d 0x6d) (map-set map_u2l 0x4e 0x6e) 
(map-set map_u2l 0x4f 0x6f) (map-set map_u2l 0x50 0x70) (map-set map_u2l 0x51 0x71) (map-set map_u2l 0x52 0x72) (map-set map_u2l 0x53 0x73) (map-set map_u2l 0x54 0x74) (map-set map_u2l 0x55 0x75) 
(map-set map_u2l 0x56 0x76) (map-set map_u2l 0x57 0x77) (map-set map_u2l 0x58 0x78) (map-set map_u2l 0x59 0x79) (map-set map_u2l 0x5a 0x7a)
