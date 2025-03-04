
(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP3NAJRMR7F04RK8WG2F48MSQ4ETH3JH1F9MV4F50.retarded-labs-usd send-many (list {to: 'SP2BN9JN4WEG02QYVX5Y21VMB2JWV3W0KNHPH9R4P, amount: u690000000000000, memo: none} {to: 'SPAE4SFGGSKKH7NC49KQCHJFY9159DG24YHQCJVX, amount: u690000000000000, memo: none} {to: 'SP1HPB7YTZDXMZSZD51C113PQFAXKSNR0QYFFPWVC, amount: u690000000000000, memo: none} {to: 'SPCDCWBEZ9ZEK49BNMDE2MDMJ0E01W02H9SA4TVZ, amount: u690000000000000, memo: none} {to: 'SP1C3H3NBJD4534XVP78BCHZHZX7H0F88VAG2GSQ, amount: u690000000000000, memo: none} {to: 'SP2A0AHSWNYPAS1KRNMEFQMV8WQ2KZRRW8DZC8Z3K, amount: u690000000000000, memo: none} {to: 'SPZVMHVVG5AD01C3KN9E8TF6BPQFRGM0N1W7E1P2, amount: u690000000000000, memo: none} {to: 'SP35KC61MJTNDZVVNED4W5W0GFBDBWVABHN38HEHR, amount: u690000000000000, memo: none} {to: 'SP000000000000000000002Q6VF78, amount: u690000000000000, memo: none} {to: 'SP2T395ZMA7X6N3JQ5VRKCME0D4DZQVM84M8AAKT1, amount: u690000000000000, memo: none} {to: 'SPJ6RD5PYMM75KQNGH588RHE153JMWRMCSWP4Q2H, amount: u690000000000000, memo: none} {to: 'SPQE3J7XMMK0DN0BWJZHGE6B05VDYQRXRMDV734D, amount: u690000000000000, memo: none} {to: 'SP3NA896RT4F14EASQFM2YTWV9S5SRGS95NS3SA8Z, amount: u690000000000000, memo: none} {to: 'SP2JCGKVMZA6QCFX0FF34AS42Z8MD56TBYWX535C8, amount: u690000000000000, memo: none} {to: 'SPK37A2Q8N9QB6JC6A7M8696JMNW5ESYGM4PBT1S, amount: u690000000000000, memo: none} {to: 'SP15V20R21ERBNC5070QWF5SH1VKWPADVWC2RZRGV, amount: u690000000000000, memo: none} {to: 'SP1ARWZD4G0SZPADBFQ5DVSK93B6QKQ6DHK9G452P, amount: u690000000000000, memo: none} {to: 'SP2FA1H3K9FMY2CQ80WWT2JYMHZ5Z2B810AT41APW, amount: u690000000000000, memo: none} {to: 'SP2RNHHQDTHGHPEVX83291K4AQZVGWEJ7WCQQDA9R, amount: u690000000000000, memo: none} {to: 'SP3QF8RJ3CE59RBAHC96YS6DRSVKYADCF2730P023, amount: u690000000000000, memo: none} {to: 'SP2KWPNJXQKQ14T3T5GZ61V5H479DPYE77DCCXJJC, amount: u690000000000000, memo: none} {to: 'SPJZKJTTSAN2YMXHPF0YZ12HGC8VZ4V82C6VPYHK, amount: u690000000000000, memo: none} {to: 'SP2XTD345MW8BENE2V6QV6SPBTY9G10GZEGXABPR4, amount: u690000000000000, memo: none} {to: 'SP238X3JD22HJBMWR8E7CKTF4JCBQ73BG9YS1DBH8, amount: u690000000000000, memo: none} {to: 'SP7KZ2AFRRTP53WGKQWY9707Y0W61DK848J1EK2D, amount: u690000000000000, memo: none} {to: 'SP30MSY8NECE4SJJRQ5NVFZA58HF9Y93XX6E15WMG, amount: u690000000000000, memo: none} {to: 'SP18148N2DV6AHCXKXXWZRNHWASEMHTK024S41HAE, amount: u690000000000000, memo: none} {to: 'SP3K0EE25S57TK269WJDYX9ZBEY763RFBX47TA69W, amount: u690000000000000, memo: none} {to: 'SP2RJRBMJQ09GEMZ0255ACY089A30CEB5ED8AWDB6, amount: u690000000000000, memo: none} {to: 'SP4BFY10R39WQKAB3HT2VADFEAR2JQN6VF7FHZ6B, amount: u690000000000000, memo: none} {to: 'SPBFPD0285PKTCTADGP9GX2JFE12R8ZXSCWRYW39, amount: u690000000000000, memo: none} {to: 'SP119F3JPW5AKFFKKTWEXE1RVD3TYQP8SG4GW80PT, amount: u690000000000000, memo: none} {to: 'SP30A13XJEHMK81JVEHMS0FEHFENS1W5KEEFYJDVM, amount: u690000000000000, memo: none} {to: 'SP33QFM4MV7H3821T6REDCB5DN485JKVXNT3ET62F, amount: u690000000000000, memo: none} {to: 'SPJBJ9ES6M9J18R4H2EQWG2VA5F8Q0TTN745M2K6, amount: u690000000000000, memo: none} {to: 'SP1ZRTHK2HERS7AR0WS6JN73VQX3HHDFMY5EQWJBN, amount: u690000000000000, memo: none} {to: 'SP10DQ9FGRK37Y1RFF1NWBTN5Q5YNV3GWJ4RMDT7K, amount: u690000000000000, memo: none} {to: 'SP3Z991D5QF6EHG2T9TZKDM9M7B010PZTNQD9XK7J, amount: u690000000000000, memo: none} {to: 'SPVR9PDHJHGJT59GE10E8QE2433YAZY6Z47EY13P, amount: u690000000000000, memo: none} {to: 'SP23JX6EVN9GK7A4EWWTEJTP6BP75R0SYJX7TV1D9, amount: u690000000000000, memo: none} {to: 'SP1B46TPZD8Y3ETHGZYJAPHD9GHJK81K08WRB127X, amount: u690000000000000, memo: none} {to: 'SPPBGBV4ZEB1FQ3954F1G4JPMKZSYJQ2BJFXEKCN, amount: u690000000000000, memo: none} {to: 'SPABSFFC2ZGXP328F8Q7RDRK96J728NFGD3PV23H, amount: u690000000000000, memo: none} {to: 'SP2WC112DEJR44WVAX5A2WZ21VCTTVMY000AJKKYT, amount: u690000000000000, memo: none} {to: 'SP3658EQDEKG3RYGVE4H1KC3PAS8MRJCXPJN7CYHC, amount: u690000000000000, memo: none} {to: 'SP1FHC2XXJW3CQFNFZX60633E5WPWST4DBW8JFP66, amount: u690000000000000, memo: none} {to: 'SP3KVRE3RDYYSJ3JDGXKA0K15CC4JEA2ZGX4TJ5EC, amount: u690000000000000, memo: none} {to: 'SP1T79CQEZE51RERQ7ZVAHP2ANPYVTTJCN623H4PG, amount: u690000000000000, memo: none} {to: 'SP3E4G6Z83YTZK1KXFVY6NHR805JEJ2GGYAZVZRTV, amount: u690000000000000, memo: none} {to: 'SPQRH49JM9YA39R21KHN49M5S947ETH2QFAW3F02, amount: u690000000000000, memo: none} {to: 'SPWC45P8JQP1VG9NDNPJ6ZXPVZ4XXGK06GXR5XN3, amount: u690000000000000, memo: none} {to: 'SP4GZY6SJD3YF65E7QNZC4CTBYR60RJ4WF4079Z4, amount: u690000000000000, memo: none} {to: 'SP2NKRMP53H372KY60GARDCR04TCS3VB2BWGS474V, amount: u690000000000000, memo: none} {to: 'SP2KZ24AM4X9HGTG8314MS4VSY1CVAFH0G1KBZZ1D, amount: u690000000000000, memo: none} {to: 'SP2JWM4MB1SBY2FT3PG5PM0V12NW8Y4FK1XXWBHSF, amount: u690000000000000, memo: none} {to: 'SP1NJMZW1GWP0ZNK59XE4TQ893CX2R8G7M28QVDBQ, amount: u690000000000000, memo: none} {to: 'SP2SBT6D37033NTT0X5347YZYZ45MQTPFZR3G45V0, amount: u690000000000000, memo: none} {to: 'SP1P637C9NB6GSK9TY8AT8SN3QKH1WSV5ZVCZZSKS, amount: u690000000000000, memo: none} {to: 'SP2P8RJ42R8MP0AAJASTT7ST6VZ7GHCWR7PET3B21, amount: u690000000000000, memo: none} {to: 'SP34BD9Y4F4VVJSVJSET42CWKW6K0A81D1YBC0NVH, amount: u690000000000000, memo: none} {to: 'SP3WZ0B7PAXPRD8Y217DMKGPXESK5EXWWCA7G03TS, amount: u690000000000000, memo: none} {to: 'SP26BHRECCNJBG2G6A139HYJ4C226KTHX762WVN8N, amount: u690000000000000, memo: none} {to: 'SP3VGRCZDRG8JBGX0H0P340DZC7C3FWCA80S9TT3D, amount: u690000000000000, memo: none} {to: 'SPGSDWYMSA6FTYPMV542D19FTZ73A7WPYXKF1QWE, amount: u690000000000000, memo: none} {to: 'SP25DP4A9QDM42KC40EXTYQPMQCT1P0R5243GWEGS, amount: u690000000000000, memo: none} {to: 'SP3K650KFSY5Y2559C56TKZNSBZ2MKVDF0PCAYE78, amount: u690000000000000, memo: none} {to: 'SP1ZCYG0D3HCK2F7SY8VH9ZREB0JWCBSAPFNS8V5Z, amount: u690000000000000, memo: none} {to: 'SP29CPZS40X3G7W6AYWB4873M27X22ZH3FJFMKZE1, amount: u690000000000000, memo: none} {to: 'SP2EQ889E0BPKDE0K7SNS3DKV11T4685Z599032PM, amount: u690000000000000, memo: none} {to: 'SP22441QWKAMN20Z16A4BVDC607C45GRH4K5C2AWE, amount: u690000000000000, memo: none} {to: 'SP2HMNV7HAAWYBYDE3CPQMGZ14V137E78B53KEJV1, amount: u690000000000000, memo: none} {to: 'SPC1KE74AZ8TT6GB8MXSY6W00MFNC29GDFXHPJX6, amount: u690000000000000, memo: none} {to: 'SP1B38V9K4MW4AR3C7MP44SHGPMBYHP2A7PJDJ2Z2, amount: u690000000000000, memo: none} {to: 'SP1Q32FAXFD7BP1B2GNNZ455P71NPG5AJ50BJ1417, amount: u690000000000000, memo: none} {to: 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0, amount: u690000000000000, memo: none} {to: 'SPRD2SQPBW6SCY9Y3NQ9FM9K3BR4G8VGB8CHEBGT, amount: u690000000000000, memo: none} {to: 'SPSZ01WZ7XDFGYXHD49RZ3SK6FYTYATVVN5GJ2YJ, amount: u690000000000000, memo: none} {to: 'SP3NYR9TY7QHDJD2Z1ZD9ERKPX5CZZ74H36ZMKB8A, amount: u690000000000000, memo: none} {to: 'SP3EBNHSGK3WPYGNP3C5KNN54V6H24BJ1H8BVPQ15, amount: u690000000000000, memo: none} {to: 'SP1AQMCE6AKND8B8R5RV7QNJGC5CPEBPPYNY6QM9T, amount: u690000000000000, memo: none} {to: 'SP2HHPWN1RSW34XSSSHC7XBH61Q23N02309AFMW52, amount: u690000000000000, memo: none} {to: 'SPBAC6ZCYDG0Z12F784TZ55CMHHW7FJJD93X1GEN, amount: u690000000000000, memo: none} {to: 'SP2WS6SV526X1GZX3RBZ3XDB0K0CANXKADYPNN8V7, amount: u690000000000000, memo: none} {to: 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV, amount: u690000000000000, memo: none} {to: 'SP21ED8W24R13AP4CPEKWK5AZPS5XFFZ4N3PY5YX1, amount: u690000000000000, memo: none} {to: 'SP2DCFHTZSY5YKSRHC7YRD1AD6HRA9CBZENCM4NGV, amount: u690000000000000, memo: none} {to: 'SP3V67J2YXAPVGC2YEB7CP4FNGG2NXKB5GD45J2RC, amount: u690000000000000, memo: none} {to: 'SP34XGTEWMW2855HQFAJAM034WHDBMETAK51PKKYH, amount: u690000000000000, memo: none} {to: 'SP2FPTH274BXVB1E2HNXBAMGABV5TCSZTFNC16FR3, amount: u690000000000000, memo: none} {to: 'SP3AP6DTCK6G65A4TK78J8J9NSV9DGMNFW0K7Q6YD, amount: u690000000000000, memo: none} {to: 'SP16VAAGEE7XE3DFZZSFDW7T5SCJR1N0WY3CVQ00B, amount: u690000000000000, memo: none} {to: 'SP3AGB55XBZN5VGK637F0A8TW8CJ70Q1RMRS5ZG6V, amount: u690000000000000, memo: none} {to: 'SP1QZWEY4AKGAM5YDBYNTJ4848RQPRM63SD8K3VPM, amount: u690000000000000, memo: none} {to: 'SPSQ4W56BY5XKZR8YJMXYP1CKJ64TT4CQ04GFQT8, amount: u690000000000000, memo: none} {to: 'SP1G4KJ49KM7QFQH0A7F2YXWSNAGFM48MN55S84PM, amount: u690000000000000, memo: none} {to: 'SPBN2RYDXB4231HJ2GHFFRGQ54X0SBMHFVRAVCW3, amount: u690000000000000, memo: none} {to: 'SP2SNQHT55ZM0TBF7DD0TA39XM652QZ97E3CXN2SJ, amount: u690000000000000, memo: none} {to: 'SP3KR9SGTMN0DRN5WPNN3MEDS4Y6XR795GCGH466K, amount: u690000000000000, memo: none} {to: 'SPQYFMS32D5KC1NT7YF5TA67TZ1Y64F97WQSZJ2P, amount: u690000000000000, memo: none} {to: 'SPQ9B3SYFV0AFYY96QN5ZJBNGCRRZCCMFHY0M34Z, amount: u690000000000000, memo: none} {to: 'SP3W83KG17KJZZXPDZQDTRQKQRGHNFZN410R9P02E, amount: u690000000000000, memo: none} {to: 'SP1454QJJZC5E7Q5D25R32Q1WYCGAN2MZHC1W349D, amount: u690000000000000, memo: none} {to: 'SP2R826J48G3P8G7C2ZTQ9V72N6M6RBGD1BJTDMY4, amount: u690000000000000, memo: none} {to: 'SP25SF2MPZZS8Q20QA3VTYJXTHAHCRNM5MSZYDNB0, amount: u690000000000000, memo: none} {to: 'SP380WYDKAB86C0WPK6FZFRCB3DDZTWKETDWQ9T54, amount: u690000000000000, memo: none} {to: 'SP3WJ60NYCKAG0D9YPSPD5T74M9NM5VZW4WZM7QG7, amount: u690000000000000, memo: none} {to: 'SP2H9Z97J0B3159H45ZFX6TVKS9RT3KVKDPGAHJC5, amount: u690000000000000, memo: none} {to: 'SP1ZWG5WEND2QSYQ04DAP17A5RMDBG76NXQQ115SK, amount: u690000000000000, memo: none} {to: 'SPWR61YRMNPGX6JASY3ZR6SSE79ACV143YW1PCAN, amount: u690000000000000, memo: none} {to: 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR, amount: u690000000000000, memo: none} {to: 'SP2QVKZ2GWP97TW4RNCT8TN65JRJPVAKERHYSS13E, amount: u690000000000000, memo: none} {to: 'SP1Y0VRA8PCQGS1JJ8D43K7ZQADY71AYCXS48H3JR, amount: u690000000000000, memo: none} {to: 'SPN6EFJZRDM7P4FP3CWY3RC8RZ2RD69MQ9DXJBZT, amount: u690000000000000, memo: none} {to: 'SPWD1B6SKM4T0DC4P3TQ20JWJ45VYGFHECMWKA4B, amount: u690000000000000, memo: none} {to: 'SP68A2GDYFED1P932H1Z3J2NKP24D8WW486C6QWT, amount: u690000000000000, memo: none} {to: 'SP2387TVHZ5X6TSCD6HNDA7N8ZC4M1XNYHFBHNWS5, amount: u690000000000000, memo: none} {to: 'SPZ57T5M3ME7SWBDJKY2C8397K5VWXNMFDVCJ236, amount: u690000000000000, memo: none} {to: 'SP35MER4PHM6XGB99YDRQAK0M0JQ8F9CVF04VZ1VX, amount: u690000000000000, memo: none} {to: 'SP1BH4ZGWANHZS5QHN8DHNEHP0QTGJBRW5WMPD4Q3, amount: u690000000000000, memo: none} {to: 'SPGNRR2GG22EKH62N8DCW58YB4D1PVK8TP0KQTHD, amount: u690000000000000, memo: none} {to: 'SP1QAS390Q4A4AHFRF5MRJ6BRD73H8AWS93QNM84Y, amount: u690000000000000, memo: none} {to: 'SP1W8J78ZWQ12TQ4910C2FAETWMS5MZATR75FXWCV, amount: u690000000000000, memo: none} {to: 'SP3ZCTZ0JDHXXCT63FZ8DC01PWJYCAB5EFP2ZH1X0, amount: u690000000000000, memo: none} {to: 'SP1DMPD0JNAVDRCTY17S2MNHX8F6502NB0Z25RVR, amount: u690000000000000, memo: none} {to: 'SP2N756NJDP0A3WYTF2ANXWJR0CEM0Y42E5C96C7J, amount: u690000000000000, memo: none} {to: 'SP2M13PGDK52VJHQXRXFQH10E5MEW767B27PQC1K0, amount: u690000000000000, memo: none} {to: 'SP19ABGPHMYDK6PA9D9NE0FCCG8NF0TYEM74MVQQ8, amount: u690000000000000, memo: none} {to: 'SP2PZYA27E8MRBQHQXE0JQH5CHM9JJNM00YEMC4QJ, amount: u690000000000000, memo: none} {to: 'SPWSGE1CDEHMM56SGMS9ZY3P91Z0G7YWD6R04KCA, amount: u690000000000000, memo: none} {to: 'SP260ZF58NPJZCJGB2K51327RW299BHES24W4ARKE, amount: u690000000000000, memo: none} {to: 'SPXY0VFX761352VTJPAMNYTJYYA82A5DRH0VR57P, amount: u690000000000000, memo: none} {to: 'SP2N7VSJ2DT9NY438G3VDWYFP3WWBKYN46GQPHH6T, amount: u690000000000000, memo: none} {to: 'SP15JMFZY4S59PTKHB399KE78ST5CHEYE2S0NCBNM, amount: u690000000000000, memo: none} {to: 'SP2H0RVJ0TCRZ3FAFAE4RD841WRCBEPGQRYZ12FF6, amount: u690000000000000, memo: none} {to: 'SP2BHPNVSEK74QWZERJV2671PN4CRCY4EQ5ZG5CMN, amount: u690000000000000, memo: none} {to: 'SPHDBN8HGYBWCC93TA95H0T4978P1A5N6M5GZ0ZY, amount: u690000000000000, memo: none} {to: 'SPWQJSR0FPTZQCQ7GF7VJMA76QV89PETA27ZCQX7, amount: u690000000000000, memo: none} {to: 'SP1GR38P4KNCQRC1BD5HC97DP36W2MBZFZ4WC0NET, amount: u690000000000000, memo: none} {to: 'SP1B2706F31PR4MR6R3453326ZR7366CBAGVVCC80, amount: u690000000000000, memo: none} {to: 'SP2RJA607NFS766M67VK2TRRTSNBFWMM1N8AH1RSC, amount: u690000000000000, memo: none} {to: 'SP1YGHETQ1ADA66DH9QD0XMK012W3FQHZ6CP2FT1W, amount: u690000000000000, memo: none} {to: 'SPVW6AV9A3H7G7P7S84GFP555E86B1SY6BE9DQPV, amount: u690000000000000, memo: none} {to: 'SP1VEHWR3SVWZWN24YQTHS3CVSMWEHK39CBM6Z3F5, amount: u690000000000000, memo: none} {to: 'SP17PZJ9A8W29FGM8BRY96M0XDXE6PRZX9DJHB926, amount: u690000000000000, memo: none} {to: 'SP2NTZ5ABMMMX1KYEHK3KYK5ZV6FKWV01CXRNYT44, amount: u690000000000000, memo: none} {to: 'SP29902VVK134BEFGP0F3QT7W2H5CFY2BVWAKSN7E, amount: u690000000000000, memo: none} {to: 'SP2Y9GB57MDT3JF8RAR7BC7D332RAZPGCEKX54NKF, amount: u690000000000000, memo: none} {to: 'SP372G1CB1DWQ8T873RC085K3QGJQ0SSRDWBM0A88, amount: u690000000000000, memo: none} {to: 'SP2DAYHJS9HYT3ND88JSFJWVG0X1JS7JXA0NG02EZ, amount: u690000000000000, memo: none} {to: 'SP274JYGEQHMBJWC0S925CT3CNX4WPWD8Z303BCG9, amount: u690000000000000, memo: none} {to: 'SP2ZM0FFZGQ64SX8G287QJEPH2KYF0EZRDJ15PSYC, amount: u690000000000000, memo: none} {to: 'SP2664YJ6Z7AWGKSGYG3MSDCCR3ZZREX3JH14TCCE, amount: u690000000000000, memo: none} {to: 'SP3EMZ5XM95XZRVFWB5M8JH3VRMMPJ8661WTT1M3T, amount: u690000000000000, memo: none} {to: 'SP1QYG7Q1NT7Y9X8GV4DQQYSM2X9DDVH304BVYF0Y, amount: u690000000000000, memo: none} {to: 'SP2YDZB938V1QNSRN2XCCP8YTWEXVC89HK9DFYDCP, amount: u690000000000000, memo: none} {to: 'SP3J98KY1Q89VA6XY69CP6FJJW9S1ZRWRP7RKKF4R, amount: u690000000000000, memo: none} {to: 'SP31JEKBEZGH2TJ9EG2TJDDYH78BB16PZZBPMKJW3, amount: u690000000000000, memo: none} {to: 'SPW45A1QA35EBWDB47V6VNK7ZMXZ01PFCJQA2JPX, amount: u690000000000000, memo: none} {to: 'SP37BWJKFCBJHW7C3H522M03DCRJQ2NC492T4AMY9, amount: u690000000000000, memo: none} {to: 'SP74BB1WD3XG6V7NMK4TW5SFNHTJ5AD4N84CAZMF, amount: u690000000000000, memo: none} {to: 'SP3BTM1J6HS9BWG8A115GN7CRWYPF2KSKETDBNP4G, amount: u690000000000000, memo: none} {to: 'SP2Q1AZMQDWH3M8DHJHVE1FC261QJ6Z9RC9ET9HGH, amount: u690000000000000, memo: none} {to: 'SP13FVX0W0AWMMECJS9K1BJNWEKRY6G98M3ZGEJ3D, amount: u690000000000000, memo: none} {to: 'SP30RDYWYBCDH2R8NWX71XNGQFX064S6QMY5MBM1K, amount: u690000000000000, memo: none} {to: 'SP2KKNVN3TFK0DYDAW6E3HZVPTN5FETZZZ436MNG9, amount: u690000000000000, memo: none} {to: 'SP31ZNSNSJK0R8Z8CRVKXFPWPC5A610SEA4XPBTQ7, amount: u690000000000000, memo: none} {to: 'SP2W1FEY0Q180MWE1J8AZQ1GNCEVN6M0H9E5MC38G, amount: u690000000000000, memo: none} {to: 'SP2VDFZJ7J6MB5SY17BY6H4F6YYH0B6Q4KYCQ48HF, amount: u690000000000000, memo: none} {to: 'SP3SFKJFQJAFV5ZTQ9P0TB86AQE639ZDFADKHTQVS, amount: u690000000000000, memo: none} {to: 'SP3WYQMPRNTX8VTKKD4TVS2W7PEYYP3V3Y24KNQ4F, amount: u690000000000000, memo: none} {to: 'SP7Z4BV67PTXXH99FAWE2CJDFRFFCW04PHNBK7ZN, amount: u690000000000000, memo: none} {to: 'SP3JFEKTFHVC3B9RRQ46FNC8MFRZPHVYYTFWYRX6W, amount: u690000000000000, memo: none} {to: 'SPAGGBPCHKV0J26MBQ7CV7D0QPGZ076T552J0YYY, amount: u690000000000000, memo: none} {to: 'SP2PPYXC7B0G5Y7JXJZ3QA2KY4657HAQTTS5KJ5HQ, amount: u690000000000000, memo: none} {to: 'SP14W78Q821B3HQ3ED30624Z1F13X4JMFZY3N5SK4, amount: u690000000000000, memo: none} {to: 'SP34QDBBSYT4DEEMNR3GC9F8V3BF0V17HCCFV0145, amount: u690000000000000, memo: none} {to: 'SPQ5Q6C96DMXJ4E7H5C1R2J9ZE3CESW2NWDPVGDP, amount: u690000000000000, memo: none} {to: 'SP2TW1D8YF5CE0NDP5VCR5NMTPHQ4PQR1KBB4NQ5Q, amount: u690000000000000, memo: none} {to: 'SP3WAAYXPC6WZNEC7SHGR36D32RJPZVXRR1BG0QSY, amount: u690000000000000, memo: none} {to: 'SP15RNN0NHNVPZZNM3TC5TWA7C4ZCBA7JJSPHEE87, amount: u690000000000000, memo: none} {to: 'SPJJZ9G3DWENGJTP4XHD3G9A2GMEJENZPFCVP30W, amount: u690000000000000, memo: none} {to: 'SP283BQ9PC3WW1TME4FK65SBDKPTRDM89QSWCHN3J, amount: u690000000000000, memo: none} {to: 'SPZSPSSF4GVFBQDTSWWY2F0WPHY3JE0PQ5F2MKA, amount: u690000000000000, memo: none} {to: 'SPHKNB2BHPZZJZAQND4ND16P9N5WRK4JCXDEBNEW, amount: u690000000000000, memo: none} {to: 'SP1P4JM3KYHYPV7G8VYT2QDPXW2X8FHRAY62CP0SE, amount: u690000000000000, memo: none} {to: 'SP1D67XVMN84D6QWXXQ5NY1DS9DCWN71W3MP00S2X, amount: u690000000000000, memo: none} {to: 'SP12WM2X339SBV7J7DPHSJFP2754MDM1411PSN1FZ, amount: u690000000000000, memo: none} {to: 'SP31MKEBNQ80ZEAAMCBXY9BVE91XTMAZG80TTBYK8, amount: u690000000000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)
