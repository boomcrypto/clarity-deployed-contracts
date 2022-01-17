;; Laser eyes NFT (visit 1.btc.us)

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant ERR_NO_AUTHORITY u1001)
(define-constant ERR_NO_NFT u1002)
(define-constant ERR_NO_META u1003)
(define-constant ERR_CID_INVALID u1004)
(define-constant ERR_BALANCE_NOT_ENOUGH u1005)
(define-constant ERR_CANNOT_MINT_NOW u1006)
(define-constant ERR_CANNOT_MINT_ANY_MORE u1007)
(define-constant ERR_ACCOUNT_NOT_ASSOCIATED u1008)
(define-constant ERR_ACCOUNT_ALREAYD_ASSOCIATED u1009)
(define-constant ERR_NAME_EMPTY u2001)
(define-constant ERR_NAME_ALREADY_TAKEN u2002)
(define-constant ERR_NAME_MINORNAME_NOT_MATCH u2003)
(define-constant ERR_MINOR_NAME_ALREADY_TAKEN u2004)

(define-constant OWNER tx-sender)
(define-constant LIST_AWARD (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20))
(define-constant LIST_INDEX (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24))
(define-constant AWARD_HOLDER_COUNT (len LIST_AWARD))
(define-constant AWARD_OWNER_PERCENT u50)
(define-constant MAX_TOKEN_ID u6400)

(define-non-fungible-token LaserEyes uint)
(define-data-var m_last_id uint u0)
(define-data-var m_mint_price uint u40000000)
(define-data-var m_update_price uint u8000000)
(define-data-var m_award_step uint u20090103)
(define-data-var m_mint_switch bool true)

(define-map map_meta
  uint
  {
    name: (buff 25),
    minor_name: (buff 25),
    cid: (string-ascii 50),
    bio: (buff 80),
    bh: uint,
  }
)

(define-map map_name2id
  (buff 25)
  uint
)

(define-map map_player2id
  principal
  uint
)

;; upper-case-char => lower-case-char
(define-map map_u2l
  (buff 1)
  (buff 1)
)

(define-public (mint (name (buff 25)) (minor_name (buff 25)) (cid (string-ascii 50)) (bio (buff 80)))
  (let
    (
      (token_id (+ u1 (var-get m_last_id)))
      (lower_name (get result (fold loop_lower LIST_INDEX { name: name, result: 0x })))
      (lower_minor_name (get result (fold loop_lower LIST_INDEX { name: minor_name, result: 0x })))
      (b_minor_name (> (len lower_minor_name) u0))
    )
    (asserts! (var-get m_mint_switch) (err ERR_CANNOT_MINT_NOW))
    (asserts! (<= token_id MAX_TOKEN_ID) (err ERR_CANNOT_MINT_ANY_MORE))
    (asserts! (is-none (map-get? map_player2id tx-sender)) (err ERR_ACCOUNT_ALREAYD_ASSOCIATED))
    (asserts! (> (len lower_name) u0) (err ERR_NAME_EMPTY))
    (asserts! (is-none (map-get? map_name2id lower_name)) (err ERR_NAME_ALREADY_TAKEN))
    (if b_minor_name
      (begin
        (asserts! (is-none (map-get? map_name2id lower_minor_name)) (err ERR_NAME_ALREADY_TAKEN))
        (if (> (len lower_name) (len lower_minor_name))
          (asserts! (get flag (fold loop_match LIST_INDEX { long_name: lower_name, short_name: lower_minor_name, flag: true })) (err ERR_NAME_MINORNAME_NOT_MATCH))
          (asserts! (get flag (fold loop_match LIST_INDEX { long_name: lower_minor_name, short_name: lower_name, flag: true })) (err ERR_NAME_MINORNAME_NOT_MATCH))
        )
      )
      true
    )
    (asserts! (> (len cid) u30) (err ERR_CID_INVALID))
    ;;
    (try! (deduct (var-get m_mint_price)))
    (try! (contract-call? .laser reward_minter))
    (match (nft-mint? LaserEyes token_id tx-sender)
      success
        (begin
          (var-set m_last_id token_id)
          (map-set map_name2id lower_name token_id)
          (and b_minor_name (map-set map_name2id lower_minor_name token_id))
          (map-set map_player2id tx-sender token_id)
          (map-set map_meta token_id {
            name: name,
            minor_name: minor_name,
            cid: cid,
            bio: bio,
            bh: block-height,
          })
          (ok true)
        )
      error (err error)
    )
  )
)

(define-public (update (cid (string-ascii 50)) (bio (buff 80)))
  (let
    (
      (token_id (unwrap! (map-get? map_player2id tx-sender) (err ERR_ACCOUNT_NOT_ASSOCIATED)))
      (nft_owner (unwrap! (nft-get-owner? LaserEyes token_id) (err ERR_NO_NFT)))
      (meta (unwrap! (map-get? map_meta token_id) (err ERR_NO_META)))
    )
    (asserts! (is-eq tx-sender nft_owner) (err ERR_NO_AUTHORITY))
    ;;
    (try! (deduct (var-get m_update_price)))
    (map-set map_meta token_id (merge meta {
      cid: cid,
      bio: bio,
    }))
    (ok true)
  )
)

(define-public (transfer (token_id uint) (sender principal) (recipient principal))
  (let
    (
      (sender_token_id (unwrap! (map-get? map_player2id sender) (err ERR_NO_NFT)))
    )
    (asserts! (is-eq tx-sender sender) (err ERR_NO_AUTHORITY))
    (asserts! (is-eq sender_token_id token_id) (err ERR_NO_AUTHORITY))
    (asserts! (is-none (map-get? map_player2id recipient)) (err ERR_ACCOUNT_ALREAYD_ASSOCIATED))
    (match (nft-transfer? LaserEyes token_id sender recipient)
      success
        (begin
          (map-delete map_player2id sender)
          (map-set map_player2id recipient token_id)
          (ok success)
        )
      error (err error)
    )
  )
)

(define-public (update_price (new_mint_price uint) (new_update_price uint))
  (begin
    (asserts! (is-eq tx-sender OWNER) (err ERR_NO_AUTHORITY))
    (var-set m_mint_price new_mint_price)
    (var-set m_update_price new_update_price)
    (ok true)
  )
)

(define-public (deduct (amount uint))
  (let
    (
      (owner_award (/ (* amount AWARD_OWNER_PERCENT) u100))
      (per_holder_award (/ (- amount owner_award) AWARD_HOLDER_COUNT))
      (last_stamp (unwrap-panic (get-block-info? time (- block-height u2027))))
      (base (+ (* (/ stx-liquid-supply u1000000) u31) (* burn-block-height burn-block-height u997) (* last_stamp last_stamp u49957)))
    )
    (asserts! (>= (stx-get-balance tx-sender) amount) (err ERR_BALANCE_NOT_ENOUGH))
    (try! (stx-transfer? owner_award tx-sender OWNER))
    (if (<= (var-get m_last_id) u1)
      (ok true)
      (begin
        (fold loop_award LIST_AWARD { index: base, step: (var-get m_award_step), award: per_holder_award, last_id: (var-get m_last_id) })
        (var-set m_award_step (+ (mod last_stamp u57) u1))
        (ok true)
      )
    )
  )
)

(define-public (set_mint_switch (mint_switch bool))
  (ok (and (is-eq tx-sender OWNER) (var-set m_mint_switch mint_switch)))
)

(define-read-only (get-owner (token_id uint))
  (ok (nft-get-owner? LaserEyes token_id))
)

(define-read-only (get-last-token-id)
  (ok (var-get m_last_id))
)

(define-read-only (get-token-uri (token_id uint))
  (ok (get cid (map-get? map_meta token_id)))
)

(define-read-only (get_summary (player (optional principal)) (name (optional (buff 25))) (token_id uint))
  (let
    (
      (player_token_id (if (is-some player) (default-to u0 (map-get? map_player2id (unwrap-panic player))) u0))
      (name_token_id (if (is-some name) (default-to u0 (map-get? map_name2id (unwrap-panic name))) u0))
    )
    {
      last_id: (var-get m_last_id),
      mint_price: (var-get m_mint_price),
      update_price: (var-get m_update_price),
      token_id: player_token_id,
      player2meta: (if (> player_token_id u0) (map-get? map_meta player_token_id) none),
      name_token_id: name_token_id,
      name2meta: (if (> name_token_id u0) (map-get? map_meta name_token_id) none),
      tokenid2meta: (if (> token_id u0) (map-get? map_meta token_id) none),
      laser_count: (if (is-some player) (unwrap-panic (contract-call? .laser get-balance (unwrap-panic player))) u0),
    }
  )
)

(define-read-only (get_members (key_list (list 25 uint)))
  (map get_member key_list)
)

(define-read-only (get_member (index uint))
  (map-get? map_meta index)
)

(define-read-only (resolve_player (player principal))
  (let
    (
      (token_id (default-to u0 (map-get? map_player2id player)))
    )
    {
      token_id: token_id,
      meta: (map-get? map_meta token_id),
    }
  )
)

;; name is lower case
(define-read-only (resolve_name (name (buff 25)))
  (let
    (
      (token_id (default-to u0 (map-get? map_name2id name)))
    )
    {
      token_id: token_id,
      meta: (map-get? map_meta token_id),
    }
  )
)

;; name and minor_name are both lower-case
(define-read-only (get_pre_act_info (player principal) (name (buff 25)) (minor_name (buff 25)))
  {
    own: (is-some (map-get? map_player2id player)),
    balance: (stx-get-balance player),
    name: (and (> (len name) u0) (is-none (map-get? map_name2id name))),
    minor_name: (or (is-eq (len minor_name) u0) (is-none (map-get? map_name2id minor_name))),
  }
)

;; name is lower-case
(define-read-only (can_name_be_minted (name (buff 25)))
  (and (> (len name) u0) (is-none (map-get? map_name2id name)))
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
      (token_id (+ (mod (+ (get index ud) i) (get last_id ud)) u1))
      (holder (unwrap-panic (nft-get-owner? LaserEyes token_id)))
      (holder_balance (/ (stx-get-balance tx-sender) u10000))
    )
    (or (is-eq holder tx-sender) (is-ok (stx-transfer? (get award ud) tx-sender holder)))
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

(define-private (init)
  (begin
    (map-set map_u2l 0x41 0x61) (map-set map_u2l 0x42 0x62) (map-set map_u2l 0x43 0x63) (map-set map_u2l 0x44 0x64) (map-set map_u2l 0x45 0x65)
    (map-set map_u2l 0x46 0x66) (map-set map_u2l 0x47 0x67) (map-set map_u2l 0x48 0x68) (map-set map_u2l 0x49 0x69) (map-set map_u2l 0x4a 0x6a)
    (map-set map_u2l 0x4b 0x6b) (map-set map_u2l 0x4c 0x6c) (map-set map_u2l 0x4d 0x6d) (map-set map_u2l 0x4e 0x6e) (map-set map_u2l 0x4f 0x6f)
    (map-set map_u2l 0x50 0x70) (map-set map_u2l 0x51 0x71) (map-set map_u2l 0x52 0x72) (map-set map_u2l 0x53 0x73) (map-set map_u2l 0x54 0x74)
    (map-set map_u2l 0x55 0x75) (map-set map_u2l 0x56 0x76) (map-set map_u2l 0x57 0x77) (map-set map_u2l 0x58 0x78) (map-set map_u2l 0x59 0x79)
    (map-set map_u2l 0x5a 0x7a)
    (print "init finish")
  )
)

(init)
