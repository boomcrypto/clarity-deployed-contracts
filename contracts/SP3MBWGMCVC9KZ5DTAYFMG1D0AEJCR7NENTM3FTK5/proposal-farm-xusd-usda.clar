;; @contract Governance proposal
;; @version 1.1

(impl-trait .lydian-dao-proposal-trait.lydian-dao-proposal-trait)

;; ------------------------------------------
;; Execute
;; ------------------------------------------

(define-public (execute)

  ;; Put 50k of the idle USDA to good use in the relaunched StableSwap xUSD/USDA on ALEX 
  ;; to earn fees from all trades in the pool and to stake the pool tokens on Arkadiko
  ;; https://discord.com/channels/923585641554518026/1080742544037662800

  (ok true)
)