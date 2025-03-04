
(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP1KNRNZET8ZC5Q9P6F1FFW8YQH45CKMNY132B36S.ned2gsk-bonding-curve send-many (list {to: 'SP16MCH4BYNNE0N7T24AAS715HHZP29BZARWSDSPY, amount: u23000000000, memo: none} {to: 'SP2M7K3YM8813404G1R7AXV106CPWH0Z5ZA80JVAV, amount: u23000000000, memo: none} {to: 'SPQFACZ5KGYJH3XG8BDWW2VGGRBJ8BPFVEXEVC6M, amount: u23000000000, memo: none} {to: 'SP1S538TKS1HVKKA111X54FCR9DV7YGD069EDTF1F, amount: u23000000000, memo: none} {to: 'SP3QF8RJ3CE59RBAHC96YS6DRSVKYADCF2730P023, amount: u23000000000, memo: none} {to: 'SP7MAP8XJCMRZ9901ETFA3EKVVPJ4X51AWQ2VG4F, amount: u23000000000, memo: none} {to: 'SP000000000000000000002Q6VF78, amount: u23000000000, memo: none} {to: 'SP428G7J1EP0QB0XCQAQ5D36RBS414XSDF8013F0, amount: u23000000000, memo: none} {to: 'SP3SE348DFBQT3PV6YT9B85014W0XAC5CT5Q50FB3, amount: u23000000000, memo: none} {to: 'SP2ZHZRWAGZE2QJKTXYJ2QWKVM3BZ5HC2KC90HN1W, amount: u23000000000, memo: none} {to: 'SP3AA8Q1P0BC9CXGM3WVMFB0JB36BW5WVFVJY0D1D, amount: u23000000000, memo: none} {to: 'SP3SA7P8C1BJM1YTNJF381EMX8B9YNG7NGHQQ89T8, amount: u23000000000, memo: none} {to: 'SP2JWM4MB1SBY2FT3PG5PM0V12NW8Y4FK1XXWBHSF, amount: u23000000000, memo: none} {to: 'SP15TQ8ZC38KT0DBE1Z359KH7R8SX2QWJ0GTDT91X, amount: u23000000000, memo: none} {to: 'SP3W83KG17KJZZXPDZQDTRQKQRGHNFZN410R9P02E, amount: u23000000000, memo: none} {to: 'SP1BNRS2PKZQFXNC20T71QGVWBB3GTGVHF7HRJ1FX, amount: u23000000000, memo: none} {to: 'SP2Q6KRYDH0198FA09DHG8WGH1E96ZR19QNYNB9X1, amount: u23000000000, memo: none} {to: 'SP2MYQF316JWNY0M6MBGRFPZS17GJKRA26ZPB35HM, amount: u23000000000, memo: none} {to: 'SP3E4G6Z83YTZK1KXFVY6NHR805JEJ2GGYAZVZRTV, amount: u23000000000, memo: none} {to: 'SP2YG82P7QQCHE9FK8EKAM9X1QM3FQTH2WA5P4J3V, amount: u23000000000, memo: none} {to: 'SP2ZXDBYT1RSP98ZZXXRDGKX3TMXCCCGERNBD5YMY, amount: u23000000000, memo: none} {to: 'SP15QCM7NJDMDJEMD3H1RDR2PV7JH0B4EMNYT9T69, amount: u23000000000, memo: none} {to: 'SP1HWKF23ZP2Z4S2NKRP14GYXV82EFXVQ92RFFKWN, amount: u23000000000, memo: none} {to: 'SP142N3M2RFDBRMMMPZVPJJJX5AJC3YM82QG64EPX, amount: u23000000000, memo: none} {to: 'SP2HS1G06D79W336VVZM38DSVTXA8V4YB1NPF76QN, amount: u23000000000, memo: none} {to: 'SP3QC9YJKFC172PYK5E316NKPEAWBHF2NSMC875B5, amount: u23000000000, memo: none} {to: 'SP28X9XQWS38676XXYSJDAMW5WMNTWAP82W20G3RN, amount: u23000000000, memo: none} {to: 'SP396ZK7K1RVQJ5NWV50499P1Q4A17C0QH1JXWW6J, amount: u23000000000, memo: none} {to: 'SP3RNDPX6X3MNZMS3NV28AF6TXVFXDXCAJTTX78GG, amount: u23000000000, memo: none} {to: 'SP2CX49B46EZMZC9YY93Y78VS0RZB9WCZ54A4282F, amount: u23000000000, memo: none} {to: 'SP1AQDVJF18XEFVXMWTRAW9TQ0N2DCN0178FKW03R, amount: u23000000000, memo: none} {to: 'SP3VE90FRGYA66A6KKGF5W2W6K6CJSEY68M7PW3NP, amount: u23000000000, memo: none} {to: 'SP1TR4FGX3PF2DN58BMQC3W2ZNDK8X9GK1GG5MRFM, amount: u23000000000, memo: none} {to: 'SP2Q1AZMQDWH3M8DHJHVE1FC261QJ6Z9RC9ET9HGH, amount: u23000000000, memo: none} {to: 'SP5JYSPE3QTN5A0YNGS424V0F3Z1B7X2TSK3SDHE, amount: u23000000000, memo: none} {to: 'SP11F09DT5HFYN7Z5HG15QXW0CMD40T2XJYY0G5AB, amount: u23000000000, memo: none} {to: 'SP1ARC8PTHHY7C9P076ZHH5MM6WDWA0XP2EXKVZJE, amount: u23000000000, memo: none} {to: 'SP1VARKQVV7Y8YJFFQ33P1VXHF1EJ367G7PD2SRNQ, amount: u23000000000, memo: none} {to: 'SP2HDF5A0ZD2CG2SEE3NSVE9TCPFJ3Y14BQ8W997Z, amount: u23000000000, memo: none} {to: 'SP376WP4SRXFGNR88DTH5MS7Y8GXKBYXSERJC3083, amount: u23000000000, memo: none} {to: 'SP21CGMV16KHKMH8M1XWJC5EP6HJ3E53A97NH87PR, amount: u23000000000, memo: none} {to: 'SPH758YK990JD6R13J4TC21DQRP22P9XAAR3ZF5H, amount: u23000000000, memo: none} {to: 'SP16T7EE6W7VTCRG1XY2KMZM89M14M153SCJJ4BF0, amount: u23000000000, memo: none} {to: 'SPGSDWYMSA6FTYPMV542D19FTZ73A7WPYXKF1QWE, amount: u23000000000, memo: none} {to: 'SPEWFN57HKXKFXS9DQ6QT16KTV4RTGW9MDVMXRBJ, amount: u23000000000, memo: none} {to: 'SP3KEAY4YFH2FT2E996G0PE89SWQHBPDQXHH04PTY, amount: u23000000000, memo: none} {to: 'SP2CDF65P3M17JGPQKGD0105Y08F4EPRHHJ2FTB23, amount: u23000000000, memo: none} {to: 'SP3QSCYA62H5WQVA99S30J5PKC60VWH0T7QRRKVH9, amount: u23000000000, memo: none} {to: 'SP11EY3Q9JHMJQG0X8CQYPG4EH143C6W4RQWJ9HXQ, amount: u23000000000, memo: none} {to: 'SP1NP0KJF3RQ003B0E28H0Y5YM50F6QR5ZHF8A3N3, amount: u23000000000, memo: none} {to: 'SPNC2PDJG1SXA8ABKEH583Q46N73PBKJDQ7NN8FY, amount: u23000000000, memo: none} {to: 'SP25P7M4D49R8BS411R4FAKD7WC38GVSQJS13V2RG, amount: u23000000000, memo: none} {to: 'SP3S6APEETSPDAXB0GSXFDZVA9R7PXJRE4JB4X0HB, amount: u23000000000, memo: none} {to: 'SP2RQ0MJ95W7FTGBP321QN8ET2ZB2Y9AXRMX31FA, amount: u23000000000, memo: none} {to: 'SP1YNJN6Z56T05P2JJX846F5H8MEHK672JCWQA8D0, amount: u23000000000, memo: none} {to: 'SP1KMAA7TPZ5AZZ4W67X74MJNFKMN576604CWNBQS, amount: u23000000000, memo: none} {to: 'SP2ADGVXAVANMM0BM6KE8423M0V7GDZ3C03TQAX88, amount: u23000000000, memo: none} {to: 'SP27236RGWXYER6PNRSGG8FGDQRVZ8Q3MFD4M440B, amount: u23000000000, memo: none} {to: 'SP3E8DBPXWV15PR41J863ZVB3GW0CG6KZ7SDKZ43S, amount: u23000000000, memo: none} {to: 'SP1PGCQE6X1G8GGJHPT5CSR27X1BPCZ79W86SNG8, amount: u23000000000, memo: none} {to: 'SPK0AAYVABSPQ7FN3AY7JERZRY5VD74ZJYQ2D5KA, amount: u23000000000, memo: none} {to: 'SP3V9R4TBKQMCRSZNJWM2W9PGKTXBVH12C10AP7HD, amount: u23000000000, memo: none} {to: 'SP2PZYA27E8MRBQHQXE0JQH5CHM9JJNM00YEMC4QJ, amount: u23000000000, memo: none} {to: 'SP3PPP9P4P45A6AW7AF8H0GZMW0YC6G26EAQKTBYA, amount: u23000000000, memo: none} {to: 'SP242WM1RTHV1WNZ763FNJRVMZB6KWJN9W51C58P5, amount: u23000000000, memo: none} {to: 'SP2WQV1YNPZYHF2MNJ4SDXBSCZSQVM86EKFNB5ACW, amount: u23000000000, memo: none} {to: 'SP2T717SNDGETK8RD0BY41E13FHDFDGBAWSXE5ADV, amount: u23000000000, memo: none} {to: 'SP2EQP7X0WCJ70ZMQYGPXAD0S9T76JH1CDZMEMQES, amount: u23000000000, memo: none} {to: 'SP2P8RJ42R8MP0AAJASTT7ST6VZ7GHCWR7PET3B21, amount: u23000000000, memo: none} {to: 'SPF55MFSRYBNADJT6HVNVA4JBMDGG8Y6R55Q0JA3, amount: u23000000000, memo: none} {to: 'SP1FEWH3946B7BYS9W1CVGSPC9FDKK5K32ZTBSVBB, amount: u23000000000, memo: none} {to: 'SPH9N1BYSFG8GWXSPBKMN1C9TNXTD8H80ZF8230S, amount: u23000000000, memo: none} {to: 'SP27C4GGZDY5109EFXVXWBFCZTHEADK5B1HSMB5ZW, amount: u23000000000, memo: none} {to: 'SP74BB1WD3XG6V7NMK4TW5SFNHTJ5AD4N84CAZMF, amount: u23000000000, memo: none} {to: 'SPTN0TBC4JX9N7PYAD4B1S42H671YTMH3Y589RK5, amount: u23000000000, memo: none} {to: 'SP3Y0BBCCCBFAMYCYN3F35CX9MH1J2GATP53JX3FA, amount: u23000000000, memo: none} {to: 'SP3Z3RAFPPGZ0XHQBZSGN86JJK3C469BXV2ZHTXYX, amount: u23000000000, memo: none} {to: 'SP3Y9VVS0YMZA2T9KFS7F86EYKF9MV8YF34PZ0D5V, amount: u23000000000, memo: none} {to: 'SP17CPQXS22FCRY16DS2BK1FS9F4V5331HQFF4P2H, amount: u23000000000, memo: none} {to: 'SP26G3471K0XRA00Y7H9QQ4AW4SGJMS4BRH6EWTF6, amount: u23000000000, memo: none} {to: 'SP3821RJXHHW3YVCHJN43XWPZJNNMPFPJEQDZJMZA, amount: u23000000000, memo: none} {to: 'SP2A0VW071VE5QXZ9699FK29F0XXQ0B8AQ5BSC431, amount: u23000000000, memo: none} {to: 'SP197N0P5B02AK4RAKFH6ZWK2C4YSSVNH0GT2J21R, amount: u23000000000, memo: none} {to: 'SP12H47A1JH7B3XN7GWZ0X6DZ385N6K5QNC8K1A2T, amount: u23000000000, memo: none} {to: 'SPNSVRTX44DWCGQYX7QZ8Y8Q0BNM2KR8TXRC0VQQ, amount: u23000000000, memo: none} {to: 'SP84DM8Y7CGRVQN9EB1VMBHDQBWV420DQHCKEGZ6, amount: u23000000000, memo: none} {to: 'SP3K5980VVGT4BVE9NX73XTTHARDPJ6FEAFQA3R8A, amount: u23000000000, memo: none} {to: 'SP4S3E8DW862FQG2ANAMPPE4WBK75EPJNFJ75PYR, amount: u23000000000, memo: none} {to: 'SPNAKZBVNTRDT1922N00Y86PK9E4WCPBCJBTD5SV, amount: u23000000000, memo: none} {to: 'SP3ENPCX78SJ2DH35BANEDR51VX1AHKRY7W5MGMA, amount: u23000000000, memo: none} {to: 'SP17PZJ9A8W29FGM8BRY96M0XDXE6PRZX9DJHB926, amount: u23000000000, memo: none} {to: 'SP3Z0BXQ79GFK8CMVVA61WP0SGDM33J5CPGTH9003, amount: u23000000000, memo: none} {to: 'SPNYE5S6EQPAQCWEAETQ0B1V4AW4ETCE0WH2VJAT, amount: u23000000000, memo: none} {to: 'SP2ME6AEPM9Q7RYEHQGKX67BM2T64EY1S90KB8QBF, amount: u23000000000, memo: none} {to: 'SP17A1AM4TNYFPAZ75Z84X3D6R2F6DTJBDJ6B0YF, amount: u23000000000, memo: none} {to: 'SP2FA1H3K9FMY2CQ80WWT2JYMHZ5Z2B810AT41APW, amount: u23000000000, memo: none} {to: 'SP3QMM82JC83Y9N5TSBV7K0CNQQJ47XVQSSC1AHX2, amount: u23000000000, memo: none} {to: 'SP28A8PAYDMD227X7QC4MYN2ASS0DXD9WM1Y5KCR3, amount: u23000000000, memo: none} {to: 'SP2BN9JN4WEG02QYVX5Y21VMB2JWV3W0KNHPH9R4P, amount: u23000000000, memo: none} {to: 'SP1MAA0KFBA6N9FTPRBW81K4QYH37XMFB5EG3V6A7, amount: u23000000000, memo: none} {to: 'SP2PHGTC4DQYVX32JHFZT7WJED070MDXTR5JY3F74, amount: u23000000000, memo: none} {to: 'SP1WZGW4VFT02TTH076HFV2CWXG6WANHTH2JFKC4M, amount: u23000000000, memo: none} {to: 'SPTBAXKRKT7EXTZ6QRZFG1145M0BZ0TTX3HJZTFW, amount: u23000000000, memo: none} {to: 'SP33NVNZHT60Q0RW6AM5F0RZDBTR4YZ6GW71JZG91, amount: u23000000000, memo: none} {to: 'SP1ZX1XM081FH279MP66FKCPFQQM7XXEATBF6JBK4, amount: u23000000000, memo: none} {to: 'SP18RY5QKTG8XCSXTQTZJYTXZ1BFE7J9WXJ2AM13H, amount: u23000000000, memo: none} {to: 'SP531F78HBZ6BEH4M4795YB9BRFKA9WYHC1KCWKB, amount: u23000000000, memo: none} {to: 'SPFPA79NV316NDZVEXEZV2ZY51JMMTN1W6R3SV1P, amount: u23000000000, memo: none} {to: 'SP2D2CR6TMFJS6FSFAHFHGAYPQP1VJYDNVHT3PB0A, amount: u23000000000, memo: none} {to: 'SP3JFEKTFHVC3B9RRQ46FNC8MFRZPHVYYTFWYRX6W, amount: u23000000000, memo: none} {to: 'SP3K4QDH3PMK195QTBS9Q5GVW3MNEAY2TBCCQEVEZ, amount: u23000000000, memo: none} {to: 'SP3WH8ZBFA8HSBG71CBQ40TCXH7BS8ZQ2237W4VGN, amount: u23000000000, memo: none} {to: 'SP27V65698KCKGJ899RXT2YX35S04HZRVZAG0CVXH, amount: u23000000000, memo: none} {to: 'SP3NG7TEEQAPM5KBYTBY94WBX7JZEJ323T7JVCK7A, amount: u23000000000, memo: none} {to: 'SP1QP5D1BEV26P0RYQVMFE3VQT4QJ1X8MESS9253B, amount: u23000000000, memo: none} {to: 'SP19P8S6GZ180FYZS2E21G8K7YSCKWVSNKN0AJEVT, amount: u23000000000, memo: none} {to: 'SP2691CFAMWN4AWKX137RQHPZF0N5CZNK3M0K10CE, amount: u23000000000, memo: none} {to: 'SP38AZCDFW8JH00FV4XP31D8M1RZFVM3AZF4QAHY7, amount: u23000000000, memo: none} {to: 'SP36MS94G7W800YAXVS6TMY0E733EV5X38XXPME95, amount: u23000000000, memo: none} {to: 'SP1Q34DK4X5K6SZ08TB363SVFMEE7N2JW8SB3Y6YS, amount: u23000000000, memo: none} {to: 'SPXM6GQQRYED3JCFP4PTQXVWWXCCAT9NTJJCH62W, amount: u23000000000, memo: none} {to: 'SP3XRZNVHS47A4DT9WAZ32C0MS3GBXNY1S1X9BFVK, amount: u23000000000, memo: none} {to: 'SP1G8DV2JF0344BB2NVJ4W72V53ZX3M9ZAV2EFZB3, amount: u23000000000, memo: none} {to: 'SP2NZ2261GGWQQ2EBTDZXWPKG1KBH027PK2QHZ0GM, amount: u23000000000, memo: none} {to: 'SP2QJYB2HDSQYVSWQRAF60B541AEBR6YFRJXH28AV, amount: u23000000000, memo: none} {to: 'SPTGQJPEZKS9S5SWQBQJRE6P5CKGSGBY1EM1E40, amount: u23000000000, memo: none} {to: 'SP36P3B159T3KFD8KM63HQXR3G2TW6AA1114Z8ZVJ, amount: u23000000000, memo: none} {to: 'SP3NRAQW0DXJ9TRJXDETBZNNC59AC8MCC3CABZ468, amount: u23000000000, memo: none} {to: 'SP1E4NAGDG5C42694ZZNQJDK7VJ41CVCYV1W1W148, amount: u23000000000, memo: none} {to: 'SP1RJXFRVMG6DKE6ZMPZ2E7WA6CS07A84971JYNMC, amount: u23000000000, memo: none} {to: 'SP1HZVREQHK75BT2D3QTVQX0D1WG2C0SB6BPMQJMZ, amount: u23000000000, memo: none} {to: 'SPGYC88E6PS8TYJME3DQRSVTNA5Q91Z7BXGX5JR1, amount: u23000000000, memo: none} {to: 'SP295GEER1Y3S70R79A9YH6C3WPRY6X4MDWWD4ZEF, amount: u23000000000, memo: none} {to: 'SP3G68FYWAFENGP6YPTD5NHX3E28Y4KM8GV9VJSXY, amount: u23000000000, memo: none} {to: 'SP1R03HBR35YZA160QC7YTBMVNZ73HZ543VGGE3NX, amount: u23000000000, memo: none} {to: 'SP1WKQV77RVX2E7AY01N7ZV10YS9A48KAND1CVQAM, amount: u23000000000, memo: none} {to: 'SP16EP4SKXWK6X3V69RJBQA0DA29V7FA7M3EZEWRE, amount: u23000000000, memo: none} {to: 'SP3YS5TFY5N93S0SWRGKY6GP4JWHP4CEBVZ01C3AH, amount: u23000000000, memo: none} {to: 'SPB1DDFETYEYE95V53MH9NS3YSNBM6HAKJY2RXWP, amount: u23000000000, memo: none} {to: 'SP3V7QT3EFGVXZ5SJ7H17TXV5GGWJGQ6HJKZ6BGY2, amount: u23000000000, memo: none} {to: 'SP29RT33FYJRARYVYC9Y8DRP5545JFBQR1RG3R8MP, amount: u23000000000, memo: none} {to: 'SP9A3803B76B1WFN76HTS9TTMXFNX4WP464RJVVX, amount: u23000000000, memo: none} {to: 'SP5Z2HY98F0B9WMYG5WDWV2KF1E1TBG50CSSN0SN, amount: u23000000000, memo: none} {to: 'SP16K3CTZVBG1AVMY37T69ME6RHTG46T7EXEZBMQW, amount: u23000000000, memo: none} {to: 'SP39F40QZAGV9RPFXRZH881CKRX9AFHNTKMBYB0E0, amount: u23000000000, memo: none} {to: 'SP2SFK2E3KV4ZT83QF1HM7R52CV0TBY47N500AK0E, amount: u23000000000, memo: none} {to: 'SP1M8XKXE8ZFB0T5AT7NYNVXY9V5JQE4GTYGNNANZ, amount: u23000000000, memo: none} {to: 'SP3WQANB6ZACY8PKJMANAX0KZYFWFPRQ4RBPXXTF3, amount: u23000000000, memo: none} {to: 'SP86YHARP3KDP4ESSYWS9Q7F3KCWMMYVP2KRWNGH, amount: u23000000000, memo: none} {to: 'SP1ZD89WMEBQN4V626T8VYT0X4T9PNRREVRJHPF19, amount: u23000000000, memo: none} {to: 'SP3F8YP43FXF1647BBEZ81H74BCT2PVD2T65N2TQ8, amount: u23000000000, memo: none} {to: 'SP3R36V9M88WBSPZ27M6CE429C5T9P4JR6V02XYVR, amount: u23000000000, memo: none} {to: 'SP37443V0QAFK82NMPCTP01KZW7BG768YYPNKANDE, amount: u23000000000, memo: none} {to: 'SP1SCQE49NNX0A27YRJ6FB0EHFT5AZWF18SBQ4ZE, amount: u23000000000, memo: none} {to: 'SP33YD8WBKT0AAH62RAA0BMK0F8SXWV88PTRK2Z64, amount: u23000000000, memo: none} {to: 'SP3591CNCDQGG1TQ9PVWWNEHAFCFD3N23ZVY21V0R, amount: u23000000000, memo: none} {to: 'SP514P9H9VCJCCD63PKZ2R2BF0QP9V14BYQHPF2J, amount: u23000000000, memo: none} {to: 'SP1A4FXHQ1XJ3K3XAQV3Z6YDJQ0D9ANN6DXNWTTWH, amount: u23000000000, memo: none} {to: 'SP3RH78C6JGY4SGN0K702CN888R6FHPNREZGWGX2F, amount: u23000000000, memo: none} {to: 'SP4HHEGY59ZJ1JXQBDNVPJJ5XT16DE0E5GT5HXJG, amount: u23000000000, memo: none} {to: 'SP36V5KYKDA9BZMNCPKTDZ8FMDG3CZTWY350CG7MW, amount: u23000000000, memo: none} {to: 'SP76JW44NWM7AWPQZQD600RJW2DT2ZG2ME2M6XCV, amount: u23000000000, memo: none} {to: 'SPX9PK5DDTTKMZHH8HZCCDVBFD8BA7V8G98QPP6Y, amount: u23000000000, memo: none} {to: 'SP122G3V933CWESM6E3F75V9VE9YPTGYW52XD44W3, amount: u23000000000, memo: none} {to: 'SPG3BVT1Y0EX7514T51C5ATE9ARWN5GMN7RNY8ZW, amount: u23000000000, memo: none} {to: 'SP3T8XVBX10T72WB2E41ZTS5NCY85WC6YMWR2QA6K, amount: u23000000000, memo: none} {to: 'SPDW3CV0QTBZTZ3H1CPEZE9CFA3HQQXR524DHKN0, amount: u23000000000, memo: none} {to: 'SP2D7E7TG18Q5C4TYYS3W3KPBXPBJD6MGDZ0BX82Y, amount: u23000000000, memo: none} {to: 'SPD0SVHC79KCYNF8HRHPE18FADS693ZX3VWH1G86, amount: u23000000000, memo: none} {to: 'SP3QDMEPRDDB45MCF1F0R6Y1M6NV7TWT8GP03AK6Z, amount: u23000000000, memo: none} {to: 'SPQ3JYB7V13TC2Q2ZDJX4FJBG810AZBZ6VKBBMQX, amount: u23000000000, memo: none} {to: 'SP2ANC8NKYKPWQHDN3VVDC786S3G7W4QR3D6AFKG1, amount: u23000000000, memo: none} {to: 'SP2VCTYBK1M4KNVJGDNTXV9F6Z6BE40A9CV6A4VB0, amount: u23000000000, memo: none} {to: 'SP1EY8FYXG8S0Z6M8TJ9DDW46QHTK8KNMJ1S77GAH, amount: u23000000000, memo: none} {to: 'SP33BCJGB06D983JECWG6SCJ8D3H3S0A89J05EAB9, amount: u23000000000, memo: none} {to: 'SP21TE9J54MYSS3K4HB87W62THPBJEFG1V9H2TW9H, amount: u23000000000, memo: none} {to: 'SP3D0BDWSEJPCFYTA7BNGS500STQV58XEWB886GQ6, amount: u23000000000, memo: none} {to: 'SPA3P35T1W8ECE3Z9ZG7JVA4622W6SSS3BAY6A5X, amount: u23000000000, memo: none} {to: 'SP36PBW21J1A3YR0DN2NDNK2YVN7PTBZ54ZTKY95E, amount: u23000000000, memo: none} {to: 'SP2Z8Q9C1SMZXSGKJ2Z43JMAD0AQWR14EFQRG23DY, amount: u23000000000, memo: none} {to: 'SP12BPNQKTT9SHG6N1BVZTM9A7B4EPAKCS9M08RZ, amount: u23000000000, memo: none} {to: 'SP3BSMY3CV6B5G6M7HJPYDP78D15D6X9R1XWC401K, amount: u23000000000, memo: none} {to: 'SP2TM285Y17BM519WT3W9SK23FEEK4WPFHAZEMT16, amount: u23000000000, memo: none} {to: 'SP2HMKTWGN3RVRRCRD6N1YE97XHC3FVC77X8NXQQC, amount: u23000000000, memo: none} {to: 'SP3W3WTY4RP85Y9PX23MW85HNS3GVHHD2J1HPXPEY, amount: u23000000000, memo: none} {to: 'SP1VC3NN3M8XC6TGHQEGCQ4AN66169Y71EGAD6EAQ, amount: u23000000000, memo: none} {to: 'SPWC45P8JQP1VG9NDNPJ6ZXPVZ4XXGK06GXR5XN3, amount: u23000000000, memo: none} {to: 'SPY4BF5RX1RNEYBQSFN6544A464N0PYTM7CQ94XW, amount: u23000000000, memo: none} {to: 'SP3YG77826QCPRAHZ9X78EHG713HVGE4286J0XZHN, amount: u23000000000, memo: none} {to: 'SP1C9HRDJWXKH5TXQYK7TXMGWMD2NPCJ05D5B8YR5, amount: u23000000000, memo: none} {to: 'SP2E095BHJ353S5EB01BYAEA1RGZVPF4BK0V9207J, amount: u23000000000, memo: none} {to: 'SP27MKAKT3E38QDQZ3732P8W8FZJMEPGX04S2PYDD, amount: u23000000000, memo: none} {to: 'SP34RJE136GXG0VPB6QDJ0GD7BJMP5F88EWV9GT28, amount: u23000000000, memo: none} {to: 'SP31PFBVWDSYD9NDWHYZ1P8770X7M9ZN7F675FSTY, amount: u23000000000, memo: none} {to: 'SP34XFG92G0Q8TK9X766PVE3RNS8NJAA16Z2962K6, amount: u23000000000, memo: none} {to: 'SP3FFEJ2RTQ1KV29B5FWAE80CD8D7AWW9AXKX1Y8G, amount: u23000000000, memo: none} {to: 'SP21PH0PYJFD3F8V726SY8NQDSE4AXCA1PTH8EM01, amount: u23000000000, memo: none} {to: 'SP153VWTPDH243GRD8GBQQJ8H1RERK3X577898NTN, amount: u23000000000, memo: none} {to: 'SP1AZ9N05EA1A62RDE644ES6CXA7H8QF6VXDDSNJ0, amount: u23000000000, memo: none} {to: 'SP33D6FSW19H7X7EYE074J50Y1SQ8YFFSNTWE0XPP, amount: u23000000000, memo: none}))
(contract-call? 'SP1KNRNZET8ZC5Q9P6F1FFW8YQH45CKMNY132B36S.ned2gsk-bonding-curve send-many (list {to: 'SP1NKTNKDEBV0N4CRW8YE125FFXZQZDJWSJV0FVDW, amount: u23000000000, memo: none} {to: 'SP4V9JNN2WHYWD5QZVYFMP82MCBGRFJNXAQY7ZGJ, amount: u23000000000, memo: none} {to: 'SP2427P70S03ZQBPVR1918VXTD19NCRDYTSPA6HNC, amount: u23000000000, memo: none} {to: 'SP36N482SM7EFB79H78GB0XDH9DB7S07Z4N38N7EQ, amount: u23000000000, memo: none} {to: 'SP1EDQ0ATYKAJ7RSGXKWYGY6K5CVN17VRAFBZH6J3, amount: u23000000000, memo: none} {to: 'SP27N0CBBRVBGSG17DK5B27AE4YBJ2GNBBCK94A6A, amount: u23000000000, memo: none} {to: 'SPCXM97J2HEY2WEANNMMPGQ4KRPQ8DRVFDF2JYWV, amount: u23000000000, memo: none} {to: 'SP1TTQZFJ8DGAFQM8FTD9CQ0ZFCC5RXH0Q0X08KQC, amount: u23000000000, memo: none} {to: 'SP223KP6S9R6PCHQ13CQ9RHNWSZ685K4M05N22Y4W, amount: u23000000000, memo: none} {to: 'SPSV8P9A8TR1ZXDRRYJS0F0YSJG0NGSC6V6TTT8X, amount: u23000000000, memo: none} {to: 'SPS7V7SWB9C1YPP8Y99S0FFGC1BG4WCC1PBPJJJY, amount: u23000000000, memo: none} {to: 'SPNKNTCYPKSQZMFZKVK5VP3JDCS1N0F5X352XRQ3, amount: u23000000000, memo: none} {to: 'SP2W8NMM6PADQ52MWVEH4BXQF17SXC3PXD4JAAV1Z, amount: u23000000000, memo: none} {to: 'SP11H2SKP7FGK1H60F7N84BPY56KVB7HF3KE6HW5H, amount: u23000000000, memo: none} {to: 'SP1PJV337M92VPDW42WD5S6337SN7ARGNNJ003WY1, amount: u23000000000, memo: none} {to: 'SP32833HW9XNVWQTQDQ7HWPK30XA64PWBKE6J51VK, amount: u23000000000, memo: none} {to: 'SP3CCQ9V0NX9BRA6RDEVFVKRME921R4AZYCDP3BAS, amount: u23000000000, memo: none} {to: 'SPF6J5FKKWFB07JNM5YM3DNM9GS5G24M5FWWXES1, amount: u23000000000, memo: none} {to: 'SP3VFQR1A0H44ZXM571C7M50S77ENTTMKP3YFYAFG, amount: u23000000000, memo: none} {to: 'SP8JWXM5KKH3FGS80YQ0STXP0CD8N555DCF7Z3TB, amount: u23000000000, memo: none} {to: 'SP3MHTZFYKTZMH9JVKN9DB23CQAFM145ZHBH62P8B, amount: u23000000000, memo: none} {to: 'SP3YCB6NVSY52PAF8CRQG4F12HC5X00PXCPF36DRG, amount: u23000000000, memo: none} {to: 'SP3R8DMT2X2497E2Z52R106B00FBN7GA816KRARKH, amount: u23000000000, memo: none} {to: 'SP2332VQH825N6JJKW9ZS04X83PH9ZXHESDB0AVEE, amount: u23000000000, memo: none} {to: 'SP1KE957MEZNDRGTFVDMVTMBJ8D9KFF2694DADTN, amount: u23000000000, memo: none} {to: 'SP323N24F22504J60X8JWYZSRKPXQD39S031MWW6M, amount: u23000000000, memo: none} {to: 'SP27ZQN75D5T9AC1VF245G66W6XTH0R4DZRXBXEJ3, amount: u23000000000, memo: none} {to: 'SP1JDK3RBFFFKBEXNMZY6SCH976F8HGXA8F52XFNJ, amount: u23000000000, memo: none} {to: 'SP3FKEBY1S8YX12Y6RE6Q6GV5VHNQ2GC35YTZEF7T, amount: u23000000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u2000000))
)
