;; @contract Stacking DAO Genesis NFT
;; @version 2
;;
;; Stacking DAO Genesis NFT minter
;; 

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_NOT_AUTHORIZED u1101)
(define-constant ERR_CANNOT_CLAIM u1102)
(define-constant ERR_ALREADY_CLAIMED u1103)
(define-constant DEPLOYER tx-sender)

;;-------------------------------------
;; Maps
;;-------------------------------------

(define-map claims principal bool)

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var cycle-end-block uint u133737)

;;-------------------------------------
;; Getters
;;-------------------------------------

;; If people held at least 100 stSTX throughout cycle 74, they can claim a Stacking DAO Genesis NFT
(define-read-only (can-claim (account principal))
  (let (
    (balances (contract-call? .block-info-v1 get-user-ststx-at-block account (var-get cycle-end-block)))
    (ststx-balance (get ststx-balance balances))
    (lp-balance (get lp-balance balances))
  )
    (>= (+ ststx-balance lp-balance) u99000000)
  )
)

(define-read-only (has-claimed (account principal))
  (default-to false (map-get? claims account))
)

(define-read-only (get-cycle-end-block)
  (var-get cycle-end-block)
)

;;-------------------------------------
;; Setters
;;-------------------------------------

(define-public (set-cycle-end-block (end-block uint))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR_NOT_AUTHORIZED))

    (ok (var-set cycle-end-block end-block))
  )
)

;;-------------------------------------
;; Claim
;;-------------------------------------

(define-public (claim)
  (begin
    (asserts! (can-claim tx-sender) (err ERR_CANNOT_CLAIM))
    (asserts! (not (has-claimed tx-sender)) (err ERR_ALREADY_CLAIMED))

    (try! (contract-call? .stacking-dao-genesis-nft mint-for-protocol tx-sender u0))
    (map-set claims tx-sender true)
    (ok true)
  )
)

(define-public (airdrop (info (tuple (recipient principal) (type uint))))
  (let (
    (recipient (get recipient info))
    (type (get type info))
  )
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR_NOT_AUTHORIZED))
    (asserts! (can-claim recipient) (err ERR_CANNOT_CLAIM))
    (asserts! (not (has-claimed recipient)) (err ERR_ALREADY_CLAIMED))

    (try! (contract-call? .stacking-dao-genesis-nft mint-for-protocol recipient type))
    (map-set claims recipient true)
    (ok true)
  )
)

(define-public (airdrop-many (recipients (list 25 (tuple (recipient principal) (type uint)))))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR_NOT_AUTHORIZED))
    (ok (map airdrop recipients))
  )
)

(map-set claims 'SP2N3KC4CR7CC0JP592S9RBA9GHVVD30WRA5GXE8G true)
(map-set claims 'SP1DJWJNKREHT3YGRB09DRCYD1QKGK5DKF8V868VX true)
(map-set claims 'SPF7FJ9VFSVKNWH7JWSNFTTCG3P5Z0429R38KV7S true)
(map-set claims 'SP3VTC5TNYC9ZJ5NZ9DG4HHZP5Z21ZM5JRSF6M5MD true)
(map-set claims 'SP3J0Z8YSJD20TGEBE6M992CWFDG18VB0PR599VY9 true)
(map-set claims 'SP34455SJ4NJ7MCKV7CN64JJTVDP3VZPMVT54BH57 true)
(map-set claims 'SP2EDRYCPGTS32HZAGWV54RAVA2GTW0WPBP4HGCXR true)
(map-set claims 'SP3XD84X3PE79SHJAZCDW1V5E9EA8JSKRBPEKAEK7 true)
(map-set claims 'SP1HHSDYJ0SGAM6K2W01ZF5K7AJFKWMJNH365ZWS9 true)
(map-set claims 'SPM5BVEBYCN2Z1AR2E06A69HF1W70G7V5GZFDNPR true)
(map-set claims 'SP331R3MQE82TBWV5R4WGZAD6FRDBN6S5ZN635CG2 true)
(map-set claims 'SP3P1TCXN3FP3V79YWXC49F5X2HYKS39CMCP5FEHN true)
(map-set claims 'SP1E8A3T3AW2HRFB5FXMYWB2DC0TSC6H1EGTHND1W true)
(map-set claims 'SP25SF2MPZZS8Q20QA3VTYJXTHAHCRNM5MSZYDNB0 true)
(map-set claims 'SP32ZYEZGWHHFQ5RX2WMFVDXR77C5WWQP4EK7E6HC true)
(map-set claims 'SP2FA1H3K9FMY2CQ80WWT2JYMHZ5Z2B810AT41APW true)
(map-set claims 'SP2855G3MZ3WFS5P0NRK098T1DKQ3QH5MVJ14P70P true)
(map-set claims 'SP3XMSJSV1TYRP69PAC0751P483QZ3E17R5GTV4CX true)
(map-set claims 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS true)
(map-set claims 'SP19WSDJWTH4CW3YG554XS5CAXJJGAN83P8CFZ4K1 true)
(map-set claims 'SP1XY983C1MEXM83MGNJC2JAAEGYVYZY5BYW5KS4K true)
(map-set claims 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G true)
(map-set claims 'SP3XYP0HYZHKHJ96THQX8AV7TQYJWMF8PP30K0RX5 true)
(map-set claims 'SP18P831TBGKSGMJEMJM0V29CMKJP650ZT21YJ3XX true)
