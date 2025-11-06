(define-constant CONTRACT (as-contract tx-sender))

(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_NOT_INITIALIZED (err u404))
(define-constant ERR_ALREADY_INITIALIZED (err u405))
(define-constant ERR_INSUFFICIENT_AMOUNT (err u406))
(define-constant ERR_STILL_LOCKED (err u407))
(define-constant ERR_NO_DEPOSIT (err u408))
(define-constant ERR_TOO_LATE (err u409))
(define-constant ERR_CALC_AMOUNTS (err u410))

(define-constant LOCK_PERIOD u12960) 
(define-constant ENTRY_PERIOD u3024)  

(define-data-var depositor (optional principal) none)
(define-data-var creation-block uint u0)
(define-data-var initial-token-amount uint u0)
(define-data-var token-used-for-lp uint u0)
(define-data-var total-lp-tokens uint u0)

(define-map user-lp-tokens principal uint)

(define-public (initialize-pool (token-amount uint))
  (begin
    (asserts! (is-none (var-get depositor)) ERR_ALREADY_INITIALIZED)
    (asserts! (> token-amount u0) ERR_INSUFFICIENT_AMOUNT)
    
    (try! (contract-call? 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory 
           transfer token-amount tx-sender CONTRACT none))
    
    (var-set depositor (some tx-sender))
    (var-set creation-block burn-block-height)
    (var-set initial-token-amount token-amount)
    
    (print {
      type: "pool-initialized",
      depositor: tx-sender,
      token-amount: token-amount,
      ft: 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory,
      unlock-block: (+ burn-block-height LOCK_PERIOD)
    })
    
    (ok true)
  )
)

(define-public (deposit-sbtc-for-lp (lp-amount uint))
    (let (
          (amounts (unwrap! (calculate-amounts-for-lp lp-amount) ERR_CALC_AMOUNTS))
          (sbtc-needed (get sbtc-needed amounts))
          (token-needed (get token-needed amounts))
          (deposit (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token 
                                transfer sbtc-needed tx-sender CONTRACT none)))
          (lp-result (try! (as-contract (contract-call? 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory-pool 
                                add-liquidity lp-amount))))
          (lp-tokens-received (get dk lp-result))
          (current-lp (default-to u0 (map-get? user-lp-tokens tx-sender))))

    (asserts! (is-some (var-get depositor)) ERR_NOT_INITIALIZED)
    (asserts! (< burn-block-height (+ (var-get creation-block) ENTRY_PERIOD)) ERR_TOO_LATE)
    (asserts! (not (is-eq (some tx-sender) (var-get depositor))) ERR_UNAUTHORIZED) ;; else err u2 in withdrawing

      (map-set user-lp-tokens tx-sender (+ current-lp lp-tokens-received))
      (var-set total-lp-tokens (+ (var-get total-lp-tokens) lp-tokens-received))
      (var-set token-used-for-lp (+ (var-get token-used-for-lp) token-needed))
      
      (print {
        type: "community-lp-deposit",
        user: tx-sender,
        sbtc-in: sbtc-needed,
        token-used: token-needed,
        lp-tokens: lp-tokens-received,
        unlock-block: (+ (var-get creation-block) LOCK_PERIOD),
        ft: 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory
      })
      
      (ok lp-tokens-received)
    )
  )

(define-public (withdraw-lp-tokens)
  (let ((unlock-block (+ (var-get creation-block) LOCK_PERIOD))
        (user-lp (default-to u0 (map-get? user-lp-tokens tx-sender)))
        (depositor-principal (unwrap! (var-get depositor) ERR_NOT_INITIALIZED)))
    (asserts! (>= burn-block-height unlock-block) ERR_STILL_LOCKED)
    (asserts! (> user-lp u0) ERR_NO_DEPOSIT)
    
    (let ((remove-result (try! (as-contract (contract-call? 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory-pool 
                                                remove-liquidity user-lp))))
          (sbtc-received (get dx remove-result))
          (token-received (get dy remove-result))
          (user-sbtc-share (/ (* sbtc-received u60) u100))       
          (depositor-sbtc-share (- sbtc-received user-sbtc-share))
          (user-token-share (/ (* token-received u60) u100))
          (depositor-token-share (- token-received user-token-share))
          (user tx-sender)
          )
        
        (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token 
               transfer user-sbtc-share CONTRACT user none)))
        (try! (as-contract (contract-call? 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory 
               transfer user-token-share CONTRACT user none)))
        
        (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token 
               transfer depositor-sbtc-share CONTRACT depositor-principal none)))
        (try! (as-contract (contract-call? 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory 
               transfer depositor-token-share CONTRACT depositor-principal none)))
        
        (map-delete user-lp-tokens tx-sender)
        (var-set total-lp-tokens (- (var-get total-lp-tokens) user-lp))
        
        (print {
          type: "lp-withdrawal",
          user: tx-sender,
          lp-tokens: user-lp,
          user-sbtc: user-sbtc-share,
          user-token: user-token-share,
          depositor-sbtc: depositor-sbtc-share,
          depositor-token: depositor-token-share,
          ft: 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory
        })
        
        (ok user-lp)
      )
    )
  )

(define-public (withdraw-lp-tokens-depositor (user principal))
  (let ((unlock-block (+ (var-get creation-block) LOCK_PERIOD))
        (user-lp (default-to u0 (map-get? user-lp-tokens user)))
        (depositor-principal (unwrap! (var-get depositor) ERR_NOT_INITIALIZED)))
    (asserts! (is-eq tx-sender depositor-principal) ERR_UNAUTHORIZED)
    (asserts! (>= burn-block-height unlock-block) ERR_STILL_LOCKED)
    (asserts! (> user-lp u0) ERR_NO_DEPOSIT)
    
    (let ((remove-result (try! (as-contract (contract-call? 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory-pool 
                                                remove-liquidity user-lp))))
          (sbtc-received (get dx remove-result))
          (token-received (get dy remove-result))
          (user-sbtc-share (/ (* sbtc-received u60) u100))       
          (depositor-sbtc-share (- sbtc-received user-sbtc-share))
          (user-token-share (/ (* token-received u60) u100))
          (depositor-token-share (- token-received user-token-share)))
        
        (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token 
               transfer user-sbtc-share CONTRACT user none)))
        (try! (as-contract (contract-call? 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory 
               transfer user-token-share CONTRACT user none)))
        
        (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token 
               transfer depositor-sbtc-share CONTRACT depositor-principal none)))
        (try! (as-contract (contract-call? 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory 
               transfer depositor-token-share CONTRACT depositor-principal none)))
        
        (map-delete user-lp-tokens user)
        (var-set total-lp-tokens (- (var-get total-lp-tokens) user-lp))
        
        (print {
          type: "lp-withdrawal",
          user: user,
          withdrawn-by: tx-sender,
          lp-tokens: user-lp,
          user-sbtc: user-sbtc-share,
          user-token: user-token-share,
          depositor-sbtc: depositor-sbtc-share,
          depositor-token: depositor-token-share,
          ft: 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory
        })
        
        (ok user-lp)
      )
    )
  )

(define-public (withdraw-remaining-token)
  (let ((entry-end-block (+ (var-get creation-block) ENTRY_PERIOD))
        (depositor-principal (unwrap! (var-get depositor) ERR_NOT_INITIALIZED)))
    (asserts! (>= burn-block-height entry-end-block) ERR_STILL_LOCKED)
    (asserts! (is-eq tx-sender depositor-principal) ERR_UNAUTHORIZED)
    
    (let ((remaining-token (- (var-get initial-token-amount) (var-get token-used-for-lp))))
      
      (and (> remaining-token u0)
           (try! (as-contract (contract-call? 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory 
                  transfer remaining-token CONTRACT depositor-principal none))))
      
      (print {
        type: "token-withdrawal",
        amount: remaining-token,
        ft: 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory
      })
      
      (ok remaining-token)
    )
  )
)

(define-read-only (get-pool-info)
  {
    depositor: (var-get depositor),
    creation-block: (var-get creation-block),
    unlock-block: (+ (var-get creation-block) LOCK_PERIOD),
    entry-ends: (+ (var-get creation-block) ENTRY_PERIOD),
    is-unlocked: (>= burn-block-height (+ (var-get creation-block) LOCK_PERIOD)),
    initial-token: (var-get initial-token-amount),
    token-used: (var-get token-used-for-lp),
    token-available: (- (var-get initial-token-amount) (var-get token-used-for-lp)),
    total-lp-tokens: (var-get total-lp-tokens)
  }
)

(define-read-only (get-user-lp-tokens (user principal))
  (default-to u0 (map-get? user-lp-tokens user))
)

(define-read-only (get-quote-for-lp (lp-amount uint))
  (contract-call? 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory-pool 
        quote lp-amount (some 0x02))) ;; 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22

(define-read-only (calculate-amounts-for-lp (lp-amount uint))
  (begin 
        (asserts! (> lp-amount u0) ERR_INSUFFICIENT_AMOUNT)
        (match (get-quote-for-lp lp-amount)
          liquidity-quote (ok {
            sbtc-needed: (get dx liquidity-quote),
            token-needed: (get dy liquidity-quote)
          })
          error-value (err error-value))))

(define-read-only (get-config) 
    {
        ft: 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory,
        pool: 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory-pool,
        denomination: 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token,
    }
)