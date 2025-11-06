(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-public (run-update)
	(begin
		(asserts! (not (var-get executed)) (err u10))
		(asserts! (is-eq deployer tx-sender) (err u11))

		;; data
		(try! (contract-call? .pool-reserve-data set-contract-owner .zest-governance))
		(try! (contract-call? .pool-reserve-data-1 set-contract-owner .zest-governance))
		(try! (contract-call? .pool-reserve-data-2 set-contract-owner .zest-governance))
		(try! (contract-call? .pool-reserve-data-3 set-contract-owner .zest-governance))
		(try! (contract-call? .pool-reserve-data-4 set-contract-owner .zest-governance))

		;; rewards
		(try! (contract-call? .rewards-data set-contract-owner .zest-governance))
		(try! (contract-call? .rewards-data-1 set-contract-owner .zest-governance))

		(try! (contract-call? .incentives-v2-2 set-contract-owner .zest-governance))

		;; ztokens
		(try! (contract-call? .zststx-v2-0 set-contract-owner .zest-governance))
		(try! (contract-call? .zststx-token set-contract-owner .zest-governance))

		(try! (contract-call? .zaeusdc-v2-0 set-contract-owner .zest-governance))
		(try! (contract-call? .zaeusdc-token set-contract-owner .zest-governance))

		(try! (contract-call? .zwstx-v2-0 set-contract-owner .zest-governance))
		(try! (contract-call? .zwstx-token set-contract-owner .zest-governance))

		(try! (contract-call? .zdiko-v2-0 set-contract-owner .zest-governance))
		(try! (contract-call? .zdiko-token set-contract-owner .zest-governance))

		(try! (contract-call? .zusdh-v2-0 set-contract-owner .zest-governance))
		(try! (contract-call? .zusdh-token set-contract-owner .zest-governance))

		(try! (contract-call? .zsusdt-v2-0 set-contract-owner .zest-governance))
		(try! (contract-call? .zsusdt-token set-contract-owner .zest-governance))

		(try! (contract-call? .zusda-v2-0 set-contract-owner .zest-governance))
		(try! (contract-call? .zusda-token set-contract-owner .zest-governance))

		(try! (contract-call? .zsbtc-v2-0 set-contract-owner .zest-governance))
		(try! (contract-call? .zsbtc-token set-contract-owner .zest-governance))

		(try! (contract-call? .zststxbtc-v2_v2-0 set-contract-owner .zest-governance))
		(try! (contract-call? .zststxbtc-v2-token set-contract-owner .zest-governance))

		(try! (contract-call? .zalex-v2-0 set-contract-owner .zest-governance))
		(try! (contract-call? .zalex-token set-contract-owner .zest-governance))

		;; core (need recipient to accept)

		(try! (contract-call? .pool-0-reserve set-configurator .zest-governance))
		(try! (contract-call? .pool-0-reserve set-admin .zest-governance))

		(try! (contract-call? .pool-0-reserve-v2-0 set-configurator .zest-governance))
		(try! (contract-call? .pool-0-reserve-v2-0 set-admin .zest-governance))

		(try! (contract-call? .pool-vault set-contract-owner .zest-governance))

		(try! (contract-call? .pool-borrow-v2-4 set-configurator .zest-governance))

		(try! (contract-call? .liquidation-manager-v2-3 set-admin .zest-governance))


		(var-set executed true)
		(ok true)
	)
)

(define-public (disable)
	(begin
		(asserts! (is-eq deployer tx-sender) (err u11))
		(ok (var-set executed true))
	)
)

(define-read-only (can-execute)
	(begin
		(asserts! (not (var-get executed)) (err u10))
		(ok (not (var-get executed)))
	)
)
