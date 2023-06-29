

(use-trait ft-trait .trait-sip-010.sip-010-trait)
(use-trait dispatcherInterface .dispatcherTrait.DispatcherInterface)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-data-var contract-owner principal tx-sender)

(define-constant ERR_BATCH_LENGTH (err u1001))
(define-constant ERR_INVALID_BATCH (err u1002))
(define-constant ERR_DISPATCH_FAILED (err u1003))
(define-constant ERR_RETURN_AMOUNT_IS_NOT_ENOUGH (err u1004))
(define-constant ERR_BALANCE_ERROR (err u1005))
(define-constant ERR_JUMP_FAILED (err u1006))
(define-constant ERR_NOT_OK (err u1007))
(define-constant ERR_NOT_AUTHORIZED (err u1008))

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

(define-public (set-contract-owner (owner principal))
  (begin
    (try! (check-is-owner)) 
    (ok (var-set contract-owner owner))
  )
)



(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_AUTHORIZED))
)





(define-public (unxswap 
    (baseRequest {fromToken: <ft-trait>, toToken: <ft-trait>, fromTokenAmount: uint, minReturnAmount: uint}) 
    (batches (list 10 {adapterImpl: <dispatcherInterface>, poolType: uint, swapFuncType: uint, fromToken: <ft-trait>, toToken: <ft-trait>, weightX: uint, weightY: uint,factor: uint, dx: uint, minDy: (optional uint)}))
    )

    (let
      (
          (batchLen (len batches))
          (toToken (get toToken baseRequest))
          (fromTokenAmount (get fromTokenAmount baseRequest))
          (minReturnAmount (get minReturnAmount baseRequest))
          (fromToken (get fromToken baseRequest))
          (sender tx-sender)
          (balanceBefore (try! (contract-call? toToken get-balance sender)))
          
          (dy (try! (fold handleJump batches (ok fromTokenAmount))))
      )

      ;; emit event: OrderRecord
      (print {orderRecord: {fromToken: fromToken, toToken: toToken, sender: sender, fromAmount: fromTokenAmount, returnAmount:  dy}})
      ;; return amount delta
      (checkMinReturn (try! (contract-call? toToken get-balance sender)) balanceBefore minReturnAmount)
    )


)

;; (define-constant ETH_ADDR 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE)
;; (define-private (balanceOf (token <ft-trait>) (user principal)) 
;;     (let 
;;         (
;;           (tokenAddr (contract-of token))
;;         )
;;         (if (is-eq tokenAddr ETH_ADDR)
;;             (stx-get-balance user)
;;             (try! (contract-call? token get-balance user))
;;         )
;;     )
;; )

(define-private (checkMinReturn (balanceAfter uint) (balanceBefore uint) (minReturnAmount uint)) 
    (begin 
        (asserts! (>= balanceAfter balanceBefore) ERR_BALANCE_ERROR)
        (asserts! (>= (- balanceAfter balanceBefore) minReturnAmount) ERR_RETURN_AMOUNT_IS_NOT_ENOUGH)
        (print {balanceAfter: balanceAfter, balanceBefore: balanceBefore, minReturnAmount: minReturnAmount})
        (ok (- balanceAfter balanceBefore))
    )
    
)


(define-public (handleJump 
    (batch {adapterImpl: <dispatcherInterface>, poolType: uint, swapFuncType: uint, fromToken: <ft-trait>, toToken: <ft-trait>, weightX: uint, weightY: uint,factor: uint, dx: uint, minDy: (optional uint)})
    (priorRes (response uint uint))
) 
(match priorRes
    amountIn 
    (let
        (
            (batchInfo (merge batch {dx: amountIn}))
            (adapterImpl (get adapterImpl batchInfo))
            (poolType (get poolType batchInfo))
            (swapFuncType (get swapFuncType batchInfo))
            (fromToken (get fromToken batchInfo))
            (toToken (get toToken batchInfo))
            (weightX (get weightX batchInfo))
            (weightY (get weightY batchInfo))
            (factor (get factor batchInfo))
            (dx (get dx batchInfo))
            (minDy (get minDy batchInfo))

            ;; 0xAAAA 0xBBBB.dispatcher
            (dy (get dy (try! (contract-call? adapterImpl swap
                    poolType swapFuncType fromToken toToken weightX weightY factor dx minDy
                ))))
        )
        (asserts! (>= dy (default-to u0 minDy)) ERR_RETURN_AMOUNT_IS_NOT_ENOUGH)
        (ok dy)
    )
    err-value (err err-value)
)
 
)
