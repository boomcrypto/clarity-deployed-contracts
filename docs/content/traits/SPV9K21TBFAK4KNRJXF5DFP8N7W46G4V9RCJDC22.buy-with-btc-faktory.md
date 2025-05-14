---
title: "Trait buy-with-btc-faktory"
draft: true
---
```
;; Faktory Fun
;; Buy with memecoins approved via Velar

(use-trait faktory-dex 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.faktory-dex-trait-v1.dex-trait) 
(use-trait faktory-token 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.faktory-trait-v1.sip-010-trait) 
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait fees-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-fees-trait_v1_0_0.univ2-fees-trait)
(use-trait pool-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-pool-trait_v1_0_0.univ2-pool-trait)

;; Constants
(define-constant ERR-NOT-OWNER (err u401))
(define-constant ERR-ALREADY-ADDED (err u402))
(define-constant ERR-INSUFFICIENT-STX-OUT (err u403))
(define-constant ERR-INVALID-DEX (err u404))
(define-constant ERR-INVALID-TOKEN (err u405))
(define-constant ERR-NOT-FOUND (err u406))
(define-constant ERR-PATH-ALREADY-EXISTS (err u407))
(define-constant ERR-NO-PATH-FOR-TOKEN (err u408))

(define-data-var contract-owner principal tx-sender)
(define-private (check-owner)
  (ok (asserts! (is-eq contract-caller (var-get contract-owner)) ERR-NOT-OWNER)))

(define-public (set-owner (new-owner principal))
  (begin
    (try! (check-owner))
    (ok (var-set contract-owner new-owner))))

(define-read-only (get-owner)
  (var-get contract-owner))

(define-public (add-token (token principal))
  (begin
    (try! (check-owner))
    (asserts! (not (is-valid-token token)) ERR-ALREADY-ADDED)
    (ok (map-set valid-tokens token true))))

(define-public (remove-token (token principal))
  (begin
    (try! (check-owner))
    (asserts! (is-valid-token token) ERR-NOT-FOUND)
    (ok (map-delete valid-tokens token))))

(define-public (add-dex (dex principal))
  (begin
    (try! (check-owner))
    (asserts! (not (is-valid-dex dex)) ERR-ALREADY-ADDED)
    (ok (map-set valid-dexes dex true))))

(define-public (remove-dex (dex principal))
  (begin
    (try! (check-owner))
    (asserts! (is-valid-dex dex) ERR-NOT-FOUND)
    (ok (map-delete valid-dexes dex))))

;; Define allowed DEXes and tokens ;; add all verified token-dexes
(define-constant BATCH-1-DEXES
 (list 
   'SP3NDZ2HXSCT0MZSJGZHYNA382DM6163KYT61524M.stx-faktory-dex
   'SPW3QV5C6TWDEJPKJB5M0JY9HPVGECM6A2Y45978.fak-faktory-dex
   'SP3MZ2SM81W87D29GZFS1R9R6NZHM8VAJ9XRHSVER.stux-faktory-dex
   'SP1R6FXP2A1Y8YATR98AGMEJHWND62H9WZAD6DB1Z.genius-ai-dao-faktory-dex
   'SP2G7NMH8FMJB1PF5M36CWV5ZMPXD3C5EWVS5WT4Y.faktory-faktory-dex
   'SPEPK2R1X08X3J45NJG1KN2NP8GW2G973E06KVJ6.fakdoge-faktory-dex
   'SP14ZYP25NW67XZQWMCDQCGH9S178JT78QJYE6K37.rapha-faktory-dex
   'SP7S3EY6FS1PJHJN6S3NV71RYQ7CKGABE5SDAT9N.supacoinstx-faktory-dex
   'SP2Z2CBMGWB9MQZAF5Z8X56KS69XRV3SJF4WKJ7J9.sweet-yamz-faktory-dex
   'SPKWB8ZX1Y9KVZX76X5JEGYQYQM1KCR5H8M2TCGN.dog-faktory-dex
   'SP2YE97WPR9C184MQ4RVM6AP1J629750Z1N48N82S.fuck-stacks-faktory-dex
   'SPCK2258XQFCF8RM4XSJ1Y7SW8E3DWX6X8S1BPV7.pepecoinstx-faktory-dex
   'SP3MABP6J5W8GXTXPTM62JQTAQPAVGGH9RYKRYZGQ.dog-to-the-moon-on-stx-faktory-dex
   'SP3FKPV0AFQWME4Q77T8E05K2977MMKRFMD1AJ7CV.stx-faktory-dex
   'SP3S2565C4DP2MGR3CMANMGYDCDA314Q258CG2R7C.geek-faktory-dex
   'SP61N7K3A9Z6M291Q89B5S2Z2BE5QYWYSRTDJM09.rapha-the-cloner-faktory-dex
   'SP3S2565C4DP2MGR3CMANMGYDCDA314Q258CG2R7C.the-ticker-is-1-faktory-dex
   'SP3H44FFW63CPHWF5RKCQK8SMJZV5DMGFZA1W71RY.qunche-faktory-dex
   'SP15WAVKQNT241YVCGQMJS777E17H9TS96M21Q5DX.the-ticker-is-2-faktory-dex
   'SP3S2565C4DP2MGR3CMANMGYDCDA314Q258CG2R7C.the-ticker-is-3-faktory-dex
   'SP3S2565C4DP2MGR3CMANMGYDCDA314Q258CG2R7C.paper-fund-faktory-dex
   'SP31ER8WTA6RM08Z0GNTY786T4PW6SYKFTNMTPRSV.slack-faktory-dex
   'SP3QF8RJ3CE59RBAHC96YS6DRSVKYADCF2730P023.phenomenon--faktory-dex
   'SP218F71JZ4R2ERQDKEBGA1FKVAQNZBM3HK7W8EA7.the-love-token-faktory-dex
   'SP218F71JZ4R2ERQDKEBGA1FKVAQNZBM3HK7W8EA7.the-peace-token-faktory-dex
   'SP2SY571GC9GSJEHSW1W7M9KF1EACC5NZ60KPRDBQ.sookie-faktory-dex
   'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB.theartist-faktory-dex
   'SP376Y7METTJAT372GYDGD225YE20A01GAV7KJFKN.mogul-faktory-dex
   'SP3E8B51MF5E28BD82FM95VDSQ71VK4KFNZX7ZK2R.frog-faktory-dex
   'SP14FSJX1Q9EV6RA2GP2WZ3RNK6DX7057QNXC4Z9B.lunacat-nebula-nibs-faktory-dex
   'SP1GR38P4KNCQRC1BD5HC97DP36W2MBZFZ4WC0NET.the-happy-captain--faktory-dex
   'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP.frankthepug-faktory-dex
 ))

(define-constant BATCH-1-TOKENS
  (list 
    'SP3NDZ2HXSCT0MZSJGZHYNA382DM6163KYT61524M.stx-faktory
    'SPW3QV5C6TWDEJPKJB5M0JY9HPVGECM6A2Y45978.fak-faktory
    'SP3MZ2SM81W87D29GZFS1R9R6NZHM8VAJ9XRHSVER.stux-faktory
    'SP1R6FXP2A1Y8YATR98AGMEJHWND62H9WZAD6DB1Z.genius-ai-dao-faktory
    'SP2G7NMH8FMJB1PF5M36CWV5ZMPXD3C5EWVS5WT4Y.faktory-faktory
    'SPEPK2R1X08X3J45NJG1KN2NP8GW2G973E06KVJ6.fakdoge-faktory
    'SP14ZYP25NW67XZQWMCDQCGH9S178JT78QJYE6K37.rapha-faktory
    'SP7S3EY6FS1PJHJN6S3NV71RYQ7CKGABE5SDAT9N.supacoinstx-faktory
    'SP2Z2CBMGWB9MQZAF5Z8X56KS69XRV3SJF4WKJ7J9.sweet-yamz-faktory
    'SPKWB8ZX1Y9KVZX76X5JEGYQYQM1KCR5H8M2TCGN.dog-faktory
    'SP2YE97WPR9C184MQ4RVM6AP1J629750Z1N48N82S.fuck-stacks-faktory
    'SPCK2258XQFCF8RM4XSJ1Y7SW8E3DWX6X8S1BPV7.pepecoinstx-faktory
    'SP3MABP6J5W8GXTXPTM62JQTAQPAVGGH9RYKRYZGQ.dog-to-the-moon-on-stx-faktory
    'SP3FKPV0AFQWME4Q77T8E05K2977MMKRFMD1AJ7CV.stx-faktory
    'SP3S2565C4DP2MGR3CMANMGYDCDA314Q258CG2R7C.geek-faktory
    'SP61N7K3A9Z6M291Q89B5S2Z2BE5QYWYSRTDJM09.rapha-the-cloner-faktory
    'SP3S2565C4DP2MGR3CMANMGYDCDA314Q258CG2R7C.the-ticker-is-1-faktory
    'SP3H44FFW63CPHWF5RKCQK8SMJZV5DMGFZA1W71RY.qunche-faktory
    'SP15WAVKQNT241YVCGQMJS777E17H9TS96M21Q5DX.the-ticker-is-2-faktory
    'SP3S2565C4DP2MGR3CMANMGYDCDA314Q258CG2R7C.the-ticker-is-3-faktory
    'SP3S2565C4DP2MGR3CMANMGYDCDA314Q258CG2R7C.paper-fund-faktory
    'SP31ER8WTA6RM08Z0GNTY786T4PW6SYKFTNMTPRSV.slack-faktory
    'SP3QF8RJ3CE59RBAHC96YS6DRSVKYADCF2730P023.phenomenon--faktory
    'SP218F71JZ4R2ERQDKEBGA1FKVAQNZBM3HK7W8EA7.the-love-token-faktory
    'SP218F71JZ4R2ERQDKEBGA1FKVAQNZBM3HK7W8EA7.the-peace-token-faktory
    'SP2SY571GC9GSJEHSW1W7M9KF1EACC5NZ60KPRDBQ.sookie-faktory
    'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB.theartist-faktory
    'SP376Y7METTJAT372GYDGD225YE20A01GAV7KJFKN.mogul-faktory
    'SP3E8B51MF5E28BD82FM95VDSQ71VK4KFNZX7ZK2R.frog-faktory
    'SP14FSJX1Q9EV6RA2GP2WZ3RNK6DX7057QNXC4Z9B.lunacat-nebula-nibs-faktory
    'SP1GR38P4KNCQRC1BD5HC97DP36W2MBZFZ4WC0NET.the-happy-captain--faktory
    'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP.frankthepug-faktory
  ))

;; Buy with memecoins approved
;; Token Constants
(define-constant SBTC-TOKEN 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)
(define-constant WSTX-TOKEN 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx)
(define-constant SHARE-FEE-TO 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to) 

(define-map token-paths 
  principal 
  {
    path-type: (string-ascii 1),  
    pool: principal,
    pool-id: uint,
    d: principal,
    e: principal,
    f: bool,
    univ2-pool: (optional principal),
    univ2-fees: (optional principal)
  }
)

(map-set token-paths SBTC-TOKEN 
  {
    path-type: "v",
    pool: 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-pool-v1_0_0-0070,
    pool-id: u21000070,
    d: SBTC-TOKEN,
    e: WSTX-TOKEN, 
    f: false,
    univ2-pool: (some 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-pool-v1_0_0-0070),
    univ2-fees: (some 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-fees-v1_0_0-0070)
  })

;; Path management functions
(define-public (add-token-path 
    (token principal)
    (path-type (string-ascii 1))
    (pool principal)
    (pool-id uint)
    (d principal)
    (e principal)
    (f bool)
    (univ2-pool (optional principal))
    (univ2-fees (optional principal)))
  (begin
    (try! (check-owner))
    (asserts! (is-none (map-get? token-paths token)) ERR-PATH-ALREADY-EXISTS)
    (ok (map-set token-paths token {
        path-type: path-type,
        pool: pool,
        pool-id: pool-id,
        d: d,
        e: e,
        f: f,
        univ2-pool: univ2-pool,
        univ2-fees: univ2-fees
    }))))

(define-public (remove-token-path (token principal))
  (begin
    (try! (check-owner))
    (ok (map-delete token-paths token))))

;; Read functions
(define-read-only (get-token-path (token principal))
  (map-get? token-paths token))

;; Helper to get path for token
(define-private (get-path (token principal))
  (match (map-get? token-paths token)
    path-data (ok (list 
      {   
        a: (get path-type path-data),  
        b: (get pool path-data),
        c: (get pool-id path-data),
        d: (get d path-data),
        e: (get e path-data),
        f: (get f path-data),
      }))
    ERR-NO-PATH-FOR-TOKEN))

(define-private (get-path-adds (token principal))
  (match (map-get? token-paths token)
    path-data (ok {
        univ2-pool: (get univ2-pool path-data),
        univ2-fees: (get univ2-fees path-data)
    })
    ERR-NO-PATH-FOR-TOKEN))

;; Maps for validation
(define-map valid-dexes principal bool)
(define-map valid-tokens principal bool)

;; Helper functions to initialize maps
(define-private (add-valid-dex (dex principal))
  (map-set valid-dexes dex true))

(define-private (add-valid-token (token principal))
  (map-set valid-tokens token true))

;; Validation functions
(define-read-only (is-valid-dex (dex principal))
  (default-to false (map-get? valid-dexes dex)))

(define-read-only (is-valid-token (token principal))
  (default-to false (map-get? valid-tokens token)))

(define-public (buy
    (token-amount uint)
    (token <ft-trait>) 
    (min-stx-out uint)
    (dex <faktory-dex>)
    (ft <faktory-token>)
    (pool <pool-trait>)
    (fees <fees-trait>))
        (let (
            (path (try! (get-path (contract-of token))))
            (adds (try! (get-path-adds (contract-of token))))
            ) 

        ;; Validate DEX and token
        (asserts! (is-valid-dex (contract-of dex)) ERR-INVALID-DEX)
        (asserts! (is-valid-token (contract-of ft)) ERR-INVALID-TOKEN)
        
        ;; Execute Velar swap
        (let ((swap-result 
            (try! (contract-call? 
                'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.path-apply_staging 
                apply
                path
                token-amount
                (some token)  
                (some WSTX-TOKEN)  ;; token2
                none none none
                (some SHARE-FEE-TO)
                (some pool) ;; univ2v2-pool-1
                none none none ;; univ2v2-pools 2-4
                (some fees) ;; univ2v2-fee-1
                none none none ;; univ2v2-fees 2-4
                none none none none ;; curve-pools 1-4
                none none none none ;; curve-fees 1-4
                none none none none ;; ststx-pools 1-4
                none none none none ;; ststx-proxies 1-4
            ))))
            
            (let ((stx-amount (get amt-out (get swap4 swap-result))))
                (asserts! (>= stx-amount min-stx-out) ERR-INSUFFICIENT-STX-OUT)
                
                ;; Use STX to buy from the provided DEX
                (try! (contract-call? 
                    dex
                    buy
                    ft
                    stx-amount))
                    
                (ok {
                    token-in: token-amount,
                    stx-amount: stx-amount
                })))))

;; Initialize maps
(begin
    (map add-valid-dex BATCH-1-DEXES)
    (map add-valid-token BATCH-1-TOKENS)
    (print "Generic DEX Proxy Contract initialized"))
```
