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
 'SP379QM3CHY64YERK62MFYBDWVAX16RP3GA9KG7J6
 'SP2X97TW8R5YW697X7S7VR87AGEPA8BDK66AKSNV9
 'SP1SWWDSEKPVS8TA7E4QYZ2ZG9HD6T4K09MX96XFS
 'SP10QCM2TWE8Y9XRXEZ4BQAHG7ZZ1PGC1917DQKVS
 'SPJG013EY7YRJRZZXBE6VBR5KJ5Q6ZNVTDSGHBJJ
 'SP1S9757HJ590FYMVGXG73Y6EK160VXNS6KSRHFTJ
 'SP1093ZT30FEP22D62X06W0P4R0733R1QSH6KCQW4
 'SP3Z455C7FSM71512HQEEA7S9WET89RAHF2WRPREY
 'SP7F0N9E90XMA50F58CTHRT2598E56F6V3VPYXCQ
 'SPHGFBW6D29Y8GCJ3NHTY5QYKT75ESZ3KRPDPBX7
 'SP166603FDK4H3JNWVHENRTP7PRRWK7SZH51FXQEY
 'SP28XEA373EXM4H4QCDK94VXMD3V0P7G9HEWBJ85
 'SP2ZGVSV6JDJ6SCGJETE3ZT0PNRSB90FM01P830D4
 'SP2T8Z4XWG7GXES6ZKXW7NRQ9BCT33TNQBNP11WTQ
 'SP24XNESRSARXMJNEBSPGB8RD5CGXHD4P0J6V0ES4
 'SP25516PM040SYQ8AYS9TXYPDKWMC2BKGD110N14B
 'SP3J59Z1DZVGW1P22V57J7VCD8Z64D7XX7804KRED
 'SP1P748S1EQKT8X33W6KPMTCMJC56J3Y89702J1ZN
 'SP1M9HYJ2EKEZC7KQJP8JQG8W67H1WYP2AF2TVY1K
 'SPMZ7M9CS4VYRATT51VPE7N1TD9H5PC86Y868857
 'SP2V8DHPFX5K9VGK5ZBP41SJS68FJ550WAXB0G1QS
 'SP2E7BQEXADN6F5GR8735XXHQFF21QY9BGJQ16W3B
 'SP11BNQMDB18JJERGE5E9EZ363ZVS22B0K1Q857MF
 'SP2XJQSVE7WFTHX0HRTK50Z2SDHBY2Q6P1E0K7CJB
 'SP1VHBZ3TJWBASX407GVS6AANN01GTW0A3E9TKBPQ
 'SP2TBW5EM2JEH10756JC1FSG784P0SVYZ9F2ZBJ7K
 'SP1W3NZH1H6Q4Z34SQAB20JFD73NYRM66GR31SFRJ
 'SP10RE0D991JAEWTBNH952ANSCCY6H80VSEAFGMJH
 'SP26XVJ5V09B44ZWVC3MABED50JS7HYZXHFRNVWZ1
 'SPR3X0H1EJ9MW8WR56J2FF7ZQB1ZF4XYW009RXZM
 'SP2Y6PN1W5F97RZ2ENNSAADVWBFDF3GCVC4YZ71CN
 'SPQD05KVECS73XX81B5DSM37S9EZTAX57Z715D13
 'SP2ENJ3R7X7XVRCB6WKYKJW3A71M8275SCT08Q8SY
 'SP2ER2W9MWH4N7NTS326J8R7F0S003RFXYBMK13CF
 'SP39008W341K5JJPC8EX27F8S936ACQNB9FHQZDRJ
 'SP2XVR6QRWNGRZN7SE3C26X17KGWFFASF72VPZ888
 'SP36G4GJX55CTGM4TJ2CY3V5S1G87524XQS67AM9
 'SP37MW060D9HH2NHY3MS4Y22W9D9W293YK9CPDC0E
 'SP375EMBBESRAHKNP9FEWMSS6DYCGB2QZVSG8VZ3J
 'SP1DA3QCZE3FG9VCZ8V3CWS6QMHYARK0GD26AGQHM
 'SPX0A0V0DTG6M3RDVTXVXJBJC3C7F4PE5P0Z5MD6
 'SP3N6EZPTSX8ZV2RGPY9NR9A8CA0QET39CY978H5E
 'SP3EVSTZBE5BKHBREY4RMX5EVH3PJDTPKBG73A6QA
 'SP3GK06CKDRH2R5KDGSXWJM39HXX5VNYCEGA9Q745
 'SPE9R5TQCEPNQR8H8H08GWKWEW40E8FM2EY50BZY
 'SP1B7AG8JNAA5ZB5SHVEFMZ130ZM43JJ05YB6D2AS
 'SPYD3HVFASAPF4N9WF45PRF5FPN0C67F2F4BK7Z1
 'SP6KDDXGXQET3YG38QB264B76V9FT5V77HK2JXGG
 'SP1EVE87SDC9C99XQQJGBXQKFX9CP07J3PY193EZ8
 'SP3YNFB1HK6NFR0ZR4A2Z1PDYEF9ZG25KRSB2GEGZ
 'SPZ0VY1HH029TGG96SC2X118KTJS8NEFZET6911B
 'SP21VW0V1Z1PWCW4GDFB6WWXFSZ3XJNFHTCYHHEZB
 'SP2DWZGRN6A13HYNZ6P26X1W87B6VN7N47V8A88TV
 'SP1NSFR5ST5PVYJBRNPMTQ768RNJYQ8XZ0HB514MW
 'SPPWRYRZ201T8GWTB5QQC7S9X3ZQJ2NQPCHFDF2J
 'SP3CY9TFJW2H5NVBBF6ZB1WMKB4RSBB4J01QZ5S8
 'SPZM99G969379CZRW0FBA0N7BE1D4HAT2QKNHXPD
 'SPS98KQK8R6N1NJACSBQFQ1HB46BPVN4HX4Y6YSE
 'SPR9P7SWQ410559B9S7RSNYYV90ZRZWJS9JTS11A
 'SP38JGANYK8HVK3S62PNYDP25CR66NDKGRMQ38BQH
 'SP2AZVJ817DGD2X493Q9TJARKGF6H1FD4HD2GF8V4
 'SPAA4DKD011VDB91MQYV5NBNAVYSSG9T0RVT0HET
 'SP12WF74FCN4SFV696YAA8XH5CBWN0JB404Q2X93B
 'SP3Z34RH9RAH7NN10BAE9SZYB945C9TYBKFN2K0Y0
 'SP3VNF3FCJ3P3HXTJ68Y7EFA2BRC68ZQQDKTWSWSH
 'SP18C9Q2F2FXGR1Z4HFM2M6HNRPCBB8XAZ0SBASA4
 'SP3ZWCFRGEJ6AH9T15DXPQ5H804RWWK1RPGAE0K2X
 'SP3E2Y6B0NT0JGCT45S7AJVV2XXTHYSZ53P9QWCM
 'SPC7WVAHMQ0ZRF85757M3XBWCQ5G583J9W3GBGF5
 'SPPC73EYWBHEB1MPTRCPM7N655RXM0ZNE1F0DZ2F
 'SP2W7BV0JJX2PDC2KAANHJRX8RXHXK82YCH7KED24
 'SP11JJ5RT71B3S5V02WGA77A5TW5SD15A5QZ2WT0F
 'SP1PQ60E563ATANXSM9CVWJ8HD5HA853WBDGN8QF7
 'SP1K1B8243JPQGSGAPT0SDDW01VWF2D6YBC8M1CRH
 'SPMMYPSV29T1Y0YC0CW217H72YAJH08MPCXXZPXH
 'SP1F7G9DVCD9JXXPFZMK5VDA1MQ932XCBXA0NCQ6K
 'SPMED7SKX8C3QCR85351SFD0QY4AXWTZRWDR3BSQ
 'SPC368F2NF35NFPZ2DHGSB06BMW9V6XG7GCSMA74
 'SP90BJ9N65AN07PNKH3ZYC2Y6RZNDMJA7AFKQ8GK
 'SP21H1T77S9AA0WGD9TTNGKJEEZ8B3JQ7Z8DQZA96
 'SP1XSNRB14HFNAV89NE3VWPVZD48NKPD1TFBT8AS9
 'SP13YV2QVDTJYHFX5XPAW2DV3G7W7CW0B6DC9FJE6
 'SP1T6G4A9Y5KEQ1KHP78N8G7831RZAE3GDY00Z37T
 'SPMPCV9VHX63RJ11G5ZXVE6NYC4B3BWQ3V3MP894
 'SP1T71WCP6PAGEXBX6N4DRJEWHXYVTMWRXZQDR7SY
 'SP3J4TZJJH4WCCX2HHDRR79G18HDQBSPXRKNJDKH
 'SP19ECAYACEGGD56T9CFNGRQJC32F8P1H50EATCHX
 'SP32N0QKN7GVVHZ4HS3QQV9H8ZTHAMZ2JZR2AB7XM
 'SP2BMH1SK80DRA9XZZEPKW057RVHGA0C2B9VZXHBC
 'SP172ZXH6NM1C47HA60APXRFMKFFHS9MFMEM7XT0G
 'SP1KDS52V2RG07FQD6Y7YX3WM3WQ9AF5ENPM5V4PD
 'SPB99G3XCF1RMR9KQ8TXHX9G70T7V34NVXAK22RF
 'SP2B0EJEMA0AGY9C986WQZRG9BAYMYMTWT990JSER
 'SP29QH0X7T8ZSN2EGNE8HZBF19PKN1678Y9VQ67QY
 'SP26XJ0ASNB2GWJFR3YJXJ7TJ1P4R5HP5FGSB7CRB
 'SP3BR2M3E0Y63NENYQ90ASNNKB6SZZWQYAYJJEMWM
 'SP2T88HJYEANEWDZEYGC8CY7SWQ52FA2D4ZJG9V14
 'SP30CJ1DJMETH7868PS627B8A5KMTNB9BCGR7EXMF
 'SP25CTYTHDRXY6WHR5MQB413VANTV48589EH0KGS2
 'SP3ZZZA95M39YJTMHX2S5ZG2ZSFD7118TBSPHHW04
 'SP31BERCCX5RJ20W9Y10VNMBGGXXW8TJCCR2P6GPG
 'SPTA1VSZ7HEPCRS4795MCRJPZ5DJ4KF8XS8H3SSH
 'SP1WZAR8MBEQ2EJJB52PG12QM3FQ0Y6E8JKZGFFCT
 'SP2FXB6AW37VTZX6RF4Y6SHA2RG5CAY3M219ZACHP
 'SPDFWR9ZPKRFG48Z4ASD4K8KTQH0RR6Q8F2M51QY
 'SP838E1RGM17AA5YR1FTND40YHKN2RNH5697DWPA
 'SP3GDZKRQ914PGS9YRBB22QD9F4R7H6B0W66VNZXY
 'SP2Z6K2G6E08399JKV48N9WJBWPQBES3ZZDH4FFHW
 'SP3NNTSWS5DPF9P1AND76KH0MK9MXF51N6EDTSJ1K
 'SP3JCWCBN7XA22T2E4GHXWQGY5HYA1KTHQDX431Z9
 'SPDVCHPD7HQKZETX2RQKMXXRK03PR5ATX9YNMS87
 'SP3GGNJ6K535NPE1SQQYTN75R2DW4YC30FDR7B635
 'SP1PSYNK6TC5ZN8VZRRE5FWCDS6WKGYM3HDG20P7S
 'SP5P05ZDA0VGAMNM3BJCK3VQ79FJHZM0SE7PQ9Y1
 'SPKKA9M9KRQ1P2B6HAAJZ132TVYMBP03YJV7NR1X
 'SP2MMW27TPKKFR130XSFETJ5AXCWQ0Z23QYC8T25S
 'SP3AMTZ4386C93296JJ4JF701BASVJ00EHJXTZ7VG
 'SP3FQ2HPJ63E6F9059DC382YFPY1B0Q3KQFPJF6SE
 'SP1J1AXM48HH1DJMCCEBBBEX5WQ92JHQXEP0WH4S8
 'SP18QVQ3CMGJ0Z4WQN39QX3MRNWRYBRC525KHF93V
 'SP3MPKFSEH22YBFFEC2EM8BRE7598Y73EXNTWQK3Y
 'SP2E52D9C7DDWWCQPNZJW8SZ755S7FRAAJSXRG7ED
 'SP3GF07VFQWD16TTAR2GRASAJ56NHGTYK28MA17QD
 'SP2CE5DJRN2QQ0599TRQ0R5JBHQ5C4DDZP5ZD9BYF
 'SP2KATBKJA0D0Z0WXT7GXES3YKTT0TDHY3XMA5SRP
 'SP2V4ZTC2VGG3RAVPV802XSCJ0YHBCDKTXHKA6J7Z
 'SP2MGXWE7WDFT6S7P4V3YVM8GDZGHC51YWXMAAPM3
 'SP82MH3BHMKTQDH3RREC9GFH4YM1JM0MM3JEGH97
 'SP340HP3XW950EWX4FM448T5S1RK25VEYPCEJQ02V
 'SPY4BEPY27MJ71CRG8D019AZH20ECTE01PP2CHGA
 'SP1BN3VDV1GP6TJ6SH21NT621PBVFTG9ETGG5RG1N
 'SP1RZGWJGEN59AJAQM452G7CYFTVH0BBS4GMDQYM3
 'SP2JM40E5HV25SH1VFASN99TA4BHBWQPBM1M2ZKTZ
 'SPDVSGNH3DPYFWCKEB9E2RYGC3ZSNY3YYV0MNBSP
 'SP3V1S3K19A26Z87VK0BFA8A9CZMRBHA4TT8DC1PR
 'SP32CPWD0RFBSXCK0WN0281K6T9YJ8B402M2AD816
 'SP1J4P1Y1NY47VPYPD8QWVS091B84DJF8H2SKF9D1
 'SP3572WHQAB3R8Z2BQPTBCQAMDNC0BD4PM4HN95JW
 'SP1ECQJPTA9RREM5RR2TMFPDCE57GX58TR2S86KRT
 'SP1F550FJRN668EBE3327K9RHSS2PSWQHR6ZEJJWW
 'SP38TS998667866SZ6VETN7CJFN20QBEF7PSXA4FH
 'SP196Q9CYB2NZ24AMZ0XHP5N8MYRJ1NE48XXA0GKK
 'SPQ2RRVPZJXNT1X4WTGHR9S36K9EAXSJ2J6GSX5V
 'SP2967ZJJDQVJXNJ81J9VP27KVH6893ZVW0BPK2Q7
 'SP2N44TKAG2CGVC4RKCMCFPRSQP02SWP2RDG2D4H8
 'SP1FARHKYYEEDY9ZDXJ1Z26ADSA2MCDQ4PES1VXJH
 'SP2G1J79TA47FE2D0MN5NPFQ3DG8WAA2R967SG2YR
 'SP3CNBPY1NBNA77BYJT5M09CS2P364YPP22TQBZVF
 'SP2GYGFJNPDTZCDGA52ZQT3RBHYCF46SJ642F8WNF
 'SPM5R5HQ3ASRGH5HEY7X200QWQC8QWBZ78P3QXRR
 'SP1E6GBE5JWRMRA0VC1TAB0YWAE8326FXKMGV441A
 'SP2575NG49YMWGDP7QYYAGR9HX49YP1WK73MTNVDY
 'SPAWF9Z8Q9HV8KP1J4PB343Z5R2JRZ5YVBGXAAAC
 'SP1N973K3V574VJ86KM95HFCT1T0V1VCQPDADRGMS
 'SP1454QJJZC5E7Q5D25R32Q1WYCGAN2MZHC1W349D
 'SP3HEDDM8VJZXWMVG6DVZ8TTFDFXYXV5M3NR8NPM5
 'SP1MGHC77K69E5TVB124SZ3S0PTNJX2GXZB05D4BG
 'SP2RHKTWVDV2MJ81TGZZPHS8PC67FCTTQF0CR368
 'SP2FWXNZJ4QEMKDBYA4R61C6N71JAY547RSH8B6K0
 'SPX71C0K7Q381T091GP87FC902CNZ55TEQHVC5Q7
 'SP26Z13X1TF93C9J20JHM592SCM6GEB36SRBHKS65
 'SP11XX0PCQVE313J2X3TAHGQ9T1T0NMMEN4XMHABQ
 'SP2JZ6Z67SQPT1SE1JV41WR6AAMM36XF5R1GBD3CY
 'SP31B2KHDPJYGXCV0SP4P35W72YGA8YNG30SJ3FGT
 'SP3A4FAWTNC17WJZCB6C53C1JHAP7WZ8JW9C2BC5H
 'SP6FD8F1VVJ1XBQVX33TBWZXNR5XA1ES2B4AQ81F
 'SP2NT1D5WQ3B755T0R15V3C9NZ7E400NSBZRJAN5Q
 'SP2GE4KF7Q9Z6590F5P1MXHJZ3B8RRV4JVDQXKPW0
 'SP2B8JQ5Y7CDWFQGP92ECE59Y7RHG989A8K123CMP
 'SP3A4EV2XMSPXF48J6PNKT3KRT6YXAXHRQSE2H29K
 'SP3ZX05AV8A8WWYJQHKEEA8SZCJQWJWSTC4C8CEZZ
 'SP30SBBRKT8FCTSX8K449SZ3ZYDK2T96Y7AEQH4T0
 'SP3698XDXXY8GFSX1P6TH6S88Q66RWR2Y1GR3XQEQ
 'SP112B8XRP4BAJ8VKJAA1CD296VCEQX0VBJDEGER5
 'SP140D96P51CKBAHYNAGZY7F6184PSVDW14V36DHJ
 'SP1K345SABJ2PKYYXC2261QGGQ7W2TJX7BBY1SN7Z
 'SP2AZP7F7TYXBHRVC99FJ3S3W01YCR0V00Q6JBY2T
 'SPXE2KMFVHH4YGDG58JBG68DTM9XJ37EFFEFF9XP
 'SP1398CHCH7S6BT3Q1JCMJP327XGNAZV4FQTTX15H
 'SP280FRJZ7JAH964VZYS5H44RP9K0916PF01HMAVZ
 'SP1FJ766Q4703PCENCWPSSSHQSTAQ34C15CFA90PG
 'SP19FKYM00ZT6SA2C7NXSW92FRF9K5MG4B3WWPTDN
 'SP2P6ND86F2YG2GQDQD8QXZTE28EWYKS559D98H48
 'SP2E78TGFKW96CMBWQVK118AJYD9SC7DH1E0PVCV0
 'SP234NYXB20YQBVXANCXFAETTN214VHHGZ3AVTCED
 'SP39GY0TY79SMBZSQ9TW28VM38999K9TPWGN5K3VJ
 'SP27A5RMDF3CBPAW2FT361D5MDGFKBQNV63691K3B
 'SP260SFRAVYMB98QKM5ATNKPC22P47G8PDMKR82N8
 'SPJ34PF85CAP4EQ67RV9AZ8Q7T7KMXEGZ54H9NKW
 'SP3722W4GQSW60QPPC9VRMMANGNHQCP07BCPF2FTB
 'SP2GY0MH5FF6JY94E40H1HSZ8NBFP4NHEBFFGXWRW
 'SP2XGT4XMKGB6DBN6FGZAVAXHBQT18F3G3WJ4TTTW
 'SP2JC5RNBKSSQ1M68Z59WG5MF4QJ7X0VER7V5252A
 'SP25MNFEVN07ADBB3GP2T4DZ6958N89G58EN493GQ
 'SP2JJPRGDW1QATKJE702W1KA1ZSQQQH7ZBQVPSJ0
 'SP338QTVEXYS2W4B1VC7X0KW0HRW6GED27RRCHDWB
 'SP2VP7ZBW7AZQNQRQ956V2RX51AHGT8ZBQZRM9G8R
 'SP3X2VA67GWQF583A7YNP2E9J3TD1MJAT9TQ0H8P
 'SP2YR859H0SM7SJHDTZVFJXJT887AE1BKZMY80MTY
 'SP2AJ6R5EN5ETQRZAJA7751WEN28TCHNAW2N617MQ
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

