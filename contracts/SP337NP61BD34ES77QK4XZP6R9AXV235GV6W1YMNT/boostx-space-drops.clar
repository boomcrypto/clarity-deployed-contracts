;; title:  boostx-space-drops
;; version:  1.7.5
;; summary:  BoostX Spacedrops Smart Contract for BoostX Browser Extension
;; authors:  cryptodude.btc and cryptosmith.btc

(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(define-constant ERR-UNAUTHORIZED (err u1000))
(define-constant ERR-INVALID-WALLET (err u1001))
(define-constant ERR-INSUFFICIENT-BALANCE (err u1002))
(define-constant ERR-INSUFFICIENT-AMOUNT (err u1003))
(define-constant ERR-NOTFOUND (err u1004))
(define-constant ERR-TOKEN-NOT-SUPPORTED (err u1005))

;; initial value for extDeployer owner wallet, set to this
(define-data-var extDeployer principal 'SP337NP61BD34ES77QK4XZP6R9AXV235GV6W1YMNT)

;; returns set extDeployer owner wallet principal
(define-read-only (get-ext-deployer-wallet) (var-get extDeployer))

;; protected function to update extDeployer owner wallet principal
(define-public (set-ext-deployer-wallet (newExtDeployer principal))
	(begin
		(asserts! (is-eq contract-caller (get-ext-deployer-wallet)) ERR-UNAUTHORIZED)
		(asserts! (not (is-eq newExtDeployer (get-ext-deployer-wallet))) ERR-INVALID-WALLET);; Ensure it's not the same as the current wallet
		(ok (var-set extDeployer newExtDeployer))
	)
)

(define-map fee (string-ascii 10) {stx: uint, ft: uint})
;; Fee's update function
(define-public (update-fees (stx (optional uint)) (ft (optional uint))) 
	(let 
		(
			(existing-fees (map-get? fee "fees"))
		) 
		(asserts! (is-eq contract-caller (get-ext-deployer-wallet)) ERR-UNAUTHORIZED)
		(if (is-some stx) 
			(ok (map-set fee "fees" {stx:(unwrap! stx ERR-NOTFOUND), ft: (unwrap! (get ft existing-fees) ERR-NOTFOUND)}))
			(ok (map-set fee "fees" {stx: (unwrap! (get stx existing-fees) ERR-NOTFOUND), ft: (unwrap! ft ERR-NOTFOUND)}))
		)
	)
)

(define-read-only (get-fees) 
	(map-get? fee "fees")
)

(define-private (send-stx (amount uint) (sender principal) (recipient principal)) 
	(stx-transfer? amount sender recipient)
)

(define-private (send-ft (token-contract <sip-010-trait>) (amount uint) (sender principal) (recipient principal) (memo (optional (buff 32)))) 
	(contract-call? token-contract transfer amount sender recipient memo)
)

(define-private (send-token (recipients-values {is-stx: bool, amount: uint, recipient: principal, token-contract: (optional <sip-010-trait>)}) (expected-result (response bool uint)))
	(let 
		(
			(is-stx (get is-stx recipients-values))
			(amount (get amount recipients-values))
			(recipient (get recipient recipients-values))
		)

		(if is-stx
			(try! (send-stx amount tx-sender recipient))
			(let ((token-contract (unwrap! (get token-contract recipients-values) ERR-NOTFOUND))) 
				(try! (send-ft token-contract amount tx-sender recipient none))
			)
		)	

		expected-result
	)
)

(define-private (validate-contract-and-balance (is-stx bool) (total-amount uint) (token-contract (optional <sip-010-trait>))) 
	(if is-stx 
		(ok (asserts! (>= (stx-get-balance tx-sender) total-amount) ERR-INSUFFICIENT-BALANCE))
		(let 
			(
				(token (unwrap! token-contract ERR-NOTFOUND))
				(user-ft-balance (unwrap! (contract-call? token get-balance tx-sender) ERR-NOTFOUND))
				(user-stx-balance (stx-get-balance tx-sender))
				(service-fee (unwrap! (get ft (get-fees)) ERR-NOTFOUND))
			) 
			(asserts! (unwrap! (unwrap! (contract-call? .boostx-supported-tokens get-token-status token) ERR-NOTFOUND) ERR-NOTFOUND) ERR-TOKEN-NOT-SUPPORTED)
			(asserts! (>= user-ft-balance total-amount) ERR-INSUFFICIENT-BALANCE)
			(asserts! (>= user-stx-balance service-fee) ERR-INSUFFICIENT-BALANCE)
			(ok true)
		)
	)
)

(define-public (space-drop
	(is-stx bool)
	(message (optional (string-utf8 255)))
	(via (string-utf8 255))
	(total-amount uint)
	(token-contract (optional <sip-010-trait>))
	(recipients (list 1000 {is-stx: bool, amount: uint, recipient: principal, token-contract: (optional <sip-010-trait>)}))	
) 
	(begin				
		(try! (validate-contract-and-balance is-stx total-amount token-contract))
		(try! (fold send-token recipients (ok true)))
		(try! (stx-transfer? (unwrap! (get stx (get-fees)) ERR-NOTFOUND) tx-sender (var-get extDeployer)))
		(print 
			{
				is-stx: is-stx, 
				message: message, 
				via: via, 
				total-amount: total-amount, 
				token-contract: token-contract, 
				recipients: recipients
			}
		)
		(ok true)
	)
)


  

;; Contract initial fees values
(map-insert fee "fees" {stx: u100000, ft: u100000})