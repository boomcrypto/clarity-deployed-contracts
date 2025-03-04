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
 { borrower: 'SP3CRKCVYP853H0A2J3THRFY6BA6HH8D6088T5Y09, new-height: u150074 }
 { borrower: 'SP1FCPT26X5HP0MNHMYD3GBSZANAKGMFZH816W2TM, new-height: u153094 }
 { borrower: 'SP2QJZBTB874KWT9YSG4CMVSYBXVYX9SDHY11108Y, new-height: u145571 }
 { borrower: 'SP2TG5M7W5DZZTRA2ZHRKYRHMXJ302W4WJ2NJQTXD, new-height: u203009 }
 { borrower: 'SP2PS9JBJ37NRHVMSDWDH47T4NMWVSWHRX19M4H2F, new-height: u150243 }
 { borrower: 'SP2HNPCJVV5K109RSGYQ6A5XXTN82ETPGXSP79RMP, new-height: u150622 }
 { borrower: 'SP2A5QR4RZJ8NX10KBZH96P10PV2JB9X38WSQX75P, new-height: u218997 }
 { borrower: 'SP1PVRTEP7TWYPR0PZFQ8Q25266T4TSWV1EA6H8YD, new-height: u152672 }
 { borrower: 'SP3Z34RH9RAH7NN10BAE9SZYB945C9TYBKFN2K0Y0, new-height: u149602 }
 { borrower: 'SP2ZHTK0AJMXF20KCQTM482YAYB6WSY7A7A708VV8, new-height: u149905 }
 { borrower: 'SPVY2PDVNB6JNR4WJ2A1HRAA0JRZ0HDVHYSS4GMP, new-height: u145948 }
 { borrower: 'SPGVENXCEYZ3G8QHTH9FMR416SS1E6QWC34QQBKB, new-height: u203190 }
 { borrower: 'SP27NQHM28DNEK38P49SSEJBHX3C9AB9RD5G4QA1Z, new-height: u145094 }
 { borrower: 'SP3KS2S9T50YG14R79978DGNHVFGR9Z1AX052B60V, new-height: u150890 }
 { borrower: 'SP277ADH9HKSG5TTZ12DX14KS1SM7T4WXE4XX3T00, new-height: u151342 }
 { borrower: 'SP26T18A9A751CM9V9BZJJ80WPRGERF4BSBJZN76W, new-height: u199801 }
 { borrower: 'SP35REDC1J2STAGW643CRSVFA9R1J8JQDK6GPX1X4, new-height: u145405 }
 { borrower: 'SP16HXWHTZEHHKBE12AB91PYJ63V0S696G3MZZM8K, new-height: u149933 }
 { borrower: 'SP267M0D84XPBWM0XWZ6NAB92TMKH89W6GBE7ZZP8, new-height: u152389 }
 { borrower: 'SP19RMCXH8EW32FGXE0706RA02QX7QDQ323XJ2PT2, new-height: u149899 }
 { borrower: 'SP20Q1H42BNH6YD6WFPCX4RZC9VDJXD8HEZTRF0CZ, new-height: u151851 }
 { borrower: 'SP2M3KJNCCQTTX609WGRDYVGE20GC1J1VWSYX9VGS, new-height: u150003 }
 { borrower: 'SP27PXWEEPDNWQMDMMZAET3MBP1N7ZE1M7XZHJF1M, new-height: u150390 }
 { borrower: 'SP2KGCD5QCV5CJRESDW96TQC8MZ7DQQ0BFD3C3890, new-height: u149900 }
 { borrower: 'SP3611GN89RB34BC48JW065Q3W6ZK81KPTA7GY9VB, new-height: u149997 }
 { borrower: 'SPJMXPPMVPAW2THBJJ667EEHJZC6XNMT699N5363, new-height: u310844 }
 { borrower: 'SP3TATWNNNE9JY7NFVP0JEB809VJSJC6E9QTQETK4, new-height: u320462 }
 { borrower: 'SP2XXPBN1JFKZY8Z0FCP022NBVQZSWTK185KQQ3NS, new-height: u150029 }
 { borrower: 'SP2NT1D5WQ3B755T0R15V3C9NZ7E400NSBZRJAN5Q, new-height: u150275 }
 { borrower: 'SP3D196DXNRR5FQ25B5M763NRE2SB1518RP6KRK23, new-height: u171765 }
 { borrower: 'SP28QK1Y9DK99RQGHMNY5TKPNFS5M4ZMMVBKB0WHD, new-height: u150503 }
 { borrower: 'SP1FPPMRP77MQMS3N9HW5Y93YREMG4SY4PF5S3S46, new-height: u152202 }
 { borrower: 'SP2HMMW7X0XRFS6Q072QS80EEPXX3EGKX7DAG3RFS, new-height: u150614 }
 { borrower: 'SPNRR1SRABG9VG67FPEKP0T02ADK1YAJ328ZZAZ4, new-height: u313560 }
 { borrower: 'SP2YZTJNXHBWXNFF644EH4GZ4S7CQ01CVSD2PEA49, new-height: u205911 }
 { borrower: 'SP15NQJMSVCASV1XG3N6W3DY874HQXMHSWDGTY62F, new-height: u239187 }
 { borrower: 'SP3A7BWWWE0QXV19WWN5D9BQGSH9VJK6MW56YM0G4, new-height: u150892 }
 { borrower: 'SPFZRYYTZ1K5JAZHE69K68JYZAWBXSZ56D9MG4B0, new-height: u149953 }
 { borrower: 'SPQ156AQEAGYSCE7YNW53JW0AT2R4C5A2RAFAMZG, new-height: u320462 }
 { borrower: 'SP3Q6BNPKK5DRHFWK8C81Y2E4XCM30ZWEZ4TH31K0, new-height: u150131 }
 { borrower: 'SP26T3TJQ9H12MZ2K7A64YT40MPEAF557AHX6P4PB, new-height: u336039 }
 { borrower: 'SP2TD9H3GY9ZPNB1Q149MYX8HHT8X2Q15ZYQWCKB9, new-height: u150632 }
 { borrower: 'SP1PE1R37416BVCZ8MFS777VKEB728S2DW094Q9YF, new-height: u320513 }
 { borrower: 'SP1AZWJFWMAPHPD9AE9WD4388XSG3PVVBRP91PVHB, new-height: u145141 }
 { borrower: 'SP1943YQ7FTHDZ4G7Y5VGRE5EQE8WW1APTJ6MVV0A, new-height: u150030 }
 { borrower: 'SPDP02PP7728P7EFHY3B84HDVQF4YRZXZA2BBJT3, new-height: u329617 }
 { borrower: 'SP1VT41Y7T8K7KKAMV5F0A000Q38GNWDTZKCGBY9, new-height: u318549 }
 { borrower: 'SP2RJRBMJQ09GEMZ0255ACY089A30CEB5ED8AWDB6, new-height: u298823 }
 { borrower: 'SP26GMJFH3PH7GZK4DRRN9Q7K65YR1C04417KV0F9, new-height: u178405 }
 { borrower: 'SP303PN90SWX0QMKGV3J1WQGSMHJAXXH99KRNNMDK, new-height: u241934 }
 { borrower: 'SP9MS5DCCWSVC7HTTQ54D5MNS2FR9YNJ0V0BJNN8, new-height: u210633 }
 { borrower: 'SPBPJTGJ922TG23ENRTKH9KHYCD5FGZPRDAGG7AC, new-height: u281635 }
 { borrower: 'SP1NM07V4FW2B5206E24VB07F9T3HFCYCCQRVBJ6Y, new-height: u145934 }
 { borrower: 'SP3Z6M5RSHSHJ781CD2DS41TMS1TV20JCFT6XXKQJ, new-height: u320513 }
 { borrower: 'SP1AAHHRZ4D47AAGAC74JFMEF70CRE93TVRHG2GZR, new-height: u144481 }
 { borrower: 'SP3VMTA44MSFR0K6EWKX7E18BKD41WANCC41BMJAC, new-height: u241934 }
 { borrower: 'SPYD9TX0D82S6K7K0S5F51DN2H1GZ0S5B45QCJT8, new-height: u314364 }
 { borrower: 'SP34GE35HK58Z1KV4FSEGJ8TP2MB34SYR3DDTHWQZ, new-height: u150116 }
 { borrower: 'SP2VASHGSVVXKADP0ZP4DY8QBYCGJ01277PA7H0T, new-height: u149961 }
 { borrower: 'SP6PCHCCFART4ZTXCVZR9FT9F4JJ0Q2A4ET41W0R, new-height: u192935 }
 { borrower: 'SPZM762VKVTS8YHKG8HM7FR1KJYVDQYQBR320W9K, new-height: u145100 }
 { borrower: 'SP28KBC99D9WG3QF9W790FAS3AG63ZD72QR6S5DKP, new-height: u150019 }
 { borrower: 'SP25V5VHY8EXNJ3PEVH6D9P9MDE9BYM5P17A528KV, new-height: u320513 }
 { borrower: 'SPEAKNCQF9B1BXPNDR24RYFH1Z6PHBYNBEXH4D72, new-height: u153093 }
 { borrower: 'SP1BN3VDV1GP6TJ6SH21NT621PBVFTG9ETGG5RG1N, new-height: u150778 }
 { borrower: 'SP1YKQ0R4ZBH818MZXKQW34133358GGRPV8N7Y66J, new-height: u256102 }
 { borrower: 'SP14EWQHWR0E0KMF5DEZXHX1HQBSGMNB4JVPWFTAP, new-height: u150064 }
 { borrower: 'SP1NE94ACGPH4Q201XJJSQ7999H28VMATMZS6PWQN, new-height: u151274 }
 { borrower: 'SP35HVQJBPC0EFDK5MK2GVQAQX0199DPQBP90Z0C9, new-height: u150136 }
 { borrower: 'SP2ADW332S32T4PGRNJ5JRQZ2DECS11HDY1GGPZPK, new-height: u150113 }
 { borrower: 'SP16Y367028R1ZT5B918N1BKPM7RQQ4QHHW19CGMK, new-height: u160829 }
 { borrower: 'SP1MWMBMQ6G4X6H4BSNNFC9RFSEATT1PJFKWA20R, new-height: u145915 }
 { borrower: 'SPPV60Q4TRZTZTDWEDJ88YM43GNTTFBFG6SNRB15, new-height: u313792 }
 { borrower: 'SP3J0GTQ7YH59P1CMJVBXHKZRKCAQVEJ8C6Z20NK2, new-height: u153092 }
 { borrower: 'SPJ66HEFR5MXZMHC5GGGRMP4GE2HA9EEYKENNP2P, new-height: u145765 }
 { borrower: 'SP1N3WKPS7PQKD837CTGSWEQ8QXTK061CHH2CKM3J, new-height: u153092 }
 { borrower: 'SP1KCBPWHQDQ9MQ8E7GPHS8A9GFYAZ2WRN2F5YC14, new-height: u145940 }
 { borrower: 'SP2RX6WRANCKWZ3C1AT4VAP3ACAZMW4QPZ09ETQ94, new-height: u150205 }
 { borrower: 'SPEXTRT7R996Z08X1PGQ93ZTEYVSCTTSM4J7187F, new-height: u150385 }
 { borrower: 'SP8H1JPB3VWRXNS8ZWYZK09WRBXD9308Z88MBEC1, new-height: u152729 }
 { borrower: 'SP1NB4E1FARJ0NFQH0X1VBAJ1TPFMN9H0AGTSPB16, new-height: u150062 }
 { borrower: 'SP1FNHJVFEHHNMT060JXNA09Z4HPMCEFJXQS31QQZ, new-height: u151736 }
 { borrower: 'SP3HEDDM8VJZXWMVG6DVZ8TTFDFXYXV5M3NR8NPM5, new-height: u149706 }
 { borrower: 'SP3G3GN0K670Q3YN59X2BYH31V7YWQ4Q547HVV1XE, new-height: u155319 }
 { borrower: 'SP37G57APVTZK2HYTH0ZYAX0HYPHNSCQ879GHWWA7, new-height: u152706 }
 { borrower: 'SP1M4S6VV1NN03N95C97SGWRCRF55CYCXJCJ8JHG9, new-height: u287732 }
 { borrower: 'SP1RP6MXN0SK2SJTSECS45XASS9YWDZSP5TVSQP37, new-height: u320513 }
 { borrower: 'SP1TNQCNF1J776HWFC7W0AN90V11674PA6YE2H1PP, new-height: u150574 }
 { borrower: 'SP2JFY8426TTDWZAPGAGYYNVJ6R9PP72HCB26YTQA, new-height: u150605 }
 { borrower: 'SP3WG60S7VAXS92YW9GNQRV382BF0GHTFJ3EKN0Y6, new-height: u145579 }
 { borrower: 'SP3WHBHC4S8D4CXDQANTH6K0FQGVA4BSGD9PZV3RA, new-height: u152706 }
 { borrower: 'SP284VB0B1MXERVZ1BSSWJ8VCXVBWW18FC2D9609W, new-height: u151315 }
 { borrower: 'SP16NWVZETSFCAAWRJCQMV5WZZ6X5E64F9KA0EEDZ, new-height: u152683 }
 { borrower: 'SPZ6RE4H52X8MY6PF88YREAC27YWH8WA57K4YVX4, new-height: u151826 }
 { borrower: 'SP2CT7PK64AJQWQP0XHECDGPJHHKREB7F13TY6XHH, new-height: u149977 }
 { borrower: 'SP33QBZQF9CZYDQTA7A5SADQA47J7FBC00G5Z85CD, new-height: u145658 }
 { borrower: 'SP1EPGQFF64GK4C262XVVCF90XTRMND9C8ZXR7DG4, new-height: u152684 }
 { borrower: 'SP1DRS6WVXNRKWAMBR66FJFVM1JRRXJJZVJ1NPVWP, new-height: u296524 }
 { borrower: 'SP2GRRJ18NHCHPDHJ8KCS09PJKR2HMK7Q26R9XMAQ, new-height: u150122 }
 { borrower: 'SP1CC4F8MVMFKJ3PVMGXJZEC2ZCPV6MMGVF921Y3M, new-height: u150387 }
 { borrower: 'SP21H3NM2YXRB88TACSAK7F5KAHSPQ79B6B87TXT2, new-height: u145934 }
 { borrower: 'SP17K76Z5D963QKB4X8T03ZF0945ZHTER06SK2HJE, new-height: u150182 }
 { borrower: 'SP12DQSBFRJATP92VET049BJTJ67J8C20EEAZQVT, new-height: u150113 }
 { borrower: 'SP1WG24AKBGPWBQP74FRZS1JQSFR0QM33KAA9H5EX, new-height: u150345 }
 { borrower: 'SP3Z412AWB9DW1GH1JKP5TPZZRFWENF24JX5BEM4B, new-height: u149899 }
 { borrower: 'SP2W0538S5PCZVZDNEMJ0CJF4V0B20DDD6XT2139N, new-height: u149903 }
 { borrower: 'SP3M0NE6YNKAM8MJZTB58RF2HFW4D91ZW4HKJ4JMM, new-height: u320513 }
 { borrower: 'SP1EZWR5J704A5G1JSV3V8PS0DWXHEFPYEN913XXC, new-height: u145435 }
 { borrower: 'SP1EQPJS15JMH6YHA079SH15E77ZZB321NQBR5RZ1, new-height: u150564 }
 { borrower: 'SP28QY2NN3KEN5CPVFATA2K6ZXN4A7SM3JC9G897, new-height: u152672 }
 { borrower: 'SPKQHV4CSMWF7S97G073WM0ETYS2EC93007A5N1T, new-height: u151291 }
 { borrower: 'SP1M26JGHGZKGSTGMABA6HJH97DCN8ASVBP0SRF82, new-height: u152686 }
 { borrower: 'SP1Q8ERJDYMXNVBQPKM525G5H4Z9B67BXM9N45QFK, new-height: u152726 }
 { borrower: 'SP360Y4M1AWDEYS872AN3DDX28FQ023ZMBHZBQ1B2, new-height: u152683 }
 { borrower: 'SP24YJDP5R2F4BJNR3EMMFE3QVR1HJ2T6XPGC1N7S, new-height: u217203 }
 { borrower: 'SPJH70Q4JA2H5GHEMZQXYE8H9XTD3RAWKES1CSZX, new-height: u150279 }
 { borrower: 'SP2MTC6BZQD08WA9TPC1GMNG4AZW3NNZV3JN1EVD2, new-height: u279433 }
 { borrower: 'SP3M69BX3YPWVBYVBWDWAP3FQ16H1GDR7TK8KQV18, new-height: u151565 }
 { borrower: 'SP2ASBP84JMKC937BVRR6AE13X4P4D3BCTQM5GQH6, new-height: u150639 }
 { borrower: 'SP226X8S1JHGSZJ6KKYA0D2H6NNAMNCAYXWPRDKN6, new-height: u149905 }
 { borrower: 'SP1SQ0J8VHQ5GF6ZNNQ323CDZMMQN988XSHA128X9, new-height: u152683 }
 { borrower: 'SP21YYAXGWPEK24D4J6127944QM4HVS0AAT6C5TX2, new-height: u152683 }
 { borrower: 'SPGVA1VXCGEPKFJ5EF8YTNX6VZ3Q6SXZK1SF9M95, new-height: u150975 }
 { borrower: 'SP88T9ZPQ2B8VECHWE7GA1H6YFYG3013F2PMTT78, new-height: u152670 }
 { borrower: 'SP18TX7QQAFABXXTZYFR75RGPDPDQ35ZYXFJXRYBC, new-height: u306552 }
 { borrower: 'SPNTV728XNNR3KRZFD2FAFBR2DVPA39BB2GRPTVX, new-height: u153043 }
 { borrower: 'SP3B9M0RS56PFY0MQ3GQ234QMJ1FZC4BJ2Y154PB1, new-height: u152706 }
 { borrower: 'SP2J2VTVRNQ8EW2XGGGM4460W3KW9BCRN0M6RKYZ4, new-height: u258555 }
 { borrower: 'SP1P6HG0SRCF9M4FH46BHZDWFWWMJPTN29WNJ4KHW, new-height: u152673 }
 { borrower: 'SP2FMBVXN0XT8G7EDHFDR0THARK8MQ56C8GPY64KV, new-height: u145804 }
 { borrower: 'SPQY7HA7ZGZFZ84WF4KGWE1S5D2RPKT76BD6XRQX, new-height: u150551 }
 { borrower: 'SP2QPZE4Z38P3SAGZHNW6C4G5W9JCBZGPG2RN77T2, new-height: u151289 }
 { borrower: 'SP1R96QFWDW16K57T0457CE8JKJWYA5RM3KGAAE5Z, new-height: u151970 }
 { borrower: 'SP13HQBWPB5ZX6C59VYVY6NVVJEHB1SSYPEJT1DXY, new-height: u310506 }
 { borrower: 'SP1NC04G54EKH45071NDZJQRJ4Y6GW6TSV1DCPNAF, new-height: u152914 }
 { borrower: 'SPSXXNR6P8PCG9X58HM1RRM3333FPXFZTPFAAWXG, new-height: u151020 }
 { borrower: 'SP1DR90069XVXRQ7ZQPJATABVJF6PFAGJ2FK346FQ, new-height: u150405 }
 { borrower: 'SP398Q24ED39YEGPMQZQYNMAGK9ZWV5VM50BMB72K, new-height: u145838 }
 { borrower: 'SP8P3719TMPXMA2DYP9696WX0D9213K1CWY6PJ4Q, new-height: u151027 }
 { borrower: 'SP3CNERKHGR5R0K420SFQ71QRX1V8S41QGT5TQG05, new-height: u157104 }
 { borrower: 'SP3Z3A0JPF1V0WCSP1XAFAREKAC6DDJZKCFHQNYPK, new-height: u152017 }
 { borrower: 'SPFMQW8TH77H8PACSS26J06VD5D9WXQTHF5F35GV, new-height: u152673 }
 { borrower: 'SP2PXD7AH66QHXBA1TTAHH0BG5VZWKJDK27EVJYRF, new-height: u152672 }
 { borrower: 'SP3EFATMQT0TA243Y7QECYVNC1T630PHGS6P6006N, new-height: u151728 }
 { borrower: 'SPGJV10GDNEDSY35Z3BZ0NSGRTV503GEA1ZCTCPM, new-height: u331840 }
 { borrower: 'SP11XCBWERH2V5SFXWPTSAQNCVXZQEW1FF5040FV8, new-height: u151007 }
 { borrower: 'SP3JCWCBN7XA22T2E4GHXWQGY5HYA1KTHQDX431Z9, new-height: u152969 }
 { borrower: 'SPM88TP159BBAZTWV3C7YQP7FSPN2EBBH5XSW796, new-height: u153193 }
 { borrower: 'SP1YKRHH5M7G6NHYQ4FWX6M6QZ19H0S9FY1P91GS4, new-height: u145387 }
 { borrower: 'SP3PAQDPXRH2B0JD6AEHM0QZ1GQM9FBA4ER5NWHGP, new-height: u213035 }
 { borrower: 'SP2FF3M47FVY2PGE71MCEZ5DEAKK80R3AHDTH3PK7, new-height: u221007 }
 { borrower: 'SP12QAAEH4R5Z9YBPAXG7FBXATDK0AVMCHAKB9AQM, new-height: u151541 }
 { borrower: 'SP120TSSBSXH9BFJ5MT2XMY5SC4Z5TAGYP4DBZ0V9, new-height: u151277 }
 { borrower: 'SP24M0BHJZRZW8ACE5WEECWYDGH6RD3TZTK1D9ABZ, new-height: u152684 }
 { borrower: 'SP2ZY1E7R3SRQZ3M4Y2PZVKCN7J93NYJAS6REMPBM, new-height: u150547 }
 { borrower: 'SP108M55RCA3NAGATCRMNK95NR4SV5HPNYDC2WT41, new-height: u145798 }
 { borrower: 'SP2HHTZRJFAE92M5V5Z3NHFYJDNG5NEWMNXB0MG4W, new-height: u150957 }
 { borrower: 'SP3VMMC1E6416NVZEW36J7R1D1KKNV49WFMJYAYXV, new-height: u149727 }
 { borrower: 'SP1RQEHGEW2S44ESCBG0BA5GZ5QK05E75GSM7PZQW, new-height: u150247 }
 { borrower: 'SPNKSQ0XECRRW6G5F3WMMV2DZ9D01HVKYAQMVQ8K, new-height: u150900 }
 { borrower: 'SPBJHGA0JY21HRV1WQCP3ZFNA15PK8ZGEMG67XP3, new-height: u152673 }
 { borrower: 'SPM09ZECSBTR8MGQH532FA4KP66H7NG29J0BQ5YA, new-height: u151749 }
 { borrower: 'SP27AB49EX6YHKD4WJTEEFE4GK5G7VDFNQ9DGAYP5, new-height: u150574 }
 { borrower: 'SP2W13BVYTVCEBHKXG1H3195PXGFFWVVPPWZ1SSMA, new-height: u150987 }
 { borrower: 'SPERVKX65E0TZXNTF05BC5915A13H8R5EYJC34GT, new-height: u156878 }
 { borrower: 'SP1H25KZJH9BSQR1WHH1HKZPE0TYNN9HWRQZTXA1, new-height: u156542 }
 { borrower: 'SP2AB6AYC6GBR5X94B4WNYDSFVXTSWRZQ9CG31TBB, new-height: u151716 }
 { borrower: 'SP4XNJ46PSB9Y2A9042SX509Q6XRSXPTQ3JMB25H, new-height: u151007 }
 { borrower: 'SP1F6XQR5M81C6B3ZB96QGDATSVKNCK6305EAD1QS, new-height: u145614 }
 { borrower: 'SP3FNQ0NJY378XA9PXC3KCK6XQ2M5ZG9GHNMRBHP2, new-height: u150899 }
 { borrower: 'SP2B3HAGG1F70CTAKPA4B43ER1PV3QKYH1WWJDJK7, new-height: u150720 }
 { borrower: 'SP8NR21S2JNZ5R2QFNW04ZQ09CX6G1W94ZPRAMZ4, new-height: u151921 }
 { borrower: 'SPXSEQCRDVG2ZYG3AGCVHJ85TRY9547RS2TZZE82, new-height: u152101 }
 { borrower: 'SP1DP772MMNNEA7PVSSKZMZYA0K2PMTF92AYBWDAJ, new-height: u151020 }
 { borrower: 'SPW3XBESSFF2NRNAMF5YB8FSARV7TASZ3G6J3A3D, new-height: u151007 }
 { borrower: 'SP2KCT8MH5GBAZ1B4AQ4ECEQPWTQBHXV5TYD4JQPH, new-height: u152707 }
 { borrower: 'SP23BYPV6CSGAVSE8NYXHE47W4A481D4BARVHY4M5, new-height: u184674 }
 { borrower: 'SP0AW56JCG6XNAQ8XTRA406QW2MKGK3Q79FNDGF3, new-height: u144429 }
 { borrower: 'SP2MC8A89S0EV0SC1S0GBP5YP8F3T0KEH4NTXP1HX, new-height: u150032 }
 { borrower: 'SP3R0A0M7E0GJYA5VASZRR7AQNX7F7HZQV05P1SW1, new-height: u201872 }
 { borrower: 'SPVAQY2P22HPKFSAYHPYV14B82B772AYMPQMXK30, new-height: u295019 }
 { borrower: 'SP1J13SBJSMSYFN21GPTJXFXRF8ZC76FWAB6TVTHH, new-height: u151171 }
 { borrower: 'SP2ZR74KMGW835MEANH220W1SEB8DB0FTY3BKF0R7, new-height: u341756 }
 { borrower: 'SP32CPWD0RFBSXCK0WN0281K6T9YJ8B402M2AD816, new-height: u151741 }
 { borrower: 'SP29CNZ51A099103CM7HBX11JFNE31AFHR55BSM0B, new-height: u151937 }
 { borrower: 'SP2GWJXZQQ9CP9R6MGXNH01T3RY896JNCCNSJBN0Z, new-height: u150643 }
 { borrower: 'SP2XGT4XMKGB6DBN6FGZAVAXHBQT18F3G3WJ4TTTW, new-height: u150369 }
 { borrower: 'SP1Q81WR3XNZGG44JPW0SZFZZMD5NR3RK6YAJQAFB, new-height: u256289 }
 { borrower: 'SP3JRK3SH37S23B95RM3N0DB3SRXYW9316FY1HHZ1, new-height: u150876 }
 { borrower: 'SP2WP3D7T8D5QTF3NPCHMXT78JNHJTMCSWBY5MH2Z, new-height: u152707 }
 { borrower: 'SP6FD8F1VVJ1XBQVX33TBWZXNR5XA1ES2B4AQ81F, new-height: u151851 }
 { borrower: 'SP3BY4E9JXGDP2GEMA2395PZY3BJJ19NRVT532P4E, new-height: u151020 }
 { borrower: 'SP2W01TKZDZEXMSNTSQ48N162RB1DTHAQPWDZ4PCD, new-height: u150832 }
 { borrower: 'SP1QQG29BPWKEYG0JHESAVXFTJSR2NV30GBKVJ2XY, new-height: u169687 }
 { borrower: 'SP3ENBT09BHBQAGVN5RNE9S4YXXFRZ0SMHTBJKDY3, new-height: u169812 }
 { borrower: 'SP30H99MRNTYMRCG4JS33BT4Q6RGWY0XTMPK2667T, new-height: u156895 }
 { borrower: 'SP2NYD6CP2JVPTABQGMC1ZA5TAVXH4DE4769X1N0K, new-height: u150747 }
 { borrower: 'SPQ33XZS2AG1JNGXDF54B3Y3KSTDNJ0QX0ZTHT7Q, new-height: u151274 }
 { borrower: 'SP3YBGWRSHSV4E8MC7NGH5SQ4W9ZGFEY1G960DVJS, new-height: u151647 }
 { borrower: 'SP9FTAY4SXYGGGPAF569TNPSN96T58GB8TKMCXXP, new-height: u150256 }
))

(define-public (set-borrowers-block-height)
  (begin
    (asserts! (var-get enabled) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))
    (asserts! (not (var-get executed-borrower-block-height)) (err u10))
    ;; enabled access
    (try! (contract-call? .pool-reserve-data set-approved-contract (as-contract tx-sender) true))

    ;; set to last updated block height of the v2 version for borrowers
    ;; only addr-2 is a borrower in this case
    (try! (fold check-err (map set-wstx-user-burn-block-height-lambda borrowers) (ok true)))

    ;; disable access
    (try! (contract-call? .pool-reserve-data set-approved-contract (as-contract tx-sender) false))

    (var-set executed-borrower-block-height true)
    (ok true)
  )
)

(define-private (set-wstx-user-burn-block-height-lambda (wstx-borrower (tuple (borrower principal) (new-height uint))))
  (set-user-burn-block-height-to-stacks-block-height
    (get borrower wstx-borrower)
    .wstx
    (get new-height wstx-borrower))
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