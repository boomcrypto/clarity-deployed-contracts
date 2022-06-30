;;     _____________  _______ _________  ___  ___  ____  ____
;;     / __/_  __/ _ |/ ___/ //_/ __/ _ \/ _ \/ _ |/ __ \/ __/
;;     _\ \  / / / __ / /__/ ,< / _// , _/ // / __ / /_/ /\ \  
;;    /___/ /_/ /_/ |_\___/_/|_/___/_/|_/____/_/ |_\____/___/  
;;                                                          
;;     _____  _____________  ______________  _  __           
;;    / __/ |/_/_  __/ __/ |/ / __/  _/ __ \/ |/ /           
;;   / _/_>  <  / / / _//    /\ \_/ // /_/ /    /            
;;  /___/_/|_| /_/ /___/_/|_/___/___/\____/_/|_/             

(use-trait sip010-ft-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.sip010-ft-trait.sip010-ft-trait)
(use-trait proposal-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.extension-trait.extension-trait)

(define-constant ERR_UNAUTHORIZED (err u2600))
(define-constant ERR_NOT_GOVERNANCE_TOKEN (err u2601))
(define-constant ERR_INSUFFICIENT_WEIGHT (err u2602))
(define-constant ERR_UNKNOWN_PARAMETER (err u2603))
(define-constant ERR_PROPOSAL_MINIMUM_START_DELAY (err u2604))
(define-constant ERR_PROPOSAL_MAXIMUM_START_DELAY (err u2605))

(define-constant MICRO (pow u10 u2))

(define-data-var governanceTokenPrincipal principal 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.mega)

(define-map parameters (string-ascii 34) uint)

(map-set parameters "proposeThreshold" u150) ;; Tokens required to submit a proposal
(map-set parameters "proposalDuration" u432) ;; ~3 days based on a ~10 minute block time
(map-set parameters "minimumProposalStartDelay" u288) ;; ~2 day minimum delay before voting on a proposal can start
(map-set parameters "maximumProposalStartDelay" u1008) ;; ~7 days maximum delay before voting on a proposal can start

;; --- Authorization check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .mega-dao) (contract-call? .mega-dao is-extension contract-caller)) ERR_UNAUTHORIZED))
)

;; --- Internal DAO functions

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

(define-read-only (get-governance-token)
	(var-get governanceTokenPrincipal)
)

(define-private (is-governance-token (governanceToken <sip010-ft-trait>))
	(ok (asserts! (is-eq (contract-of governanceToken) (var-get governanceTokenPrincipal)) ERR_NOT_GOVERNANCE_TOKEN))
)

(define-read-only (get-parameter (parameter (string-ascii 34)))
	(ok (unwrap! (map-get? parameters parameter) ERR_UNKNOWN_PARAMETER))
)

(define-public (can-propose (who principal) (tokenThreshold uint) (governanceToken <sip010-ft-trait>))
	(let
		(
			(balance (unwrap-panic (contract-call? governanceToken get-balance tx-sender)))
		)
		(ok (>= balance (* MICRO tokenThreshold)))
	)
)

(define-public (propose (proposal <proposal-trait>) (startBlockHeight uint) (governanceToken <sip010-ft-trait>))
	(begin	
		(try! (is-governance-token governanceToken))
		(asserts! (>= startBlockHeight (+ block-height (try! (get-parameter "minimumProposalStartDelay")))) ERR_PROPOSAL_MINIMUM_START_DELAY)
		(asserts! (<= startBlockHeight (+ block-height (try! (get-parameter "maximumProposalStartDelay")))) ERR_PROPOSAL_MAXIMUM_START_DELAY)
		(asserts! (unwrap-panic (can-propose tx-sender (try! (get-parameter "proposeThreshold")) governanceToken)) ERR_INSUFFICIENT_WEIGHT)
		(contract-call? 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mde-proposal-voting add-proposal
			proposal
			{
				startBlockHeight: startBlockHeight,
				endBlockHeight: (+ startBlockHeight (try! (get-parameter "proposalDuration"))),
				proposer: tx-sender
			}
		)
	)
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)