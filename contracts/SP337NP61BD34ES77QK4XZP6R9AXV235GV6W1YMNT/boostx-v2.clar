;; title:  boostx
;; version:  2.0
;; summary:  BoostX Smart Contract for BoostX Browser Extension
;; authors:  cryptodude.btc and cryptosmith.btc

(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait sip-009-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait boostx-options-trait 'SP337NP61BD34ES77QK4XZP6R9AXV235GV6W1YMNT.boostx-options-trait.boostx-options-trait)

(define-constant ERR-UNAUTHORIZED (err u1000))
(define-constant ERR-INVALID-WALLET (err u1001))
(define-constant ERR-INSUFFICIENT-BALANCE (err u1002))
(define-constant ERR-INSUFFICIENT-AMOUNT (err u1003))
(define-constant ERR-NOTFOUND (err u1004))

;; initial value for extDeployer owner wallet, set to this
(define-data-var extDeployer principal 'SP337NP61BD34ES77QK4XZP6R9AXV235GV6W1YMNT)

(define-map fee
	(string-ascii 10)
	{
		stx: uint,
		ft: uint,
		nft: uint,
	}
)
;; Fee's update function
(define-public (update-fees
		(stx (optional uint))
		(ft (optional uint))
		(nft (optional uint))
	)
	(let ((existing-fees (map-get? fee "fees")))
		(asserts! (is-eq contract-caller (get-ext-deployer-wallet)) ERR-UNAUTHORIZED)
		(if (is-some stx)
			(ok (map-set fee "fees" {
				stx: (unwrap! stx ERR-NOTFOUND),
				ft: (unwrap! (get ft existing-fees) ERR-NOTFOUND),
				nft: (unwrap! (get nft existing-fees) ERR-NOTFOUND),
			}))
			(if (is-some ft)
				(ok (map-set fee "fees" {
					stx: (unwrap! (get stx existing-fees) ERR-NOTFOUND),
					ft: (unwrap! ft ERR-NOTFOUND),
					nft: (unwrap! (get nft existing-fees) ERR-NOTFOUND),
				}))
				(if (is-some nft)
					(ok (map-set fee "fees" {
						stx: (unwrap! (get stx existing-fees) ERR-NOTFOUND),
						ft: (unwrap! (get ft existing-fees) ERR-NOTFOUND),
						nft: (unwrap! nft ERR-NOTFOUND),
					}))
					(ok false)
				)
			)
		)
	)
)

(define-read-only (get-fees)
	(ok (map-get? fee "fees"))
)

;; returns set extDeployer owner wallet principal
(define-read-only (get-ext-deployer-wallet)
	(var-get extDeployer)
)

;; protected function to update extDeployer owner wallet principal
(define-public (set-ext-deployer-wallet (newExtDeployer principal))
	(begin
		(asserts! (is-eq contract-caller (get-ext-deployer-wallet)) ERR-UNAUTHORIZED)
		(asserts! (not (is-eq newExtDeployer (get-ext-deployer-wallet)))
			ERR-INVALID-WALLET
		)
		;; Ensure it's not the same as the current wallet
		(ok (var-set extDeployer newExtDeployer))
	)
)

;;

(define-private (pay-royalties
		(id uint)
		(pay-options (response {
			amount: uint,
			bns-contract: <sip-009-trait>,
		} uint
		))
	)
	(let (
			(bns-contract (get bns-contract (unwrap! pay-options ERR-NOTFOUND)))
			(amount (get amount (unwrap! pay-options ERR-NOTFOUND)))
			(get-receiver-address (unwrap! (contract-call? bns-contract get-owner id) ERR-NOTFOUND))
			(receiver-address (unwrap! get-receiver-address ERR-NOTFOUND))
		)
		(try! (stx-transfer? amount tx-sender receiver-address))
		(ok {
			amount: amount,
			bns-contract: bns-contract,
		})
	)
)

;; Extension Operation boostx-message
(define-public (boostx-message
		(content-author principal)
		(amount-or-id uint)
		(via-id (string-utf8 256))
		(is-stx bool)
		(is-nft bool)
		(ft-contract-id (optional <sip-010-trait>))
		(nft-contract-id (optional <sip-009-trait>))
		(memo (optional (buff 34)))
		(message (optional (string-utf8 256)))
		(options-contract <boostx-options-trait>)
		(bns-contract <sip-009-trait>)
	)
	(let (
			(royalty-ids (unwrap! (contract-call? options-contract get-options-id-list) ERR-NOTFOUND))
			(profile-stx-balance (stx-get-balance contract-caller))
			(stx-fee (unwrap! (get stx (map-get? fee "fees")) ERR-NOTFOUND))
			(ft-fee (unwrap! (get ft (map-get? fee "fees")) ERR-NOTFOUND))
			(nft-fee (unwrap! (get nft (map-get? fee "fees")) ERR-NOTFOUND))
		)
		(asserts! (not (is-eq content-author tx-sender)) ERR-UNAUTHORIZED)
		(if is-stx
			(let (
					;; STX Royalty for Referals and Spornsor's
					(stx-fee-royalty (* (/ stx-fee u100) u10))
					(stx-fee-offset (* (len royalty-ids) stx-fee-royalty))
					(stx-fee-platform (- stx-fee stx-fee-offset))
				)
				(asserts! (>= profile-stx-balance amount-or-id) ERR-INSUFFICIENT-BALANCE)
				(asserts! (> amount-or-id stx-fee) ERR-INSUFFICIENT-AMOUNT)
				(if (is-some memo)
					(try! (stx-transfer-memo? (- amount-or-id stx-fee) contract-caller content-author
						(unwrap! memo ERR-NOTFOUND)
					))
					(try! (stx-transfer? (- amount-or-id stx-fee) contract-caller content-author))
				)
				(try! (stx-transfer? stx-fee-platform contract-caller (get-ext-deployer-wallet)))
				(try! (fold pay-royalties royalty-ids
					(ok {
						amount: stx-fee-royalty,
						bns-contract: bns-contract,
					})
				))
				;; fee payout to updatable extDeployer)
				(print {
					stx-fee-platform: stx-fee-platform,
					stx-fee-offset: stx-fee-offset,
					stx-fee-royalty: stx-fee-royalty,
					royalty-ids: royalty-ids,
					event: "boostx-message-stx",
					content-author: content-author,
					amount: amount-or-id,
					via-id: via-id,
					is-stx: true,
					memo: memo,
					message: message,
				})
				(ok true)
			)
			(if is-nft
				(let (
						(nft-contract (unwrap! nft-contract-id ERR-NOTFOUND))
						(profile-nft-owner (unwrap!
							(unwrap! (contract-call? nft-contract get-owner amount-or-id) ERR-NOTFOUND)
							ERR-NOTFOUND
						))
						;; NFT Royalty for Referals and Spornsor's
						(nft-fee-royalty (* (/ nft-fee u100) u10))
						(nft-fee-offset (* (len royalty-ids) nft-fee-royalty))
						(nft-fee-platform (- nft-fee nft-fee-offset))
					)
					(asserts! (>= profile-stx-balance nft-fee) ERR-INSUFFICIENT-BALANCE)
					(asserts! (is-eq profile-nft-owner contract-caller) ERR-UNAUTHORIZED)
					(if (is-some memo)
						(try! (contract-call? nft-contract transfer amount-or-id contract-caller
							content-author
						))
						(try! (contract-call? nft-contract transfer amount-or-id contract-caller
							content-author
						))
					)
					(try! (stx-transfer? nft-fee-platform contract-caller (get-ext-deployer-wallet)))
					(try! (fold pay-royalties royalty-ids
						(ok {
							amount: nft-fee-royalty,
							bns-contract: bns-contract,
						})
					))
					;; fee payout to updatable extDeployer)
					(print {
						event: " boostx-message-nft",
						content-author: content-author,
						id: amount-or-id,
						via-id: via-id,
						is-stx: false,
						contractId: nft-contract,
						memo: memo,
						message: message,
					})
					(ok true)
				)
				(let (
						(ft-contract (unwrap! ft-contract-id ERR-NOTFOUND))
						(profile-ft-balance (unwrap! (contract-call? ft-contract get-balance contract-caller)
							ERR-NOTFOUND
						))
						;; FT Royalty for Referals and Spornsor's
						(ft-fee-royalty (* (/ ft-fee u100) u10))
						(ft-fee-offset (* (len royalty-ids) ft-fee-royalty))
						(ft-fee-platform (- ft-fee ft-fee-offset))
					)
					(asserts! (>= profile-stx-balance ft-fee) ERR-INSUFFICIENT-BALANCE)
					(asserts! (> profile-ft-balance amount-or-id) ERR-INSUFFICIENT-BALANCE)
					(if (is-some memo)
						(try! (contract-call? ft-contract transfer amount-or-id contract-caller
							content-author memo
						))
						(try! (contract-call? ft-contract transfer amount-or-id contract-caller
							content-author none
						))
					)
					(try! (stx-transfer? ft-fee-platform contract-caller (get-ext-deployer-wallet)))
					(try! (fold pay-royalties royalty-ids
						(ok {
							amount: ft-fee-royalty,
							bns-contract: bns-contract,
						})
					))
					;; fee payout to updatable extDeployer)
					(print {
						event: " boostx-message-ft",
						content-author: content-author,
						amount: amount-or-id,
						via-id: via-id,
						is-stx: false,
						contractId: ft-contract,
						memo: memo,
						message: message,
					})
					(ok true)
				)
			)
		)
	)
)

;; Contract initial fees values
(map-insert fee "fees" {
	stx: u100000,
	ft: u100000,
	nft: u100000,
})
