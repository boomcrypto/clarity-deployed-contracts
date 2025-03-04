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
 'SP1FRV07JWJCK8EJ37GM5SP92C9FXR5AND211HQC3
 'SP2H8ZJGRAMYYKQ9JKGS2E6KAQTQ7B328A9RJPMQR
 'SP17YG5A833SDJTSDKF1YY09GBHC2PTY22S0N36FP
 'SP38F139KNGWV4GNPJYGRFHM0MG4NKEJ97T7ZTT41
 'SP15F5VKTQ2EP4DTX8DP89KZVM65AHANGXE0RM7NV
 'SP2EDRYCPGTS32HZAGWV54RAVA2GTW0WPBP4HGCXR
 'SP3XBCE7R73W9TPWSM3B1NYKHYY9P5K81HE0TWPRP
 'SP29ND06B304CCN4HQDVN7T1DT8BRT75D6VBF28T6
 'SP2P7YY9N2TN0G8RZ2ZW1EY19P42NKK24YFWTSSVT
 'SP3WV7W60ATCSRAY8941JT789A0DYVFQWNT1N6NYH
 'SPSB6PN15X97031SMTJBERZ8T2H0TXG255XCV59V
 'SP1FXCKY6E03H7HYKWX8Z0DGJ54YDK5CQH1EDSAJM
 'SP1MK4YCXZY4RM257C61AARJK4H2ZBSDD5MJ038RY
 'SPEFCW4DY382E1YGJFZD4DQARNWASE5CT9P3V6YV
 'SP16YT2WWWS8MY3JXM3YVRW6TW1MG8DN22Z3HQRCQ
 'SP12VTBRY3M9X3HKZH1ST668METTXR452V29XF7QJ
 'SP1R0R6DC3K9E1N7FW8K0C78KE2QBGXRRK80KTBFN
 'SP2MAE1ARW7SACWKFJT49895752EBWHFWRMT08K1T
 'SPBN2RYDXB4231HJ2GHFFRGQ54X0SBMHFVRAVCW3
 'SPVMKK8WC9FB93973DYD3SWWT4X4BHDN5XNFHH29
 'SP1PSHN13FD8EJ302QBCAGT9MEW975ZQ9SY2Y3D05
 'SP12F5H16HM28TVHJGDH7ZHRGHBE55RG9KMYGPHQJ
 'SP1TWEQRB442KEK8WS27R9BPADW5CB5JGW9J2KY7D
 'SPQHS93G4QBKFEYJT9J5D07XJAK760095HE5J03S
 'SPPA2C4X2YZ8DNVW241ZZ4FEH12SWE1VTPF8SA8Q
 'SP2YADQRAJ4468KEX4CYD4MQPF0S6QYFT5BRA22J0
 'SP1A4S4WTWKPYWZQ946BG4893J6JP0N2GX7NT1QCY
 'SP3PG6WX96X2QAYCA70WVVZHBSQHMECW50W9AMCV6
 'SP2277PPJAZDPPN9MH9ZDA1AJ2GGAEY2BDW09H1Z0
 'SP2GSEVPVKX2PX027NMCQK74XH5Z4FK3M7K62SVCE
 'SP11EBWRDRHWHWBM8XMNTD45VM5Z41XM29TBV7ECD
 'SP2MZB9A4JAX3QXSCF63F93HP3FVXJHTZJKY8N7K8
 'SP13FPEN3GP72HCFC7R0306DJFCN15G7E3CXWZDJ6
 'SP2T5ZS0WA4BP31E3CTK5GDAY3VKJ1JXSGHDQZD66
 'SP2WJVEFVCYCQ128NRP41SPWVSJV1CJHE0PTKC0QH
 'SP1MKKX1CDRYNRGSA1E1BE4C2Q63FK27K5ZWMATYE
 'SP2WHGX98J57PV22RG15VSYGYQQJCDWCS4NDCRZS4
 'SPHNEPXY2N25RTB6BMJGJXAH0XSHV55GZB2FC69D
 'SP3JMWGH54DNFHCRZ82QQVX64XFY7P0CQPQMVKRD7
 'SP3BBDG6D7KC254H0C7RBAPDV3GXK5B0H668GCHGF
 'SP29RKAMSY8HNDC1VNBPWJVAN9C4CKG5J3GA8XJB
 'SPATWT835C0WS9H6JXV4A3CBW397ZYJCK1B1SNZT
 'SP3KDJWBQGBR0CZFJ3K5TQV60G05MBB6ESPCQ0GVT
 'SP1VK05GCEXC47F14DVF6MDK19RYZJJKR3AM0GCDK
 'SP1C5M5R31V8KEPTFE9TRXZXNSH3K5KNGWXJSF4YQ
 'SP32ZYEZGWHHFQ5RX2WMFVDXR77C5WWQP4EK7E6HC
 'SPVQW7M5BBPP05C36SZPYACHZ3NZ62N58BNNGEDA
 'SP2G369JC28XY3NHWBTX5JQ6F9QJ4BK7S2W0CQSC3
 'SP1TRMTVW882W2M7ED9AQ9E3T7YAR47CW3N83AFN
 'SP3X9QKYXQWY5HNX8KVE1E5N9GQHWHTBQ36NJRTED
 'SPYRK8D45R4CDB3K5YWP907NC0P4HC8GQKF6EJ9S
 'SP2NMG5CCPNE8T4CTSNE6NAGBNNSKQMZ71BY58FKN
 'SP31XERSQDEADYRCBPG5B0JQJ1CWTX8PEFAX1AV25
 'SP169RJ2B9M600FQVYBHESNMHKVVR0NPESZ6VGGBY
 'SP10ACX3A54PFCX22J22JASJF5EB354KYQHK55Q7K
 'SP235T4QMFY3SEFMEMFTXF36G840QFBVTJJYJZYEF
 'SP1DKM1GC9T7W7RH2F4DX8EDVVQSH4JSX858ZK3DC
 'SP1HMC0Y5YPHJVRN7VS3XSKQK2F9061V9W4Z2M8ET
 'SP1YXKQ5R6Y0R6RMW6DA64S08RD0D8MQGNYRVDJH8
 'SP3RZF2W4YMMQX0ZFEQY8ANW73WTYNFKCD9BACCCH
 'SP2WRX7ZAR4Z1SJ5V1NHBXZHWX2112HATSDV4R0Y5
 'SP38GBVK5HEJ0MBH4CRJ9HQEW86HX0H9AP1HZ3SVZ
 'SP9TDN2WENRJYA6KEWZHZ8CP17HSD5KR0ATC72DB
 'SP31RM6SWEJ787WADZPHGWNP7XMH463HCX4CYX96A
 'SP2Y4SY8QD0BZ49VG41V274HPWJA7M7YN1XKQ2M0
 'SP34AMF2BJVABM45DAPVM1EMQZWEN6MECW41SHTE3
 'SP1M2KTKG2HK0ZAKVYTEN9DF7Q00KC5YMDWK263CK
 'SP2WS5H3ZSDBAYZM2WFDC71CNKQ8P91HD6JN41R8R
 'SPY9Q896GJ209XKATBPBZWXB90BF369DD2CM7R41
 'SP37GN4JPWNNC8EQ956F6K76MCPVDXSRTWY4TK6A1
 'SP218TBV9HWW8QQRARHQ6XK7G10271SQTTCCTHW20
 'SP31YB1E2VCAGW2DKGGNH82ZEYCF7V3P7CZ61N89P
 'SP1545TQCSD9VVGMCTVMV5RAVKMS8S7PPDJSEV3ST
 'SP12FXX43RDKMHD2BNQTT6XYQX4AMEEG52XT36N9S
 'SP2RS0YJZ2QH5VYXQ91X06B9QYR90BNGJETWP0V69
 'SP3WAAYXPC6WZNEC7SHGR36D32RJPZVXRR1BG0QSY
 'SPNRFFS6D3VBP73MX95S397Z9G6X74X4281C2TPT
 'SP25FAA28RK4TAPQTVMDQAMEHC85T0XCE193RZW5Z
 'SP3F299JV1TJMCKTG0MTG2PKB246DF7FM03NSPHZR
 'SP1M2KMGZH26GBB5PMMYQ5WB06Z4BTXJAJYJ77DE9
 'SP7TYMCHNJJ0F8FQPXSN2B7TT90V9798G2PQ2CN3
 'SP179E4TQEDW24975R88Y8KBKBG0AYJ3GK9FY7BCF
 'SP1CMAZ4K4NW7GSZC3REXJ1P10GX1WBDB6MHPGDHT
 'SP3SEXMGJ2CX2RBV7DNHKV7FAWDZJ47ZVAEZKWY2P
 'SPZ6RE4H52X8MY6PF88YREAC27YWH8WA57K4YVX4
 'SP3NKSPVD9RAHZ8AJ7492MRMFCS40JRTWMCYVWM6
 'SP2PGM6DJWZ9Y04TRZD13MAFTVFBPKW3GRXJZMYZR
 'SP30DH6N0N3CFKHVE4ECMFDS6T5VN9VKCTETW8BV6
 'SP28ZTJS8Q58ERK8MDNFGQA85CHQRP4SYH85B95SG
 'SP3Z3464AZ64FCNAN4CP0XRAVT18B1ZJ0ECS7TTKY
 'SP2K0VG0Y0V5CZA7YBNN07E6A3M1N7KM4QB8KKQRW
 'SP5J8R6KKJ9PJ6TWFTXTG4ZY7BMABCT6KN694WV5
 'SP2TZE09GHARKG0B8NTT9X77QXBTQPQ2J1579T0D8
 'SPQZB84K0ZW6BNAVWETXHY6THQT1RYEMF930QZS2
 'SP143S7QJWE14EYGVTC99HGYEMG70YVG1RT81KA1A
 'SPFJBA3PWNM7ED1M3RJSX5DYCAXW94Y0FQ72X096
 'SP25K9JNFTSTGFDG89BZT121CE0S1DZP91QFHJ0W5
 'SP2P16WNCSW310V6T76Y6A34HRGXD7EPCSG36X690
 'SP390HW8AGYC5KNX81EDHXSYJJ0QGX6DFDG4PGRSZ
 'SPCAN6YWKEVCQMMN3K0D4P95KXMRJS7S2KTN6BXQ
 'SP1Y7GQJ3ZSC8MGGBWXGT23V6R1QYR98WW6ARCXJ1
 'SP3F6KXYE41W2GBPGEZ5Y9CDGHVKG7CT97GY6G2NF
 'SP1ZCA2YV8TGX1NCJ8K04P5WJSGJVM1XD44APZD9Q
 'SP2PJQRYKT9RD49852K6KYZJ5NKN4Z73W2Z0R3G0K
 'SP2BMZEXMTM4CRX961B53GBY3QANXDXK3MBY8NZ0V
 'SP265MKD6DWYXTMZZ41DEFQ5M2HWJSQ52V26WFWRF
 'SP3MW51TJ2APKCKVY2HT3J133HJRAP9219K0PT2X3
 'SP2Y55WKSPB1ACM5RZDAKPDKHECZJD4GZ4V311NP7
 'SP1KWR3XZFQCMGXYDHNSTPPXFHRK6N0QPTQMEXEM8
 'SP9H6RW69EM0APP2EMXC1C8ZFXEQF7P0H5D6BMX4
 'SP2X4A0M71D5W136FEJDQ3C4FD7SFR8EBQ45A3KR0
 'SP1WQAB4ES6PNN3D115XAXGHRPRP160T46NM9ETH2
 'SPD7MPRYTT7SGBWFJHH4HETY37TG2F49J65VZNNR
 'SP36ZZ7YKA9MK3227HH7MGBEBBX8N5H8H295VJAQN
 'SPZAZHB59ZPHTAS0H72H7517J9B8092D2MH7YRGW
 'SP9469CHQ3SZB16XX7YNM0QFEQCD3WA3D85CP6C0
 'SP3ZW40EN0XN0JVEKJ20656MSDV1JB4Z80DG6FEK3
 'SP3WJAT6QM4DBQPEE4V36S6MKEWT0P0Z8VX1B7RMQ
 'SP18JYK86ZBZSZR8V4ZT0TXVAS2YXDN64JED02RDG
 'SP26RX546ATF5ZNFFSB041NQ7ZAE4FFKDDSDBB9G4
 'SP105GNSZG9S5M6G89K6ZR257C9A1YZF0VY8CVVGZ
 'SP2KAM4A6W2F7NNSA8W21WABP0QW5WANZ4QK67RNR
 'SP3RRGMNH6NVP2NNKTN9QQBVXWZJ2H9XDP6Y38GMG
 'SP19B7JPCGVBP2TEZ32FYHVQPWD9JGVGVBWZJNFCX
 'SP284C79DJQ7TZWTE2GHYS19H8AMRK0FE41NP0CY4
 'SP1K4AT7KDB9AE2EBRNFQ7M5VK4AW4N3EECR114Y0
 'SPARHENQD3QXG6VTHPNQBXSA72508JZZA4NW7VNG
 'SP3P1TCXN3FP3V79YWXC49F5X2HYKS39CMCP5FEHN
 'SP2NC3CNDTAWBX7RY739TK03XF7H8Y6N05MV10BYJ
 'SP2Q7JQCGF38EP2WENTW0VT9Y771SQDGMPFH7SAQW
 'SP2M7K3YM8813404G1R7AXV106CPWH0Z5ZA80JVAV
 'SP17TK9D2MWWSE1GWD3Q8SFT5AMT8TTDGQHZ023M6
 'SP3CDV7032X3GM01SXYSNXSJY7EG5XG008W21A7HQ
 'SP1H5Z2WN165X46EQZ41EB9XXZ9KJ98S7CA1YP16G
 'SP1WH8C9SS79X25AWTDA8XJ8HXT389353343BSN2F
 'SP15ET57VBMPY2F9K6CBDMCC3V8FJSV58VZMZJ4ZZ
 'SP1JBBGYFQ7M19C2C8N08HGP3M57NZYE3QZKKT79K
 'SP24ACTWX0M8A3KKC3GC5Q8YGFA0QN6A3ZG94156P
 'SP35CVHQMZP9525TPYZ7R5W5PKA2X8Z1HBRWZXFXA
 'SP1D4EWTP39DRRKNAAH3R5176ARFZKB08W53TJP1G
 'SP2KCBMBNT182VVTCTDQC1404S3NPW12W8SS4CAJ9
 'SP3V540F0YRSZAJXEV4W53G8AQWA1JPDWNJQSRMHA
 'SP1HWQZYMGSS457QFT9ZSTF8ERSF85J6RVCTF9VNV
 'SP2A0828P02DFE5ZMWSEBDDTB3V96EC86QZ3ACRHY
 'SP2A5R0RPA43ECZK7QT4KMN22XG6XX7100ADA0R68
 'SPVMY3KNEF6VZ6NXG0VCRR88XGZQ6AQQWB9ACWP0
 'SP1DTNP1973ZGMXPN21RBB4P73Q5G2H4JRMXN35ZR
 'SP2MV2YYRABTMK176E2CSJP1R3CVC7MS4HCN799T1
 'SP23SAQK5JYCEGN5NG836EAWZVZ803YHSMXF6APMH
 'SP3CZCF7H1AFSX1AZX2R0BHPEAMP8QX9NHC8KRNR6
 'SP17CXRDR9C62BD41TS5XNXKPZ0P97JBEFSSKMJC9
 'SP2DK6S5P9GEQVASGYXC98Y85FQ49J2ZGS74HH6WK
 'SP37JBA3QSWYHR7HJMSKMJYV7ZYRKY0SGWXDT1E0W
 'SP13EASTN4ZCNFE635X6SNQ58H4NGHST1EBTHG0SF
 'SP1N4RJNMF1ZW1PSDCNNV37GPX2GA2ZEZF5ZMSSTX
 'SP36H5MV2DCRKYBXAZYZ43WB6N245K80NCJGNAR2P
 'SP3E73RS47DP7YPYW56R5VTT514JQQNE1Z7PEV224
 'SP20B4G0S7V5M7PVNY5AX139VF5EC0BXVSWJA2X38
 'SP1ECASSY1VNPYT8MDGYQZYA2QFC98NTTQ922839A
 'SP2D21TSA9RB2TXT67E2A0K76JVG1NBEWC93FZE8Q
 'SP9BZJYW2JRBP3BHHG3SWNNSYWFQ1QH4MD0XWG9R
 'SP1M1NJ68Z3YT3M4CWQMVRHDFT11GYPG689M3WJ1V
 'SP17NDNV75HDMS64QJ5ENZ40JAP736RHJPHTS0A0K
 'SP258RY1JPHAGV2B08CXR2S3CZNETB3HYQGJV9V0F
 'SP34BD9Y4F4VVJSVJSET42CWKW6K0A81D1YBC0NVH
 'SPX9Y1MWGE9BWSNZWW018XV7MD9CPZH9X2JF42CR
 'SPMAEPTCD1H89CV9FGZE16MT27KXM4B0R2AMJXW9
 'SP1KMQAPBQ1M4HC8N0FYJ4ESJ7688HRSXNK8682QT
 'SP1N4AD8N1HXNT2KFEFH3302JK504ZPGVERS6AC4J
 'SP31A0B5K60KHWM3S3JD0B47TG3R43PT1KRV7V53B
 'SP18QG8A8943KY9S15M08AMAWWF58W9X1M90BRCSJ
 'SP1TGQMX1GMBQVEB8DXMYF312HBJPKMYT27PKRXN8
 'SP1AF9R3GCMFN280M3MVKSJ4XYC6EFTSCBQ6ZC3NT
 'SP1JC4S54YG0FQ71FJ8BC1BM8JWR3968ZHVKRVXBK
 'SP3WT9PV5E28VBHAN7KV2BTHCA93SC9R7B64MB043
 'SP2EW8RZN4EE9ZWMXEQ2KTXXZP1YK4KJW0PG2D3K
 'SP3GXRSVBWTVS7DNK466APX88XZKAB8FT52ZQ8WG4
 'SP2PJ2HWWTP3X78J9B324547GVH2H9TR4XCF901AX
 'SP37Q85SAPYZ0E53HBMG64PBSWA9HZ0P7RMW5682H
 'SP1F7R01W46TF73ARYCBVQ92QY7X9T6D6SXF5FE7K
 'SP1AF7TH2DDN2XCFFEVXKF15VVYW2X68CDQW3G4MK
 'SPN781D127KF9E600496VHSGNJEB2VNTR5ZFSY9C
 'SP385CENFX0R0E7D5S6QSJ90PDBN50HANR6K9K4X7
 'SPGV9X2E071QJP5N65V8PY69R5CCZSAFVRNNXGK1
 'SP1YX2253C74SBWACJ551BJYE9QVDK64ZWAA2D3AB
 'SPYF9PC72BSWS0DGA33FR24GCG81MG1Z96463H68
 'SP2T9SHEHFTMKR30FAZCY9Z7GYB874YRRAR02B1PC
 'SP1BFYVSC1G8X1YRCJSFS3A32CB5WDS033PE46Y55
 'SP1P9K14JNEPK2ZRKQ2J9P5ZXWQWV8Q1H6HXEJQHF
 'SP375AE4B6EWDCE852X1RJNQ5NDNQ01RF9WRC05SJ
 'SPD8NCE0DHXTQDN92C5K44YB276882WW32RM6NKN
 'SP21X6WYC74YN28WH2G3RJ7HSGS161DVEXZGS0FVX
 'SPDCY9900XG7Q86KXMESB257V6EAD4VDCP374HE9
 'SP3DPXHEAQ34YVNC7NADP1BSYXWSDTW9KW6PGTAM0
 'SP25DP4A9QDM42KC40EXTYQPMQCT1P0R5243GWEGS
 'SPQ9HXJ0XJ84QXEZACDNAYE2C6T58WAYW6MG6N5Z
 'SP2KW7JS1S4F4FQD869JCCKS2QC8NZJWBPFFMW6R4
 'SP3Y67B9J4Q2QA3VVKYFHW35X9TDZH44WNV2G8QX3
 'SP24YJDP5R2F4BJNR3EMMFE3QVR1HJ2T6XPGC1N7S
 'SP1CAG46TZ53DT0EP57AMRPJDS1XX3JKBH2957SQP
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

