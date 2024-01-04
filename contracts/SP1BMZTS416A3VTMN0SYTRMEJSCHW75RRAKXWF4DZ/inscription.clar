;; Inscription
;; By https://stacksinscription.com

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant ERR_NO_AUTHORITY u1001)
(define-constant ERR_INVALID_TYPE u1002)
(define-constant ERR_INVALID_CALLER u1003)
(define-constant ERR_BURN_STX u1004)
(define-constant ERR_INVALID_PAYLOAD u1005)
(define-constant ERR_INVALID_TOKEN_ID u1006)
(define-constant ERR_STX10_INVALID_TICK u2001)
(define-constant ERR_STX10_INVALID_MAX u2002)
(define-constant ERR_STX10_INVALID_LIM u2003)
(define-constant ERR_STX10_TICK_EXISTS u2004)
(define-constant ERR_STX10_INVALID_AMT u2005)
(define-constant ERR_STX10_INVALID_RECEIVER u2006)

(define-constant DEFAULT_INSCRIBE_FEE u50000)
(define-constant DEPLOY_STX10_FEE u15000000)
(define-constant MIN_STX10_TICK_LENGTH u2)
(define-constant MIN_STX10_MINT_TIMES u20000)
(define-constant MAX_STX10_SUPPLY u10000000000000000)
(define-constant TYPE_TEXT "text")
(define-constant TYPE_DEPLOY_STX10 "deploy-stx10")

(define-non-fungible-token inscription uint)

(define-data-var m_last_token_id uint u0)
(define-data-var m_last_stx10_tick_index uint u0)

(define-map map_inscriptions
  uint
  {
    block: uint,
    type: (string-ascii 32),
    payload: (buff 1022976), ;; Max 999k
  }
)

(define-map map_stx10_tick
  uint              ;; tick_index
  (string-ascii 16) ;; tick
)

(define-map map_stx10_attribute
  (string-ascii 16)
  {
    block: uint,
    tokenId: uint,
    max: uint,
    lim: uint,
  }
)

(define-map map_stx10_total_suppy
  (string-ascii 16)
  uint
)

(define-map map_stx10_balance
  {
    tick: (string-ascii 16),
    address: principal,
  }
  uint
)

(define-read-only (get-last-token-id)
  (ok (var-get m_last_token_id))
)

(define-read-only (get-token-uri (tokenId uint))
  (ok (if (and (> tokenId u0) (>= (var-get m_last_token_id) tokenId)) (some "ipfs://QmdXxMw2b7aqf38XfKhRjjiPzsMXxqu5job4atrDvzVT4s") none))
)

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? inscription id))
)

(define-public (transfer (id uint) (sender principal) (receiver principal))
  (begin
    (asserts! (is-eq sender tx-sender) (err ERR_NO_AUTHORITY))
    (print {
      type: "nft-transfer",
      id: id,
      sender: sender,
      receiver: receiver,
    })
    (nft-transfer? inscription id sender receiver)
  )
)

(define-read-only (get_summary)
  {
    last_token_id: (var-get m_last_token_id),
    last_stx10_tick_index: (var-get m_last_stx10_tick_index),
  }
)

;; May fail if payload too big, can use /v2/map_entry
(define-read-only (get_inscription (id uint))
  (map-get? map_inscriptions id)
)

(define-public (inscribe_text (payload (buff 1022976)))
  (inscribe "text" payload DEFAULT_INSCRIBE_FEE)
)

(define-public (inscribe_misc (type (string-ascii 32)) (payload (buff 1022976)))
  (begin
    (asserts! (not (or (is-eq (len type) u0) (is-eq type TYPE_TEXT) (is-eq type TYPE_DEPLOY_STX10))) (err ERR_INVALID_TYPE))
    (asserts! (not (has_invalid_type_chars type)) (err ERR_INVALID_TYPE))
    (inscribe type payload DEFAULT_INSCRIBE_FEE)
  )
)

(define-read-only (get_stx10_attribute (tick (string-ascii 16)))
  (map-get? map_stx10_attribute tick)
)

(define-read-only (get_stx10_total_supply (tick (string-ascii 16)))
  (map-get? map_stx10_total_suppy tick)
)

(define-read-only (get_stx10_balance (tick (string-ascii 16)) (address principal))
  (default-to u0 (map-get? map_stx10_balance { tick: tick, address: address }))
)

(define-read-only (get_stx10_ticks (index_list (list 25 uint)))
  (map get_stx10_tick index_list)
)

(define-read-only (get_stx10_tick (index uint))
  (map-get? map_stx10_tick index)
)

(define-read-only (get_stx10_infos_by_index_list (index_list (list 10 uint)))
  (map get_stx10_info_by_index index_list)
)

(define-read-only (get_stx10_info_by_index (index uint))
  (let
    (
      (tick (default-to "" (map-get? map_stx10_tick index)))
    )
    {
      tick: tick,
      attr: (map-get? map_stx10_attribute tick),
      supply: (default-to u0 (map-get? map_stx10_total_suppy tick)),
    }
  )
)

(define-read-only (get_stx10_infos_by_ticks (tick_list (list 15 (string-ascii 16))))
  (map get_stx10_info_by_tick tick_list)
)

(define-read-only (get_stx10_info_by_tick (tick (string-ascii 16)))
  {
    attr: (map-get? map_stx10_attribute tick),
    supply: (default-to u0 (map-get? map_stx10_total_suppy tick)),
  }
)

(define-read-only (get_stx10_transfer_payload (tick (string-ascii 16)) (amt uint))
  (concat (concat (concat (concat "{\"p\":\"stx10\",\"op\":\"transfer\",\"tick\":\"" tick) "\",\"amt\":\"") (int-to-ascii amt)) "\"}")
)

;; {"p":"stx10","op":"deploy","tick":"bits","max":"21000000000000","lim":"21000000"}
(define-public (inscribe_deploy_stx10 (payload (string-ascii 120)) (tick (string-ascii 16)) (max uint) (lim uint))
  (begin
    (asserts! (>= (len tick) MIN_STX10_TICK_LENGTH) (err ERR_STX10_INVALID_TICK))
    (asserts! (not (has_invalid_tick_chars tick)) (err ERR_STX10_INVALID_TICK))
    (asserts! (and (> max u0) (<= max MAX_STX10_SUPPLY)) (err ERR_STX10_INVALID_MAX))
    (asserts! (and (> lim u0) (>= (/ max lim) MIN_STX10_MINT_TIMES)) (err ERR_STX10_INVALID_LIM))
    (asserts! (is-eq payload (concat (concat (concat (concat (concat (concat "{\"p\":\"stx10\",\"op\":\"deploy\",\"tick\":\"" tick) "\",\"max\":\"") (int-to-ascii max)) "\",\"lim\":\"") (int-to-ascii lim)) "\"}")) (err ERR_INVALID_PAYLOAD))
    (asserts! (is-none (map-get? map_stx10_attribute tick)) (err ERR_STX10_TICK_EXISTS))
    (try! (inscribe TYPE_DEPLOY_STX10 (ascii_2_buff payload) DEPLOY_STX10_FEE))
    (map-set map_stx10_attribute tick {
      block: block-height,
      tokenId: (var-get m_last_token_id),
      max: max,
      lim: lim,
    })
    (map-set map_stx10_total_suppy tick u0)
    (var-set m_last_stx10_tick_index (+ (var-get m_last_stx10_tick_index) u1))
    (map-set map_stx10_tick (var-get m_last_stx10_tick_index) tick)
    (print {
      type: "deploy-stx10",
      caller: contract-caller,
      payload: payload,
      tick: tick,
      max: max,
      lim: lim,
    })
    (ok true)
  )
)

;; {"p":"stx10","op":"mint","tick":"bits","amt":"21000000"}
(define-public (inscribe_mint_stx10 (payload (string-ascii 120)) (tick (string-ascii 16)) (amt uint))
  (let
    (
      (tick_info (unwrap! (map-get? map_stx10_attribute tick) (err ERR_STX10_INVALID_TICK)))
      (total_supply (unwrap! (map-get? map_stx10_total_suppy tick) (err ERR_STX10_INVALID_TICK)))
      (balance (default-to u0 (map-get? map_stx10_balance { tick: tick, address: contract-caller })))
      (des_info (unwrap! (principal-destruct? contract-caller) (err ERR_INVALID_CALLER)))
    )
    (asserts! (is-none (get name des_info)) (err ERR_INVALID_CALLER))
    (asserts! (and (> amt u0) (<= amt (get lim tick_info)) (<= (+ total_supply amt) (get max tick_info))) (err ERR_STX10_INVALID_AMT))
    (asserts! (is-eq payload (concat (concat (concat (concat "{\"p\":\"stx10\",\"op\":\"mint\",\"tick\":\"" tick) "\",\"amt\":\"") (int-to-ascii amt)) "\"}")) (err ERR_INVALID_PAYLOAD))
    (asserts! (is-ok (stx-burn? DEFAULT_INSCRIBE_FEE contract-caller)) (err ERR_BURN_STX))
    (map-set map_stx10_total_suppy tick (+ total_supply amt))
    (map-set map_stx10_balance { tick: tick, address: contract-caller } (+ balance amt))
    (print {
      type: "mint-stx10",
      caller: contract-caller,
      payload: payload,
      tick: tick,
      amt: amt,
    })
    (ok true)
  )
)

;; {"p":"stx10","op":"transfer","tick":"bits","amt":"500000"}
(define-public (inscribe_transfer_stx10 (payload (string-ascii 120)) (receiver principal) (tick (string-ascii 16)) (amt uint))
  (let
    (
      (sender tx-sender)
      (tick_info (unwrap! (map-get? map_stx10_attribute tick) (err ERR_STX10_INVALID_TICK)))
      (sender_balance (default-to u0 (map-get? map_stx10_balance { tick: tick, address: sender })))
      (receiver_balance (default-to u0 (map-get? map_stx10_balance { tick: tick, address: receiver })))
    )
    (asserts! (and (> amt u0) (<= amt sender_balance)) (err ERR_STX10_INVALID_AMT))
    (asserts! (not (is-eq sender receiver)) (err ERR_STX10_INVALID_RECEIVER))
    (asserts! (is-eq payload (get_stx10_transfer_payload tick amt)) (err ERR_INVALID_PAYLOAD))
    (map-set map_stx10_balance { tick: tick, address: sender } (- sender_balance amt))
    (map-set map_stx10_balance { tick: tick, address: receiver } (+ receiver_balance amt))
    (print {
      type: "transfer-stx10",
      payload: payload,
      sender: sender,
      receiver: receiver,
      tick: tick,
      amt: amt,
    })
    (ok true)
  )
)

(define-private (inscribe (type (string-ascii 32)) (payload (buff 1022976)) (burn_fee uint))
  (let
    (
      ;; (payload_len (len payload))
      (token_id (+ (var-get m_last_token_id) u1))
      (des_info (unwrap! (principal-destruct? contract-caller) (err ERR_INVALID_CALLER)))
    )
    (asserts! (is-none (get name des_info)) (err ERR_INVALID_CALLER))
    ;; (asserts! (> payload_len u0) (err ERR_INVALID_PAYLOAD))
    (asserts! (is-ok (stx-burn? burn_fee contract-caller)) (err ERR_BURN_STX))
    (map-set map_inscriptions token_id {
      block: block-height,
      type: type,
      payload: payload,
    })
    (try! (nft-mint? inscription token_id contract-caller))
    (print {
      type: "inscribe",
      caller: contract-caller,
      inscribe_type: type,
      token_id: token_id,
      ;; len: payload_len,
    })
    (var-set m_last_token_id token_id)
    (ok true)
  )
)

;;;; Checkers ;;;;
;;; tick
(define-map map_tick (string-ascii 1) (buff 1))  ;; ascii => buff
(define-private (iter_tick (ch (string-ascii 1)) (b (buff 1)))
  (map-set map_tick ch b)
)
(map iter_tick "abcdefghijklmnopqrstuvwxyz" 0x6162636465666768696a6b6c6d6e6f707172737475767778797a)

(define-read-only (has_invalid_tick_chars (name (string-ascii 48)))
  (< (len (filter check_tick name)) (len name))
)

(define-private (check_tick (char (string-ascii 1)))
  (is-some (map-get? map_tick char))
)

;;; type
(define-map map_type (string-ascii 1) (buff 1))
(define-private (iter_type (ch (string-ascii 1)) (b (buff 1)))
  (map-set map_type ch b)
)
(map iter_type "0123456789abcdefghijklmnopqrstuvwxyz/;+-=" 0x303132333435363738396162636465666768696a6b6c6d6e6f707172737475767778797a2f3b2b2d3d)

(define-read-only (has_invalid_type_chars (name (string-ascii 48)))
  (< (len (filter check_type name)) (len name))
)

(define-private (check_type (ch (string-ascii 1)))
  (is-some (map-get? map_type ch))
)

;;; ascii => buff
(define-map map_convert (string-ascii 1) (buff 1))
(define-private (iter_convert (ch (string-ascii 1)) (b (buff 1)))
  (map-set map_convert ch b)
)
(map iter_convert "0123456789abcdefghijklmnopqrstuvwxyz/;+-=_\",{}:." 0x303132333435363738396162636465666768696a6b6c6d6e6f707172737475767778797a2f3b2b2d3d5f222c7b7d3a2e)

(define-read-only (ascii_2_buff (str (string-ascii 120)))
  (fold convert_ascii str 0x)
)

(define-private (convert_ascii (ch (string-ascii 1)) (result (buff 120)))
  (unwrap-panic (as-max-len? (concat result (unwrap-panic (map-get? map_convert ch))) u120))
)

;;; Migrate from https://explorer.hiro.so/txid/SP1BMZTS416A3VTMN0SYTRMEJSCHW75RRAKXWF4DZ.stacks-inscription?chain=mainnet
(define-constant ERR_MIGRATE u3001)

(define-data-var m_migrate_operator (optional principal) (some tx-sender))

(define-public (migrate_stx10_ticks)
  (begin
    (asserts! (is-eq (some tx-sender) (var-get m_migrate_operator)) (err ERR_MIGRATE))
    (migrate_stx10_tick u1)
    (migrate_stx10_tick u2)
    (migrate_stx10_tick u3)
    (migrate_stx10_tick u4)
    (migrate_stx10_tick u5)
    (ok (var-set m_last_stx10_tick_index u5))
  )
)

(define-private (migrate_stx10_tick (tick_index uint))
  (let
    (
      (tick (unwrap-panic (contract-call? .stacks-inscription get_stx10_tick tick_index)))
      (attribute (unwrap-panic (contract-call? .stacks-inscription get_stx10_attribute tick)))
    )
    (print {
      type: "migrate-stx10-tick",
      tick_index: tick_index,
      tick: tick,
      attribute: attribute,
    })
    (map-set map_stx10_tick tick_index tick)
    (map-set map_stx10_attribute tick attribute)
  )
)

(define-public (migrate_stx10_balance (address principal) (tick (string-ascii 16)))
  (let
    (
      (balance (contract-call? .stacks-inscription get_stx10_balance tick address))
    )
    (asserts! (is-eq (some tx-sender) (var-get m_migrate_operator)) (err ERR_MIGRATE))
    (if (> balance u0)
      (ok (begin
        (print {
          type: "migrate-stx10-balance",
          address: address,
          tick: tick,
          balance: balance,
        })
        (map-set map_stx10_balance { tick: tick, address: address } balance)
        (map-set map_stx10_total_suppy tick (+ (default-to u0 (map-get? map_stx10_total_suppy tick)) balance))
      ))
      (ok false)
    )
  )
)

(define-public (migrate_nft (unused uint))
  (let
    (
      (token_id (+ (var-get m_last_token_id) u1))
      (receiver (unwrap-panic (unwrap-panic (contract-call? .stacks-inscription get-owner token_id))))
    )
    (asserts! (is-eq (some tx-sender) (var-get m_migrate_operator)) (err ERR_MIGRATE))
    (try! (nft-mint? inscription token_id receiver))
    (map-set map_inscriptions token_id (unwrap-panic (contract-call? .stacks-inscription get_inscription token_id)))
    (print {
      type: "migrate-nft",
      id: token_id,
      receiver: receiver,
    })
    (ok (var-set m_last_token_id token_id))
  )
)

(define-public (bulk_migrate_nft (unused (list 50 uint)))
  (ok (map migrate_nft unused))
)

(define-public (migrate_finish)
  (ok (var-set m_migrate_operator none))
)

(define-read-only (get_migrate_operator)
  (var-get m_migrate_operator)
)
