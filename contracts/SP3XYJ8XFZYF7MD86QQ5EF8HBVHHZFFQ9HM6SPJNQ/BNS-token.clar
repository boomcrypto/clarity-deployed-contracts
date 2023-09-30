;; $BNS (https://xnft.fan/#/x/tokens)
;; Total: 20,917,968.75
;; Only .btc users can claim
;; First 21000 holders, each claim 500 $BNS
;; Next 21000 holders, each claim 250 $BNS
;; Next 21000 holders, each claim 125 $BNS
;; Next 21000 holders, each claim 62.5 $BNS
;; Next 21000 holders, each claim 31.25 $BNS
;; Next 21000 holders, each claim 15.625 $BNS
;; Next 21000 holders, each claim 7.8125 $BNS
;; Next 21000 holders, each claim 3.90625 $BNS

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant ERR_NOT_MEMBER u10001)
(define-constant ERR_CLAIM_HAD_CLAIMED u10002)
(define-constant ERR_CLAIM_NO_REMAIN u10003)
(define-constant ERR_BNS_RESOLVE_FAIL u10004)
(define-constant ERR_BNS_NAME_NOT_SATISFY u10005)

(define-fungible-token BNS)

(define-constant DECIMAL u8)
(define-constant ONE_COIN (pow u10 DECIMAL))
(define-constant MAX_CLAIM_HOLDER_COUNT u168000)

(define-data-var m_claim_count_per_holder uint (* u500 ONE_COIN))

(define-data-var m_claimed_bns_count uint u0)
(define-map map_claimed_bns_note
  { name: (buff 48), namespace: (buff 20) }
  bool ;; whether has claimed
)

(define-read-only (get-balance (user principal))
  (ok (ft-get-balance BNS user))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply BNS))
)

(define-read-only (get-name)
  (ok "BNS")
)

(define-read-only (get-symbol)
  (ok "BNS")
)

(define-read-only (get-decimals)
  (ok DECIMAL)
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (is-eq tx-sender sender)
    (begin
      (try! (ft-transfer? BNS amount sender recipient))
      (print memo)
      (ok true)
    )
    (err u4)
  )
)

(define-public (burn (count uint))
  (ft-burn? BNS count tx-sender)
)

(define-public (get-token-uri)
  (ok (some u"https://ipfs.io/ipfs/QmaEHXtKSdsSQKgxtTr15bh5fJHQy6Pj1Szgjfsibgzhgo"))
)

(define-public (bns_claim)
  (let
    (
      (resolve_info (unwrap! (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal tx-sender) (err ERR_BNS_RESOLVE_FAIL)))
      (namespace (get namespace resolve_info))
      (name (get name resolve_info))     
      (new_claimed_holder_count (+ (var-get m_claimed_bns_count) u1))
      (claim_count (var-get m_claim_count_per_holder))
    )
    (asserts! (is-none (map-get? map_claimed_bns_note { name: name, namespace: namespace })) (err ERR_CLAIM_HAD_CLAIMED))
    (asserts! (<= new_claimed_holder_count MAX_CLAIM_HOLDER_COUNT) (err ERR_CLAIM_NO_REMAIN))
    (asserts! (is-eq namespace 0x627463) (err ERR_BNS_NAME_NOT_SATISFY))
    (var-set m_claimed_bns_count new_claimed_holder_count)
    (map-set map_claimed_bns_note { name: name, namespace: namespace } true)
    (and
      (is-eq (mod new_claimed_holder_count u21000) u0)
      (var-set m_claim_count_per_holder (/ claim_count u2))
    )
    (ft-mint? BNS claim_count tx-sender)
  )
)

(define-read-only (get_base_summary)
    {
      claimed_bns_count: (var-get m_claimed_bns_count),
      claim_count_per_holder: (var-get m_claim_count_per_holder),
    }
)

(define-read-only (get_player_summary (player principal))
  (merge
    {
      b: (var-get m_claimed_bns_count),
      c: (var-get m_claim_count_per_holder)
    }
    (match (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal player)
      ri { n: (is-none (map-get? map_claimed_bns_note { name: (get name ri), namespace: (get namespace ri) })) }
      e { n: false })
  )
)
