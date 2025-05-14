---
title: "Trait buy-with-aibtc-faktory"
draft: true
---
```
;; Faktory Fun
;; Buy with memecoins approved via Velar

(use-trait stxcity-dex 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.token-dex) 
(use-trait faktory-dex 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1-1.faktory-dex) 
(use-trait faktory-token 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.faktory-trait-v1.sip-010-trait)
(use-trait stxcity-token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait fees-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-fees-trait_v1_0_0.univ2-fees-trait)
(use-trait pool-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-pool-trait_v1_0_0.univ2-pool-trait)

;; Constants
(define-constant ERR-NOT-OWNER (err u701))
(define-constant ERR-ALREADY-ADDED (err u702))
(define-constant ERR-INSUFFICIENT-STX-OUT (err u703))
(define-constant ERR-INVALID-DEX (err u704))
(define-constant ERR-INVALID-TOKEN (err u705))
(define-constant ERR-NOT-FOUND (err u706))
(define-constant ERR-PATH-ALREADY-EXISTS (err u707))
(define-constant ERR-NO-PATH-FOR-TOKEN (err u708))

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
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.shortstx-faktory-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.inpc-faktory-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.btchc-faktory-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.ctaxdao-faktory-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.rosscoin-faktory-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.rossadv-faktory-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.nothing-faktory-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.shortdao-faktory-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.marsdao-faktory-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.sfund-faktory-dex
  'SP2KSQNEN2TYH3NSH1CRQRNZ0XAQNTZCXCG2JKHDG.swt-faktory-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.supply-faktory-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.btcdao-faktory-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aireal-faktory-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.alphadao-faktory-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.martians-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.newai-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.artdao-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.dbgov-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.fincl-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.hfit-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.repeal-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.spc2mrs-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.tcorn-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.brmovie-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.fatwtr-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.ddm-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.fastdao-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.freedom-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.glitchart-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.gldage-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.green-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.richms9-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.secdao-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.stacksdao-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.stkinc-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.twtrdao-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aiearth-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.joydao-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.absrd-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.geniusai-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.dickh-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.stxnode-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.opc-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.canex-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.randdao-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.launch-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aicity-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aifi-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aimkt-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.jbtdao-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.ptd-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.fresd-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.cvltdao-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.marsbit-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.newdao-stxcity-dex
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aavote-stxcity-dex
))

(define-constant BATCH-1-TOKENS
(list 
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.shortstx-faktory
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.inpc-faktory
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.btchc-faktory
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.ctaxdao-faktory
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.rosscoin-faktory
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.rossadv-faktory
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.nothing-faktory
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.shortdao-faktory
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.marsdao-faktory
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.sfund-faktory
  'SP2KSQNEN2TYH3NSH1CRQRNZ0XAQNTZCXCG2JKHDG.swt-faktory
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.supply-faktory
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.btcdao-faktory
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aireal-faktory
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.alphadao-faktory
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.martians-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.newai-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.artdao-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.dbgov-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.fincl-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.hfit-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.repeal-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.spc2mrs-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.tcorn-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.brmovie-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.fatwtr-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.ddm-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.fastdao-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.freedom-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.glitchart-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.gldage-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.green-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.richms9-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.secdao-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.stacksdao-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.stkinc-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.twtrdao-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aiearth-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.joydao-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.absrd-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.geniusai-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.dickh-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.stxnode-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.opc-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.canex-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.randdao-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.launch-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aicity-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aifi-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aimkt-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.jbtdao-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.ptd-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.fresd-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.cvltdao-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.marsbit-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.newdao-stxcity
  'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aavote-stxcity
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
        (let ((path (try! (get-path (contract-of token))))) 

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

(define-public (quick-buy
    (token-amount uint)
    (token <ft-trait>) 
    (min-stx-out uint)
    (dex <stxcity-dex>)
    (ft <stxcity-token>)
    (pool <pool-trait>)
    (fees <fees-trait>))
        (let ((path (try! (get-path (contract-of token))))) 

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
