;; Faktory Fun
;; Buy with memecoins approved via Velar

(use-trait faktory-dex 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.faktory-dex-trait-v1.dex-trait) 
(use-trait faktory-token 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.faktory-trait-v1.sip-010-trait) 
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

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

;; Define allowed DEXes and tokens
(define-constant BATCH-1-DEXES
  (list 
    'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.bushcoin-faktory-dex 
  ))

(define-constant BATCH-1-TOKENS
  (list 
    'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.bushcoin-faktory 
  ))

;; Buy with memecoins approved
;; Token Constants
(define-constant LEO-TOKEN 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token)
(define-constant PEPE-TOKEN 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz)
(define-constant ROO-TOKEN 'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo)
(define-constant WELSH-TOKEN 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token)
(define-constant WSTX-TOKEN 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx)
(define-constant SHARE-FEE-TO 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to) 

(define-map token-paths 
  principal 
  {
    pool: principal,
    pool-id: uint
  }
)

(map-set token-paths LEO-TOKEN 
  {
    pool: 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx-leo,
    pool-id: u28,
  })

(map-set token-paths PEPE-TOKEN 
  {
    pool: 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx-pepe,
    pool-id: u11,
  })

(map-set token-paths ROO-TOKEN 
  {
    pool: 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx-roo,
    pool-id: u15,
  })

(map-set token-paths WELSH-TOKEN 
  {
    pool: 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx-welsh,
    pool-id: u27,
  })

;; Path management functions
(define-public (add-token-path 
    (token principal)
    (pool principal)
    (pool-id uint))
  (begin
    (try! (check-owner))
    (asserts! (is-none (map-get? token-paths token)) ERR-PATH-ALREADY-EXISTS)
    (ok (map-set token-paths token {
        pool: pool,
        pool-id: pool-id
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
        a: "u",  
        b: (get pool path-data),
        c: (get pool-id path-data),
        d: WSTX-TOKEN,
        e: token,
        f: false
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
    (ft <faktory-token>))
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
                none none none none ;; univ2v2-pools 1-4
                none none none none ;; univ2v2-fees 1-4
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