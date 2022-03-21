---
title: "Trait transfer-test-v2c"
draft: true
---
```

;;(define-constant CONTRACT_ADDRESS (as-contract tx-sender))

;;(define-constant OTHER_CONTRACT "ST21S70JZYAR5N2M6BTEBC3YQY1SE4NY9VDND53ZP.transfer-test-v1")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    FUNCTIONS THAT SHOULD WORK ON TESTNET   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-public (callOtherContract (amountUstx uint))
	(begin

		;; Call Other Contract
		;;(try! (as-contract (contract-call? 'ST21S70JZYAR5N2M6BTEBC3YQY1SE4NY9VDND53ZP.transfer-test-v1b depositFunds amountUstx)))
		(try! (contract-call? 'ST21S70JZYAR5N2M6BTEBC3YQY1SE4NY9VDND53ZP.transfer-test-v1b depositFunds amountUstx))

		(ok true)
	)
)

```
