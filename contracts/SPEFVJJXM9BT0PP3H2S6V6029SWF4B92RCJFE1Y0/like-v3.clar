;; Laser eyes NFT (visit https://onedotbtcus.bitbucket.io/ or 1.btc.us)

(define-constant ERR_NO_AUTHORITY u1001)
(define-constant ERR_TOKEN_NOT_EXIST u1002)
(define-constant ERR_CANNOT_LIKE_SELF u1003)
(define-constant ERR_ALREADY_LIKED u1004)
(define-constant ERR_INVALID_PRICE u1005)

(define-constant OWNER tx-sender)

(define-data-var m_liked_award_percent uint u20)
(define-data-var m_like_price uint u500000)

(define-map map_like_cnt
  uint
  uint
)

(define-map map_like
  { tid: uint, index: uint }
  uint
)

(define-map map_liked_cnt
  uint
  uint
)

(define-map map_liked
  { tid: uint, index: uint }
  uint
)

(define-map map_note
  { tid: uint, liked_tid: uint }
  bool
)

(define-public (like (tid uint))
  (let
    (
      (sender_tid (unwrap! (contract-call? .laser-eyes-v3 get_id_by_player tx-sender) (err ERR_NO_AUTHORITY)))
      (liked_owner (unwrap! (contract-call? .laser-eyes-v3 get_player_by_id tid) (err ERR_TOKEN_NOT_EXIST)))
      (like_cnt (+ (default-to u0 (map-get? map_like_cnt sender_tid)) u1))
      (liked_cnt (+ (default-to u0 (map-get? map_liked_cnt tid)) u1))
      (like_price (var-get m_like_price))
      (liked_award (/ (* like_price (var-get m_liked_award_percent)) u100))
    )
    (asserts! (is-none (map-get? map_note { tid: sender_tid, liked_tid: tid })) (err ERR_ALREADY_LIKED))
    (asserts! (not (is-eq liked_owner tx-sender)) (err ERR_CANNOT_LIKE_SELF))
    (try! (stx-transfer? liked_award tx-sender liked_owner))
    (try! (contract-call? .laser-eyes-v3 deduct (- like_price liked_award)))
    (map-set map_like_cnt sender_tid like_cnt)
    (map-set map_like { tid: sender_tid, index: like_cnt} (+ tid (* u10000 block-height)))
    (map-set map_liked_cnt tid liked_cnt)
    (map-set map_liked { tid: tid, index: liked_cnt } (+ sender_tid (* u10000 block-height)))
    (map-set map_note { tid: sender_tid, liked_tid: tid } true)
    (contract-call? .laser-eyes-v3 set_ud tid u6 u4 liked_cnt)
  )
)

(define-public (set_like_price (price uint))
  (begin
    (asserts! (is-eq tx-sender OWNER) (err ERR_NO_AUTHORITY))
    (asserts! (and (>= price u10000) (<= price u10000000)) (err ERR_INVALID_PRICE))
    (ok (var-set m_like_price price))    
  )
)

(define-read-only (has_like (tid uint) (liked_tid uint))
  (default-to false (map-get? map_note { tid: tid, liked_tid: liked_tid }))
)

(define-read-only (get_like_count (tid uint))
  (default-to u0 (map-get? map_like_cnt tid))
)

(define-read-only (get_like_list (tid uint) (index_list (list 25 uint)))
  (get r (fold loop_l index_list { tid: tid , r: (list) }))
)

(define-read-only (get_like_data (tid uint) (index_list (list 25 uint)))
  {
    total: (default-to u0 (map-get? map_like_cnt tid)),
    likes: (get r (fold loop_l index_list { tid: tid , r: (list) }))
  }
)

(define-private (loop_l (i uint) (ud { tid: uint, r: (list 25 uint) }))
  (match (map-get? map_like { tid: (get tid ud), index: i}) val
    (merge ud {
      r: (unwrap-panic (as-max-len? (append (get r ud) val) u25))
    })
    ud
  )
)

(define-read-only (get_liked_count (tid uint))
  (default-to u0 (map-get? map_liked_cnt tid))
)

(define-read-only (get_liked_list (tid uint) (index_list (list 25 uint)))
  (get r (fold loop_ld index_list { tid: tid , r: (list) }))
)

(define-read-only (get_liked_data (tid uint) (index_list (list 25 uint)))
  {
    total: (default-to u0 (map-get? map_liked_cnt tid)),
    likes: (get r (fold loop_ld index_list { tid: tid , r: (list) }))
  }
)

(define-private (loop_ld (i uint) (ud { tid: uint, r: (list 25 uint) }))
  (match (map-get? map_liked { tid: (get tid ud), index: i}) val
    (merge ud {
      r: (unwrap-panic (as-max-len? (append (get r ud) val) u25))
    })
    ud
  )
)