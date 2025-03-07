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
 'SP3QBFQGPQH26CCYCT025PXRTZWCQ7QHYKRD603CJ
 'SP3THEFW1M9MCYBNH1Z0MQHKPHCH64AF38BAPVCJM
 'SP8MP70KD4E1NDHY4D0VF909MJBT6WCZGM0D1HV8
 'SPA7PJWFKPPYQ2BDPCXAG0WB9C52G06B2Q50QDJ5
 'SPDW9JCXXHVGWVZXD2HZX6Y8Q7B8W72567Q7N7AJ
 'SPF628CZHVHT1R5ECM2VGF1RSRX39WV1532GP8Y9
 'SPKPFJCXQ5B9EK4X4VKA0F0VZAP46XHR2WRANSE2
 'SPP573S6EBM2XS05ADMCB8E1C3EPWKSKQKS1ANKJ
 'SPT4QSFTPBS8B2QX9VCQ6CCYM5RVNHF1FY45WT0K
 'SPV2E19WA1DS67PXBT0EF689T1KNYZ9T2GN9ZGKV
 'SPZKACCZC5GMBTJBG35D8BCS7FJ5MGR6BN95GY7S
 'SP3W05KES7GVWRR977DX1ZYEAFTEMJJP4WJBHJFDF
 'SP32NK6N7GN16P734VCJ80D4EKQHA0EQMY11PA9PD
 'SPK43K3DHQ9KANTPAES87MGES3WP21RFXM3BWTWA
 'SP3HYY2J5F1JRST8QAC3CYYXRE9SP8MNHWQJE91ZX
 'SPM2TBKEPXB1Z4J2EFR2DMB6F53YP95SDG5RMEHW
 'SP2A3RR660KNYQ1D724C8HGS8DFV919R8M3YD4JQB
 'SP2ND057V3RK6RDAWF4CKBV2VXNCT6ZXY3VM9B1CY
 'SP17V9P5WP0BHJG66F77Z4WCN8ZVER4X68JBZCRW4
 'SP16CWZW1PCYB13WFCVBKJTXFV7W09246SPDZGHQ0
 'SP2DZVM2KBC445F3T6NXM5NKTEBPKEM5WSXZBHG3X
 'SP2FBH2VSF2D5KNK4KW4CAJKZFVV8JNGWSD0YNPT8
 'SP2V1PD1MCEAAB1NTP5K1XY33SP5QW57ND6Z9TT7Z
 'SPKZ4SV89K72MJGGXW8GNJTB9F05JB2KDNWHX9Q7
 'SPWCGZ1XRHTMWFQWS6JKF9438PVWEB2C60W50RC1
 'SP2BYPKKSVF01Z4QBW6XY47FBHKEB8RM78PTX5RHT
 'SP2J8031AENGX9H9V1N2M6VQDHVSCCVD41Z65K2QN
 'SP37CBPKYENDQ4JV9P4MFNN7PNVF7CPPYDQESK3X9
 'SP7Z1D1RJG33W0K99Y40P55TVFXPV2TXEMM95J9X
 'SPY804VSTARNWA0SCTV6JJ1DHDKA8XFJVQVDG5J1
 'SP1VA2P1MFBKJ30WET6DVFAGYQRE95T0N1S7NVHPZ
 'SP2JK5TRRHJZN8QQQGSVKXMGDT3DZ9WFFHF2J2YPY
 'SP3PC00WB192FB3E9YNMJ8DWBR3PFJ6GVAXJH247X
 'SPZX4S98KR7EAZT6C1YK7XD02ZDT3N0XBVBVH4NK
 'SP024YFNK3350K1S3Y2VFRPBMNFN8M513590ZCG7
 'SP27VV0FQP4H8J41896N6YPE9ZQY0T9ZX9Q5RXM47
 'SP15K3P093P54TVW7NTQ6RGY5261HF2XE0M6J6K6E
 'SP35ESCM9SM8FHTFPCVBF2S92FTJJ1G4B666C1HC3
 'SP10N9MG0Q6R8JASPAHZWM5CVR3Q1A2EERTFC926M
 'SP3AXFSQY7S9YEHPMWE9KJGAQE09FGGKEGN768XD
 'SP3G98P3GKB3XCN5X014A4EEVQ6Y8RNF2NGE2JXH5
 'SP1G3FCHEZWNXGV9NZ7YG9R6Y168N9RW8HR4VTWTV
 'SP9J9GT1WH1YH99SPV0YR2A40R9FJ0N1WJAV9X35
 'SP1W35PY711H9N28DA00M3GDDEAKNDWR6M5FYC8YA
 'SP9MYD61T01V2E3Z10PN01GZ7XZEHG40Z2RXY9VC
 'SP9YWPBTX7DZWHAPVBH7CMA039HSKDPX7VASEXVJ
 'SP3B6YG6MTG1FQTZMMP8XRXNBQ9QGDYPB4B553W19
 'SPQKZS8HG7WPW63BG5QDFPKD49SCKFYRNZQTRCQ7
 'SP31XMC5HM010EC4WWXE7NGZ0CG79FGTZ7PRP3CQ2
 'SPM7G7N741FQT0EXW9RVKPVJNV7AJFDVH6F2M14R
 'SP3DC62V3XNK2DXWMQAE4J0DVJFXS7N6N8HM5K4W8
 'SP1VBYB8Q4EYFH34318NYQ639CJZNH190R8RZVHZ
 'SP22WHSQ6NSNGBNAH299K3RQQ88HP195ZB8JQGHQE
 'SP20NVZXR5EBJ7YSWNW0E6EW0KGW66TVZ8Q4R1WVM
 'SP13VZ66ER5GBA7PM276H7ZJ5ST65Z2CWAPSATFXX
 'SP29XK0ZSX7PWXWYPSA873JS2WGN9EPS9RPMHRR3S
 'SP3SRD9VBH81J7ZHTRSJTTDMHK7300EB66C8QXFM6
 'SP2RTHJ70R2D8MBAQD7J6Q1Y7QVHNPQ9YCTVS0MV6
 'SP2NQ2JFRDEB4K6AQGM7X2438FKJZCWDAFYDZT48S
 'SP3G7FWXCFTZJTBSFGYTVEARTSAJN2MBMH3KZZACM
 'SP3D45KMD1T3TX8AN476WSH4HK40N0EXVGEP0P154
 'SPJ5K6B6SVF4G1XBABKQ6R4SVQ7C3AQMEPYH1EGR
 'SP1J4ZT1GAPYAWBKVS5A2BNTZDC1KDRYYP3Y34GEA
 'SPHQ21KXXPH7DP7EBRF4CVR600WBTFYHW5965NS2
 'SP2K9D10ENKQJVNGK69A6PN2G5FADTGK1BE55XR8Q
 'SP24EJXF836BWZ1NB1RG0CDBC3Z4MV0G52PAQPJC8
 'SP2FCVBM6PSHJX9W3B0BPZ0CT1C2V9Y46T4GEEAVA
 'SP16KMQWMF5ZKD95KCTA04FZPMZCNTGBBAPF33JN4
 'SP3TDHV7BH8MKYEJYSVSW18PG1YQV0C236SPJYMYV
 'SP185D5HQ6AF8280PEVF12HRB4GX1K7XJ25F2DXZ4
 'SP2NT791VKVJ29GP7WKC47T2V01B9VERJ6E6EMVZ6
 'SPPX9EAB73406Q6J0466WJM32KENF0774FERSPDT
 'SP22P7T552R9G5PXSP46T86EG6FR7M2DKYD86AG73
 'SP4RKBHKCDQHYXJJ5QY5ZQBSDV9JM1PRE5CWMKDG
 'SPVSVYH2CVZTVTXWRRD2G1SVMHDHXAJS02KHTKP9
 'SPWB12ZW2J66ATDG1W01GDRR1DFG29G0KDQV163W
 'SP198KRAR7N24D57V1R71QYW4TRZD6Q7B65QSNG03
 'SP1GC99FG5HXGBRP6RD5MNENBPH74EEBT5TAJEMKM
 'SP1GNXJ700VAXMS5V64C5ZRXQM0H1A612PPHM0HRS
 'SP33G759DBBCVD83FC06SMT75C1XKYDFR1ATQGHZQ
 'SPJG26J8FJMZH84XKWC5R7ETDYQR08X4PG187ZJY
 'SPE1MGT6N9P1XCFJQKJSJ12T9HFYY13YY8N7GT41
 'SP8H1JPB3VWRXNS8ZWYZK09WRBXD9308Z88MBEC1
 'SP3S3FQA3T8F40D0CK82ESAK79JMAEXYZ47VWA9JG
 'SP30HZQ4XR8NVQMZ13V22ABPRERXSEV56FT4Z1DQ
 'SP25SWG8PG99W85J03ZWPHT6H341T4PTJ91EK58YC
 'SP1BCDCEJ8K0HSSJ1M3PJPVGP6EGX408X07VZT4J5
 'SP3DGMAN61KKK4DDS70WKST59WWR3PHZY7CP5BCKP
 'SP3VHCCGTPMNGVM20S2A4MZE3TZ6HQYBCAD2GT3WY
 'SPGKKWQXWZ5FDKR5PVEN1FDBSQ2JA2MDSTD19M7X
 'SP1V0MWV8V9Z7MRVJAABWR4XPSFJZ67R4FMN011HE
 'SP2S5X1JKR9TGV6K173BGJAGZ1E6RM6Z3BV3B2EWN
 'SP1113XP6CAN6MES1W0J854E3E8881GJMZBNN3YF5
 'SP185MT0TN0QRKMSV2KXS6HD9NC8P1RMBWKVNVJXP
 'SP2Z1V405B3S6ZCECPT8P9A66N2H3GP60TZ882XC4
 'SP7EEVB135N0ZDSXP6NTZR2AYPJ3HE915N0QWA5R
 'SP3YJNHT8KZFWSRT96AVB5SBJ1Y0ZH8H1VY5130QJ
 'SP35S2G4P1Q7VCGNDMM7T7AK6XBNT07AW28DVXV59
 'SP1RXDBX0DKVWYXPS1WZ1BXVYB2DJQ2JGXEZQ0XTA
 'SP1P3HD8Z6F8EBFP4CGN2MFP0V3JGN5A31NT3GDHQ
 'SP2ZKTYREFH6A2TCCY66SFX6V2608VJQA3NB3MY4H
 'SP3XDEQ0JHP6AGMWF6PQZMJC1C0BFK2H0YSWMNYXS
 'SPM4QPSET1AMK9K64W22KX62V71T9QAGE5FPXFM5
 'SP14Y5R5250EQFC2Q5VBSKFNHDVV52XH1Q18GT3H1
 'SPJPKP7KJ5C90HSBWD0GXRK5KBK3241BXQR07VX2
 'SP34CXZZ86HTZCMF96BX6HGHADZ0YQ3PSM50VG8X4
 'SPA8DHRRVPMPVYBTE1YSQZRKD71NMTZ9P99CW10G
 'SPBZ053RNY57AD40TRVMQ52GKZA86HC3959CZBV3
 'SPWYGV8FK7WXYMJZF7SSYEXR1R1QA2FG05AVPY4H
 'SP1VT41Y7T8K7KKAMV5F0A000Q38GNWDTZKCGBY9
 'SP1NTBTPVZHEM779MZXNQWQ48XMW2NHTMXNANYFN7
 'SP175WXE409KV3FSGS3S2WGDSWZ8V2YHQ1WEC8XCB
 'SP367JYM20EYK5M3615E2J2F23DG2VTVK125E35S0
 'SPY2RQ669KEH0HRR71DYWHA3W1VA3EGH9Z5DT3K0
 'SP3V6FBBVN9FG7PTR39ZPQC3KQ3SS1MFPWWH14JRJ
 'SP2XHQ1ZX86F2V6S652F5D5HY37HTM2FFCZ7WN10G
 'SP2KY3X9FVXSBR3EVKS6VPKWQZQBSXF449DDHATWH
 'SP3ZDBCDC0XS99XY2PA2AYZ7M0PYZXDTD4XWKECCP
 'SP1MDT7W1C0RM2PJ7X2YG5BQ6QNCZK40FXRWTESQE
 'SP3JC5Q7TM69284CCYMYJWGPCXXV92TA055R0657A
 'SP2SHVP2MC8GYQ9WQEF6XNE7VGFETYMSZW0ZG196M
 'SP37ZKT5VEEABYQJENCR2KXX7BFM9DDPWDZP4F21M
 'SP14G9P39M8SXF4SYQH1GDXAWREC0AS2MNRXKTW8J
 'SP3W5SYJ03112YY7WN33D0KW0KH675YPXKVGFY5MN
 'SP30VSZ7DT27XJGGPS3ZJEYQ3FN6D7224FRAC0VMY
 'SP20M3DXS8P1ZP7X2RVVA0Q162A21X0XBNJKY1VEX
 'SP3RFW3FH7890SJ2KJ1VETX9FN9Y4J1T4WF0QRDAH
 'SP1WFTCF8R8TTG53YZB8TMMR4T3RWVVTYKCHFZP5R
 'SP29Y2BR0845WZVMEMTWHENG46HVYQKM2EG6KKQSY
 'SP18V1ZKEW9YZ8YRNPPSDW9VXT3BSX6HW00HN3R16
 'SP2QJNK08YJRQKXGN09QTGDCGA5C34ARVJ33626PY
 'SP1TEB27G4VQZED23HG32PQNA7RMTKE8A3JFC3DH6
 'SPX74BVCREFB62QW9VB15JAASXYRK49Q6M650632
 'SP1AYX7DQ3TERCJDDQ424GGCEK3YK5C809H6YB1YX
 'SP3DYQP75J2P91S7WAAZ3ANE2NB4ZRRWPWWY386D9
 'SP1WE84A7XF5WED5285CPZ573HY81BMP22ZYJG4PM
 'SP2K1HZH5672HTWJFDSMH1V0B47N8DPENY3SWRA3T
 'SP2XM1QJB05F2JA76J6PEKHTEKBW8GEDY1XRND9F6
 'SP2Y7GHJ2E0XAKHW22988GZXE3EW8G2N4700DDS4W
 'SPCTDJP6V3TGQR5JVCJ4SPYE0J6QMXP2382TH009
 'SPE4EKB7Y19Y9KQVQFXAEM9SF1BYRDEWDCRTAZP4
 'SP2A4101CRS4FHK06VGVBP41SD31007A5Z93ZN8RV
 'SP3W1EY9XBBCP2RG1J6A42WJNP4FAK4D8SVT4AB5V
 'SP1CSVW1CDRY5HTHPA78RTBM6ZT5H8K4SCZPAPAS9
 'SPZSN5532BR0H1M3C57YR834N8R36PGCYY4EYWBK
 'SP9AXWX6CYX30T0KB235RYWZ6Q01G2JHKMB2G8YV
 'SP1J13SBJSMSYFN21GPTJXFXRF8ZC76FWAB6TVTHH
 'SPKR4VBCY24WMG511A6JD9M29JZ6V186736V9JDR
 'SP3Y12Z2TD816TMG4XPH2FE508VNVNJN2S64FXV8X
 'SP12WWAENT8PHFA7JNDK2M0Q644EZNDGMJSHVJ9S9
 'SPZAJ1266M5150DBTCRRMD82TAGPVRX6NM5NV54G
 'SP34NX3GKTYVBSR2VBAYR3YN9DZVB06NH7RNM8VCY
 'SPDYKH10WC4JFZMVMRW8ECXD2FC362G72X4ABJ7Q
 'SPSHM7BK73D2WY2YD2R15VX2KF4AS9QT0Y331CJ2
 'SP1245MQVQMCAHHV8XEJAXP2QQZDP9GEMF8N0A7B5
 'SP2PJ8RQ3Q6RS8A8SP9F1SN03J1NVHDPYBCHE125A
 'SP1NR1G13R3NMST4JT7WC0KCAWAR5BE2GKZA7X4GY
 'SPVS85MX63F81CBXN1E36GCMK6KP1SD7AVG3S5X4
 'SP1TVC1QY4S3ZPVP58M4R52WGH4EXAH6ET5BC24WX
 'SP2AWV0FWMMYTQSFEATX5GXV5BFYH3B4FZNWNRZQ5
 'SP13SPZAS7582CV08CY8TJJQT9TKGT841GB09E17M
 'SPV1ZK8Y5TSQ36DSTCD651BPCKFJRVZQVQB6RQWM
 'SP1W0J5RXVGWK4KZ9P4YA83AR4KZCA01RYKEVNHHM
 'SP1PAGYEDF35JACKPBBTDRYDTV84ZAT0FAMCC38V9
 'SPKWS5RYVHX6X6QJ67Z84NK4CH1ZBANAQT4DVB69
 'SP2S7QQ46767XG6HEEQ867RDET8J1F7YRNB1MMHMF
 'SP2BT75NGZ32N8ZPYSPZA9WJA76WVBF4R35GEY6VB
 'SP3GKF2XA0MRCXSF827J9M76KM7AW3C53ET78BAZG
 'SP1ZKQM5GRTG42CY8QMABPFVNPWBV16AF1G145JC5
 'SP20RN8R8A3DCVDNSVWA2VE0QSXTWEFWVM5PCS36Y
 'SP3E4919H3GVJPPKEDTDY2EJTSQTPGDA7V62JRJVE
 'SP2W76MDJNXJD7DBKTEH71CNTTR242GSD8PS1BF59
 'SP7CD8EB3GT9N5PFW8TPY9CMF84208V7KB0EPAPR
 'SP95RD0P9BANN19802P9NBEX0FVJVPY4XFKT84H3
 'SP2WP3D7T8D5QTF3NPCHMXT78JNHJTMCSWBY5MH2Z
 'SP2KP96PS0P584GVKA1HC5RP385DK53ZYC50B00K0
 'SP1TJZA1RQN8FTX4YARVWV1TCYY2K8BF64NRT7635
 'SP4HCEG0XTAABK91HZZQSN5S26ZCMPWWH2Q5NHP4
 'SP2Q1DMW11BTAT0DZ7AA7NWT8TB9D73SHF549X951
 'SP45X0587ECYDYV8G6TTSBE8H0Y9K5JVZKMSQC3S
 'SP4HVX51TQVRZRYQ4Q3VSCPTBJGE2DW5MGV96X1N
 'SP3C0YB66FJ7G2NH69JYPHDE315QQ3SHT9H35058B
 'SP1Z7Y8T73QZ8RVX7VH1KZXMX457JFPFT1R7T1S98
 'SP26QVCQ9AFF0SYQT3R93KPKW77BT46NQTMB17P4Y
 'SP19KS16RSV5G32SND6HF7ATZVK305P66TMSDK7X4
 'SP1Y40A7JGNVW8T4DPR8B4TG0SHDJRHB7AJZ1FEV6
 'SP26FTZ05084XZJ7GP0MFAGFMB400HV613SDYMYFC
 'SP3AYNR9K25M06MNV5JY21Q32BDTT22HDZJ650YN6
 'SP3N2D4X387J0F2EFDMT6YZJ1AR08H02Z3Y3K7KYJ
 'SPKPWE4J3674Z75D2SRDT4E4QGR5G41NKXCPR91R
 'SP3G77VPYCY93Z4P3SCYAKS49C09X52ZGSQXVQFAZ
 'SP271N4269J9GKA8GN4R0BBD35ZGKJF9XAQCTNF0F
 'SP32YTEZSV6H6NHF8WMX75HC38D9K0QAC4RVJ1GA7
 'SP9ZWVDMGGFYJF7PVFJC4KJPV1E5ARXGXSTFG375
 'SP2Y0V1WQSNFAVEXRB67NM18MNCC0W1WX2EGKTSHX
 'SP1S5407HED4VT2MBE1F247B43XT3RWGNV75MQDBB
 'SP2SGMZ12DJJEZ50Z8G79VV72V89949JZCPH9XWMG
 'SPMKAE32ZFDT4F6T13KJN5JG853B6MQF6A4S495Q
 'SPF6G48815QC8EVGMW98DQSCP1GA3D7304K8XRGD
 'SP1DR90069XVXRQ7ZQPJATABVJF6PFAGJ2FK346FQ
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

