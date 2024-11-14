---
title: "Trait sip028-signer-criteria-for-sbtc"
draft: true
---
```
;; Title: SIP-028: sBTC Signer Criteria
;; Author(s): Adriano Di Luzio, Andre Serrano, Ashton Stephens, Daniel Jordon, 
;; Friedger Muffke, Jesus Najera, Joey Yandle, Jude Nelson, Marten Blankfors,
;; Tycho Onnasch
;; Synopsis:
;; Signer Criteria for sBTC, A Decentralized and Programmable Asset Backed 1:1 with BTC.
;; Description:
;; This SIP proposes a new wrapped Bitcoin asset, called sBTC, which would be 
;; implemented on Stacks as a SIP-010 token. sBTC enables seamless and secure 
;; integration of Bitcoin into the Stacks ecosystem, unlocking decentralized 
;; applications and expanding Bitcoin's utility through smart contracts. Stacks 
;; today offers a smart contract runtime for Stacks-hosted assets, and the forthcoming 
;; Stacks 3.0 release provides lower transaction latency than Bitcoin for Stacks transactions. 
;; By providing a robust BTC-wrapping mechanism based on threshold signatures, users would 
;; be able to lock their real BTC on the Bitcoin chain, instantiate an equal amount of sBTC 
;; tokens on Stacks, use these sBTC tokens on Stacks, and eventually redeem them for real BTC 
;; at 1:1 parity, minus the cost of the relevant blockchain transaction fees.
;; 
;; This is the first of several SIPs that describe such a system. This SIP describes the threshold 
;; signature mechanism and solicits from the ecosystem both a list of signers and the criteria 
;; for vetting them. These sBTC signers would be responsible for collectively holding all locked 
;; BTC and redeeming sBTC for BTC upon request. Given the high-stakes nature of their work, 
;; the authors of this SIP believe that such a wrapped asset can only be made to work in practice 
;; if the Stacks ecosystem members can reach broad consensus on how these signers are chosen. Thus, 
;; the first sBTC SIP put forth for activation concerns the selection of sBTC signers.
;; 
;; This SIP outlines but does not describe in technical detail the workings of the first sBTC system. 
;; A separate SIP will be written to do so if this SIP successfully activates.

(impl-trait .proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(ok true)
)

```
