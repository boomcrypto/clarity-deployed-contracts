;; use the SIP090 interface (testnet)
;;live (impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;test (impl-trait 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.nft-trait.nft-trait)
(impl-trait .nft-trait.nft-trait)
(impl-trait .re-touchable-nft-trait-v1.re-touchable-nft-trait)
(impl-trait .reserve-nft-trait-v1.reserve-nft-trait)

(use-trait commission-trait .commission-trait-v1.commission)

(define-non-fungible-token AI-NFT uint)

;; Storage
(define-map market uint {price: uint, commission: principal})

;; Define Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-SOLD-OUT (err u300))
(define-constant ERR-MINT-START-BLOCK-NOT-MET (err u302))
(define-constant ERR-WRONG-COMMISSION (err u301))   
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-METADATA-FROZEN (err u505))
(define-constant ERR-MINT-ALREADY-SET (err u506))
(define-constant ERR-LISTING (err u507))
(define-constant ERR-CANNOT-RETOUCH-MORE (err u508))
(define-constant ERR-RETOUCH-TIME-NOT_REACHED (err u509))
(define-constant ERR-REGRESS-TIME-NOT_REACHED (err u510))

(define-constant RESERVE-TOKEN .lbtc-token-v1c)

(define-constant WALLET_1 'SP3QSWXQQJ5BKCVZBY1BH3BPGVX4MZPRKKG8CBDGR) ;; Service Fee
(define-constant WALLET_2 'SP3QSWXQQJ5BKCVZBY1BH3BPGVX4MZPRKKG8CBDGR) ;; Creator Fee
(define-constant WALLET_3 (as-contract tx-sender)) ;; TO NFT

(define-constant WALLET_1_FEE u100)
(define-constant WALLET_2_FEE u700)
(define-constant WALLET_3_FEE u200)
(define-constant FEE_BASE u1000)

(define-constant TOTAL_SUPPLY u288)

(define-constant GOLD_PASS_SUPPLY u57)
(define-constant SILVER_PASS_SUPPLY u114)

(define-constant TIER_COUNT u300)

(define-data-var GOLD_PASS_START_BLOCK uint u48516)
(define-data-var SILVER_PASS_START_BLOCK uint u49524)
(define-data-var START_BLOCK uint u50532)

(define-data-var regressed uint u0)

;; Define Variables
(define-data-var metadata-frozen bool false)
(define-data-var base-uri (string-ascii 80) "ipfs://QmQ8LSjmkqkLRyBa922eHSXKuE6XdfN5UsEGVbzikWLe5T/")
(define-constant contract-uri "ipfs://QmQ8LSjmkqkLRyBa922eHSXKuE6XdfN5UsEGVbzikWLe5T/")

(define-map nft-data
  uint ;;id
  {
    lbtc_amount : uint,
    re_touched_block : uint,
  }
)

(define-read-only (get-nft-data (id uint))
  (map-get? nft-data id)
)

(define-private (get-nft-data-or-default (id uint))
  (default-to 
    { 
      lbtc_amount : u0,
      re_touched_block : block-height,
    }
    (map-get? nft-data id))
)


;; SIP009: Transfer token to a specified principal
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? market id)) ERR-LISTING)
    (ok (try! (nft-transfer? AI-NFT id sender recipient)))))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (id uint))
  ;; Make sure to replace AI-NFT
  (ok (nft-get-owner? AI-NFT id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get nft-counter)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (id uint))
  (ok (some (concat (concat (var-get base-uri) (unwrap-panic (contract-call? .lookup-v1a lookup id))) ".json")))
)

(define-read-only (get-total-supply)
  (ok (- (var-get nft-counter) (var-get regressed))))

(define-read-only (get-contract-uri)
  (ok contract-uri))

(define-data-var nft-counter uint u0)
(define-data-var nft-index uint u0)
(define-data-var rotation uint u1)

(define-data-var un_minted_item (list 288 uint) (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40 u41 u42 u43 u44 u45 u46 u47 u48 u49 u50 u51 u52 u53 u54 u55 u56 u57 u58 u59 u60 u61 u62 u63 u64 u65 u66 u67 u68 u69 u70 u71 u72 u73 u74 u75 u76 u77 u78 u79 u80 u81 u82 u83 u84 u85 u86 u87 u88 u89 u90 u91 u92 u93 u94 u95 u96 u97 u98 u99 u100 u101 u102 u103 u104 u105 u106 u107 u108 u109 u110 u111 u112 u113 u114 u115 u116 u117 u118 u119 u120 u121 u122 u123 u124 u125 u126 u127 u128 u129 u130 u131 u132 u133 u134 u135 u136 u137 u138 u139 u140 u141 u142 u143 u144 u145 u146 u147 u148 u149 u150 u151 u152 u153 u154 u155 u156 u157 u158 u159 u160 u161 u162 u163 u164 u165 u166 u167 u168 u169 u170 u171 u172 u173 u174 u175 u176 u177 u178 u179 u180 u181 u182 u183 u184 u185 u186 u187 u188 u189 u190 u191 u192 u193 u194 u195 u196 u197 u198 u199 u200 u201 u202 u203 u204 u205 u206 u207 u208 u209 u210 u211 u212 u213 u214 u215 u216 u217 u218 u219 u220 u221 u222 u223 u224 u225 u226 u227 u228 u229 u230 u231 u232 u233 u234 u235 u236 u237 u238 u239 u240 u241 u242 u243 u244 u245 u246 u247 u248 u249 u250 u251 u252 u253 u254 u255 u256 u257 u258 u259 u260 u261 u262 u263 u264 u265 u266 u267 u268 u269 u270 u271 u272 u273 u274 u275 u276 u277 u278 u279 u280 u281 u282 u283 u284 u285 u286 u287 u288))

(define-constant TIER_1 (list u77))
(define-constant TIER_2 (list u13 u231))
(define-constant TIER_3 (list u163 u52 u123 u281))
(define-constant TIER_4 (list u72 u199 u140 u7 u156 u182 u221 u188))
(define-constant TIER_5 (list u49 u129 u120 u272 u64 u19 u174 u128 u111 u122 u133 u144 u166 u177 u219 u211))
(define-constant MINT_FEE u100000000)
(define-constant RE_TOUCH_FEE (list u0 u1440000000 u720000000 u360000000 u180000000 u90000000))


(define-private (mint-next-id)
  (let (
      (count (var-get nft-counter))
      (idx (var-get nft-index))
      (random-sample (unwrap! (get-random-uint-at-block (- block-height u1)) u0))
      (random-number (mod random-sample (len (var-get un_minted_item))))
      (random-nft-id
        (unwrap-panic (element-at (var-get un_minted_item) random-number))
      )
    )
    ;; (print {random-sample : random-sample, random-number : random-number})
    (var-set nft-counter (+ count u1))
    (var-set rem_item random-nft-id)
    (var-set un_minted_item (unwrap-panic (as-max-len? (filter removeFilter (var-get un_minted_item)) u288)))
    (if (is-some (index-of TIER_1 random-nft-id))
      random-nft-id
      (if (is-some (index-of TIER_2 random-nft-id))
        (+ random-nft-id TIER_COUNT)
        (if (is-some (index-of TIER_3 random-nft-id))
          (+ random-nft-id u600)
          (if (is-some (index-of TIER_4 random-nft-id))
            (+ random-nft-id u900)
            (if (is-some (index-of TIER_5 random-nft-id))
              (+ random-nft-id u1200)
              (+ random-nft-id u1500)
            )
          )
        )
      )
    )
  )
)


;; Mint new NFT
(define-public (mint (new-owner principal))
  (begin
    (asserts! (< (var-get nft-counter) TOTAL_SUPPLY) ERR-SOLD-OUT)
    (asserts! (can-mint) ERR-MINT-START-BLOCK-NOT-MET)
    (let ((next-id (mint-next-id)))
      (try! (nft-mint? AI-NFT next-id new-owner))
      (let (
          (before-stx (stx-get-balance (as-contract tx-sender)))
          (before-lbtc (unwrap-panic (contract-call? .lbtc-token-v1c get-balance (as-contract tx-sender))))
        )
        (try! (stx-transfer? (/ (* MINT_FEE WALLET_1_FEE) FEE_BASE) tx-sender WALLET_1))
        (try! (stx-transfer? (/ (* MINT_FEE WALLET_2_FEE) FEE_BASE) tx-sender WALLET_2))
        (try! (stx-transfer? (/ (* MINT_FEE WALLET_3_FEE) FEE_BASE) tx-sender WALLET_3))
        (try! (as-contract (contract-call? .stackswap-swap-router-v1b router-swap .wstx-token-v4a .stsw-token-v4a .lbtc-token-v1c 
              .liquidity-token-stx-stsw .liquidity-token-v5krqbd8nh6 true true 
              (- (stx-get-balance (as-contract tx-sender)) before-stx) u0 u0)))
        (map-set nft-data
          next-id
          {
            lbtc_amount : (- (unwrap-panic (contract-call? .lbtc-token-v1c get-balance (as-contract tx-sender))) before-lbtc),
            re_touched_block : block-height
          }
        )
        (addItemToTotalList next-id)
        (ok next-id)
      )
    )
  )
)

(define-private (is-sender-owner (id uint))
  (let ((owner (unwrap! (nft-get-owner? AI-NFT id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

;; Set base uri
(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (is-eq contract-caller CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (not (var-get metadata-frozen)) ERR-METADATA-FROZEN)
    (var-set base-uri new-base-uri)
    (ok true)))

;; Freeze metadata
(define-public (freeze-metadata)
  (begin
    (asserts! (is-eq contract-caller CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set metadata-frozen true)
    (ok true)))

(define-public (set-mint-start-block (gold uint) (silver uint) (normal uint))
  (begin
    (asserts! (is-eq contract-caller CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set GOLD_PASS_START_BLOCK gold)
    (var-set SILVER_PASS_START_BLOCK silver)
    (var-set START_BLOCK normal)
    (ok true)))

(define-read-only (get-mint-start-block)
  (ok 
    { 
      GOLD_PASS_START_BLOCK : (var-get GOLD_PASS_START_BLOCK),
      SILVER_PASS_START_BLOCK : (var-get SILVER_PASS_START_BLOCK),
      START_BLOCK : (var-get START_BLOCK)
    }
  ))

(define-private (can-mint)
  (or
    (and (> (contract-call? .stackswap-gold-pass-v1b get-balance tx-sender) u0) (>= block-height  (var-get GOLD_PASS_START_BLOCK)) (<= (var-get nft-counter) GOLD_PASS_SUPPLY))
    (and (or (> (contract-call? .stackswap-gold-pass-v1b get-balance tx-sender) u0) (> (contract-call? .stackswap-silver-pass-v1b get-balance tx-sender) u0)) (>= block-height (var-get SILVER_PASS_START_BLOCK)) (<= (var-get nft-counter) SILVER_PASS_SUPPLY))
    (>= block-height  (var-get START_BLOCK))
  )
)

(define-public (re-touch (id uint))
  (let (
      (tier (/ id TIER_COUNT))
      (price (unwrap-panic (element-at RE_TOUCH_FEE tier)))
      (temp_nft_data (get-nft-data-or-default id))
      (before-stx (stx-get-balance (as-contract tx-sender)))
      (before-lbtc (unwrap-panic (contract-call? .lbtc-token-v1c get-balance (as-contract tx-sender))))
    )
    ;; (print {tier: tier, price: price, temp_nft_data: temp_nft_data, block-height: block-height})
    (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
    (asserts! (> tier u0) ERR-CANNOT-RETOUCH-MORE)
    (asserts! (< (+ (get re_touched_block temp_nft_data) u287) block-height) ERR-RETOUCH-TIME-NOT_REACHED)
    (asserts! (is-none (map-get? market id)) ERR-LISTING)
    (try! (nft-burn? AI-NFT id tx-sender))
    (try! (nft-mint? AI-NFT (- id TIER_COUNT) tx-sender))
    (try! (stx-transfer? (/ (* price WALLET_1_FEE) FEE_BASE) tx-sender WALLET_1))
    (try! (stx-transfer? (/ (* price WALLET_2_FEE) FEE_BASE) tx-sender WALLET_2))
    (try! (stx-transfer? (/ (* price WALLET_3_FEE) FEE_BASE) tx-sender WALLET_3))
    (try! (as-contract (contract-call? .stackswap-swap-router-v1b router-swap .wstx-token-v4a .stsw-token-v4a .lbtc-token-v1c 
          .liquidity-token-stx-stsw .liquidity-token-v5krqbd8nh6 true true 
          (- (stx-get-balance (as-contract tx-sender)) before-stx) u0 u0)))
    (map-delete nft-data id)
    (deleteItemFromTotalList id)
    (map-set nft-data
      (- id TIER_COUNT)
      {
        lbtc_amount : (+ (get lbtc_amount temp_nft_data) (- (unwrap-panic (contract-call? .lbtc-token-v1c get-balance (as-contract tx-sender))) before-lbtc)),
        re_touched_block : block-height
      }
    )
    (addItemToTotalList (- id TIER_COUNT))
    (ok (- id TIER_COUNT))
  )
)

(define-read-only (get-reserve-token)
  (ok RESERVE-TOKEN)
)

(define-read-only (get-reserve-amount-total)
  (ok (unwrap-panic (contract-call? .lbtc-token-v1c get-balance (as-contract tx-sender))))
)

(define-read-only (get-reserve-amount (id uint))
  (ok (get lbtc_amount (get-nft-data-or-default id)))
)

(define-public (regress-token (id uint))
  (let (
      (tier (/ id TIER_COUNT))
      (price (element-at RE_TOUCH_FEE tier))
      (temp_nft_data (get-nft-data-or-default id))
      (user tx-sender)
    )
    (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
    (asserts! (< (+ (get re_touched_block temp_nft_data) u4320) block-height) ERR-REGRESS-TIME-NOT_REACHED)
    (asserts! (is-none (map-get? market id)) ERR-LISTING)
    (var-set regressed (+ (var-get regressed) u1))
    (try! (as-contract (contract-call? .lbtc-token-v1c transfer (get lbtc_amount temp_nft_data) tx-sender user none)))
    (try! (nft-burn? AI-NFT id tx-sender))
    (map-delete nft-data id)
    (deleteItemFromTotalList id)
    (ok (get lbtc_amount temp_nft_data))
  )
)

;; market

(define-data-var total_list (list 300 uint) (list ))
(define-data-var market_list (list 300 uint) (list ))

(define-data-var rem_item uint u0)
(define-private (removeFilter (a uint)) (not (is-eq a (var-get rem_item))))

(define-private (addItemToTotalList (id uint))
  (let (
      (m_total_list (var-get total_list))
    ) 
    (if (is-some (index-of m_total_list id))
      true
      (var-set total_list (unwrap-panic (as-max-len? (append m_total_list id) u300)))
    )
  )
)

(define-private (deleteItemFromTotalList (id uint))
  (begin 
    (var-set rem_item id)
    (var-set total_list (unwrap-panic (as-max-len? (filter removeFilter (var-get total_list)) u300)))
  )
)

(define-private (addItemToMarketList (id uint))
  (let (
      (m_market_list (var-get market_list))
    ) 
    (if (is-some (index-of m_market_list id))
      true
      (var-set market_list (unwrap-panic (as-max-len? (append m_market_list id) u300)))
    )
  )
)

(define-private (deleteItemFromMarketList (id uint))
  (begin 
    (var-set rem_item id)
    (var-set market_list (unwrap-panic (as-max-len? (filter removeFilter (var-get market_list)) u300)))
  )
)

(define-read-only (get-total-list)
  (var-get total_list)
)

(define-read-only (get-market-list)
  (var-get market_list)
)

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm)}))
    (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
    (map-set market id listing)
    (addItemToMarketList id)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)))

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
    (map-delete market id)
    (deleteItemFromMarketList id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-ustx (id uint) (comm <commission-trait>))
  (let (
      (owner (unwrap! (nft-get-owner? AI-NFT id) ERR-NOT-FOUND))
      (listing (unwrap! (map-get? market id) ERR-LISTING))
      (price (get price listing))
      (before-stx (stx-get-balance (as-contract tx-sender)))
      (before-lbtc (unwrap-panic (contract-call? .lbtc-token-v1c get-balance (as-contract tx-sender))))
      (temp_nft_data (get-nft-data-or-default id))
    )
    (asserts! (is-eq (contract-of comm) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm pay id price))
    (try! (nft-transfer? AI-NFT id owner tx-sender))
    (if (> (- (stx-get-balance (as-contract tx-sender)) before-stx) u0)
      (begin
          (try! (as-contract (contract-call? .stackswap-swap-router-v1b router-swap .wstx-token-v4a .stsw-token-v4a .lbtc-token-v1c 
          .liquidity-token-stx-stsw .liquidity-token-v5krqbd8nh6 true true 
          (- (stx-get-balance (as-contract tx-sender)) before-stx) u0 u0)))
        (map-set nft-data
          id
          {
            lbtc_amount : (+ (get lbtc_amount temp_nft_data) (- (unwrap-panic (contract-call? .lbtc-token-v1c get-balance (as-contract tx-sender))) before-lbtc)),
            re_touched_block : (get re_touched_block temp_nft_data)
          }
        )
      )
      true
    )
    (map-delete market id)
    (deleteItemFromMarketList id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)
  )
)


(define-constant BUFF-TO-BYTE (list 
    0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x0a 0x0b 0x0c 0x0d 0x0e 0x0f
    0x10 0x11 0x12 0x13 0x14 0x15 0x16 0x17 0x18 0x19 0x1a 0x1b 0x1c 0x1d 0x1e 0x1f
    0x20 0x21 0x22 0x23 0x24 0x25 0x26 0x27 0x28 0x29 0x2a 0x2b 0x2c 0x2d 0x2e 0x2f
    0x30 0x31 0x32 0x33 0x34 0x35 0x36 0x37 0x38 0x39 0x3a 0x3b 0x3c 0x3d 0x3e 0x3f
    0x40 0x41 0x42 0x43 0x44 0x45 0x46 0x47 0x48 0x49 0x4a 0x4b 0x4c 0x4d 0x4e 0x4f
    0x50 0x51 0x52 0x53 0x54 0x55 0x56 0x57 0x58 0x59 0x5a 0x5b 0x5c 0x5d 0x5e 0x5f
    0x60 0x61 0x62 0x63 0x64 0x65 0x66 0x67 0x68 0x69 0x6a 0x6b 0x6c 0x6d 0x6e 0x6f
    0x70 0x71 0x72 0x73 0x74 0x75 0x76 0x77 0x78 0x79 0x7a 0x7b 0x7c 0x7d 0x7e 0x7f
    0x80 0x81 0x82 0x83 0x84 0x85 0x86 0x87 0x88 0x89 0x8a 0x8b 0x8c 0x8d 0x8e 0x8f
    0x90 0x91 0x92 0x93 0x94 0x95 0x96 0x97 0x98 0x99 0x9a 0x9b 0x9c 0x9d 0x9e 0x9f
    0xa0 0xa1 0xa2 0xa3 0xa4 0xa5 0xa6 0xa7 0xa8 0xa9 0xaa 0xab 0xac 0xad 0xae 0xaf
    0xb0 0xb1 0xb2 0xb3 0xb4 0xb5 0xb6 0xb7 0xb8 0xb9 0xba 0xbb 0xbc 0xbd 0xbe 0xbf
    0xc0 0xc1 0xc2 0xc3 0xc4 0xc5 0xc6 0xc7 0xc8 0xc9 0xca 0xcb 0xcc 0xcd 0xce 0xcf
    0xd0 0xd1 0xd2 0xd3 0xd4 0xd5 0xd6 0xd7 0xd8 0xd9 0xda 0xdb 0xdc 0xdd 0xde 0xdf
    0xe0 0xe1 0xe2 0xe3 0xe4 0xe5 0xe6 0xe7 0xe8 0xe9 0xea 0xeb 0xec 0xed 0xee 0xef
    0xf0 0xf1 0xf2 0xf3 0xf4 0xf5 0xf6 0xf7 0xf8 0xf9 0xfa 0xfb 0xfc 0xfd 0xfe 0xff
))

(define-private (buff-to-u8 (byte (buff 1)))
    (unwrap-panic (index-of BUFF-TO-BYTE byte)))

(define-private (add-and-shift-uint-le (idx uint) (input { acc: uint, data: (buff 16) }))
    (let (
        (acc (get acc input))
        (data (get data input))
        (byte (buff-to-u8 (unwrap-panic (element-at data idx))))
    )
    {
        acc: (+ (* byte (pow u2 (* u8 (- u15 idx)))) acc),
        data: data
    })
)

(define-private (buff-to-uint-le (word (buff 16)))
    (get acc
        (fold add-and-shift-uint-le (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15) { acc: u0, data: word })
    )
)

(define-private (lower-16-le-closure (idx uint) (input { acc: (buff 16), data: (buff 32) }))
    (let (
        (acc (get acc input))
        (data (get data input))
        (byte (unwrap-panic (element-at data idx)))
    )
    {
        acc: (unwrap-panic (as-max-len? (concat acc byte) u16)),
        data: data
    })
)

(define-private (lower-16-le (input (buff 32)))
    (get acc
        (fold lower-16-le-closure (list u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31) { acc: 0x, data: input })
    )
)

(define-read-only (get-random-uint-at-block (stacks-block uint))
    (let (
        (vrf-lower-uint-opt
            (match (get-block-info? vrf-seed stacks-block)
                vrf-seed (some (buff-to-uint-le (lower-16-le vrf-seed)))
                none))
    )
    vrf-lower-uint-opt)
)