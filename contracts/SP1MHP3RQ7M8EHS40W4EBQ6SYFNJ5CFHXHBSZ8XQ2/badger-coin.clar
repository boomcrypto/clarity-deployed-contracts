;; Honey badger token, totally and permanently free. visit a.btc.us for more info

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant ERR_NO_AUTHORITY u1001)
(define-constant ERR_NO_REMAIN u1002)
(define-constant ERR_IN_CD u1003)
(define-constant ERR_BALANCE_NOT_ENOUGH u1004)
;;
(define-constant OWNER tx-sender)
(define-constant MAX_SUPPLY u1000000000000000)
(define-constant OWNER_SUPPLY (/ (* MAX_SUPPLY u1) u100))
;;
(define-constant MIN_HOLD_STX u10000000)
(define-constant CD_BLOCKS u200)
(define-constant CLAIM_REWARD u1000000000)

(define-fungible-token BADGER)

(define-data-var m_total_mint_count uint OWNER_SUPPLY)
(define-data-var m_rand uint u1)

(define-map map_note
  principal
  uint
)

(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance BADGER owner))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply BADGER))
)

(define-read-only (get-name)
  (ok "Honey badger")
)

(define-read-only (get-symbol)
  (ok "BADGER")
)

(define-read-only (get-decimals)
  (ok u0)
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR_NO_AUTHORITY))
    (try! (ft-transfer? BADGER amount sender recipient))
    (print memo)
    (ok true)
  )
)

(define-public (burn (count uint))
  (ft-burn? BADGER count tx-sender)
)

(define-public (get-token-uri)
  (ok (some u"https://gateway.pinata.cloud/ipfs/QmXNJZL7Yvoa59fvvW7JqanEMzAyFAHkvBkGCbdXNB3d9T"))
)

(define-public (claim)
  (let
    (
      (rand (var-get m_rand))
      (caller tx-sender)
      (last_claim_bh (default-to u0 (map-get? map_note caller)))
      (last_stamp (unwrap-panic (get-block-info? time (- block-height u1))))
      (cur_mint_count (var-get m_total_mint_count))
      (stamp1 (unwrap-panic (get-block-info? time (- block-height u157))))
      (stamp2 (unwrap-panic (get-block-info? time (- block-height u1043))))
      (stamp3 (unwrap-panic (get-block-info? time (- block-height u2009))))
      (bh block-height)
      (bh1 (- bh u1))
      (bh2 (- bh1 u503))
      (bh3 (- bh1 u1440))
      (bh4 (- bh1 (mod stamp1 u1440)))
      (bh5 (- bh1 (mod (+ stamp2 rand) u1440)))
      (bh6 (- bh1 (mod (+ stamp3 rand) u1440)))
    )
    (asserts! (<= (+ cur_mint_count CLAIM_REWARD) MAX_SUPPLY) (err ERR_NO_REMAIN))
    (asserts! (or (is-eq last_claim_bh u0) (< (+ CD_BLOCKS last_claim_bh) bh1)) (err ERR_IN_CD))
    (asserts! (>= (stx-get-balance tx-sender) MIN_HOLD_STX) (err ERR_BALANCE_NOT_ENOUGH))
    (asserts! (>= (at-block (unwrap-panic (get-block-info? id-header-hash bh2)) (stx-get-balance caller)) MIN_HOLD_STX) (err ERR_BALANCE_NOT_ENOUGH))
    (asserts! (>= (at-block (unwrap-panic (get-block-info? id-header-hash bh3)) (stx-get-balance caller)) MIN_HOLD_STX) (err ERR_BALANCE_NOT_ENOUGH))
    (asserts! (>= (at-block (unwrap-panic (get-block-info? id-header-hash bh4)) (stx-get-balance caller)) MIN_HOLD_STX) (err ERR_BALANCE_NOT_ENOUGH))
    (asserts! (>= (at-block (unwrap-panic (get-block-info? id-header-hash bh5)) (stx-get-balance caller)) MIN_HOLD_STX) (err ERR_BALANCE_NOT_ENOUGH))
    (asserts! (>= (at-block (unwrap-panic (get-block-info? id-header-hash bh6)) (stx-get-balance caller)) MIN_HOLD_STX) (err ERR_BALANCE_NOT_ENOUGH))
    ;;
    (var-set m_rand (+ (mod (* last_stamp (/ (stx-get-balance caller) u10000) rand) u256) u2021))
    (map-set map_note caller bh1)
    (var-set m_total_mint_count (+ cur_mint_count CLAIM_REWARD))
    (try! (ft-mint? BADGER CLAIM_REWARD caller))
    (ok CLAIM_REWARD)
  )
)

(define-read-only (get_summary (player (optional principal)))
  {
    bh: block-height,
    supply: (ft-get-supply BADGER),
    tmc: (var-get m_total_mint_count),
    stx: (if (is-some player) (stx-get-balance (unwrap-panic player)) u0),
    ft: (if (is-none player) u0 (ft-get-balance BADGER (unwrap-panic player))),
    last_get_bh: (if (is-some player) (default-to u0 (map-get? map_note (unwrap-panic player))) u0),
  }
)

(ft-mint? BADGER OWNER_SUPPLY OWNER)
