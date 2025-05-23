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
 'SP1VCK6DRQMYX9M1ZB27KJHXD1W9WYNNXNW06E1QE
 'SP2DY2NYB5V051DHG584H2Z7EE4C87462WZ4EN83X
 'SP2KY125GEXKEYR8HYQZH2CXMKVF0NNER58RVZETS
 'SP347YF5WFYW014VYYKKV6PZXN2T65G01HEQPGW0W
 'SP3FBBYBR8FMCP8NPT95SQJZCBY8A74PCF4X1GNQ
 'SP6XCH76X75V34N5HNRN89HZKMY50DMBM60D80CA
 'SPS64FY9RPET9JBHHSVZ0CD77PRFKYZPS17EVNVQ
 'SP1MAVN1K5D9JJDVFK6RMJABE6NAV4K67G2SG34ZN
 'SPMPCEQP6QVSZBFDP8WG8W08Y14D8QWGGGN6BREV
 'SP1M75K525BYRRK1VFQWMAPX7BYWFXE1NPQNETYK0
 'SP141AEN1YSRM25JBEAN3HNZ839JSD2BJ9X72A5HG
 'SP3XN8VRCGT78C7CTBEXJZ9EB2AECQ6E5WY4QT8YR
 'SPH68T7WJA4D74RZXWCBX0Z9ZXMYP4S1MMACDSMK
 'SP55B8GPX15Z85277DK2YNARA6P1EHWP6FJZC1X1
 'SP1G2YHW23S05W7DFCYAKEXA1SPTEY5TDY8QZNZ5A
 'SP1TQH5N07WC5JDBCECGSYA6NT310SK03QQ7KC82T
 'SP2J62SXSQW5A5W1BBTMW45V16F84VXFETFP3XW5H
 'SP2EK0C7R4Z42PT0PENYPC83NNK8MPGRR75P111CS
 'SP29TFP5CWPPNGRAN54PMWDHD97B30NWKTKMFNRRM
 'SP2J9FCGZMM7DVF75R7C8MKD6C7HXY8FDCNHP0H2S
 'SP1JTQ988GYBQKZARR03XNKQBGTTB181VNAQDEM1E
 'SP271ZC76AHVG0HASM56H113BSMPV8YBBC4B8Y3AG
 'SP2F4S1Y4FA6D8QTG1DVAJ92VJ08R9EDJ3AQ2ZT2T
 'SP2FZ9WEWD28MAJHXD61875S4X74S3CFRFPWTDDGM
 'SPE20DJCZYTGCZ6XTWZ6YTXCS6XBT1PVGX903JBW
 'SP1NRKS56YQXFHF0A7SW5TG2C85HPR7CEGWKJQ91H
 'SP1YF7Y07D38ZKRE1F6J1KND76N73H34KDWS2SMZV
 'SP8XB2MAYZDZTW57Z8X92H17M7N8863TMTFY2K8Q
 'SPBKC1NGB52EMR5HWXB3P615XKTHD64TXY3D6J1G
 'SP2ZTX17SSND77RDJP15HV3JMC5248RA7KCA3QSTG
 'SP37278Y5HKS9WPVTTK2V14ME1ZXBMC63B8FYQXTN
 'SP1AK04W1757QXM2BWNMHP8K7BPTNMFSPF0RC69R0
 'SP1F43TQEYCRHWVRG44HGFN5HV0YT969PEVT3GBAC
 'SP1MSCRYX1XSWZHT1JV22WW0JHRCZSPX5QYW7BWG9
 'SP22BRNMAC7QJYC1NYDF289AXXRPW579WDG0BYQSW
 'SP240M4D2RC5FZRRKR92E0D6QQ5D4JAC444CFHNJ3
 'SP2AH5S7Q3868E0NKTV7N18WK432SD39ZV6D003HC
 'SP3D88J9EDQKW8J4EP450MR59W422M9BYRZ77TVNJ
 'SP3K5PGRR74W9ETJQGTDPAHE6SBY6M54F4ZCKVFED
 'SP3KVEAFG5427J6CPP5JGW0WKY378QNKNND3MBNMD
 'SPVT3AW629851B7MK6M8N58CJ7JHM4JSH462BD91
 'SPJ9T46Z7M6BG8BCWJ4P8CCENVTDC5GHQW9WZJRZ
 'SP1FTZJ7F41YGQBVMMZSD7A85KYVR35G3EP5SVZGF
 'SP1FV37MR66MW71VXW08M0DC10QER8RX8236B48KR
 'SP3QRWYAX3JRXD3M5H5DWS9Z2QN4T5SS969GSW5EP
 'SP2CTXGNRCABRKC8Z6HGTQ7YVHPVT61EJJ6F2QFN1
 'SP2XWPWXBCV138E2QN9JAJMDBXQ8MPK39RR5M8SHS
 'SP3B2HP3CJTKDQX3AZMX9CTRBAMETADCXQ5ZDWMS8
 'SP2DV1KQJD88RKGZ0W8D92NMW8PA3N2YKTNZ369CG
 'SP255M5D0S3JZBY6XF2R8C5V1ZQA5FXQM6Q1A7EZ5
 'SP37WGZ0XY3WGREW1K038X8T5XVRG4TY017WPM3CM
 'SP16QYAYKQ3NNN4CMVSV9FY3PS2WEMHQJTGZQF98J
 'SP1V0T1AEVZWVP19403MXSK0EKX8WBDZZJM87YVWK
 'SPQ3ZV2X9HEBWDE913C4KK2TNAY3WP4AB9TYKH5D
 'SP3G1WFQPW6N7T70M4CE085MFBSN2R8RZBQ8SDQ9F
 'SP3GZYMED0JA902Z0CQKNMT1MDEE6SHVYS0DVRJSP
 'SP1ZKM2PEP0N6TBE21HSTPH2D1WX1GJQBSYSWA8B5
 'SPEX3RKJSP929V9Q1FHJHWXTH25EAFK067F9Z6R6
 'SP909KYW2W7ER924RVDSPH42Q37P9RZ5VT9BKM2Y
 'SP32JA843P5D9XXJY80CBMBD4QBJGQ82VPPJR7EWZ
 'SPJH144XQV4YAJJTD5FMWN97N46F6PVP6B4R1KPE
 'SP1KVEG9227HKYH7AJ7YRFGWZ1BXH9P0J2W6B1H8Y
 'SP2R30XBTW56BYPM5JNSPKGGJ6SXR2C7DHASHK7EN
 'SPFEPA2CQJP0KFXXAGV2QJZVHTV7EECHPDH53KHR
 'SP1XVFZJJ48Y5586BTDWE22MXFDCYZKCDRWY6T0AA
 'SP1A0XVMK6361SJV5AD0AK0MM9RSXRPXP1M8RE02J
 'SP263Q9V1VA2TRMYSVNR59M4QA9ZTYRQ52CCJKK07
 'SP3SZ0E2AE8FTTKW37XJK58EGVDQ6T7Q65FAM0T8G
 'SP1K5S29VVBSKYV6M70ZN27JHBHFND6MHFJZ84G8N
 'SP2MT21Q6AB97SK1JFYYZGKMTRAXCM5Z676KD0AWS
 'SP3BWRZ3MTCJF8HWBPFYB24BCFDP34VWH0BTQHY81
 'SP3DBZ0AAWCMWMJNX1RX7BES0V2ES0SKNZ76BVQ0M
 'SPQY7HA7ZGZFZ84WF4KGWE1S5D2RPKT76BD6XRQX
 'SP1AX6S539HS5Y8XY9T7JRBY6B0HS0FV759X53G9P
 'SP2A7BRA059X4Q7TEQ8FSKWAAFVC7WMRKGH0XSZ8
 'SP26W97E7BPNNCCX5ZY9E82TJ7MG22H9DGAVMP8P6
 'SP1XXV0J4KMSH4TTJJ95D5AJ8P7D55B3P2FNJNQAB
 'SP2AAF1S51A2DNRY15X8WHXNTMN481Q6A0W5G69MB
 'SP2FTR6AWCR2J7NC4SPG7CKAAD45FQ2HPAYMZMP83
 'SP11HTY8257JSWMXFSDCXSSZ8BKQYBAZ71MS9J73A
 'SP18PV47NQMD0TP36TX1ERVDM3DPP433TF2MSD7RN
 'SP1BEV5JHS8E7JC1NDMH1729JFYSP0PK5RZPYFZPT
 'SP2BB5QZWKG1ZARXB1CMAH83AAJ8VRS0F3SJ2A7BG
 'SP2M5MTR8MVR5QS6HQ88YHB60D9JCD9KT5WT0MPDE
 'SPBYJGG7PPM9F8E9TSQ3AE4N9RB54F7WANMKTV1F
 'SP6H04FQ360PMGYQ2WN5Q0F8MJFVWEN8A7NQB23S
 'SP1R3B4K77VBJWXSQAKV2VHBHE8YYP60SM4S17GXX
 'SP2EX5DGYSGT1GHT5YK08TW9R6A193D19WG1R7G7V
 'SP2635RGB8G26E6754DFPSDXGMRZB7W89GMPAT6R
 'SP370VMPZMNWQHPMF0GPJXN2GA1JPP9PP0XDW70BS
 'SP1RXS33931GRAWMF30SAZNNZAFFW46RY13ERKY4Q
 'SP1N55MCYVJRREE1XBV0N6ZRDN8Z41ERJ8KQHGR0X
 'SP216Y4DYSSBMMEACTMNRFYAWQZ1GWY49DJWH54PC
 'SPH434T4DTNWC4KPCMYDXYSH80CYCZMWB0EFCE1A
 'SP1J3H6YSRANW8HMCPTVH9XK9E9KP2SM3NQNNJJSD
 'SP2XHQ31804Y97R0VZX2EA3ATY4VNGYJJS1X4BQ40
 'SP3E0R3JCQAYG7M96B8CW81ND1K8V5X4MPX5KH7CV
 'SP4BB7N2H95N5BW77D65JRK417X3B7WTW6EG7738
 'SPDQ1VAT8JQ8EV279R49VVXTKQP439QFNJN4S8H7
 'SPJNYPNBT86BK7BEDS3VF7RRYQE4E9VJ9VK5KVAJ
 'SP3Q33C69JTEA5MFEWF2RVSPZKBSHCYX4Q6MZWAT
 'SP10E9Y1C7PFBJQW0G917N80YS3G7Z93FR4424S4J
 'SP3MKF26KERR90G2RYRT0VKF4CE51DSRRCE7FJZYZ
 'SP0CDTTKFVBDQFJWEHRGHF0QM67X74S3D3Z2G7H9
 'SP3ZAR3JB15ZJ7RCMQ5ERY13C6BSK3278A5DD01AN
 'SP3TCJMRQV9WE5BY3XAQGC2WBDH9QM85JGVAE8DTX
 'SPVTZNJV1SKZQGMHFZ87FMVA8JM2ZW4SYX4HSC3P
 'SP1K89NZY0J1N31W0A5BH5HWD3W05DKBAEQVJR8GF
 'SP1SFF9CQ7KYJ9JB993FRTZ5ZVR0JBER2YE7NQQQ0
 'SP20WJ32B9P9G9B32ZXS7MXNFSS8PVHEVEJXPAXMC
 'SPSG8C4JFTZ6YSAJX7WPTCY5N0WPGGPX166PSPZT
 'SP3J86ZDPVYJ50JXAXX5VQJ19VVDCCXCMDS0TT0GY
 'SP3Z27FC1PNKZPKCV7088BYCVME8BRS8P2BN30ZAH
 'SPM3MAD8N74MRTY8XDWTZS756EFAD81VS5N4WQK6
 'SP2P2XFTCTH4G5XMV3BSAZ6A2X18TCRST82XQXTRH
 'SP15KMQHT7GF9P88FMFXQSFDQ5V9H5PJMJW66JTG4
 'SP0F7F4AJH6V835K72273ST7RNYV74R2MXYHJ0BN
 'SP32RHR0Q5WE18DD0D2Z3H7PC0EMKT1RXAZ2KQBBQ
 'SP3X8T8SA3FPRK6S8RD5XZEH9K44SP3KFJFEP4SQM
 'SP1VFDQK6N41TJN2433SYD6XJ2M8DVT65ZQW5YQD7
 'SP3S0EJT2W0WWBG7VRF0BQZ2ACBD4TKZKDXH5J6Q7
 'SP274PMRF37Z0QSKA8RQ2QBEH7DERX291CD5RXZBW
 'SP2PQG40GYFYWGSMM4N9DS2R6TA5N5BS8MFMYP9E6
 'SP2SZED64A0WAMJ5TAXAD3XX80ZEBRZKA15QF57GZ
 'SP1SED69SA2S0GB383H46HK9HH2DY20800XSS7WW3
 'SP1SY72GHXF36XM042RE425D6J6A055423PC114AD
 'SP2T45BWAXTQG1RWRTTHCAYZXHA0XMZRBFMZCY40K
 'SP38ZW8SMTE5D91C682ZKTE89CDJ93TTZ1ZJDWG4K
 'SP1PZFSQMGS5REQB40CDX8ESN8RTNDGZ8CQHYYPTC
 'SP3NEPVM5EP97JZKNKYW8EF22Q4G98HV6HZ5TEM5
 'SP3X7A0PY0SY0G67F7VHMWKGGG03V19WMZZR41PC3
 'SP2D5GJDV4FBKHR0EBBRXT6XEQ9HXX4DTYHWJ4F2G
 'SP2Y1X1V3TF6HJQM36MMDWPPZ6QHZ0DV035BKP0JZ
 'SP1MCXW9KFCHJFVZHQEY16G700M884FGMY8H9M7W2
 'SP24V4YZFZD52YJRA38T3VSA31ASXSWMCTBYT38WK
 'SP3B9M0RS56PFY0MQ3GQ234QMJ1FZC4BJ2Y154PB1
 'SP3DMTE2FEYANBGRAEP2CBXSPVRCBE8333CF4ESSY
 'SP176T3FB3PDWPVGBCNP0GT4P2PD1JQCQAXEV67VZ
 'SP2QAK37DBTDCMZZ8GNS93B6GFMWBBNN2ZD872W3H
 'SPVHW7SHBTE8HMMB9DQGK2FH2CC11GJAC7ASGY75
 'SP2V2Q9QN0NX07PQTTEH0MPERMNVF4RXTYA0HKRB7
 'SP2SQT2MMET6WS02SVCGMYF4HD3JF135ASJZQQ83
 'SP38008MVFENGNZD9369HDNCJBHS6G15VXEG7DPKH
 'SP2591FKT37XMNVAXJW3AX265K8KG3KE3NK3RFJRP
 'SP2CQJJJ090QGB1K7XSSRJD474B118PV18785C1TA
 'SPT0904S3GZ2816ZHXD7RWBXEB5030MYB3G753NE
 'SPY1T388DEB1PP2SZ8BFNMYYE1ZB7RBHDWXX2WZD
 'SP5MKG4784065NVR2X0HTT4H0F2GDFGQQE0TA3WN
 'SP1MBAA5PS9X73HNYFX4S1RYC33CSJ976C3X3NVAD
 'SPTZ4FTC37QE49VFCHE3QFD4NT51MBWXA8TN02M3
 'SP37TFQNA7M0EWZ1MCGJGDJ4J0BA9X8AKMEZJA2G8
 'SP2Y5YPVRJ3RAFHXM04E0N7ZXNPD9PHND85NVVDVB
 'SP2C4B8ZY6G4JRNDDH1PHKZFB5JSESX7D5HV4NT6Q
 'SP2N2H0Y9CYD8WKSVDJES7JTE1FDN9ZZ589NVGX0T
 'SP3ECN8GQZRNN90G748C0Y0VPF4YZA4FQ8363J03Z
 'SP1SP68J2FTHHG4X0GTDKC9570AE0XNQ1JW0XC88M
 'SP2P9Y3EJHCM8T0690X7H6ZV8CRXG9ZN34K2AP00B
 'SP2RTTZSAT92NNPSDF2V94XF8MXDTQKTK12JK5SM0
 'SP33SFYJ4YY31PJ4HTF3BBY4SKDSR6B9FVRB3G93Q
 'SP2QTDS7HD9A93S1J6D3HH5Y7YDF5AT13621QFPWJ
 'SP1SCHYQ2X6CBS128C891V6NJYG6EBEK3RB3GRJVK
 'SP91T9XFDGQMKTG6K30QRJBDMSFQ4EDN552JXQ4Q
 'SP55R4ZSDTS5PGGZ7ZD70RNEHT55XNBHA3ZFMRA2
 'SP1J53Q86T20KMMPPRZ05T3DW6FMEA7WFKKC0C5BT
 'SP1CF4DB3ARVRRAW5Y9A68E3V9MAQ9BG24NDDDXXJ
 'SP2CS6HTBN4SE149P8M82WM3A2MQA8HH8EFRDTTYJ
 'SP27658BTVZ8DHBR0XB599504MP0773CTABY81YJJ
 'SPWQ59BDVJJPYY1H591XKKV6H4QG3S2CVPVNAB3Z
 'SP2PDGYWC3QJ3ZWKYE7VTH18J8KZTSATYG4X5V060
 'SP3EPQF5RY9TD7BPCX2HNZ3H2ZZGWSCHZ50DYVS52
 'SP1YN0K0MMAR4Y5YRYWDAESMHMCJM9VD0DJ87AR31
 'SP2FXQGZZ23EJR0EPQBNWZC274H8BB1WXAXTNCM7K
 'SP3YWMB24SSRPCRNH5EPXEXJKPBSXCQ3TREJNAGAN
 'SP2V8PF8QRSQJ3B282WXARZG2C43X5BEEEMCZTSP3
 'SP1N57AYNYV09E4ZKPJWB8JQTNSZXPW7Y9HC1PSPV
 'SP15APEJ7MWTWJW2Z975AN597M268312FSDGWPPTQ
 'SPSN69CPNDXKZCQH3QRC18QXJ5WTHVRHN7N2DX4B
 'SP3F7000ETV6PAZCQ6PZ30PKWJ0WGSRF7P6A6F3S1
 'SP3NCFR5SW185SCXY99DPBWYGTTXTT9ZZJG2QCGQT
 'SP219G4RNY1T22S4ND4CA1A3D2CSE89GRSNC1DW8V
 'SP2JBGDF8GRSWJ25Q1F1EKZ43NBXJX0A14M8VH0VG
 'SP12NRYHSXYXABZ8D95YHS2RXAWXRDD916WXAZ8RT
 'SP1ETKME4D2XK2FJT9QXYA4RHGMD7RCNFJ3K7FJC0
 'SP3Z2ZGSZKJP0C3KSFNMXPZVRQ44HF608FMPNY7Y8
 'SP1Y6EAFDJS4DJX39NT6BEFZ77DBNHKD3J7MX0ZKY
 'SP25YCAS2FTXE41S0D9K5ZW2VNHYVMCNDC95AQKG3
 'SP2943YW93JJPSGMNDMXRFRQYXPS2AKX5Q28FNJ5B
 'SP3NBR8WP7RXV0FT4DVSVF817314S82GNCCZDZ2WR
 'SP3YXQT5DXDZKEDSK6YN3GKM2JEMPFC6GD6BMBYEC
 'SP9Y88T07VEVB7V4Y8D8SR1ETE8H07MNV79M8VWK
 'SPCW1G8MWE3QT8PEWXWS0FXE0BVAZJ5N4YG8YHK3
 'SPFCXXESD46NNHZKED4B6TEFGGTXD5N2DRKMPA7B
 'SPZRP1JA643MVTEY1YT9XHTVKQXM1FXD5W5ZE4MY
 'SP2Q8PBDVQY4N3PD5THRE6RNZC4WCPDCP0KMB22MD
 'SP208BFNA6FP2K3HS8V3VVD17JBNN63RCEP7PN0V0
 'SP1FMV7AX1WFGWG6VSCBPHNRN3MXFQZFD27EFA5KC
 'SPHKPR44HBYK3VP3WG1CM5TCVG63KKK4QRZRQ180
 'SP3X4ZDCH4X4WRZ8XEBZWVQQ6ZM69Y800KW4F1YKC
 'SP1S518J780VXYJS9MQ16JW5NQZBQ0GS56G0C41Q6
 'SP1MF05PEQHRC9NTVTGD920KEZP2SDZKKDZMCS3DH
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

