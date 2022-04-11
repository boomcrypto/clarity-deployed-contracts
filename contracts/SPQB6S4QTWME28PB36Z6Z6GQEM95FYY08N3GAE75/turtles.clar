;; Turtles NFT by Bitcoin Birds

(impl-trait .sip009-nft-trait.sip009-nft-trait)
(define-non-fungible-token turtles uint)

;; Errors
(define-constant ERR-SOLD-OUT (err u100))
(define-constant ERR-MINT-NOT-LIVE (err u101))
(define-constant ERR-NOT-AUTHORIZED (err u102))
(define-constant ERR-NOT-BIRD-OWNER (err u103))
(define-constant ERR-PRE-MINT-NOT-OVER (err u104))
(define-constant ERR-BIRD-ALREADY-USED (err u105))
(define-constant ERR-MINT-LIMIT-REACHED (err u106))
(define-constant ERR-PRE-MINT-NOT-STARTED (err u107))
(define-constant ERR-PRE-MINT-ALREADY-STARTED (err u108))
(define-constant ERR-TRANSFER-NOT-AUTHORIZED (err u403))

;; Constants
(define-constant PUBLIC-MINT-LIMIT u1)
(define-constant COLLECTION-LIMIT u800)

;; Mint fees (50 STX)
(define-constant MINT_FEE_1 u15000000) ;; 30% - Creator 1
(define-constant MINT_FEE_2 u10000000) ;; 20% - Creator 2
(define-constant MINT_FEE_3 u10000000) ;; 20% - Creator 3
(define-constant MINT_FEE_4 u10000000) ;; 20% - Marketplace commission
(define-constant MINT_FEE_5 u5000000)  ;; 10% - Turtle charity

;; Variables
(define-data-var last-id uint u0)
(define-data-var pre-mint-expiration uint u0)
(define-data-var pre-mint-initiated bool false)
(define-data-var public-mint-initiated bool false)
(define-data-var contract-owner principal tx-sender)
(define-data-var token-base-uri (string-ascii 128) "https://www.blockgallery.com/api/v1/collection/turtles/metadata/")

;; Withdraw wallets
(define-data-var withdraw-wallet_1 principal 'SP2K9XEKEG7BE5BTYWZDAXJ8QAZBJ2TQZJJY3MV90) ;; Creator 1
(define-data-var withdraw-wallet_2 principal 'SP2E1XNE523ZAWHW899HAAJ793PDGAJJZSGC3VEA8) ;; Creator 2
(define-data-var withdraw-wallet_3 principal 'SP1TFWX5VEYDEJ4RW0WQAKQTJPWBP2E305WW9V6P0) ;; Creator 3
(define-data-var withdraw-wallet_4 principal 'SPQB6S4QTWME28PB36Z6Z6GQEM95FYY08N3GAE75)  ;; Marketplace commission
(define-data-var withdraw-wallet_5 principal 'SP2MT2QCH5HDY4JZWJHQR5DX16VQ3CQZH1AQ9V14K)  ;; Turtle charity

;; Maps
(define-map birds-used uint principal)
(define-map withdraw-wallets principal uint)
(define-map principal-mint-count principal uint)

(define-read-only (get-contract-owner)
	(ok (var-get contract-owner))
)

(define-read-only (is-pre-mint-initiated)
  (ok (var-get pre-mint-initiated))
)

(define-read-only (is-public-mint-initiated)
  (ok (var-get public-mint-initiated))
)

(define-read-only (get-pre-mint-expiration)
  (ok (var-get pre-mint-expiration))
)

(define-read-only (check-bird-used (bird-id uint))
  (ok (is-some (map-get? birds-used bird-id)))
)

(define-read-only (get-principal-mint-count (principal principal))
  (ok (default-to u0 (map-get? principal-mint-count principal)))
)

(define-public (set-withdraw-wallet (wallet-id uint) (principal principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (and (is-eq wallet-id u1) (var-set withdraw-wallet_1 principal))
    (and (is-eq wallet-id u2) (var-set withdraw-wallet_2 principal))
    (and (is-eq wallet-id u3) (var-set withdraw-wallet_3 principal))
    (and (is-eq wallet-id u4) (var-set withdraw-wallet_4 principal))
    (and (is-eq wallet-id u5) (var-set withdraw-wallet_5 principal))
    (ok true)
  )
)

(define-public (initiate-pre-mint)
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (asserts! (not (var-get pre-mint-initiated)) ERR-PRE-MINT-ALREADY-STARTED)
    (var-set pre-mint-expiration (+ block-height u288)) ;; ~48 hrs
    (ok (var-set pre-mint-initiated true))
  )
)

(define-public (initiate-public-mint)
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (asserts! (var-get pre-mint-initiated) ERR-PRE-MINT-NOT-STARTED)
    (asserts! (>= block-height (var-get pre-mint-expiration)) ERR-PRE-MINT-NOT-OVER)
    (ok (var-set public-mint-initiated true))
  )
)

(define-public (pre-mint (bird-id uint))
  (begin
    (asserts! (and (var-get pre-mint-initiated) (< block-height (var-get pre-mint-expiration))) ERR-MINT-NOT-LIVE)
    (asserts! (is-none (map-get? birds-used bird-id)) ERR-BIRD-ALREADY-USED)
    (asserts! (is-eq (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.bitcoin-birds get-owner bird-id) (ok (some tx-sender))) ERR-NOT-BIRD-OWNER)
    (map-set birds-used bird-id tx-sender)
    (ok (try! (mint bird-id)))
  )
)

(define-public (public-mint (bird-id uint))
  (let ((mint-count (default-to u0 (map-get? principal-mint-count tx-sender))))
    (asserts! (var-get public-mint-initiated) ERR-MINT-NOT-LIVE)
    (asserts! (< mint-count PUBLIC-MINT-LIMIT) ERR-MINT-LIMIT-REACHED)
    (map-set principal-mint-count tx-sender (+ u1 mint-count))
    (ok (try! (mint bird-id)))
  )
)

(define-private (mint (bird-id uint))
  (let (
    (sender tx-sender)
    (next-id (+ u1 (var-get last-id)))
    (wallet_1 (var-get withdraw-wallet_1))
    (wallet_2 (var-get withdraw-wallet_2))
    (wallet_3 (var-get withdraw-wallet_3))
    (wallet_4 (var-get withdraw-wallet_4))
    (wallet_5 (var-get withdraw-wallet_5))
  )
    (asserts! (<= next-id COLLECTION-LIMIT) ERR-SOLD-OUT)
    (and (not (is-eq sender wallet_1)) (try! (stx-transfer? MINT_FEE_1 sender wallet_1)))
    (and (not (is-eq sender wallet_2)) (try! (stx-transfer? MINT_FEE_2 sender wallet_2)))
    (and (not (is-eq sender wallet_3)) (try! (stx-transfer? MINT_FEE_3 sender wallet_3)))
    (and (not (is-eq sender wallet_4)) (try! (stx-transfer? MINT_FEE_4 sender wallet_4)))
    (and (not (is-eq sender wallet_5)) (try! (stx-transfer? MINT_FEE_5 sender wallet_5)))
    (try! (nft-mint? turtles next-id sender))
    (ok (var-set last-id next-id))
  )
)

(define-public (set-token-base-uri (new-uri (string-ascii 128)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (ok (var-set token-base-uri new-uri))
  )
)

(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (ok (var-set contract-owner new-owner))
  )
)

;; SIP009
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-TRANSFER-NOT-AUTHORIZED)
    (nft-transfer? turtles token-id sender recipient)
  )
)

;; SIP009
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? turtles token-id))
)

;; SIP009
(define-read-only (get-last-token-id)
  (ok (var-get last-id))
)

;; SIP009
(define-read-only (get-token-uri (token-id uint))
  (ok (match (token-id-to-string-ascii? token-id)
    id-string (some (concat (concat (var-get token-base-uri) id-string) ".json"))
    none
  ))
)

;; Dynamic token URI
;; Credit: SP3BS8RXKKAAM7HA76SFDKG4Q2YSG0X8K5K44XNDV.jelly-nft
(define-constant digits-to-string (list "0" "1" "2" "3" "4" "5" "6" "7" "8" "9"))

(define-private (extract-digit (n uint) (digit uint))
  (mod (/ n (pow u10 digit)) u10)
)

(define-private (token-id-to-string-ascii? (n uint))
  (begin
    (asserts! (<= n COLLECTION-LIMIT) none)
    (some
      (concat (unwrap-panic (element-at digits-to-string (extract-digit n u2)))
      (concat
        (unwrap-panic (element-at digits-to-string (extract-digit n u1)))
        (unwrap-panic (element-at digits-to-string (mod n u10)))
      ))
    )
  )
)
