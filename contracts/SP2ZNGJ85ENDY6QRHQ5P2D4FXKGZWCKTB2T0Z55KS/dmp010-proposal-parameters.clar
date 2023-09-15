;; Title: DMP010 - Update Proposal Parameters
;; Author: rozar.btc
;; Synopsis:
;; This proposal shortens the total time proposals are in the voting phase to more quickly deliver platform updates.

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme002-proposal-submission set-parameter "proposal-duration" u720))
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme002-proposal-submission set-parameter "minimum-proposal-start-delay" u36))
        (ok true)
	)
)
