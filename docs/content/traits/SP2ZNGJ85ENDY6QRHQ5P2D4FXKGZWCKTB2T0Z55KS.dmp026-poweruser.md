---
title: "Trait dmp026-poweruser"
draft: true
---
```
;; Title: DMP026 Poweruser
;; Author: rozar.btc
;; Synopsis:
;; Instead of having short vote times, temporarily enable a trusted principal as an extension to accelerate development.

(impl-trait .dao-traits-v2.proposal-trait)

(define-public (execute (sender principal))
	(begin
		;; set trusted principal as new extention
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master set-extension 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS true))
		;; increase proposal duration for better platform security
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme002-proposal-submission set-parameter "proposal-duration" u1000))
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme002-proposal-submission set-parameter "minimum-proposal-start-delay" u10))
		(ok true)
	)
)

```
