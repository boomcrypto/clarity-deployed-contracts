(define-private (airdrop (id uint) (recipient principal))
    (begin
        (try! (contract-call? 'SP3J9CZ0HNRZX7S5YBAFPT3SJ4KP1PBSRVP3TQAT7.welsh-corgi-balls claim))
        (try! (contract-call? 'SP3J9CZ0HNRZX7S5YBAFPT3SJ4KP1PBSRVP3TQAT7.welsh-corgi-balls transfer id tx-sender recipient))
        (ok true)
    )
)

(airdrop u8 'SPVFP50TXD0YXVDN3EA0J6VJ37SF50B7RZ1DVSJK)
(airdrop u9 'SPE81GVMGB2EYS1W5BWSG6GV3XZDMPNH6XE0GA56)
(airdrop u10 'SP356N5YV24DVGXRTP7MR33D0N0AN991SRT1473SQ)
(airdrop u11 'SP2TSV9JBA8HD0W8V8312D83NDG9NG2QJAVTHEHGT)
(airdrop u12 'SP3P5G2JAT3B6NKARS7V31PVCJZS0DP8TBS3ZVGWV)
(airdrop u13 'SP27VX4CNSYGNR2DZ7ABZHW2AGQBJ15VDYDF2BV9G)
(airdrop u14 'SP1GRHME0BDHTM1VK7GNWM3FN9TZN1YZPK7DHX01A)
(airdrop u15 'SPKSA0GDPH7Q0D7DNE6Y9MFM6QP0S47ME3CKWRQB)
(airdrop u16 'SP3QSJ073HR4X7F7ETWAEH7GPSPWH5JDS6W3SNMS0)
(airdrop u17 'SP17BBW7ZVMENJBKTH2M84RMCX1B2SJDV04BZBW37)
(airdrop u18 'SPQHKMH5BSPA5G2Z9YAZP2R1XKQ8SF8H7TEC1R75)
(airdrop u19 'SP23XTAP3MMPDPCG95C4X4WFWEMB5M5NY0FWPSA87)
(airdrop u20 'SP3QGFESCS2XD1EV1VNB5MSD5VWCCDG0WBY3Q44QB)
(airdrop u21 'SP1894WXHDHE7CM1RT9HQHDT42GCXTK9RR3T2PNZW)
(airdrop u22 'SP300JWKAX2368SFDTAM5709J3PVZ9S6CYVV5QKZP)
(airdrop u23 'SP1639XPPSHH4FS0BZ1EKC522ZV257W3MPE2DF54V)
(airdrop u24 'SP1PH418TYKC114NXYF155XNRQQFCFV6D8J7C4P3K)
(airdrop u25 'SP16GV7TPQ84AFNE07JD59VDWNHHE2FADBGRGT4YG)
(airdrop u26 'SP2KKFGGFDE47DYQFYGJB7M1VGS92GAZ1NQ4JBHVA)
(airdrop u27 'SPMFJNS1FF7TVJP65YY2D4APWC2XCWCWGZS9J4GJ)
(airdrop u28 'SP2SZQ2WKJNANP3VN9W3S8HFC9DNY6Z1EVR1YRP4P)
(airdrop u29 'SP1JEXAQAZQWMPM629RA6BC811Z9RXDH641E21C6M)
(airdrop u30 'SP3DM7D31TNPDS4T2KG2STXT42KR1M18WGJT4DFZS)
(airdrop u31 'SPNRPPRT5YPKA0AR0T2G8XTP5Y3GCQNKNJY98K9R)
(airdrop u32 'SP3VTPMYKWTC2QS3C220394BA4R9B20CZW8PF3APQ)
(airdrop u33 'SP334F8NJ039RBZ4QG3N8JZTC7KEDHWKQ2NEZCD6T)
(airdrop u34 'SP325P0GCBWNV94P7QQ4FKFGCGSGXPMZ7EFH8DYPA)
(airdrop u35 'SPK1MMYCHWB8E40JRV0DWEYWRDYR2QV1FJYCS8C1)
(airdrop u36 'SP3A0H5WERFZKYSPYJFRJ23RA04SV5PC07E69999W)
(airdrop u37 'SP3BJ0E1NRWFXS9XEHMMPDBNV5EBZ3S5ZN2XHET7W)
(airdrop u38 'SP2MA4TTQH42YQV6D0SS0KZ9102RXF68AHJ6H02ND)
(airdrop u39 'SP10HQP0PC0BEEEACR1BMXA769HW8M65NEDWJ20K9)
(airdrop u40 'SP20Z6G3MX9ATYRJT010V4Z7XXP0HEWMP0Q32B019)
(airdrop u41 'SPC28Q2RBKKYCBD00XE3HFT1RFGCF8N6W1TBY56Q)
(airdrop u42 'SP37W6CK0YZ1KJXGFM57Z7VY48T6VFKCQYKQ929NP)
(airdrop u43 'SP2Y8ZW4GZSNV18KC6VNVK6EBT3MH46Q55HKA3808)
(airdrop u44 'SP3QMHQBADCZZZVAMSNR8NZEFQYC044Y4TAEQX0D2)
(airdrop u45 'SP19AYXTE2C1552BQ9KAJS2SA0CRHS0XKGKP90K5Z)
(airdrop u46 'SPWS176WQE0WYXA0YNWDWS5T5W0KRXBV5RSH8BNX)
(airdrop u47 'SP3PWW09NKQ5PBP26E4GCB1AJ79PV6SZBEGX9XG6Z)
(airdrop u48 'SP2T5SRK71JJMT3JHHX7F35VM9XE84V1W60J2QE6D)
(airdrop u49 'SP1S5NPA5M0NXNYAQPF691HRS0KFW7VQ54BRVZ6NW)
(airdrop u50 'SP3PZ9ZQPJ0WXX9APS2VZX239BHK39FEVT185ZR8H)
(airdrop u51 'SP2EJBFMJZHFHMNAPGD3XJZJQH0FGBXJVDQ36PZPP)
(airdrop u52 'SP113C966NAQNQCS1VER3PQWRDDTNZ1TYF0BPX3EM)
(airdrop u53 'SP1C1P9ZJMCH8H0HCRTVEPCAVMJMA3A4PZ76TV5NA)
(airdrop u54 'SP2G2F1WYXKRXJVM091NE5H324BBSEGF1D6VMZ5FS)
(airdrop u55 'SP710X9V22KNEV3NNNR13P3KNH0VRDFNK27HNK3X)
(airdrop u56 'SP3QKA2TR83TX6YQE327Y5Q53QMBYGVG3MEN8KJBF)
(airdrop u57 'SP39HKMGXW6T5HBHTT6MZ3ZP9NJ9JCEX6B6W6FEMA)
(airdrop u58 'SP19P9Y790BVP2C7Y6BCTH20TAXCGF4QNTDS4PZ5P)
(airdrop u59 'SPKP1V57RK96NQN8TAZ0ANGV6RGQ9WAJWNJ3T19E)
(airdrop u60 'SP3JMYXYRTBA9X5J53SDWEM6DA0VVEMT4TXEDE2EZ)
(airdrop u61 'SPJYX32DA47N9R3CE6XFWFZV0V92X2WPTHA394SV)
(airdrop u62 'SP3GYXZKYH6DZKCW8ESBVPN5N6KTKC5WHK4AKD0MP)
(airdrop u63 'SP1B83VSK7GF4HJZDDRHCT6JF57AX6HHXJ4YWM6WA)
(airdrop u64 'SP2D0M5B89QXCA01CM9TG5H8XBGC7KT1ZJCAYQN8R)
(airdrop u65 'SPA7PBTTRCFKH84R1N5YGS4YC2B92MM95M5HWH20)
(airdrop u66 'SP2Z47ZMH1GJ9XZHNBM054KWHY1JN2N97PG3A1V81)
(airdrop u67 'SPDZ56FT3QFM931J9CRT7R0MW527K48ZD23NSC4X)
(airdrop u68 'SP1KWYVRXSTJNZ4BMX6VS3C689VSAN1FQT0GDZHFE)
(airdrop u69 'SP1EHWYVGTNY09VESTYRP7KCFZQCCCF499QRRFG7P)
(airdrop u70 'SP2584XRNCECJMG28ET47RNGST5HVFJDFYWCF93V2)
(airdrop u71 'SP2SPEB7T42GTH81AR8BB18HHFWMPAMPXTZW0QVPR)
(airdrop u72 'SP1TDYJ4TG68ANP1SG13M7MEFPJBF3XNKWQ3609G8)
(airdrop u73 'SPKQJ7T8W94JAQX1XJ7NQTZCGWW32W7XGR607EA1)
(airdrop u74 'SP25BNDPJBQ1Q25VHWKYCNHBSBGJMRDNB9A9TAE40)
(airdrop u75 'SP1FAKG5T3TNKR64B1KYHWDBVH0QS8G99N13T61QE)
(airdrop u76 'SP3F9VDH7B2D2588JNG8S5K38TCTBW008G4GTPEBR)
(airdrop u77 'SPTR1DJVM5ZNPRY0M5ED3HJ1MT2ZZV90T9QV11DN)
(airdrop u78 'SPDVGYNA43TMEJEAX05BH1BFWSPSDQHM3QBXK1P7)
(airdrop u79 'SP1D9RSJ6M14EBQTD2HJSCG363DSE3VQVJ73V6K0H)
(airdrop u80 'SP2JT7KC3HXZR10CBSHJTHKN5Q15MNY6G6NMS1FA6)
(airdrop u81 'SP3G9DVB1EW2MRZKS32Z4FAY73SVG5KX8D8H1CSRB)
(airdrop u82 'SP3KX6DBMWRQ5PMYQ1NFQEC4R4H9J1TPE4BVP0P8D)
(airdrop u83 'SP3RF7NMYWMEVTNRK1P8MPD9NC77EVQ7CS8BV21C6)
(airdrop u84 'SP3DAV77J33FWHBZ142APWZ9G94KY0JCC0Z0D53ZB)
(airdrop u85 'SP2TZMT2N7V1WPXYWNE14GXM4YWB7260PP5S3HC9J)
(airdrop u86 'SPJZVXPBN0GHHYQA3KAFJAAK7RQG3ANG6RAB1F43)
(airdrop u87 'SP2TNHSQFESSTT90QFVYNMVM9CZ4XCP49GQVBEA5B)
(airdrop u88 'SPEE2S17QQ4YAKVZ6G4BYJ7JC6JFMT6M9RYDVH29)
(airdrop u89 'SPXWJG6TB9BFSWC2C44NQ319QDGTPYSNZ84PAZG5)
(airdrop u90 'SP2KHD47XNNS032R7VQRHTH5DW1YVD980G139526D)
(airdrop u91 'SP9EHGYRJWZ167ZP1ZY7M3AP4VSBZAA2S3ZDAXBG)
(airdrop u92 'SP1CTE1GSY59K8VPNTGAF6W2X72JEV5QA73BH8FPH)
(airdrop u93 'SP2BYP1MWEWV6A2AZWB6MXPJC725R4Z5BM4YN087H)
(airdrop u94 'SP19VMVTNT2WK3VEXQ8WGJ463SHT1Q8GT2516DHP5)
(airdrop u95 'SP1S8WENCQGPSRHWX08GAPXA6VB0EMH157SKGMCKM)
(airdrop u96 'SP2062SC9MY5K5XEWMAB6S6VG3ERR0V7YG1VQK43E)
(airdrop u97 'SP1VQV48BC1GSWF0T45DFP0XE4WKEWBGR6K3SDK3H)
(airdrop u98 'SPPMWYXXBPXXYESGC92EGEDTK35VREMYNRNFZ9YB)
(airdrop u99 'SP2V3RB9KK92WRYXZKQM06PX29VAK316GSB00BHWF)
(airdrop u100 'SP6ZBR3ZH5F7JBMZHD3PGZH6RD7D0XXZHDRQMTE5)
(airdrop u101 'SP37S6ASV5A45JJ9MQWD1GG53W0CYMKXQZ6D9BR2P)
(airdrop u102 'SP2NKGW1SPN511P6QMB76XYHFD5GE3NBA95NQGD5H)
(airdrop u103 'SP3CB56S5SCW707RGRGGWQRAHQ15HWQANNN7JE8CX)
(airdrop u104 'SPNTGTG1PFEV65GM6551F8JTWQ6K9KJ19JJRBD54)
(airdrop u105 'SPN72XM6P0JWBWQMKKJAYH9EDVVXA6ZB8G21Y1X4)
(airdrop u106 'SP2W41CVZPM8HY2GMG9SXNS3TG0CT49JJ2TC7DDZE)
(airdrop u107 'SPQEGVHY3FAC84HWZ6NNWDXD35GQ6JT1FWWEK21F)
(airdrop u108 'SP2YDMX8TGY8DRJ09P55N01V0RRF7TCMFDPJGP4T1)
(airdrop u109 'SP2F43PKVK4BB5QE4MR953T4SM3XVRZJW0W57VM77)
(airdrop u110 'SPNSMY505JGXGBCFANEM01QV4STEVKH9TFMYCZYP)
(airdrop u111 'SP2XX0XPVSF1P4Q8837HYNE37056A8KK17XWGG9HH)
(airdrop u112 'SPTGWHRQH3T39PSEB4K0RB5FCA1RTCD3W67G7JWY)
(airdrop u113 'SP31B8R53TJRJQRYK61RXPGEA7HX8QSA3D1PF3EHF)
(airdrop u114 'SP2FJ9GZKZJRJ4YJK2FXN568ZAT7YVY37BC8QK8GR)
(airdrop u115 'SP9HHTQ83NERPK17M440WK6H4DTZ6QZVGFFFA0J8)
(airdrop u116 'SPT8WMAD9K3H1H7KAZBTEBN6QP3CDMX2V3WRTSEK)
(airdrop u117 'SP2ZS2NK55VW6711Y4VHJJCBJN99QGQB9DC4PBGK8)
(airdrop u118 'SP18Z15G649E37158N51T6F419YSQNS9WTY0V1TKM)
(airdrop u119 'SPP3VT59MKN6T7PZSCY9GY38S68PVKYH32AB0WJ4)