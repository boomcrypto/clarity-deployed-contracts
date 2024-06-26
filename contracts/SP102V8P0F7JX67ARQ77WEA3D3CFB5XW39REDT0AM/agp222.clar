(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 u100000000)
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .executor-dao set-extensions (list
			{ extension: .amm-pool-v2-01, enabled: true })))
(try! (contract-call? .amm-registry-v2-01 set-blocklist-many (list 		
{ sender: 'SP2AS4QCQ81PJQ5HE3TJ6AJ554QX2YK14MFHT2VRS, blocked: true }
{ sender: 'SP196HNSDZS7CPE3ZZJFGF15SG7YT4GZ38XNR53EB, blocked: true }
{ sender: 'SP27X56V58YZM2BATE66SDX3496RV4CFRS9TAPC9D, blocked: true }
{ sender: 'SPF5VQ99HDCF1TXNB7KBTDTEJHATA01FC2BTE04J, blocked: true }
{ sender: 'SP1JKTQZ8HQTH6VDD9X78H94F06YBE1TZFQ06YDJH, blocked: true }
{ sender: 'SP3TAP8CDKZER14E79Y5W352V81FTGD2BTK5GS64Z, blocked: true }
{ sender: 'SP1H50WKK84CQ6KJNJGW3QW0TPB0ENZ7TV46RZ060, blocked: true }
{ sender: 'SP3GRKGJKE9NFPHH1QQMKSE062D07MSZYJWBM88FV, blocked: true }
{ sender: 'SP126BHRB04MW4XE11B0TM01407ZH17F7DGTSZGDT, blocked: true }
{ sender: 'SP11TRGP2XDRYKYBS3K3D42YBC44K9855CPYQ054H, blocked: true }
{ sender: 'SP127KNCWDSP3XRQTZPM7TJ0XB8ZK036H4DVEJ4Z8, blocked: true }
{ sender: 'SP8C8ZZKVWWYRK452KZTTY84K13TNMTVNCE812WA, blocked: true }
{ sender: 'SP39PBP7TQ5QFQT97NVXBRP9M3GBW81R8FBFDCRFG, blocked: true }
{ sender: 'SP2BZ7FA747KFBDKVKZDNF3CJYGRVW581JKQ4GTFN, blocked: true }
{ sender: 'SP11KBJ8EFP13HZ0QRWFE5Z3JPQE3RC6J20PM1K2M, blocked: true }
{ sender: 'SPTP7D8Z2TCRZKJ0PATYDQ5NMGZYXGTYZB9RMHNP, blocked: true }
{ sender: 'SP1NK5EV2TZ7ATJ70YQJPFCV4BZRS7J98J87MVYC8, blocked: true }
{ sender: 'SM3QMKMYSQ5VFPDQ9RGS8KXKNC96XDHT7PEMK9VP5, blocked: true }
{ sender: 'SP3DMA7B96T511E13B9ACN0S7GW3Y2JPNH8RB59RX, blocked: true }
{ sender: 'SP2YNJ97SYG4C0V30NNDM6YS80JHYK1FH273FF55X, blocked: true }
{ sender: 'SPPPNSVTFDSXBFSYPN685T8NBCRDCKH3XX5A5JM8, blocked: true }
{ sender: 'SP04ZW97VV5DG52J9XG7KTVGBQNRQAZJ43MA0JSF, blocked: true }
{ sender: 'SP32SWF1W84JQYSWCTAWSZ3MQ61Z71B9WF054AJES, blocked: true }
{ sender: 'SPY0ESYK6TR8R92JZAX52Q0X1YNEWD21JNDCF5Q, blocked: true }
{ sender: 'SP37M3VDMVPSZ3AVZEGG0GTP4H5DN9SBJN226J6H5, blocked: true }
{ sender: 'SPA03A9XFP629VS720SWEHGH3YAB7ZFSYEQMZMQE, blocked: true }
{ sender: 'SP3SXZ2T5FNXY9XBNANCRMNDDAESHCNX5G75BP60A, blocked: true }
{ sender: 'SP3RSCHXEJA93BY0H8QQ76KGRCGG1718HMD9EEEQQ, blocked: true }
{ sender: 'SP1CEPXCY1JW4N3A9PGD2Z9XZMG717KFWJZJ8ZE5S, blocked: true }
{ sender: 'SP2N47G7MDQ850VQ58W9CH5KV5FD6HHWGAJXXD2YW, blocked: true }
{ sender: 'SP147GH3EBM2BF9FBDXK7PDCM46AFS53V7NSP9RSN, blocked: true }
{ sender: 'SP3HJFRDRPPTHFF4YHM6PW8GTF5V7DMAVR28NW5CB, blocked: true }
{ sender: 'SPCQR68QXPBB0MNCV4HXB2BQX6ASM55A9ZT3KRSB, blocked: true }
{ sender: 'SPTT6NM51BTFZ3MR7GT3Q3YDQ8GWGFYVPFVZZB71, blocked: true }
{ sender: 'SP2WJSJ5Z3Z5Q9MJCWXNCYWN365TJR7SB8JFTE1DX, blocked: true }
{ sender: 'SP2VGGEJTE2EE72BMZ3N6ZMP2CQ11AKCKVZJVW061, blocked: true }
{ sender: 'SP3V3ZSP3CH988FJYQN3VAK5DJJ672S94P5QENF5C, blocked: true }
{ sender: 'SPNJ4TV5X69K5S1EXQ36A1AS1M3NJFBWT6P042FW, blocked: true }
{ sender: 'SP3JF564BPZ4XYWGX2FAH5CD8S92G0VY40433MC7J, blocked: true }
{ sender: 'SP148WN9YHKKMJNM4QPK10EWQ2T0XA9FCP8XBPZTC, blocked: true }
{ sender: 'SPW9CSNTAFRXXC6CJW5GJG5X71TB01H7M519H000, blocked: true }
{ sender: 'SP94NW542MQHMJK8F3YK9A84QBAF397PFJKTHTGN, blocked: true }
{ sender: 'SP24ZPK8JHMS7P9GS2SAB733FNS4SDDFZ90Z0GFYS, blocked: true }
{ sender: 'SP2RR6JV6AP3XQWXTA9FQ4N018RTF55DQR8JXDXQ4, blocked: true }
{ sender: 'SPEWZXCBGN4HWMC0R7395N8ZT3BK6RGP9WSRP217, blocked: true }
{ sender: 'SP2W240C2XHVHCMFVHE8S221JQYT31V72PJ5CEH5E, blocked: true }
{ sender: 'SP2JSN0KAVAMBGMK5G8377W8JF1JJXMP1R5WWY3JJ, blocked: true }
{ sender: 'SP3GPWMBGY4M8F240R29ARM487PC1BN83MCPQP4PE, blocked: true }
{ sender: 'SPFNJ27RY3C7VHX6KXD2W44JSF6DCQ823T54PED9, blocked: true }
{ sender: 'SP3VPQZ676M4R57V65EFEYVCNH0DH4D1QE3KGPQ89, blocked: true }
{ sender: 'SPEDPV735EQQXHYWP44V3PS2T5Z50BCSN4A2YVH2, blocked: true }
{ sender: 'SP1WBVCMC6R6034QTT8RXZKHBQ4PKMZJN0SZP525A, blocked: true }
{ sender: 'SP249NX8PZJCPAEENGY2VF788Z7BMEDZFE26MTR3W, blocked: true }
{ sender: 'SP2F7PS5FW14NG62F2BKCF7W019SGFP82BN6H9C5S, blocked: true }
{ sender: 'SPFVVJQMSB2B7NGGGK31Z1GRKDCRN93H1CQRB4RA, blocked: true }
{ sender: 'SP3V5G0RJCKY611VV146QZJ654JCNK7WBFVR6KNC0, blocked: true }
{ sender: 'SP1Y07H708YMNMQNAZ159HXK6DGNC9JJ2NWF4A49R, blocked: true }
{ sender: 'SP4NTJR33X9YTVWM0FFD0QQYG7XTMH89KWZ28DAZ, blocked: true }
{ sender: 'SP3X41H2Q16QPT9Y27ASPP72CNSSVC5FEMS8AHFA2, blocked: true }
{ sender: 'SP1TR3VFK1FG3R1ZWZ3JCFBMX0HZGSC62N5SZZPGH, blocked: true }
{ sender: 'SP2S5X00CKAB6079NGSC3KFPDKKFZDD87QPR8W66C, blocked: true }
{ sender: 'SP3BQ1SZ3Y6GGXZD9XFKMXZ0YVQ3F514TJ627NYAR, blocked: true }
{ sender: 'SP3Q60B11DG7EG492DX6Q515CDY5FE1926RB6JB9Z, blocked: true }
{ sender: 'SP1QBFTYEB36H581B69JS2XP16T6TVFB5K4H26D3E, blocked: true }
{ sender: 'SP2FYD8Q6CBCNGS30RDTJD202TJZRADD5SJWMT9JV, blocked: true }
{ sender: 'SP2PHSN9JCM51VN29MK2NM7FWNJ849082EGKT3QMX, blocked: true }
{ sender: 'SPCNEBMJC9G6319526TBR93DYG7YFGCEEN1BNBB7, blocked: true }
{ sender: 'SPQDRR1V5HWTTSSC34XBCG9W9P1BBP0YXCW01E1Q, blocked: true }
{ sender: 'SP367NX3W8Q7GAY758ER57G3DRD1ZN4P3SW765171, blocked: true }
{ sender: 'SP2PJQ9RB3XXMK04KNAK9QV0MHARZ1PZCFX5EM7DT, blocked: true }
{ sender: 'SP3J2G4RW0ARYXQ6C0J4CYM9J33KTSGEY5W73THC3, blocked: true }
{ sender: 'SP2M8QXJJ2RKXM4ZM0KXH2DBV53HX5XZWZPJD9KNW, blocked: true }
{ sender: 'SP4X9W7P0Y063S6VZ879XW97VCG11T8ZTEDWFS1J, blocked: true }
{ sender: 'SP152PGWA3RMQFM6EBRNE0WN0GRR97Q8MH72M74QE, blocked: true }
{ sender: 'SP7KT3421A0EBGTENAQ15HQB9TPHCF9J975CARQD, blocked: true }
{ sender: 'SP12630RBBX11XRHW3AHVJW5X0Y544AZSZHAYDB71, blocked: true }
{ sender: 'SP11QYGF0HA4JPQZ2FFNHGWGJ1FSD5DN9TJ45TWEF, blocked: true }
{ sender: 'SP118B9TBB45PMT96J3M6S86FF1F2CT4VGNQ5MFH9, blocked: true }
{ sender: 'SP11TVW2VTXVGD61NC0W12TTPH3Q1HR56BFW8NENJ, blocked: true }
{ sender: 'SPVF9Y3VB8FTQRQS615E4M7ENYTZ9R0E2DEP7BHP, blocked: true }
{ sender: 'SP149R6H2CTTSSQCAGR9QZGK7TCS180ZGRARDPFMK, blocked: true }
{ sender: 'SP2WWVCKQEFC3B269KNCS4KASK0GZJ3DC0B6BHM1A, blocked: true }
{ sender: 'SP26RBTJTMX7NJRM72ZT6HBCA56ACKC7QP6RQYAXY, blocked: true }
{ sender: 'SP3X56D96AA7QD6Y112WN9D91692SKRY8AY7PJYA5, blocked: true }
{ sender: 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9, blocked: true }
{ sender: 'SP3G6YBZH4NDBKQ6WXXXBM4WP5MST99DD5NHNQWRY, blocked: true }
{ sender: 'SP125ZXAFYQM1G6VADFMQ0F920HE2C8JESQ4S4RJK, blocked: true }
{ sender: 'SP16PJ76ZQPPJP16DAM4W5J8PSPNSEV1E4CGWNPVG, blocked: true }
{ sender: 'SP385T0FSV9Z2A991CMP1PWH885NHWM85QYY7QPBT, blocked: true }		
)))
		(ok true)
	)
)