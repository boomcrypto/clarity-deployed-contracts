;; https://explorer.stacks.co/txid/0x80eb693e5e2a9928094792080b7f6d69d66ea9cc881bc465e8d9c5c621bd4d07?chain=mainnet
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(define-non-fungible-token phases-of-satoshi uint)

;; constants
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALL-MINTED u101)
(define-constant CONTRACT-OWNER tx-sender)

;; variables
(define-data-var phases-index uint u0)
(define-data-var phases-counter uint u6)
(define-data-var token-uri (string-ascii 256) "")
(define-data-var token-phases-uri (string-ascii 256) "")
(define-map phases { id: uint } { minted: bool })
(define-map phases-by-owner { owner: principal } { ids: (list 210 uint) })
(define-data-var removing-phase-id uint u0)
(define-data-var cost-per-mint uint u24000000)
(define-data-var creator-address principal 'SPBFZ5MRGDMEKWNQTJ57W2PA2GC0765ZFC5BY0KP) ;; STBFZ5MRGDMEKWNQTJ57W2PA2GC0765ZFC33E2WE TESTNET
(define-data-var nft-ids (list 210 uint) (list u122 u142 u15 u104 u118 u117 u145 u37 u77 u210 u17 u89 u60 u68 u163 u53 u28 u100 u182 u198 u160 u78 u196 u149 u157 u137 u135 u83 u121 u141 u64 u85 u16 u40 u55 u204 u197 u33 u67 u65 u8 u183 u123 u148 u70 u175 u136 u105 u49 u131 u159 u10 u75 u91 u127 u12 u147 u20 u178 u209 u162 u180 u52 u23 u61 u171 u176 u203 u99 u139 u188 u134 u35 u79 u95 u50 u36 u140 u93 u152 u166 u71 u143 u82 u73 u144 u114 u200 u18 u48 u54 u189 u30 u164 u88 u113 u26 u184 u132 u63 u41 u38 u177 u81 u46 u186 u9 u133 u191 u84 u101 u92 u201 u47 u96 u107 u185 u154 u74 u72 u169 u90 u94 u58 u42 u206 u174 u146 u103 u106 u11 u167 u165 u31 u151 u155 u109 u80 u32 u170 u44 u205 u138 u194 u179 u172 u168 u51 u195 u187 u119 u156 u86 u126 u14 u111 u153 u39 u56 u69 u22 u19 u62 u192 u120 u116 u21 u202 u13 u108 u102 u98 u57 u207 u150 u34 u161 u124 u181 u43 u130 u158 u87 u7 u199 u125 u208 u128 u45 u66 u190 u129 u25 u115 u193 u173 u27 u59 u29 u24 u110 u97 u76 u112))

;; public functions
(define-public (mint)
  (begin
    (asserts! (<= (var-get phases-counter) u210) (err ERR-ALL-MINTED))

    (try! (mint-next))
    (ok true)
  )
)

(define-private (mint-next)
  (let (
    (count (var-get phases-counter))
    (phases-ids (unwrap-panic (get-phases-by-owner tx-sender)))
    (random-phases-id (unwrap-panic (element-at (var-get nft-ids) (var-get phases-index))))
  )
    (match (stx-transfer? (var-get cost-per-mint) tx-sender (as-contract tx-sender))
      success (begin
        (try! (nft-mint? phases-of-satoshi random-phases-id tx-sender))
        (var-set phases-counter (+ u1 count))
        (var-set phases-index (+ u1 (var-get phases-index)))
        (map-set phases { id: random-phases-id } { minted: true })
        (map-set phases-by-owner { owner: tx-sender }
          { ids: (unwrap-panic (as-max-len? (append phases-ids random-phases-id) u210)) }
        )
        (try! (as-contract (stx-transfer? (/ (* u8000 (var-get cost-per-mint)) u10000) (as-contract tx-sender) (var-get creator-address))))
        (ok random-phases-id)
      )
      error (err error)
    )
  )
)

(define-read-only (get-phases-entry-by-owner (owner principal))
  (default-to
    { ids: (list ) }
    (map-get? phases-by-owner { owner: owner })
  )
)

(define-public (get-phases-by-owner (owner principal))
  (ok (get ids (get-phases-entry-by-owner owner)))
)

(define-public (burn (index uint))
  (if (is-owner index tx-sender)
    (match (nft-burn? phases-of-satoshi index tx-sender)
      success (ok true)
      error (err error)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (transfer (index uint) (owner principal) (recipient principal))
  (if (and (is-owner index owner) (is-owner index tx-sender))
    (match (nft-transfer? phases-of-satoshi index owner recipient)
      success (let ((phases-ids (unwrap-panic (get-phases-by-owner recipient))))
        (map-set phases-by-owner { owner: recipient }
          { ids: (unwrap-panic (as-max-len? (append phases-ids index) u210)) }
        )
        (try! (remove-phase owner index))
        (ok true)
      )
      error (err error)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-private (remove-phase (owner principal) (phases-id uint))
  (if true
    (let ((phases-ids (unwrap-panic (get-phases-by-owner owner))))
      (var-set removing-phase-id phases-id)
      (map-set phases-by-owner { owner: owner }
        { ids: (unwrap-panic (as-max-len? (filter remove-transferred-phases phases-ids) u210)) }
      )
      (ok true)
    )
    (err u0)
  )
)

(define-private (remove-transferred-phases (phases-id uint))
  (if (is-eq phases-id (var-get removing-phase-id))
    false
    true
  )
)

(define-read-only (get-last-token-id)
  (ok (var-get phases-counter))
)

(define-public (set-cost-per-mint (value uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set cost-per-mint value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-token-uri (value (string-ascii 256)))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set token-uri value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-token-phases-uri (value (string-ascii 256)))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set token-phases-uri value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-creator-address (address principal))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set creator-address address))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-read-only (get-token-uri (id uint))
  (if (not (is-eq id u0))
    (ok (some (var-get token-phases-uri)))
    (ok (some (var-get token-uri)))
  )
)

(define-public (get-owner (index uint))
  (ok (nft-get-owner? phases-of-satoshi index))
)

(define-read-only (stx-balance)
  (stx-get-balance (as-contract tx-sender))
)

(define-read-only (stx-balance-of (address principal))
  (stx-get-balance address)
)

(define-public (transfer-stx (address principal) (amount uint))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (as-contract (stx-transfer? amount (as-contract tx-sender) address))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; private functions

(define-private (is-owner (index uint) (user principal))
  (is-eq user (unwrap! (nft-get-owner? phases-of-satoshi index) false))
)

;; initialize
(var-set token-phases-uri "https://www.stacksart.com/assets/phases_of_satoshi.json")
(var-set token-uri "https://www.stacksart.com/assets/phases_of_satoshi.json")

(let (
  (phases-ids (unwrap-panic (get-phases-by-owner 'SP3N6EZPTSX8ZV2RGPY9NR9A8CA0QET39CY978H5E)))
)
  (try! (nft-mint? phases-of-satoshi u1 'SP3N6EZPTSX8ZV2RGPY9NR9A8CA0QET39CY978H5E))
  (map-set phases { id: u1 } { minted: true })
  (map-set phases-by-owner { owner: 'SP3N6EZPTSX8ZV2RGPY9NR9A8CA0QET39CY978H5E } { ids: (unwrap-panic (as-max-len? (append phases-ids u1) u210)) })
)

(let (
  (phases-ids (unwrap-panic (get-phases-by-owner 'SP3N6EZPTSX8ZV2RGPY9NR9A8CA0QET39CY978H5E)))
)
  (try! (nft-mint? phases-of-satoshi u2 'SP3N6EZPTSX8ZV2RGPY9NR9A8CA0QET39CY978H5E))
  (map-set phases { id: u2 } { minted: true })
  (map-set phases-by-owner { owner: 'SP3N6EZPTSX8ZV2RGPY9NR9A8CA0QET39CY978H5E } { ids: (unwrap-panic (as-max-len? (append phases-ids u2) u210)) })
)

(let (
  (phases-ids (unwrap-panic (get-phases-by-owner 'SP14R7S7497PS3VMH3WQ1S6NPNXR47G3RRC1G2K0G)))
)
  (try! (nft-mint? phases-of-satoshi u3 'SP14R7S7497PS3VMH3WQ1S6NPNXR47G3RRC1G2K0G))
  (map-set phases { id: u3 } { minted: true })
  (map-set phases-by-owner { owner: 'SP14R7S7497PS3VMH3WQ1S6NPNXR47G3RRC1G2K0G } { ids: (unwrap-panic (as-max-len? (append phases-ids u3) u210)) })
)

(let (
  (phases-ids (unwrap-panic (get-phases-by-owner 'SP3N66VSF1HAH9BP36XEAT2JZWZ45TDJXWENGS7Y5)))
)
  (try! (nft-mint? phases-of-satoshi u4 'SP3N66VSF1HAH9BP36XEAT2JZWZ45TDJXWENGS7Y5))
  (map-set phases { id: u4 } { minted: true })
  (map-set phases-by-owner { owner: 'SP3N66VSF1HAH9BP36XEAT2JZWZ45TDJXWENGS7Y5 } { ids: (unwrap-panic (as-max-len? (append phases-ids u4) u210)) })
)

(let (
  (phases-ids (unwrap-panic (get-phases-by-owner 'SP4P7ZGMPH4MGF8ZD0TFG035DNFZP4X3RMBPFKT3)))
)
  (try! (nft-mint? phases-of-satoshi u5 'SP4P7ZGMPH4MGF8ZD0TFG035DNFZP4X3RMBPFKT3))
  (map-set phases { id: u5 } { minted: true })
  (map-set phases-by-owner { owner: 'SP4P7ZGMPH4MGF8ZD0TFG035DNFZP4X3RMBPFKT3 } { ids: (unwrap-panic (as-max-len? (append phases-ids u5) u210)) })
)

(let (
  (phases-ids (unwrap-panic (get-phases-by-owner 'SP3X9696B2ZKFMBHEJF1RBWMYDQ2YGXDA11GFYTE5)))
)
  (try! (nft-mint? phases-of-satoshi u6 'SP3X9696B2ZKFMBHEJF1RBWMYDQ2YGXDA11GFYTE5))
  (map-set phases { id: u6 } { minted: true })
  (map-set phases-by-owner { owner: 'SP3X9696B2ZKFMBHEJF1RBWMYDQ2YGXDA11GFYTE5 } { ids: (unwrap-panic (as-max-len? (append phases-ids u6) u210)) })
)
