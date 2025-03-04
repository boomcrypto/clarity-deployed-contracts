
(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SPZX1HBFWAQMCJF9D5CZK0D067Z86KC2XVY75KKY.kitsune-inu send-many (list {to: 'SP3M31QFF6S96215K4Y2Z9K5SGHJN384NV6YM6VM8, amount: u5000000, memo: none} {to: 'SP36SYFW550MXX9T1H0MJXVCQ6045DF03W2N7YB9V, amount: u5000000, memo: none} {to: 'SPXA6ARZECQFWY0B3ZWT3S8ND22255EDN2PE88A3, amount: u5000000, memo: none} {to: 'SP3DGS23N2NAMJZZYFVNYS331GRVY1CVJPAKZMEGN, amount: u5000000, memo: none} {to: 'SP2DPSWCHWV27C6PVEP5GD4731QX40JGYC0ZKTGJT, amount: u5000000, memo: none} {to: 'SPRWNYXVK041BCWWYCRWX4VRS503A85MQNXYEC3R, amount: u5000000, memo: none} {to: 'SP1MKAKC9PVCCZXPPWFNEQTH2HFDV2VCHS8SE7C0P, amount: u5000000, memo: none} {to: 'SP2YYG5F3GKC2RWCQGFMSRAKS2BY5RCNZZMKV7BWD, amount: u5000000, memo: none} {to: 'SP27G7PE8VWZ2JC91K0D2KVWFME9AGWK2ARK8HAMP, amount: u5000000, memo: none} {to: 'SP2XE654A8BDXM740KDE68A01B0RGB3YV1S1PRQW, amount: u5000000, memo: none} {to: 'SP210TA1X155Z2KKBH53AWX38HDAWEVXB9GY41CHV, amount: u5000000, memo: none} {to: 'SP2J6XWX2703GR3NKKJZEA2ZZKYXYVXM1SYW4KCV3, amount: u5000000, memo: none} {to: 'SP271WW77JVK3ZF4J2D2X85J0TS3YTWW65G02NDKG, amount: u5000000, memo: none} {to: 'SP29AP5ST6S4T6QMYH8594YRG1WMK2YMV67WN4E8E, amount: u5000000, memo: none} {to: 'SP3ZDA2TJV6BMKNK7ZKGTQPYC4M3SSMR24V736XNC, amount: u5000000, memo: none} {to: 'SP3Q6P7ZT52EWW58NRHGJN1782ARW50P38M6VV8EX, amount: u5000000, memo: none} {to: 'SPSGNHGEV58J2A7N8TS946JK3BYMXADJH0F11F68, amount: u5000000, memo: none} {to: 'SP24Y7PJ1VVFG760Y6B558KNWFQKHDZ3F2MGCB6JJ, amount: u5000000, memo: none} {to: 'SP2YJA5P986DNJPMTR5CMY9GDHE5D6NZTT4S16VVQ, amount: u5000000, memo: none} {to: 'SP1APJ38R6X3QDTSBEK8X7KEQRH8SM5N32RBDN6XS, amount: u5000000, memo: none} {to: 'SP23E63ZKD8KG91DHQCSBP3A112DGHCKW6M3EGYK6, amount: u5000000, memo: none} {to: 'SP1QVASZ0RF6NHNNFXV2YMA3VDPM1PN9TXNGWM15A, amount: u5000000, memo: none} {to: 'SP2PPY7A58MF8V2Y2EDXJSTYCFAJBWVPG3N0R5GAQ, amount: u5000000, memo: none} {to: 'SPVKZRCR7KJE5MQ2FCQPT7YPGY2MCS8DGZ7T7T1Z, amount: u5000000, memo: none} {to: 'SPMPG4Q78YGJF114HR9BRRJ7QNMQ3WTKMJ4D7YY8, amount: u5000000, memo: none} {to: 'SP26QE8ZT1213VXS54SH315ZS0SPSFEJCSVNCWZ4Q, amount: u5000000, memo: none} {to: 'SP2N5HHMKKDVS8HSZXX8EA7JX7H895VTWTV67EP90, amount: u5000000, memo: none} {to: 'SP369QT67NYESRSYTQHNPZZ2JGVPBSF47KZMPFZ1X, amount: u5000000, memo: none} {to: 'SPPFKKZ3YDRT33RCBAVP1KX08215X8WYFX1NV1Z8, amount: u5000000, memo: none} {to: 'SPP5D3FNBCPE3MDY278QPC9C5654V247FGYET54J, amount: u5000000, memo: none} {to: 'SP3HWMBE0Z42CPYY589XVKVXEK4BMF24Y05ZT9P9, amount: u5000000, memo: none} {to: 'SP13QXC3F0QBFFN73DGBQ8PA6G0YFPYB0KQ4FR5MG, amount: u5000000, memo: none} {to: 'SP94VPZ90K4FHQSDB86JGPYA0388VHP2R6KHQ1XA, amount: u5000000, memo: none} {to: 'SPX5JETF35KGMVQ66KPS58XKK9N8YFNS7DSATZ96, amount: u5000000, memo: none} {to: 'SP0DX44TBK5WF34FA7XT8WX1JK5QB0NF61TG8A20, amount: u5000000, memo: none} {to: 'SP13WHEX8PJ8EFCBF32BYGD45NDMZ5H7TSFXZMVRD, amount: u5000000, memo: none} {to: 'SP3EBWBPQJ6JMRK1285W75W842RXZQ1J1V8XM190F, amount: u5000000, memo: none} {to: 'SPENAF4JGEP9S0FBNM32QJRVPBFJVRQ2EJCAHVS9, amount: u5000000, memo: none} {to: 'SP3SKXKKGW2MDNFWDN4Q5V4654VRKT4WCJV2H52Q5, amount: u5000000, memo: none} {to: 'SP2Y5TXQ5BX5C9ZH8AT76QW11GVMQC73E5A4X21DK, amount: u5000000, memo: none} {to: 'SP1HJ43ZSAYWPK27MBC2NS50JV2CK01EXEFQE1FK7, amount: u5000000, memo: none} {to: 'SP238F4X8XQAWZR0A93KVQWH6K336E28HB4BNF0PQ, amount: u5000000, memo: none} {to: 'SP3QEXAGW3M02N0S2XFC3FVADAD3ZWRNGWMQDN3Q2, amount: u5000000, memo: none} {to: 'SP17WV83JA5AC8BXQN16V5Y15K6N4A1ECRGHNW6HC, amount: u5000000, memo: none} {to: 'SP359MH86SSBYR7CD9MBYEFEZCXETJS3CVX5TF3GN, amount: u5000000, memo: none} {to: 'SP1M5KG0D88KNPCJH9MMGN3YZFP17NDVPQSJVPMCS, amount: u5000000, memo: none} {to: 'SP3S22XXF93KDCHGF77XB21QWAMQD26MAAR312XA1, amount: u5000000, memo: none} {to: 'SP2468TRFGYZAJ0P86NNMPNJ08KPH9WH2A4K2ABD2, amount: u5000000, memo: none} {to: 'SP3R025QAM7VA8NPCP8S5E39SSPR6EKN9TDZHVYBW, amount: u5000000, memo: none} {to: 'SP1K35PJGG3VA85JWPX98AN5FS6R0CFV87DW7GAZ8, amount: u5000000, memo: none} {to: 'SP120D0CYMB5AKX7YJCGK3PH28N1ZEE62WTDMADGN, amount: u5000000, memo: none} {to: 'SP3B8VSZN7BWE8CBXJTBSM4R2QQNAMZB8DTTB5PTN, amount: u5000000, memo: none} {to: 'SP1DECG2RND2NJR72HKXMXPVMV496S4G30VW9EV1J, amount: u5000000, memo: none} {to: 'SPWHMR51KW4PZKE13DZNM7V515Y3HC3JV4N4MB6J, amount: u5000000, memo: none} {to: 'SP26X9RJXYM8K14BWDHWP75S1DSTVJWHPP59DBMAE, amount: u5000000, memo: none} {to: 'SP23NKTGXAW9QDM24Q71WPD5FFN9Y5HFSC0QAMWK1, amount: u5000000, memo: none} {to: 'SPN8QVA4H4F6KCV13P2QZBJR878SE9WE80KT9QS9, amount: u5000000, memo: none} {to: 'SP1PFGGYWAKE1ESX7RNKMHSK0TNM68J5JF18TPTYN, amount: u5000000, memo: none} {to: 'SP1DKBEE3SZDQX38SHCP149J93194NK8M51XQYTEY, amount: u5000000, memo: none} {to: 'SPN5Z0F7EKVYKG7DQESZAQAVB6AQC8P8Q3XREJRV, amount: u5000000, memo: none} {to: 'SP2F72QRY66GTVH72AY69242K63DJF2NPTEF0HV2N, amount: u5000000, memo: none} {to: 'SP1CNHQ9X1GQ3Z46DA0AVFH66BX42G1GDB3T118YR, amount: u5000000, memo: none} {to: 'SP7PANKRW56BX5SVR64QC1QNJ2XAGDX6N631ZHMQ, amount: u5000000, memo: none} {to: 'SP1K9RYF8B7Z74KAQJBFV0Y6V2G2BMA1WX2EJKYEZ, amount: u5000000, memo: none} {to: 'SP2G3PMV6VCRT9J00J1H467C86HEKP97SFVQK541A, amount: u5000000, memo: none} {to: 'SPJQ5GN4CETCAAV5MCX6B9HAQCPV15VJQFVMYXMK, amount: u5000000, memo: none} {to: 'SP36RWPBEY629GKX6QM5Q9FB8Q8CW0NS2ZSX773K1, amount: u5000000, memo: none} {to: 'SP2M587PXHGCK8JWHR1ERDE1E182R5VZ24NS3GQ51, amount: u5000000, memo: none} {to: 'SPZ7WEX5CM4FJ5GDQV96N3XXCXDWBG3YABMFFXMB, amount: u5000000, memo: none} {to: 'SPCK4A018WRDZA07TSHGJ3MZENE6HYY1ZGPWSHNV, amount: u5000000, memo: none} {to: 'SP10TDS4NPHEGXR58HG1BDZ82WX4J4G9EE6XSE58, amount: u5000000, memo: none} {to: 'SPJZBA2BE74D5RR3D2T10YF4C7216SWZ02JHS1KT, amount: u5000000, memo: none} {to: 'SP127WFR38MGRE6BQB1TZ944SXA9S46TKZ6QJCQK7, amount: u5000000, memo: none} {to: 'SP2GYCDWZM40AF9A0NAV57G9B81B77GYAVMVG9VCK, amount: u5000000, memo: none} {to: 'SP3FR9GB0DPZ7YM0EWVHFZ8GXJA56NG3ZSQFXMQAR, amount: u5000000, memo: none} {to: 'SP2FM4A6VW48SMGQYW5GXBRTMM049YRBCEM9GBNRA, amount: u5000000, memo: none} {to: 'SP14MHHRE8MSPQEYZ8Y01JTZ2AGGNH1GARRFQ0DP7, amount: u5000000, memo: none} {to: 'SP3TPN8PRYJEH17TN5781A0B2TH2MTMWM3PEN6PQM, amount: u5000000, memo: none} {to: 'SP294NX5D3E3KWE9SE49GP7C13F0JZTM9318E1A0C, amount: u5000000, memo: none} {to: 'SP18N1FFE60W13NBC1SX16W5KGR5QJNTFFX87YCPY, amount: u5000000, memo: none} {to: 'SP1WV4XBH6R6WRGYHE3DC7MNVZHNTHBX3EZ7FTM7A, amount: u5000000, memo: none} {to: 'SP3QGTVE8RV0M9AJADSNAYHENHD469ESQMNM3W8MN, amount: u5000000, memo: none} {to: 'SP3YGV4PGA8GPQR0CPCK0RFXQ83RNJ9GM774YSZHN, amount: u5000000, memo: none} {to: 'SP3QNB3116SM1W590YE6PPZ9YWHWYBHQV0VGD3WXN, amount: u5000000, memo: none} {to: 'SP5QTH4QQNB77GTF9FJM8AS4BB32PNYT2SH14T6W, amount: u5000000, memo: none} {to: 'SPHA09TR2CB01S1M4T5FB8SBVTGSEZ7XD6FWMMB1, amount: u5000000, memo: none} {to: 'SP1YWW3DXQKB1GCQXS4GXGFFWHYM4AJS58P7RG5V6, amount: u5000000, memo: none} {to: 'SP3W6NFEB6KADDM8MHQPJ8R9AHCTF80NBR7SNP1Z9, amount: u5000000, memo: none} {to: 'SP2AQVHFBCV2NC0A5Y2GBM5E6HDW1VX0PSB8RPYS0, amount: u5000000, memo: none} {to: 'SP13WXDRGXE1GFYGFJZ8AVPDK0B1FDH022NDVC5MS, amount: u5000000, memo: none} {to: 'SP3X35B5W03X9Z57EB8H0EDPB5SP64B9VXEYJNM12, amount: u5000000, memo: none} {to: 'SP3ZXGPPKPBQ9B6Z0RQ9AT1T3A691DSBKBDVBXPDD, amount: u5000000, memo: none} {to: 'SPJ0SR7GMC463Y29AR7CQM4DNWEP4RHQCYJDS1Z6, amount: u5000000, memo: none} {to: 'SP31NBMQPWYJ4D57YF4P7C8WG6TH1EXYT3N462EER, amount: u5000000, memo: none} {to: 'SP8Z5FMD29EB8T3557980KWHDG226F1JMK6S2KGA, amount: u5000000, memo: none} {to: 'SP1J3Q6B486VVF6J0VWJYWN18TPYSE68JG29MJ4KM, amount: u5000000, memo: none} {to: 'SPK2QQ1YZZG6HF4S47NQW40FRNC0R42GRJWZ9FBK, amount: u5000000, memo: none} {to: 'SP3XW69EJ6HC4F3RDR8XP9X950EAZVK0ZX5A0BXPB, amount: u5000000, memo: none} {to: 'SP2WRHVSX3N0AMH1TYVDSK8V9D7S4DX7GD41Z51X7, amount: u5000000, memo: none} {to: 'SP87YTXRJ6KWCQ91Y8YTHEQMCHSWGCD63GGFPT7K, amount: u5000000, memo: none} {to: 'SP1CVR7030BV8V1MQ6X2SGWVR0N1A07DJWMADYSG0, amount: u5000000, memo: none} {to: 'SP1152CHQ700JWASKE28REM344BDZQNYFGTY7H0DW, amount: u5000000, memo: none} {to: 'SP24P2YYD2RKDC8XHZXHHS3MY0E5HYPGXSGRCKJ6B, amount: u5000000, memo: none} {to: 'SP3PFV3WX5BYY6K7AS4CHSQDZ623WFRS3G0W5EM6W, amount: u5000000, memo: none} {to: 'SP23AAYH9C4X1T0EA59J43CZKAF1DCB1PTDKRAJX, amount: u5000000, memo: none} {to: 'SPDTJ9M5M8RVWRD40HJ1Z5J85NZMFBZD308CM45X, amount: u5000000, memo: none} {to: 'SPSXZBJWC05C2ZMX4JB7BK53CVBVZV5STQXCBWH7, amount: u5000000, memo: none} {to: 'SP2RHP1VK32Q92KBJ3ZD091XSKN95TKJKW72F8ASE, amount: u5000000, memo: none} {to: 'SP0406NC9GD6QWS2F7K1DMQ03MS2B8TDH1CZ59J2, amount: u5000000, memo: none} {to: 'SP21SYRE3YWXN0YTXWNB9JC65EWVSWDR69RR5J3Z8, amount: u5000000, memo: none} {to: 'SP24P0VF1XNB2E0CGD9T54BB9XA4B9Q6K426ECT3R, amount: u5000000, memo: none} {to: 'SPP8V2JXXSFRE9SV0B2KXAN891PSRQWMS93KGP2Y, amount: u5000000, memo: none} {to: 'SP3VEB2RA8SJA9AB6K5C9S6BJWGBPC0PXZMNG7TEQ, amount: u5000000, memo: none} {to: 'SP29Y0K9157D4G0BQSXZDF5MJ3TRM0AS5J20CQEAG, amount: u5000000, memo: none} {to: 'SP24KG0ZP3N7XQ5VPF9NX7NTEG9CJD7EYE9WH8EY0, amount: u5000000, memo: none} {to: 'SP144769XBABSXQY0J0CR1V0BF0HDA4RVY2B26CV4, amount: u5000000, memo: none} {to: 'SP1PYN4E6XJP59B74TAC9TKJXBWP6YG73RDZW2PDF, amount: u5000000, memo: none} {to: 'SP594KRAKXE74HY7D1S6TKPD30NZYP2C6KHR3RXT, amount: u5000000, memo: none} {to: 'SP3JBZYA4KHZ4BP2E94Z979Q79KW75EW9ADJ6ANFV, amount: u5000000, memo: none} {to: 'SP2KZ24AM4X9HGTG8314MS4VSY1CVAFH0G1KBZZ1D, amount: u5000000, memo: none} {to: 'SP3ZTW0J4FZHDVVH8RV3FCYW535FRQN495GV904EQ, amount: u5000000, memo: none} {to: 'SP2Z4323QGZVRCVRAJ8VABZ7SF7K1V8RXQ482RX42, amount: u5000000, memo: none} {to: 'SP3DVC4BF5QG7VB7NBWY25QV4W3YR8T2JKKZRVQWD, amount: u5000000, memo: none} {to: 'SP1WB26C74Q010P0Q3ZTZTAT1YAQTBV1PFNMZ69D4, amount: u5000000, memo: none} {to: 'SP1Y5AT2NQ915Z6CRTTDE4AZDHD0CE4A8K2GC090H, amount: u5000000, memo: none} {to: 'SP1F6E00YQK63FFQKJ7MDSYW2PGD05Z4VCYXEMV5M, amount: u5000000, memo: none} {to: 'SPW2B3V8R33YQMY0Q224BM2K1HT4384V4AE268P3, amount: u5000000, memo: none} {to: 'SP3FEYH9GEVJ7X16AJKARQFQ298DDMCEQ0FA15YRV, amount: u5000000, memo: none} {to: 'SP2KGG7DDH65TGB9RV36233W3ZBEG9CRQ6AQKGRWS, amount: u5000000, memo: none} {to: 'SP3YFDDQ23DV353XGSN3A7MNVN0C2VZRWZR1NST93, amount: u5000000, memo: none} {to: 'SP2CX9488XXKQBZRDS866TKAFRDVDTP5QE8HN1B3Q, amount: u5000000, memo: none} {to: 'SP92NJ6Z9K7K7VNG3TZWNK3QMZCC6KES2D80HS9F, amount: u5000000, memo: none} {to: 'SP1JVD0FZP3HB5J6QMXCHVW9STPER4HEZ8GRFRVE6, amount: u5000000, memo: none} {to: 'SP3Z991D5QF6EHG2T9TZKDM9M7B010PZTNQD9XK7J, amount: u5000000, memo: none} {to: 'SP1MRWBSHDSSHYAGHECK85K47ZYW9ZBPZF3ZFNG20, amount: u5000000, memo: none} {to: 'SP1EPFBVNVXFARAJFMNJNREBAGNC04X7Y6FNBZ13S, amount: u5000000, memo: none} {to: 'SP1NHS7H3KCYP19KSBGRAT77B00F0ZZ6QW0JP6CAP, amount: u5000000, memo: none} {to: 'SP2Z9T2N2E1HQBE44E8GZHF503DMABTRTADCNZKNC, amount: u5000000, memo: none} {to: 'SP1R30HVA28N3117QX5A16KNKZ2VYY3TZ0BC8YEYM, amount: u5000000, memo: none} {to: 'SP2XNRBD1R53A7C06T3P15RY2B3D1V6K74RBMZ392, amount: u5000000, memo: none} {to: 'SP34GX3AX2JTH0B81RAAR6XYRE9G3HW1FJ3JHPSXE, amount: u5000000, memo: none} {to: 'SP33QPZNWBBS236EJAWNVJWTMGRQMTXR566P5N8ZC, amount: u5000000, memo: none} {to: 'SP2SNQHT55ZM0TBF7DD0TA39XM652QZ97E3CXN2SJ, amount: u5000000, memo: none} {to: 'SPCEAKYNEKN5XJT3X41DAFGJF7QF3DHT1C2W0551, amount: u5000000, memo: none} {to: 'SP807PQ8JQG23JWNKM1S2MHDTY7Z65J29KWRN5FC, amount: u5000000, memo: none} {to: 'SP2072BTG3AG2E6YPVKXYJ47PHAPRGD6AEZKESNBE, amount: u5000000, memo: none} {to: 'SPJTYDJJWB7QHN0N755N80JCZKHJPBXZQ38GQBD8, amount: u5000000, memo: none} {to: 'SP8GZ98PK2JH2R3JV31KESWD8RYZA6WHRH8EJMTA, amount: u5000000, memo: none} {to: 'SP9C3EVCWBQ4E3W4MGRA3H74WA4Y7Q1TDNHRNNJB, amount: u5000000, memo: none} {to: 'SP2MAPP0KGQGXW85FPGWKVM0JCW5R4JG7P3QV7V5W, amount: u5000000, memo: none} {to: 'SP12FXFA3825SX18C4K5ZVZTM6XEK1X0CTD44HVT1, amount: u5000000, memo: none} {to: 'SP2M64A49FD47RC7WJZNH9ZZPN6R72BQ2S4ZDV9MR, amount: u5000000, memo: none} {to: 'SPC9FE95JR0N04FSXM4EPH3EZ6JG39029PF0SJQF, amount: u5000000, memo: none} {to: 'SP7TYMCHNJJ0F8FQPXSN2B7TT90V9798G2PQ2CN3, amount: u5000000, memo: none} {to: 'SP2MVAYYW2VZS35870SFRH493NZ8GA1ASY83FXYR2, amount: u5000000, memo: none} {to: 'SP2Q09ZN5G7RQ237EFAKDS8J1V90QVH1NJBC9901X, amount: u5000000, memo: none} {to: 'SP25J1YASYZ3S8VQP2220PHZZ3P7VNVHK1B4DX08T, amount: u5000000, memo: none} {to: 'SP1G8C3H9AFBZSA2X32XGNYYPRC233Y0JZXNTTAA6, amount: u5000000, memo: none} {to: 'SP1TZS4DAM4NBGPTS8CCTZ14MB0KD3G4RWGPBPHK, amount: u5000000, memo: none} {to: 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK, amount: u5000000, memo: none} {to: 'SP181F079PVMRSTP73XPJXD0MJ3RVS95RKM1YY4YA, amount: u5000000, memo: none} {to: 'SP1603T0TST2PWCZ8P05N355YH5644WNS452FBJT2, amount: u5000000, memo: none} {to: 'SP2RAHGK109E7KYFSY26MXNFHP9220BZ3ESSZH9E, amount: u5000000, memo: none} {to: 'SP3BZW8TGZX7TGA6RFWHA5EGW8DPXMHA8G2CER58, amount: u5000000, memo: none} {to: 'SP36GVWQK11AJQTV6QRKY93ZJ2TAG286CYKFNXEC8, amount: u5000000, memo: none} {to: 'SP1S17Y59Q5GRHWZAG3GES5A04H78RPBQCFRZCG71, amount: u5000000, memo: none} {to: 'SPKS2F0YKTGTYEJHY7BR7DRWKTTAXRZ7TVZTPN7M, amount: u5000000, memo: none} {to: 'SPV1DM03GA6KRZ2FY9PNBKFPW51GCF41TYDGW21M, amount: u5000000, memo: none} {to: 'SP2RRX2EKSDFSZQNQEFJ0JXJGTJ7GGGB29KKE1AXB, amount: u5000000, memo: none} {to: 'SPFDAYS6C5XBH3CEMC6R210P348YXT7W1Q69JKPP, amount: u5000000, memo: none} {to: 'SPVR9PDHJHGJT59GE10E8QE2433YAZY6Z47EY13P, amount: u5000000, memo: none} {to: 'SP1PTW89FS94MFZPVT8RKQ5X8ZJR68X6CCXQHN161, amount: u5000000, memo: none} {to: 'SP2C72R5ZP035N7F6EC72P4AM314H8EJNB2R3B70J, amount: u5000000, memo: none} {to: 'SP2YCQB38E908PMAABD0FYCA00FX22311MPMHPEZ0, amount: u5000000, memo: none} {to: 'SP3HXH8YZAFY0PBSY3F30YP01R2BGFRGZ6QJGVB4R, amount: u5000000, memo: none} {to: 'SP1BFEQNAG1RBTX7T9CAZNKGPJGKT1BBDRGN4TM0K, amount: u5000000, memo: none} {to: 'SP753DM4YTCETNZC2AV9BF26XW61SFD8MDTQDE13, amount: u5000000, memo: none} {to: 'SP2XMCX1AST1PM21CWDHW5YBSSKXG0TXAB45JCS6, amount: u5000000, memo: none} {to: 'SP3658EQDEKG3RYGVE4H1KC3PAS8MRJCXPJN7CYHC, amount: u5000000, memo: none} {to: 'SPS1V0TA8RC4BNY60HEHAGN77NP5YCCTKFNKZ3C0, amount: u5000000, memo: none} {to: 'SPQTVFCKQJMZYZBC2XA0R5EBDMSFEYWZPJ8SFG4P, amount: u5000000, memo: none} {to: 'SP3TAQCT0KQ1TC9E6XJ33J26XPG1DGSPS61M61H9G, amount: u5000000, memo: none} {to: 'SP143S7QJWE14EYGVTC99HGYEMG70YVG1RT81KA1A, amount: u5000000, memo: none} {to: 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV, amount: u5000000, memo: none} {to: 'SP1WK5MA8RPTT10C2EQ4BEQYN3BBEYY8MCY5FFKRQ, amount: u5000000, memo: none} {to: 'SP12FXX43RDKMHD2BNQTT6XYQX4AMEEG52XT36N9S, amount: u5000000, memo: none} {to: 'SP3RY185H0R8TNX4PGRYFZ07AV001N23N1FJX9MEE, amount: u5000000, memo: none} {to: 'SP3SDZ9WKEDX6WT8BKMY80SM37VD6QKGQH9GP5CD, amount: u5000000, memo: none} {to: 'SP279WY2EJTR9FB8PH02110D5YTCJ3WM6Q6FRXSWN, amount: u5000000, memo: none} {to: 'SP1KNRNZET8ZC5Q9P6F1FFW8YQH45CKMNY132B36S, amount: u5000000, memo: none} {to: 'SP2HS1G06D79W336VVZM38DSVTXA8V4YB1NPF76QN, amount: u5000000, memo: none} {to: 'SP238X3JD22HJBMWR8E7CKTF4JCBQ73BG9YS1DBH8, amount: u5000000, memo: none} {to: 'SPFBQ9HB0FH3VXS75RFHRWZQ5M9DY2FCT174Y9GN, amount: u5000000, memo: none} {to: 'SP3EJCRT5V10W6JBS8D76J5PXCTF0SD250N1Z1HRS, amount: u5000000, memo: none} {to: 'SP1K1B8243JPQGSGAPT0SDDW01VWF2D6YBC8M1CRH, amount: u5000000, memo: none} {to: 'SP3PQE65P3PX6YGA8J2CC74NPD02Z40JY69BXS3PC, amount: u5000000, memo: none} {to: 'SP2ZTY5Y18BHEPMTHDKFVJ1F8FT7CK1TSKFTM350S, amount: u5000000, memo: none} {to: 'SP23JX6EVN9GK7A4EWWTEJTP6BP75R0SYJX7TV1D9, amount: u5000000, memo: none} {to: 'SP1DZ6CVX4TYYNRV39WBPSH18EMA5C6S6TZHBZT75, amount: u5000000, memo: none} {to: 'SPWC45P8JQP1VG9NDNPJ6ZXPVZ4XXGK06GXR5XN3, amount: u5000000, memo: none}))
(contract-call? 'SPZX1HBFWAQMCJF9D5CZK0D067Z86KC2XVY75KKY.kitsune-inu send-many (list {to: 'SP12PV7PWGHDY37CF5T38CMGC27T01X25KN4RF3VT, amount: u5000000, memo: none} {to: 'SP20QT7ZP4PFNTZNX97BQFHZCDJBM3B9NA0WNQD7E, amount: u5000000, memo: none} {to: 'SP1N0P0C47K4JN9TW4XAZW7AKEH7490709F5W7KA6, amount: u5000000, memo: none} {to: 'SPAK2ZT2XXXWYK7VF96BQC0NEV4WZQGC47Y0T864, amount: u5000000, memo: none} {to: 'SPBNZD0NMBJVRYJZ3SJ4MTRSZ3FEMGGTV2YM5MFV, amount: u5000000, memo: none} {to: 'SPFJJQTRGYA8H4S14D7GD6MTP4KFE324AET54JEW, amount: u5000000, memo: none} {to: 'SP3CDM1FWZK3MSREMF2F5XF888TAKNY5EWVY2QA50, amount: u5000000, memo: none} {to: 'SPGW9BJR01CAWR50XP563KS4FCTD0AR8YBEQB81V, amount: u5000000, memo: none} {to: 'SP35DZ04QSJKYNGMJV1K8BW7JEAE039GS41CFR0W9, amount: u5000000, memo: none} {to: 'SP1QW0SDVT6E22HWD2G5JRTM68GD199HERQWMHSE6, amount: u5000000, memo: none} {to: 'SP1EHJ1PBS8ZHHM991PWYE77D7MD3B76BQJ47GCX4, amount: u5000000, memo: none} {to: 'SP9RV75K77F7G8HKKKVS3438JEH8ZBEW36PEVNW9, amount: u5000000, memo: none} {to: 'SP2NTQPZ71HRHXMGE3WYVCNSDYDBJR012S6TRSDFB, amount: u5000000, memo: none} {to: 'SP3T8XVBX10T72WB2E41ZTS5NCY85WC6YMWR2QA6K, amount: u5000000, memo: none} {to: 'SP1HQDXGN55G42GWT2TQN0DDQSM41NGF1FGJ5KK9C, amount: u5000000, memo: none} {to: 'SP3KDPB1XS8ST0K0P56RQY801KREBMPXD4FBX3RDJ, amount: u5000000, memo: none} {to: 'SP15X19EZ14DF9VVATBTBKXH56A8QAGN466HKXQGP, amount: u5000000, memo: none} {to: 'SPCDCWBEZ9ZEK49BNMDE2MDMJ0E01W02H9SA4TVZ, amount: u5000000, memo: none} {to: 'SP1ZD4FWR418R91DWQGMN2SNWBV5QQV4TYQFWBTQY, amount: u5000000, memo: none} {to: 'SP1QFNWW4G31MMDM7315VQVWK7ENTGJD3V3SRYTRQ, amount: u5000000, memo: none} {to: 'SP3HYMM87H9N4JFRRJ67TYQDCYV17BBB54J0RST0C, amount: u5000000, memo: none} {to: 'SP2Y8KZ07NJV1QA9NG5RT4SSCT07S12HMNP4A4WXC, amount: u5000000, memo: none} {to: 'SP2JWM4MB1SBY2FT3PG5PM0V12NW8Y4FK1XXWBHSF, amount: u5000000, memo: none} {to: 'SP1DAD610W1MZ02YKDYS0W681ACNZZAQADK6CQ8V1, amount: u5000000, memo: none} {to: 'SP2H9Z97J0B3159H45ZFX6TVKS9RT3KVKDPGAHJC5, amount: u5000000, memo: none} {to: 'SP2SFZX1WJSKT1GA2STDT6E5NWDX44GW4BB8DW4DJ, amount: u5000000, memo: none} {to: 'SP329M6CS0S3738Z0T268FXQXBSX0ZD1FZVBZS037, amount: u5000000, memo: none} {to: 'SP1QJ15XM7CJRE7C9XQZEDEV9K8C66ZA177XEMPNQ, amount: u5000000, memo: none} {to: 'SP2A4R43TCNHZ19AKK44WEBP4R16X7DV4093GQ0X4, amount: u5000000, memo: none} {to: 'SP18148N2DV6AHCXKXXWZRNHWASEMHTK024S41HAE, amount: u5000000, memo: none} {to: 'SP3XY5TSZC1N6G93Q0PNQWAR9N5724PNBKRSD249R, amount: u5000000, memo: none} {to: 'SP78064ZF3TDWDNX3AZ293DW0QJ6EX3TJVWENYPA, amount: u5000000, memo: none} {to: 'SP2WCB5H1BKN04XGYKZZSNCSKSB1JQCNR0DX2GTMK, amount: u5000000, memo: none} {to: 'SP1D2QBX3EEESR2KF16J8E5119WYZR8TE3A9KKV9E, amount: u5000000, memo: none} {to: 'SP2TPDSTGHXW6JBP2GKHQQ3WYK41AN1Q38AN8BVPP, amount: u5000000, memo: none} {to: 'SP2GYXR37WGDP11A2CT9T4HBXDPS8SA6YTHQ8A2NH, amount: u5000000, memo: none} {to: 'SP1T12938AEDPVPK0QMK6FAB1JMJZMBZVFJXQTV1P, amount: u5000000, memo: none} {to: 'SPBGX7PWC5719ZSPCMA8YJGXM08HVV93SR5PQ102, amount: u5000000, memo: none} {to: 'SPRH1453F58A1GMEN41ZVNRC05JJ72YBAJTZ65F5, amount: u5000000, memo: none} {to: 'SPGGZN2C79FBCTY13FWRMC60RF2VPKN4H57TKJC7, amount: u5000000, memo: none} {to: 'SP1MTDQ4S1FHFJCA9MQYGRKJ4HEA9RJ3KEXG9CW9B, amount: u5000000, memo: none} {to: 'SP2DXSMHAEAS5RK9G38XKD80G1N14KFS1C1ARAS50, amount: u5000000, memo: none} {to: 'SP382ZXETYB3A9HXK2MWDVGTAQ49M2JGMNNX5MJ7S, amount: u5000000, memo: none} {to: 'SP2WC112DEJR44WVAX5A2WZ21VCTTVMY000AJKKYT, amount: u5000000, memo: none} {to: 'SP2RNHHQDTHGHPEVX83291K4AQZVGWEJ7WCQQDA9R, amount: u5000000, memo: none} {to: 'SP2P8RJ42R8MP0AAJASTT7ST6VZ7GHCWR7PET3B21, amount: u5000000, memo: none} {to: 'SP23MR5Z8WEA6ZXYFPB87XW60KD7ENS2STX2ZAG17, amount: u5000000, memo: none} {to: 'SPBFPD0285PKTCTADGP9GX2JFE12R8ZXSCWRYW39, amount: u5000000, memo: none} {to: 'SP2B0EJEMA0AGY9C986WQZRG9BAYMYMTWT990JSER, amount: u5000000, memo: none} {to: 'SP31CZZ7NJA484QSV739BKF1NH13G4XBCJ1AMM9GW, amount: u5000000, memo: none} {to: 'SPGSDWYMSA6FTYPMV542D19FTZ73A7WPYXKF1QWE, amount: u5000000, memo: none} {to: 'SP3243SNNN9AV9N4NCWKEJ5AC82MCY3PD3AKXX3ZR, amount: u5000000, memo: none} {to: 'SP2HMNV7HAAWYBYDE3CPQMGZ14V137E78B53KEJV1, amount: u5000000, memo: none} {to: 'SP3W83KG17KJZZXPDZQDTRQKQRGHNFZN410R9P02E, amount: u5000000, memo: none} {to: 'SP2EB6GVMGRJKJC7THQTMKV6ZSTM29B4E2S5M4CVD, amount: u5000000, memo: none} {to: 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG, amount: u5000000, memo: none} {to: 'SP2FK12Y691KF520H82B39T7H6MKEX7NRJ94K5KEV, amount: u5000000, memo: none} {to: 'SP1ZCYG0D3HCK2F7SY8VH9ZREB0JWCBSAPFNS8V5Z, amount: u5000000, memo: none} {to: 'SP247TX129AZ7T4MM49W4ZGKJSA4Z9Z1FX8A66B7R, amount: u5000000, memo: none} {to: 'SP3JATJK4G0HVYS7ED03EF1MSQCYDCHZ8RQ5TNJZ1, amount: u5000000, memo: none} {to: 'SP3AD7E7KATKS1042VHGEF7DHAE95QTKTXCQ2PN6W, amount: u5000000, memo: none} {to: 'SP3AP6DTCK6G65A4TK78J8J9NSV9DGMNFW0K7Q6YD, amount: u5000000, memo: none} {to: 'SP1YP3RVGRKV3F0PBC1ZQHGV1ACZT05087ZTPRZAQ, amount: u5000000, memo: none} {to: 'SP3T5Y7Q14P34ATGNY6VQMJHDH3D047F413EN9Q56, amount: u5000000, memo: none} {to: 'SPR08BK1VKD1YD6NXFF3JW5CEQPJE3HVFP8SHBSR, amount: u5000000, memo: none} {to: 'SPXY0VFX761352VTJPAMNYTJYYA82A5DRH0VR57P, amount: u5000000, memo: none} {to: 'SP33KXWETMY4RN3ZBPQB69H46MRF9TA5971VAQ09Z, amount: u5000000, memo: none} {to: 'SP2JG0SHYCJ8FN3DMZH3ZGMECFH3PFQEDX1T26QTY, amount: u5000000, memo: none} {to: 'SP2R826J48G3P8G7C2ZTQ9V72N6M6RBGD1BJTDMY4, amount: u5000000, memo: none} {to: 'SP3C2753ZD7JRQ15JEC3DJ2X6YGE5NSHXY78TY23D, amount: u5000000, memo: none} {to: 'SP3Q5BWKZTN3GMTYWFFBM2TVRVVWRZWYYF8P6D2XE, amount: u5000000, memo: none} {to: 'SP123EVPE3PA6XJZ90CEZ3SVR8KWTEFCZD65NKDWB, amount: u5000000, memo: none} {to: 'SP2EMZSA1CQQCGJEQ9JSDBWBV0NFDJ59EH5P9E56V, amount: u5000000, memo: none} {to: 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G, amount: u5000000, memo: none} {to: 'SP3R7JD4FYCC65ZYGE1PYJM2T5BH39TJTPZRM5QRT, amount: u5000000, memo: none} {to: 'SP3D8TTGYNSS37NJWF7H4FZ00K8DWGWT599TVJ3V8, amount: u5000000, memo: none} {to: 'SP2W7H14W898Y29YHZJV44V4SS0C0VXNH3TZC2HVD, amount: u5000000, memo: none} {to: 'SP2D8RP8J0EYMZPFTT0SS0YE4HR0JV6CBBAB9508F, amount: u5000000, memo: none} {to: 'SP1Z8F1C9AVVRMQCV3ZW7CBSKPHV89MG275AC5PA0, amount: u5000000, memo: none} {to: 'SP2QVKZ2GWP97TW4RNCT8TN65JRJPVAKERHYSS13E, amount: u5000000, memo: none} {to: 'SP3RDC4C9B0A2FG8B7DQ9MBTFPYQZNDAVCBME8Q41, amount: u5000000, memo: none} {to: 'SP2387TVHZ5X6TSCD6HNDA7N8ZC4M1XNYHFBHNWS5, amount: u5000000, memo: none} {to: 'SP74BB1WD3XG6V7NMK4TW5SFNHTJ5AD4N84CAZMF, amount: u5000000, memo: none} {to: 'SP1W6PTFG2BEZ4ZFKTBTK9W4Z7X5YHQCR41WN67N9, amount: u5000000, memo: none} {to: 'SPPYPG5369EGVVRRM7MWBGD2PGQX1HDEH7G4KFEA, amount: u5000000, memo: none} {to: 'SPMZ912TEK2P15E8Q9W1W33QN793XR7XVDYY4R8H, amount: u5000000, memo: none} {to: 'SP37T76GFXWD6RNSAT2TRWDEFN36A737JA41Z0M1D, amount: u5000000, memo: none} {to: 'SPWQJSR0FPTZQCQ7GF7VJMA76QV89PETA27ZCQX7, amount: u5000000, memo: none} {to: 'SP1ZWG5WEND2QSYQ04DAP17A5RMDBG76NXQQ115SK, amount: u5000000, memo: none} {to: 'SP1269QYBVVMGM863Q7NFWZ9DKDSHG97EGK4KP51J, amount: u5000000, memo: none} {to: 'SP3K7F99KPDX8ZPMB6PS8XTADAG32BZ003CWDPWVN, amount: u5000000, memo: none} {to: 'SPWSGE1CDEHMM56SGMS9ZY3P91Z0G7YWD6R04KCA, amount: u5000000, memo: none} {to: 'SP8CHH13JYCS3SZDBG28MH4M5Z2ESEH0QF4GAXQF, amount: u5000000, memo: none} {to: 'SP335PH1JFHVP8BZQ2HYJZHV3VNQRKWDKTNJCFBCF, amount: u5000000, memo: none} {to: 'SP2H4BKDA61N7YDCZRJZJ17AB33KHJ7SS8TPK1FE0, amount: u5000000, memo: none} {to: 'SP1F6VVB5PW0E80YKNNVC3NFS77W873DHT400VFYK, amount: u5000000, memo: none} {to: 'SP260ZF58NPJZCJGB2K51327RW299BHES24W4ARKE, amount: u5000000, memo: none} {to: 'SP3Y40HEB35N00GQ82HRPXYEFN6BYR6ZB9R399VY4, amount: u5000000, memo: none} {to: 'SP1C0CQCAGZ48RSKFPVFPAKBRT88429PN2BTTNAHE, amount: u5000000, memo: none} {to: 'SPBN8C718NWZ9588BMNA0CNF5YTGW04VF3AEMPRW, amount: u5000000, memo: none} {to: 'SP95S67V2MK08PBN7P2QC6YWBMWASRSX6H6JFZ7J, amount: u5000000, memo: none} {to: 'SPHCSG1R7QAJPV085VT2N06J2PEF0CJ7X9PTHYYC, amount: u5000000, memo: none} {to: 'SPHWQBXQAMZYM5EHX4QGCSCKAGXCRJCM572ZNYAK, amount: u5000000, memo: none} {to: 'SP2A1GBDNBDBP50JAWDC4F940S6E2DTBWX7DDGET8, amount: u5000000, memo: none} {to: 'SP2NAWN9QNDE2DE93AHR7CH68CPYMPVC8BV8NV2BM, amount: u5000000, memo: none} {to: 'SP2HDF5A0ZD2CG2SEE3NSVE9TCPFJ3Y14BQ8W997Z, amount: u5000000, memo: none} {to: 'SP3N5C56QF3NNQC7D3D1TN7R4K3V59TFDSKTEKKCQ, amount: u5000000, memo: none} {to: 'SP3TT0MVCVSWBS7QRBY0FGVA9BH4DYSYYX74G5P6V, amount: u5000000, memo: none} {to: 'SP3M91QPK24F300VBFN7PV9SA4RMC6KQP63S1BYXB, amount: u5000000, memo: none} {to: 'SP3C5C0KBMRE7A22GCHEC3YTBKYKF4X936K4JCHS3, amount: u5000000, memo: none} {to: 'SP2BFQXBX1FHGFR6P3DZ6N6VPBS31S8YZQAT8E3NN, amount: u5000000, memo: none} {to: 'SP3XVBQ4FKDNDTS3KFQ83GED16J845ZNK6PXCW7RT, amount: u5000000, memo: none} {to: 'SP1QYG7Q1NT7Y9X8GV4DQQYSM2X9DDVH304BVYF0Y, amount: u5000000, memo: none} {to: 'SP2N7VSJ2DT9NY438G3VDWYFP3WWBKYN46GQPHH6T, amount: u5000000, memo: none} {to: 'SP39859AD7RQ6NYK00EJ8HN1DWE40C576FBDGHPA0, amount: u5000000, memo: none} {to: 'SP17PZJ9A8W29FGM8BRY96M0XDXE6PRZX9DJHB926, amount: u5000000, memo: none} {to: 'SP5TN2MP8EW41ECDDS9R10AZJAACV5RFBVP6PR6X, amount: u5000000, memo: none} {to: 'SP2H8DP4MHZG7VQS1SAZCDJZ7F8HEP3DYKNRMEFB4, amount: u5000000, memo: none} {to: 'SP3SX5CW9RPCHHWR833NTKFE116A4KGFGDAEBV34R, amount: u5000000, memo: none} {to: 'SP2PZYA27E8MRBQHQXE0JQH5CHM9JJNM00YEMC4QJ, amount: u5000000, memo: none} {to: 'SP3WAAYXPC6WZNEC7SHGR36D32RJPZVXRR1BG0QSY, amount: u5000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u2000000))
)
