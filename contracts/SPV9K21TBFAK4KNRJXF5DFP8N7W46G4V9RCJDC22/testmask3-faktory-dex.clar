
  ;; 6870d4c4ad372d98fd17e996f9ed9a4098cfd107282da974a0fd292e7ac5805c
  ;; aibtc.dev DAO faktory.fun DEX @version 1.0

  (impl-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1-1.faktory-dex)
  (impl-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.faktory-dex-trait-v1-1.dex-trait)
  (use-trait faktory-token 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.faktory-trait-v1.sip-010-trait) 
  
  (define-constant ERR-MARKET-CLOSED (err u1001))
  (define-constant ERR-STX-NON-POSITIVE (err u1002))
  (define-constant ERR-STX-BALANCE-TOO-LOW (err u1003))
  (define-constant ERR-FT-NON-POSITIVE (err u1004))
  (define-constant ERR-FETCHING-BUY-INFO (err u1005)) 
  (define-constant ERR-FETCHING-SELL-INFO (err u1006)) 
  (define-constant ERR-TOKEN-NOT-AUTH (err u401))
  (define-constant ERR-UNAUTHORIZED-CALLER (err u402))
  
  (define-constant FEE-RECEIVER 'SMHAVPYZ8BVD0BHBBQGY5AQVVGNQY4TNHAKGPYP)
  (define-constant G-RECEIVER 'SM3NY5HXXRNCHS1B65R78CYAC1TQ6DEMN3C0DN74S)

  (define-constant FAKTORY 'SMH8FRN30ERW1SX26NJTJCKTDR3H27NRJ6W75WQE)
  (define-constant ORIGINATOR 'SP7SX9AT5H41YGYRV8MACR1NESBYF6TRMC6P82DV)
  (define-constant DEX-TOKEN 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.testmask3-faktory)

  ;; token constants
  (define-constant TARGET_STX u5000000)
  (define-constant FAK_STX u1000000) ;; this will be 1M satoshis
  (define-constant GRAD-FEE u100000)
  
  ;; data vars
  (define-data-var open bool false)
  (define-data-var fak-ustx uint u0)
  (define-data-var ft-balance uint u0)
  (define-data-var stx-balance uint u0)
  (define-data-var premium uint u25)
  
  (define-public (buy (ft <faktory-token>) (ubtc uint))
    (begin
      (asserts! (is-eq DEX-TOKEN (contract-of ft)) ERR-TOKEN-NOT-AUTH)
      (asserts! (var-get open) ERR-MARKET-CLOSED)
      (asserts! (> ubtc u0) ERR-STX-NON-POSITIVE)
      (let (
            (in-info (unwrap! (get-in ubtc) ERR-FETCHING-BUY-INFO))
            (total-stx (get total-stx in-info))
            (total-stk (get total-stk in-info))
            (total-ft (get ft-balance in-info))
            (k (get k in-info))
            (fee (get fee in-info))
            (stx-in (get stx-in in-info))
            (new-stk (get new-stk in-info))
            (new-ft (get new-ft in-info))
            (tokens-out (get tokens-out in-info))
            (new-stx (get new-stx in-info))
            (ft-receiver tx-sender)
            )
        (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token 
                    transfer fee tx-sender FEE-RECEIVER none))
        (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token 
                    transfer stx-in tx-sender (as-contract tx-sender) none))
        (try! (as-contract (contract-call? ft transfer tokens-out tx-sender ft-receiver none)))
        (if (>= new-stx TARGET_STX)
            (let ((premium-amount (/ (* new-ft (var-get premium)) u100))
                  (amm-amount (- new-ft premium-amount))
                  (agent-amount (/ (* premium-amount u60) u100))
                  (originator-amount (- premium-amount agent-amount))
                  (amm-ustx (- new-stx GRAD-FEE))
                  (xyk-pool-uri (default-to u"https://bitflow.finance" (try! (contract-call? ft get-token-uri))))
                  (xyk-burn-amount (- (sqrti (* amm-ustx amm-amount)) u1)))
              (try! (as-contract (contract-call? ft transfer agent-amount tx-sender FAKTORY none)))
              (try! (as-contract (contract-call? ft transfer originator-amount tx-sender ORIGINATOR none)))
              (try! (as-contract 
                     (contract-call? 
                       'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 
                           create-pool 
                           'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.xyk-pool-sbtc-testmask3-v-1-1
                           'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token 
                           ft
                           amm-ustx 
                           amm-amount 
                           xyk-burn-amount 
                           u10 u40 u10 u40 
                           'SP31C60QVZKZ9CMMZX73TQ3F3ZZNS89YX2DCCFT8P xyk-pool-uri true)))
              (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token 
                            transfer GRAD-FEE tx-sender G-RECEIVER none)))
              (var-set open false)
              (var-set stx-balance u0)
              (var-set ft-balance u0)
              (print {type: "buy", ft: (contract-of ft), tokens-out: tokens-out, ustx: ubtc, premium-amount: premium-amount, amm-amount: amm-amount,
                      amm-ustx: amm-ustx,
                      stx-balance: u0, ft-balance: u0,
                      fee: fee, grad-fee: GRAD-FEE, maker: tx-sender,
                      open: false})
              (ok true))
            (begin
                (var-set stx-balance new-stx)
                (var-set ft-balance new-ft)
                (print {type: "buy", ft: (contract-of ft), tokens-out: tokens-out, ustx: ubtc, maker: tx-sender,
                        stx-balance: new-stx, ft-balance: new-ft,
                        fee: fee,
                        open: true})
            (ok true))))))
  
  (define-read-only (get-in (ubtc uint))
    (let ((total-stx (var-get stx-balance))
          (total-stk (+ total-stx (var-get fak-ustx)))
          (total-ft (var-get ft-balance))
          (k (* total-ft total-stk))
          (fee (/ (* ubtc u2) u100))
          (stx-in (- ubtc fee))
          (new-stk (+ total-stk stx-in))
          (new-ft (/ k new-stk))
          (tokens-out (- total-ft new-ft))
          (raw-to-grad (- TARGET_STX total-stx))
          (stx-to-grad (/ (* raw-to-grad u103) u100)))
      (ok {total-stx: total-stx,
           total-stk: total-stk,
           ft-balance: total-ft,
           k: k,
           fee: fee,
           stx-in: stx-in,
           new-stk: new-stk,
           new-ft: new-ft,
           tokens-out: tokens-out,
           new-stx: (+ total-stx stx-in),
           stx-to-grad: stx-to-grad
           })))
  
  (define-public (sell (ft <faktory-token>) (amount uint))
    (begin
      (asserts! (is-eq DEX-TOKEN (contract-of ft)) ERR-TOKEN-NOT-AUTH)
      (asserts! (var-get open) ERR-MARKET-CLOSED)
      (asserts! (> amount u0) ERR-FT-NON-POSITIVE)
      (let (
            (out-info (unwrap! (get-out amount) ERR-FETCHING-SELL-INFO))
            (total-stx (get total-stx out-info))
            (total-stk (get total-stk out-info))
            (total-ft (get ft-balance out-info))
            (k (get k out-info))
            (new-ft (get new-ft out-info))
            (new-stk (get new-stk out-info))
            (stx-out (get stx-out out-info))
            (fee (get fee out-info))
            (stx-to-receiver (get stx-to-receiver out-info))
            (new-stx (get new-stx out-info))
            (stx-receiver tx-sender)
            )
        (asserts! (>= total-stx stx-out) ERR-STX-BALANCE-TOO-LOW)
        (try! (contract-call? ft transfer amount tx-sender (as-contract tx-sender) none))
        (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token 
                                  transfer stx-to-receiver tx-sender stx-receiver none)))
        (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token 
                                  transfer fee tx-sender FEE-RECEIVER none)))
        (var-set stx-balance new-stx)
        (var-set ft-balance new-ft)
        (print {type: "sell", ft: (contract-of ft), amount: amount, stx-to-receiver: stx-to-receiver, maker: tx-sender,
                stx-balance: new-stx, ft-balance: new-ft,
                fee: fee,
                open: true})
        (ok true))))
  
  (define-read-only (get-out (amount uint))
    (let ((total-stx (var-get stx-balance))
          (total-stk (+ total-stx (var-get fak-ustx)))
          (total-ft (var-get ft-balance))
          (k (* total-ft total-stk))
          (new-ft (+ total-ft amount))
          (new-stk (/ k new-ft))
          (stx-out (- (- total-stk new-stk) u1))
          (fee (/ (* stx-out u2) u100))
          (stx-to-receiver (- stx-out fee)))
      (ok {
           total-stx: total-stx,
           total-stk: total-stk,
           ft-balance: total-ft,
           k: k,
           new-ft: new-ft,
           new-stk: new-stk,
           stx-out: stx-out,
           fee: fee,
           stx-to-receiver: stx-to-receiver,
           amount-in: amount,
           new-stx: (- total-stx stx-out)
           })))
  
  (define-read-only (get-open)
    (ok (var-get open)))
  
  ;; boot dex
    (begin
      (var-set fak-ustx FAK_STX)
      (var-set ft-balance u20000000000000000)
      (var-set stx-balance u0)
      (var-set open true)
        (print { 
            type: "faktory-dex-trait-v1-1", 
            dexContract: (as-contract tx-sender),
            ammReceiver: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2,
            poolName: 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.xyk-pool-sbtc-testmask3-v-1-1
       })
      (ok true))