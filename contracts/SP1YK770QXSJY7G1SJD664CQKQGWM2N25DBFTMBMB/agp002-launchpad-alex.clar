(impl-trait .proposal-trait.proposal-trait)

(define-constant fee-to-address .executor-dao)
(define-constant amount-per-ticket u1) ;; number of $ALEX per IDO ticket
(define-constant wstx-per-ticket-in-fixed u100000000) ;; STX required per IDO ticket (in 8-digit fixed notation)
(define-constant tickets u1) ;; total number of IDO tickets to win $ALEX
(define-constant registration-start (+ block-height u100)) ;; block-height when registration opens
(define-constant registration-end (+ block-height u200)) ;; block-height when registration closes / claim opens
(define-constant claim-end (+ block-height u300)) ;; block-height when claim ends
(define-constant activation-threshold u1) ;; minimum number of IDO tickets to be registered before listing activates

(define-constant ONE_8 (pow u10 u8))

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .age000-governance-token mint-fixed (* amount-per-ticket tickets ONE_8) .executor-dao))
		(try! (contract-call? .alex-launchpad create-pool .age000-governance-token .lottery-ido-alex fee-to-address amount-per-ticket wstx-per-ticket-in-fixed registration-start registration-end claim-end activation-threshold))
		(contract-call? .alex-launchpad add-to-position .age000-governance-token tickets)
	)
)
