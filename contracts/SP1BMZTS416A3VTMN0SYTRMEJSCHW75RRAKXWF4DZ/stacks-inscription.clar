;; Stacks inscription
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
(define-constant ERR_STX10_TICK_ALREADY_EXISTS u2004)
(define-constant ERR_STX10_INVALID_AMT u2005)
(define-constant ERR_STX10_INVALID_RECEIVER u2006)

(define-constant DEFAULT_INSCRIBE_FEE u50000)
(define-constant DEPLOY_STX10_FEE u15000000)
(define-constant MIN_STX10_TICK_LENGTH u2)
(define-constant MIN_STX10_MINT_TIMES u20000)
(define-constant MAX_STX10_SUPPLY u10000000000000000)
(define-constant TYPE_TEXT "text")
(define-constant TYPE_DEPLOY_STX10 "deploy-stx10")

(define-non-fungible-token StacksInscription uint)

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
  (ok (if (and (> tokenId u0) (>= (var-get m_last_token_id) tokenId)) (some "") none))
)

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? StacksInscription id))
)

(define-public (transfer (id uint) (sender principal) (receiver principal))
  (begin
    (asserts! (is-eq sender tx-sender) (err ERR_NO_AUTHORITY))
    (nft-transfer? StacksInscription id sender receiver)
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

;; {"p":"stx10","op":"deploy","tick":"bits","max":"21000000000000","lim":"100000000"}
(define-public (inscribe_deploy_stx10 (payload (string-ascii 120)) (tick (string-ascii 16)) (max uint) (lim uint))
  (begin
    (asserts! (>= (len tick) MIN_STX10_TICK_LENGTH) (err ERR_STX10_INVALID_TICK))
    (asserts! (not (has_invalid_tick_chars tick)) (err ERR_STX10_INVALID_TICK))
    (asserts! (and (> max u0) (<= max MAX_STX10_SUPPLY)) (err ERR_STX10_INVALID_MAX))
    (asserts! (and (> lim u0) (>= (/ max lim) MIN_STX10_MINT_TIMES)) (err ERR_STX10_INVALID_LIM))
    (asserts! (is-eq payload (concat (concat (concat (concat (concat (concat "{\"p\":\"stx10\",\"op\":\"deploy\",\"tick\":\"" tick) "\",\"max\":\"") (int-to-ascii max)) "\",\"lim\":\"") (int-to-ascii lim)) "\"}")) (err ERR_INVALID_PAYLOAD))
    (asserts! (is-none (map-get? map_stx10_attribute tick)) (err ERR_STX10_TICK_ALREADY_EXISTS))
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

;; {"p":"stx10","op":"mint","tick":"bits","amt":"100000000"}
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
      (tick_info (unwrap! (map-get? map_stx10_attribute tick) (err ERR_STX10_INVALID_TICK)))
      (caller_balance (default-to u0 (map-get? map_stx10_balance { tick: tick, address: contract-caller })))
      (receiver_balance (default-to u0 (map-get? map_stx10_balance { tick: tick, address: receiver })))
    )
    (asserts! (and (> amt u0) (<= amt caller_balance)) (err ERR_STX10_INVALID_AMT))
    (asserts! (not (is-eq contract-caller receiver)) (err ERR_STX10_INVALID_RECEIVER))
    (asserts! (is-eq payload (concat (concat (concat (concat "{\"p\":\"stx10\",\"op\":\"transfer\",\"tick\":\"" tick) "\",\"amt\":\"") (int-to-ascii amt)) "\"}")) (err ERR_INVALID_PAYLOAD))
    (map-set map_stx10_balance { tick: tick, address: contract-caller } (- caller_balance amt))
    (map-set map_stx10_balance { tick: tick, address: receiver } (+ receiver_balance amt))
    (print {
      type: "transfer-stx10",
      caller: contract-caller,
      payload: payload,
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
    (try! (nft-mint? StacksInscription token_id contract-caller))
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

;;; genesis
(try! (inscribe_text 0x5468652054696d65732030332f4a616e2f32303039204368616e63656c6c6f72206f6e206272696e6b206f66207365636f6e64206261696c6f757420666f722062616e6b73))
(try! (inscribe_text 0x60602e2e2e20746f206265206120636f6d706c6574656c79207365706172617465206e6574776f726b20616e6420736570617261746520626c6f636b20636861696e2c207965742073686172652043505520706f776572207769746820426974636f696e6060202d205361746f736869204e616b616d6f746f))
