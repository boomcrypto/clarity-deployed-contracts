;; Title: SIP-029: Bootstrapping sBTC Liquidity and Nakamoto Signer Incentives
;; Author(s): Alex Miller, Andre Serrano, Brittany Laughlin, Jesse Wiley,
;; Jude Nelson, Philip De Smedt, Tycho Onnasch, Will Corcoran
;; Synopsis:
;; Extends the current emission rate of 1000 STX per block.
;; Description:
;; The first Stacks halving is expected to take place at Stacks block height 210,384, 
;; which is set to occur during Reward Cycle 100 in December 2024, cutting the STX block 
;; reward from 1,000 STX to 500 STX. This SIP proposes a modification to the emissions 
;; schedule given that the network is going through two major launches (Nakamoto and sBTC) 
;; which rely on predictable economic incentives. The proposed schedule modification 
;; and associated STX emission rate would create time for Nakamoto and sBTC to launch 
;; and settle in, but, being mindful of supply, would still result in an overall reduced 
;; target 2050 STX supply (0.19% lower) and a reduced tail emission rate (20% lower).



(impl-trait .proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(ok true)
)
