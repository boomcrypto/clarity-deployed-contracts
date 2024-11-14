---
title: "Trait sip028-sbtc-signer-criteria"
draft: true
---
```
;; Title: SIP-028: sBTC Signer Criteria
;; Author(s): Andre Serrano, Ashton Stephens, Joey Yandle,
;; Marten Blankfors, Jesus Najera, Jude Nelson, Friedger Muffke,
;; Tycho Onnasch, Daniel Jordon
;; Synopsis:
;; Signer Criteria for sBTC, A Decentralized and Programmable Asset Backed 1:1 with BTC.
;; Description:
;; This SIP takes the position that Stacks can play a key
;; role in offering a rich programming environment for Bitcoin
;; with low-latency transactions. This would be achieved with a
;; new wrapped Bitcoin asset, called sBTC, which would be implemented
;; on Stacks 3.0 and later as a SIP-010 token. Stacks today offers
;; a smart contract runtime for Stacks-hosted assets, and the
;; forthcoming Stacks 3.0 release provides lower transaction latency
;; than Bitcoin for Stacks transactions. By providing a robust BTC-wrapping
;; mechanism based on threshold signatures, users would be able to lock
;; their real BTC on the Bitcoin chain, instantiate an equal amount
;; of sBTC tokens on Stacks, use these sBTC tokens on Stacks, and
;; eventually redeem them for real BTC at 1:1 parity, minus the cost of
;; the relevant blockchain transaction fees.

(impl-trait .proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(ok true)
)

```
