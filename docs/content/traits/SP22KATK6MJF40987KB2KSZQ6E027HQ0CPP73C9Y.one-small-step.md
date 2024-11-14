---
title: "Trait one-small-step"
draft: true
---
```
;; by highroller.btc
;; One giant leap for Stacks Kind.

(define-private (transa (address principal))
 (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.token-lqstx transfer u6900000 tx-sender address none))

(define-private (whiteList (address bool))
 (contract-call? 'SP22KATK6MJF40987KB2KSZQ6E027HQ0CPP73C9Y.StakeForRock set-hardRock true))

(define-private (transc (address principal))
 (contract-call? 'SP4M2C88EE8RQZPYTC4PZ88CE16YGP825EYF6KBQ.stacks-rock transfer u169690000000 tx-sender address none))



(transa 'SP22KATK6MJF40987KB2KSZQ6E027HQ0CPP73C9Y.SendLiSA)
(whiteList true)
(transc 'SP22KATK6MJF40987KB2KSZQ6E027HQ0CPP73C9Y.StakeForRock)
```
