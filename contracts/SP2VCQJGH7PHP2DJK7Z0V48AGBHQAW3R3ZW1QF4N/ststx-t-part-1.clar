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
 'SP3V2DGJ3EVPY680F4N7ZF69152W05X4JH3X0P6RV
 'SPWKDKPZ3QDPQGDADWJ3EWPAP14CB1N1HDQ897W5
 'SP2D2M4G94PBW4QTZZ5VPXJMJT25AKNVB5GNC6N88
 'SP1YFBFQYPXTD0GS180M868YVZ8BXKZYK06QC0WZC
 'SP19C86XC505G87MYM33FCA0Y0BJV8SS64KKDPC8S
 'SP2VC4CXTWYRZEV7MSGXPNHE739N14ECQWX8JP2BF
 'SP1CMFJW9J8WN7R2XJ26AC90AARGW68R1CWNYDANC
 'SP2JACZ2382Y6FQXY2YWZJB8X7PJCEZEHJQDXCMW
 'SP3FEMRF8WWN9WV3KNG6NDGEVSW23XBAXBFBZ93MA
 'SP2KD44XNHAXEPY4WXDQDCM596DNM68N29EGWJJ52
 'SP212GPY9BTNZ9XPPBVBWWAEMYKJ0MGJ76X7DTAEM
 'SP1KVVSY1CNJ6QW7BCJBDY7VXE9F3DZPPR9TRRR4N
 'SP3ZPQ3QWH2V5CT69A9G6WPYXKDKZP6D1YV1ZVT6G
 'SP31KW1PTH7W7J6PFMFZGK4H75P2PRQ8BYQJ2TEGY
 'SP3E3FWG7HCZ0ZQANBY0EB5PV2RXMQG18NG08MGW9
 'SPZHCRB6K4FR6Z2NB6QEAWB7WCADB8V32VMRMYQH
 'SP19EFHJDC9C4RX064BPJ7SFXXD5CQRFCF199129M
 'SP1AAHHRZ4D47AAGAC74JFMEF70CRE93TVRHG2GZR
 'SP16YGBC7HZDKQAFKJNHNZV1AMEYFANRYCTJ4ZFAC
 'SP3TGM1MYQHN3RNDKT78N7TB13SNF7GEFX21SMET1
 'SP388KEZ5JV583ZXD04M06R3TDKXTM6XM0J1FE3TY
 'SP13QC2G49PXXA84H083Y1PMFS2PGXM583HQ8TQ9F
 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7
 'SP1NGCHX615S1CFA80S43T4YWDA9NQ599R8T2DP4C
 'SP87MT4CA256R9HD2DZ6ZWF9CMGB9Y7SMK1X7JE4
 'SPQFY8GDC8XXR30RGW2JCGCFG42TFZQP0K3QQY6A
 'SP3PR8WPVBC0YXPSEVR78T0NPMT1Y01231QZRQSKK
 'SP1NVRFGCABR2H7C5Z05JCN2FE1P4A3K2J73CC9WW
 'SPJZZG5VWKD2KQZV8VP9RXQVBAFTP2N84ZP7MZAD
 'SP232NTSTP2WMYPCZZBJ1PGFCMP86VWXNAJAYSW81
 'SP7QXF69DV4B5TV0GJGJFED2JBRED62BAX24R086
 'SPA5ANFWSYHWPGQJWKRX1TRZ4ZRA155YH1P6KCEN
 'SP19FPTFZMPTAJ3X4E91Y867MTEEY4TC8P193AJ1N
 'SP3ZMEFW7VH796ZQAH1JMAJT4WC4VPEZZFB6W5CAD
 'SP1R2DHP2TGMY0KR1EBQX6TYWT0Q1ABZ2HB4C049G
 'SP27JJS3774KPR0MMB5FH77VWBD8KD0SVNZ4QNX5X
 'SP1A02Z9HE18BXC2800RWXDQW4N7Y128CQHYKG8T5
 'SP8B25TQC2XDAKSFWMD1C4VN2PWHG75SV1R7RR01
 'SPF7Y6JJHA7S8KSBWB0ZJJAKQFGMMJ759EDH8KPT
 'SPPZTRYYGZWA7BY3YX6NSXFE87CWJE0FFVEXCQ9Y
 'SP92BR07YNC1371FRX2M5M5F7ARA63EVYTMKTV6H
 'SP2VAKZGM873F6ZHSJXZ1BGJE5D4Z2H8B66EXXJKC
 'SP1Z2AGR9FJ8HTA7QDE1V3MNNCBG5Y3FFW5ME3H8Z
 'SP1V25JS50N3AMQ8JW99GBV54WBTYJQ2F2Y18VAXB
 'SP28YHBJYDCG3YEKVMNHY7AVM380N3VWQQTVWRQPN
 'SPFF6TZK4Y9YZ1Y9K0K6ZDNX1HWQ8MYPMFZAY6N0
 'SP1J5PS54EC4M9WN7CVNFRP5J88DB9K0MS06PZ7R6
 'SP3W2X4YB38RM1XXK1VS20YQHAFSHN8YJ32P8XDV8
 'SP22DGADCDARESGJ1A9TJ1B8VMRW5BBSNGTW6P95N
 'SP3KBMD47ZGR3F400ZXRBWMMFC8QFV7BVKYK8Z7BJ
 'SP15NQJMSVCASV1XG3N6W3DY874HQXMHSWDGTY62F
 'SPZBR3JHKX1E4FD5PPF9JGVFJET97CMSD1NZ95C5
 'SP3XSTBKYPMR0WRXD0JNXTMCTTD588C06VNCPET94
 'SP2FMBVXN0XT8G7EDHFDR0THARK8MQ56C8GPY64KV
 'SP2F845QAR3CMT1WFWF52KMFQ4SJK3J3QJXMBCQM3
 'SPKV40624TWPZXRHMQ44H7SVZK35YSVJ7NBGAV2B
 'SP21125B3JZM6FQ7VSC1YXNPED2HMN7C7HEERGV8D
 'SPNF6V2Z7SZ6NXSPQK3R5SSR3BKCBWQ6E029VZG5
 'SP2XK5VQ46J9ZCFEGDF7Z11CT0ZPXH1CJ9MEHRK8A
 'SP3ANZY9ENCJJN6QCQW0TBYAQN7W37A6CMYEGB282
 'SPJYH7C2F7SJH13E5JB5T6HV21KY4BAYEKSF1AV3
 'SP33QBZQF9CZYDQTA7A5SADQA47J7FBC00G5Z85CD
 'SP2C082EC61TARPS72G190ZQ91FP56EQH89FGWZ6C
 'SPZ1KS5R0XX9F6MMEVS715RM2ND7PWTNP9V1R3JQ
 'SPVY2PDVNB6JNR4WJ2A1HRAA0JRZ0HDVHYSS4GMP
 'SPZD2MFC5R2FC0SNZ8SNZ9YCVM0YB4ZA0GRE1364
 'SP19RMCXH8EW32FGXE0706RA02QX7QDQ323XJ2PT2
 'SP15M881ED8JGZ5CAXTR6VM4FRH61C0SJQ3H9BAFR
 'SP2W8FZ2WRT6G86Z001CA8TP717H4ZHTCVBF7FXF6
 'SP3K95YG8F25HE0KVMR5E8H58DHNZTRT307YKQ7TB
 'SP5BS3ZYEMZH74EBJGKDVYRS0JH569ENR56YGFCM
 'SPS1WJG6TK3XRKYNQP01HWD9NXJK5KPP6XY7JN75
 'SP2Q6FW2J84X6KNF59TQEV2XVN64Q7JJ9YR83TKYJ
 'SP1EZWR5J704A5G1JSV3V8PS0DWXHEFPYEN913XXC
 'SP1PJY6BZKW5JXT4PY7JZNX27BVAR4ADHV4MX07AM
 'SP37V30X7F9AZ3088R3SCPEHAS8YMYKHYSB736WQF
 'SP1469XJ2BCQ515P9Q4DE9XEK2DT44BY2GW155PCV
 'SPT6CQP20SGVVXPPRE9QVJPFNYBXJZNEATJBXJYH
 'SP37B7YRCACRMKNTHSM43RCF6QYVT69ZXASPKNTM6
 'SP1QSMPQJK184K2SHBG3DZH9BF5A2FVPQ4ZANC79V
 'SP1F6XQR5M81C6B3ZB96QGDATSVKNCK6305EAD1QS
 'SP108M55RCA3NAGATCRMNK95NR4SV5HPNYDC2WT41
 'SP33ABZ860YXPQYHR4CSJZMH7DERM55CMQ0X9PNN4
 'SP31MFYFN60R4261KT5MS88NG30SFPEP7YR3KXH42
 'SP3XHKJ74DK1CV6FWHJN28K2K5R3GEMN3WVYR6AMG
 'SP2FQX4436VXJ09KSSZ52V0Z9K85KRGHYXYENFMYG
 'SP21E4WGWMP23CYE31KYAV1BS1VWZA9MD9PZRWE1S
 'SP2B4RX6FH7HSFE7X0GJXMRRRS5GARRBD0DMWPBP3
 'SP3YJPGV1WQ0YX5F80NYX9M6ZWDBCQQ95YN577A2V
 'SP3GJPR9RTJG3NAKKZAQRD2GS55AMM7BAHXYB0GDA
 'SP16593SNDJ01WMJ8K5PCXRZFN98AYJJ29KKQH58H
 'SP2J0Z0C54R721YQWPWYPJKK3RPRFV7HD1JFX92NY
 'SP2N94V78TBXBPQR4HET7ASD933BDB107VE4N820H
 'SP1ZBHR6B8BH6F4S7MFX9AV4MS0B6AE85E4SNARZA
 'SP1KCBPWHQDQ9MQ8E7GPHS8A9GFYAZ2WRN2F5YC14
 'SP2KRCGTC8QN0Z7CV2AJ6J1MK7MCYSGSE6FW71T29
 'SP1XNKNDRVV6JEWT2DS8H1F5Y1QKVDZD4B9ADYFZY
 'SP1MWMBMQ6G4X6H4BSNNFC9RFSEATT1PJFKWA20R
 'SP35REDC1J2STAGW643CRSVFA9R1J8JQDK6GPX1X4
 'SP636HFPNRGR42XBAB0Y4YR26G2HYBETW7PBX9ZK
 'SP1J4VFHH3CQJCC8WHPVMY2VDKKJM9BZBKE8XT7S9
 'SP2AZJJBT8T8F9VPJX0H5P2722KWWT59AVAHJST4P
 'SPPTKQ34ST51KYZ53Y60MD3EKVSM173P077QMH3C
 'SP2K10HFR0BY3JZVQ70MXGW5MKMKKWM3QM86HZ8B3
 'SP2TCWYR49B4TNRTEZPX61R6FFPAMMCJRDGKJYK7V
 'SP1GNMVM8AY9TX6140XQ7FCRBZ3MVF1ZJG6VFYHD
 'SP31AFRF5ERWQVW0KSNCVQC3Q9NZ51B5N0D8PGJ1D
 'SP2YKGTN9NRYM02Z3D6VMMN5DCSPS58G6DCNR7AYQ
 'SP2WEPB230RZ8N0XNHRYWW7CG0EVP1GARR3CYAAVR
 'SP12JW8WTWMTV78FJPGWAZ27XSXV22KGECQ7FQHSC
 'SP28GF941NGYYZDH8B05VGRTV242WE4PEPD8Y414H
 'SP2JFEQ45G2ZVX83C3EQ906821072T6JDFKEGESRF
 'SP2TBCYQC7NKXAZK0QXJ2554ZMNYT6VM17JA7ZXGJ
 'SPYPRWTERZPZC2C50DYHW9H740VB3PP85N8Q5S3X
 'SP2H3CG1T8F9R769HCR221DQHV94F3B7E7Y0VKACH
 'SP860WWXHMFFF4KXHNVKX4PKCEGKNVTQ1JXMQS1Q
 'SP3KYAGCME37WZ5NXCHS6X8D31NQVHATV3W7PB4E1
 'SP27NQHM28DNEK38P49SSEJBHX3C9AB9RD5G4QA1Z
 'SPR643E2Z21Z638ZFGHPR8VDVNRSSF990MBYFZJR
 'SP2CZP0VGN4DA08VX9N2EM0G1TDNHZD65TRBWDHE5
 'SPV4H9607JNE9DZBCHJY0ADWBWGTDDWFM0JJGNAS
 'SP234CWQBK5X8VVARJ16PT9Q1TGFDFD0310436AKD
 'SP1SA9ZTHB8QWNWJAYX54RZKA1EGB3R6YZDN4RWNJ
 'SP379DQDX08J9FT1AWQWPH9HDCX8SE4YZXVZFRNC
 'SPXHTE0ESYYXCYT2PRQ5XZ8BNDQYKH67759CX5C5
 'SP1X524DYD5G1SRP5NPVW5EWFRTAY8DEEJGK490FN
 'SP329XX3PSAB2WZZARW39K25B275B62A7WENEY4Y
 'SP8X66091KM6A3EBYK6XVCHKA7H1S6YRXAHCM184
 'SP2BDR80RZ00E7V3WJSQYZWTCP9S6CC2GW4N94DPM
 'SPA0P1B6F3DHBKPPZJ54MT8Z0EE46RX6VC2TCETX
 'SP3M2QBYH3A2Q4ATEQHBMZW63D9XS6AS43VWH1JFS
 'SPJJE3PPC7070BTDB8H8YB537HQCKRQ5QF3TRPW1
 'SP21WQSZ3DCTAVVWF0HV59R0YSQSR8C054FS4MKQ3
 'SPG6XWKY0Q1P90KRK4HPFD1GZ3FX3040WEBJW468
 'SP2096JYVBM5QCRG7JQ57ZAFQAQCSSZXX4D9ZFJJP
 'SP28H8KYSJ2EH898AD2YY2RD6N3A4DPKKPGMYXSRE
 'SP3XE83R926A0X892VA30028K0TT06PSMC8YGWGXQ
 'SPB81B44C33K44RVE0C3CNY5Y6R3XW4JQFTTVWBV
 'SPMMPB451Z13MVACXSFGM42QP9V5TJXQ0DY5YGMH
 'SPYGZQFDYMME91BZJ9MXQWTVY8VCFTY3EEQN3AH8
 'SP13SDD9HDGT3056EXAJ8VGYKAG9MDGS2QWWVNGHS
 'SP1TEY118FAWETHD1ZQ18ST5SW6KPXK8GSMGE3SEH
 'SP38A04MF92WSMCG9DH5BA5EA1CBPWDG9NNAZSJG0
 'SP1AZWJFWMAPHPD9AE9WD4388XSG3PVVBRP91PVHB
 'SP2GAV07HA1920DTCD578MJC67V4X3W1NR71P9D50
 'SP4C46JRF02K2GRWNCE6XHDKNYMV6SHYWQ4H9KWE
 'SPT5DR8RNAWWBSHENV465GTN5Q47J079BWG82AWW
 'SP2ZD755DFNJGW4BR40JFDA4CDZ40FJKVM4QW3Z2P
 'SP16CVJT4K2A4Y77T71ZNA13SFX7FB9YJRQ58YGZ4
 'SP3432CDC7C2XMH2WQG1BR3XQQTR1JVB8AHHRRHXR
 'SP3BK0PZ6CRWJ0W84F1VKFR8AAH45W5C9KJ60NBDK
 'SP2HB2EG8P3F673DKG5HKAEF0P489C89803YTZGP0
 'SPXADN0ZATAKTSFJK5381SPXSKR800NZM3F5K7HD
 'SP3TJS9K4G0B736GRFGXC7248K4BAK5VAXBEZR57J
 'SP2F6XA179WBAJ3HBZKHCPVXHY4YGNXWHTP0APARZ
 'SP1EVZ387AA1EBR2W2GAYPHTKW1J9K7QNSECNEZJZ
 'SP1F0TBF1GS8MA2BED7BD4C7E0WRN37QDPZNTA9E
 'SP3KD0C5J0FQNEFBQTH1EHJCFM0RKHKE2HDQ3BSNJ
 'SP3Q4MFDV8KFG48F1FK761VCT257Z625NC1VR87EX
 'SP3XNVN0JNWJNYC7W0MHZMJPTYCWXMNCXX3HF9ZBX
 'SPHAFF464DK5AFC4A24NKS4697EDVTBCC48GJ2GJ
 'SP1CH8F1PM3FWS9P86Z7FJ2K6CG4VS8MXQHJX9WK2
 'SP1P3TJM0PFF5HWK64J3PDRV8APCY4M92AFWX8MEF
 'SP1RDWCRA4XVHSQMXNS6QGWE9QW0GM1MP80EGSYP6
 'SP1T631R3AYB13K1AE1RK7ZXEVN3FKJ2KTW2G5T8M
 'SP1VM5898Q6M7AD0ASY99NB9VKCXKNDP93PKQ4T64
 'SP1X5C173AGWDKENQHSAR01SH81BBBN0JVRNKW64A
 'SP1YNWVT7MY3AD1WPYHX3QGGEFWCR2PP3RSEHZBWE
 'SP20EY4M3S1BDZDNRSYP3VEE3CPEQ0E1QJ548K4EP
 'SP25XSF4ZQ87N6FZEFANQGY9H1XGBNNCHECGCW17Q
 'SP2CGFSB8YHE0NQ7XW7NTPCVNFVWQKHG321KS4KXX
 'SP2QSB1TB76VD7F40GQ09C8BYQP0TT01QXFCC1BC3
 'SP2R14ZRPE2Z84RA1BKM2QEWXEN97Y9TFCQRFFGDF
 'SP2R7FB9DS5A38H3TFXH4BBWSWKJK2C26CQD12BE3
 'SP2SF1WM8TDGNB2CPGKBVE6SNETRM1JW323QEZG8J
 'SP2SVPGSX7QSZHT4WBPZYTB4VMVWRK3GVNCKBZPSS
 'SP2W8WKF4C1RACPAG5H8EP7VBG55Q0C52NDZDG6A0
 'SP2XTYJQJY3DK2HP3WVE69CSPKD1YA27EYBFHEMAS
 'SP3BHQNHXVH3KABGVMQEPS322S1V0TR87DJFFHN4W
 'SP3TM8TRJV54EQJCC51YHEE8VP1DA023GN9B15DZ4
 'SP3V8GXH4MN1F5K8J3B2D86PW7TWX5Z2J7Y38C66N
 'SP8HPQMV2Q6R6J485SNZ4VTTKDYWGK7E4JARCSY8
 'SPJG64C05Z0QGAW199SKXWTJWW9KPDDQ4YP4BT5H
 'SPZQA7ZMDF3ZRJVC4DXFFATEB4JCBAGGJTP284B5
 'SP1EP6854YZ8QKV5AVY613BDFQMMEXBN1FRHT2DFZ
 'SP3V06FTAPZTHT2K6QWNZFCSBFEK5YYY0904DTF3B
 'SP35CQSF60V57BZSEVJNHN7WDVS53M0VJVGVZB7YS
 'SP1GQKBVX6TTP1NRGB5FZXBG9CTJ011N5H7HH19V6
 'SP1RJP8EZFPJMA0G4BJJAGJTZZMYTM0D8MQD8F895
 'SP23SHNY9M0F0XDB1AG5CPFRH9KZC895VMA3SQXKJ
 'SP2H667JRMBHX0NRJ3ZMPPDR4R9TH6NM1ZFYW07S6
 'SP34G3MERX5M21MK97MSED21RN8RM3R3TK7F10F1E
 'SP3FK9MST3Y7CH2E1HHA84VA1CWDS67AHAAX8R9J0
 'SP3JRHW6MESKE576TAF36DM3TXG6D9S6GZXHB37V1
 'SP3YDKTXXDNE6MR64YDW494N39PB7S796M8EC4GEB
 'SPXD2C1MNBFYERPVXR31FNEV4MN5ZVGTV0N6G2HQ
 'SP1YKRHH5M7G6NHYQ4FWX6M6QZ19H0S9FY1P91GS4
 'SP2TDPJKNGE0KGZGFJ4C71KA9QJH0BSTKJY2GSXB
 'SPR8KP1APHSY1C0VJ8ZJ8HW5SD9AQQCAFKF807ZY
 'SP3WFE7WQ3PV4X12GPJSY59FAW0RC5TJPME38WWJP
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

