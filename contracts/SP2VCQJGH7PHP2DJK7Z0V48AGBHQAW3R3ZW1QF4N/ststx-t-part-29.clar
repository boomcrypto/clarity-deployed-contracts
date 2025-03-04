;; Used to simulate mainnet migration from v1 to v2 in the test suite
;; Must be called after deploying migrate-v0-v1.clar

(define-constant deployer tx-sender)

(define-data-var executed bool false)
(define-data-var executed-burn-mint bool false)
(define-data-var executed-reserve-data-update bool false)
(define-data-var executed-borrower-block-height bool false)
(define-data-var enabled bool true)

;; TODO: to fetch off-chain
(define-constant ststx-holders (list
 'SP12KKW35KNZHCVJ2HZ4A9RSCXGS7CEH21MK5N9H4
 'SP35HP6T2CYR6Q5NX6BNE8T1TD932KG2F2X1PM2VJ
 'SP3KTYD2DVHK5FYAZH8V7X27X9CPG9RBDQR50EG6J
 'SPYR85QEKH9M8DRD04CE36AWGR4JH4C0RYT92WH0
 'SP1Q88P496669RHKSMTSZPRJ2ZZNFZ09F5WXGHBQ6
 'SP1X95B5MFW7JD7EQD85QEC0F47HFD58MBR0PC8D8
 'SP22GKS3K3T504E6RHMWTZ33SV0RSAP0A5ZCV0VYN
 'SP2299BKGKDATXTFKNZ8FDHN74K7C1VN78R8SNPM4
 'SP1M8V9TWH35VKPES3Z5SE6SC3QYYH8V4Q3ZG2WZX
 'SP18RWGFD1N4NRXWM67299VHWV6SAKEZ6ZE9S249E
 'SP2NA0NSCECV75XQ84YYNK508SNTKWA4AZYWQEW8P
 'SP1EPE8RHP1VZ7TXDAHDGG6YZWG47DN9GMPZED4DT
 'SPQXWNTRSV95QB42ASXN8XJ8WD44GHZ6M2VBGFK2
 'SP18FHZT6MWEJGQDA4XPVDSF8K8HT3JAV5YJ4DF66
 'SP3GCGCPPAYW99KDE1VJ69Z7A31DHB98CRMQ5J655
 'SP20BRDCK1N6DK6SBTC8AMP1KGTG3B99J601EZDWX
 'SP1EYW6SPR7457KMZJAEVHK3JCBGW476B5YFTCNDD
 'SP3YYGE56KSD827S266EB3XYXF2VEQ0CPW1NGSFP8
 'SP1SM3H4E96WZQ8GCH0K8HG4QREKQWFNBHDD216QH
 'SP164S279A1RR17SFBRXBS5G247CT1YNAP173ZDF9
 'SP1GDWX1D4HMDW1S9YG933WD39K85XA326HZ6YHMQ
 'SP2ANCVW0VKZ7KK6NYP00F0VGRR3TRGEXC0R97WFY
 'SP3BRM3074RVEAJ1VD2JHBNR0SDDKW9ZEYP1092A
 'SP1RMN3KZH53HRPZYH9DCQ4NJ3TKQVBACDFBBVTKN
 'SPN61H9E1QQ7WJ047509VW9EW5ZFVEE1VZWK0MY0
 'SP5J5F9X0QM38FE2QRH0501BFB8Y0XJSYAK2TVNW
 'SP2QYAFFJVMAR5CRQKBF0G1SJYF8QSS78XP9VP2E6
 'SPV84939785F5KRBHPY3Y2VH1RK1E7K9G883RR5A
 'SP21GPFXWAAAV02P8RHT3R8ZV0JP0JSFGKSZ7YF9R
 'SP2JVB44M39020KH1RX84JCXC3PZA58VDZ7ZK35GK
 'SP3KMP49R91J0JPH7ZW42A4NKKYFTEF403YDDSQX3
 'SPJ9ER10F41HBCCEM0HGBCWDF9PY6EPG2S5VD6KK
 'SP87RE9WY5J8Z514KHFJ4ZF2PF7PRPYCX1H1HB98
 'SP2FTBBN7AEZ1CPKM3NBNMZYVE7ZG1NHF2B110Q98
 'SP2SW37ADE7PZDMJQCDC8C34MJEM6BKXZ24SZ49QT
 'SP3BTSXVZBNW5XTTE04WV52Y8HVRSFCXFBEB647V7
 'SP21KVQFKT1Q7ZR6K550TCD2H0BJS5X9HJ1WC3HHW
 'SP2GRKFF6VJCZF535D4TWTR2NSRPW1XGZXZ3NW74J
 'SP13AK8NAHD3VFN57EEMHHD91QBJWFEWHWABTK12N
 'SP2AAMK3XCAQ7M81YAP4X5CP8DBCAXQQ0CFMN2S0J
 'SP3BTBP42PP54PJ8NVPABY978QAVYV1ZWBHG2PGC9
 'SPTK25H621HEP48MY4912JRKH7DS30BBWREV33S9
 'SP1N2RZD7WW0WPC7EV55ANX88N8F2A7DMZGP3X81M
 'SP163PW8Y4YVJ39B2P80T5N9APXXX0SDAJQR8QDEZ
 'SP18EGET64NATCVBHVD1EKQ8F15KR3PQJSZS3AFNX
 'SP1DR9BA7ZQXV5EMQWH2QDZEFYTB8MTKQ15256EZ0
 'SP1YW9W6F1A511Y32MGFD0HG5JVWT933S5QMY642P
 'SP2WPDBN7CAHE8P3B17TK4NNH3XGB41DS035RFESW
 'SP393MHJ6FSC3HERJGHX2D4JGJ8KPTECZN76ME33R
 'SP4HT3XTG508GSFV4JBZ4SNQZTPJ3J242YEHDY5T
 'SPHKAF5XRYMQ164HQ6JTN68FHH60CCKC7WT4GFA9
 'SP2NKYT2E6X2NBR7FP77VP5M7RX6CGN401P7XJ348
 'SP3HFN3Z6RNKETKPDK5XQCDE8NMPGVNPYWR2CPDE5
 'SPQ8542P6CWS4VYYMXVC6S3YNTZ06Y3X0ZB5YS3G
 'SPRZMTKSW07JGQJKE1DPB343BD422ZNRA9APERF8
 'SP3X6G145Z6DV5H49MN0P0RK9SXY83ZN4ACM3RPMA
 'SP325JCAZGDZNH5E83AQEDCD6CJ57765S4CN1HR0A
 'SPXME841C0743YMCSMHPZZA5GWK908045MQ887B6
 'SP20A3HVQBR8JT5N51KY356ZVBWMDXRZ8QWQFXDP4
 'SP2EH5JTPJ380YSBH8E16V5ZYYP2EMT5H13YM4NJY
 'SP2QJKJR6T7X1DSWWEJ668BH1AK6VVP94A7EWE9BT
 'SP3ZRT4RK42A6BT6V2NM1TY5S3PVNB01J6RVG97JD
 'SP18Q757EDXW10RD1TSKS59PXRP1AEEEF8RWVPY37
 'SP2B90A10YGB4NJ449XSXVCF388JHYPP543DZGT4W
 'SP103JP1P2KNHJ1DSP1N26R1CMTB06QHRC054G7TT
 'SP1J2BT2AK5YSWA1WFQGDJF8P7PV1DEN6ZNHPBPR9
 'SP237PPBRK4S8H041RVVNDA4DQFY5Y87BDEAXXN5T
 'SP2BEW5KTD8DG8CPA0WCHYGMJFN9BJ0RSS01S1NMD
 'SP31TM3GZ6SPECK5VEA3ZJE77X98VNQDW926NYCWB
 'SP1Z4A2QDSQ2RZVVDPRABZSK9D8FJN6R3WN0WT7JK
 'SP10WHRFDR3NYS7JJM12XQK181Q5THQBV1PNAPRBS
 'SP1103G1PQTM665YNXVQBMFAHEX3E6ZK8Z84D7S7G
 'SP14RCC7FBPT4H1S8R8AZ5E3ZJSCWS5B9XY85AT09
 'SP15C0FGPDWVKN1NP9ZMGQJMNGE629Q982DK3WZR8
 'SP18F7QZKX4RGFAX4C6GZ58TJ40H3WN4Q6ZHE3T92
 'SP19RMSE37WMTTGNZKJHY7J6ABQNFCBN46M05RZHR
 'SP1B3PZ308BJRWH1QSRYT7GAG1QTY1HGKD0SESYJW
 'SP1BKXFW1HTVNQ53GBA3VXFFGKX2K24EZ4AKGXXND
 'SP1JZ7J757QTKA4K90D8039YF828Z50TZ4ZTVBEWB
 'SP1NPEBZ4FNJE69V8EDR7XJCFJN7FHWXXRC4WFK8T
 'SP1YK87WR3701NWK3G4WE32ZT97Y5YA4XWNE5G60D
 'SP21F2W5XABMBCCEB4K8BFF3ZJA8TM5E38AQ3XJ21
 'SP223A9F29B6RKT77P6X92HCEWB37H52486KG8EFM
 'SP253XXX94ZHFF3X1V3PK4WRMQ99ACAH7MVWQ8VZK
 'SP28RP5FDNKGRXX4FYV0P9370FV7E8RQ82K0FGHCV
 'SP2A93M9ZHQ5K8VVSABJ672KN24Z9KFFJAT6HFZ2D
 'SP2HK1E8AZEWP1VZ7B8MHPSPHJG4YX5G9PGN89R3M
 'SP2JN7RCFQZ8Y98FSQXRP9GVFZNEDJTYT4V2K3XX0
 'SP2K7SA8TCW2EF8237YYFCKGK1RPV6TA3ZQS88V6S
 'SP2MHKN5BXC3K30S5CXSRJCZV4MQHR7P30RC4SEB
 'SP2S5RV2BQXPXBDJ8P4G465K14Y34THTZFK6H3X8R
 'SP2XXXCV97QM3S0V0JP7JJYJA8RKARGS6Z240K0Z9
 'SP2YS5EDQKPHY3RQS66K9QNCWYNA83YW90GR358W9
 'SP31VY7WGGD9Z4YDVNES9QEQFK6B3P7BBX3504Q87
 'SP33JF7X2CBK6AX4TJCQDT02P1JAXR4JYPESFYPCC
 'SP34G5V6W0DTZP7NXXTS86BAVYDNCM6X4P5WDVJJH
 'SP3H63GFS7C11KTTF6F6QDHPJ6DZBQ197YCZRRGSW
 'SP3P015SEV12FD839XE5SB67YH6S31N8HK3500JKC
 'SP3PZNBAVV9W2WHK179DQCF7SFWBF7KD00173Q2J9
 'SP3TV07JJPBEH0DEJEMX3MEVFRESSCTK5F53XTYK1
 'SP3VPZ9DP3NQ3Y8V72T0QY3D738YFKR5MF8NJHTJ2
 'SP3VRSTBZRGCZWD3P2KSW17JQNVV25015BJWSZA6D
 'SP3WHQJNAWMWVT1KDRTTBNV10CPCC2P6GDCTT5HDY
 'SP3YQ3HX2ZVSHNZSKN5N2PENMARNSZPRDGH3WA15M
 'SP4DRC2V4D1AVBV0HNDQ3MGXXADHK2KMRGVMZM3C
 'SP5R9KZMDGAGTNWXZ1A85TRYXP90FR7R6PZX2CZA
 'SPBAD0MSD738XFXX2XK21QGJPRAEF6B0AF1D68FR
 'SPBNRQ8P3JXR1BHK5EHSZ3XBPMH2M7YDJ52TMY88
 'SPTDE6PYVFW33MJ0BBR2AHJ2BX94KB89F9EWRMM
 'SPZ4PVZ6WREF492G4XC7Y425HNG7HKXASSKCNTZ3
 'SPZTYGX0QJPXRHBP4552CTWZDKXJ4VVQYGNKSNFG
 'SPH6FZ3TGS22E23RBMHXGAH6RK08JP1GQZD15J4K
 'SP3FRXQDK4RZJYKH74T059139B3ADBJQZJYQHJ546
 'SP34KBQSHN4T3HYRD6762PV1E5PSB1W4FJ2S77NF6
 'SPAAP8KMNZC8EPQKMH12QHSWMGR4J1KJWNT5N0A0
 'SP2VTP47J3CC0BE5NKYNNN3PQZ61S70NPDJ62EDFR
 'SPW60RX1FPVTH3E5HVET3ZEWB4M3PFKPWFXRT6HG
 'SP3MH1ZMTYSMV6BAF6X0YE2A5582X41ZDZW7ZAWJB
 'SP3TSRVQJHXY7700R7KW3KT3G79WMGE2R4YB0W831
 'SP1V6HRCT3TGQY009FXVBG38KQ4P1BDWTZTRJ9ZCQ
 'SP1JEK7MTZSB2WZRKYCE32GPNV6665WCG0SACKNQ9
 'SP27VH773FJ824WDP20BQSGFSZ04RHHRYG67EX935
 'SP2G0J4JA2H89BPNEFFZFF30HM8W4MHJVZSJD6AET
 'SP2KRBSWW0TFBVZ4RPMWKDWX27BM0DN9FMY9KNWPA
 'SP2B2P0RHBZ55RRC37PY6T3P2K0ZTGT6WQN62VKPR
 'SP3YDJ3KH7ER26GZB08XJF9ZSZ54V1XSXVJ1NBHE6
 'SP3WAC6BM3CX233QWH9VZPKB37AWX3SCV0K6K5F54
 'SPPN89BC8DWQF35GBZ4YK21GJM9ADHZ70GR9WA85
 'SP7TQHQHF7NVDTZQ5S2B3EY187D22ECJMWGZTQ7E
 'SP1K0SK3VM39HD9B9G9FKWWVAV96QBNTMZM3N5RMQ
 'SP3WCTYDGWMGKGW9WR90CBQJ4SXWBT3VK1BKM0WD8
 'SP3A0B3NC7JHX5Y020329QCJVM0MKZQJ9D3R140G4
 'SP36AR7JR66V24AM94XFG894FRQ20WY4V3TFPGF1N
 'SP3CJBFW9B3VKBET0390T29BVJP3HCVVSNJ79KV4B
 'SP81G8VA8ZFZ4141PRMXHSD10G8JT2ZPPRDEGWTV
 'SPMFF99SA725ZCY9YYQ5AJTRZBHV4YD192SPY3V2
 'SPTTHFT47R067Y9GC93QX07NT5ANZ5R1MW39G9B8
 'SPRWKG907G3VG46WWPHVCTN510PE3BVAXEDDWGJ0
 'SP1KR5G5KBEPZZ5THHRXQMKVA8SW9FXTS9BK2TBBB
 'SP2D86ECR005XDGFABX9DB64S1YK19GZD61WYGTGN
 'SPD2E26F7F00PF0V7FZZMPPYEFXVF9TRS3BNK48Y
 'SP18HDCYJFYT0XZD3J62G4N6R7DG8K6T85YJ75TGJ
 'SP19FFV2ZVCXKSWEAZF019R69DA1FFS94CMB4M2KQ
 'SP2Y30D3R878W2CC5QDSTEATA3SHWXT19TDAPTJH
 'SP3VTCG8XP3T2KWMDEVB9VYYAKG38Q8Y6E99EBE5Y
 'SP2G5SQ49YWTCXES22W4Z9443SET2CES8C068HS63
 'SP1A6TNE82ETG17AF8J81FE224PP3T9987RMGSEF3
 'SP30RVXXCRASXTPTSG8WMJDZX6X7AMBP8G0NSYR0G
 'SP3M0HEFN0QC7G1H734DKZYPKHXF7T86MR8NA7PQA
 'SP35QXJW7512GS48T5QHY03PJYK9G2FBCP5Q4MTVP
 'SP12B16B9H5VBN73TB6JHY85T2E48KFWB55WVQ64E
 'SP3810R7KM0N07SBQX24YE053R0BMS3FBNV4FSMC6
 'SP1CFYP0E00YWR57Q655YQYZWXVHPF8AXVSJA82QC
 'SPDM3SWGHXY4QJGP0DDVXQR22AABH5EKTV2BV6HB
 'SP1SHYVQFD8FDSNMK950TRH8P00HQBJZ5WPEWG0XR
 'SP2MGVDF5BM1AQC17CTMY1SKFW2FKEDWSN4C2VPNA
 'SP3C83NKPMSNZXPTKCTXHGETWTAZ9GA2END890XFC
 'SP3XH1RHDZJB1HM5BVXTMYSXNG73N64RWG78KM70R
 'SP14PZMVH17K9DHEJTY5RFKCS53PBBY7EXSVW8C2R
 'SP30671XH611N511BWECWGQJV545G8VCHFE1EHAW3
 'SP32SCQC3EZBCZ9VV4M3D843XPWSFM97K93TATF61
 'SP3RZ8D0KJVG08TGXYAH0ASP1ST739H9QW3PX47H3
 'SP1VQG5562PVR5PDPEQHY11R4F4H5W2JB1GVVBQS9
 'SP31GJVSA8QPTJVRRAW1AFXN649VRRXQNMPGJXZTY
 'SP3ZAV1WX63CPX32RHGTQ0MKK5DV8S2N1J6RA868S
 'SP2GAX3V22F5YGCGVQE3QE5THHRRPS2PP2TCZKR3E
 'SP2353M4HN8MA1WKS5CJWRVS5VRQ3TJP8KHNDQB0J
 'SPG22Y5SKSQMYE3Q54962NZNTJ1ANEYJC9Y2TYB0
 'SPB806XMECZ000K7V1ZDFKQ11WAD42X9B1AX8RCG
 'SPWR2WC9MJ4VYCKQQZJRB1SNB0CD3GG4SJD1BAFP
 'SP3DZD75137VJWJ8YYFA7DHWMXBE4GCZ4X7HHS89M
 'SP2T02258VZ8BK8EAEZVDYYP6EJVP4GXSJ4V6J0S0
 'SP1NVMY3XXSXGNXHMG3X05J7Q6SS9QYJKTG085AJ6
 'SP1B8HPFBTG200S2S9M3SSGDXECTR2VKJREM51XA2
 'SP1NNWDA9BJ36V84ME7NFKFZ1VQ326S7A762S292G
 'SP1RXGVE0NDY49BK6W70JG0CRW26D37S2PZ9TEW8
 'SP28RJBSV5P4W871WEGWJTNHJ55AZNCRGG7JW1EJP
 'SP2FE3N2AXW215KRGTQM5SWEDV1XJA1PTBPRT694Z
 'SP2Q7Y2YFM7DFY8EDZH6FH7ZRWN5G461Y4JXT5730
 'SP10AD0VGGXT8W7DB93MWHVTKTJP90G45N0WHGF05
 'SP11P5S149QW8JWVCTM9QZ05MG4W1Y3TKE7257EQM
 'SP2DS0828BAMNZRPVSACT371ZZPAB8QC36SNEEZQH
 'SP3HV4KJRE3C2DZPGJY3Q87NEPAHB9YAFYYNWE7VK
 'SPYJ7GT4G511QG4JMRN11DF2HJEQA72G79WTH06V
 'SPZ82FQK1AA2Y7KKNK1HX5HV5T1SASWGYM0H6VX3
 'SP1R3395K5WQ3E4HVHJ4C8HAWBNYHM9G11S3WYW4M
 'SPRKD5KNAB4A9QDGPTKKVMN6CS2ESXYMY7VSQQPV
 'SP10676XJ9SY8S8PBMM8SFYYM2AMV5YCN3HDW4DJX
 'SP3KPTBKZFB7X87RM7X5X88S70QAWNV9BQGF9QT57
 'SPHDVHQZSPH6MYDCNAPT8JG4TE0XRD8QBQPQYWXJ
 'SP1H9X7C979NCMJXY6ZF1NGE5BJ29F90Z8MHS16HA
 'SP1K1WACD6SFP9CF09FMPBFM2AF4MVYP3P87ER4FZ
 'SP20E74SC9X5MW34ZDE29KWQXJXE3JQHJ83JYV9XF
 'SP2HM280KZ98GJYTNTWVPW0RE1EK4VF7YTWSS2NPQ
 'SP2P85BM73QJPMKMGY2JM7EWA5067GX3KZSS5Q5CY
 'SP31NJAB6FS2K8K3A2A75HEN2D3FK2RMN2WSSD2QB
 'SP3XPJWRVPBRNGAW1WFWTG3T943QTZ4W01A1NCDQB
 'SPQNPHYJJ6XDD1C6P0621KMMDMF0VEGN5AF73JCD
 'SP1HC2WZ68KE8YEXM89PRXXEJYAR4N9CPX4QWJ1ZV
 'SP2E41T73DFQWKTH4RJCDX02Q3AAWSKXD3DQQA6KW
))

(define-public (burn-mint-zststx)
  (begin
    (asserts! (var-get enabled) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))
    (asserts! (not (var-get executed-burn-mint)) (err u12))
    ;; enable zststx access
    (try! (contract-call? .zststx set-approved-contract (as-contract tx-sender) true))
    (try! (contract-call? .zststx-v1-0 set-approved-contract (as-contract tx-sender) true))
    (try! (contract-call? .zststx-v1-2 set-approved-contract (as-contract tx-sender) true))
    (try! (contract-call? .zststx-v2-0 set-approved-contract (as-contract tx-sender) true))

    ;; burn/mint v2 to v3
    (try! (fold check-err (map consolidate-ststx-lambda ststx-holders) (ok true)))

    ;; disable access
    (try! (contract-call? .zststx set-approved-contract (as-contract tx-sender) false))
    (try! (contract-call? .zststx-v1-0 set-approved-contract (as-contract tx-sender) false))
    (try! (contract-call? .zststx-v1-2 set-approved-contract (as-contract tx-sender) false))
    (try! (contract-call? .zststx-v2-0 set-approved-contract (as-contract tx-sender) false))

    
    (var-set executed-burn-mint true)
    (ok true)
  )
)


(define-private (consolidate-ststx-lambda (account principal))
  (consolidate-ststx-balance-to-v3 account)
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

(define-private (consolidate-ststx-balance-to-v3 (account principal))
  (let (
    ;; burns old balances and mints to the latest version
    (v0-balance (unwrap-panic (contract-call? .zststx get-principal-balance account)))
    (v1-balance (unwrap-panic (contract-call? .zststx-v1-0 get-principal-balance account)))
    (v2-balance (unwrap-panic (contract-call? .zststx-v1-2 get-principal-balance account)))
    )
    (if (> v0-balance u0)
      (begin
        (try! (contract-call? .zststx burn v0-balance account))
        (try! (contract-call? .zststx-v2-0 mint v0-balance account))
        true
      )
      ;; if doesn't have v0 balance, then check if has v1 balance
      (if (> v1-balance u0)
        (begin
          (try! (contract-call? .zststx-v1-0 burn v1-balance account))
          (try! (contract-call? .zststx-v2-0 mint v1-balance account))
          true
        )
        ;; if doesn't have v1 balance, then check if has v2 balance
        (if (> v2-balance u0)
          (begin
            (try! (contract-call? .zststx-v1-2 burn v2-balance account))
            (try! (contract-call? .zststx-v2-0 mint v2-balance account))
            true
          )
          false
        )
      )
    )
    (ok true)
  )
)

(define-read-only (can-execute)
  (begin
    (asserts! (not (var-get enabled)) (err u10))
    (ok (not (var-get enabled)))
  )
)


(define-public (disable)
  (begin
    (asserts! (is-eq deployer tx-sender) (err u11))
    (ok (var-set enabled false))
  )
)

