
;; /Users/owner/bob-fix-52/contracts/fix-52.clar
(define-constant err-unauthorized (err u401))
(define-constant err-already-revealed (err u402))
(define-constant err-transfer-failed (err u403))
(define-constant err-insufficient-balance (err u404))
(define-constant err-reveal-failed (err u405))
(define-constant err-unable-to-get-random-seed (err u406))
(define-constant err-block-not-found (err u407))
(define-constant err-no-participants (err u408))

(define-constant TARGET-EPOCH u52)
(define-constant DRAW-BLOCK u208264)
(define-constant TAILLE u27)
(define-constant PARTICIPANTS 
    (list 'SP3AJC728JY0Y43E8RT6K4VDWPT265RDMXJ8M0VH0 
    'SP1EQGZT0WN75N5AMJH2C40N5GBJTEVY9E6ZY8EH3 
    'SP2AFGWN521W5PYP5R2RJ7QAJSBQAKA4HSPTKJYHX 
    'SP3K650KFSY5Y2559C56TKZNSBZ2MKVDF0PCAYE78 
    'SP1H9ZKGH940EH9V5JCHJW1XMH33ASTBTQ35W2NQ 
    'SPTETYQFT9B9CK357K88PCF52TBZQ1WP9S3AR4S3 
    'SP1W5YQQ375XGC1Q14D8GZ22MJZMR6QYG9YAYSBC 
    'SP2G8FJT1ZKJVP116PNV06W1F5WAFGC5S2RZTV8PH 
    'SPW0CHYR5S4J0DM03ACH2PH9ZHPFJ776Z1EQBPSV 
    'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK 
    'SPSQ4W56BY5XKZR8YJMXYP1CKJ64TT4CQ04GFQT8 
    'SP1REGTTRBMCV355TCW4C5V2ZC8EVA9YV58P9HY9K 
    'SP3WAAYXPC6WZNEC7SHGR36D32RJPZVXRR1BG0QSY 
    'SP218F71JZ4R2ERQDKEBGA1FKVAQNZBM3HK7W8EA7 
    'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G 
    'SPSK86Q3EP02Q5618EBPH9H4KSWDD1HDBB9SDSK8 
    'SP14FSJX1Q9EV6RA2GP2WZ3RNK6DX7057QNXC4Z9B 
    'SP2H6M5G37EDRD62J68YC4857JA14KZ5YDE6WG31W 
    'SP14W78Q821B3HQ3ED30624Z1F13X4JMFZY3N5SK4 
    'SP2PZYA27E8MRBQHQXE0JQH5CHM9JJNM00YEMC4QJ 
    'SP1MP4A2TZBX935NS93V5QP8ESG8534XARQFQPCMG 
    'SP1RB1V65A1PAAXYT8PVFFFC6T1FN9E8RQX7HMDKC 
    'SP3G3FGJ5FWYJMZZ839QS05BMXYSEHVM6NHBYFDXM 
    'SPY3VW50YQCEWD905SSBPVF55D1E502ZV24TE2M6 
    'SP2RQ0MJ95W7FTGBP321QN8ET2ZB2Y9AXRMX31FA 
    'SP68A2GDYFED1P932H1Z3J2NKP24D8WW486C6QWT 
    'SP25DP4A9QDM42KC40EXTYQPMQCT1P0R5243GWEGS))
(define-constant BOB-BONUS-AMOUNT u1000000000) 
(define-constant FAKFUN-BONUS-AMOUNT u100000000000) 
(define-constant FUNDER tx-sender)

(define-data-var winner-revealed bool false)
(define-data-var epoch-winner (optional principal) none)
(define-data-var contract-funded bool false)

(define-public (fund-contract)
    (begin
        (asserts! (not (var-get contract-funded)) err-already-revealed)
        (try! (contract-call? 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G.built-on-bitcoin-stxcity 
               transfer BOB-BONUS-AMOUNT tx-sender (as-contract tx-sender) none))
        (try! (contract-call? 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.fakfun-faktory 
               transfer FAKFUN-BONUS-AMOUNT tx-sender (as-contract tx-sender) none))
        (var-set contract-funded true)
        (print {
            event: "rafico-funded",
            funder: tx-sender,
            bob-amount: BOB-BONUS-AMOUNT,
            fakfun-amount: FAKFUN-BONUS-AMOUNT,
            epoch: TARGET-EPOCH
        })   
        (ok true)))

(define-read-only (get-rnd (block uint))
    (let (
        (vrf (buff-to-uint-be (unwrap-panic (as-max-len? (unwrap-panic (slice? (unwrap! (get-tenure-info? vrf-seed block) err-block-not-found) u16 u32)) u16))))
        (time (unwrap! (get-tenure-info? time block) err-block-not-found)))
        (ok (if is-in-mainnet (+ vrf time) vrf))))

(define-public (reveal-and-distribute)
    (begin
        (asserts! (var-get contract-funded) err-insufficient-balance)
        (asserts! (not (var-get winner-revealed)) err-already-revealed)
        (let (
            (random-number (unwrap! (get-rnd DRAW-BLOCK) err-unable-to-get-random-seed))
            (recipient-index (mod random-number TAILLE))
            (chosen-recipient (unwrap! (element-at? PARTICIPANTS recipient-index) err-no-participants)))
            
            (try! (as-contract (contract-call? 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G.built-on-bitcoin-stxcity 
                   transfer BOB-BONUS-AMOUNT (as-contract tx-sender) chosen-recipient none)))
            
            (try! (as-contract (contract-call? 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.fakfun-faktory 
                   transfer FAKFUN-BONUS-AMOUNT (as-contract tx-sender) chosen-recipient none)))
            
            (var-set winner-revealed true)
            (var-set epoch-winner (some chosen-recipient))
            
            (print {
                event: "epoch-52-winner-revealed-and-rewarded",
                epoch: TARGET-EPOCH,
                winner: chosen-recipient,
                bob-bonus: BOB-BONUS-AMOUNT,
                fakfun-bonus: FAKFUN-BONUS-AMOUNT,
                revealer: tx-sender,
                random-seed: random-number,
                recipient-index: recipient-index
            })
            
            (ok chosen-recipient))))

(define-public (fund-and-reveal)
    (begin
        (try! (fund-contract))
        (reveal-and-distribute)))

;; (begin 
;;     (try! (fund-and-reveal))
;;     (ok true))
;; hiro's post conditions are incorrect in the platform deployment
