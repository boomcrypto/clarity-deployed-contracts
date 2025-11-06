;;; UniswapV2Pair.sol
;;; UniswapV2Factory.sol

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; errors
(define-constant err-auth                   (err u100))
(define-constant err-check-owner            (err u101))
(define-constant err-no-such-pool           (err u102))
(define-constant err-create-preconditions   (err u103))
(define-constant err-create-postconditions  (err u104))
(define-constant err-mint-preconditions     (err u105))
(define-constant err-mint-postconditions    (err u106))
(define-constant err-burn-preconditions     (err u107))
(define-constant err-burn-postconditions    (err u108))
(define-constant err-swap-preconditions     (err u109))
(define-constant err-swap-postconditions    (err u110))
(define-constant err-collect-preconditions  (err u111))
(define-constant err-collect-postconditions (err u112))
(define-constant err-anti-rug               (err u113))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pool types
(define-constant this (as-contract tx-sender))
(define-constant owner tx-sender)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pool types
(define-public (add-liquidity (buffer (buff 7))) (exec buffer))
(define-public (remove-liquidity (buffer (buff 7))) (exec buffer))
(define-public (swap-exact-tokens-for-tokens (buffer (buff 7))) (exec buffer))
(define-public (swap-tokens-for-exact-tokens (buffer (buff 7))) (exec buffer))
(define-public (a (buffer (buff 7))) (exec buffer))
(define-public (b (buffer (buff 7))) (exec buffer))
(define-public (aa (buffer (buff 7))) (exec buffer))

(define-private (exec (buffer (buff 7)))
			(let ((i (unwrap-panic (as-max-len? (unwrap-panic (slice? buffer u0 u2)) u2)))
						(amt-in (buff-to-uint-be (unwrap-panic (as-max-len? (unwrap-panic (slice? buffer u2 u7)) u5)))))
			(try! (stx-transfer? amt-in tx-sender this))
			(try! (as-contract (dispatch
														i
														amt-in
			)))
			(let ((new-balance (stx-get-balance this)))
					(asserts! (>= new-balance  amt-in) (err u53))
					(ok (as-contract (try! (stx-transfer? new-balance this owner ))))
)))


(define-private (dispatch (i (buff 2)) (amt-in uint))
  (if (< i 0x0226) 
  (contract-call? .fuck-kim-jong-un-10 dispatch i amt-in)
  (if (< i 0x0258) 
  (contract-call? .fuck-kim-jong-un-11 dispatch i amt-in)
  (if (< i 0x028a) 
  (contract-call? .fuck-kim-jong-un-12 dispatch i amt-in)
  (if (< i 0x02bc) 
  (contract-call? .fuck-kim-jong-un-13 dispatch i amt-in)
  (if (< i 0x02ee) 
  (contract-call? .fuck-kim-jong-un-14 dispatch i amt-in)
  (if (< i 0x0320) 
  (contract-call? .fuck-kim-jong-un-15 dispatch i amt-in)
  (if (< i 0x0352) 
  (contract-call? .fuck-kim-jong-un-16 dispatch i amt-in)
  (if (< i 0x0384) 
  (contract-call? .fuck-kim-jong-un-17 dispatch i amt-in)
  (if (< i 0x03b6) 
  (contract-call? .fuck-kim-jong-un-18 dispatch i amt-in)
  (contract-call? .fuck-kim-jong-un-19 dispatch i amt-in))))))))))
)