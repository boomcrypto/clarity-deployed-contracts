;; Used to simulate mainnet migration from v1 to v2 in the test suite
;; Must be called after deploying migrate-v0-v1.clar

(define-constant deployer tx-sender)

(define-data-var executed bool false)
(define-data-var executed-burn-mint bool false)
(define-data-var executed-reserve-data-update bool false)
(define-data-var executed-borrower-block-height bool false)
(define-data-var enabled bool true)

;; TODO: to fetch off-chain
(define-constant ststx-holders (list
 'SP2KN43P1KVHAEMPJT0GM1JH6DW058M99C7DEX0XJ
 'SP3G1FYEP0DAWM0BTX446Y92HVT7RJ8KB0MBG6VMQ
 'SP2NH5JB01WYMBE4ZBP2MRWC1VT5VNP15J89SRQ47
 'SP18295NSWPNSHYF8CYQYVFAJTPM8855242MPBG96
 'SP2Z7EPPAQGCVSTSKG13DT6YRN8X21HVD83Y5YH1N
 'SP3J3XP8TW2ENWZM3ZKDA3PFT46GSTZ3ZTTFSWZDK
 'SPCD0ZWMQ75ZJ152PB0C2Q1S69P0GDFYBAS3Q315
 'SP302KETQ770ME2ZA3KHRAPTN2BJ1HWJFZRH5ZQGZ
 'SP6SGVE6KJP8S7BN66TJWP0HERWDTERXS9PKRHDN
 'SP330R59339Q2WQNVX43Z5AN1GCYMFJ9PN3K66YQD
 'SP1GTQ9CS546J6WPCDRXGWYRGHVSGZAC5QMNTYXCB
 'SP2F48735BJJMJFSY9R05WCANKHZZDQ0PPK285GR5
 'SP11ZVV9T0E7D82BFE6T54N1475E2A2EA383X422J
 'SP6PCHCCFART4ZTXCVZR9FT9F4JJ0Q2A4ET41W0R
 'SP1A3C02M44YXV6NB049PSBE2V7PZ6MNMAK4Q9AZF
 'SP3A74M7AX67W64Y8SH1ARYC1K8ZM522QNBQKB7SZ
 'SP15GD4DFAG4X5M0CYNAYMHDPKMMT9Z0NCXNH16HW
 'SP2RCA8KBFGXY0FPJM7B96D2FNSKD1F4V3ZBDK8DY
 'SPMR93J5G7M76EYKZG4DRQYZEZENYM6XMFXSCVC2
 'SP310VPG5A9YN3PS7NTSAEBEPX3E8H0HE8MACVTKZ
 'SP2S48W70RJW2FZQ0MGZXN6BJKQ4GNRRV6B83Y91S
 'SP1HVJNSBKK54E2NDTZSS240Z2Z0RB67B2ZDT9E43
 'SP2T0DVED39JM0X8MWAYFRAYB7R8EWFJC2W3VT1A
 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G
 'SP3BK01NQBKFGA8W39N7YQ4QH2G6K9T5FP0258VY6
 'SPMYW766HEERCDHWYAHR83NW4VR2YC89ZN7CQ5BG
 'SP1QQG29BPWKEYG0JHESAVXFTJSR2NV30GBKVJ2XY
 'SPS1BZ7XDEP906VS8FGF13YV47AA4HZDTM1MT3C8
 'SP133HFRSC3TQGG5MQD8SG87C4Q1R0N8HS8VXCVG2
 'SP1QB148EP9VA61KTBCTJKWG97KGV2B5P39ADBVAG
 'SP2NVGWMJSAAEPZNNQRHW626HBA4Q325FHX7VVPF3
 'SP2W1CCVM1261D8182DT5Q5YRY0A66PFD3G9FYVJ3
 'SP1PY22WG0EV9NNGEH6JD4YPD472RENR073R6C2N3
 'SP131T921X82DWY6EFGKXYM5ER9BPHQGN1NQWRWKG
 'SPT7YVVS93NGKGVK4EGC6WP04ZBKD3Q67MZ4Z0H3
 'SP142SYE5MZ1E1WYV6DMZXDFN9WC643PRNNGVND2Q
 'SP3RPKCYN57DMKKKZWPB91VQ79GS1FEYB0G5NCCSK
 'SP2HTNFVF2XKP814TTY9M3B2N71C85G34N4R576YZ
 'SPM2E0PJAA72T29M7WP1CRY2404BT68DPA44TMG5
 'SP2MVFGS9Z6Y7WA374JQ2KVR4081C4Y8MWNCKMH4F
 'SP19SVK0XYQ9QWCMKSV9XYME2RY9M03FVJW2NNFSF
 'SP1RBHQQ3K7QZ3TAS75FQDGVY5MKFRTBNNFXF0MM6
 'SP3HQ8K1HV7KZPE2N4F83BQY25HJS8VRQF67V9Z5G
 'SP38ZJWREWK3JRM6W09XK5856CN7RGCTJFT1FQXHT
 'SP3KTNQFHQ4N5DH40F1164TGYMX3QG2N8NA5VKN4X
 'SP3HCM6CG3EM4XK5EM65ZP9P9K5QHTY5X868SVAAJ
 'SPPXHPBYCRMJ8K7FYS5SZAJ3C17QP9T1XCTA0941
 'SP1GDMYCGWEF311Y1SBDB3J8XKC4JD5AJAAYFJZNZ
 'SP1CCVPBKXT69WRP8VKSK2VJ5W0M5MTBHG2HPS962
 'SP3PAQDPXRH2B0JD6AEHM0QZ1GQM9FBA4ER5NWHGP
 'SP26GMJFH3PH7GZK4DRRN9Q7K65YR1C04417KV0F9
 'SP30MXC484QAN5472KXWJ03MKPF3Z5K6YEWFRDW9T
 'SP2PKX3NAER3T40ECAYAVZESCGA42B6BP50K6ENKM
 'SP33J1XHG0XY1DP0NVC87YB4ZNKTNHDHCBP4RXJEG
 'SP2460ZC8GAP7PFX3HGX9XTN74TFCBH26B8S2VFEY
 'SP1H6WMP29RXTQQCB3QSA146P6SR7G59BVHTTKWCC
 'SP2Q3FYQ407FAQY2C47CTP43ZXEG00511R3FTMVTY
 'SP3H7QV2A6H1CBH7XV6CF3C9N1DABZ20Q7GRMR4G2
 'SP257MXWZK04XRGY7HYY69QSFV62TX2PC8A49WWSB
 'SP1FQKMVRAYQFXATRVJ5ASRGCBXGAGQ2EY6D1D6FN
 'SP12M9AB90Y8V5V645SZCM2DBE2GS82XET2CXRJE0
 'SPAYE8JQ4D48WPH3JA6B331QXTNZE2EK6GPFRFPY
 'SPT6FK75RFEEM99Q7AMZ90RT6N4CK46BN70YCCMC
 'SP3Y50MB35S35Q3YKQ2AZNR1X0MFZ4NVR77AFJRHR
 'SP7S3EJYAM7NVJ7KD0KEFCY78MRP9M4G2N92QZ24
 'SP35JTXYC99Q5XP12B44VMEYEDWWSKAGSF435KTZT
 'SP23YFKQQB2A83TQCDC4MEQPEKQZJKP83A48XMWXV
 'SP6CG22E967ZVT6920M8ZREGEZE19E6DJR2QB9Z9
 'SPMRZSNH0ZKMT8GQT8XV25SG841ZHC4BQSK49MW7
 'SP3ENBT09BHBQAGVN5RNE9S4YXXFRZ0SMHTBJKDY3
 'SPKTWHES76JSVK3AC7JQY472EFMQ4AEN5K94BZAN
 'SP1W5SQ4WCQ7VCSY3Y5NQAC328K63YFB5YYRBGQJ2
 'SP3XGAZ3QKB0ZVJ73ZF1X4E0H4MDE3HGQ404XK58E
 'SP4PFFP8JRS69BS65RQ0TVQPHWZZZAAVTHK6PQWT
 'SP1FC4XP3KC8083WB8SB6GMVETKG2TXH9KGX98QFE
 'SP1WY102H26RKKV4WKHH3ZB9KGVBE925HP6PH3WE5
 'SP3MVC83VYYSWXEAQN52MHQSMCV55W1RVQB8EDSDH
 'SPNQV83EX9ZXNQJ8YYBJ6AYE3M0WSV8B6PFNQWY1
 'SP2238V3XHZW373R1NHCD5MN3FWDWA7SBZ0ZEC53Y
 'SPMSR80T4EHKYQZKPNA7WVC3AN149EKH1XFJNSM3
 'SPKA8TZZ2GJK06RSQ2JFJ0J7X85D8P4XX16C8MX5
 'SP18TX7QQAFABXXTZYFR75RGPDPDQ35ZYXFJXRYBC
 'SP1YMFYH8GJC31T4FDHS5R1R8PMDZRAGFFPKHFER7
 'SP3G1EFZWNFBPBWZRAXWQR57QKEJYBPH1NZPDCKYT
 'SP2H84QZT1V0YZ70RTRZFT7HAZWDK88XK4CSNBMYE
 'SP3GMVPF5WSRFVV8WQ6P0M4VZFMC46R5MRA6P34EE
 'SP3NYA0QV0QF333437ZERVRH9T0XQ24JM81K36YC4
 'SP3WFW3G78JSYKFEYVTXJSBG9MYDG706DN00SR043
 'SP2J6Y09JMFWWZCT4VJX0BA5W7A9HZP5EX96Y6VZY
 'SP35N6HZTH0GBN0N69FDXWR13T8JG3GRE3Q4WB6V9
 'SP2JTTG6NWJ3V4CFVPY0Q62Z0VSMSGVD9RT0VX9AH
 'SPG9DGS8J4YQX7B0JSMN2FCGS5769C7G11V5H80F
 'SP2G8PQH2QV3ZGNE4SYJH81JQ87PVWHCTKQ7J424C
 'SP4VMR772QMGX40AJKEN1VA0RB2950D071Y77CA3
 'SP1BA3NXG56E229KTRVCZJB62WJTPJZ01ASCZ4BTC
 'SP2J2VTVRNQ8EW2XGGGM4460W3KW9BCRN0M6RKYZ4
))

(define-public (burn-mint-zststx)
  (begin
    (asserts! (var-get enabled) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))
    (asserts! (not (var-get executed-burn-mint)) (err u12))
    ;; enable zststx access
    (try! (contract-call? .zststx set-approved-contract (as-contract tx-sender) true))
    (try! (contract-call? .zststx-v1-0 set-approved-contract (as-contract tx-sender) true))
    (try! (contract-call? .zststx-v1-2 set-approved-contract (as-contract tx-sender) true))
    (try! (contract-call? .zststx-v2-0 set-approved-contract (as-contract tx-sender) true))

    ;; burn/mint v2 to v3
    (try! (fold check-err (map consolidate-ststx-lambda ststx-holders) (ok true)))

    ;; disable access
    (try! (contract-call? .zststx set-approved-contract (as-contract tx-sender) false))
    (try! (contract-call? .zststx-v1-0 set-approved-contract (as-contract tx-sender) false))
    (try! (contract-call? .zststx-v1-2 set-approved-contract (as-contract tx-sender) false))
    (try! (contract-call? .zststx-v2-0 set-approved-contract (as-contract tx-sender) false))

    
    (var-set executed-burn-mint true)
    (ok true)
  )
)


(define-private (consolidate-ststx-lambda (account principal))
  (consolidate-ststx-balance-to-v3 account)
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

(define-private (consolidate-ststx-balance-to-v3 (account principal))
  (let (
    ;; burns old balances and mints to the latest version
    (v0-balance (unwrap-panic (contract-call? .zststx get-principal-balance account)))
    (v1-balance (unwrap-panic (contract-call? .zststx-v1-0 get-principal-balance account)))
    (v2-balance (unwrap-panic (contract-call? .zststx-v1-2 get-principal-balance account)))
    )
    (if (> v0-balance u0)
      (begin
        (try! (contract-call? .zststx burn v0-balance account))
        (try! (contract-call? .zststx-v2-0 mint v0-balance account))
        true
      )
      ;; if doesn't have v0 balance, then check if has v1 balance
      (if (> v1-balance u0)
        (begin
          (try! (contract-call? .zststx-v1-0 burn v1-balance account))
          (try! (contract-call? .zststx-v2-0 mint v1-balance account))
          true
        )
        ;; if doesn't have v1 balance, then check if has v2 balance
        (if (> v2-balance u0)
          (begin
            (try! (contract-call? .zststx-v1-2 burn v2-balance account))
            (try! (contract-call? .zststx-v2-0 mint v2-balance account))
            true
          )
          false
        )
      )
    )
    (ok true)
  )
)

(define-read-only (can-execute)
  (begin
    (asserts! (not (var-get enabled)) (err u10))
    (ok (not (var-get enabled)))
  )
)


(define-public (disable)
  (begin
    (asserts! (is-eq deployer tx-sender) (err u11))
    (ok (var-set enabled false))
  )
)

