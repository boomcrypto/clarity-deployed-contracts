(define-constant err-unauthorized (err u401))

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) err-unauthorized))
)

(define-public (mint (cha-amount uint))
	(let
		(
			(initial-scha-balance (unwrap-panic (contract-call? .liquid-staked-charisma get-balance tx-sender)))
		)
		(try! (is-dao-or-extension))
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint cha-amount tx-sender))
		(try! (contract-call? .liquid-staked-charisma stake cha-amount))
		(let
			(
				(after-scha-balance (unwrap-panic (contract-call? .liquid-staked-charisma get-balance tx-sender)))
				(scha-balance (- after-scha-balance initial-scha-balance))
			)
			(ok scha-balance)
		)
	)
)