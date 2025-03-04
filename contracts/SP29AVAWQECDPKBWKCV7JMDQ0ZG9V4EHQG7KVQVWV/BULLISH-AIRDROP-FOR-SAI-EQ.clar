
(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP29AVAWQECDPKBWKCV7JMDQ0ZG9V4EHQG7KVQVWV.stacked-bull-coin send-many (list {to: 'SP3M31QFF6S96215K4Y2Z9K5SGHJN384NV6YM6VM8, amount: u100000, memo: none} {to: 'SP36SYFW550MXX9T1H0MJXVCQ6045DF03W2N7YB9V, amount: u100000, memo: none} {to: 'SP3DGS23N2NAMJZZYFVNYS331GRVY1CVJPAKZMEGN, amount: u100000, memo: none} {to: 'SPXA6ARZECQFWY0B3ZWT3S8ND22255EDN2PE88A3, amount: u100000, memo: none} {to: 'SP27G7PE8VWZ2JC91K0D2KVWFME9AGWK2ARK8HAMP, amount: u100000, memo: none} {to: 'SP2DPSWCHWV27C6PVEP5GD4731QX40JGYC0ZKTGJT, amount: u100000, memo: none} {to: 'SPN8QVA4H4F6KCV13P2QZBJR878SE9WE80KT9QS9, amount: u100000, memo: none} {to: 'SPRWNYXVK041BCWWYCRWX4VRS503A85MQNXYEC3R, amount: u100000, memo: none} {to: 'SP1MKAKC9PVCCZXPPWFNEQTH2HFDV2VCHS8SE7C0P, amount: u100000, memo: none} {to: 'SP2YYG5F3GKC2RWCQGFMSRAKS2BY5RCNZZMKV7BWD, amount: u100000, memo: none} {to: 'SP2XE654A8BDXM740KDE68A01B0RGB3YV1S1PRQW, amount: u100000, memo: none} {to: 'SP210TA1X155Z2KKBH53AWX38HDAWEVXB9GY41CHV, amount: u100000, memo: none} {to: 'SP2J6XWX2703GR3NKKJZEA2ZZKYXYVXM1SYW4KCV3, amount: u100000, memo: none} {to: 'SP271WW77JVK3ZF4J2D2X85J0TS3YTWW65G02NDKG, amount: u100000, memo: none} {to: 'SP29AP5ST6S4T6QMYH8594YRG1WMK2YMV67WN4E8E, amount: u100000, memo: none} {to: 'SP3ZDA2TJV6BMKNK7ZKGTQPYC4M3SSMR24V736XNC, amount: u100000, memo: none} {to: 'SP3Q6P7ZT52EWW58NRHGJN1782ARW50P38M6VV8EX, amount: u100000, memo: none} {to: 'SPSGNHGEV58J2A7N8TS946JK3BYMXADJH0F11F68, amount: u100000, memo: none} {to: 'SP24Y7PJ1VVFG760Y6B558KNWFQKHDZ3F2MGCB6JJ, amount: u100000, memo: none} {to: 'SP2YJA5P986DNJPMTR5CMY9GDHE5D6NZTT4S16VVQ, amount: u100000, memo: none} {to: 'SP1APJ38R6X3QDTSBEK8X7KEQRH8SM5N32RBDN6XS, amount: u100000, memo: none} {to: 'SP23E63ZKD8KG91DHQCSBP3A112DGHCKW6M3EGYK6, amount: u100000, memo: none} {to: 'SP1QVASZ0RF6NHNNFXV2YMA3VDPM1PN9TXNGWM15A, amount: u100000, memo: none} {to: 'SP2PPY7A58MF8V2Y2EDXJSTYCFAJBWVPG3N0R5GAQ, amount: u100000, memo: none} {to: 'SPVKZRCR7KJE5MQ2FCQPT7YPGY2MCS8DGZ7T7T1Z, amount: u100000, memo: none} {to: 'SPMPG4Q78YGJF114HR9BRRJ7QNMQ3WTKMJ4D7YY8, amount: u100000, memo: none} {to: 'SP26QE8ZT1213VXS54SH315ZS0SPSFEJCSVNCWZ4Q, amount: u100000, memo: none} {to: 'SP2N5HHMKKDVS8HSZXX8EA7JX7H895VTWTV67EP90, amount: u100000, memo: none} {to: 'SP369QT67NYESRSYTQHNPZZ2JGVPBSF47KZMPFZ1X, amount: u100000, memo: none} {to: 'SPPFKKZ3YDRT33RCBAVP1KX08215X8WYFX1NV1Z8, amount: u100000, memo: none} {to: 'SPP5D3FNBCPE3MDY278QPC9C5654V247FGYET54J, amount: u100000, memo: none} {to: 'SP3HWMBE0Z42CPYY589XVKVXEK4BMF24Y05ZT9P9, amount: u100000, memo: none} {to: 'SP13QXC3F0QBFFN73DGBQ8PA6G0YFPYB0KQ4FR5MG, amount: u100000, memo: none} {to: 'SP94VPZ90K4FHQSDB86JGPYA0388VHP2R6KHQ1XA, amount: u100000, memo: none} {to: 'SPX5JETF35KGMVQ66KPS58XKK9N8YFNS7DSATZ96, amount: u100000, memo: none} {to: 'SP0DX44TBK5WF34FA7XT8WX1JK5QB0NF61TG8A20, amount: u100000, memo: none} {to: 'SP13WHEX8PJ8EFCBF32BYGD45NDMZ5H7TSFXZMVRD, amount: u100000, memo: none} {to: 'SP3EBWBPQJ6JMRK1285W75W842RXZQ1J1V8XM190F, amount: u100000, memo: none} {to: 'SPENAF4JGEP9S0FBNM32QJRVPBFJVRQ2EJCAHVS9, amount: u100000, memo: none} {to: 'SP3SKXKKGW2MDNFWDN4Q5V4654VRKT4WCJV2H52Q5, amount: u100000, memo: none} {to: 'SP2Y5TXQ5BX5C9ZH8AT76QW11GVMQC73E5A4X21DK, amount: u100000, memo: none} {to: 'SP1HJ43ZSAYWPK27MBC2NS50JV2CK01EXEFQE1FK7, amount: u100000, memo: none} {to: 'SP238F4X8XQAWZR0A93KVQWH6K336E28HB4BNF0PQ, amount: u100000, memo: none} {to: 'SP3QEXAGW3M02N0S2XFC3FVADAD3ZWRNGWMQDN3Q2, amount: u100000, memo: none} {to: 'SP17WV83JA5AC8BXQN16V5Y15K6N4A1ECRGHNW6HC, amount: u100000, memo: none} {to: 'SP359MH86SSBYR7CD9MBYEFEZCXETJS3CVX5TF3GN, amount: u100000, memo: none} {to: 'SP1M5KG0D88KNPCJH9MMGN3YZFP17NDVPQSJVPMCS, amount: u100000, memo: none} {to: 'SP3S22XXF93KDCHGF77XB21QWAMQD26MAAR312XA1, amount: u100000, memo: none} {to: 'SP2468TRFGYZAJ0P86NNMPNJ08KPH9WH2A4K2ABD2, amount: u100000, memo: none} {to: 'SP3R025QAM7VA8NPCP8S5E39SSPR6EKN9TDZHVYBW, amount: u100000, memo: none} {to: 'SP1K35PJGG3VA85JWPX98AN5FS6R0CFV87DW7GAZ8, amount: u100000, memo: none} {to: 'SP120D0CYMB5AKX7YJCGK3PH28N1ZEE62WTDMADGN, amount: u100000, memo: none} {to: 'SP3B8VSZN7BWE8CBXJTBSM4R2QQNAMZB8DTTB5PTN, amount: u100000, memo: none} {to: 'SP1DECG2RND2NJR72HKXMXPVMV496S4G30VW9EV1J, amount: u100000, memo: none} {to: 'SPWHMR51KW4PZKE13DZNM7V515Y3HC3JV4N4MB6J, amount: u100000, memo: none} {to: 'SP26X9RJXYM8K14BWDHWP75S1DSTVJWHPP59DBMAE, amount: u100000, memo: none} {to: 'SP23NKTGXAW9QDM24Q71WPD5FFN9Y5HFSC0QAMWK1, amount: u100000, memo: none} {to: 'SP1PFGGYWAKE1ESX7RNKMHSK0TNM68J5JF18TPTYN, amount: u100000, memo: none} {to: 'SP1DKBEE3SZDQX38SHCP149J93194NK8M51XQYTEY, amount: u100000, memo: none} {to: 'SPN5Z0F7EKVYKG7DQESZAQAVB6AQC8P8Q3XREJRV, amount: u100000, memo: none} {to: 'SP2F72QRY66GTVH72AY69242K63DJF2NPTEF0HV2N, amount: u100000, memo: none} {to: 'SP1CNHQ9X1GQ3Z46DA0AVFH66BX42G1GDB3T118YR, amount: u100000, memo: none} {to: 'SP7PANKRW56BX5SVR64QC1QNJ2XAGDX6N631ZHMQ, amount: u100000, memo: none} {to: 'SP1K9RYF8B7Z74KAQJBFV0Y6V2G2BMA1WX2EJKYEZ, amount: u100000, memo: none} {to: 'SP2G3PMV6VCRT9J00J1H467C86HEKP97SFVQK541A, amount: u100000, memo: none} {to: 'SPJQ5GN4CETCAAV5MCX6B9HAQCPV15VJQFVMYXMK, amount: u100000, memo: none} {to: 'SP36RWPBEY629GKX6QM5Q9FB8Q8CW0NS2ZSX773K1, amount: u100000, memo: none} {to: 'SP2M587PXHGCK8JWHR1ERDE1E182R5VZ24NS3GQ51, amount: u100000, memo: none} {to: 'SPZ7WEX5CM4FJ5GDQV96N3XXCXDWBG3YABMFFXMB, amount: u100000, memo: none} {to: 'SP10TDS4NPHEGXR58HG1BDZ82WX4J4G9EE6XSE58, amount: u100000, memo: none} {to: 'SPCK4A018WRDZA07TSHGJ3MZENE6HYY1ZGPWSHNV, amount: u100000, memo: none} {to: 'SPJZBA2BE74D5RR3D2T10YF4C7216SWZ02JHS1KT, amount: u100000, memo: none} {to: 'SP127WFR38MGRE6BQB1TZ944SXA9S46TKZ6QJCQK7, amount: u100000, memo: none} {to: 'SP2GYCDWZM40AF9A0NAV57G9B81B77GYAVMVG9VCK, amount: u100000, memo: none} {to: 'SP3FR9GB0DPZ7YM0EWVHFZ8GXJA56NG3ZSQFXMQAR, amount: u100000, memo: none} {to: 'SP2FM4A6VW48SMGQYW5GXBRTMM049YRBCEM9GBNRA, amount: u100000, memo: none} {to: 'SP14MHHRE8MSPQEYZ8Y01JTZ2AGGNH1GARRFQ0DP7, amount: u100000, memo: none} {to: 'SP3TPN8PRYJEH17TN5781A0B2TH2MTMWM3PEN6PQM, amount: u100000, memo: none} {to: 'SP31NBMQPWYJ4D57YF4P7C8WG6TH1EXYT3N462EER, amount: u100000, memo: none} {to: 'SP18N1FFE60W13NBC1SX16W5KGR5QJNTFFX87YCPY, amount: u100000, memo: none} {to: 'SP3Z991D5QF6EHG2T9TZKDM9M7B010PZTNQD9XK7J, amount: u100000, memo: none} {to: 'SP3YGV4PGA8GPQR0CPCK0RFXQ83RNJ9GM774YSZHN, amount: u100000, memo: none} {to: 'SP5QTH4QQNB77GTF9FJM8AS4BB32PNYT2SH14T6W, amount: u100000, memo: none} {to: 'SP1YWW3DXQKB1GCQXS4GXGFFWHYM4AJS58P7RG5V6, amount: u100000, memo: none} {to: 'SP3W6NFEB6KADDM8MHQPJ8R9AHCTF80NBR7SNP1Z9, amount: u100000, memo: none} {to: 'SP35DJDPDNCYRPMTDW10YCQFA29HWXK2S3W5FKFA7, amount: u100000, memo: none} {to: 'SP2AQVHFBCV2NC0A5Y2GBM5E6HDW1VX0PSB8RPYS0, amount: u100000, memo: none} {to: 'SP13WXDRGXE1GFYGFJZ8AVPDK0B1FDH022NDVC5MS, amount: u100000, memo: none} {to: 'SPK2QQ1YZZG6HF4S47NQW40FRNC0R42GRJWZ9FBK, amount: u100000, memo: none} {to: 'SP1XM1VK1P5Z7TSJ4SM5JX6796Q4P4AJ8QSA90M5R, amount: u100000, memo: none} {to: 'SP3XW69EJ6HC4F3RDR8XP9X950EAZVK0ZX5A0BXPB, amount: u100000, memo: none} {to: 'SP87YTXRJ6KWCQ91Y8YTHEQMCHSWGCD63GGFPT7K, amount: u100000, memo: none} {to: 'SP1152CHQ700JWASKE28REM344BDZQNYFGTY7H0DW, amount: u100000, memo: none} {to: 'SP24P2YYD2RKDC8XHZXHHS3MY0E5HYPGXSGRCKJ6B, amount: u100000, memo: none} {to: 'SP3PFV3WX5BYY6K7AS4CHSQDZ623WFRS3G0W5EM6W, amount: u100000, memo: none} {to: 'SP23AAYH9C4X1T0EA59J43CZKAF1DCB1PTDKRAJX, amount: u100000, memo: none} {to: 'SPDTJ9M5M8RVWRD40HJ1Z5J85NZMFBZD308CM45X, amount: u100000, memo: none} {to: 'SPSXZBJWC05C2ZMX4JB7BK53CVBVZV5STQXCBWH7, amount: u100000, memo: none} {to: 'SP2RHP1VK32Q92KBJ3ZD091XSKN95TKJKW72F8ASE, amount: u100000, memo: none} {to: 'SP0406NC9GD6QWS2F7K1DMQ03MS2B8TDH1CZ59J2, amount: u100000, memo: none} {to: 'SP21SYRE3YWXN0YTXWNB9JC65EWVSWDR69RR5J3Z8, amount: u100000, memo: none} {to: 'SP24P0VF1XNB2E0CGD9T54BB9XA4B9Q6K426ECT3R, amount: u100000, memo: none} {to: 'SPP8V2JXXSFRE9SV0B2KXAN891PSRQWMS93KGP2Y, amount: u100000, memo: none} {to: 'SP3VEB2RA8SJA9AB6K5C9S6BJWGBPC0PXZMNG7TEQ, amount: u100000, memo: none} {to: 'SPFDCBWGCVT6BRWHFA8BP5699DZB7SYV0RF9N2SS, amount: u100000, memo: none} {to: 'SP144769XBABSXQY0J0CR1V0BF0HDA4RVY2B26CV4, amount: u100000, memo: none} {to: 'SP594KRAKXE74HY7D1S6TKPD30NZYP2C6KHR3RXT, amount: u100000, memo: none} {to: 'SP3JBZYA4KHZ4BP2E94Z979Q79KW75EW9ADJ6ANFV, amount: u100000, memo: none} {to: 'SP3ZTW0J4FZHDVVH8RV3FCYW535FRQN495GV904EQ, amount: u100000, memo: none} {to: 'SP2KZ24AM4X9HGTG8314MS4VSY1CVAFH0G1KBZZ1D, amount: u100000, memo: none} {to: 'SPE2X9X6VRYX2872PWQV7RGTXM3YH9B80TQ8NZBJ, amount: u100000, memo: none} {to: 'SP2SNQHT55ZM0TBF7DD0TA39XM652QZ97E3CXN2SJ, amount: u100000, memo: none} {to: 'SP1G0EGYPGT7RQN2JJEQVPP1QRHZA5Y5HHY2CQX0F, amount: u100000, memo: none} {to: 'SP1F6E00YQK63FFQKJ7MDSYW2PGD05Z4VCYXEMV5M, amount: u100000, memo: none} {to: 'SP3FEYH9GEVJ7X16AJKARQFQ298DDMCEQ0FA15YRV, amount: u100000, memo: none} {to: 'SP3YFDDQ23DV353XGSN3A7MNVN0C2VZRWZR1NST93, amount: u100000, memo: none} {to: 'SP1WB26C74Q010P0Q3ZTZTAT1YAQTBV1PFNMZ69D4, amount: u100000, memo: none} {to: 'SP9BT37C7T1ZCPERC17AJ47A64N7VCBZJXTKSK0M, amount: u100000, memo: none} {to: 'SP2M64A49FD47RC7WJZNH9ZZPN6R72BQ2S4ZDV9MR, amount: u100000, memo: none} {to: 'SP1KNRNZET8ZC5Q9P6F1FFW8YQH45CKMNY132B36S, amount: u100000, memo: none} {to: 'SP301D8E6XYWA05DX8F8HSD73NT2XB376R47G0STV, amount: u100000, memo: none} {to: 'SP1QFNWW4G31MMDM7315VQVWK7ENTGJD3V3SRYTRQ, amount: u100000, memo: none} {to: 'SP2RAHGK109E7KYFSY26MXNFHP9220BZ3ESSZH9E, amount: u100000, memo: none} {to: 'SP3MTMK7R8GQKYHN3XZGBFS81NSDD1YAZW305H2CS, amount: u100000, memo: none} {to: 'SP2XMCX1AST1PM21CWDHW5YBSSKXG0TXAB45JCS6, amount: u100000, memo: none} {to: 'SPS1V0TA8RC4BNY60HEHAGN77NP5YCCTKFNKZ3C0, amount: u100000, memo: none} {to: 'SP279WY2EJTR9FB8PH02110D5YTCJ3WM6Q6FRXSWN, amount: u100000, memo: none} {to: 'SP3TAQCT0KQ1TC9E6XJ33J26XPG1DGSPS61M61H9G, amount: u100000, memo: none} {to: 'SP143S7QJWE14EYGVTC99HGYEMG70YVG1RT81KA1A, amount: u100000, memo: none} {to: 'SP1EPFBVNVXFARAJFMNJNREBAGNC04X7Y6FNBZ13S, amount: u100000, memo: none} {to: 'SP11ECZ9ZYQQ9NYAGSP0H3H4QYWKQF1XGJB17JNA7, amount: u100000, memo: none} {to: 'SP3RY185H0R8TNX4PGRYFZ07AV001N23N1FJX9MEE, amount: u100000, memo: none} {to: 'SP3SDZ9WKEDX6WT8BKMY80SM37VD6QKGQH9GP5CD, amount: u100000, memo: none} {to: 'SP3MTR701Y14SM1E5QJW5Y44C8B5VHSKT1VA917NS, amount: u100000, memo: none} {to: 'SP2HS1G06D79W336VVZM38DSVTXA8V4YB1NPF76QN, amount: u100000, memo: none} {to: 'SPFBQ9HB0FH3VXS75RFHRWZQ5M9DY2FCT174Y9GN, amount: u100000, memo: none} {to: 'SP3EJCRT5V10W6JBS8D76J5PXCTF0SD250N1Z1HRS, amount: u100000, memo: none} {to: 'SP2Z1XHZ5YXPMMXE6ZRMDC7AE85NMW7DC3BJ01V2X, amount: u100000, memo: none} {to: 'SP3QF8RJ3CE59RBAHC96YS6DRSVKYADCF2730P023, amount: u100000, memo: none} {to: 'SP1K1B8243JPQGSGAPT0SDDW01VWF2D6YBC8M1CRH, amount: u100000, memo: none} {to: 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV, amount: u100000, memo: none} {to: 'SPVR9PDHJHGJT59GE10E8QE2433YAZY6Z47EY13P, amount: u100000, memo: none} {to: 'SP1DZ6CVX4TYYNRV39WBPSH18EMA5C6S6TZHBZT75, amount: u100000, memo: none} {to: 'SP12PV7PWGHDY37CF5T38CMGC27T01X25KN4RF3VT, amount: u100000, memo: none} {to: 'SPBNZD0NMBJVRYJZ3SJ4MTRSZ3FEMGGTV2YM5MFV, amount: u100000, memo: none} {to: 'SP2GYXR37WGDP11A2CT9T4HBXDPS8SA6YTHQ8A2NH, amount: u100000, memo: none} {to: 'SP1QW0SDVT6E22HWD2G5JRTM68GD199HERQWMHSE6, amount: u100000, memo: none} {to: 'SP1ZD4FWR418R91DWQGMN2SNWBV5QQV4TYQFWBTQY, amount: u100000, memo: none} {to: 'SP1HQDXGN55G42GWT2TQN0DDQSM41NGF1FGJ5KK9C, amount: u100000, memo: none} {to: 'SP3KDPB1XS8ST0K0P56RQY801KREBMPXD4FBX3RDJ, amount: u100000, memo: none} {to: 'SP3658EQDEKG3RYGVE4H1KC3PAS8MRJCXPJN7CYHC, amount: u100000, memo: none} {to: 'SP3HYMM87H9N4JFRRJ67TYQDCYV17BBB54J0RST0C, amount: u100000, memo: none} {to: 'SP2JWM4MB1SBY2FT3PG5PM0V12NW8Y4FK1XXWBHSF, amount: u100000, memo: none} {to: 'SP3D2W82STFR5DYEGW31FA029S425D05B1J6499ZE, amount: u100000, memo: none} {to: 'SP1DAD610W1MZ02YKDYS0W681ACNZZAQADK6CQ8V1, amount: u100000, memo: none} {to: 'SP2H9Z97J0B3159H45ZFX6TVKS9RT3KVKDPGAHJC5, amount: u100000, memo: none} {to: 'SP329M6CS0S3738Z0T268FXQXBSX0ZD1FZVBZS037, amount: u100000, memo: none} {to: 'SP2DXSMHAEAS5RK9G38XKD80G1N14KFS1C1ARAS50, amount: u100000, memo: none} {to: 'SPXY0VFX761352VTJPAMNYTJYYA82A5DRH0VR57P, amount: u100000, memo: none} {to: 'SP2TPDSTGHXW6JBP2GKHQQ3WYK41AN1Q38AN8BVPP, amount: u100000, memo: none} {to: 'SP23JX6EVN9GK7A4EWWTEJTP6BP75R0SYJX7TV1D9, amount: u100000, memo: none} {to: 'SP3JATJK4G0HVYS7ED03EF1MSQCYDCHZ8RQ5TNJZ1, amount: u100000, memo: none} {to: 'SP2HMNV7HAAWYBYDE3CPQMGZ14V137E78B53KEJV1, amount: u100000, memo: none} {to: 'SP18148N2DV6AHCXKXXWZRNHWASEMHTK024S41HAE, amount: u100000, memo: none} {to: 'SP2RNHHQDTHGHPEVX83291K4AQZVGWEJ7WCQQDA9R, amount: u100000, memo: none} {to: 'SP31CZZ7NJA484QSV739BKF1NH13G4XBCJ1AMM9GW, amount: u100000, memo: none} {to: 'SP3W83KG17KJZZXPDZQDTRQKQRGHNFZN410R9P02E, amount: u100000, memo: none} {to: 'SP2P8RJ42R8MP0AAJASTT7ST6VZ7GHCWR7PET3B21, amount: u100000, memo: none} {to: 'SPBFPD0285PKTCTADGP9GX2JFE12R8ZXSCWRYW39, amount: u100000, memo: none} {to: 'SP1ZCYG0D3HCK2F7SY8VH9ZREB0JWCBSAPFNS8V5Z, amount: u100000, memo: none} {to: 'SP3AJC728JY0Y43E8RT6K4VDWPT265RDMXJ8M0VH0, amount: u100000, memo: none} {to: 'SPN6EFJZRDM7P4FP3CWY3RC8RZ2RD69MQ9DXJBZT, amount: u100000, memo: none} {to: 'SP3T5Y7Q14P34ATGNY6VQMJHDH3D047F413EN9Q56, amount: u100000, memo: none} {to: 'SP33KXWETMY4RN3ZBPQB69H46MRF9TA5971VAQ09Z, amount: u100000, memo: none} {to: 'SP3VE90FRGYA66A6KKGF5W2W6K6CJSEY68M7PW3NP, amount: u100000, memo: none} {to: 'SP1131XRHKJ3DBYY8D4FZ32Z07GWYPT7A3Q7CSV7C, amount: u100000, memo: none} {to: 'SP2WMT25X0XGMARDJF00VSY8BZ3Y1TD81XJYPR974, amount: u100000, memo: none} {to: 'SP2HDF5A0ZD2CG2SEE3NSVE9TCPFJ3Y14BQ8W997Z, amount: u100000, memo: none} {to: 'SP2D8RP8J0EYMZPFTT0SS0YE4HR0JV6CBBAB9508F, amount: u100000, memo: none} {to: 'SP260ZF58NPJZCJGB2K51327RW299BHES24W4ARKE, amount: u100000, memo: none} {to: 'SP2QVKZ2GWP97TW4RNCT8TN65JRJPVAKERHYSS13E, amount: u100000, memo: none} {to: 'SP3RDC4C9B0A2FG8B7DQ9MBTFPYQZNDAVCBME8Q41, amount: u100000, memo: none} {to: 'SP8CHH13JYCS3SZDBG28MH4M5Z2ESEH0QF4GAXQF, amount: u100000, memo: none} {to: 'SP74BB1WD3XG6V7NMK4TW5SFNHTJ5AD4N84CAZMF, amount: u100000, memo: none} {to: 'SP2DAYHJS9HYT3ND88JSFJWVG0X1JS7JXA0NG02EZ, amount: u100000, memo: none} {to: 'SP1MP4A2TZBX935NS93V5QP8ESG8534XARQFQPCMG, amount: u100000, memo: none} {to: 'SP68A2GDYFED1P932H1Z3J2NKP24D8WW486C6QWT, amount: u100000, memo: none} {to: 'SP2KGG7DDH65TGB9RV36233W3ZBEG9CRQ6AQKGRWS, amount: u100000, memo: none} {to: 'SP2J6Y09JMFWWZCT4VJX0BA5W7A9HZP5EX96Y6VZY, amount: u100000, memo: none} {to: 'SP3C5C0KBMRE7A22GCHEC3YTBKYKF4X936K4JCHS3, amount: u100000, memo: none} {to: 'SP2NTZ5ABMMMX1KYEHK3KYK5ZV6FKWV01CXRNYT44, amount: u100000, memo: none} {to: 'SP1PKKPBB3K60S4PD7545H7JK8AH0MZJEV9T4X15K, amount: u100000, memo: none} {to: 'SP1BZXABNDK1KNRADQ2EZFW8Z0V5GZCP6P2NF64QW, amount: u100000, memo: none} {to: 'SPPTGPWRZ1BWZ9J94DKBRQQHK6ABD5H5JW3X1CYN, amount: u100000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)
