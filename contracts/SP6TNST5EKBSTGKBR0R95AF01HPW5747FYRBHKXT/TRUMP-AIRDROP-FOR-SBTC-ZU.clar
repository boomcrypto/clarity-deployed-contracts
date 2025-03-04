
(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP6TNST5EKBSTGKBR0R95AF01HPW5747FYRBHKXT.trump-meme send-many (list {to: 'SPBQ3VHZAXDP7BFH2C5DSNN7XZFP3E5GDEF5JYPJ, amount: u100000, memo: none} {to: 'SP1QY7345XCN36RS041CHY5QT4Q4E2FV6VGQ4510G, amount: u100000, memo: none} {to: 'SP3QR8PYHYRKFERM3CKAKQXFQ7M1SJ4383EWNC30R, amount: u100000, memo: none} {to: 'SP3G9C89KCS7S4FKHJEFK6SN8J2H9PR3E6HM2F9GK, amount: u100000, memo: none} {to: 'SPPQV44FJWBXFGVF9NJ5PTV9B0CCNQNTKNPGA6QR, amount: u100000, memo: none} {to: 'SP1E751EJJSDR62WB3WK6QJVR5M9RFBV3SHH453PY, amount: u100000, memo: none} {to: 'SP12V7ZARZ3S8YD98YWYKH3QVMXZZEXB7CD8QQQ4A, amount: u100000, memo: none} {to: 'SP33R5AZV09JXFN5JKM89DM48CPRTAVJESJ49TV7H, amount: u100000, memo: none} {to: 'SP161T05N1EWJ52XDVSE1SY16N80PSVDPZRSG3MEM, amount: u100000, memo: none} {to: 'SP3TA40KJ1DGB5Y231PHFCECWQGK1313J5KM4671M, amount: u100000, memo: none} {to: 'SP2JEVSHVSAQV5VW2RB748KCRV8V9NG3D9TGQTE48, amount: u100000, memo: none} {to: 'SPWWNKR8ZANV0YWS6ZN5H5GYZZSPHXN39MDZ2J6K, amount: u100000, memo: none} {to: 'SPXY0VFX761352VTJPAMNYTJYYA82A5DRH0VR57P, amount: u100000, memo: none} {to: 'SPAKQTN553RJVBJJ65AF22XXN7PP89C8BEM0FW40, amount: u100000, memo: none} {to: 'SP3T7AK2MVX1C3VB7YSV0H48HZRMV0B0QHJAB4N50, amount: u100000, memo: none} {to: 'SP15D2ZFYSV1T4YYPY3NYN75JCRZQWWA4MN22TDR9, amount: u100000, memo: none} {to: 'SP2P336EM6HGAX7NQJGR0A4W7KP11BNY25YDSTA6W, amount: u100000, memo: none} {to: 'SP14EFAF85KE7G42GR9SVEGWXT8XW2VDP3QTPBTKY, amount: u100000, memo: none} {to: 'SP3P46ZY2WHX5V4EC6HWX85KY75R6B9VV94MDCSZ0, amount: u100000, memo: none} {to: 'SP25MAMV1RKAVCY6HZSNX8V3VDMDPNNDEVNKSMDJ7, amount: u100000, memo: none} {to: 'SP14NM3P7YSV8KH3ZQJ7QC726NQ55MSKMXNQTBS75, amount: u100000, memo: none} {to: 'SP1X9HAM930KHKPKHF3F44J30T3HAVXDXJBT0BX4W, amount: u100000, memo: none} {to: 'SPDAK6G9JG8BRTKMSAC03JAM046BS8E3K90YAW2R, amount: u100000, memo: none} {to: 'SP1S9MZKQ3QGKSY9F0FTW26BQAYC4N543TYRG2Y5E, amount: u100000, memo: none} {to: 'SP90RDWVNK60VHVZZBQX60CTJS3N2V3W1HHASEJD, amount: u100000, memo: none} {to: 'SP2FS9BF92Y1SPXR2VN5K0FHWZDS1PQQYDXB2NH6H, amount: u100000, memo: none} {to: 'SPDHPXT9CZQ17KYJRSA02W54DFP08FG6BHYKZANM, amount: u100000, memo: none} {to: 'SP325225NJPW66N8DC3N3RBSDW5006QWJYFA8XAMQ, amount: u100000, memo: none} {to: 'SP1TM71P56ARSNQFFAQWBQXJ6786CHKH9G2C3ZFG3, amount: u100000, memo: none} {to: 'SPTQRD9WQP6ZDA78EJF72B4ZM4P4BWQWC81W1399, amount: u100000, memo: none} {to: 'SP1Z0W2A9XH2R8985VKCJD7QPG1ZMMBXYKS48FTRP, amount: u100000, memo: none} {to: 'SP3N2RARPZ4FZP7JHJTXF30NAHQ0T9EYG4QZG4DJ5, amount: u100000, memo: none} {to: 'SPZZDFGRADAM0B3YNYMHW7Y9NAYJPWH9E18SRAJZ, amount: u100000, memo: none} {to: 'SP1SZQFNX9R6X782JED528KQT718MJA8AGKV282MA, amount: u100000, memo: none} {to: 'SP1J9JVDWMAM63RZM54R43TK84XCT85C2W254TMYX, amount: u100000, memo: none} {to: 'SP1RB1V65A1PAAXYT8PVFFFC6T1FN9E8RQX7HMDKC, amount: u100000, memo: none} {to: 'SP077QS6TJ4F4D3780KZE2CKEW78G9WB3TNACZKR, amount: u100000, memo: none} {to: 'SP1MX49VX1K525JGBHABKGB4F37C1QMREM9H4VWJH, amount: u100000, memo: none} {to: 'SP3151657BJMN72ZY56MN8CMCCBH4CTPH3S6C2G8R, amount: u100000, memo: none} {to: 'SP1ZJ2APVE2WBXZS1WR6GPRB4A49R214RXS6CKTVG, amount: u100000, memo: none} {to: 'SP3H4NPDRFM97G1MQR049AYT69TBHN6B20ZBRFA3V, amount: u100000, memo: none} {to: 'SPE68951PZPW5ADRH23BAQ5E0P0HXM8XTH2AHGKB, amount: u100000, memo: none} {to: 'SP2DC1NTQTEXJ66K4FAYQVB4C0AA47HP1HFPVYGE2, amount: u100000, memo: none} {to: 'SP262Q37WXVJA3MPT41R1ZN79R0BYYFN6BQ7MTAKV, amount: u100000, memo: none} {to: 'SP3H6ADRE4CB2S10EQS193SE3BKR4S3CEVQCMHM6K, amount: u100000, memo: none} {to: 'SP16VAAGEE7XE3DFZZSFDW7T5SCJR1N0WY3CVQ00B, amount: u100000, memo: none} {to: 'SP2JWM4MB1SBY2FT3PG5PM0V12NW8Y4FK1XXWBHSF, amount: u100000, memo: none} {to: 'SP3RNDPX6X3MNZMS3NV28AF6TXVFXDXCAJTTX78GG, amount: u100000, memo: none} {to: 'SP3WF2DJQV0FZQ4WBGBH5NF724ADPR706KVQ559CH, amount: u100000, memo: none} {to: 'SP1TJGR2Q7FVZ4QDHJK8ZDRBE8C7FYDNS1K0DZ6CT, amount: u100000, memo: none} {to: 'SP3W83KG17KJZZXPDZQDTRQKQRGHNFZN410R9P02E, amount: u100000, memo: none} {to: 'SP19HGJE7BCQVHTPKR11BKP7AC60J837BEYE5GPMP, amount: u100000, memo: none} {to: 'SP3NKFD8FD7FGVPRGG6F8V5VV0MSY8FE7FVPP9PEF, amount: u100000, memo: none} {to: 'SP74BB1WD3XG6V7NMK4TW5SFNHTJ5AD4N84CAZMF, amount: u100000, memo: none} {to: 'SPGZHQN9C9B9JA52P4YKR3XQQ8N747NXGGW1V8EZ, amount: u100000, memo: none} {to: 'SP2JRDNCXQ3MPTPNESPJTQAS546DPNXT0WY35731Z, amount: u100000, memo: none} {to: 'SP1QYG7Q1NT7Y9X8GV4DQQYSM2X9DDVH304BVYF0Y, amount: u100000, memo: none} {to: 'SPZNDFVQHVWH9C4PAV3Z9W52RPADDSEJ9R1PX4BT, amount: u100000, memo: none} {to: 'SP19PXXH9H5HQ7RKGH39124YS4NS53SDFHZVCFZS7, amount: u100000, memo: none} {to: 'SPTRD7N8CDE68Z2ATYEKAS6E7K40J8WMP3MNWX47, amount: u100000, memo: none} {to: 'SP20Q61GJ6GWABJHV2B0XWA1N2Z5SVY8ASKHBES55, amount: u100000, memo: none} {to: 'SP2DE8GXZVXXJHCBW9DFFMADZ40SKDPDKX5EZ79NT, amount: u100000, memo: none} {to: 'SP1093PXJD0BB7KK6SPJB3TPQDRPE0VVK7PWY1FGR, amount: u100000, memo: none} {to: 'SP12WHJ0PCGE53HNRZNF92PKH4R3C6HWZV4MF2SRV, amount: u100000, memo: none} {to: 'SP314EAJ16MWSAH33C394BHXZQEHC9PMRVT06HQJC, amount: u100000, memo: none} {to: 'SPXGA1M0XE3DD84VFF4KDYNZ8WS3W7079Z6PVBQX, amount: u100000, memo: none} {to: 'SP2S3C7KJQZDZWW8F9Z57YXD1B27J75JFWF3H8XKQ, amount: u100000, memo: none} {to: 'SPX9AVXYA6JW4DK6DNW3XJZECR74MBPGB5X4PSF5, amount: u100000, memo: none} {to: 'SPHZ4N00EMEVJ2Q66KA34VD5H3SBPV0JM4ZPN5H3, amount: u100000, memo: none} {to: 'SP3D312WVYRGK9EQ7DJEX43JRDEM93SDMV3XXHZFT, amount: u100000, memo: none} {to: 'SP1YTJDBXGVKJHK4QQ0A1EA3PKMXQBP3GG0RAJCY7, amount: u100000, memo: none} {to: 'SP1JHQZQ7XKDSE2HAZKD7N9A6MCN7PDCZ5XHK486K, amount: u100000, memo: none} {to: 'SP26M2WRP0F96AS5BPVVXGVHSC1A4648Q2BFM2TJW, amount: u100000, memo: none} {to: 'SP3G6FJZKYH7EGSTF4RWHF7CDE7EHNBAT32MMASZ5, amount: u100000, memo: none} {to: 'SPRSQ4RBKB6QYE9V45CWZN0Y8VQEKD38RATBH7A2, amount: u100000, memo: none} {to: 'SP362H33H7ANHSEH9SN98ENTX3QH16HM5C4MYPG2Y, amount: u100000, memo: none} {to: 'SP3F27JXPG7FDNBBJTBQQ435WDP28R6PHWVPE3FX3, amount: u100000, memo: none} {to: 'SPEDXKKEBES7V74SSKE8QX4N4FETRJ26ECEKBBPF, amount: u100000, memo: none} {to: 'SP3QT1989TQTVXMZHCMF2SAHW3QXK9ZZ2N2MQYXVQ, amount: u100000, memo: none} {to: 'SP25MCX61AWW163QBTW2NC7TS6WE3JKM4967MDZ2F, amount: u100000, memo: none} {to: 'SP8XKFCA54GVMYD7ZA9DJ9VR3XY9AHN8E2D5MG3W, amount: u100000, memo: none} {to: 'SP6EAA73GZ9QRP8M8RJ1K8Y6TQDJJ2SSKWB010K5, amount: u100000, memo: none} {to: 'SP15QCM7NJDMDJEMD3H1RDR2PV7JH0B4EMNYT9T69, amount: u100000, memo: none} {to: 'SP243BDJKB7QKCD8GC87V5GEZXH5E25B9BD66T4R3, amount: u100000, memo: none} {to: 'SPDGZ40Y1PMFE6EKZ1P6B6D3PTS6ZCR4CM1SY0HV, amount: u100000, memo: none} {to: 'SP1YR9YE171WMHDTFC8ZPCW836ZSZEM2P3W9C48ER, amount: u100000, memo: none} {to: 'SP2N7VSJ2DT9NY438G3VDWYFP3WWBKYN46GQPHH6T, amount: u100000, memo: none} {to: 'SP2M1KV3AHT55YZ7VMRN2JS9HJVTVSW8RCAT4B326, amount: u100000, memo: none} {to: 'SP3E3YY80K9RYMPMDNMQ5TDT9FZMA6DS7B1PB2MME, amount: u100000, memo: none} {to: 'SP3V6CJR12YJPEX98SGG447GNZX541QGWGGRR8PVG, amount: u100000, memo: none} {to: 'SP18FEGNAJPHMB1ZCDDRYJ92GCQW4DWWSZ72ZXHZ1, amount: u100000, memo: none} {to: 'SP1S222S146VZQGW21D58GM20FXWDJ8HXMXH3RNVB, amount: u100000, memo: none} {to: 'SP2T3JJXD7Y7B3G9V3KAGW167X5YB3HWZ3TKASNXG, amount: u100000, memo: none} {to: 'SP19Q1NE93YQZC95Y6DDZR6CA43T2G6CC99PZ2JTD, amount: u100000, memo: none} {to: 'SP249J11A1B5X0PZG0WDNFGB7SG2TYY37CGK921Z7, amount: u100000, memo: none} {to: 'SP1QPG0DXG6Z90CMCFQMXCRB1258Z527SX70CPG37, amount: u100000, memo: none} {to: 'SP1DB81CRGJ99A621W6C9F2W4F1YNMT3FWKFP6WJS, amount: u100000, memo: none} {to: 'SP3DHESS6CYBESG5812GWHZ7NWR7KK8ZEXZ6BESDX, amount: u100000, memo: none} {to: 'SP1EN5T7H48EVND8JQ1VPSZKHR49YC8E05J8TWXMQ, amount: u100000, memo: none} {to: 'SP3K9BRMHSN8KKGDZC7GPZ35XJBXJ9CXMAK1H3PBC, amount: u100000, memo: none} {to: 'SP1CHWS7TDP36PPVWV8E4Q8QV7S8SZPYYWW9N0ZW8, amount: u100000, memo: none} {to: 'SP1WFBWXTZZT7KE85Y6HV7MNSZQH18TCD8JWC27Y1, amount: u100000, memo: none} {to: 'SP1927MA1M5E1KVPYMFMT8ARNGCY6FFFJXER7MN35, amount: u100000, memo: none} {to: 'SP2V2C5A5BA5YB1XQZ9EWQ65QJH0FQ13557M5XHGS, amount: u100000, memo: none} {to: 'SP20GEA83VEXX1XW3PA4293BYXGVK5T608SX4RDEM, amount: u100000, memo: none} {to: 'SP1CWHNC8VBSBD2SFANT6E65P4RGM3NTVTK1RJEF2, amount: u100000, memo: none} {to: 'SP2VS7TMXG1WEQN9W9WGVW4E06FAMKT2AYZMT94DY, amount: u100000, memo: none} {to: 'SP3XZM3R8D8D6JE8VTJ8TTW59DBEP2YDC1K61RWJ2, amount: u100000, memo: none} {to: 'SP3G4AVQDH622Y0J77PN2JH1BJVBJ39WBGBKA2M1A, amount: u100000, memo: none} {to: 'SP11DGFWJK8NB8Z2R7B9N1CQZSJKD2MQ3P98NXM1X, amount: u100000, memo: none} {to: 'SP1K448QTJKMPYJH1BAM939S9E8V5WRTWVBPEQB7D, amount: u100000, memo: none} {to: 'SP3Z4S6FMQTZ42F6TFEWZNMASZQ6EJ3M5ABSB1T2Y, amount: u100000, memo: none} {to: 'SP9FATAHQ37CZK6F20660X6FK9M3VA2C3NHWGWAT, amount: u100000, memo: none} {to: 'SP20DE60E7WS597FAJHZ52A5AJ0A5JB34VPR72QRC, amount: u100000, memo: none} {to: 'SP3J70E18Y8J476QCGAH55GR24PC36PAWSVPR8788, amount: u100000, memo: none} {to: 'SPZKPNX77WD6PFEGYRZAPQFY318EG17XWV6MERDT, amount: u100000, memo: none} {to: 'SP3N8X2M713B43F2K05DHPRNEWP2VPVT2VA1GGMKD, amount: u100000, memo: none} {to: 'SP148A8PP9DE6T0W3AF5SWWP3GXB984AX8MBY970S, amount: u100000, memo: none} {to: 'SP1P05QV1K4Z3C98ZN1R8QBMA79DQX6NPJYTW6MQR, amount: u100000, memo: none} {to: 'SP1J744ZC17NHMPN6EP4RRQ7TXF477YFKYR1J2SSN, amount: u100000, memo: none} {to: 'SP11KEPTX6S20GRS7HGP6HEM036VGG9MRZZXQ3R39, amount: u100000, memo: none} {to: 'SP18VK6KX9KFQS1FCFJ9TYPQDSEDSJXJBKSEN22K4, amount: u100000, memo: none} {to: 'SP2DS5V25N6EXXF1X0CWM3E4ZFDM3HSQPFAH1A05T, amount: u100000, memo: none} {to: 'SP1G0Y2PJ0AZGNDQVS6KRC425DSAJKD321WHBBJP7, amount: u100000, memo: none} {to: 'SP2GCP1MF71SGMN7T8NX3M0CBM292G64A8AH6K50E, amount: u100000, memo: none} {to: 'SP3523C8C9Y25G9P3Q6GFC5M4C8T3C55KWV3ZP0T, amount: u100000, memo: none} {to: 'SP386FBKTG1QCAJ5M4A680SWFJYVYTVXAVME04QAP, amount: u100000, memo: none} {to: 'SPKBJ3R6MGJ1JRJPG57BM224T70BT9E6R4JQ8JF1, amount: u100000, memo: none} {to: 'SP2S8WFSWYF84SX9206E1MESN3XS669M7Q5KHXHTC, amount: u100000, memo: none} {to: 'SP1RHZVXQT0EYFZ6AQA242MJ88N0217CV5C4WHQ3F, amount: u100000, memo: none} {to: 'SP3WK8X7V71JNK8VPK736S7R2DVZMKV2N2YDY2EAH, amount: u100000, memo: none} {to: 'SP3J1HDD08AGMGVH560MV4D9EZJ0E7ANRXQTKJMTF, amount: u100000, memo: none} {to: 'SP2N91Z2A1VNH4A4PYA3JH116XKBVF8CJHKAJ29F2, amount: u100000, memo: none} {to: 'SP3298720FTGJ34Y2XWDZGM6HHBB2AKA508Z2G7M9, amount: u100000, memo: none} {to: 'SP1A68MSD7H4WFYJQPE3NPE1PXX9RR7W7ETXM598A, amount: u100000, memo: none} {to: 'SP155JDJSF4QRHCH1ZMTB5Z802GJ4G0EQVVY4KSBY, amount: u100000, memo: none} {to: 'SP19VG66CM0VX1R818H0HMQ8EHRYVXTSX4ZGA69WP, amount: u100000, memo: none} {to: 'SP19S2ZARWJDKKC1SR7V09ZSM0NYEG1GB5H1XZQQM, amount: u100000, memo: none} {to: 'SP6MQ67EGTC4W6YGAPHTQ7AP776SFAK0AQMXBT1K, amount: u100000, memo: none} {to: 'SP1RACBWD24S5T6SAXTQ1E425Y5NEK4DD0EQAT0CX, amount: u100000, memo: none} {to: 'SP2PW8FYT6H06BY6Y1P3YKAY6CG38JHD9SKPMJ44Y, amount: u100000, memo: none} {to: 'SP35DMPV41J9262MDNEWKHQH8VDHPF1X7PDA8A0JK, amount: u100000, memo: none} {to: 'SP3TWJSAM450Y4X5MTS47KWK77X7MB0X4P26289GZ, amount: u100000, memo: none} {to: 'SP4WA7ZS6EF6CQ1F27Z88EXQ7N211ZCRJ2TVH3AR, amount: u100000, memo: none} {to: 'SP7XQF0SGP9R0WAH8NX5BQV3ZC04H5WEV7AT2FZW, amount: u100000, memo: none} {to: 'SP1EMVVHFD91WK6HACVGKXX7DW3NYJMYS8W7Q3PJW, amount: u100000, memo: none} {to: 'SP3JA8BEXJ7J60NP51D7282H78YMXFGSEJV3Q2CBG, amount: u100000, memo: none} {to: 'SP2JKCJ2XZ914K06VFW3FRCYTY6S57A4A011B0CNN, amount: u100000, memo: none} {to: 'SP3R30SGFS8PK1BM6SGQN6GX6GVFEKFCXWPSSJHA7, amount: u100000, memo: none} {to: 'SP14JXHKGGDX0QHZ87DZJKWA6AP6WV7X4HDMPRMTZ, amount: u100000, memo: none} {to: 'SP2HBBQ3SMGHMD0KPDEFE4MN5WS8BZG23D2B3RPJ8, amount: u100000, memo: none} {to: 'SPF5AZY0N16YB7AA3YCY12Z89VJE6E1ZK2E5E9SN, amount: u100000, memo: none} {to: 'SP17WRR7TDG60FJJW4PXEM4S27T1DPY7VQE5QAMX1, amount: u100000, memo: none} {to: 'SP3A0TS22EMC0ETYVXG76Z2YZZ0T8TWX0QW42RYJ5, amount: u100000, memo: none} {to: 'SP1Q6Q8D44FFFYRT5V1BRBKPS34W26F0ZKHJXTJDZ, amount: u100000, memo: none} {to: 'SP3HRC476H7VF4RY90SESZ7RADVEVKJFN8M4QAFEW, amount: u100000, memo: none} {to: 'SP1VN26PZ9E80G9MGDJ3SNECDAJCFZAZC2KJQEGK7, amount: u100000, memo: none} {to: 'SP2SGSJ3TDC07ZBE53K6AGS1PMW07NP3FK8Q6K65D, amount: u100000, memo: none} {to: 'SP3TKPKX88XR5FACNHXM11YRZ7YA6NH0XN457MPVJ, amount: u100000, memo: none} {to: 'SP3SDJEFE6ZQ2KJKVGCWC1A25GFPW6CX8Z77Z716Q, amount: u100000, memo: none} {to: 'SP2DPZ5K27BRH2A5ACA7EFR6PJ3GPK3DR7B2AMX7D, amount: u100000, memo: none} {to: 'SP3GFJ00NC1WHFQ8Y6ND2FMZB6F6ZSC4NG247KS7F, amount: u100000, memo: none} {to: 'SP3GN37GAPD3ERB5V1DT00F41PH2AQSZRB6016MXQ, amount: u100000, memo: none} {to: 'SP1NVY84GF8W0AFPJKP71PV5WNFWX0BT0HVF1TQC, amount: u100000, memo: none} {to: 'SP3JQM1Y1B06GHF23TBHVP1HDH56QHYS5Q96D3JN3, amount: u100000, memo: none} {to: 'SP23210MPVNRY0141T6F6XWESDB00CMPRH46GXXRN, amount: u100000, memo: none} {to: 'SP76BYNSX1C3V6XRQ8QWZW887AX49PP4ZHT0W0VH, amount: u100000, memo: none} {to: 'SP10G7EKVAQPPC3MWZTD04974PBG0F3H2GDAK8ZPE, amount: u100000, memo: none} {to: 'SPDARSTBMA1QYEXVN58SSDWST3S6YD7VN8YFZAMW, amount: u100000, memo: none} {to: 'SPBGWX7ZW6C51KR00PK2R5YN2NTDYBX9J2GQJ4B4, amount: u100000, memo: none} {to: 'SP1CT0FV0K1C5C9KW9SWEW684MN4QKM5QMW3NQ7SZ, amount: u100000, memo: none} {to: 'SP28DX7EFK9AGG61X1153YZTWSWJMFN34A7P9Y1P4, amount: u100000, memo: none} {to: 'SP376372HW3XN5K316D1PCVMX067XMHPBKT4EZDY, amount: u100000, memo: none} {to: 'SP62BZRKG5DCSZX1Y3DYZ32JSA7FPAJFK8M7EAC6, amount: u100000, memo: none} {to: 'SP3H0FT1S9P5HDTJAT82H9A4CWGZ7D84GVQCESNFT, amount: u100000, memo: none} {to: 'SP2PHP5AE0BG3SXENTR7F52KW4HSZDMXAPVWG5W9, amount: u100000, memo: none} {to: 'SP2FRQ5SH7YJHW1YR98C9VZHFH1VX3RVZHX6C87V9, amount: u100000, memo: none} {to: 'SP390F9NW4H745J2TK4F593E1NJ0E0X1GFY74E0S6, amount: u100000, memo: none} {to: 'SPWAR5N31A2951V0TZHKYMDGHXQC05CQ3T4N5ZAX, amount: u100000, memo: none} {to: 'SP23YAH0226228PZ35KG6PXT9MG2PKVMB3G99TYR2, amount: u100000, memo: none} {to: 'SPJWMM1WH9RNEC22AA0KFYRSKDSC7YTS92Z8H6PP, amount: u100000, memo: none} {to: 'SPQM2J79MNK0RRGF9V93CPYVE1YB0TSXGRH32CQY, amount: u100000, memo: none} {to: 'SPMHTTD0F80F253DWP6MGB43YZHMKN11H5GQ5K6W, amount: u100000, memo: none} {to: 'SP3H0F981VVR2PW95VJ7PBNBZFNWJPE32KD2G9CFH, amount: u100000, memo: none} {to: 'SP3ZJWKB6A84S3TNNK2FJ2V27TB51D3HTKJCCHHCS, amount: u100000, memo: none} {to: 'SP3VHRZR0SBFZ6A4CNVV9CYAGTYY2K60S3WG4BAFW, amount: u100000, memo: none} {to: 'SP3CRNZZYN5QGAPDK2RAS7FGTHMZ6PWXPFZPQFRGB, amount: u100000, memo: none} {to: 'SP2XDJMSYV8MTG3NXW60R8WNF3F49CWDABW096G27, amount: u100000, memo: none} {to: 'SP17N4YH90HWQXBYT50YHM8HYYAT8FRS0SZS8SDMN, amount: u100000, memo: none} {to: 'SP3GRFSX8EP0B6GJ5XW0FKYCW39KVN5ZA2B7EYSPE, amount: u100000, memo: none} {to: 'SP1H9CVH0YS4DV4DXXBS3425VDT4VCQSNAJBY3HXJ, amount: u100000, memo: none} {to: 'SP2EPH7G19552NQ8A32FMZZP5X6AR9W56YW5HD1JY, amount: u100000, memo: none} {to: 'SPAENM03MG6VK5XDEPYF2N9G1X2A7ATD8652D1GE, amount: u100000, memo: none} {to: 'SP1902FZNH8AS7HTJYJDHHX0JQ3JN288F7W067B27, amount: u100000, memo: none} {to: 'SP2P7Z04WNE1R7FVYPCCVNJANG6KSJAA3S1JQHR4E, amount: u100000, memo: none} {to: 'SP3S2P4196CS5Q81ZQ71EP5GDAAE4RM1R94MHQC0G, amount: u100000, memo: none} {to: 'SP3GGMWZTK59819RFYTAW20FS4F0KFE6XRAQT8004, amount: u100000, memo: none} {to: 'SP311VSZDGNVY8TAWVWNBXVHX64FE45DH2105T3A7, amount: u100000, memo: none} {to: 'SP1Z55AWAZ33DXC0D34NF6EDDAGE0ADGMX1A72E6S, amount: u100000, memo: none} {to: 'SP22BH687QV9M68SE0VH4YHRRJ29YAWBBAVRF00DA, amount: u100000, memo: none}))
(contract-call? 'SP6TNST5EKBSTGKBR0R95AF01HPW5747FYRBHKXT.trump-meme send-many (list {to: 'SP1XXPGYTE3XDG0YM20N58C68BVS827SPFKVNZQQM, amount: u100000, memo: none} {to: 'SP1QQBQX2JTRZ07DD8TVTN39TJV4R3CJJ4NMRZ3G, amount: u100000, memo: none} {to: 'SP3YP4J7VMBZ6QKYB02GSJV72GPKETPQ4G0YQVHR0, amount: u100000, memo: none} {to: 'SP2GYCTYFBX1WNDSED2RTWECHWQVT0P2GW0Y4A7EW, amount: u100000, memo: none} {to: 'SP3RENA6R1RDD7JKYSP70GFMF56J2D0JD4E2H7BC, amount: u100000, memo: none} {to: 'SP1EPT7WEJGX5MD1VMQ779Z5C1YTAQEE4J0AF4T92, amount: u100000, memo: none} {to: 'SP339K2T2ZAKKW73A0FN1BK1KRQ6QTPR7CWJJXZ2H, amount: u100000, memo: none} {to: 'SP169JEPCNT078P1E4FBCD93GG4HFH1FW9SGFREGV, amount: u100000, memo: none} {to: 'SP3D54Y79PGB7DQPT1XXNMRCNYEA9FW4N6S3V98DE, amount: u100000, memo: none} {to: 'SP2X6X9V0K4PYH411BB8GB3MSEXH1B6VTTPWMWY3J, amount: u100000, memo: none} {to: 'SP2T6N8TRGAP6CS6VM569FRTXKS0SHE6983J3B8PS, amount: u100000, memo: none} {to: 'SP2AC8HE45X3SD12VGKSQSZJP1PW42W27MQS72SP0, amount: u100000, memo: none} {to: 'SP19C7QRJ2DKD1B15X0FJ1FSMRHQRQ9WP0JTVPMCH, amount: u100000, memo: none} {to: 'SP39QXE5QY24Y0NEYMRMYD0EYNQYNSSVGWHNTA3FT, amount: u100000, memo: none} {to: 'SP2CA44S7GP2JGY6CBEFP2TZCBYP3C6DZ76V6EWRP, amount: u100000, memo: none} {to: 'SP2BTK901M52YGZHT3N9969TGF8CGH3RG1EK9RAH9, amount: u100000, memo: none} {to: 'SPRWHV2RV6Q1D44V70R9M0SWSX548DP1J5QB0PD2, amount: u100000, memo: none} {to: 'SP1RQK3TQJS5WVMNCQVY1ZW9H6S78Q3DZGF6NEDM0, amount: u100000, memo: none} {to: 'SPZT8RCWYZYKPX8QYRKDG2XTWB38VE6WV15WRV8B, amount: u100000, memo: none} {to: 'SP2KAX4T76DH2RFTFZ0BYFVE27ENWAN08A1AN3M6, amount: u100000, memo: none} {to: 'SP1GTKWWV3N2HG81AS9N7TTDJZCM2749NMJX05GKV, amount: u100000, memo: none} {to: 'SP3Z5SBR3ZK6T4DCJ7WMXX61GFDFNSXDT98QSYQYB, amount: u100000, memo: none} {to: 'SP3PXTFFX1793FRW4XVZJKNMJ77M5SFSTHXWX4MPB, amount: u100000, memo: none} {to: 'SP1D15PKDHN12A6E077RDFEJYGMP4ZX3YAECFMGG1, amount: u100000, memo: none} {to: 'SP1XRHP4SBVKA9N069NSX6TTB0MG8JK5NFZWBJFEJ, amount: u100000, memo: none} {to: 'SP3CJB1BJ8T6J68HNNBKSWMZB0SG8KB11KD3A0239, amount: u100000, memo: none} {to: 'SP35C7VJ6TP7Y3V1ZPVVZGFKH99A5MPNMNXDAQ100, amount: u100000, memo: none} {to: 'SPX5NS7HPPV8KSQFKZQJ8G14GA032WKAMJT6NP9Q, amount: u100000, memo: none} {to: 'SP1MKBHD21HPZ9VQTQ1QKM8PZAQJWXFM3572M9JKP, amount: u100000, memo: none} {to: 'SP3766XANH6GDQF1CJVAJGJXMZ334QWNGXEF4W20K, amount: u100000, memo: none} {to: 'SPFC27RNZB7V525J0FS508MY6RHNQTVT7NFSFDD8, amount: u100000, memo: none} {to: 'SP2ANQ5G8A47E42KDWBT3W00REREF6AETMQ6YTMN0, amount: u100000, memo: none} {to: 'SP3Q7DRF28BA4QGGBKPY0WN01QP2SS1EQA0CZYN0Y, amount: u100000, memo: none} {to: 'SP1AK0YDP4DAJWN801SRYFBZG8RW32SG46V2XJXRC, amount: u100000, memo: none} {to: 'SP14G08PFQGX7W9XH33YWJQEJ69G1NSB59NR9G1P, amount: u100000, memo: none} {to: 'SP279058N98NH8Q2NAXY4VVA3G5904FS0771VCW12, amount: u100000, memo: none} {to: 'SP3ME5X2DZ40QQK6Q52NHHF9TGE1A5JN65TP58VMD, amount: u100000, memo: none} {to: 'SP37E50WZD0K7Y4K6JRQPE7N8C5X5256K57GNW508, amount: u100000, memo: none} {to: 'SP5Y7JN12TD8JPBT04H6NBM25BSDZJ0FPPCHSK6E, amount: u100000, memo: none} {to: 'SP2969ZSHHX800A1FSP0CK36RV1M6V5XEKM32HG1G, amount: u100000, memo: none} {to: 'SP283WKXRD5Q4WJ02R0KMEMDN56F3SFVQ22DNTMH9, amount: u100000, memo: none} {to: 'SP3DDWAGVVD9WGAA5AZ2GYFYJ1YTXP37JNEWPGA35, amount: u100000, memo: none} {to: 'SP6T5V5ZDNGKYMJCCE76FD9RZEE4Y249HAWRNF40, amount: u100000, memo: none} {to: 'SP3GYAKNQGPJSK5AHNNA64HWW3MSMR1ZHPAC5VXZ, amount: u100000, memo: none} {to: 'SP27G0SFDVZ1PQWW73JYGFEMTHCY7VP31Q487XZJ5, amount: u100000, memo: none} {to: 'SP3BEGQYBC929D1YRS9M8MEBBZKT9Q72XEDEYEKB0, amount: u100000, memo: none} {to: 'SP1RS3DQK9J3A69XK428WWTA5RVBVA84AHJNWKBSN, amount: u100000, memo: none} {to: 'SP273D47ZPFF3BQG041CBX7JHWCWZQ7J12Z4C3PD1, amount: u100000, memo: none} {to: 'SP2CA8RN0KRY37HZ7SXRNH37Z4DNCG57KWAHRH8RJ, amount: u100000, memo: none} {to: 'SP3TRFHNN36Q79738HGE8QWQSBZRF689S5HAAZYRN, amount: u100000, memo: none} {to: 'SPVE11REV3G8VMWG3S3NQWW9XSWZN89N7BY23CZ7, amount: u100000, memo: none} {to: 'SP1CHJENAXENQA152EP5A2MC2HZX9S22VWNCXSAES, amount: u100000, memo: none} {to: 'SP03MW49KG2WGT9MB1PEKMJG010NEJQJNA9APP2E, amount: u100000, memo: none} {to: 'SP1ENF33PJX0VQY0FQYK2YVFAXA1WMD7AZ65X8VZM, amount: u100000, memo: none} {to: 'SP1164XG34CRA9K2G2HCS1XF1S6R9N4ANVCQT0BVZ, amount: u100000, memo: none} {to: 'SPQP8R76EPCS8CWEXEXKDP3YNB8CVDXKG01XC6MB, amount: u100000, memo: none} {to: 'SP3QW73B5FVJZQ8CJZ3CQN526EXB8MWCE06V2JDHM, amount: u100000, memo: none} {to: 'SP000000000000000000002Q6VF78, amount: u100000, memo: none} {to: 'SP234KQ79X3P56TGWYSACGKXM5NP8EQA2R5QQVYKJ, amount: u100000, memo: none} {to: 'SP2286XX3GZAHT2B9K40V7BVTTYVS92PQ32KSR47W, amount: u100000, memo: none} {to: 'SP114GJSNVBQBAJTKVTW1330E0BWZ9B73RQP70MYV, amount: u100000, memo: none} {to: 'SP17PFSXCJ3PS4ZRZH37A388345J4P6PPVK650QSR, amount: u100000, memo: none} {to: 'SP1D9RSJ6M14EBQTD2HJSCG363DSE3VQVJ73V6K0H, amount: u100000, memo: none} {to: 'SP1BZXABNDK1KNRADQ2EZFW8Z0V5GZCP6P2NF64QW, amount: u100000, memo: none} {to: 'SPYVZQ41MTY1ECX55H1P37ZATDNH3KRA6FG5QVR0, amount: u100000, memo: none} {to: 'SP20VRJRCZ3FQG7RE4QSPFPQC24J92TKDXJVHWEAW, amount: u100000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u2000000))
)
