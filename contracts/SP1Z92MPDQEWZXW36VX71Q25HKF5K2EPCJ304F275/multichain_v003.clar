(use-trait sip-010-token .sip-010-v1a.sip-010-trait)
(use-trait liquidity-token .liquidity-token-trait-v4c.liquidity-token-trait)

(define-constant ERR_AMT u1001)
(define-constant ERR_INVALID_CALLER u2002)
(define-constant ERR_TX_MAP u3003)
(define-constant ADMIN_PRINCIPAL tx-sender)

(define-map CrossChainDepositInfo
    {
        user: principal,
        key: (string-ascii 256)
    }
    {
        from_token: principal,
        from_amt: uint,
        to_token: principal,
        to_amt: uint,
        to_addr: principal,
        is_deposit: bool
    }
)

(define-read-only (getCrossChainDepositInfo (user principal) (tx_hash (string-ascii 256)))
  (default-to { from_token: ADMIN_PRINCIPAL, from_amt: u0, to_token: ADMIN_PRINCIPAL, to_amt: u0, to_addr: ADMIN_PRINCIPAL, is_deposit: false} 
    (map-get? CrossChainDepositInfo { user: user, key: tx_hash }))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-map whitelist principal bool)
(map-set whitelist tx-sender true)
(map-set whitelist 'SP3J8Z4QNYZZ07EENF4S0HGNNPV263YM021FBKVXR true)
(map-set whitelist 'SP3ZE6Z7N902XR34YEKJ84JKEFT7WE0PFKSR3AAA0 true)
(define-data-var FeePrincipal principal 'SP1VX81H9CRRGCQK1SQ2ND0GBC67B0QS5WXQXB4F3)
(define-data-var isSwapStep bool true)
(define-data-var SwapStepNum uint u2)
(define-data-var FeeUnit uint u10000)
(define-data-var FeeRatio uint u200)

(define-read-only (get-fee-info)
    (ok {
        FeePrincipal: (var-get FeePrincipal),
        isSwapStep: (var-get isSwapStep),
        SwapStepNum: (var-get SwapStepNum),
        FeeUnit: (var-get FeeUnit),
        FeeRatio: (var-get FeeRatio),
    })
)

(define-read-only (is-updater (user principal))
  (match (map-get? whitelist user)
    value (ok true)
    (err ERR_INVALID_CALLER)
  )
)
(define-public (add-updater (user principal))
  (begin
    (asserts! (is-eq contract-caller ADMIN_PRINCIPAL) (err ERR_INVALID_CALLER))
    (ok (map-set whitelist
      user true
    ))
  )
)
(define-public (remove-updater (user principal))
  (begin
    (asserts! (is-eq contract-caller ADMIN_PRINCIPAL) (err ERR_INVALID_CALLER))
    (ok (map-delete whitelist
      user
    ))
  )
)

(define-public (SetSwapStep (setIsSwapStep bool) (setSwapNum uint))
  (begin
    (asserts! (is-eq contract-caller ADMIN_PRINCIPAL) (err ERR_INVALID_CALLER))
    (var-set SwapStepNum setSwapNum)
    (var-set isSwapStep setIsSwapStep)
    (ok true)
  )
)

(define-public (SetFeeRatio (setValue uint))
  (begin
    (asserts! (is-eq contract-caller ADMIN_PRINCIPAL) (err ERR_INVALID_CALLER))
    (ok (var-set FeeRatio setValue))
  )
)


(define-public (SetFeePrincipal (setValue principal))
  (begin
    (asserts! (is-eq contract-caller ADMIN_PRINCIPAL) (err ERR_INVALID_CALLER))
    (ok (var-set FeePrincipal setValue))
  )
)

(define-read-only (getFeeInfo)
    (ok {
        FeePrincipal: (var-get FeePrincipal),
        isSwapStep: (var-get isSwapStep),
        SwapStepNum: (var-get SwapStepNum),
        FeeUnit: (var-get FeeUnit),
        FeeRatio: (var-get FeeRatio),
    })
)

(define-private (calcFee (inputAmt uint) (TOKEN_STX <sip-010-token>) 
    (TOKEN_STSW <sip-010-token>) 
    (PAIR_STX_STSW <liquidity-token>))
    (let 
        (  
            (fee1 (if (and (< u0 (var-get SwapStepNum)) (var-get isSwapStep)) (try! (ONESTEP_STX_STSW inputAmt TOKEN_STX TOKEN_STSW PAIR_STX_STSW)) inputAmt))
            (fee2 (if (and (< u1 (var-get SwapStepNum)) (var-get isSwapStep)) (try! (ONESTEP_STX_STSW fee1 TOKEN_STX TOKEN_STSW PAIR_STX_STSW)) fee1))
            (fee3 (if (and (< u2 (var-get SwapStepNum)) (var-get isSwapStep)) (try! (ONESTEP_STX_STSW fee2 TOKEN_STX TOKEN_STSW PAIR_STX_STSW)) fee2))
            (fee4 (if (and (< u3 (var-get SwapStepNum)) (var-get isSwapStep)) (try! (ONESTEP_STX_STSW fee2 TOKEN_STX TOKEN_STSW PAIR_STX_STSW)) fee3))
            (fee5 (if (and (< u4 (var-get SwapStepNum)) (var-get isSwapStep)) (try! (ONESTEP_STX_STSW fee2 TOKEN_STX TOKEN_STSW PAIR_STX_STSW)) fee4))
            (FeeAmt  (/ (* fee5 (var-get FeeRatio)) (var-get FeeUnit)))
        ) 
        
        ;; contract -> fee Wallet
        (try! (as-contract (stx-transfer? FeeAmt  tx-sender (var-get FeePrincipal))))
        (ok (getContractBalance true TOKEN_STX))
    )
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-private (getContractBalance
    (isSTX bool)
    (token <sip-010-token>) 
 )
    (if (is-eq isSTX true) 
        (stx-get-balance (as-contract tx-sender))
        (unwrap-panic (contract-call? token get-balance (as-contract tx-sender)))
    )
)

(define-private (getContractBalance_wallet
    (isSTX bool)
    (token <sip-010-token>) 
    (wallet principal)
 )
    (if (is-eq isSTX true) 
        (stx-get-balance wallet)
        (unwrap-panic (contract-call? token get-balance wallet))
    )
)


(define-private (ONESTEP_STX_STSW
    (STXAmt uint)
    (TOKEN_STX <sip-010-token>) 
    (TOKEN_STSW <sip-010-token>) 
    (PAIR_STX_STSW <liquidity-token>) 
 )   

    (let 
        (  
            (initSTSWAmt (getContractBalance false TOKEN_STSW))
        ) 
        (asserts! (>= (getContractBalance true TOKEN_STX) STXAmt) (err ERR_AMT))
        (try! (as-contract (contract-call? .stackswap-swap-v5k swap-x-for-y TOKEN_STX TOKEN_STSW PAIR_STX_STSW STXAmt u0)))

        (let 
            (
                (afterSTSWAmt (getContractBalance false TOKEN_STSW))
                (deltaSTSWAmt (- afterSTSWAmt initSTSWAmt))

                (initSTXAmt (getContractBalance true TOKEN_STX))
            )
            (asserts! (>= (getContractBalance false TOKEN_STSW) deltaSTSWAmt) (err ERR_AMT))
            (try! (as-contract (contract-call? .stackswap-swap-v5k swap-y-for-x TOKEN_STX TOKEN_STSW PAIR_STX_STSW deltaSTSWAmt u0)))

            (let 
                (
                    (afterSTXAmt (getContractBalance true TOKEN_STX))
                    (deltaSTXAmt (- afterSTXAmt initSTXAmt))
                ) 
                (ok deltaSTXAmt)
            )
        )
    )
    
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (STX_transfer
    (target principal)
    (STXAmt uint)
    (TOKEN_STX <sip-010-token>) 
    (TOKEN_STSW <sip-010-token>) 
    (PAIR_STX_STSW <liquidity-token>) 
    (tx_hash (string-ascii 256))
 )   
    
    (begin         
        ;; tx-sender -> contract
        (try! (stx-transfer? STXAmt tx-sender (as-contract tx-sender)))
        (let 
            (
                (is_deposit (is-some (get is_deposit (map-get? CrossChainDepositInfo { user: tx-sender, key: tx_hash}))))
                (stx_amt2 (try! (calcFee STXAmt TOKEN_STX TOKEN_STSW PAIR_STX_STSW)))
            )
            
            ;; contract -> target
            (try! (as-contract (stx-transfer? stx_amt2 tx-sender target)))
            
            ;; save map
            (asserts! (is-eq is_deposit false) (err ERR_TX_MAP))
            (map-set CrossChainDepositInfo { user: tx-sender, key: tx_hash } { from_token: (contract-of TOKEN_STX), from_amt: STXAmt, to_token: (contract-of TOKEN_STX), to_amt: stx_amt2, to_addr: target, is_deposit: true })

            (ok stx_amt2)
        )
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Only "whitelist -> user"
(define-public (SingleSwap_STX_Token
    (toToken <sip-010-token>) 
    (xyPair <liquidity-token>) 
    (STXAmt uint)
    (target principal)
    (TOKEN_STX <sip-010-token>) 
    (TOKEN_STSW <sip-010-token>) 
    (PAIR_STX_STSW <liquidity-token>) 
    (tx_hash (string-ascii 256))
 )   
    
    (begin 
        (try! (is-updater contract-caller))
        
        ;; tx-sender -> contract
        (try! (stx-transfer? STXAmt tx-sender (as-contract tx-sender)))
        (let 
            (
                (is_deposit (is-some (get is_deposit (map-get? CrossChainDepositInfo { user: tx-sender, key: tx_hash}))))
                (stx_amt2 (try! (calcFee STXAmt TOKEN_STX TOKEN_STSW PAIR_STX_STSW)))
                (beforeToAmt (getContractBalance false toToken))
            )
            
            (try! (as-contract (contract-call? .stackswap-swap-v5k swap-x-for-y TOKEN_STX toToken xyPair stx_amt2 u0)))
            (let 
                (  
                    (afterToAmt (getContractBalance false toToken))
                    (deltaToAmt (- afterToAmt beforeToAmt))
                )
                ;; contract -> target
                (try! (as-contract (contract-call? toToken transfer deltaToAmt tx-sender target none)))

                ;; save map
                (asserts! (is-eq is_deposit false) (err ERR_TX_MAP))
                (map-set CrossChainDepositInfo { user: tx-sender, key: tx_hash } { from_token: (contract-of TOKEN_STX), from_amt: STXAmt, to_token: (contract-of toToken), to_amt: deltaToAmt, to_addr: target, is_deposit: true })
                (ok deltaToAmt)
            ) 
        )
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Only "user -> whitelist"
(define-public (SingleSwap_Token_STX
    (fromToken <sip-010-token>) 
    (xyPair <liquidity-token>) 
    (fromAmt uint)
    (target principal)
    (TOKEN_STX <sip-010-token>) 
    (TOKEN_STSW <sip-010-token>) 
    (PAIR_STX_STSW <liquidity-token>) 
    (tx_hash (string-ascii 256))
 )       
    (let 
        (
            (is_deposit (is-some (get is_deposit (map-get? CrossChainDepositInfo { user: tx-sender, key: tx_hash}))))
            (beforeFromAmt (getContractBalance false fromToken))
            (beforeSTXAmt (getContractBalance true TOKEN_STX))
        )
        (try! (is-updater target))

        ;; tx-sender -> contract
        (try! (contract-call? fromToken transfer fromAmt tx-sender (as-contract tx-sender) none))
        (let 
            (  
                (afterFromAmt (getContractBalance false fromToken))
                (deltaFromAmt (- afterFromAmt beforeFromAmt))
            )

            (try! (as-contract (contract-call? .stackswap-swap-v5k swap-y-for-x TOKEN_STX fromToken xyPair deltaFromAmt u0)))
            (let 
                (
                    (afterSTXAmt (getContractBalance true TOKEN_STX))
                    (STXAmt (- afterSTXAmt beforeSTXAmt))
                    ;; (stx_amt1 (try! (ONESTEP_STX_USDA deltaSTXAmt TOKEN_STX TOKEN_USDA PAIR_STX_USDA)))
                    ;; (stx_amt2 (try! (ONESTEP_STX_STSW stx_amt1 TOKEN_STX TOKEN_STSW PAIR_STX_STSW)))
                    (stx_amt2 (try! (calcFee STXAmt TOKEN_STX TOKEN_STSW PAIR_STX_STSW)))
                )
                
                ;; contract -> target
                (try! (as-contract (stx-transfer? stx_amt2  tx-sender target)))

                ;; save map
                (asserts! (is-eq is_deposit false) (err ERR_TX_MAP))
                (map-set CrossChainDepositInfo { user: tx-sender, key: tx_hash } { from_token: (contract-of fromToken), from_amt: fromAmt, to_token: (contract-of TOKEN_STX), to_amt: stx_amt2, to_addr: target, is_deposit: true })
                (ok stx_amt2)
            )
        ) 
        
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Only "whitelist -> user"
(define-public (Router_STX_STSW_Token
    (toToken <sip-010-token>) 
    (STSW_To_Pair <liquidity-token>) 
    (STXAmt uint)
    (target principal)
    (TOKEN_STX <sip-010-token>) 
    (TOKEN_STSW <sip-010-token>) 
    (PAIR_STX_STSW <liquidity-token>)
    (tx_hash (string-ascii 256))
 )   
    
    (begin 
    
        (try! (is-updater contract-caller))
        ;; tx-sender -> contract
        (try! (stx-transfer? STXAmt tx-sender (as-contract tx-sender)))
        (let 
            (
                (is_deposit (is-some (get is_deposit (map-get? CrossChainDepositInfo { user: tx-sender, key: tx_hash}))))
                (user tx-sender)
                ;; (stx_amt1 (try! (ONESTEP_STX_USDA STXAmt TOKEN_STX TOKEN_USDA PAIR_STX_USDA)))
                ;; (stx_amt2 (try! (ONESTEP_STX_STSW stx_amt1 TOKEN_STX TOKEN_STSW PAIR_STX_STSW)))
                (stx_amt2 (try! (calcFee STXAmt TOKEN_STX TOKEN_STSW PAIR_STX_STSW)))
                (beforeToAmt (getContractBalance false toToken))
                
            )

            (try!  (as-contract (contract-call? .stackswap-swap-router-v1b router-swap TOKEN_STX TOKEN_STSW toToken PAIR_STX_STSW STSW_To_Pair true true stx_amt2 u0 u0)))

            (let 
                (  
                    (afterToAmt (getContractBalance false toToken))
                    (deltaToAmt (- afterToAmt beforeToAmt))
                )
                ;; contract -> target
                (try! (as-contract (contract-call? toToken transfer deltaToAmt tx-sender target none)))

                ;; save map
                (asserts! (is-eq is_deposit false) (err ERR_TX_MAP))
                (map-set CrossChainDepositInfo { user: tx-sender, key: tx_hash } { from_token: (contract-of TOKEN_STX), from_amt: STXAmt, to_token: (contract-of toToken), to_amt: deltaToAmt, to_addr: target, is_deposit: true })
                (ok deltaToAmt)
            ) 
        )
    
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Only "user -> whitelist"
(define-public (Router_Token_STSW_STX
    (fromToken <sip-010-token>) 
    (STSW_From_Pair <liquidity-token>) 
    (fromAmt uint)
    (target principal)
    (TOKEN_STX <sip-010-token>) 
    (TOKEN_STSW <sip-010-token>) 
    (PAIR_STX_STSW <liquidity-token>)
    (tx_hash (string-ascii 256))
 )   
    
    (let 
        (
            (is_deposit (is-some (get is_deposit (map-get? CrossChainDepositInfo { user: tx-sender, key: tx_hash}))))
            (beforeFromAmt (getContractBalance false fromToken))
            (beforeSTXAmt (getContractBalance true TOKEN_STX))
        )
        (try! (is-updater target))

        ;; tx-sender -> contract
        (try! (contract-call? fromToken transfer fromAmt tx-sender (as-contract tx-sender) none))
        (let 
            (  
                (afterFromAmt (getContractBalance false fromToken))
                (deltaFromAmt (- afterFromAmt beforeFromAmt))
            )

            (try! (as-contract (contract-call? .stackswap-swap-router-v1b router-swap fromToken TOKEN_STSW TOKEN_STX STSW_From_Pair PAIR_STX_STSW false false deltaFromAmt u0 u0)))
            (let 
                (
                    (afterSTXAmt (getContractBalance true TOKEN_STX))
                    (STXAmt (- afterSTXAmt beforeSTXAmt))
                    ;; (stx_amt1 (try! (ONESTEP_STX_USDA deltaSTXAmt TOKEN_STX TOKEN_USDA PAIR_STX_USDA)))
                    ;; (stx_amt2 (try! (ONESTEP_STX_STSW stx_amt1 TOKEN_STX TOKEN_STSW PAIR_STX_STSW)))
                    (stx_amt2 (try! (calcFee STXAmt TOKEN_STX TOKEN_STSW PAIR_STX_STSW)))
                )
                
                ;; contract -> target
                (try! (as-contract (stx-transfer? stx_amt2  tx-sender target)))
                ;; save map
                (asserts! (is-eq is_deposit false) (err ERR_TX_MAP))
                (map-set CrossChainDepositInfo { user: tx-sender, key: tx_hash } { from_token: (contract-of fromToken), from_amt: fromAmt, to_token: (contract-of TOKEN_STX), to_amt: stx_amt2, to_addr: target, is_deposit: true })
                (ok stx_amt2)
            )
        ) 
    )
)