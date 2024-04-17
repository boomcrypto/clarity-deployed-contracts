;; This is a boilerplate contract for a proposal 


(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

(define-constant MICRO (pow u10 u2))
(define-constant STXMICRO (pow u10 u6))

(define-public (execute (sender principal))
	(begin

    ;; Title: SOCK
    ;; Description: Create 1T SOCK tokens. 5% goes to Megapont NFT holders. 50% is reserved for LP for the pair MEGA/SOCK, such that the initial pool has 2000 MEGA and 500000000000 SOCK. 44.8% is reserved for LP farming in ALEX. The remaining 0.2% goes 0.1% to whoever volunteers to deploy SOCK and deal with ALEX for listing the pair, and 0.1% to sock.btc for being a nice sock. 

    

		(print {event: "execute", sender: sender})

		(ok true)
	)
)
  