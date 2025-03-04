
(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP3NAJRMR7F04RK8WG2F48MSQ4ETH3JH1F9MV4F50.retarded-labs-usd send-many (list {to: 'SPQE3J7XMMK0DN0BWJZHGE6B05VDYQRXRMDV734D, amount: u690000000000000, memo: none} {to: 'SPAE4SFGGSKKH7NC49KQCHJFY9159DG24YHQCJVX, amount: u690000000000000, memo: none} {to: 'SP1PNSSXPYTNGKSBPTFM5E03QT1CKCKHVYH9WBP1, amount: u690000000000000, memo: none} {to: 'SP2T395ZMA7X6N3JQ5VRKCME0D4DZQVM84M8AAKT1, amount: u690000000000000, memo: none} {to: 'SPZVMHVVG5AD01C3KN9E8TF6BPQFRGM0N1W7E1P2, amount: u690000000000000, memo: none} {to: 'SP1HPB7YTZDXMZSZD51C113PQFAXKSNR0QYFFPWVC, amount: u690000000000000, memo: none} {to: 'SPCDCWBEZ9ZEK49BNMDE2MDMJ0E01W02H9SA4TVZ, amount: u690000000000000, memo: none} {to: 'SP2A0AHSWNYPAS1KRNMEFQMV8WQ2KZRRW8DZC8Z3K, amount: u690000000000000, memo: none} {to: 'SP000000000000000000002Q6VF78, amount: u690000000000000, memo: none} {to: 'SPWC45P8JQP1VG9NDNPJ6ZXPVZ4XXGK06GXR5XN3, amount: u690000000000000, memo: none} {to: 'SP15V20R21ERBNC5070QWF5SH1VKWPADVWC2RZRGV, amount: u690000000000000, memo: none} {to: 'SP1ARWZD4G0SZPADBFQ5DVSK93B6QKQ6DHK9G452P, amount: u690000000000000, memo: none} {to: 'SP1B46TPZD8Y3ETHGZYJAPHD9GHJK81K08WRB127X, amount: u690000000000000, memo: none} {to: 'SP2FA1H3K9FMY2CQ80WWT2JYMHZ5Z2B810AT41APW, amount: u690000000000000, memo: none} {to: 'SP238X3JD22HJBMWR8E7CKTF4JCBQ73BG9YS1DBH8, amount: u690000000000000, memo: none} {to: 'SP3WAAYXPC6WZNEC7SHGR36D32RJPZVXRR1BG0QSY, amount: u690000000000000, memo: none} {to: 'SP2E84S976Q7G1YQNBRFA22HJHPDES6HM6RKSZMH7, amount: u690000000000000, memo: none} {to: 'SP2XTD345MW8BENE2V6QV6SPBTY9G10GZEGXABPR4, amount: u690000000000000, memo: none} {to: 'SP3K0EE25S57TK269WJDYX9ZBEY763RFBX47TA69W, amount: u690000000000000, memo: none} {to: 'SP119F3JPW5AKFFKKTWEXE1RVD3TYQP8SG4GW80PT, amount: u690000000000000, memo: none} {to: 'SPR6K4VQ0JQN677W4GGCN5JTPN7XF7YTP7WKAJXH, amount: u690000000000000, memo: none} {to: 'SPBFPD0285PKTCTADGP9GX2JFE12R8ZXSCWRYW39, amount: u690000000000000, memo: none} {to: 'SP3QF8RJ3CE59RBAHC96YS6DRSVKYADCF2730P023, amount: u690000000000000, memo: none} {to: 'SP1FHC2XXJW3CQFNFZX60633E5WPWST4DBW8JFP66, amount: u690000000000000, memo: none} {to: 'SP1ZRTHK2HERS7AR0WS6JN73VQX3HHDFMY5EQWJBN, amount: u690000000000000, memo: none} {to: 'SP30A13XJEHMK81JVEHMS0FEHFENS1W5KEEFYJDVM, amount: u690000000000000, memo: none} {to: 'SPVR9PDHJHGJT59GE10E8QE2433YAZY6Z47EY13P, amount: u690000000000000, memo: none} {to: 'SP23JX6EVN9GK7A4EWWTEJTP6BP75R0SYJX7TV1D9, amount: u690000000000000, memo: none} {to: 'SP3658EQDEKG3RYGVE4H1KC3PAS8MRJCXPJN7CYHC, amount: u690000000000000, memo: none} {to: 'SPFWTZMGERSZVZZ7HX657X291YPNGFNR84E9VYPA, amount: u690000000000000, memo: none} {to: 'SPABSFFC2ZGXP328F8Q7RDRK96J728NFGD3PV23H, amount: u690000000000000, memo: none} {to: 'SP2WC112DEJR44WVAX5A2WZ21VCTTVMY000AJKKYT, amount: u690000000000000, memo: none} {to: 'SP2JWM4MB1SBY2FT3PG5PM0V12NW8Y4FK1XXWBHSF, amount: u690000000000000, memo: none} {to: 'SP4GZY6SJD3YF65E7QNZC4CTBYR60RJ4WF4079Z4, amount: u690000000000000, memo: none} {to: 'SP2NKRMP53H372KY60GARDCR04TCS3VB2BWGS474V, amount: u690000000000000, memo: none} {to: 'SP2KZ24AM4X9HGTG8314MS4VSY1CVAFH0G1KBZZ1D, amount: u690000000000000, memo: none} {to: 'SP7KZ2AFRRTP53WGKQWY9707Y0W61DK848J1EK2D, amount: u690000000000000, memo: none} {to: 'SP2RNHHQDTHGHPEVX83291K4AQZVGWEJ7WCQQDA9R, amount: u690000000000000, memo: none} {to: 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV, amount: u690000000000000, memo: none} {to: 'SP2SBT6D37033NTT0X5347YZYZ45MQTPFZR3G45V0, amount: u690000000000000, memo: none} {to: 'SP1P637C9NB6GSK9TY8AT8SN3QKH1WSV5ZVCZZSKS, amount: u690000000000000, memo: none} {to: 'SP2P8RJ42R8MP0AAJASTT7ST6VZ7GHCWR7PET3B21, amount: u690000000000000, memo: none} {to: 'SP3T8XVBX10T72WB2E41ZTS5NCY85WC6YMWR2QA6K, amount: u690000000000000, memo: none} {to: 'SP3WZ0B7PAXPRD8Y217DMKGPXESK5EXWWCA7G03TS, amount: u690000000000000, memo: none} {to: 'SP26BHRECCNJBG2G6A139HYJ4C226KTHX762WVN8N, amount: u690000000000000, memo: none} {to: 'SP3E4G6Z83YTZK1KXFVY6NHR805JEJ2GGYAZVZRTV, amount: u690000000000000, memo: none} {to: 'SPGSDWYMSA6FTYPMV542D19FTZ73A7WPYXKF1QWE, amount: u690000000000000, memo: none} {to: 'SP25DP4A9QDM42KC40EXTYQPMQCT1P0R5243GWEGS, amount: u690000000000000, memo: none} {to: 'SP3K650KFSY5Y2559C56TKZNSBZ2MKVDF0PCAYE78, amount: u690000000000000, memo: none} {to: 'SP34XGTEWMW2855HQFAJAM034WHDBMETAK51PKKYH, amount: u690000000000000, memo: none} {to: 'SP2GB0DWAXSAM4W5K475RC8GXRQE5YM9KEKSPYXYE, amount: u690000000000000, memo: none} {to: 'SPB8H6K97YY2TEWP726SG652KSJVNB6GJQ6RTMYE, amount: u690000000000000, memo: none} {to: 'SP1ZCYG0D3HCK2F7SY8VH9ZREB0JWCBSAPFNS8V5Z, amount: u690000000000000, memo: none} {to: 'SP16VAAGEE7XE3DFZZSFDW7T5SCJR1N0WY3CVQ00B, amount: u690000000000000, memo: none} {to: 'SP2EQ889E0BPKDE0K7SNS3DKV11T4685Z599032PM, amount: u690000000000000, memo: none} {to: 'SP1H49625Y264FMMNPN42QT92EQBEWJRT0EGP34FP, amount: u690000000000000, memo: none} {to: 'SP22441QWKAMN20Z16A4BVDC607C45GRH4K5C2AWE, amount: u690000000000000, memo: none} {to: 'SPC1KE74AZ8TT6GB8MXSY6W00MFNC29GDFXHPJX6, amount: u690000000000000, memo: none} {to: 'SP2HMNV7HAAWYBYDE3CPQMGZ14V137E78B53KEJV1, amount: u690000000000000, memo: none} {to: 'SP29CPZS40X3G7W6AYWB4873M27X22ZH3FJFMKZE1, amount: u690000000000000, memo: none} {to: 'SP1AQMCE6AKND8B8R5RV7QNJGC5CPEBPPYNY6QM9T, amount: u690000000000000, memo: none} {to: 'SPV3KF5YV0SXVEQ6V50SW2K93YQYKXHGD3SHFV35, amount: u690000000000000, memo: none} {to: 'SP2HHPWN1RSW34XSSSHC7XBH61Q23N02309AFMW52, amount: u690000000000000, memo: none} {to: 'SPBAC6ZCYDG0Z12F784TZ55CMHHW7FJJD93X1GEN, amount: u690000000000000, memo: none} {to: 'SP21ED8W24R13AP4CPEKWK5AZPS5XFFZ4N3PY5YX1, amount: u690000000000000, memo: none} {to: 'SPZ57T5M3ME7SWBDJKY2C8397K5VWXNMFDVCJ236, amount: u690000000000000, memo: none} {to: 'SP2FPTH274BXVB1E2HNXBAMGABV5TCSZTFNC16FR3, amount: u690000000000000, memo: none} {to: 'SP3VE90FRGYA66A6KKGF5W2W6K6CJSEY68M7PW3NP, amount: u690000000000000, memo: none} {to: 'SP2DCFHTZSY5YKSRHC7YRD1AD6HRA9CBZENCM4NGV, amount: u690000000000000, memo: none} {to: 'SP20Q56ZW7JKDPK7FSD2JYH9MAVB1165EV2PH0QGV, amount: u690000000000000, memo: none} {to: 'SP1454QJJZC5E7Q5D25R32Q1WYCGAN2MZHC1W349D, amount: u690000000000000, memo: none} {to: 'SP1Z8F1C9AVVRMQCV3ZW7CBSKPHV89MG275AC5PA0, amount: u690000000000000, memo: none} {to: 'SP3AP6DTCK6G65A4TK78J8J9NSV9DGMNFW0K7Q6YD, amount: u690000000000000, memo: none} {to: 'SP283BQ9PC3WW1TME4FK65SBDKPTRDM89QSWCHN3J, amount: u690000000000000, memo: none} {to: 'SP35MER4PHM6XGB99YDRQAK0M0JQ8F9CVF04VZ1VX, amount: u690000000000000, memo: none} {to: 'SP19ZRTPZ3Q77SFT8BMEDYGSWSZRV861V8T4G6VGM, amount: u690000000000000, memo: none} {to: 'SPHKNB2BHPZZJZAQND4ND16P9N5WRK4JCXDEBNEW, amount: u690000000000000, memo: none} {to: 'SPBN2RYDXB4231HJ2GHFFRGQ54X0SBMHFVRAVCW3, amount: u690000000000000, memo: none} {to: 'SP2QVKZ2GWP97TW4RNCT8TN65JRJPVAKERHYSS13E, amount: u690000000000000, memo: none} {to: 'SPQYFMS32D5KC1NT7YF5TA67TZ1Y64F97WQSZJ2P, amount: u690000000000000, memo: none} {to: 'SP3W83KG17KJZZXPDZQDTRQKQRGHNFZN410R9P02E, amount: u690000000000000, memo: none} {to: 'SP3SFKJFQJAFV5ZTQ9P0TB86AQE639ZDFADKHTQVS, amount: u690000000000000, memo: none} {to: 'SP2R826J48G3P8G7C2ZTQ9V72N6M6RBGD1BJTDMY4, amount: u690000000000000, memo: none} {to: 'SP1YGHETQ1ADA66DH9QD0XMK012W3FQHZ6CP2FT1W, amount: u690000000000000, memo: none} {to: 'SP3V67J2YXAPVGC2YEB7CP4FNGG2NXKB5GD45J2RC, amount: u690000000000000, memo: none} {to: 'SP25SF2MPZZS8Q20QA3VTYJXTHAHCRNM5MSZYDNB0, amount: u690000000000000, memo: none} {to: 'SP3WJ60NYCKAG0D9YPSPD5T74M9NM5VZW4WZM7QG7, amount: u690000000000000, memo: none} {to: 'SP2YDZB938V1QNSRN2XCCP8YTWEXVC89HK9DFYDCP, amount: u690000000000000, memo: none} {to: 'SP2H9Z97J0B3159H45ZFX6TVKS9RT3KVKDPGAHJC5, amount: u690000000000000, memo: none} {to: 'SP29QAJG65AKFHRD23415HBPQG4QQ4H41YSDKP4HZ, amount: u690000000000000, memo: none} {to: 'SP63SYHXYMCCEHQHXKHW3JN55V8YTPKM04GP329S, amount: u690000000000000, memo: none} {to: 'SPWR61YRMNPGX6JASY3ZR6SSE79ACV143YW1PCAN, amount: u690000000000000, memo: none} {to: 'SP1GR38P4KNCQRC1BD5HC97DP36W2MBZFZ4WC0NET, amount: u690000000000000, memo: none} {to: 'SP1Y0VRA8PCQGS1JJ8D43K7ZQADY71AYCXS48H3JR, amount: u690000000000000, memo: none} {to: 'SP260ZF58NPJZCJGB2K51327RW299BHES24W4ARKE, amount: u690000000000000, memo: none} {to: 'SP2BH9D4AKKANA8G8Q5ED1XBFGBRWNY0RS5PP20T5, amount: u690000000000000, memo: none} {to: 'SPN6EFJZRDM7P4FP3CWY3RC8RZ2RD69MQ9DXJBZT, amount: u690000000000000, memo: none} {to: 'SP1D67XVMN84D6QWXXQ5NY1DS9DCWN71W3MP00S2X, amount: u690000000000000, memo: none} {to: 'SPY4D6C43JJ9JHEYJKV9YNT5BE7GNN42DSTCBH10, amount: u690000000000000, memo: none} {to: 'SP68A2GDYFED1P932H1Z3J2NKP24D8WW486C6QWT, amount: u690000000000000, memo: none} {to: 'SP1CP6JGSVSZKTEN51W4N6MBBVHNDE3Z0YV3X5B91, amount: u690000000000000, memo: none} {to: 'SP2387TVHZ5X6TSCD6HNDA7N8ZC4M1XNYHFBHNWS5, amount: u690000000000000, memo: none} {to: 'SP1ZWG5WEND2QSYQ04DAP17A5RMDBG76NXQQ115SK, amount: u690000000000000, memo: none} {to: 'SP3J98KY1Q89VA6XY69CP6FJJW9S1ZRWRP7RKKF4R, amount: u690000000000000, memo: none} {to: 'SPGNRR2GG22EKH62N8DCW58YB4D1PVK8TP0KQTHD, amount: u690000000000000, memo: none} {to: 'SP1QAS390Q4A4AHFRF5MRJ6BRD73H8AWS93QNM84Y, amount: u690000000000000, memo: none} {to: 'SPJ353E6AFJY1MFNZ326EJ2BMD6RBN39K69X9X85, amount: u690000000000000, memo: none} {to: 'SP3ZCTZ0JDHXXCT63FZ8DC01PWJYCAB5EFP2ZH1X0, amount: u690000000000000, memo: none} {to: 'SP2DAYHJS9HYT3ND88JSFJWVG0X1JS7JXA0NG02EZ, amount: u690000000000000, memo: none} {to: 'SPWSGE1CDEHMM56SGMS9ZY3P91Z0G7YWD6R04KCA, amount: u690000000000000, memo: none} {to: 'SPXY0VFX761352VTJPAMNYTJYYA82A5DRH0VR57P, amount: u690000000000000, memo: none} {to: 'SP2N7VSJ2DT9NY438G3VDWYFP3WWBKYN46GQPHH6T, amount: u690000000000000, memo: none} {to: 'SP15JMFZY4S59PTKHB399KE78ST5CHEYE2S0NCBNM, amount: u690000000000000, memo: none} {to: 'SP13FVX0W0AWMMECJS9K1BJNWEKRY6G98M3ZGEJ3D, amount: u690000000000000, memo: none} {to: 'SP30EAHAMB9MYBCBDTAXNBBC1CCNR3XJHV9SDB1MS, amount: u690000000000000, memo: none} {to: 'SP16HBH1ECJ71E8VWYSSQKYN8ZT6S8DTBTAX02TRF, amount: u690000000000000, memo: none} {to: 'SP2ZN8DTVP101P42NN9MM6TJV83SWRQNGRZYEE2K0, amount: u690000000000000, memo: none} {to: 'SP2Q1AZMQDWH3M8DHJHVE1FC261QJ6Z9RC9ET9HGH, amount: u690000000000000, memo: none} {to: 'SP17PZJ9A8W29FGM8BRY96M0XDXE6PRZX9DJHB926, amount: u690000000000000, memo: none} {to: 'SP1X1TE6KX7HZ9T6NWP0V87WYHY1Z7BD92JYYKBCZ, amount: u690000000000000, memo: none} {to: 'SP2NTZ5ABMMMX1KYEHK3KYK5ZV6FKWV01CXRNYT44, amount: u690000000000000, memo: none} {to: 'SP31MKEBNQ80ZEAAMCBXY9BVE91XTMAZG80TTBYK8, amount: u690000000000000, memo: none} {to: 'SP2664YJ6Z7AWGKSGYG3MSDCCR3ZZREX3JH14TCCE, amount: u690000000000000, memo: none} {to: 'SP3EMZ5XM95XZRVFWB5M8JH3VRMMPJ8661WTT1M3T, amount: u690000000000000, memo: none} {to: 'SP1QYG7Q1NT7Y9X8GV4DQQYSM2X9DDVH304BVYF0Y, amount: u690000000000000, memo: none} {to: 'SP389APB4DHZ836P4AE9RJW7EKEZAPV5NPDNG7N46, amount: u690000000000000, memo: none} {to: 'SPVW6AV9A3H7G7P7S84GFP555E86B1SY6BE9DQPV, amount: u690000000000000, memo: none} {to: 'SP2ZMWSVZT0NZVZNJVE00JJK1SKK6JS2WJXFN835M, amount: u690000000000000, memo: none} {to: 'SP31JEKBEZGH2TJ9EG2TJDDYH78BB16PZZBPMKJW3, amount: u690000000000000, memo: none} {to: 'SP14W78Q821B3HQ3ED30624Z1F13X4JMFZY3N5SK4, amount: u690000000000000, memo: none} {to: 'SP3BTM1J6HS9BWG8A115GN7CRWYPF2KSKETDBNP4G, amount: u690000000000000, memo: none} {to: 'SP30RDYWYBCDH2R8NWX71XNGQFX064S6QMY5MBM1K, amount: u690000000000000, memo: none} {to: 'SP3JFEKTFHVC3B9RRQ46FNC8MFRZPHVYYTFWYRX6W, amount: u690000000000000, memo: none} {to: 'SP2KKNVN3TFK0DYDAW6E3HZVPTN5FETZZZ436MNG9, amount: u690000000000000, memo: none} {to: 'SP1PKKPBB3K60S4PD7545H7JK8AH0MZJEV9T4X15K, amount: u690000000000000, memo: none} {to: 'SP2W1FEY0Q180MWE1J8AZQ1GNCEVN6M0H9E5MC38G, amount: u690000000000000, memo: none} {to: 'SP3WYQMPRNTX8VTKKD4TVS2W7PEYYP3V3Y24KNQ4F, amount: u690000000000000, memo: none} {to: 'SPQ5Q6C96DMXJ4E7H5C1R2J9ZE3CESW2NWDPVGDP, amount: u690000000000000, memo: none} {to: 'SP12WM2X339SBV7J7DPHSJFP2754MDM1411PSN1FZ, amount: u690000000000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)
