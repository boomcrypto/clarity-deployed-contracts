(define-constant ERR_ACCOUNT_NOT_ASSOCIATED u1001)

(define-constant LIST_LATEST (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12))
(define-constant MAX_CACHE_MSG_COUNT u100000)

(define-data-var m_chat_index uint u0)

(define-map map_chat
  uint
  {
    ud: uint,
    msg: (buff 120)
  }
)

(define-public (chat (msg (buff 120)))
  (let
    (
      (tid (unwrap! (contract-call? .laser-eyes-v5 get_id_by_player contract-caller) (err ERR_ACCOUNT_NOT_ASSOCIATED)))
      (next_index (+ (var-get m_chat_index) u1))
      (real_index (if (> next_index MAX_CACHE_MSG_COUNT) u1 next_index))
      (stamp (unwrap-panic (get-block-info? time (- block-height u1))))
    )
    (var-set m_chat_index real_index)
    (map-set map_chat real_index
      {
        ud: (+ tid (* stamp u10000)),
        msg: msg
      }
    )
    (ok true)
  )
)

(define-read-only (get_chat_index)
  (var-get m_chat_index)
)

(define-read-only (get_summary (player (optional principal)))
  {
    p: (if (is-some player) (contract-call? .laser-eyes-v5 resolve_player (unwrap-panic player)) { tid: u0, meta: none }),
    index: (var-get m_chat_index),
    latest: (get r (fold loop_latest LIST_LATEST {i: (var-get m_chat_index), r: (list)}))
  }
)

(define-read-only (get_chats (keys (list 25 uint)))
  (map get_chat keys)
)

(define-read-only (get_chat (key uint))
  (map-get? map_chat key)
)

(define-private (loop_latest (i uint) (ud { i: uint, r: (list 12 {ud: uint, msg: (buff 120)}) }))
  (if (> (get i ud) u0) (match (map-get? map_chat (get i ud)) info { i: (if (> (get i ud) u1) (- (get i ud) u1) MAX_CACHE_MSG_COUNT), r: (unwrap-panic (as-max-len? (append (get r ud) info) u12)) } (merge ud { i: u0 })) ud))