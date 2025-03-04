;; Used to simulate mainnet migration from v1 to v2 in the test suite
;; Must be called after deploying migrate-v0-v1.clar

(define-data-var executed bool false)
(define-data-var executed-burn-mint bool false)
(define-data-var executed-reserve-data-update bool false)
(define-data-var executed-borrower-block-height bool false)

(define-data-var enabled bool true)
(define-constant deployer tx-sender)

;; TODO: to fetch off-chain
(define-constant borrowers (list
 { borrower: 'SP20XJSVQX6MMXK3QXZD3TJKB2AMFDWAW2PZQGZ69, new-height: u170655 }
 { borrower: 'SP1SC7DK4TG2X5P55D1EYTGMPD0X445SGSV1H1TQ9, new-height: u170387 }
 { borrower: 'SP1M2F96QM7VWGMMDZZ49554BWRZYSC7QD9KV7X60, new-height: u158718 }
 { borrower: 'SP2D8RP8J0EYMZPFTT0SS0YE4HR0JV6CBBAB9508F, new-height: u170980 }
 { borrower: 'SP39AHHCMG916GWSN5Y76HVCVGNJ17TPN8EQQC0C, new-height: u183988 }
 { borrower: 'SP35JTXYC99Q5XP12B44VMEYEDWWSKAGSF435KTZT, new-height: u168068 }
 { borrower: 'SPBVQ97925R5S67BAB4D4SHEBDFFX6TMDKAGE8AZ, new-height: u155639 }
 { borrower: 'SP35N08GFQWBNNRRN81R6T384QEC2YN0A2ZD0H6SP, new-height: u345048 }
 { borrower: 'SP8Q4FZW27NZ7B4777179YC5GFGKG003JFDBM6SW, new-height: u327400 }
 { borrower: 'SP3G1FYEP0DAWM0BTX446Y92HVT7RJ8KB0MBG6VMQ, new-height: u170687 }
 { borrower: 'SP1AZMDNVMPR13VYKVEXHFGCXP9JETA2W8G5YTPAQ, new-height: u152360 }
 { borrower: 'SP202M362AFPKY48WKB1SAR2X2VW659VBH4TVNHC, new-height: u300198 }
 { borrower: 'SPMHQGEV4YTPGA4MMSY3FCDR4PW0SNKKHTKEK275, new-height: u155456 }
 { borrower: 'SP3N0TGQW4GDYHCFZ6K7CS6W3JV0E5P7ZFJ99CRNV, new-height: u183920 }
 { borrower: 'SP2T5PNF09GZYH92BQMJGJAV0PZ8N1PPFAF3CWE2A, new-height: u167444 }
 { borrower: 'SP92Y7K97R51SMHDFY185NV8JNKGRHM214EHNF63, new-height: u310359 }
 { borrower: 'SP1SWFS8AR0DYJXZ4P3XW3RMNGVM3E0HNBSHBGPY2, new-height: u171834 }
 { borrower: 'SP3QFAX1BNWHS3ETCEFJHGYRCZ4BT9VW4NBFGAQQA, new-height: u167069 }
 { borrower: 'SP1317GKQJHCQETSFQZ9MS4YXKVBRR29MMXVFSQJY, new-height: u156378 }
 { borrower: 'SPQJN9008GBDXCPVS2CZSPXAPYV8251GZX1GX64R, new-height: u307913 }
 { borrower: 'SP22ARKWN5F6CCYXX5DYVJQCE2YSAPGEEYDZHYSVR, new-height: u155478 }
 { borrower: 'SP38GBVK5HEJ0MBH4CRJ9HQEW86HX0H9AP1HZ3SVZ, new-height: u170073 }
 { borrower: 'SP31SXJHBV3YN94HQX7NR7TV9RBM8NSNYAGXG9R6X, new-height: u170576 }
 { borrower: 'SP31XX9BP58NAFFZFC1N30NDP60TMPNGYREYT6X15, new-height: u167943 }
 { borrower: 'SP1W5SQ4WCQ7VCSY3Y5NQAC328K63YFB5YYRBGQJ2, new-height: u170399 }
 { borrower: 'SP1F7G9DVCD9JXXPFZMK5VDA1MQ932XCBXA0NCQ6K, new-height: u156384 }
 { borrower: 'SP1KKD2QHZSFPBR8T8833YR7PMZ655ECZ8JJPP25Z, new-height: u155787 }
 { borrower: 'SP1FTHMG0MTJ278RX4VY2FR21QNVB46AAV02Y62S8, new-height: u155336 }
 { borrower: 'SPBQ6QY471478FVZ2ECZ118JT3YAVF5CBXXQCEP2, new-height: u155546 }
 { borrower: 'SP3TR8BEX8M4B93ZDP06BFWW8SYDHANTYHKZ142FV, new-height: u155478 }
 { borrower: 'SP1SR794KR1W098E1RJR1JKPPX38ZH1NCDYXFJYTF, new-height: u165875 }
 { borrower: 'SP3YKKE23MAQA1CSQJGWXBKYXMVGGH3G6AYHHBXHR, new-height: u155937 }
 { borrower: 'SP3RFW3FH7890SJ2KJ1VETX9FN9Y4J1T4WF0QRDAH, new-height: u155577 }
 { borrower: 'SPDXRNJ3DHVXMM1DHVCNDY7ZG8BENGEA0DHXPATT, new-height: u170261 }
 { borrower: 'SP3YM926G158RV76VT9M2NCVE0V5RT76Y1ZMTNZQ8, new-height: u205649 }
 { borrower: 'SP3X2VA67GWQF583A7YNP2E9J3TD1MJAT9TQ0H8P, new-height: u157673 }
 { borrower: 'SP2FDSGHQ5NJYXX8EE3GEW1DD44YBMC00Z8KVVT65, new-height: u155232 }
 { borrower: 'SPK42JR8Q2VNVBC8SAM1M2BQ5SEZC0JPZ295Z62Z, new-height: u170146 }
 { borrower: 'SP3BYHB8JV8J50PTG46JNGD5FZSVEREEV6B1VX8M9, new-height: u155333 }
 { borrower: 'SP365FZS1S8642AGS4V3JC10KF79XQ9VEYFBXSPYT, new-height: u154899 }
 { borrower: 'SP17KYWCE38C81K43ESJ0R0REC2GTKZVJK927AQH0, new-height: u168783 }
 { borrower: 'SP2MGZ8M0XK3E8WZV2CZ3SY2DZEG8BAZXAX07M7MS, new-height: u155036 }
 { borrower: 'SP319BKQSXHAYK20CHBM0S52FRMVNJC3FARRRWA8X, new-height: u155240 }
 { borrower: 'SP1VVR95BWF35KY592602WX1YH0YG302CBT8AJWZZ, new-height: u285368 }
 { borrower: 'SP7F0N9E90XMA50F58CTHRT2598E56F6V3VPYXCQ, new-height: u152478 }
 { borrower: 'SPN0FMB91X65WPEMQ278NCWCZ14XSAT7MJ4J9543, new-height: u167112 }
 { borrower: 'SPXJMQ34NYCY0RQ5CB6X6BZQYV0FQ1TDMPR3CYT6, new-height: u344315 }
 { borrower: 'SP3HQAMGTNJTTDWC45BW75Q45H9Q02A3P8DDEX80S, new-height: u155249 }
 { borrower: 'SP2145N7YM7X8D68WWC5ACW00QF5G85FM1YGCKY1B, new-height: u204835 }
 { borrower: 'SPS4HWEXC0C1GK18YS02P7P4RHR35AT67B4YD0VV, new-height: u167697 }
 { borrower: 'SP1DMY09AC1716AQ4BQ6F9XC4QK5PRT0C4H3AN0SH, new-height: u321902 }
 { borrower: 'SP2XWGZ4XNGX3CBMJ60WB8WY5WWCBXAY21M80WT2Y, new-height: u171158 }
 { borrower: 'SP1DC9TAV0P22SHK2DN2PAQ8A8PZXKKFWR6NG4G1K, new-height: u155255 }
 { borrower: 'SPJGSWR5JG7D03D55XP2HGJQC03BVBAEWZ19CEE4, new-height: u204835 }
 { borrower: 'SP1T2FTMXH9QFBKBG45XCKPT0A36SV2KEM88XERWJ, new-height: u204835 }
 { borrower: 'SP2R0T61X06QHGQ67SNTF6M533QB21FBYWY4JFG1B, new-height: u152135 }
 { borrower: 'SP13R7HYNK9HXZSC3P3BSYHVFZA84CB6M697JC46W, new-height: u204835 }
 { borrower: 'SP1GR3KAWAMASAP3VM3A0B7S0KNTH28GBP5QXM7Z0, new-height: u165438 }
 { borrower: 'SP23YTQDD36TXW1Z3CFKGHWBGDBB4R2B0GFTZ649Q, new-height: u155036 }
 { borrower: 'SP144F4JWAGREMXDNJ3TAEN3K5XP30RGB4YRQEAHK, new-height: u155049 }
 { borrower: 'SP15C511T142ZSVJ3SMZP9K8SH5XN9MFB7Q7ZZTJ0, new-height: u172382 }
 { borrower: 'SPKA8TZZ2GJK06RSQ2JFJ0J7X85D8P4XX16C8MX5, new-height: u252138 }
 { borrower: 'SP3N4K1X8MTBF86E4ZBCXXEJNRTKASBXJK7009QTQ, new-height: u204642 }
 { borrower: 'SP35Q63GH5CYG639VZVCXP2M7PHGDAR20ZXJK4DWX, new-height: u204835 }
 { borrower: 'SP30B64TWM1TB8MBRJJ9E8PTKP49G3T44RJF2S9GN, new-height: u204835 }
 { borrower: 'SP3EBHKH2V5ZBS98VZDK5QCKSEG3THTZ074SMERCD, new-height: u154919 }
 { borrower: 'SP2HXTYPDWS59MBTXC4DDYXFYM0V83F2ZW2WFNWK7, new-height: u315932 }
 { borrower: 'SP32P38F0SNN42R5B80PSZE97A635F2C91V76QAYY, new-height: u307008 }
 { borrower: 'SP3TF0J5PW51AFPM5JTW8ZYFC1PK5Q2FV321Q13TC, new-height: u246169 }
 { borrower: 'SP31E8EP537PDVF304V83KJJX4H2TN2Z88DQ1KPX5, new-height: u154635 }
 { borrower: 'SP2FXB6AW37VTZX6RF4Y6SHA2RG5CAY3M219ZACHP, new-height: u154674 }
 { borrower: 'SP31ZA4DFKMX57WB4J3HBTGSF91KFJM1Y3MRE8ZJ2, new-height: u154763 }
 { borrower: 'SP1H5Z2WN165X46EQZ41EB9XXZ9KJ98S7CA1YP16G, new-height: u212042 }
 { borrower: 'SP2DSQ3SAPA28WH5CVWMZVF99S9RX3T4R98Y96DJJ, new-height: u287332 }
 { borrower: 'SP27K5VXGG9512F3Z1JCE5NS4NDC72KAAZD929ABS, new-height: u169220 }
 { borrower: 'SP3PYWTSJA8X2ANJ0GFAXV8QXTDR3KX5DE7TT1GW7, new-height: u164816 }
 { borrower: 'SP1K3PTTYNAF6RNKJ77Q7NZ62QTK99NGYB3FYNVZ0, new-height: u154903 }
 { borrower: 'SP3XGAZ3QKB0ZVJ73ZF1X4E0H4MDE3HGQ404XK58E, new-height: u169648 }
 { borrower: 'SP25X4ZVYPKA7W65RN9YFSMRM5XJ77JZAX9JAQNX, new-height: u154480 }
 { borrower: 'SPGZPVBKCH1ZV7R31ZW7E9R61E2CV7ABW0XGEJWP, new-height: u166791 }
 { borrower: 'SP3H17JCG9W1RP5H8Z09X8FJA3PF2WJ14STMSEVZ3, new-height: u166929 }
 { borrower: 'SP1GKBCNG7F0TF6R9NQQRH1R6BMQZZW5DPYW1C515, new-height: u163687 }
 { borrower: 'SP1P9NVFD9FARHN7SH9NB417YC9FG3SQNNZBZ8R26, new-height: u327770 }
 { borrower: 'SP2ADCJ6606CFHERS3HKABWB6PF5XBANXBQ4GSE86, new-height: u168998 }
 { borrower: 'SPZAEJRJ6FA2X8KTFGZ7ZPJJ12N4HST9HYSE1V2R, new-height: u155470 }
 { borrower: 'SPS2CAE9DS91XHXGH9TAWZAA0SNQRWFYCNC8JG2H, new-height: u204293 }
 { borrower: 'SP1VNCNJHTEFRN1D2NN4XZ78T7TKZJTRT2MNRBW2Z, new-height: u152380 }
 { borrower: 'SP3RPKCYN57DMKKKZWPB91VQ79GS1FEYB0G5NCCSK, new-height: u170719 }
 { borrower: 'SP2Q1X7A5RHEN6XXC5BH4MKGE4S7Y6QZHY3ZZTVYV, new-height: u169260 }
 { borrower: 'SP1JJTJAR37HBHFBV73GFRMG07XYPH3VEKWTWT7W1, new-height: u167052 }
 { borrower: 'SP3XZ9701DM8XEAXZT86A0JC3DMB70CPKD4X13KKD, new-height: u206889 }
 { borrower: 'SP1S2S18XDQ71A92JVN898S621XAQBDQMY6WT4EA4, new-height: u154190 }
 { borrower: 'SP2JZH30520DFFS4Z15RY0Q9ZXEFNF6E32S7XZ1YK, new-height: u186921 }
 { borrower: 'SP1K96254R3KP5TRT5N2X64FB12VMHX6MYS0BQGYQ, new-height: u164056 }
 { borrower: 'SP3EHQXZK6SV1XRP95RNHR74RBXZ9YCAN8YZC4AWA, new-height: u155910 }
 { borrower: 'SP3VF7YG6PXV18WVWQZR3P64AP47XTB3M97BBKFR2, new-height: u164078 }
 { borrower: 'SP3WH4VDCB81VY2CGN0Z7XSJH8YSNF8R9B3E51VB2, new-height: u154480 }
 { borrower: 'SP355676T5QBZ4HPWRW7B3G9P989DZ6DA1YY8VMD, new-height: u154510 }
 { borrower: 'SP3QG9M0AXTS3X7ZYHXMK6F8VXCQJCBKF31AEK10B, new-height: u297848 }
 { borrower: 'SPB51186R8WZZBDJKC5EJDDWXQQJEWQ15DVQMFJC, new-height: u169456 }
 { borrower: 'SP1HVG66BYR7ZW38S2DCYYD9BAKBQ7C1JQJGXWC69, new-height: u169470 }
 { borrower: 'SPHE0PHNF1E1Z4YSVSMCT72DQHMSQQBGZEW5JQKB, new-height: u170233 }
 { borrower: 'SP37E46M4GR5X7A1KGE3B3V7TCVWBJCZCGQH0PS40, new-height: u163109 }
 { borrower: 'SP3404N547SXGRJ4QMHC7TKT4DSBAKF8K5JZ1Z36K, new-height: u154350 }
 { borrower: 'SP1HVJNSBKK54E2NDTZSS240Z2Z0RB67B2ZDT9E43, new-height: u155125 }
 { borrower: 'SP16WRER12NZMAV63M62FEXHMVWS8V2Q74MHSG04Q, new-height: u325354 }
 { borrower: 'SP55B8GPX15Z85277DK2YNARA6P1EHWP6FJZC1X1, new-height: u154196 }
 { borrower: 'SP6SVZRG52SS35ANKZR0RTBE0CN982E3AJZZKZF3, new-height: u162927 }
 { borrower: 'SP2XJAWTQH9MJ1FV1QGP12KP3Q1SZAYT3RTBJBDPK, new-height: u167086 }
 { borrower: 'SP360GVPPMMHWM0BTZCC381GC1881MZEXJHJRAJQJ, new-height: u183693 }
 { borrower: 'SP3G0JPRH9K2VP42P0VY8NYSTZFH0KB0ESXRNB497, new-height: u167536 }
 { borrower: 'SP2SCZ33HRSDR6S6JFKKJV2ZJCR7623B02WABHA84, new-height: u162928 }
 { borrower: 'SP2642699XFS6DQ6E2MB5BZ2V7F61EPZCZQH7HZPT, new-height: u168412 }
 { borrower: 'SP2BMH1SK80DRA9XZZEPKW057RVHGA0C2B9VZXHBC, new-height: u195009 }
 { borrower: 'SP3PJYP3861PST63S9YBA8TKJRC8YFQ46C1T7R9QH, new-height: u208238 }
 { borrower: 'SP2BNY111K73715XKP1EBEBVVRWSNMMV1H42SJHZ, new-height: u197608 }
 { borrower: 'SP3H2MFMZMK754K3YM3CBMVQ8QYFZEHBF90TSXQ6B, new-height: u155709 }
 { borrower: 'SP36Q34V1Y55ZB4E675GX5CPHMZ62P5EMP7W3D668, new-height: u223412 }
 { borrower: 'SP2E0BGKYVPX1MVNECTKM6J7VP2JYH4TRN3KXA950, new-height: u170598 }
 { borrower: 'SP3486ZKTPK7SGSBPF8YXQ9B00W5KARM6T8FCDZPM, new-height: u153834 }
 { borrower: 'SP3JCAF094F0PHA7S85XAYAZM5Z4GWM9VZQ6GTMGP, new-height: u231654 }
 { borrower: 'SP2917XJ23T0WQM0TXQWEPSVTC113H7KC67A2R8JP, new-height: u167446 }
 { borrower: 'SP3MS5H6FDB9KAE92AMRDVZBGYWSXW8GX71X7A2P5, new-height: u154032 }
 { borrower: 'SP3P1TCXN3FP3V79YWXC49F5X2HYKS39CMCP5FEHN, new-height: u173398 }
 { borrower: 'SP1HDC7VN41SYNQGSVXNVYNDZNXMMEZ0MH0R527B3, new-height: u156385 }
 { borrower: 'SP2YADQRAJ4468KEX4CYD4MQPF0S6QYFT5BRA22J0, new-height: u269011 }
 { borrower: 'SP3YHVAR9CP9QD2D2HNJ5RH7NT5GXE2X4GXNX4YPX, new-height: u160390 }
 { borrower: 'SP379QM3CHY64YERK62MFYBDWVAX16RP3GA9KG7J6, new-height: u160778 }
 { borrower: 'SP3DW9KTFJJNE28EMSSSAJ5XMRRTZFQNW33X6P5RT, new-height: u161976 }
 { borrower: 'SP39RQFWJZ0VC7P8RW2066D5E5GZ8S4YA4CK4R11W, new-height: u155485 }
 { borrower: 'SP39C67QEXVA0W12ZHG14H5RXWYMEDVP2XQPQSMXT, new-height: u154017 }
 { borrower: 'SP3YEVF4WR00WN2SENM59EJKPVP2NWBR8QX42ZJA1, new-height: u169744 }
 { borrower: 'SP27GTERN6CCBBB81K54KJFHR2JEEG13HRS6NPHBD, new-height: u153889 }
 { borrower: 'SP2E3MKFV0ARX4SXDEEJ1RM4CG5X40E2RFFYB6554, new-height: u155872 }
 { borrower: 'SPH85B3SDQBT0VT6GN1KKR0J2BDKBWACYGNAVXHN, new-height: u153631 }
 { borrower: 'SP32GA720YCP6JTS6PBSQSTC5N4DNB6A5JDRJXZHK, new-height: u209608 }
 { borrower: 'SP11WB7FSYTQ9V04H54F4JR36616R4SNK8PH8RQ76, new-height: u166770 }
 { borrower: 'SP1ED2H5ENVTRW8NG3BQ47V3M4W14G71WH4YASD5B, new-height: u152914 }
 { borrower: 'SP172ZXH6NM1C47HA60APXRFMKFFHS9MFMEM7XT0G, new-height: u196464 }
 { borrower: 'SP2B0EJEMA0AGY9C986WQZRG9BAYMYMTWT990JSER, new-height: u303886 }
 { borrower: 'SP30YYW07A4SSESMRVBR1VH6XCBXYERHEJ9P9SAB1, new-height: u153730 }
 { borrower: 'SP12NT59RP062GR9DFZXEV61YTJD5N1G2PC1YKE83, new-height: u161969 }
 { borrower: 'SP11C1T880E8A4TVYSYVFXXMSSE10ZS429N99Q5AZ, new-height: u161976 }
 { borrower: 'SP2HMHC2JNXJ9363MDE1G2S4CTJSMDCXG4AG50VQX, new-height: u253768 }
 { borrower: 'SP1EM9A5C61ME8X731NKN82HQGEEY61K44YG9QDRG, new-height: u153456 }
 { borrower: 'SP1K0HS27EEQ2VHJ5TC6Y9D13CKVM90F6XN1PS558, new-height: u165892 }
 { borrower: 'SP3T4GE6V1Y2MJ0EMTMC0FKHMX27S8YK8KGFEX7M9, new-height: u153729 }
 { borrower: 'SP2GEHNS7HCJSNQP59S6XNWYN21YHWFZE1CXN0BFY, new-height: u161969 }
 { borrower: 'SP1W2ZYVWM974TFQBQ0QKM8CG6YHACJKVSA47K0GC, new-height: u170121 }
 { borrower: 'SPCPAPDGA87BXQWMDQPM5DHKW9HM5XTXWWDP9P78, new-height: u160490 }
 { borrower: 'SP1XSZW5YHS02PW82FRQV9HXH3MD0GRJFQ08X7RMS, new-height: u162349 }
 { borrower: 'SP22W36VNAT5GDVDFZ2SJJM9Q4PN7W1VKZ00MSRVK, new-height: u161976 }
 { borrower: 'SP37278Y5HKS9WPVTTK2V14ME1ZXBMC63B8FYQXTN, new-height: u152178 }
 { borrower: 'SP7TEF3PAXCQHZF4N5PT68GWQ5PGWR6VDNWQ5CYK, new-height: u288404 }
 { borrower: 'SP2X5X4HSR9ABHSY60SR3JQXE7SDXQQVEKKKVAVP1, new-height: u153367 }
 { borrower: 'SP3T4343SXGSQ0QGBDME836JYRS7JWE5HCC59VGZQ, new-height: u153531 }
 { borrower: 'SPC6G4B6AWB3Q72EDWNAKGAR2QGZP46RSCWQPPBK, new-height: u154539 }
 { borrower: 'SP37S80Z9WG22KG3KHRE1P4SCTSR2ZWQX9Z04YEXY, new-height: u261146 }
 { borrower: 'SPVSDAKF4GM3D7VZB2RNRPVDMECVDSJCHYG8FEHJ, new-height: u155682 }
 { borrower: 'SP13N23VJPMDJF838VTKKN8A0Y53MK46CF3726X4A, new-height: u153888 }
 { borrower: 'SP17KV2ZDVGN94KNXTPA9PAR0Q9EZBM623T63WN1R, new-height: u281352 }
 { borrower: 'SP33JS3FEPHZ0254MX17SK863QE1MNTJHSEDY94RF, new-height: u167033 }
 { borrower: 'SP1GF27KKQR481ASDXC92DX3AN7BVY0MTN36ES19N, new-height: u331803 }
 { borrower: 'SP2S7GTAT2EZ2MM5EFV4WTMZ88C5DNG13924B7NMN, new-height: u153231 }
 { borrower: 'SP3H7QV2A6H1CBH7XV6CF3C9N1DABZ20Q7GRMR4G2, new-height: u153321 }
 { borrower: 'SP1SHNXDRWV9WHB18GTFK4GEFMMG2JC5X7WYVCBD2, new-height: u343387 }
 { borrower: 'SP23ZSH34VFD9WC6FVWYNKJAVME1SN89ZWHHR5NCC, new-height: u154808 }
 { borrower: 'SP18T8G59THD4TZM9E976SQY0F4926C6H708R4RG4, new-height: u153919 }
 { borrower: 'SP3YDJ3KH7ER26GZB08XJF9ZSZ54V1XSXVJ1NBHE6, new-height: u161632 }
 { borrower: 'SP26RBTJTMX7NJRM72ZT6HBCA56ACKC7QP6RQYAXY, new-height: u153517 }
 { borrower: 'SPZCY64MG4J3BNCMPE8THZST36QV5EYTEWAVR4C6, new-height: u153853 }
 { borrower: 'SP7TYMCHNJJ0F8FQPXSN2B7TT90V9798G2PQ2CN3, new-height: u170748 }
 { borrower: 'SP3M9H338NVTBDYZD4KKWK67AR87ATZ3F9PQ0BH9T, new-height: u153241 }
 { borrower: 'SPD035CRTEXCYF6WMFZVNPPG0965TZM74NPSWXB6, new-height: u153504 }
 { borrower: 'SP3W1EY9XBBCP2RG1J6A42WJNP4FAK4D8SVT4AB5V, new-height: u269492 }
 { borrower: 'SP102FPDQSDE9JZZV1V8K51SY4WWJMV6ZQZ4MT3MZ, new-height: u231830 }
 { borrower: 'SP39HZWWMWBHECGZ8BDFGSJ0310V38QP6BCWN83F, new-height: u161796 }
 { borrower: 'SP2591N54T6FTX1YJND3TKDY5TB1RWFFWXZYW9XZ, new-height: u153543 }
 { borrower: 'SP2XE0W323XF3EZETK5VHXJYKE84VWPK50ZMB31S1, new-height: u169551 }
 { borrower: 'SPQHN087TCXJNA34PHDVGTFXTE3WMA8KPBRTX1X5, new-height: u153543 }
 { borrower: 'SPT7YVVS93NGKGVK4EGC6WP04ZBKD3Q67MZ4Z0H3, new-height: u171029 }
 { borrower: 'SP17MA2G8RKVR3QHXGZ60V187DVVRT58Q35K91T3C, new-height: u265986 }
 { borrower: 'SP39RX0A0Y53RRQPJ70HGQZY6JJ25ATXE15AK8KVQ, new-height: u184998 }
 { borrower: 'SPY472EQXTPGGTKQJA30B930NR8XBMJJ6HZSS4PV, new-height: u181928 }
 { borrower: 'SP1X0M0CE2J5XZ8A7DGTKHWZQMN5ZFRP7H5ZJJ97B, new-height: u164630 }
 { borrower: 'SP1SG8ZPWC51YPDH495G5YX9NZZE8A84WSANX7HP6, new-height: u161118 }
 { borrower: 'SP10Q0MJKXWXJ2FH9GZPSJXHJX4K2ERET5TDJQBC5, new-height: u154073 }
 { borrower: 'SPZZSPRJQBVNJ0W888ET23XA7XJ33WR4835SDNF1, new-height: u153215 }
 { borrower: 'SP1HXT635AVD4MWFGNYEC79YG4TXS5QJE9NTB3T2A, new-height: u165847 }
 { borrower: 'SP2EDRYCPGTS32HZAGWV54RAVA2GTW0WPBP4HGCXR, new-height: u184090 }
 { borrower: 'SPAM1EBK881V1GP2X5D0W0NCTFQ81SK18RBRTF6J, new-height: u153138 }
 { borrower: 'SP3VRPTRSDB10TXGY3XTJ0KGNGS15H7BTKZPQTCEP, new-height: u155595 }
 { borrower: 'SP1AVKGHDB8W0C0WKA65H68HZPY45TRTMXYZV57AK, new-height: u153309 }
 { borrower: 'SP214CGYXQCBJWA41Z4T3N8MM39G9WWR6AHYKRJFK, new-height: u153543 }
 { borrower: 'SP1EQGZT0WN75N5AMJH2C40N5GBJTEVY9E6ZY8EH3, new-height: u259139 }
 { borrower: 'SP2J6Y09JMFWWZCT4VJX0BA5W7A9HZP5EX96Y6VZY, new-height: u187484 }
 { borrower: 'SPQ9HXJ0XJ84QXEZACDNAYE2C6T58WAYW6MG6N5Z, new-height: u153276 }
 { borrower: 'SP3VM8F6FKS3810M3NVE6GZ937BJXZGMVKZPVT1E2, new-height: u166240 }
 { borrower: 'SP2SGTG124NX7XPXFSTD47T77N0K5KX7DGFT2SRV8, new-height: u155927 }
 { borrower: 'SP1HNQH0FW7N5QWYEF77SGRZSDPHCV39TY3SJN8B1, new-height: u153361 }
))

(define-public (set-borrowers-block-height)
  (begin
    ;; TODO: remove 
    (asserts! false (err u1))
    (asserts! (var-get enabled) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))
    (asserts! (not (var-get executed-borrower-block-height)) (err u10))
    ;; enabled access
    (try! (contract-call? .pool-reserve-data set-approved-contract (as-contract tx-sender) true))

    ;; set to last updated block height of the v2 version for borrowers
    ;; only addr-2 is a borrower in this case
    (try! (fold check-err (map set-ststx-user-burn-block-height-lambda borrowers) (ok true)))

    ;; disable access
    (try! (contract-call? .pool-reserve-data set-approved-contract (as-contract tx-sender) false))

    (var-set executed-borrower-block-height true)
    (ok true)
  )
)

(define-private (set-ststx-user-burn-block-height-lambda (ststx-borrower (tuple (borrower principal) (new-height uint))))
  (set-user-burn-block-height-to-stacks-block-height
    (get borrower ststx-borrower)
    'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
    (get new-height ststx-borrower))
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

(define-private (set-user-burn-block-height-to-stacks-block-height
  (account principal)
  (asset principal)
  (new-stacks-block-height uint))
  (begin
    (try!
      (contract-call? .pool-reserve-data set-user-reserve-data
        account
        asset
          (merge
            (unwrap-panic (contract-call? .pool-reserve-data get-user-reserve-data-read account asset))
            { last-updated-block: new-stacks-block-height })))
    (ok true)
  )
)

(define-read-only (can-execute)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (ok (not (var-get executed)))
  )
)

(define-public (disable)
  (begin
    (asserts! (is-eq deployer tx-sender) (err u11))
    (ok (var-set enabled false))
  )
)

;; (run-update)
;; (burn-mint-zststx)