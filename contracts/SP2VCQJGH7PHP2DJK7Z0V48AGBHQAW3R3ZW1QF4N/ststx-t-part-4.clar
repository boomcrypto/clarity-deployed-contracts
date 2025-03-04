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
 'SP1342DAV9ANVMQMF5GWYQYJD6GXPT5EENP29CV1V
 'SP95NXE5T10VAHPJPYN43Q3K9VG8GBNM0G1DRZDF
 'SP1R9KP5R7GGM8THF6SAG875GBMAAY9S3SYF2W8N7
 'SP3ZWD38S48NFMKB61KCEHZVX198JTG2TV6XX7NP7
 'SP15BWFCTJPKJXQ25MSCDTXHXJSZVK6WKFK1RM8KG
 'SP3JD29Z4QV1P7H7BQY0RSGQPHBT6A6KZFH1JK2PD
 'SP3K6VMHJKSYH0JD181DHMR2VH7VAAPGBY7K14J3J
 'SP2545F4STJZ6N1637NK2Q0P0158Y57YMWDHPC5DB
 'SP372B3QPFAC65VY7R68GK4Z8WNRZ74NRWGWM9W4F
 'SP2RFGZ9WWXV3CZAR9QR94FHJ1WVZ59SF8J6QEA0C
 'SP33FQ9HBWJ8FRH5GNJEGTZCH3C43K9QHS3QAPCFF
 'SP1F4NX1QJ5ABHDRH6PG6GP5NFFY9JPQVSRTX7YT2
 'SP67Y9M4M8HZ094HC3G0VG9F4A5ZNW5A3AK17322
 'SPQZ94RC1JB4YQYDD17WSH397G83RP21G8Z9CHSM
 'SP23ZSH34VFD9WC6FVWYNKJAVME1SN89ZWHHR5NCC
 'SP1ZPS1ENZ8KXXMS960DQ6ZT3AQSB7BWD2W6P6297
 'SP328G9XY58KQ04S3RPKPR42V4B13XVAS70PV1DF6
 'SPQAEDJAGGMB2JBECE5XD76KJ6RR8F4XJ4VVRJTB
 'SPJJZHS9GS25CXJ6KKG2J1AJHQDX85PCC25NZ65E
 'SPMKYECR51RWWGTT3CVR9X81ZKPC611ZQDZ2X672
 'SP1ZZ247SM1PCK3B0G54Y3Q4C8CN9K8B9J0JCZT5Y
 'SP1WYX7K5Z83JK6WVAYG452K28JM1Y5JH6NH957RN
 'SP3ZR7MK6AE6DFR243YZS9XCPS92XGGKN8538WB62
 'SPQ2Z5FN56CAQT0KZKFT533XZ9WSNHG49DTQP1ZW
 'SP2FZ6G0YGD5JN9Q7GVH2WBC1B2GJ550H99PQ2GN6
 'SP2QS4K4Y30Z7S95TGGCNYGKPPRZ8JCT9YMA9YAJ9
 'SPG65R8APPVFPR0HVGVRWJTNAZXDDCGY7VF73Z09
 'SP3T4GE6V1Y2MJ0EMTMC0FKHMX27S8YK8KGFEX7M9
 'SP1RB63ZYA50H6M96SHQFWRX0ATQPZ07D5KNBJV0A
 'SPFJJQTRGYA8H4S14D7GD6MTP4KFE324AET54JEW
 'SP2P2F724HZ5RGBQX50KC8KR9XVWKFK9W8VPQM3FZ
 'SP3TZHPYHKBG7RSMJFK72EQQ9N9JD5ZM614QASC0J
 'SPEARSQWBDXAY1138PDYNPPEC0W9R4FRX478JAB7
 'SP3NRG8DMXEPD4TMDX18PZM9PCPEH36QEZ83QDZPT
 'SP2V4V1T2H7JEJ6GCVSS0CWSPADH7VYPJNH8FHWRZ
 'SP3XVKFHS2Z6Z8PHB08PDDZ494YKNRFBVWS9E4RV8
 'SP15XYF4M7FN9VFT79YBKNHDHGRZASXYA4C9RXY3Q
 'SP1GP81BHTQN13KEKHC8DJWQ1WMMD40BSKZT3HQMC
 'SP1M71JK52GZSZSTXT9FSGB2FHY8630WD756VV97D
 'SP3RN7H52GE45T5NB3AH7GYSBGQTM8TVG43S6KZ57
 'SP175NZDA6ZPH95SMS0N0X6VYS2WJ1FDDR99739RH
 'SP2RSTYRD7H1AAK530F15NSGGZ0NN2VXRKJGKZ74X
 'SP3W40MZ80HTCCQYAM3PM1QH02NZ48C9D0DJSFVGN
 'SP291XEGKQM2QVXTEK19FS5SX1V16BQG2FNF1723S
 'SP3G2C60QHG9ZNBDG0J519C3QQEP8XQNWD80KD9GS
 'SP30TZGG24XKX9VC60S93TYW8FE3T94CRX4X2DM9R
 'SP1YWFP80QE1GD65MPGCXE509R0662DXJ9ANCKWDD
 'SP242EYG60RDPPY74JSZRZGT3VEAZAVY2XJ37HJW9
 'SP3BSX57ZEH2KA2FKE3NVNA7SZ4QXEGZN29TC6BZT
 'SPW02JA8DY901YCB6VRJNB9YG6PWPE85BJR1EFN0
 'SP1D0M9AKF9QB3JPZ418MYYC2MMD1AVA11DTAFJM8
 'SP35R4DXWZRPMPTSNK0FFW714H9HPWH3R35Z4GVJC
 'SPN7CBF46R1H49S6ATT8AQEA9XMZ304VGHBN4A28
 'SP1TVEF4V22ZDRXDXTEWN84468TPT9K08ZYD23P0A
 'SP3PYWTSJA8X2ANJ0GFAXV8QXTDR3KX5DE7TT1GW7
 'SP1S1ZPFABXAQBF2JNZ0NGF0KWDXJJAE8AFNJM568
 'SPG7YJ4X0KCND509CM00S8Z0WEVW04HP945NT1CB
 'SPW3QD7ZT18M7QDQDB26ERT1TW4HJCD4TTJZJ00B
 'SP2BGBSCRYQGECRFRP1NCWGBZSHYEQPKH65RK7NMM
 'SP37E46M4GR5X7A1KGE3B3V7TCVWBJCZCGQH0PS40
 'SPGJV10GDNEDSY35Z3BZ0NSGRTV503GEA1ZCTCPM
 'SPQSJFT9T1BEJBC9H7A9KDG3Z6Y4WDS32XWNB44W
 'SP30Z4TB1Z40VQV6XCN20KXCM4SQNNBHGHDC8QYTK
 'SP310GASP6CSA9THSFEJYJZ3NRB6AYFX7CG9DT6CF
 'SPVH3QTX9F8JZBWPVK2ZPW3A07G048XJC2G61SJ4
 'SP3DTRHXJF6HBAT0EY784GDYRHG1YCFZXJXB5ZTNW
 'SP27F67QBT3KD8XW6XCG11KH311BYVNE7M5GTA85Q
 'SP3CRRCDH12KXQMKJYH5N840FKQVH4B7R4TRG1570
 'SPV0MKAK39GMGP1AD4GAN5X7J3F3ZPYJPJQZH5MJ
 'SP3SF0PSD7KYVJQPKKRBYJFF7NENGFHZSBVHM3B27
 'SP13N23VJPMDJF838VTKKN8A0Y53MK46CF3726X4A
 'SP1V0KG71DM21SKGHEDR4X92ME3WF9EYSA1CHF9SP
 'SP8Q4FZW27NZ7B4777179YC5GFGKG003JFDBM6SW
 'SP86QENQB6S45M2BMPE7Y1XJ76FQA4J5Z5WA5D9M
 'SPXH4RFHRWC6FGGSZ64M3EFVY6XBS8VR8ATTXAV7
 'SP32FVZKVWY59WZGS9A6N1ZVN3Z0H5DA4NFTXS6B2
 'SPQBW1GG42D2JXVR2Y794EYZJD5K03VGJC6DKMS7
 'SP3P6JN3G14EJCEAVDC56B2J6JE2NNZMT2Y2GDMF8
 'SP37XZWB0DWXNKMT0172HHMWCK35VBBEK19DN2YYT
 'SP1TX38Z0VH00DF2DXGBRXF7B79NXPYG1B902PDEV
 'SP1PQ8YK8JJYD17G7SW5KFKQ748ZBAFPVSBTK1846
 'SP3TF77S4XWBMZ455YTYWRMRMHTM7AZDM6258ACR3
 'SP3045VHS30MW2T425PMPD7FABPHNTR47HVZGFE90
 'SP132X914XMHFABXVJZMA90WXFGBQEK0BC736HRR4
 'SP96589NZVRAX8JK28BK5BSHCVS8GYEVR4JNWK89
 'SP2S2S7YZRRJV2XSDVB1VQNCA86NQ4YYCXPYVGVFZ
 'SP204HTBQFTT933YX5ZYPJMWJ8SYKM46Y7S92X84H
 'SPNAMJGDVGM3P0E7JTZEWCPZV8M7J2RDWCGRXNN9
 'SP3R3ADEPVQFR7BPXMAQR2KBVRKM19N1JCQHFCA31
 'SP28ZXE2XDBRAT3D77FQCY004V5HWBFJJJRZQGWXY
 'SPFM99G8DR23W1XG6NBBHMNVN46DA6P73A4RQ4FM
 'SP3FZGQS4YTC87PSQGKY43RGSYX41APNM6VQ00SG5
 'SP1XWNXXK29MY1B3WYR2YY9PT68CRK8WZFRK6XWGG
 'SP2FPFACHEAVM7M0E2W8G9ZGGD8QDAS536AX8XMBS
 'SP7XZVVXFFHMMTWZ8WNNKNY0TSHM5FQVJDT707CV
 'SP38PWQVVQF0X1QJW7Q9SGGE3DG8BP80XGAM76HPP
 'SP34BHTHCQK27CY57X8FANVGTHR2EEX4KC85T7GXR
 'SP1S2XG2DERE2G1YDHQBD0NV2E3WTXEZQGW4J2DX3
 'SP1WRKTDAY5B2B1SH5D18TAA1TAED8HX6E83PM2QY
 'SP2T186R4C6RA0CJ45VMFQVZPJF5ACTM8PD9WX0D0
 'SP19BVGYWCHZCMAPYY5B0SBPMMCHJ46DZSJJBFZY8
 'SP10ECZKBTMVGV9Z41A9QQP80TQFZK2QRSV5BWNMX
 'SP30W6DD86PVMF45CBSJS330ZAZ2T76VT36206VHR
 'SP2FZMJ6MNX9KQR6PGAJFVNF0ND96ZMAVRKVX3F2P
 'SP2JPCDDB900AEH4MY3X0KNAJRHSPDN78TN91HZFM
 'SP2AEY9QJD5MGDEEYYTNYBVVS7S97W2S0302HQ7S1
 'SP7QR1PX0JZFJWTYB588K9TY2ZZNST3AJHGT5DJ1
 'SP2DSQ3SAPA28WH5CVWMZVF99S9RX3T4R98Y96DJJ
 'SP2CENTECQ7E56WPVAAAS1BC8NYMBYMA60PTGH8N6
 'SP3YKKE23MAQA1CSQJGWXBKYXMVGGH3G6AYHHBXHR
 'SP3G022QFZ5HEG9TWKAZ8HHV32CAWNVREVWNBMMAP
 'SP2QED6YW7H6VMSN95T8BNWF3V47HB0XYVS1K8B3F
 'SP1EMHSG9FS73TMRJWY679GSGZ7HQ54HG73PD6VZD
 'SP1RS5ZXK8D8VRNBGVA36PRCS2EJC4C0SPSKW7JN
 'SP3CPTZK9X90P1JPEGRFA3DCDCTZJ0RJKM0EFCAH3
 'SP31KC2HG7RSZHMMY7ZTR4SJ63M742WE6QVHCTVG4
 'SP2GZBAPG13T1JNH48NKCSJV24XFRTYWQFN37K7C5
 'SP26VYV7EPF8G9XD8YXVPA4RDMZVEMPCZN1TX40BH
 'SP13K4Z88AVWRHXKMRPR744N8PDWSZR6M4YVHJ1HQ
 'SP3K75K2VYFWCBRM4B5V14NFX5BPDE3AZ5VSTP953
 'SP3GPV7YEVS2VNFYYXEJA4HWXA0HFX4SMFK9F12P7
 'SP3TZEC9PYDZ3Y2F5RMNGFS24D1CDPW6EW8QK6616
 'SPWV2EZE3HZN9366KAN137KZZM4HZ885P323WXFE
 'SP34FY6AWA0T1J1CZGK9JQRFDK5GCV9W0HXG7A55S
 'SP2MBBNPKEX67FR5CRR5MN1F1QZ8DQX99V4H09EBA
 'SP19T36JB0JETZ2F9R2MVWWR2CC8SSJCN0B90TS49
 'SPXTHZQJX567G3SK245R24BW2403V8XAK8VBW08P
 'SPP95MSJC26ZXP48GKQ718FXZ7E21BZP0X0FHVB3
 'SP3WDDBDK6Y91X66BSM25ZSY0F7W0WHGAJ57R6PQH
 'SP34YB409RQYQDNQMW3CBBVHJWH0YMT1YD89B5JP7
 'SP19P51DNENYEM96PVNKSYNJE4Z5705ZJC08ZS007
 'SP3ZTY2CAGNRRDE9RJNNF849S5B4TAVMPA7RNVA0X
 'SP3A7WGTT3G279RR90S6G9F4FNR0H9EX770VQF0GG
 'SP1A6FV9C7QPVET7Z6X26QPYYEVN10PB1R0EZ6W3T
 'SP3PR3ETRNRY4MRTCPAGG2VF7HBC577Q87R0GXQV6
 'SP2QFN74QXNZ8Q1NMWPPEM4F12XPYZ8Y2CQQT8ZH3
 'SP2K70SHMN5M81AJNCCB38H3ZBD2W3TRKHQ2N9C73
 'SPRZXS220A70095JQXMHPT517BGSC9DZXRYF1EHR
 'SP1CEQKZ2E3HJGF40W9Q5KP4PTQNQGMTK7A47K3HV
 'SP2XA5WD2JC3D1H1PMZTEQ4BQ1F3YGV94ATYKMFZE
 'SP9X50Z52TX1EYHGRAM9B12J567W0XBEPK0151X1
 'SPZGQQDNG2SC5ZY8E9ZQXB3PYQJRRWQJ39B43C1R
 'SP350N4SX832092H6F07YKB1R5X5DM90BV6P97B8N
 'SP1G4XYHQT2KSTB6ZKHBZKN28RPHQAVZBNAS2FPMC
 'SP36V264H7J05RKZ4SAH6VYVR6VADDY18XEQC5ZVZ
 'SP15PM2QE14E20JDYTQ4YTREN3TPS0K390Z694FEM
 'SP3TT9FFGVEN0GHC6F208KFNV7DCFDFB37PF5NDR4
 'SPW0CHYR5S4J0DM03ACH2PH9ZHPFJ776Z1EQBPSV
 'SP3TAQCT0KQ1TC9E6XJ33J26XPG1DGSPS61M61H9G
 'SP3E0535P4TWPH30BBSG3XNQSD2CQWA54A48DPDQK
 'SPJNJJ3NBR3D6CH1C5RQ8A50SP69T8MKQK0EP7RP
 'SPXJKX5JZ3E573DAQD3XBPPC0VQKE0JKR5JCE4NP
 'SP1QWSRR7ZP9695F3Z2Y56KHW6GZK4JD2W35XX56N
 'SP3YYZ4ZEJCDCQPM0PZQN0ANG77NXG8PSGP4P1XDY
 'SP2A754FBPQH9J89ZPHP3FT8PD067YS7AEEYHDNB2
 'SPW32GREJ0TZ013P3CK4H8ZKAVSSQFYHYMN1NF8M
 'SPTXZTN30Y4RNYG9G6YHKNAA9CNGCBVTQW6RSN3M
 'SP1SG8ZPWC51YPDH495G5YX9NZZE8A84WSANX7HP6
 'SPC7M5BS09G0MEX6FZ4WAKK6JFZ4AVZMZB8FXDEP
 'SP291KEYRVKKQQTVSXQ5CJFGRRSA40RFQPR2M62GN
 'SP301ZT9SW5Z1BQ4D020YWJZSWG7BR8W207917RQF
 'SP2N667K129YA55W7JXFPFT5AM6BY82QH83DP7RHH
 'SP3MFG5GAD2Z299ZC082KPST29394GDQ8HVZQ2KSD
 'SP1G5F70FF2FT66PAQVDKQDHK14EKQS4SP6FRXGGK
 'SP2A7WMNWY0KZDTVRDJTQJFT10H9NE97JJE9NSW8S
 'SP2YSFPT19S2S5FGT8WVTRAH02F1KS3QY72WCK45P
 'SP2SWKTYYWC1FEYVMG59NWGC9Q95DW50SDTE8JEBH
 'SP1J0DRQ6VYPAKZYQM8EYT3JQE63JC3X6GXM9S59F
 'SP3VSH6NQX0N9Y1JFNFN4E3AG6HTP161CRW3XXD1B
 'SP1H3DY1527FGNZCN1VTAKWZQK8EW7A91V0B4E1Q3
 'SP3EEY64DVR8HWWNQJHBK37DT1HSC6X4P6ENG4HDE
 'SPA3P34ZVXJ3CEDHAXY6D2EC57T4NPEYQTDQXS0Z
 'SP2HG965STSHPXKJE033E810RZFHGC63NY484YRD5
 'SP2JB8RF1F7DNFG545GF68F976ME1PX4EA6SJ6JF7
 'SP1RT80B6G2SADNGJG1XES0BYC0G4QT48Z13JY5ER
 'SP31CS3K2M80HJZ5QDJCHWD4XFGQ8N5PCPDZBHJNK
 'SP37S80Z9WG22KG3KHRE1P4SCTSR2ZWQX9Z04YEXY
 'SP3TCKRCZFT9KVN0NWBDHTZ3PZW22YEQYJBM9KCP3
 'SP164EEKSKP2K6G4N97553SZTFPS33FMJ3PS1BQGT
 'SP11JZZTFQV8B8X0VB17AXXGEQA154PKVC5MSE49T
 'SP1CYVH4G1MBZVQ3KGQNG1AH76FM6Q0P3EATDXD3N
 'SPYA40P5WD8HX0TRD7VNVGDH9XC6XPWPCEP1K2JK
 'SP67BWNC1T3MS7QZDJBYER3BV8ZWYZ78Q1PGCJJN
 'SP1NGXZMZCARCG4FSHXKR4TJ0FHMZ3QPH5JA1YKAG
 'SP3MP1X4QTENV1YEVJPMVY0999CY1QY5DZFBM40KX
 'SP2KCSSTRDX65Y2RQ9MG6GH0KE7KN34Q50F1N112D
 'SP14FT7FNFKY9WX5NW9Y13AF6DPFVQX42Q9BKW72N
 'SP7A9RHPKB5X86TC953SH78ZNR5CZ10670KWXGZ1
 'SP2C70M13CVA7ETHWFZC0HCESS5YNF60H8A9EZ21C
 'SP1R305P4D80CJE2S51N76Q5BH6REM8SA9BMVWS31
 'SP26N920AMMJB74HXM85DBYZV80G01R9WBM0SKDX5
 'SP2M20S7BDE9CPJRYDZCCTC1EFXYX6P1N128JJKAX
 'SP150EKYM4DKC96WP3BE2RRWG0Q065MEBSRZVB9C7
 'SPD85KB6T7JPSQ4PAVRZF1H8123K4AXCE4T9Z3TS
 'SP3H5CRENA8TA1SSYEQ5TXS66AWR9FWH2YA5WJA7V
 'SP1F8GB7KTNY8JMX3R8385DE9XS6AH6H36J7H0E3N
 'SP2VY6S85EFVJK7JKYJ00A79D55A1BYT15JR6TDQ2
 'SP37X5NF39N68F48THEJ8FFB6HQ0KF988ADQFGXH5
 'SP2Y3GEA79YK2FVB0RZTDY6XHBRSJWAQ8XZB4VYCJ
 'SP3QJ7C5GJ8WWPE5QXP2D6ZKVDXDPX401S7P4Z27S
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

