;;     _____________  _______ _________  ___  ___  ____  ____
;;     / __/_  __/ _ |/ ___/ //_/ __/ _ \/ _ \/ _ |/ __ \/ __/
;;     _\ \  / / / __ / /__/ ,< / _// , _/ // / __ / /_/ /\ \  
;;    /___/ /_/ /_/ |_\___/_/|_/___/_/|_/____/_/ |_\____/___/  
;;                                                          
;;     _____  _____________  ______________  _  __           
;;    / __/ |/_/_  __/ __/ |/ / __/  _/ __ \/ |/ /           
;;   / _/_>  <  / / / _//    /\ \_/ // /_/ /    /            
;;  /___/_/|_| /_/ /___/_/|_/___/___/\____/_/|_/             

(use-trait proposal-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)
(use-trait sip010-ft-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.sip010-ft-trait.sip010-ft-trait)

(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.extension-trait.extension-trait)

(define-constant ERR_UNAUTHORIZED (err u2600))
(define-constant ERR_UNAUTHORIZED_PROPOSER (err u2601))
(define-constant ERR_UNKNOWN_PARAMETER (err u2602))
(define-constant ERR_PROPOSAL_MINIMUM_START_DELAY (err u2603))
(define-constant ERR_PROPOSAL_MAXIMUM_START_DELAY (err u2604))

(define-map parameters (string-ascii 34) uint)

(map-set parameters "proposeThreshold" (get-micro-balance u250))
(map-set parameters "proposalDuration" u720)
(map-set parameters "minimumProposalStartDelay" u144)
(map-set parameters "maximumProposalStartDelay" u1008)

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .mega-dao) (contract-call? .mega-dao is-extension contract-caller)) ERR_UNAUTHORIZED))
)

(define-public (set-parameter (parameter (string-ascii 34)) (value uint))
	(begin
		(try! (is-dao-or-extension))
		(try! (get-parameter parameter))
		(ok (map-set parameters parameter value))
	)
)

(define-private (set-parameters-iter (item {parameter: (string-ascii 34), value: uint}) (previous (response bool uint)))
	(begin
		(try! previous)
		(try! (get-parameter (get parameter item)))
		(ok (map-set parameters (get parameter item) (get value item)))
	)
)

(define-public (set-parameters (parameter-list (list 200 {parameter: (string-ascii 34), value: uint})))
	(begin
		(try! (is-dao-or-extension))
		(fold set-parameters-iter parameter-list (ok true))
	)
)

(define-read-only (get-micro-balance (amount uint))
	(let
		(
			(decimals (unwrap-panic (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.mega get-decimals)))
			(micro (pow u10 decimals))
		)
		(* micro amount)
	)
)

(define-read-only (get-parameter (parameter (string-ascii 34)))
	(ok (unwrap! (map-get? parameters parameter) ERR_UNKNOWN_PARAMETER))
)

(define-read-only (can-propose (who principal) (tokenThreshold uint))
	(let
		(
			(balance (unwrap-panic (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.mega get-balance who)))
		)
		(>= balance tokenThreshold)
	)
)

(define-public (propose (proposal <proposal-trait>) (startBlockHeight uint))
	(begin	
		(asserts! (>= startBlockHeight (+ block-height (try! (get-parameter "minimumProposalStartDelay")))) ERR_PROPOSAL_MINIMUM_START_DELAY)
		(asserts! (<= startBlockHeight (+ block-height (try! (get-parameter "maximumProposalStartDelay")))) ERR_PROPOSAL_MAXIMUM_START_DELAY)
		(asserts! (can-propose tx-sender (try! (get-parameter "proposeThreshold"))) ERR_UNAUTHORIZED_PROPOSER)
		(contract-call? .mega-proposal-voting-v2 add-proposal
			proposal
			{
				startBlockHeight: startBlockHeight,
				endBlockHeight: (+ startBlockHeight (try! (get-parameter "proposalDuration"))),
				proposer: tx-sender
			}
		)
	)
)

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)