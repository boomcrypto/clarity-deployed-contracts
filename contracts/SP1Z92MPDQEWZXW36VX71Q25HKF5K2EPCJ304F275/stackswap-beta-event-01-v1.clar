
(define-constant ERR_NOT_INVESTER u1001)
(define-constant ERR_NOT_AUTHORIZED u1002)

(define-constant EVENT_START u44744)
(define-constant LOCKUP_BLOCK_1 u97304)
(define-constant LOCKUP_BLOCK_2 u149864)

(define-data-var contract-owner principal tx-sender)

(define-map investers
  principal
  {
    stsw_reward : uint,
    event1_1_claimed : bool,
    event1_2_claimed : bool,
    event1_3_claimed : bool
  }
)

(define-read-only (get-user-rewards (user principal))
  (map-get? investers user)
)

(define-public (claim-reward)
  (let (
      (user_data (unwrap! (map-get? investers tx-sender) (err ERR_NOT_INVESTER)))
      (user tx-sender)
    )
    (if (and (not (get event1_1_claimed user_data)) (< EVENT_START block-height ))
      (begin 
        (try! (as-contract (contract-call? .stsw-token-v4a transfer (get stsw_reward user_data) tx-sender user none)))
        (map-set investers user (merge user_data {event1_1_claimed : true}))
      )
      false
    )
    (if (and (not (get event1_2_claimed user_data)) (< LOCKUP_BLOCK_1 block-height ))
      (begin 
        (try! (as-contract (contract-call? .stsw-token-v4a transfer (get stsw_reward user_data) tx-sender user none)))
        (map-set investers user (merge (unwrap-panic (map-get? investers tx-sender)) {event1_2_claimed : true}))
      )
      false
    )
    (if (and (not (get event1_3_claimed user_data)) (< LOCKUP_BLOCK_2 block-height ))
      (begin 
        (try! (as-contract (contract-call? .stsw-token-v4a transfer (get stsw_reward user_data) tx-sender user none)))
        (map-set investers user (merge (unwrap-panic (map-get? investers tx-sender)) {event1_3_claimed : true}))
      )
      false
    )
    (ok true)
  )
)

(define-public (emergency-withdraw)
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR_NOT_AUTHORIZED))
    (as-contract (contract-call? .stsw-token-v4a transfer (unwrap-panic (contract-call? .stsw-token-v4a get-balance (as-contract tx-sender))) tx-sender (var-get contract-owner) none))
  )
)

(try! (contract-call? .stsw-token-v4a transfer (* u1016926400000 u3) tx-sender (as-contract tx-sender) none))

(begin
  (map-set investers
    'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275    {
      stsw_reward : u113976909,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPDP8YK19CE3G3J2PGCRWXK770VQC8P5GC341JZM    {
      stsw_reward : u267629615525,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPRSJ4CKZ7QKV70ZN42X265DDVCGRTKFRQ1TADQB    {
      stsw_reward : u155052106735,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPR8ZXFPMW6CGWQVTKM3BSZYGRZ3JDHV61CCVRXN    {
      stsw_reward : u91793281180,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPJ2VG1VQHTWSS7D7MPYKGPM8CBCVSVH53D6WDBR    {
      stsw_reward : u70350654235,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP1HQJ977TNX4JNPP1FPFB9FYX6SBFJCQDGP7KHYT    {
      stsw_reward : u51569976089,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP3M0Z1ZFCW7P3VXYT1ACRHE4GV7926SYZQ7ZBV03    {
      stsw_reward : u48917252014,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP3Q3Y5E2S782ZWCQNQM6S66FCBVB4SS764RMV6KF    {
      stsw_reward : u48551176146,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP2QM2TZP4DD8KP2MX6C5TA5P82S3KXZM9NV267RN    {
      stsw_reward : u41253934371,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP1420SJVGARGC631S7NSDJJHX85ZZXD6Q3CF13K6    {
      stsw_reward : u38840940916,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPA7KHZWAV9HZWA6T8VC242D23VDK521M61YGEMD    {
      stsw_reward : u27329457052,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP2WX131T97YTERRR12WEQD5KHD6M97SQJC37NXBJ    {
      stsw_reward : u18533261199,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP1YR8XPY3JJZXQ91MMFTE1FT7RA7DF6NAWMQ2C84    {
      stsw_reward : u16514511718,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP3ZJPXCGDDRZSJNVEH013T35SBTKKTQHF2RDG6M5    {
      stsw_reward : u14730757994,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP1W8C25TZCXDQTAR7MZQPSNF8C73274DCNT2NWJZ    {
      stsw_reward : u12384067051,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP2D0ZNGY848WF4X3G56ZF28287V4EQNTQ2D6C0D0    {
      stsw_reward : u11349785622,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP1J74SH0NQ5PCP519A8GTF4BJNPT7K40EM1YY78N    {
      stsw_reward : u10946129094,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP1S22NM6QQM12D5SZM6GJBNQPGDQ45F3ZNQKE6ER    {
      stsw_reward : u8418966152,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP2RXEA3MZ8NKWNN194GQWSETKF5004CB4PTD2XWW    {
      stsw_reward : u8160372823,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP3RPMFZMJQ4ZC04Q42ZFWP1C64E6V6WHA68N4DEQ    {
      stsw_reward : u7993856234,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPKVB1PBQF8909VKRBXAZCP526RK1GV110JSN6WQ    {
      stsw_reward : u7876031432,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP16Q5ZHRZMGBJCASF9MCW4YEMDSYXK4DJHFWBB66    {
      stsw_reward : u7563174425,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP1FXCKY6E03H7HYKWX8Z0DGJ54YDK5CQH1EDSAJM    {
      stsw_reward : u6984075642,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP2FFJ305NSDQ461BMFSCF16MCDSNT2K69CRJKR8X    {
      stsw_reward : u4835218768,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP129EV7GZZY9GZZ4RBT48CXRJF2SWQGXVTY35MYK    {
      stsw_reward : u4198839732,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP31A0B5K60KHWM3S3JD0B47TG3R43PT1KRV7V53B    {
      stsw_reward : u3398011132,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP1SA9ZTHB8QWNWJAYX54RZKA1EGB3R6YZDN4RWNJ    {
      stsw_reward : u3297961661,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPFPMC99PMNBJT5VV9X5S134GJFG421XXYB4JS9H    {
      stsw_reward : u2907077684,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP20V49Y7JVMASMTC9G4B01E94PM2FK5130TD0TFA    {
      stsw_reward : u2362475824,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP335ZC3W6M308ZKTSCCBMR54GWA20RSXCKJPZC59    {
      stsw_reward : u1853788605,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPBDCE0KCWY56SX6XE7MB6DVVETABYM2WRDK6PCB    {
      stsw_reward : u1724963857,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP2TZE09GHARKG0B8NTT9X77QXBTQPQ2J1579T0D8    {
      stsw_reward : u1480793106,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP2BZZR5RW68JRPA4FGXDBVQ69K6ECEST4F5VH0H6    {
      stsw_reward : u1384281210,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP30A0CG3P0N57Q1C9170C332CWBAYNAVY9DYMEW5    {
      stsw_reward : u1133218974,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP39W9M4HFGD1AF5939RECC39HMT5EVGEMQ9K390G    {
      stsw_reward : u1068752671,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275    {
      stsw_reward : u1055341445,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP3DEN0AZXRZV9ZBMQ7NB65V9NV4Y9TMF87NNP4RF    {
      stsw_reward : u1045259574,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP19Z1SDK7E1S54041NV70165TP1GD1YTHVYC3YQW    {
      stsw_reward : u965823661,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP1TXGE9FX8JG75QXGADJKSDQFENTVAMJ5JM6YD5G    {
      stsw_reward : u957522577,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP2DY125D01W1B3Z8HBGQFM9SAERG94A5RPMYEKHK    {
      stsw_reward : u867629099,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP1YNFAAGY02F784AAR10TW3AQPEK4Y74S4RADD12    {
      stsw_reward : u800757497,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP9VZH3MXPPGRRN11GPYMSC8R97N534AWW2ZSZ1J    {
      stsw_reward : u796160505,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP3GT6YMNTGNZ50RBFAPR5WWJMQ2XKJCJAY6KQTFD    {
      stsw_reward : u674643321,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP3824858RSZMHG48S829SMJ3K00J81QM7TKSDJTR    {
      stsw_reward : u525921150,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP17R69J3Z3Y1P24WFWWWAE3PTV8S84BBBRWH1T9W    {
      stsw_reward : u499772728,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP2MQS5MFYPAD05RD44HPNY729CENXDWEX1YFP7CA    {
      stsw_reward : u469333125,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP2V4GKQ28G0J1640870FNJWQ5F7WCJMFKT16X1TQ    {
      stsw_reward : u404294151,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP387AWC5F23X02DJSEAQE2XGNY5NS8W0SPJB3TD9    {
      stsw_reward : u322837483,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP1B9NJDMFPPZ6NEPJHDPFQEWQS2S7HZNAV3RN547    {
      stsw_reward : u301113992,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP3J0Z8YSJD20TGEBE6M992CWFDG18VB0PR599VY9    {
      stsw_reward : u281779029,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP3J271TZ9ECGSECNRTQRZVJE2KPS7A9ZZMTBTS35    {
      stsw_reward : u267748677,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPHYYF20CF09CNMY1JN4Q6GPDRT5CECEFVX3JG7G    {
      stsw_reward : u262643604,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPESYQ0AXGNVFS3WC9DG3A47QCTBN71FWAGE9YMW    {
      stsw_reward : u236854861,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPPF3WW61SPVQ0CCPP45HZDS2Y1YN3HDVE2591NX    {
      stsw_reward : u230752594,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP172ZXH6NM1C47HA60APXRFMKFFHS9MFMEM7XT0G    {
      stsw_reward : u226494138,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP2QE3SKKZAY68Z3KN4TTJN41BVE3B5QVJMNKJAZB    {
      stsw_reward : u223809889,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP158V6RZEA7N9WQDYZMQZNSXJPTSYJWAGH1N8AYA    {
      stsw_reward : u181840489,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP322C73BSZGPEFNMND6XQQ53Y6QA3XEG0CTSY1WW    {
      stsw_reward : u180788321,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP3QS9C7EY35ZF2RRF3Z7WKQD72ZX2A2MMQ3SJVWG    {
      stsw_reward : u178938210,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP31DFRJ0QZ07AK7JHH5P47KNRETMV0W564Y8VB2C    {
      stsw_reward : u168713762,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP3V4HYX57EEFXX5N3JSJXY4HE1QZPCRGVT8WB24E    {
      stsw_reward : u145359731,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPT977DSCQVH1TZB4RMB3K4C5MKHB3R1KJPR0CAX    {
      stsw_reward : u138822775,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP19WSDJWTH4CW3YG554XS5CAXJJGAN83P8CFZ4K1    {
      stsw_reward : u132122231,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP10TRDNW4VVW85Y2F17X5EB1K90DD0XKG3WTDJMM    {
      stsw_reward : u113976909,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPB6AB1RNNY6CP0SGSHKNY1F0DB0ZDYA7R7KM97Q    {
      stsw_reward : u113284746,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP3PSPXSQDBHS0C0FD0EKSF7XZW2YNA4V7XGHNA83    {
      stsw_reward : u99603342,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP1W4Z0Z0WA7N92CTPH61BGWNP806KQXKZ4F1MN5W    {
      stsw_reward : u98735603,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP3D6PYDCVCFXM1ZH5Y3050MNK90DSVTMWSDK46TJ    {
      stsw_reward : u97971266,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP3AJCGHV8WG7WNVWH9E6F2W966C1CCRTFHW4DJHZ    {
      stsw_reward : u94007061,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP1S2SEP2MCCJZ0N07FWWS8NKK43YNDZ0WB4QB9RK    {
      stsw_reward : u82919751,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP36MCQHXPP0DZ2KPC1KEY6ERC8GKB6QVCAK0PQYG    {
      stsw_reward : u79807162,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP2MMQN4BVGG9TYBTV0Y5WFAHRQPVMJMY8NB88QW7    {
      stsw_reward : u72103604,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP2DZEW2X26NHWFTAX75PKREYHDVBF1MMXES9WCNS    {
      stsw_reward : u70035149,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP1DMFJZ886CAHZB26ZVXAFHFKRHHHK299JR7TZ4A    {
      stsw_reward : u65209439,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPBM4PH31HA499RC0A1HJRANBW6M7T1Q4W2E4S80    {
      stsw_reward : u63735941,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP2NQDTN4KNFPSRJB35Y2E0FHH6HBF9YTJQ3002XG    {
      stsw_reward : u59788057,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP2KBCGRHACXZ8B3ZW1W3W2A8WHYTR861HRR6036N    {
      stsw_reward : u59059768,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP1ZN8GF3DY8CGS73DXKJ4B37HDDJSC93VSGPZWEQ    {
      stsw_reward : u56449242,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP1CC4F8MVMFKJ3PVMGXJZEC2ZCPV6MMGVF921Y3M    {
      stsw_reward : u53967993,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP39H4H8TDZGSHBK6ST6J25TE050EZBC3M7YJC1E1    {
      stsw_reward : u45620416,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPSF2JPRM3WENT2NKAK7BEG1R7SFVVZRX4XK557D    {
      stsw_reward : u45063180,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP1GMSC56NFS86ASM2DHD3WTA1BWHEF3K7067BQ5W    {
      stsw_reward : u42003777,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPXEXQ0ZESWZK9ZK4S5KEZ2EHS48NZ4F241X2FZS    {
      stsw_reward : u41967413,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP2GHPX871GG50BE72CNFZZ0FJM5JQ5GPDKM4T2RC    {
      stsw_reward : u40412213,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP3Y4DWNK7PG9YM46SMXA870JX5K9CQ6DTHKMAPMJ    {
      stsw_reward : u39617628,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPYF9PC72BSWS0DGA33FR24GCG81MG1Z96463H68    {
      stsw_reward : u38280942,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP1D0T0HNWEVS9D9SDDC0ST0PYA8FQMS566ESWFEX    {
      stsw_reward : u35713534,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP1NGMS9Z48PRXFAG2MKBSP0PWERF07C0KV9SPJ66    {
      stsw_reward : u30167559,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP28NCWFZBT0SR2J9BZ4348J86Q0Z3H1FDWZYB6FN    {
      stsw_reward : u29444216,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP2FC065VDS4D01D3FMJQXPSTDCBKB7R793FXJAG9    {
      stsw_reward : u28687598,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPGGR1N66VR9E8EGT09GJDA9KGH7CQ6YBQK5S5ZV    {
      stsw_reward : u26069493,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPF60G7DPMCFNMPB1HY6MK8PPWAERERTX6P0GVFF    {
      stsw_reward : u24755077,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPCP6QYQG399SWCF2TVAFHVHN302TB3ABRTWHPEH    {
      stsw_reward : u23385086,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP6YAN6MV4SS2YJRMA3HQ2PYVQGVHV4W08D8HZ3V    {
      stsw_reward : u21632342,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP3YSSX1E167TYX2T55QH83DYW5F45BX3YT8M6KCT    {
      stsw_reward : u16777529,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP37H540P5WSY153W5CKAX000W8XH13RAPQ1JC57R    {
      stsw_reward : u15692505,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP9QXM38XZX8744Z9DFWX1EG92ENF0NKPNMF24TH    {
      stsw_reward : u15650217,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP2Q6V9SAWDCJD0ZG9BQZJH5MRQ8F4YGDSSHQCZ8G    {
      stsw_reward : u13818631,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP3Q1CZZNXM95DZVTB7VBND4FW4B2E0YXM2KJ7FAH    {
      stsw_reward : u12985939,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPA5TQXK1FEEV8SA0S6G2PPZCWKDQQCSRG0N5BM4    {
      stsw_reward : u12558462,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP1TCA7QER9J9NKCKBB78K48TADDFC2GXYM3QQV3X    {
      stsw_reward : u11613108,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP3VQMFJTCW7YE7SYRWD3PWRJJ42G87BMJ4DMNJC6    {
      stsw_reward : u11551880,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP913RJ34V2X3YA2PTNXFVAZF9Z1SH8M1FH8X7CH    {
      stsw_reward : u11162381,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP3N6EZPTSX8ZV2RGPY9NR9A8CA0QET39CY978H5E    {
      stsw_reward : u8585192,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP2A21HTEWS8ZNW2NCBV6QPF9HS2PEJ9VR2CFN3WZ    {
      stsw_reward : u8431619,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP2YHK1RMVYP3RB43VQY72TQNXKFNJ3J1MHKS5ZF6    {
      stsw_reward : u7861311,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP1DRNMHNBAKSKV6QYBSEY503WMEHPW9RMM5H05FP    {
      stsw_reward : u6743237,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP3ZQ4BX9VAF6FE8MCAN99TZYG7JQDP1TYFMDRB39    {
      stsw_reward : u5095257,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPYPHBSBFKYSNHF9KSZRPN3VM610APB36HT22ZPV    {
      stsw_reward : u4581852,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPVG7C6FWXDDECA0HJ3FC9KJY3PKK220W3REDP60    {
      stsw_reward : u4537709,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP2HB4FDPS2X6FRY027D6SJWDTVETW77KYNVN0P69    {
      stsw_reward : u4520828,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP13GGXX86NM03G6TG8GF7KCXHAD54C9ZYK7B7HWV    {
      stsw_reward : u4086949,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP2GFJXDVAARK7JF6T5SZJGVW8DR7TA65KXPHAKX2    {
      stsw_reward : u3421192,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPBGQHZQR9M8YM2JAMB735ET495T2QKEPY9EXK4B    {
      stsw_reward : u3354928,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP3FS08MTB57D9BFEX4GMP2PNE0MFBS9FZRMBKRZ4    {
      stsw_reward : u3230812,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP1YQFZTZZ42SY22H831HE5REGVJ43XEMQ0C3TR1C    {
      stsw_reward : u3025825,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP2JJNGXG74XZ13GGWK3XZGSBCYC9H7DSKVDMWMW1    {
      stsw_reward : u2859589,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP23DAB333A5CPFXNK13E5YMX1DZJ07112QNZEBCF    {
      stsw_reward : u2755009,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP2EVH80XBHCSJFQFQ1KKK9NE42Z5ZZJKGMPNW0C9    {
      stsw_reward : u1391584,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP8D8D98NJK6GRMDFH4V5R3Y7H4YC2DZV8J89C44    {
      stsw_reward : u1355741,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPJ51JPKQ1CYTA430GHQJWR7QFZVGSTS0T7CAZGG    {
      stsw_reward : u1338661,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP20E0RC1NWFVD6A2QC8Z4CTWK7X5FKFCB6M6P6W4    {
      stsw_reward : u959713,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPXHH8N45951BY16FJ4DBVBM34GYS80PXKGX6GCD    {
      stsw_reward : u404505,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP272Z7XM8ME1V0ZW2P180PJFF1WM645545468R39    {
      stsw_reward : u384622,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP3X244SHTGBFDE437E1MSBQQQ4Q0ZQM7NJXKFDJ9    {
      stsw_reward : u225414,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPN9JGFGXFJZD7AM5VF2S7BRATNCQYVHVWG3087B    {
      stsw_reward : u116798,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
)
