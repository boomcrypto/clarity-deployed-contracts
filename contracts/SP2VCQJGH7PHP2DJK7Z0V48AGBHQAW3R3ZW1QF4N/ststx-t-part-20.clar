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
 'SP1FFES3TZANDZKQCC58T270H07CW4Q8RBRHQP9ST
 'SP26X772FAXCH2W21H3K1434VCBHAWGXNS33ENW19
 'SP21FT7TD4C39NV01DS3M8KWV7QM4YHYEX7PCQ8G0
 'SP2ZHQ2WMWHM769X463KPDFEKHTTVRQM8B6909CQ7
 'SP3FJAEQA6M2DK1K76S05B7PB2J60QREAVY38P39S
 'SP1995S5EH862NMV72DQ15P1F6FYP7ADZDZKG75M8
 'SP3D5H0YZZBAY3XBFVRDT8AJEK6XDM3X623SHHQ81
 'SP18D65DBE69VB4MXHXD8DST6CA5JRZY49BHERZ62
 'SP3DZ1J57M3W5FSDS0Y2SF3GEDBKV2EMA2PYTBHC
 'SP3GYDJSBY7VXCGCF4HQN10H068RZ9WY05JXGHMAZ
 'SP35NYP2N91PCDHP1ZDF2HDW4VNKSSF0YMYS9H4Z
 'SP3CMVQ7N2JYSBM8JBNHP38WXPT2VVK1C9DFDBCM7
 'SP287W28WPXZKNWJ7H6NBPP9W3RPCGTBCYEB8GZK0
 'SP20M18F726HVG58MXF2HAWW4X8JZW82FAN8YWTWP
 'SP3N20XATYFVXDGDF8W83QPNNP11TTQBP23BCKD4Z
 'SP1YYHMNQTAX7ZYBJ981N8QC8CD4E1F7C4GKN2588
 'SP30Z0C24JH6H73MCAKH4EET0JHZNFTPBDMXHEMYE
 'SPFD1J8TSFE71YZXEW0M9J31M7TTPWMVB8R87DTQ
 'SP1EZ04X5VXFSPY9NWZXNVESDG982EB0ZW031QX9P
 'SP2WTAVJRN60FGB4YF0QT6S81G73XCJVE6TNZR1G4
 'SP216EBVAVVEAN5RY7DCE1JFHWTB8J9B7D0VM4XDB
 'SP111G0S42TY2TY3QSATH2KZMMRJYY00Q0WA1A1CR
 'SP3V944HMS8AQW1Q8WEVTGKR8W429NABE0D0623RT
 'SP3JCJP3PBVR28D5FFDFJ1P9NTR2EPMWYEB69D0AF
 'SP32Q0XW4TGJ1QE0QA6Z1HVBRWEKRJS0XCYDZ21HQ
 'SP1TRSSHKYKPXY4TSAETFD9WK9JTS5NCK62E8ZNTJ
 'SP281NBPA7H99TPEBB22J1Y360GE3Z6735NN92C4D
 'SP1B1M40Y4Q18G7S2HAJ3K24F1XZJCEBBTVZ1DNZ6
 'SPVXSWNDVZCGPF3CA0DSBMW98GT3N9KJB7PEJ7H9
 'SP26ZKPJQ8HAM8695NWE6Z9ZAG48YBM1QRM1X61QZ
 'SP1K30YJE3K05ETW7MBQP8VM2ZC5DFPECT2ATXDPF
 'SP2YZ69H0J46KC6N3TS1FD26W73Q5TP6JBB2G7JYP
 'SP2G7VD3TG8BGWGG2EJ9EVB9M1HX9YA82PHYE8WCE
 'SP35A6CSZ329705M1X644J8B11941QSA2DNSDYH2D
 'SP3YQNS5RNT5RFB6G6GNMG1T3C2AFM6X18E86JX5V
 'SP3B85787JXJ5DPV2K4DCAJREKNGWWHZ37ZENR2XY
 'SP1BWD6GGXF1B5BJ0ZFP27ZZB443KHPYEY2FTJA2W
 'SP3CWF98FPKPKDFX5QFTXSH465S6DXXWZQN5ZJDXB
 'SPJBHB2WW2REY4TTC2KDH87APP7SZPAK766N85YM
 'SP3ZX0QTVHJKHP2GJE95338RA200F67VY30JCQQCH
 'SPXZJPEQ3P0721P7HTP2Y27DAY216Z3ZNQYXAWFR
 'SP3B3AES6XXPC2MFYFQM8V1NTY1VDBPVZ2QNMG1GK
 'SP17BR51JTVDXM97TTWA8AESRSASBWSASN7T47NA
 'SPMDKK36EX59YZ41ZYSHSQ4AAM8QSBWZP8PKN3ZC
 'SP29X2GDNP6SJBCS50W5C45WW3WZKENCHCR2TWCTJ
 'SP18JV6DZ4PQWBART79Z8KKRCWAV610QX8Y73HXCM
 'SPEHMKKMWP0PRVG5F70D3QQ1P250H6MN8V8TRD0V
 'SP2B6EEWTJ7MVFYJERR8VF1C7RB5N4VZY5WDBA35E
 'SP164SS9Y29G3BJABQXQ13M8GQPA15A5N1S3TKJBV
 'SP1Q1R96THZA9THXF2F0ZAJ7332Q1GHAPD97B5HF0
 'SPQ2AT2319NV91VDRXV1M6CJKKCBTBJ6RZYN6RE6
 'SP33SA8RHR9J0YWGDYW2YK0YG7GEDR6XRZP1MBPN6
 'SPAFBVN7MM26W3X41B509BZD13KNQV03B3PVEXG5
 'SP166YMP1WNJPF6HESB56YAKPN64JY1AGDA1627DE
 'SP3YFAY7620YKQ1MA3BFJS31AH8SWADWR81SZK6GX
 'SP3T4343SXGSQ0QGBDME836JYRS7JWE5HCC59VGZQ
 'SP33GZFQQGGWGN6RECJK1TSQ84KRESCJM2MYNAKY8
 'SP3EBHKH2V5ZBS98VZDK5QCKSEG3THTZ074SMERCD
 'SPD7RK3X2AF8F9RRXJE4CRJWZYJA3E7B3ZZJ8RDG
 'SP3TSS9Z04R4QXQP6VWTPGW07P522FCSYPY123978
 'SP3TA7GXVGNKQ3KH7R4EQ2M6VK3TNWBHJ5DAP16K
 'SPB13MFVH79TAQ61TJCAHCRQBN4S4DMH5Y7VB9ER
 'SPJ7CRE1FN68VP4B9HSDPTHRYYHG84PMA12Q2P0N
 'SP15G5487JXJP9NRSCJX6RZKMYQHB0A96GPGE8AYQ
 'SP1C9SDT4T4XKAZEQJEK5YVSTDZNNQRD1VH1780AR
 'SPKW4PEF8Y4KJT0GQGSTBSFP69NSKJQXAF5MZN3Y
 'SP11270JK5V2MVFAY8HYQ12R6NTM6MWN94XTNZNN
 'SP211PFP9YN90JRCCCDF21TZ6SB882KVM52YHTS4Z
 'SP5KDZBX13T1AGBNXYWJPK38GVE27965EEKDSPSC
 'SP2AJQM0DM5H86T3YE3CWQN0FBVPGFMW0D92JX8R8
 'SP3VTB9KN0CG458EDZVF26RS6CMJ9AG9S9VCX7GRK
 'SP72P1SE8605ECM4KCXXXYM1SQ3RRR92F8KR4FA3
 'SP30HMWB6PM0CPJWK4TVFVVXVYM00WFRP8XQ6Z0CB
 'SP38S9B9NQJNN2G3864PZK30BH4C4EM4TX8G81FQV
 'SP1JV4H3C2TN58XP4QSNRDVA9WTJA1HHM7VFMQ6G6
 'SP5G12HMXVSQCAQ84JRF9YRSZ2KFBRK8R6VYZ7GW
 'SP1605XSGYGDJ7JM8FYTRSJE0XBFPV5FH33TQBWC
 'SP21P74SC00TWZ6NZG77093DG3MV157SRJDNVW85Z
 'SP30CVEAPVEEJV8PHPY36ESE7J4A6VSHQPJEEKTB4
 'SP3RKS4FD9PWZ0Q12P7W2YKM3455CF17XHA8XQDHH
 'SP35WXCNT25988V29M8GA4MG9AJ6BST71CXGM814X
 'SP3BKD452PMV9BR9CVTX086F2QMA1H3F2Z043HTC2
 'SP8AQGRN2YNVXZ2D43J961WJ1VFF4J762F71GRKZ
 'SPPQTEKMW4HBQBFMWZ8PM9N7NNC80GZYS9TT8ASG
 'SPVRWZ9V487N3CA4G13KT1CPFG653ESREWYKV83X
 'SP1CSGTFAWCP4572S8DYZTQ1DYATB1YZEAFSJDS93
 'SP13APZEH9SVZ5N7M12AD71XYC83D96Y3F1YMTZAS
 'SP354SDJC9RMTP4ZC4ZCT0AB362XR44B74G1SN33V
 'SP1C1K3V42T0ZKFKJBMYH7Q6QX9H4XV48DJCFAZY7
 'SPQS4AQY7G3ZE17BJ24FRMS0A2H0T1R9PCS3VWPP
 'SP1VBY36VKHF9ZMQTFMVNH1S2VB9SAE48G8Y46JAM
 'SP34XY62X519Y1FR3T8HJM4NTHGVSE8M7Z0176F57
 'SP3TJ9JXY9B9VK3C29ERESE8CKMM5GYP0VEF7GQP2
 'SP3R6AHE765A4EMTB03T8SQ4Y9XSA82346NKCGNB4
 'SP30YRVSP4DMYDCHAFDFS7B0VEBYVKJJ7Z5DCKWK5
 'SP2DYBQN208DPMKHEB0V8T4HS1VGC0FD31DF134HV
 'SPMA9JV6WENRB8PWWD835YX7RTJ4TZBDN7FGCC72
 'SP1TXPDNM3WBCSZT1NTHD2A93CM071PQRGWY4CW01
 'SP2S7Z5QWWEG9JXNK0P6VVTJ6RQ9K6A8D8HMKXKXQ
 'SP3AZ26P83BY3JZD0MK097FGMH98DRYWZN53XZSEC
 'SP3GZ0CMQF5VHFT07S8WVFDZSAQGZK1P94XP82Q9
 'SP7ZEPM59VKMBQFF65H7R9810V6RSB3Q6A3ACWGK
 'SP18V3TRF4GAQJFEMF8FYWW9XNSPVVQ9B9JGVD3QM
 'SPZZJFZRQX97S8FQ7M2EG67E43EDPA7VPKP3XKEQ
 'SP21H3ZPX2J14F2RF3C52GCG5T90FBWD0CKCTC9P1
 'SP27G60TMQ6J4X11K2NBN7BNMHMYHFYYDPGYXXBF1
 'SP3CF4GZA2FH4THX46XR34RF5VYT6G6B08GNSAZ1D
 'SPTA78CW7NX5JY9B8AYA07N1XDYV2MQ71C4WXBJG
 'SP1G342S5WSCRMKQT7NY2B6JCQDJP8MPM0Q54ZF2J
 'SPZ7A8MEYDCA1RFW3WM57SBP31N2P1EWYHECWZVH
 'SPKVP0VC8E3P02HGCE9GH9PHMQMPD7Y8AGT31416
 'SP2APG0ASXK7BRYS7PYKPZ6DJJBVH2NC92HRV8V1A
 'SP2QK5DTDN60ZD97R3NH4PW59A96TB39DSXPEWSBV
 'SP29CSBSRR1AZ9XHGKC9NZARM10SS39M7XGXE2FWN
 'SP30KKWCHBGRT7G12R5ENM0NPNBY5MTQBRKV3VKEB
 'SP2EHQ3GB2E5WXVQ2RKJA8DMCNPCTT4FB1RTAH8YK
 'SP2FHPPRCAK9ACBT7TTXHZ16CH9KGS955XCDH40MZ
 'SP2S08H3BBAK0GM01NBSMCN7Y5XY6EBDCRVS6A2DN
 'SP0EZ3Y5SP58XD2BZZQ02MXQJCNYAFX3P32K7WR3
 'SP2BB9Y221BZ7H2YB4VGBP0G14FJT9X7K88KZZVZN
 'SP4TZX0KN0GDN6HCFSXV0317C3WWKNEM0SGV2H8T
 'SP18QWM087PHZ69QYJMNNQC6Q79163XJQVSGBG3ZH
 'SP1Q7XK2CDX52TZTZD4AHJ3ZVF78X9D7W9BG9SJAM
 'SP351S7MP64EEVBPJJTA3PXGSB9BDY54TFEAMY96C
 'SP3RH8QV6YYFYZH85JTVE2YRB8VPNFQSPXB19ZA6R
 'SPAYXN3NGYNT18QFGTMFXT33YJ0JMDGJ6JWJ5BVS
 'SP5WV1AT5THB3MRPXW6GJ01T68W8M9N4QYC4MD1P
 'SP15GRZWFSWBS3GGH19JGZMB2E1QR66BTSGXY60V0
 'SP1GDX27G90RCEY1VZTP7KS4NPRTEJ5XFRDD3M6PN
 'SP3H8VZ7SHK2NPT2DQS7MF7K6T979EQQ8MBF93M61
 'SPQ8PEE1SFPAKP2TRFYDXXQ67TQ6ZBXPPWEGAY0M
 'SP3V6RFD57HZ2719D39DH8NDB5AMGQSCT00EB079E
 'SPXV01FYJVVKANAKXWCS8BX0FMA2JKAWEN9VA618
 'SP11H20VJEC57WYKVP0VRKMHZBX0N3D8FD55YB6XP
 'SPP1D6SHK394JJB7P9V792XG8J6MG52D3EDMVA01
 'SP3G1JAPQXW3WJWS1YX6HP7S1BBKHDXMWQ98S2NXB
 'SP2AB46D01GZF6W9HCPXMPPG7Y25E2W672P7VKG7C
 'SP3JDHC43B8RTMS1ZJATQBJEHJRZNPB8GPVR7Q7B0
 'SP3JD8MANF0CT6BXGRSDYGQQ2YA02DZJDRHA0E6CZ
 'SP36DJHTEJ9C62WHMH3WQV0R3ZDVFMD30MTWWDWWH
 'SPJ3WZF17SGD4045H6DFJ29BB6RMA50VJVAVENGG
 'SP3ZS7KGYV6ZZWR0YAG2N6D4TJ7Y9XSP8N4YQVDPV
 'SPRKYBSSKCW17GC6GX5K072ZAAY0X1PWA5VVEP0E
 'SPMFZAXZ8AXCR1RZXVME8BXTZBA6J5K4R1CMBVV2
 'SPE46PFP93SE4DK7GA99AHV9A7T94HE03EJ0PH4T
 'SP1RC7MYCB42042KT6NSRVEECRJK04GEFE0VFW9T5
 'SP2EHRGX8T617CMPYT2FDKYKDFYQAR1N9S8Y7FPZY
 'SP33V83YSGMN0TBCG6XZMR9KT3KCYEND757FSSJ3V
 'SP31XHB0Q7A2KMWEZ43NPEPT17Z3WV05RZJTZ46ND
 'SP3H9DQ0R15K7FAGR8AQ1NXBTK1W135CSGG8G6MRK
 'SP2PAF1DD280QXQP9C4WNAYA3YY331B6G3TRJ4XCY
 'SP127CMB7P2G7KR9S3W32JB8HGNNFRK61WEA9VXNB
 'SPD1758WYNC9C8H4J92ZGD5ZN9ZJT2SC8WH04M4Z
 'SP12H4D3F93BSRR13S1PXGWRHJAMGFDJA5EZV47AR
 'SPNPJ6Y5GCJDR6D6B4C94KE8C7Z4DRT8HHT81Y0N
 'SP39TSD45B9Q8S3S293NTAZ32ENFRZTBREMR4ZTR7
 'SPS32J3Z76R2QN66AWC9CS8G2NCW4X9J5E8D26ZS
 'SP2PN99PMD7V73PSGG9WKZWSQSH5XY4C5R74VKT6J
 'SP04GTPTJJZV83PXPK21ADV195Y3SNCYMNDKPJ7Y
 'SPE2X9X6VRYX2872PWQV7RGTXM3YH9B80TQ8NZBJ
 'SP2E290TNAEPXEX7AJTD2X0C6X3QM3HD84Z2R9HT1
 'SPNHVTCJVQ9563XAJQTV3VXK9W38KTYAZX94B01S
 'SP1JS1SM3F2CZW92X2RNWQPYCY6CQ8EHD2X7WKJ9V
 'SPKC6PGFS6T66YJR9RZ4XXHVGGE2S2GYXV2A2AQW
 'SP1MF4W0G1DYXCF0WJATM55K2WFKCWXSM09DEQ253
 'SPEV0A50E464V1AK76K9H2XZG7F5NGW5T6YMPG69
 'SP10GV4MFH29SQEQB2ZK1NBBNRCQSTQS5EAE2MWTR
 'SPXT9Z2Q2361P078A66HQ3P2A5K5300PEN1D9S88
 'SP16K4ME6DMN5MQDVY5K71SC168014GPGSBCHZP9E
 'SP1S78KEPD07D4HNE7EFE07R9T1BW49P2DVW3RH7J
 'SPK1GZTZTG4XWH5XBTKB74FAPB8BERJC1CYQ231Y
 'SP1C4CE1NDPGA5H5T3D82A8869CXZGK8QRMYP594M
 'SP3K8774VJN2EGZ4C6B5NC33X4ZXPE1WKEFH2NNEE
 'SP3DWW9X9Y4T5RCYS84BVVXFDFF6HBF88JDQQNNW
 'SP1TJGR2Q7FVZ4QDHJK8ZDRBE8C7FYDNS1K0DZ6CT
 'SP2E0BGKYVPX1MVNECTKM6J7VP2JYH4TRN3KXA950
 'SP3YAVW8T1BWX79VF5J2TRGTZTK3VGDMTZTYMY5AW
 'SP35NXD70WZHGJXDVJXA7F83KPKQ4RVKMHFRQ6DT6
 'SP1SMF6H4Y3B67ZPKCS5J2P0J8A0ECR98YF07RM48
 'SP3W6S2T1MSDXF0HF2V8KWJZEFNAXM8HQZB5ATC50
 'SP1YHNX2MT8QER62EXKS5CFNF61BB5MA5B8HB9NS
 'SP1802P2J4RC02WW7YZZ5S7ZYXFWTJY3R9T32F63Z
 'SP3YP566MVXQDC3ZJQT69B9QT49YCHCYZ9NVTW2NS
 'SP1X9HAM930KHKPKHF3F44J30T3HAVXDXJBT0BX4W
 'SP15QMGQFG718HFGQ90NVJ1QTXDJGWNGM58MJ79G2
 'SP1TV1339KTFWB663BVWZHYVFN948A3BABJ70V49E
 'SP631VEX1DQ5N8Z1CRB40P30GDX3GPFZJFE9CSHN
 'SP2F8ZMEPAN43EDHGN1X7SFRJWSSQ48THCJNEF0DR
 'SP2JAWRXBJTETMYFRDMVT11NA4MN5DWDXX9928NY5
 'SP3SCDK93PJ4KW5JYYPZVV07PAZ6XZQPQ44F7EV4G
 'SP3AW75VT4VPGT2G3PWSGGBE1ZR4PKZVEV96AAK7Q
 'SP195Q21AEE0E3D97F5B4ADZ7308V555FQA1S7GZ3
 'SP3Y4Q6YE58SJSWS2YAM2402JHNBJNH8Z3JGN5GB8
 'SP2TVY4D4XJ802PCDH776Y3Y5Y3CAQY6F42YMSBN
 'SP0864CFTZ2DR8FDCA9PC03AACZRQYWF5A00Y8WZ
 'SP3Q8PWSVZWEP5B2VX3734P2XH3583X8HJ6PJQ37B
 'SP2DKCVJT3SGXYQSC2Q8QEGACYA10B4RM81S4H5G4
 'SP1RQF9SCJ5XDDGBK56ATPM3QZWGHF6MW8X9K39EW
 'SP2S60RTV47KNHVKP5H5NDNRQZ5017TTS7NHAQSBY
 'SPCQ4MQRKK2PPX2MVZ0NRHPGZR5F5HA0D0TXJX13
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

