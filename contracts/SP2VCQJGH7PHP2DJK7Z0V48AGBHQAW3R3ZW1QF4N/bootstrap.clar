(impl-trait .proposal-trait.proposal-trait)

(define-constant signer-1 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N)
(define-constant signer-2 'SP3PNBD47F620H0VXMC6ZG4DPF58R9V3RZVDPDTGX)
(define-constant signer-3 'SP2D738BJ3Y896ZTK6B3DFR8Q30GSZ1X2JW4BMF39)
(define-constant signer-4 'SP25NSVXX7BFFCTNZRXF7DHHS245ZECABA783CZ3A)

(define-constant executive-1 'SP2AXXV291M8089NXT3Z8021A3XQWAAYR4HAZ5363)
(define-constant executive-2 'SP1D9Q54QG3BE00SQR3MQRQBBY0FZKPT6RVD1YDJH)
(define-constant executive-3 'SP3QTMKR80GBYZKY3JGCCWAJH3B4CH1C63NMMWA4S)

(define-public (execute (sender principal))
	(begin
		;; set signer team members
		(try! (contract-call? .zest-governance set-signer-team-member signer-1 true))
		(try! (contract-call? .zest-governance set-signer-team-member signer-2 true))
		(try! (contract-call? .zest-governance set-signer-team-member signer-3 true))
		(try! (contract-call? .zest-governance set-signer-team-member signer-4 true))

		(try! (contract-call? .zest-governance set-signer-signals-required u3))

		;; set executive team members
		(try! (contract-call? .zest-governance set-executive-team-member executive-1 true))
		(try! (contract-call? .zest-governance set-executive-team-member executive-2 true))
		(try! (contract-call? .zest-governance set-executive-team-member executive-3 true))

		(try! (contract-call? .zest-governance set-executive-signals-required u2))

		(ok true)
	)
)
