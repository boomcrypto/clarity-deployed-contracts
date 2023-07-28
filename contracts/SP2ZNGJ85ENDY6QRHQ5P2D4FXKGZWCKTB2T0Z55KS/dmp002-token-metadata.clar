;; Title: DMP002 Token Metadata Update
;; Author: Ross Ragsdale
;; Synopsis:
;; Update token metadata for wallet indexing

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token set-token-uri (some u"https://charisma.rocks/charisma.json")))
        (print { notification: "token-metadata-update", payload: { token-class: "ft", contract-id: 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token }})
        (ok true)
	)
)
