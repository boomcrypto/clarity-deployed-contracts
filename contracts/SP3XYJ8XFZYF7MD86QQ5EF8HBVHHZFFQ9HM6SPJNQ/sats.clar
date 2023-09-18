;; $SATS (https://xnft.fan/#/)
;; Total: 21,000,000, Distribution as below:
;; Airdrop: 900,000 (for current 18 members, each get 50,000)
;; Members: 10,000,000 (first 200 members can claim, each get 50,000)
;; BNS: 10,100,000 (first 50,500 names, each get 200. Only available for .btc, .id(length<=2), .stx(length<=2), .app(length<=2), .stacks(length<=2))

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant ERR_NOT_MEMBER u10001)
(define-constant ERR_CLAIM_HAD_CLAIMED u10002)
(define-constant ERR_CLAIM_NO_REMAIN u10003)
(define-constant ERR_BNS_RESOLVE_FAIL u10004)
(define-constant ERR_BNS_NAME_NOT_SATISFY u10005)

(define-fungible-token SATS)

(define-constant DECIMAL u8)
(define-constant ONE_COIN (pow u10 DECIMAL))
(define-constant MAX_SUPPLY (* u21000000 ONE_COIN))
(define-constant AIRDROP_COUNT_PER_MEMBER (* u50000 ONE_COIN))
(define-constant CLAIM_COUNT_PER_MEMBER (* u50000 ONE_COIN))    
(define-constant MAX_CLAIM_MEMBER_COUNT u200)
(define-constant CLAIM_COUNT_PER_BNS (* u200 ONE_COIN))    
(define-constant MAX_CLAIM_BNS_COUNT u50500)

(define-data-var m_claimed_member_count uint u0)
(define-map map_claimed_member_note
  uint ;; tid
  bool ;; whether has claimed
)

(define-data-var m_claimed_bns_count uint u0)
(define-map map_claimed_bns_note
  { name: (buff 48), namespace: (buff 20) }
  bool ;; whether has claimed
)

(define-read-only (get-balance (user principal))
  (ok (ft-get-balance SATS user))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply SATS))
)

(define-read-only (get-name)
  (ok "Sats")
)

(define-read-only (get-symbol)
  (ok "SATS")
)

(define-read-only (get-decimals)
  (ok DECIMAL)
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (is-eq tx-sender sender)
    (begin
      (try! (ft-transfer? SATS amount sender recipient))
      (print memo)
      (ok true)
    )
    (err u4)
  )
)

(define-public (burn (count uint))
  (ft-burn? SATS count tx-sender)
)

(define-public (get-token-uri)
  (ok (some u"https://ipfs.io/ipfs/QmZnxUsJQe8bNPxqcqHqi4Eniz2r2X4GaUvQRcVbRp4qBC"))
)

(define-public (member_claim)
  (let
    (
      (tid (unwrap! (contract-call? .laser-eyes-v5 get_id_by_player tx-sender) (err ERR_NOT_MEMBER)))
      (new_claimed_count (+ (var-get m_claimed_member_count) u1))
    )
    (asserts! (is-none (map-get? map_claimed_member_note tid)) (err ERR_CLAIM_HAD_CLAIMED))
    (asserts! (<= new_claimed_count MAX_CLAIM_MEMBER_COUNT) (err ERR_CLAIM_NO_REMAIN))
    (var-set m_claimed_member_count new_claimed_count)
    (map-set map_claimed_member_note tid true)
    (ft-mint? SATS CLAIM_COUNT_PER_MEMBER tx-sender)
  )
)

(define-public (bns_claim)
  (let
    (
      (resolve_info (unwrap! (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal tx-sender) (err ERR_BNS_RESOLVE_FAIL)))
      (namespace (get namespace resolve_info))
      (name (get name resolve_info))     
      (new_claimed_count (+ (var-get m_claimed_bns_count) u1))
    )
    (asserts! (is-none (map-get? map_claimed_bns_note { name: name, namespace: namespace })) (err ERR_CLAIM_HAD_CLAIMED))
    (asserts! (<= new_claimed_count MAX_CLAIM_BNS_COUNT) (err ERR_CLAIM_NO_REMAIN))
    (asserts! (name_satisfied name namespace) (err ERR_BNS_NAME_NOT_SATISFY))
    (var-set m_claimed_bns_count new_claimed_count)
    (map-set map_claimed_bns_note { name: name, namespace: namespace } true)
    (ft-mint? SATS CLAIM_COUNT_PER_BNS tx-sender)
  )
)

(define-read-only (get_base_summary)
    {
      claimed_member_count: (var-get m_claimed_member_count),
      claimed_bns_count: (var-get m_claimed_bns_count),
    }
)

(define-read-only (get_player_summary (player principal))
  (let ((tid (default-to u0 (contract-call? .laser-eyes-v5 get_id_by_player player))))
    (merge
      { tid: tid, t: (is-none (map-get? map_claimed_member_note tid)), m: (var-get m_claimed_member_count), b: (var-get m_claimed_bns_count) }
      (match (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal player)
        ri { n: (is-none (map-get? map_claimed_bns_note { name: (get name ri), namespace: (get namespace ri) })) }
        e { n: false }))))

;; In case the upper function reaches read-only limitation
(define-read-only (get_player_summary_safe (player principal) (name (buff 48)) (namespace (buff 20)))
  (let ((tid (default-to u0 (contract-call? .laser-eyes-v5 get_id_by_player player))))
    {
      tid: tid,
      m: (is-none (map-get? map_claimed_member_note tid)), 
      m_count: (var-get m_claimed_member_count), 
      b: (is-none (map-get? map_claimed_bns_note { name: name, namespace: namespace })),
      b_count: (var-get m_claimed_bns_count)
    }
  )
)

(define-private (name_satisfied (name (buff 48)) (namespace (buff 20)))
  (if (is-eq namespace 0x627463)
    true
    (if (or (is-eq namespace 0x6964) (is-eq namespace 0x737478) (is-eq namespace 0x617070) (is-eq namespace 0x737461636b73))
      (<= (len name) u2)
      false
    )
  )
)

(define-private (airdrop (tid uint))
  (match (contract-call? .laser-eyes-v5 get_player_by_id tid) user
    (is-ok (ft-mint? SATS AIRDROP_COUNT_PER_MEMBER user))
    false
  )
)

;; Airdrop to early users
(map airdrop (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18))