---
title: "Trait transfer-test-v2d"
draft: true
---
```

(define-constant CONTRACT_ADDRESS (as-contract tx-sender))
(define-constant POOL_OPERATOR tx-sender)

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
	(let
		(
			(recipient 'ST1G4GV4JT3W2YMWNERV685FBJKEBG7KYZT24R8QM)
		)

		;;(asserts! (is-eq tx-sender recipient) (err u40404))

		;; Transfer an arbitrary amount (1 STX) Both of these versions work:
		;;(try! (as-contract (stx-transfer? u1000000 tx-sender recipient)))
		(as-contract
  			(try! (stx-transfer? u1000000 CONTRACT_ADDRESS recipient)))


		(ok true)
	)
)

(define-read-only (getPoolFundAmt)
	(ok (var-get poolFundTotalDeposited))
)

(define-read-only (getPoolBalance)
	(ok (stx-get-balance CONTRACT_ADDRESS))
)
```
