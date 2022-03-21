---
title: "Trait transfer-test-v1"
draft: true
---
```

(define-constant CONTRACT_ADDRESS (as-contract tx-sender))

(define-data-var poolFundTotalDeposited uint u0)		;; total amount deposited to pool


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    FUNCTIONS THAT SHOULD WORK ON TESTNET   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-public (depositFunds (amountUstx uint))
	(begin
		;; Add amountUstx to poolFundTotalDeposited
		(var-set poolFundTotalDeposited (+ (var-get poolFundTotalDeposited) amountUstx))

		;; Transfer the STX (amount as parameter)
		(try! (stx-transfer? amountUstx tx-sender CONTRACT_ADDRESS))
	
		(ok true)
	)
)

;; This function is available if the contract is closed, either because the hard block limit has been reached
;;  or because the minimum deposit threshold was not met 
(define-public (reclaimFunds)
	(begin

		;; Transfer an arbitrary amount (1 STX)
		(try! (stx-transfer? u1000000 CONTRACT_ADDRESS tx-sender))

		(ok true)
	)
)

(define-read-only (getPoolFundAmt)
	(ok (var-get poolFundTotalDeposited))
)
```
