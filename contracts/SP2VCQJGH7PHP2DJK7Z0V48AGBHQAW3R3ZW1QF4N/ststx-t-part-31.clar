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
 'SPP5F4NABAQ0H96Z1DVQG3KADTDVYD5FFDYBAFTR
 'SP1PJNSRDFBJ3NCKTCZ3ZKMPJBADZ6TKQPYWT8TDB
 'SP1X5KKCE7Q2RHRVGS2WEM78V2059D5WXRZ5WME6X
 'SP2EZDBKWJKJCYNPF57V4D3XWG3KHDG51CEHQRR96
 'SPB0MXXXPW0768YR2RWVAC6R2RQQYF3QA663565Y
 'SPSHJ39EMMYZM5JWP7RE2YPS2QARGCV52T41WQ6P
 'SP2S01GTAERBGD66C66TRWZXZCKSNCMJHHDDCYCE
 'SP1208E4GZ3B52YK5EW7A04FMYK1Q81HCEPQGAPVW
 'SPJGSWR5JG7D03D55XP2HGJQC03BVBAEWZ19CEE4
 'SP2P4R9JXTH0NCSK2B9VGF6QBE9KDHYB4T6WK0FN2
 'SP4G3X0J0MZEZYZ0GX8K49D431FEM1Q3CPTE2TMP
 'SP3PVW0VNNFPBTT76MPJHC4AM175EZ0XBFAAPBQ1Y
 'SP2ZZQ7P9PRXQRRDCJX8F5YR2E4C3KACABS392XKN
 'SP1EZTYRA9MTKK69B52MMGJYG6F83QC4MH427JK33
 'SP6183W9GP835GX1Q6SSTJSAXN4PN9XDGJ790WDJ
 'SPM6ZWN6DYAF65AZZFPDN7ZW47Y70T0T2E0FSV6B
 'SP35W29TD6004P3ZSPW3HP80129E8Q0GRFWXQ10Q
 'SP30RK02S4MV7B6KEXCNYKXKBF8T3B1S5G20ZSV2K
 'SP3KN7SSPAK328BNRQEK6YQ1V7CW4NWSAJBTWCSQT
 'SP12B9ZKZ1NZ3R0Z7QSVVKMD4VBXAK5QJZCX941KW
 'SPQN232AZ5X0CMX11T8EAF0BJ098KBEKHFA18DTQ
 'SP3HFC484JA2H1BK9TKY1N2672BHH8S1ECX2H8E4X
 'SP1BA6Q94CTAZ28RJS1ZQ600QEWSCXGXBGWNP0VCQ
 'SP2S9Y713A6TEYADJRYNTW520PEDTZRSQVX6GSFMZ
 'SP30DPWAT46SR0WP8WJX8B27BR9S16P4MV083KEBF
 'SP39YZX8FAHKEE4XD2Z7785QVTGMC3E6JMAGMEY8M
 'SP3M04M5A8ZFPDSVV4YJCC6C1JFE9TD8R6RD236DX
 'SP3ZQWY7M512V810T9V5VT023954P8GZWQMFM6N37
 'SPB07FJS1EGMS5SJG1BY51RY3HBWMK528P5ZA100
 'SPG88EV6D9E251ECXPWQFBVQV600VV3CYN7HB855
 'SP1S263J5GV4S3GET4DJYZNKCN8E3QBWSK56APE58
 'SP2CX1073915Y2GK7RF50BMKR94DSSRMKGBYFNXSE
 'SP39V4YYPZ8JF62KKYDRKSXMZ94J2DTNS9XW6PBE4
 'SPHTJ363KKNEZ3GXWX8A1RRWAXSP1M7X9TNFSZK9
 'SPTNZA5E3ME76KGZZXJ5VPVYMJRNRES1SP6SGG5M
 'SP21P9MS64SGD93PZ1HRCJEP9GSMWGF59SYBTZFP1
 'SPW9V7K8TQWTF1SB9B6WDYR02BG5EAD1BP8ZWE7R
 'SP12HMFJQB9SJGZBAARRM46PJA05K4WF907MKCYKP
 'SP18WAJRASHRVEJQ4Q85VFF2WPSSRB0HG7FCC1N1C
 'SP31T6E7HP4FB19VEWXQXE0ZB9E5JWX72JFPKPNTY
 'SP264M3T26QJRM5ABHV8DFZA4X26JC7DPSW8T7F4W
 'SP1YNB324SGQWVFFCBRCMTYNFQZ5WSX9FKEY38SKX
 'SP2C8YF5SKE7H7Y3AJ48PJ7A05X3AD8PR2BT4P2JZ
 'SP2W20XAJM8HTH1AGNE79NZTAZT7JV6RS0EMKSRGJ
 'SP2QDJ8QR6CHVSYS244275C7GRHNMZTR21B4ZR4HK
 'SP2XBRSWXANMZRDCAR5VMAE3GSPYCKRWSCJADG2XG
 'SP29FF7Q30GB4GHJRCS2NBNSCZKJGMFY7G1ZQG99P
 'SP273SWYJNKJNS07QAJ6W3Q888CPKNTP00GRZCGVH
 'SP23GPBC9JG4ZWYVW91QQZVVJGAY9WBE1AVHW432S
 'SP32EHA96EQEJRVCNJ3WFFZAS55TV1CST934EQ7AS
 'SP1779T6BNQ853MTF39HHJAR5E7WVJQZEBGZ2B9VB
 'SP187F5A0T1C0CXQSAK2C8SM3HVVVAWEYM70RPD2F
 'SP38BAX7M0G2P0W9YTDED1QJE6QTRKZFKB3KYZSE2
 'SPGG5GP5ADPHN69905ABB34V4FKHSJ3YPC6ECKG1
 'SP3REC94393AVDRVC2VJSWSAXMZNPTXXP9YG8BQ81
 'SPARR852YJXKJQATJ1C9ET7CSNSFEA4HPMS4MW6R
 'SP3WZGDSD8PVNP4QYD1YJYK4T6B76JGTK8PHGMMZ6
 'SPG1Z0X1E83CZC8KFVC9QC9FGEE28YSJTWVNXPJY
 'SPT9T4E901QTPMCYJPS0BHK8J730H6MWT4NC7TX6
 'SP370FAM2AJ0RMBK4VKDQAC9R0SZS71DNT3D3HH2E
 'SP25MTG5KRGZP0EEYRQT6N762XG5JSF5WCXR968RZ
 'SP39WZZCZKJ1KQJ190GRDS8BVBZ8N86WASZNZZT08
 'SP2RVAE6ZMX06AP71SGEJTWZNKFERCTQH9974DPBD
 'SP203RE3BPGHG4DZ6ZP8BB2JJ0DFZY49RT6WBMYK3
 'SP88S5ECRMBQXRM0A7HJTJXCPEE9P5QXSBPCWYXN
 'SP1DC9TAV0P22SHK2DN2PAQ8A8PZXKKFWR6NG4G1K
 'SP284VB0B1MXERVZ1BSSWJ8VCXVBWW18FC2D9609W
 'SP1353CTXA3DHFWFTQPEHCKBKDMYTJQWWK03RFFFN
 'SP29VKSM1YZZ4PCE377GP9EQVME3M5PC230951QF
 'SP33R7PQK79C9Q6YP1FP20BZPEDT3Y0T4YHWB95A7
 'SP67NSCB8ZZMRQ7Z3V3K5VZNW9MMTJSQPAES3DDM
 'SP1M8NDH13T3ZH1ZTVP3WPFD4NP53JA0SY30NMD97
 'SP30MT9XRVBHRS0CKMKBBK7XDRDD0C0FXX8XR3S85
 'SPV8RHBQPFJCQ5JSYBGA0EHY2XXCZYHQY13DHMZ2
 'SP13SN3HMHM9DRA78SCPFGW2WWH1E5GD6RD35AMJ7
 'SPKBQDEW9VX33SZC4NT1CV94WACXTDHEKX65Y16X
 'SP1BQZ7QBWMRCYYFB51F5SGH2NJJ33R3BJQA71AQ0
 'SPY9P8SPCVPETSY0F0BY1CX5YN20ZQFHE8SAM7VE
 'SP3B2TE0N9J98YG74PCHAS5P4WDZVFQ04YMAJ8A6S
 'SP24TTFCM1PJS3FE3X1TNX28GTRQMM7EXMM66KN08
 'SP3TYWNTFYN0WNE785MHJ77G0739G2QT68GQA7XB2
 'SP21VS4BGVTBQCKZDXA3XCRKEFEPCXCWFNGX0668R
 'SP2KHVPBF1TQAWAA4P5AV8996QWAYV349C4QZA4D8
 'SP31PM95CQ4HZ4CTJ9GBXMK8N83WYCRZTDT286GG4
 'SP2YC35P1G5XBZC7QW9KQCZDAA6KARHYJC7GY4XS6
 'SP3Q3AZ3FRJTE8BXBBS401Z6K33V6XCY2K8VX1MNF
 'SP4VRCKMYHA5X4WNN2QNNHFCRD44DHVQBQ3DB1Z1
 'SPBSMN21JTN1752GG6Y7J66WV3XSN90S2EX3VJPQ
 'SP103TH08C0DXTRC4SGVRFJAC7WRFFYAHD61PHK2K
 'SP2AAR5QYWYBG8SB1KZTHTKT56ER8TR7398EHNZ48
 'SP20FX74Y6D3QFMGYEF5G139PNDGCY5W8KE351KQ7
 'SP1FF886MNJBA8H80HE62ZT38VVVYA20F4VE92VY3
 'SP32GRPF16YX6NXV8GKD8NANJW47QY08CVTR7XJS1
 'SP2WS28J7A725HPCGPFBG9F0973JQTQ8Z0FX3GDJP
 'SP3XVD2WP8ZKNATT7RTNAA8KMYQS60ZZBVJHTBFTS
 'SP1AQX89NTDCX261RPAXF28P35JEXD2AG0AX8VXJ9
 'SP1ARB46YBPMG0BR95H7NRYWNQDZ7WVD248XGJ5NZ
 'SP2QNYQVE7WJ1398ZR3DQ18K6DPRDEJRMQHBE7H7F
 'SP2CPZMMHNA92RDK1CX3GRMFYVYZYWSKRWYQFKYV5
 'SP375WP6WN5H5R1AQM3C39EZY39RF283BGAJX9E7W
 'SP1DNDZ9B3V9P3CZMV15MPD71VDPA4VYEKM1XCP2A
 'SPH41D7CRG2Y1Y8T2HXEKM7KMATFCCX7RKMTCG0C
 'SP39RX0A0Y53RRQPJ70HGQZY6JJ25ATXE15AK8KVQ
 'SP35MRN2TNF82TX19WEG0C832J0ED8ENEBR3VBR2R
 'SP03M23WXVQ4416T4AJKDHY64R311E9NZYF2QD8J
 'SP16P22FR1X88MRP52F4W6QED4W4GBS72Z1VP33DR
 'SP1G3EE5Z9HHQDDEZ10SEAVJZ9F814JD8DEV1BBDH
 'SP1PDYH36R7YY5HRVG17DRYJVKQMF0C132TKSW1RK
 'SPCYN7662K6R761J6GSB7G8EHT5DTAYRXK43Z9ZP
 'SP0A63S7S9GDBQSMN7ZMBBSV3ZJ34YTTPGE3GKRP
 'SP1GA276Y60T9E8EQWTFJYRTY63S3V8GC251KXKCY
 'SP1B387XD26P47M27VCSNGXZMK82H9R7ZXP6XVPZR
 'SP3713YYS5WSPP5MD9AVC0TM5H6YN9HFB9A75NKS1
 'SP37WMMM9ZY5KZWR2PSB58VYB12X0T56G15JFQH32
 'SP38S3VFTM4AJFCWMVCJFFNKFNZ325ZA1QYPQK4BK
 'SP3KV5DT37GBG6S623Y8NAHMWS75TXD0NDASZ1HCJ
 'SP3PB020S015AJ9ZGENJAY3RMX8M0VXBYWVM023NW
 'SP1KS7EZ5STB1JC65PXMWVBCHVGHHQPA78HMCGBKH
 'SPD0XJQ031PD1QV6MS2GDMVXWRKFRJQ1XKGQ2XP8
 'SP3Z6XCAN6F7NM4BE7BT880PV9YTDCHKTP7BJGDKK
 'SP1EM9A5C61ME8X731NKN82HQGEEY61K44YG9QDRG
 'SPP8YSK51944MKTR9WMBSWVNW036FEDJB25Y4J0B
 'SP5WDDZXVD8SBKZVMRB3ZVGYTJM5586N1PC74SH4
 'SP1B2DNGZ20JYS7BYWTBDD5DKGK8S4TZGYWG0BMDB
 'SP2KZ24AM4X9HGTG8314MS4VSY1CVAFH0G1KBZZ1D
 'SP3YYW67N57TPCWQGQXFA6HNH5XE1DJ7M1SR00AQJ
 'SP247A8K42S2YQW314MWWKV8N6FVPN8TMPZX0VEW5
 'SP3R5MTB2C4RQ44P1KFYAJSN4077A073ZCZMAFQRN
 'SPPS9NX5V0HJZD7NTBXC1X534A9PEMWY0RW2HMKE
 'SP3J99AYSVWZ72H02TM1THEGNYR6YZ5QXX3WJ4M8B
 'SP270DJFTAXQVP6J7BS0572RTWRX07BCPKFNDTZMB
 'SP1J9A32HBNYWXGSQF92GKA8B4ZFHKY1HHA49V7F1
 'SP3V6FM3KV9BFQBEE1T8XXNKCE01H8QK13VA5BCAZ
 'SP19743R820G3WF8NQF8XEN9R54HKCP1DE9GSQDDA
 'SP6WVRDCHZYYXVC97PY7CFYEXQ4WGCP149HQHA8T
 'SPCPERM6DNVD9MF7FD82YGS3ZTD8W4ECS2A2NAKH
 'SP289BGYY1TZ7HZASZHCG50XVDF8QRFJQBJNY481Y
 'SP6Y1VKBVY7VNZEPJVW88PYFTTSMKEBFQ6CKBTBY
 'SP1Z225Q809R1HDQD8V48R4Z02EGJJMXA0X8JRZX2
 'SP2NY0HDVZ83NXVDWNB8DEZJC498XZFZBYBAR6BBW
 'SP174RPDG6H060VNNYAMRFEJSDX4Z87RPYTV3899E
 'SP2QAH2E410KFCP8QK45BMCENB333NY6DVA4PYRG7
 'SP13K4X973GG1X37DSEX38NKPAS024WHCCPF7MW8J
 'SP2J2NR8VMY1J5KM8HCZ2NC7GMY2J5VKYP23A7J2W
 'SP2EGH5MSX6VR5BMKZ0K3MDKKH7RTM62WRHRQ2WGA
 'SP305ZQXS1XY8Z1ZNKJ80PT4ZRYZCJJTHJ5C771DG
 'SP3V2EVXM71BZ25JA935VHYRS1N1SYVGGYKKV5GER
 'SP3J02HWA553H9EX4ZV30CCYHZQ2ZXMJ079YFGZ3T
 'SP34Z09K23W7FVY4K6XQKQPYDNTE8YQSZ8JX9X4YG
 'SP3S5JQKRS9N98AX195B4235MX4SMTJXVT2YTC8GK
 'SP3BRDQW4HFA9ECNZFVT5XKPFVSZTA2ZX5ET1N7VY
 'SP3EY0AZAMD9H5QR6ZPNZBYBDGXXDFMWDG07791H1
 'SP3ANSGM3J116RTWYMZ5KDHJ9RBF3P2330H8RQQDR
 'SP3ZH7JQ5AT4JV2T6MAAVKMY5HX8CK88XV6N6HC29
 'SPACW7T4XKF8T5VAEXQSPR7144MZE9V9ANQVQHNP
 'SPQPRTN8ZMWZF2G7KBVS4H7AM9D2DWBEFF0FM2G0
 'SPEA33WSEQK01FAEP4SMKF183APPQ2GE50VYV1HG
 'SP33506QDHEW6NK09CCG67NYNXKF8EFQNDEW2GXQB
 'SP3N2RARPZ4FZP7JHJTXF30NAHQ0T9EYG4QZG4DJ5
 'SP1T2FTMXH9QFBKBG45XCKPT0A36SV2KEM88XERWJ
 'SP3TMZ9J6ET3ZKZQ5N3G3TZJZQVV1RX34VCQG727B
 'SP2ST65HVW8V9Q7B05KS3EKXY8J9A1JRJ5MVT7V7N
 'SP11SC4T0AVAWM2T2VKTXA501VBVHGK500KMK9S5
 'SP33BQGRMFZMECTC9Z3KYAA2RSK7M8ZGM9J5XT294
 'SP181XGM4E5P4MR03J572B2HVP6WJ6R6BNGZXNYSH
 'SP3S1NBVZQBVK2DAKTS69K31H0HG5SRGVW6QXF4RC
 'SP2NN797S3H599SWS7MAK50TH7MH2KB7144WJ3823
 'SP2145N7YM7X8D68WWC5ACW00QF5G85FM1YGCKY1B
 'SP108PFJNH8ZF0YNH8RDERYTZZW5B135RFYBKCHA3
 'SPJJBWKHNF52BZGD9VQDV2Q4F78G6KC22P49TV3X
 'SPYEEJKTXMCZ6QKQYJR3WR924FE8SAZDTRX5DCF1
 'SP182NQ9P14WCTM373JJ11TXA969PR0W4T173KJB0
 'SP35Q63GH5CYG639VZVCXP2M7PHGDAR20ZXJK4DWX
 'SP15BQKNFCSB90V0BY3HNNMTT0J454D5Y7KNCFNC5
 'SP3A3TTEBDG34WN8AAAF4P5JB9C0ETWPNGGTPPDEV
 'SP2ADW332S32T4PGRNJ5JRQZ2DECS11HDY1GGPZPK
 'SPRXA4K7C0CS0DYRC85M03JFGVBK7WX9BB83BV0Z
 'SP1X0M0CE2J5XZ8A7DGTKHWZQMN5ZFRP7H5ZJJ97B
 'SP2HA2B4YYMJ0DMN7AXMAY3JGTMW37KV355D2DTE3
 'SP2NERP6DEN78WNTGJMJCHAWSVTNARR55ZXH2PR5J
 'SP2VE2SB8VJES300N97GTWYE25PVXN1Q3CSPC1CX4
 'SP4W8N4CPJDW7955C2TZJT1ZCA1G9PYD3EEQHQ5R
 'SPC759JQKPRM7GR5M053BKQ2NEZD8K6SA8Q2WXE9
 'SP17NZTB4MZ4EWAC2Z8K4EG3NVKZYEAVCW607R63W
 'SP3GD3WDCVFHZSCXQ47NA4QQPNKB80PZS776K6FS1
 'SPM5BVEBYCN2Z1AR2E06A69HF1W70G7V5GZFDNPR
 'SPBRH0E6Y2J1YHJWT38W6XAQC2YQDG4NMH57BHC3
 'SPZYVAHQ0ET84QTVC7DKSZY2J4FV9217KAWNVYEH
 'SP38K9RHDW3KXWCB4W2CQX9BMKKKW6P87CPGM2A4J
 'SP31MWX5JR4NYNNGWBFFJJC9A7ZF825A53PJJDBS7
 'SP10X5JQ38APVZSCM8067MJ76987A5EC035Y8BWZK
 'SP11J5D1S2TDBCG2Y5WD9ENNDEG9QEKN2RNX0H1KZ
 'SP16G10DPJK5F0X3JEDG71J64ACAYZ637PVK745HM
 'SP19EC75DBV7BXMEHGW7XFM2G4NM5R8Y31T06BJK5
 'SP19VW60DGWNH2JPZYYGYVY15ZN56A89SH16ZQA5N
 'SP1K33Y659SJNFPVKN1RVKDCZRKDHQQXM5BYA9X3R
 'SP1P6D5YNBWJG4D0SGQAE4F1BMD7TM2QJ0DKJC4WV
 'SP1T8NWHGM5HYSC0JEHYW4VQSM4CWCCNN47HQBZRT
 'SP1VFTXPFH4S8T99NHWQBJ8BECKZFQ3YFXRN4NJY8
 'SP1W577DNF1JZJ6MXC4CTT7675KBNBS8XNSR33R1S
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

