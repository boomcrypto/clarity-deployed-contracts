;; Storage
(define-map presale-count principal uint)
(define-map treasure-count principal uint)

;; Define Constants
(define-constant CONTRACT-OWNER tx-sender)

;; Define error codes
(define-constant ERR-NOT-AUTHORIZED (err u201))
(define-constant ERR-SALE-NOT-ACTIVE (err u202))
(define-constant ERR-NO-TREASURE-AMOUNT-REMAINING (err u203))
(define-constant ERR-NO-PRE-SALE-REMAINING (err u204))

;; Define Variables
(define-data-var pre-sale-active bool false)
(define-data-var public-sale-active bool false)

;; Get activation of sale
(define-read-only (get-pre-sale-active)
  (ok (var-get pre-sale-active)))

(define-read-only (get-public-sale-active)
  (ok (var-get public-sale-active)))

;; Get balance of treasure
(define-read-only (get-treasure-balance (account principal))
  (default-to u0
    (map-get? treasure-count account)))

;; Get balance of pre sale
(define-read-only (get-presale-balance (account principal))
  (default-to u0
    (map-get? presale-count account)))

;; Mint: a new NFT
(define-public (mint)
  (if (var-get pre-sale-active)
    (pre-mint tx-sender)
    (public-mint tx-sender)))

(define-public (mint-two)
  (begin
    (try! (mint))
    (try! (mint))
    (ok true)))

(define-public (mint-three)
  (begin
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (ok true)))

(define-public (mint-four)
  (begin
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (ok true)))

(define-public (mint-five)
  (begin
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (ok true)))

(define-private (treasure-mint (new-owner principal))
  (begin
    (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner))
    (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner))
    (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner))
    (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner))
    (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner))
    (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner))
    (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner))
    (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner))
    (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner))
    (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner)) (try! (pre-treasure-mint new-owner))
    (ok true)))

;; Mint: reward NFT
(define-private (reward-mint (new-owner principal))
  (begin
    (try! (pre-treasure-mint new-owner))
    (ok true)))

;; Mint: treasure NFT
(define-private (pre-treasure-mint (new-owner principal))
  (let ((treasure-balance (get-treasure-balance new-owner)))
      (asserts! (> treasure-balance u0) ERR-NO-TREASURE-AMOUNT-REMAINING)
      (map-set treasure-count
                new-owner
                (- treasure-balance u1))
      (contract-call? .stacks-3ridge-seoul-meetup-2023-nft treasure-mint new-owner)))

;; Mint: pre sale NFT
(define-private (pre-mint (new-owner principal))
  (let ((presale-balance (get-presale-balance new-owner)))
    (asserts! (> presale-balance u0) ERR-NO-PRE-SALE-REMAINING)
    (map-set presale-count
              new-owner
              (- presale-balance u1))
  (contract-call? .stacks-3ridge-seoul-meetup-2023-nft mint new-owner)))

;; Mint: public sale NFT
(define-private (public-mint (new-owner principal))
  (begin
    (asserts! (var-get public-sale-active) ERR-SALE-NOT-ACTIVE)
    (contract-call? .stacks-3ridge-seoul-meetup-2023-nft mint new-owner)))

;; Flip flag for pre sale
(define-public (flip-pre-sale)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    ;; Disable the Public sale
    (var-set public-sale-active false)
    (var-set pre-sale-active (not (var-get pre-sale-active)))
    (ok (var-get pre-sale-active))))

;; Flip flag for public sale
(define-public (flip-public-sale)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    ;; Disable the public sale
    (var-set pre-sale-active false)
    (var-set public-sale-active (not (var-get public-sale-active)))
    (ok (var-get public-sale-active))))

;; Initialize address for minting
(as-contract (contract-call? .stacks-3ridge-seoul-meetup-2023-nft set-mint-address))

;; Treasure Mint Addresses
(map-set treasure-count CONTRACT-OWNER u50)
(map-set treasure-count 'SP1997REHPBDBRRWRHCTF693SHS0TDEA6V84TKYZV u1)
(map-set treasure-count 'SP3B12KNF2WWXPMTY5GK3S9D8HG2W6ZG9H84NB6T4 u1)
(map-set treasure-count 'SP1ZJHN74VH26SPHHJB4YP6NSEYVKFZD1W0ZK5K9H u1)
(map-set treasure-count 'SP20KFMW5NAQATXXG8MMB8ESGB33XYAEK1TBTR8J8 u1)
(map-set treasure-count 'SP31A0B5K60KHWM3S3JD0B47TG3R43PT1KRV7V53B u1)
(map-set treasure-count 'SP2FYNJVHG0CJDMYCCVK4AB0WBD561TW0YP7M4PVA u1)
(map-set treasure-count 'SPA5RK3DBP26GHD5Z462JRME33GQWXWAVX359FAJ u1)
(map-set treasure-count 'SP2TSP9H8877HZX69B9JQ2EM2JP97XJNZEKJTE2ZT u1)
(map-set treasure-count 'SP3D4C9J5GX7WN3Z4X1SXE3A88MJYKM41YS7GHEDY u1)
(map-set treasure-count 'SPJ9J39D9FDFXM3FC31Z5QGC31FAEMRJ13WPXJMY u1)
(map-set treasure-count 'SP1VEQYSMWF1J3XV35XVCFXY8YW2E92QMPG2VT5WR u1)
(map-set treasure-count 'SP2YXPVMEVPGT5ZP071CCA2ZZC68EYQ72J5ES0R19 u1)
(map-set treasure-count 'SP1CD4CH173PM3STX545S40GFNGTVQAJ85BTQEMEN u1)
(map-set treasure-count 'SP1BH6PQFJ69BNKM6A2MQ10V7J6PFT7JXHNDYF0WQ u1)
(map-set treasure-count 'SP1NGMS9Z48PRXFAG2MKBSP0PWERF07C0KV9SPJ66 u1)

;; Treasure Mint
;; (treasure-mint tx-sender)

;; 3ridge Reward Mint
(reward-mint 'SP1997REHPBDBRRWRHCTF693SHS0TDEA6V84TKYZV)
(reward-mint 'SP3B12KNF2WWXPMTY5GK3S9D8HG2W6ZG9H84NB6T4)
(reward-mint 'SP1ZJHN74VH26SPHHJB4YP6NSEYVKFZD1W0ZK5K9H)
(reward-mint 'SP20KFMW5NAQATXXG8MMB8ESGB33XYAEK1TBTR8J8)
(reward-mint 'SP31A0B5K60KHWM3S3JD0B47TG3R43PT1KRV7V53B)
(reward-mint 'SP2FYNJVHG0CJDMYCCVK4AB0WBD561TW0YP7M4PVA)
(reward-mint 'SPA5RK3DBP26GHD5Z462JRME33GQWXWAVX359FAJ)
(reward-mint 'SP2TSP9H8877HZX69B9JQ2EM2JP97XJNZEKJTE2ZT)
(reward-mint 'SP3D4C9J5GX7WN3Z4X1SXE3A88MJYKM41YS7GHEDY)
(reward-mint 'SPJ9J39D9FDFXM3FC31Z5QGC31FAEMRJ13WPXJMY)
(reward-mint 'SP1VEQYSMWF1J3XV35XVCFXY8YW2E92QMPG2VT5WR)
(reward-mint 'SP2YXPVMEVPGT5ZP071CCA2ZZC68EYQ72J5ES0R19)
(reward-mint 'SP1CD4CH173PM3STX545S40GFNGTVQAJ85BTQEMEN)
(reward-mint 'SP1BH6PQFJ69BNKM6A2MQ10V7J6PFT7JXHNDYF0WQ)
(reward-mint 'SP1NGMS9Z48PRXFAG2MKBSP0PWERF07C0KV9SPJ66)