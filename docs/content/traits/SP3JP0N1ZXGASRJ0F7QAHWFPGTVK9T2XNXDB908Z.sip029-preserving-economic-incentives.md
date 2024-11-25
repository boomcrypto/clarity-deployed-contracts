---
title: "Trait sip029-preserving-economic-incentives"
draft: true
---
```
;; Title: SIP-029 Preserving Economic Incentives During Stacks Network Upgrades
;; Author(s): Alex Miller, Andre Serrano, Brittany Laughlin, Jesse Wiley,
;; Jude Nelson, Philip De Smedt, Tycho Onnasch, Will Corcoran
;; Synopsis:
;; This SIP proposes a modification to the emissions schedule.
;; Description:
;; The first Stacks halving is expected to take place 210,384 Bitcoin blocks after the 
;; Stacks 2.0 starting height, 666,050, which is Bitcoin height 876,434, which is set to 
;; occur during Reward Cycle 100 in December 2024, cutting the STX block reward from 
;; 1,000 STX to 500 STX. This SIP proposes a modification to the emissions schedule given 
;; that the network is going through two major launches (Nakamoto and sBTC) which rely on 
;; predictable economic incentives. The proposed schedule modification and associated STX 
;; emission rate would create time for Nakamoto and sBTC to launch and settle in, but, being 
;; mindful of supply, would still result in an overall reduced target 2050 STX supply (0.77% lower) 
;; and a reduced tail emission rate (50% lower).



(impl-trait .proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(ok true)
)

```
