(define-private (airdrop (id uint) (recipient principal))
    (begin
        (try! (contract-call? 'SP3J9CZ0HNRZX7S5YBAFPT3SJ4KP1PBSRVP3TQAT7.leo-balls claim))
        (try! (contract-call? 'SP3J9CZ0HNRZX7S5YBAFPT3SJ4KP1PBSRVP3TQAT7.leo-balls transfer id tx-sender recipient))
        (ok true)
    )
)

(airdrop u2 'SPP3VT59MKN6T7PZSCY9GY38S68PVKYH32AB0WJ4)
(airdrop u3 'SP1AT73PR9Q1FMV8D059X4KW2BPTJ576GFW265T00)
(airdrop u4 'SP1AMMVB28GBE80ZE578QKNTDNEKNK7089N031YHX)
(airdrop u5 'SP26VT4TN6P1DCQQANDGZTXTA7EG8SXVM1709G47D)
(airdrop u6 'SP3XE0S2KC9NJ6PA09B1N2CR828BBWHS4C9RNCQRQ)
(airdrop u7 'SP2QG30SY1SNBNYBAFS5JTGVRKZXZW4MMVPP05M03)
(airdrop u8 'SP2V0HT46H3VP1B4NV211ZV4S9M5NZEEPP77Y8SG8)
(airdrop u9 'SP25D26KNR5N1PPFPN3DC02H07VVJ04CE5WCH9KH6)
(airdrop u10 'SP3KZ0E3QQQMK09FTP1Q352T1246RN25WRQ4T78WM)
(airdrop u11 'SP1RJR4YQ10F0XNXPRHYHCS95T03PXQSW9MNE4S2P)
(airdrop u12 'SP9NW512ZDCSVA63MGXETXTF8H8KXZYS51P4K3JY)
(airdrop u13 'SPSHZXHVZVS5T3CJ9K8H52MKM7CMY9KQ0MC06MFP)
(airdrop u14 'SP13W72DM2YDKQFHNN2NB8BD4QEH62RQCFJVW7473)
(airdrop u15 'SP26XN8V1XWNGSWF65MG5JEK14VF4J4EXTY9P6R6V)
(airdrop u16 'SP1AV5B8888S5JM9WTBYDJKN4YQKJEP3BYFK0TF98)
(airdrop u17 'SP1SX394S9S920N5PAG6A6MXBG0FA42755A8E01FB)
(airdrop u18 'SPCD0ZWMQ75ZJ152PB0C2Q1S69P0GDFYBAS3Q315)
(airdrop u19 'SP2HX4PSJKTTR6J49WVNEEDY8VJVXWD5XBSZE49EM)
(airdrop u20 'SPJRA593NTXANNPYRSBMWSRGNJ9MZDCQFWH7V204)
(airdrop u21 'SP2KS49Q2VB48ZDN6ETQR9C4S08XFA48F1Q850YZB)
(airdrop u22 'SPD5604VQFWSKMNZKP2G9JPDP0SR55RJDJMMQB1K)
(airdrop u23 'SPP61SWKZEYNPNFV5NCEANJV5EJP0SD5QQGHD6N3)
(airdrop u24 'SP1B18PZZN9Q58KQG2K9S2GMTEF0HXC7FYTAKX856)
(airdrop u25 'SP12QNPX3WR8KZ0379ZHVHGYYP1BZEBQ0678Z8XQZ)
(airdrop u26 'SP2NJWPWSDT3G3D1X89G7NNS18WGK2N8YJF0Z7S9P)
(airdrop u27 'SP2D80XZYYTASWPZ9VKP0DBCRAKHN2HDC3TM1YDRC)
(airdrop u28 'SP20TMBT6GN4ADGRPV79FABKQEFJEZAKN3ACA3WEM)
(airdrop u29 'SP31HT07DE3NA4TFGKEMEFYJJAX8BNGGZ6RWVASSM)
(airdrop u30 'SP1RSVW41BGZ598C3VFCH2P4CCHEMFAFYXCKFC5FK)
(airdrop u31 'SPAS2FHBFJP7ZWTKQK0MB2RZMJ60PSMT1BC5QNM3)
(airdrop u32 'SP2S8K971HED06QPQ8RNQ965CZDFMDKDGDVR66N5X)
(airdrop u33 'SP3NPC1KK23ZF26FQHK5M1CQDQZZYPG91PEEDP8NP)
(airdrop u34 'SP1NNXXF0F9948E82BXSZK0XB05ST7A35E96JBJVR)
(airdrop u35 'SP1E2QNJFCDD7PTRV9331B4590Y5E17AWRXKX5HP5)
(airdrop u36 'SP380ZB9FHFEQJ69P23EHFYEVWM47VCZYJCH95RK4)
(airdrop u37 'SP15XKZXB5GJ5MTN3CP54TBZ9ZAMJ3RK4RXN7MTXC)
(airdrop u38 'SP2Q5ZN0TEJXVY2TQ3PNRC4CHQBPFC396XVVMH4Y4)
(airdrop u39 'SPF8QC7QYQEH50CBQJGY3JENAGD54NS5FBW8GFCG)
(airdrop u40 'SPH8R2T8SNV09VB677FMCV99HMZ12JK892JKMTAX)
(airdrop u41 'SP21WVXN929S5VSJZMD9HNTKXYJYPTMNFK606GZ9Q)
(airdrop u42 'SP55HTW5RT9AXRQTEYRKAXPVDTKJYE3SCC62BHNH)
(airdrop u43 'SPSTE5R54386QDCDNJJWH2EXQFST44QYZW3RPMD3)
(airdrop u44 'SP343CTXVZD3N9PWZC3786FFD5DJ842C5A7XCAYHE)
(airdrop u45 'SP1FSWGVRVMHVGAV4Q3GP57VGXGZSXFJJMSZCG5JF)
(airdrop u46 'SPE24SASN0RT8KCNBV9JBCWEAQBT6YDMD9AA8RWM)
(airdrop u47 'SP3G74N2RR2EV7JJ2D4BH76SF2MFVVZSK0DCD94AY)
(airdrop u48 'SP1728RNYVGNGX7JMEP8YWY9A77WKEAJR0FYPTJ5G)
(airdrop u49 'SP32ZWKMXDMQGZ9WFHWM7C6BNGP9MS1VPG7HQ6G8K)
(airdrop u50 'SP3SF0PSD7KYVJQPKKRBYJFF7NENGFHZSBVHM3B27)
(airdrop u51 'SP199QY1M4KZSR6892X2S6V1PT9KB6WPCBXTH8PEP)
(airdrop u52 'SP14T22XY7S60GSK9ZJVGARK3WVYJM394835PYT1D)
(airdrop u53 'SP2FQCK9G13XNP5HFP0WESARDJWXJMTM6H2E2CXH8)
(airdrop u54 'SP153RCF0G23G88R9Q1G4FYTNYTTTDDYMSNWDNPD3)
(airdrop u55 'SP1PKKPBB3K60S4PD7545H7JK8AH0MZJEV9T4X15K)
(airdrop u56 'SP3ATFW5VSD0W4N0E3K1E4CGFE8MJXQ9XFFMQ0HBY)
(airdrop u57 'SP17BFJSVKNGRQRNYXR2DCV8TSFTFPW3P9BVQWMKY)
(airdrop u58 'SPRTYCCMQ15H22VN2F96VRF60MCJBNXFQ3WMDBZ4)
(airdrop u59 'SP1Z9H94PPSPCAP0A1YZ0ECEF7YYVWCXHY1SJH96K)
(airdrop u60 'SP68A2GDYFED1P932H1Z3J2NKP24D8WW486C6QWT)
(airdrop u61 'SPESDYPQP2ZH3HBZTMMJNE5MHPCY8KE6TSAK10FT)
(airdrop u62 'SP31VD9ZBK2ZPE822YMJ64VZBFCFH6N104P9CGS9)
(airdrop u63 'SPEJGDRBB31E1V00BEBSCMW343GDFEG3D7AXRG7G)
(airdrop u64 'SP1TV749TN6YJP7S3R7DAX1P0FB1C4MAFKFBW6MR3)
(airdrop u65 'SP1Y1T6Y52JGBG7CCTT8KBCN1K5N9A18T338QT5M4)
(airdrop u66 'SP1Y4KEFT4CBAWE0DDP202KNDM16NBFJH2V099X33)
(airdrop u67 'SP1GAA5VBWE65MZGPE4M66PZRQZTA2M10F7V01X4V)
(airdrop u68 'SP7J000HNJPQX7GC2BG13FJSQZ2J1J8EVY6MY7XG)
(airdrop u69 'SPSQ4W56BY5XKZR8YJMXYP1CKJ64TT4CQ04GFQT8)
(airdrop u70 'SP18TMHKPGW4RZF2CE63NCZFNEAKW9P1XS3EZJQVA)
(airdrop u71 'SPWC45P8JQP1VG9NDNPJ6ZXPVZ4XXGK06GXR5XN3)
(airdrop u72 'SPZ94RN5KMNFCECJMW876ZH59A30X2HECQMEVDHR)
(airdrop u73 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK)
(airdrop u74 'SP2KS65M7CV8Z508DG1VRHJFV61FDRZCK02FF9DNJ)
(airdrop u75 'SPGACKM8A0CVEW11XQ2M0EAFRM24DNDWNAN7RXFR)
(airdrop u76 'SP2P8RJ42R8MP0AAJASTT7ST6VZ7GHCWR7PET3B21)
(airdrop u77 'SP2KBJ8W68H4RCSAQHB0WYAFKME5AMZ5CJVPFV6YF)
(airdrop u78 'SP377PERR19T3GF9WA2MY6KZRCM1TANMRXWGDR5WM)
(airdrop u79 'SP3MVAF8396RSMFWBCNTVW8DB1JDJJHY9RE8XET5G)
(airdrop u80 'SPQ4W2M67DDEVPT02W1VXAWC4707594EZCZQBBTY)
(airdrop u81 'SP1FEWH3946B7BYS9W1CVGSPC9FDKK5K32ZTBSVBB)
(airdrop u82 'SP1AQDVJF18XEFVXMWTRAW9TQ0N2DCN0178FKW03R)
(airdrop u83 'SPBWF76FHRNA9C1A6ZZ896B3XRRK5TGGW7X9A55A)
(airdrop u84 'SP2TH0ZEF2AKBVH93A4ST0GNWKFTXDQ34YSR1CA42)
(airdrop u85 'SPG3BVT1Y0EX7514T51C5ATE9ARWN5GMN7RNY8ZW)
(airdrop u86 'SP122G3V933CWESM6E3F75V9VE9YPTGYW52XD44W3)
(airdrop u87 'SP18X5RY2BX9GA319NWB1GHZQKWX16C4SJZD4RP32)
(airdrop u88 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV)
(airdrop u89 'SP2SJYYF2XWAW2XVJFSF60P0BB5F5193TNZ5FN0CK)
(airdrop u90 'SPBZQFYJWRDDPF3SV0P04X79VEKMYZ07DG7VP8J0)
(airdrop u91 'SP3QFV7FJ2HRQNKFDTDYNTQSZ3RQAPJD7T66WEJYE)
(airdrop u92 'SP2TGZCKVWF2T3MEPT3D658N85KT8MYTX05SE0HQD)
(airdrop u93 'SPR907PMYHKNDT5R0ZXTZ6C6HE80PAWMZD3T3N8R)
(airdrop u94 'SP2PZYA27E8MRBQHQXE0JQH5CHM9JJNM00YEMC4QJ)
(airdrop u95 'SP1PKZ3CQSC8RWFCJ1Z0Q4VE5BAF5E5V59PMPKFVY)
(airdrop u96 'SPS1PM5CSB0R731ZWE329EDX2PT2RTXRQHA1ARCS)
(airdrop u97 'SPA6Z8C308QWMRDHFC5PVXDY989MW9DHCB3KWGKE)
(airdrop u98 'SP3HQ5PX7ATWQT3NPAS0ZZWF1FD747VF8CJ7344NH)
(airdrop u99 'SP1R72EVD25AVFPYJGMS402PEF49HG2V0R5J7T1E5)
(airdrop u100 'SP1D2JB7J9BWPQTH49AB5XNZPH0Y8RXJ6203F6T5N)
(airdrop u101 'SP1ANSAC8Y5Q1CKBZQGDCM9N2618VEDN4CVJMDKZ9)
(airdrop u102 'SP38JGWTADV6949NNH43ZBC64VBE70X72P0RDJE1)
(airdrop u103 'SP3VWWZYHF92082SPJCTK1X61665VYS20VGBB1KAZ)
(airdrop u104 'SP2387TVHZ5X6TSCD6HNDA7N8ZC4M1XNYHFBHNWS5)
(airdrop u105 'SP2WQV1YNPZYHF2MNJ4SDXBSCZSQVM86EKFNB5ACW)
(airdrop u106 'SP3046RCBEPPAC1ASS4KWC50TJJH78FE681PHNA8Q)
(airdrop u107 'SP10PX1X6X5DZEZCZ0ZTV6D1DNHQ2GJXKPAA3YTKV)
(airdrop u108 'SP12G2A9ZKB08QQTZQXWH95K9H6J7G5SBGJ45WPYD)
(airdrop u109 'SP2D8RP8J0EYMZPFTT0SS0YE4HR0JV6CBBAB9508F)
(airdrop u110 'SPEW42NMB4F832CDN4GDFQV8D7JD33B22VRFF7WY)
(airdrop u111 'SP1NRW6CW39P00180RM071C8QMR74NQPD2XS2M8F3)
(airdrop u112 'SP35D1PHFATDEHVCJEQ1Z2M1MD71YGBDRM4TFPYG2)