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
  (if (< i 0x0802) 
  (contract-call? .fuck-kim-jong-un-40 dispatch i amt-in)
  (if (< i 0x0834) 
  (contract-call? .fuck-kim-jong-un-41 dispatch i amt-in)
  (if (< i 0x0866) 
  (contract-call? .fuck-kim-jong-un-42 dispatch i amt-in)
  (if (< i 0x0898) 
  (contract-call? .fuck-kim-jong-un-43 dispatch i amt-in)
  (if (< i 0x08ca) 
  (contract-call? .fuck-kim-jong-un-44 dispatch i amt-in)
  (if (< i 0x08fc) 
  (contract-call? .fuck-kim-jong-un-45 dispatch i amt-in)
  (if (< i 0x092e) 
  (contract-call? .fuck-kim-jong-un-46 dispatch i amt-in)
  (if (< i 0x0960) 
  (contract-call? .fuck-kim-jong-un-47 dispatch i amt-in)
  (if (< i 0x0992) 
  (contract-call? .fuck-kim-jong-un-48 dispatch i amt-in)
  (contract-call? .fuck-kim-jong-un-49 dispatch i amt-in))))))))))
)