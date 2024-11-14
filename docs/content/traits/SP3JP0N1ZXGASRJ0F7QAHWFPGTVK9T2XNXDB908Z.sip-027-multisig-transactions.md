---
title: "Trait sip-027-multisig-transactions"
draft: true
---
```
;; Title: Non-sequential Multisig Transactions
;; Author: Jeff Bencin, Vlad Bespalov
;; Synopsis:
;; Improves handling of multisig transactions on the Stacks Blockchain.
;; Description:
;; This SIP proposes a new multisig transaction format which is 
;; intended to be easier to use than the current format described 
;; in SIP-005. It does not remove support for the current format, 
;; rather it is intended to co-exist with the old format and give 
;; users a choice of which format to use.
;;
;; The issue with the current format is that it establishes a signer 
;; order when funds are sent to multisig account address, and requires 
;; signers to sign in the same order to spend the funds. In practice, the 
;; current format has proven difficult to understand and implement, as 
;; evidenced by the lack of Stacks multisig implementations today.
;;
;; This new format intends to simplify the signing algorithm and remove 
;; the requirement for in-order signing, without compromising on security 
;; or increasing transaction size. It is expected that this will lead to 
;; better wallet support for Stacks multisig transactions.

(impl-trait 'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(ok true)
)
```
