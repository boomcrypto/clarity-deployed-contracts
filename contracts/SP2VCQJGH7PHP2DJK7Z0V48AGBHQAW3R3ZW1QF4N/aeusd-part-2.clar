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
 { borrower: 'SPPXHPBYCRMJ8K7FYS5SZAJ3C17QP9T1XCTA0941, new-height: u166335 }
 { borrower: 'SPN0FMB91X65WPEMQ278NCWCZ14XSAT7MJ4J9543, new-height: u166448 }
 { borrower: 'SP2R29BCJZQYRNP11DDWB71V2G712927EM31ZBGR9, new-height: u301910 }
 { borrower: 'SPBZ053RNY57AD40TRVMQ52GKZA86HC3959CZBV3, new-height: u155214 }
 { borrower: 'SP1WT0MNXRA8Z0TEE7FS4Y836HQ62WR0ZPXG31T51, new-height: u164400 }
 { borrower: 'SP1DMY09AC1716AQ4BQ6F9XC4QK5PRT0C4H3AN0SH, new-height: u170350 }
 { borrower: 'SP2XWGZ4XNGX3CBMJ60WB8WY5WWCBXAY21M80WT2Y, new-height: u156773 }
 { borrower: 'SP22TS112NMSK54WGFR7HVB5320KJHAPH2A6EFHF7, new-height: u165701 }
 { borrower: 'SP2925X9ZAQJ8BCZDJXD591YVR65JCQAM18SHKCPB, new-height: u155264 }
 { borrower: 'SP1WTRVC2B8NQTSFCPDKVV2WGD02NMHCDRBX9X22K, new-height: u168710 }
 { borrower: 'SP305DH1G931D4TR5SD2MW8S60QYWVVX50K7R1CAP, new-height: u165481 }
 { borrower: 'SP37X5NF39N68F48THEJ8FFB6HQ0KF988ADQFGXH5, new-height: u254782 }
 { borrower: 'SPK40QN3YCT0CHT2DFC17W7NG54FPYCHGN41ACQV, new-height: u165444 }
 { borrower: 'SP2Z88KHPRY9ECF9EZWS957A9TYTNGD65EMF2W02G, new-height: u154689 }
 { borrower: 'SP1Q1PVYXM0F4VFP8WQ7237W2SP25RY250KWDQ71A, new-height: u172571 }
 { borrower: 'SP2ASBXYH8JDHA7CTG07BEC9BD9K4HMGV2KF6HBJP, new-height: u157848 }
 { borrower: 'SP3W6S2T1MSDXF0HF2V8KWJZEFNAXM8HQZB5ATC50, new-height: u154987 }
 { borrower: 'SPKJ67P9BDZSES48MM3S4AWQCRR2N6R5F5284K66, new-height: u151303 }
 { borrower: 'SP3NW880NAT0N9K35Y0Y3MKE3F3HGKAS2AN2BF697, new-height: u154528 }
 { borrower: 'SPRXA4K7C0CS0DYRC85M03JFGVBK7WX9BB83BV0Z, new-height: u175557 }
 { borrower: 'SP24GYD8ZF3RN0B359BD29WF2FBZEKBNA9KWP5H02, new-height: u154591 }
 { borrower: 'SPXRWYCBABERSTKC2XNS4M9QMQFSR907SWR3582S, new-height: u154650 }
 { borrower: 'SP2WC112DEJR44WVAX5A2WZ21VCTTVMY000AJKKYT, new-height: u204036 }
 { borrower: 'SP24Z7C1VBBEQ8Y988E6CCR42MW8F7D37BVKK01TA, new-height: u164589 }
 { borrower: 'SP3ZJXZ7321QH9NWJAYEN27CEX1SR3HT7TY7Y11TT, new-height: u155030 }
 { borrower: 'SP3BT3ZND2FKPPB6F7PK8S9JKK5YJ4WG8C7ZVSNNC, new-height: u168577 }
 { borrower: 'SP1C4ZN118N6TV5B375WJJWW0Y7PE919FSN9S2PGQ, new-height: u152513 }
 { borrower: 'SP2RCA8KBFGXY0FPJM7B96D2FNSKD1F4V3ZBDK8DY, new-height: u312605 }
 { borrower: 'SPAPJ8MX052QRES5P4WRFZRYZA9Z2QGVNT7KV4K5, new-height: u181320 }
 { borrower: 'SP27JGYKJD4V1K6Z1H2TERBRA62JB6D4EG7HR1Y76, new-height: u183679 }
 { borrower: 'SP2VR35TSYTE36FD0QX856MC5621NNTK4BWERZGY, new-height: u170380 }
 { borrower: 'SP7EFV7NZYD22S027E32NZE7N0FYRJW8K2PX1Z40, new-height: u164561 }
 { borrower: 'SP36C0SC6Y0Y5EJWR51NDGKWQSQSV1H5DT3RB9K1G, new-height: u154983 }
 { borrower: 'SP1QBRG3HG4EGKYF69E0Y1RE1WANC0NV94CF0Z2PY, new-height: u163495 }
 { borrower: 'SP1PSTA73FRSRK0KZAWBCM9KRXHVE3RY255E3VZ3N, new-height: u167428 }
 { borrower: 'SPZBXP3450SR8BMF8K1H6RKMS16CPP16QSTV9S32, new-height: u172213 }
 { borrower: 'SP37E46M4GR5X7A1KGE3B3V7TCVWBJCZCGQH0PS40, new-height: u222747 }
 { borrower: 'SP3045VHS30MW2T425PMPD7FABPHNTR47HVZGFE90, new-height: u213035 }
 { borrower: 'SP2NHT6DXQ1CEB74WZQ86A424DR8ZZNGESTX3WK6, new-height: u186688 }
 { borrower: 'SP2JVB44M39020KH1RX84JCXC3PZA58VDZ7ZK35GK, new-height: u290548 }
 { borrower: 'SP3MWVV1MC6XG0KB0YDBP2MF8FFTNBP6762Z6VRBW, new-height: u154411 }
 { borrower: 'SP2C7P94NSSYFXSJ2NTPZKJ081BMQNB38EWM0F2FX, new-height: u169978 }
 { borrower: 'SP2BMH1SK80DRA9XZZEPKW057RVHGA0C2B9VZXHBC, new-height: u191234 }
 { borrower: 'SP2BEFSB43KR4M6C9117SA2A6T4SA6H0X1XDZF716, new-height: u150138 }
 { borrower: 'SP1FRV07JWJCK8EJ37GM5SP92C9FXR5AND211HQC3, new-height: u160745 }
 { borrower: 'SP31RM6SWEJ787WADZPHGWNP7XMH463HCX4CYX96A, new-height: u312660 }
 { borrower: 'SPKPDKHT2TH732Q4FZCM3EBS5WFWAT96B5R258S7, new-height: u291235 }
 { borrower: 'SP234NYXB20YQBVXANCXFAETTN214VHHGZ3AVTCED, new-height: u288700 }
 { borrower: 'SP3YHVAR9CP9QD2D2HNJ5RH7NT5GXE2X4GXNX4YPX, new-height: u172192 }
 { borrower: 'SP375EMBBESRAHKNP9FEWMSS6DYCGB2QZVSG8VZ3J, new-height: u204449 }
 { borrower: 'SP3GZYDAT52VPQBAQVE6Z2KDHNG0X9RQR88JYFPS4, new-height: u162421 }
 { borrower: 'SP1FC4XP3KC8083WB8SB6GMVETKG2TXH9KGX98QFE, new-height: u181240 }
 { borrower: 'SP2RFGZ9WWXV3CZAR9QR94FHJ1WVZ59SF8J6QEA0C, new-height: u167698 }
 { borrower: 'SP3YEVF4WR00WN2SENM59EJKPVP2NWBR8QX42ZJA1, new-height: u152295 }
 { borrower: 'SPEB3YJGJ7AZ5RAEJCB0HPK0ACRECFT6KX9075EW, new-height: u153759 }
 { borrower: 'SP3M1H9S2YMCXP7A2K25PPF8J4EFJ1DWBRWYA7SB9, new-height: u151977 }
 { borrower: 'SP32ZYEZGWHHFQ5RX2WMFVDXR77C5WWQP4EK7E6HC, new-height: u204949 }
 { borrower: 'SP10VD0X3X2MBYZF52M25Q79QSM3JAB6HBADQRAVC, new-height: u153549 }
 { borrower: 'SP2HMHC2JNXJ9363MDE1G2S4CTJSMDCXG4AG50VQX, new-height: u166522 }
 { borrower: 'SP1SM4F13P8RDRABXAPFAFZJ0NZYJT5HFE70AY9ZG, new-height: u151141 }
 { borrower: 'SPYJ7JAWA02WSRH51ZSFYVBKQ80H6B3G9K3B7CKZ, new-height: u186993 }
 { borrower: 'SP1XPCCJE4NR82X6D8PX32NF1KAYYM36B5T83J6GP, new-height: u143738 }
 { borrower: 'SP3T4GE6V1Y2MJ0EMTMC0FKHMX27S8YK8KGFEX7M9, new-height: u143686 }
 { borrower: 'SP1W2ZYVWM974TFQBQ0QKM8CG6YHACJKVSA47K0GC, new-height: u150138 }
 { borrower: 'SP2VKV3A239D5117VEWG39FNYC2FKK6915WM5RDZF, new-height: u183693 }
 { borrower: 'SP3G5RZETXZ4WB7BWCMF57CF7DSR56M0BHE32VB9E, new-height: u198738 }
 { borrower: 'SP2WHHNS0QFZKE4J2V0PMJ9X4GHKXA6NTCMXX36AF, new-height: u295332 }
 { borrower: 'SP3795C9QYT13ZC1AGMPP9FQCYES5MP8XHRS6AK8N, new-height: u153244 }
 { borrower: 'SP3W1EY9XBBCP2RG1J6A42WJNP4FAK4D8SVT4AB5V, new-height: u269133 }
 { borrower: 'SP2RBQNS29P5YE0RB1HC9GVW3JCQCFEX8HFJXGC4A, new-height: u164365 }
 { borrower: 'SP1HXT635AVD4MWFGNYEC79YG4TXS5QJE9NTB3T2A, new-height: u270145 }
 { borrower: 'SP21BKCJC80FR7T55Z0ZTKGP7BC8HJV6B99T4BM34, new-height: u161278 }
 { borrower: 'SP1454QJJZC5E7Q5D25R32Q1WYCGAN2MZHC1W349D, new-height: u163205 }
 { borrower: 'SPK3P8E11MGWEN3HNY2T5W7MKNMDDF21WWHZ6FRB, new-height: u154583 }
 { borrower: 'SPFJQ1HKXPHNPK9RWWT6V30B9HRA6HJC0QZYM9ND, new-height: u168576 }
 { borrower: 'SP2ZDTWRQTS3MZWD1K3KJ41YQWFVRRNPEPMVP9CAD, new-height: u161286 }
 { borrower: 'SP2F0AHP4Y35AF74YK0VZN5AEZCXQK4REKBC0D8M6, new-height: u203009 }
 { borrower: 'SP336EE6CBKM01N4G9E9BYFN1WM46GQJS22TDM8YS, new-height: u153292 }
 { borrower: 'SP323F9RS1CN0NQWNY42S3HAHE8M97SVFTMEQDAGS, new-height: u167848 }
 { borrower: 'SP11Z1W6A7HERV06SH414ZE4FK8STF9N244GK3NSZ, new-height: u160829 }
 { borrower: 'SP12ES6760QNTDV4Z52CKKCR97W4K9JF35M2VYHSW, new-height: u154324 }
 { borrower: 'SP11XX0PCQVE313J2X3TAHGQ9T1T0NMMEN4XMHABQ, new-height: u160735 }
 { borrower: 'SPHJZ6S6M22TATB805TMAVQ9YNYMCSB4EJ5VYE1Z, new-height: u153060 }
 { borrower: 'SP2PKX3NAER3T40ECAYAVZESCGA42B6BP50K6ENKM, new-height: u168418 }
 { borrower: 'SP3A23V9S1F1WNXJS2WKRFCJ3NRVH9SJE3FW37FRN, new-height: u152400 }
 { borrower: 'SP1KPDH86AWT9TQQ31G5JHEJ3WRV16S08ST71TVKA, new-height: u151268 }
 { borrower: 'SPG6M2B89MV2PQPB8VDQEJ13EJKPMJHPJSFY54XH, new-height: u149744 }
 { borrower: 'SP39BJNYR8HX904WB46ZHX1PF06RDP37D5A6BNRK4, new-height: u160799 }
 { borrower: 'SP1A4MBYCB2DKM0HCVPTCKWBVSAD0J73KWVRJ8RWF, new-height: u167647 }
 { borrower: 'SP18A6PSVMYTC9REXF5MED259S5Y9TRHHD8Z7Y69N, new-height: u164399 }
 { borrower: 'SPMYZC3EQYQ73RJFZKYBF7D76BNWEVR7TCH7XDBD, new-height: u155106 }
 { borrower: 'SP36A56G05V2SZ9PJ81PNZRY4TXT50ZTFNA19DTE2, new-height: u161071 }
 { borrower: 'SP1JES6BF7VN9840VTXGT5MB36SY0PAE3KP7FQNTZ, new-height: u155275 }
 { borrower: 'SP1ZQYG5H5SPF4Z49RAZDKMFSGKK7ACTYNY3QM70C, new-height: u164399 }
 { borrower: 'SP2CJBE3SWKCK85KKKY1ZY898MJNVSH0A703565HS, new-height: u183679 }
 { borrower: 'SP2EGFDK5A2PP30YRX5SR2EAR9F6RFDM407S6FJK3, new-height: u152956 }
 { borrower: 'SP3XAGB4X61XCF68MDMFQD8W7MPFHN8HJBCW2E7JA, new-height: u152712 }
 { borrower: 'SPXZ5TX6R19NDAVVXNM5CR2R77MABNF32P6Q6BAD, new-height: u239552 }
 { borrower: 'SP2YE97WPR9C184MQ4RVM6AP1J629750Z1N48N82S, new-height: u175607 }
 { borrower: 'SP29DX2PV40QY2J6Y66MDTVW5KANSGD8VA1FXC6RA, new-height: u152728 }
 { borrower: 'SP1EKDMMG508FY96RSEQ1EFGGZ6J8T8DCDPAM12HS, new-height: u166649 }
 { borrower: 'SP3MTVR17D40ZGRZWGAPKSVRATYZJP66PFDAVNADF, new-height: u169689 }
 { borrower: 'SP190GFXHFA096G8V7B1SE0221ZJX6D5CPK8FMDY9, new-height: u155890 }
 { borrower: 'SPWV51E9AJFX130258AN5630F5JGH0SW8664H4HW, new-height: u155264 }
 { borrower: 'SP1ZP650KJDD91TQXBPS6EB4T54EF237NW1MN0G8N, new-height: u235405 }
 { borrower: 'SP1QDF6140PMACZ35RMBBEY3XX9Q7KJ5RDCASAV4K, new-height: u155692 }
 { borrower: 'SP1ZN3QYDX9J8F1V8HDBB16WZ9EVG762XRPED0HMD, new-height: u155264 }
 { borrower: 'SP04FZTETK9DH5VY5QKABMP1NYCYW40FYBSANGRS, new-height: u160628 }
 { borrower: 'SP2ENJ3R7X7XVRCB6WKYKJW3A71M8275SCT08Q8SY, new-height: u160397 }
 { borrower: 'SP31NTDV1482AW4FCYPRMEKFRVF1GTDAVWF4ZA3DN, new-height: u183693 }
 { borrower: 'SP73813P0X4ER4KTWQX796NC9T500P092KJNDYDN, new-height: u155264 }
 { borrower: 'SP3ZJF89QRQW466932PHMQ2Q65MMK1EHKPJA2M9DT, new-height: u160729 }
 { borrower: 'SP1CFD0KXA1G36CPFGDFDAM1JHJ2H7XP100QP6590, new-height: u167447 }
 { borrower: 'SP3K0EE25S57TK269WJDYX9ZBEY763RFBX47TA69W, new-height: u316269 }
 { borrower: 'SP3JNACGEX37WW3GJM4SHZMZ04QMDRVHY63DC58HQ, new-height: u155161 }
 { borrower: 'SP35R4DXWZRPMPTSNK0FFW714H9HPWH3R35Z4GVJC, new-height: u143614 }
 { borrower: 'SP334RNE1M86TC3A460NB848NET14EACXQ2260CXM, new-height: u202256 }
 { borrower: 'SP1R8K9ZE5XVB9Q13WRA250MX4J1RYGSXABSQ69W1, new-height: u167065 }
 { borrower: 'SP3AAZ14KVKRF8DN6FV2YDFJTXFV05PA6WT20T267, new-height: u154368 }
 { borrower: 'SP3GGNDQASTXH0SVTSWVSNS7BP3RZ4MDXX25YW80J, new-height: u166792 }
 { borrower: 'SP1MZ3CF4W2NXNKHZDGCXVTGRCRVW9CT8ZX52CT33, new-height: u213035 }
 { borrower: 'SPWYGV8FK7WXYMJZF7SSYEXR1R1QA2FG05AVPY4H, new-height: u160257 }
 { borrower: 'SP1S9V348SY2H77AH4B008KX0K2GPW2EGEW29847M, new-height: u320104 }
 { borrower: 'SP1QF33CQESD5K623HDG9CW19SBDRTW17N13WGXVR, new-height: u161256 }
 { borrower: 'SP16CVJT4K2A4Y77T71ZNA13SFX7FB9YJRQ58YGZ4, new-height: u328351 }
 { borrower: 'SP4RWYXSAM1TXYNYVFDV073XKB4W9P5HWT4RP85F, new-height: u167379 }
 { borrower: 'SP38DK4JAY0NVH59QM21EBBNQWZPXB94K0FXK0JJ8, new-height: u152237 }
 { borrower: 'SP3K47Y6STKES195TV262H8ZKCFXB5DWF71MCWSDB, new-height: u159349 }
 { borrower: 'SP340HP3XW950EWX4FM448T5S1RK25VEYPCEJQ02V, new-height: u159553 }
 { borrower: 'SP2T0DVED39JM0X8MWAYFRAYB7R8EWFJC2W3VT1A, new-height: u168863 }
 { borrower: 'SP1HQ50VYDPATJXE3F6P9BQD8FFWAGB0265ST0STC, new-height: u152727 }
 { borrower: 'SP17TK9D2MWWSE1GWD3Q8SFT5AMT8TTDGQHZ023M6, new-height: u167301 }
 { borrower: 'SP1779T6BNQ853MTF39HHJAR5E7WVJQZEBGZ2B9VB, new-height: u239005 }
 { borrower: 'SP3GXPJAJY660N38FKQBBBDFRAEE9Y4TWC3V3PS0A, new-height: u159121 }
 { borrower: 'SP82MH3BHMKTQDH3RREC9GFH4YM1JM0MM3JEGH97, new-height: u163960 }
 { borrower: 'SP3VGGV866MC5EKKHWG7G8WZSER20VV1ETNHF8CWG, new-height: u149933 }
 { borrower: 'SP20QZBHD8QZKS9NGV9FQ76KQ6AD98SGQKXYQ2ZPG, new-height: u163110 }
 { borrower: 'SP2HER9FS9TAH93ENW0PC6JZR27WN5HT8R94GJTRR, new-height: u166661 }
 { borrower: 'SPF0V8KWBS70F0WDKTMY65B3G591NN52PTHHN51D, new-height: u206404 }
 { borrower: 'SP1AWFA1CJ71Y306NZJ3JVFC3PHGH5QW8D8JVXW8W, new-height: u247632 }
 { borrower: 'SP19AZ6MKKXV0JW5R05F7YBY68NF72TSMVB2CF0CB, new-height: u163367 }
 { borrower: 'SPMA0EH4FZGPA1FJBQXJREE22CBKYCBBVH8M55TV, new-height: u167442 }
 { borrower: 'SP1M2KTKG2HK0ZAKVYTEN9DF7Q00KC5YMDWK263CK, new-height: u253634 }
 { borrower: 'SP2JF9JVQ6AYYG3VDYYSM7B87DZTK2QAX783H3T5R, new-height: u296266 }
 { borrower: 'SP87PHFBSH9B51W2GBEN7BG4RHF81PP6Q4WKJ96V, new-height: u160735 }
 { borrower: 'SP39KW7PHTAC7MKDZJT64ZVFS141B4G7KQKEG7MG3, new-height: u160735 }
 { borrower: 'SP3JDHC43B8RTMS1ZJATQBJEHJRZNPB8GPVR7Q7B0, new-height: u157355 }
 { borrower: 'SP265MKD6DWYXTMZZ41DEFQ5M2HWJSQ52V26WFWRF, new-height: u268325 }
 { borrower: 'SP218TBV9HWW8QQRARHQ6XK7G10271SQTTCCTHW20, new-height: u248314 }
 { borrower: 'SP1S2XG2DERE2G1YDHQBD0NV2E3WTXEZQGW4J2DX3, new-height: u157281 }
 { borrower: 'SP3KTNQFHQ4N5DH40F1164TGYMX3QG2N8NA5VKN4X, new-height: u191993 }
 { borrower: 'SP190VXRZCP3KBTVE5E84GPBY7P9WKY9D5Z4QTA79, new-height: u160759 }
 { borrower: 'SP1R08FJCZ5RE2FJX5C2V7FG53GZ7XN8NDBJ36THD, new-height: u160735 }
 { borrower: 'SPE5HDPQGE360QSRTA7TQAVVX3DTV44530J1WH1X, new-height: u141831 }
 { borrower: 'SP2PHMA1MTGQXG5DV6G61AW7GHRZH946RR54BK4FG, new-height: u156931 }
 { borrower: 'SP197PW7EE4YN54PGAKKJBTPPYJ75HA1258NEDZEW, new-height: u312035 }
 { borrower: 'SP1087208W7B3ETPQ8CHP24K0PGNW7GC822SKEFHK, new-height: u156624 }
 { borrower: 'SP3TWW4KNPSYJPV9HGFG9J2KWDNT7WNS60YGFHTY0, new-height: u160735 }
 { borrower: 'SPG4AM3P10V8DWNB4CC8XBQDD5244C8Z8HSQQTYJ, new-height: u202414 }
 { borrower: 'SP1EW1NDQG9G73R7TZGJXMRK6E7VERVHRG7HPN5VX, new-height: u297012 }
 { borrower: 'SP161QHS676YAM88D58Q958DV2XQCSF73DSN7S2DP, new-height: u154677 }
))

(define-public (set-borrowers-block-height)
  (begin
    ;; TODO: remove 
    (asserts! (var-get enabled) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))
    (asserts! (not (var-get executed-borrower-block-height)) (err u10))
    ;; enabled access
    (try! (contract-call? .pool-reserve-data set-approved-contract (as-contract tx-sender) true))

    ;; set to last updated block height of the v2 version for borrowers
    ;; only addr-2 is a borrower in this case
    (try! (fold check-err (map set-aeusdc-user-burn-block-height-lambda borrowers) (ok true)))

    ;; disable access
    (try! (contract-call? .pool-reserve-data set-approved-contract (as-contract tx-sender) false))

    (var-set executed-borrower-block-height true)
    (ok true)
  )
)

(define-private (set-aeusdc-user-burn-block-height-lambda (aeusdc-borrower (tuple (borrower principal) (new-height uint))))
  (set-user-burn-block-height-to-stacks-block-height
    (get borrower aeusdc-borrower)
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    (get new-height aeusdc-borrower))
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