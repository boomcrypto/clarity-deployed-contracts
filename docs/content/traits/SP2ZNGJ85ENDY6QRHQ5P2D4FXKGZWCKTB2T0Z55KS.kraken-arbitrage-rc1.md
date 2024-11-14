---
title: "Trait kraken-arbitrage-rc1"
draft: true
---
```
;; Kraken Arbitrage Interaction Wrapper
;;
;; This contract serves as a crucial interface for arbitrage functions within the 
;; Charisma protocol's interaction-based system. It implements the interaction-trait,
;; allowing seamless integration of arbitrage opportunities with the protocol's 
;; exploration mechanism.
;;
;; Primary Purpose:
;; The main goal of this contract is to decentralize access to arbitrage opportunities,
;; enabling fair and distributed participation across the Charisma ecosystem. By making
;; these actions available as interactions, the contract allows any user to potentially
;; benefit from market inefficiencies as part of their exploration activities.
;;
;; Key Features:
;; 1. Decentralized Arbitrage: Enables any user to execute arbitrage strategies during exploration.
;; 2. Multiple Strategies: Offers four different arbitrage strategies (STRW1, STRW2, STRR1, STRR2).
;; 3. Integration with Exploration: Can be included in every explore request, distributing arbitrage opportunities.
;; 4. Fixed Input Amount: Uses a predetermined amount (25,000,000) for each arbitrage attempt.
;;
;; Actions:
;; - STRW1: Execute the first Welsh Corgi Coin arbitrage strategy.
;; - STRW2: Execute the second Welsh Corgi Coin arbitrage strategy.
;; - STRR1: Execute the first Roo Coin arbitrage strategy.
;; - STRR2: Execute the second Roo Coin arbitrage strategy.
;;
;; Integration with Charisma Ecosystem:
;; - Implements the interaction-trait for compatibility with the exploration system.
;; - Interacts directly with the ProfiterolV2 contract for executing arbitrage strategies.
;; - Can be included in the Dungeon Crawler's explore function for widespread accessibility.
;;
;; Significance in the Ecosystem:
;; 1. Market Efficiency: Helps maintain price equilibrium across different markets.
;; 2. Fair Opportunity: Provides all users equal access to potential arbitrage profits.
;; 3. Increased Liquidity: Encourages more frequent trading and transfers between markets.
;; 4. Risk Distribution: Spreads arbitrage-related risks across many participants instead of concentrating them.
;;
;; Security and Control:
;; - Uses a fixed input amount to limit potential risks or exploits.
;; - Admin function for updating the contract URI, controlled by the contract owner.
;;
;; Usage in Exploration:
;; When included in explore requests, this contract allows users to potentially execute
;; arbitrage strategies with each exploration action. This mechanism ensures that arbitrage
;; opportunities are fairly distributed among all active participants in the Charisma ecosystem.
;;
;; Economic Impact:
;; - Helps in price discovery across different markets.
;; - Potentially reduces spreads and increases overall market efficiency.
;; - Creates an additional incentive for users to actively participate in the ecosystem.
;;
;; By enabling decentralized and fair access to arbitrage opportunities, this contract 
;; plays a vital role in maintaining the health, efficiency, and fairness of the Charisma
;; ecosystem. It embodies the protocol's commitment to distributed participation and 
;; equal opportunity for all users engaging with the Charisma platform, while also 
;; contributing to overall market stability and liquidity.

;; Implement the interaction-trait
(impl-trait .dao-traits-v6.interaction-trait)

;; Constants
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_INVALID_ACTION (err u402))
(define-constant CONTRACT_OWNER tx-sender)

;; Data Variables
(define-data-var contract-uri (optional (string-utf8 256)) (some u"https://charisma.rocks/explore/kraken-arbitrage"))

;; Read-only functions

(define-read-only (get-interaction-uri)
  (ok (var-get contract-uri))
)

(define-read-only (get-actions)
  (ok (list "STRW1" "STRW2" "STRR1" "STRR2"))
)

;; Public functions

(define-public (execute (action (string-ascii 32)))
  (let 
    ((sender tx-sender))
    (if (is-eq action "STRW1")
      (strw1-wrapper)
      (if (is-eq action "STRW2")
        (strw2-wrapper)
        (if (is-eq action "STRR1")
          (strr1-wrapper)
          (if (is-eq action "STRR2")
            (strr2-wrapper)
            ERR_INVALID_ACTION
          )
        )
      )
    )
  )
)

;; Private wrapper functions

(define-private (strw1-wrapper)
  (match (contract-call? 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE.profiterolv2 strw1 u25000000) success (ok true) failure (err failure))
)

(define-private (strw2-wrapper)
  (match (contract-call? 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE.profiterolv2 strw2 u25000000) success (ok true) failure (err failure))
)

(define-private (strr1-wrapper)
  (match (contract-call? 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE.profiterolv2 strr1 u25000000) success (ok true) failure (err failure))
)

(define-private (strr2-wrapper)
  (match (contract-call? 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE.profiterolv2 strr2 u25000000) success (ok true) failure (err failure))
)

;; Admin functions

(define-public (set-contract-uri (new-uri (optional (string-utf8 256))))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (ok (var-set contract-uri new-uri))
  )
)
```
