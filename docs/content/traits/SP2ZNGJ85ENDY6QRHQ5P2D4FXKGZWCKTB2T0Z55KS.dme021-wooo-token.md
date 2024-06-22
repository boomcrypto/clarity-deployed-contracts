---
title: "Trait dme021-wooo-token"
draft: true
---
```
;; Title: DME021 Wooo! Token
;; Author: rozar.btc
;;
;; Synopsis:
;;  The Wooo! Token contract implements a novel fungible token on Stacks, featuring strategic fee mechanisms for crafting, salvaging, and transferring tokens. 
;;  Designed to empower decentralized finance (DeFi) applications, it employs a game-theoretic fee distribution model that benefits early participants 
;;  by increasing the intrinsic value of sWELSH and sROO, the tokens required for crafting, through micro-transaction deposits to their liquid staking pools.
;;
;; Unique Creation Process:
;;  The WOOO Token is uniquely "crafted" through a specific process that involves combining a fixed supply two distinct tokens: sWELSH and sROO. 
;;  This method ensures that WOOO Tokens can only be created by merging these predetermined components and cannot be produced by any other means. 
;;  This creation mechanism is intended to align both communities' incentives, while combining the liquidity of the two memecoins into one.
;;  Additionally, the WOOO Token can be "salvageed" back into it's base tokens, sWELSH and sROO, whenever desired.
;;
;; Core Features:
;;
;; Game-Theory Fee Model:
;;  Token operations such as crafting, salvaging, and transferring incorporate a royality fee, which is deposited into the base token's liquidity pools. 
;;  These fees not only enhance the value of the sWELSH, sROO and WOOO tokens used in these processes but also provide direct rewards to the participants. 
;;  This setup creates a compelling economic incentive for early adoption and active engagement.
;;
;; Charisma Token Rewards:
;;  The Charisma Token is an integral part of the Dungeon Master DAO, functioning as the governance token within the Charisma app ecosystem. 
;;  This token empowers holders by allowing them to participate in decision-making processes that shape the platform's development and tokenomics. 
;;  As a governance tool, it ensures that the community has a vote on significant decisions, like the incentives defined within this contract.
;;
;; Incentive Mechanisms:
;;
;; - Crafting Costs:
;;   - A fee of 0.01% is applied to the crafted amount, which is very low but enough to drive a fly-wheel for early adoption.
;;
;; - Salvaging Costs:
;;   - A fee of 1% is applied, meant to deter frequent salvaging to keep sWELSH and sROO communities aligned.
;;
;; - Transfer Costs:
;;   - A transfer fee of 0.1% is meant to prevent excessive on-chain jeeting without discouraging necessary transfers.
;;
;; Community Fly-Wheel:
;;  Fees collected from token operations are specifically directed to the liquidity pools of Liquid Staked Welsh and Liquid Staked Roo. 
;;  These allocations enhance the value of these pools, which in turn bolsters the value of Wooo! tokens.
;;
;; Memecoin Consolidation:
;;  The Wooo! Token smart contract consolidates liquidity between various memecoins, uniting fractured liquidity in the ecosystem. 
;;  This consolidation helps enhance market efficiency and provides a more stable trading environment for all participants.
;;
;; Decentralized Administration:
;;  The protocol's parameters, including the token's name, symbol, URI, and decimals, are managed via DAO or authorized extensions. 
;;  This ensures that changes to the token's properties are overseen by the community, aligning with decentralized governance practices.
;;
;; Final Thoughts:
;;  At the end of the day, Wooo! is an experimental token designed to bring together the best of two great memecoin communities.
;;  Don't ape in with your life savings, but do have some fun. Wooo!

(impl-trait .dao-traits-v0.sip010-ft-trait)
(impl-trait .dao-traits-v0.extension-trait)

(define-constant err-unauthorized (err u3000))
(define-constant err-not-token-owner (err u4))

(define-constant supply-weight-w u10000) ;; WELSH 10B total supply
(define-constant supply-weight-r u42) ;; ROO 42M total supply
(define-constant ONE_6 (pow u10 u6)) ;; 6 decimal places

(define-constant contract (as-contract tx-sender))

(define-fungible-token wooo)

(define-data-var token-name (string-ascii 32) "Wooo! Token")
(define-data-var token-symbol (string-ascii 10) "WOOO")
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://charisma.rocks/wooo.json"))
(define-data-var token-decimals uint u4)

(define-data-var craft-reward-factor uint u0)
(define-data-var salvage-reward-factor uint u0)
(define-data-var transfer-reward-factor uint u0)

(define-data-var craft-fee-percent uint u100) ;; 0.01%
(define-data-var salvage-fee-percent uint u10000) ;; 1%
(define-data-var transfer-fee-percent uint u1000) ;; 0.1%

;; --- Authorization check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) err-unauthorized))
)

;; --- Internal DAO functions

(define-public (set-name (new-name (string-ascii 32)))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-name new-name))
	)
)

(define-public (set-symbol (new-symbol (string-ascii 10)))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-symbol new-symbol))
	)
)

(define-public (set-decimals (new-decimals uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-decimals new-decimals))
	)
)

(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-uri new-uri))
	)
)

(define-public (set-craft-reward-factor (new-craft-reward-factor uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set craft-reward-factor new-craft-reward-factor))
	)
)

(define-public (set-salvage-reward-factor (new-salvage-reward-factor uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set salvage-reward-factor new-salvage-reward-factor))
	)
)

(define-public (set-transfer-reward-factor (new-transfer-reward-factor uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set transfer-reward-factor new-transfer-reward-factor))
	)
)

(define-public (set-craft-fee-percent (new-craft-fee-percent uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set craft-fee-percent new-craft-fee-percent))
	)
)

(define-public (set-salvage-fee-percent (new-salvage-fee-percent uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set salvage-fee-percent new-salvage-fee-percent))
	)
)

(define-public (set-transfer-fee-percent (new-transfer-fee-percent uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set transfer-fee-percent new-transfer-fee-percent))
	)
)

;; --- Public functions

(define-public (craft (amount uint) (recipient principal))
    (let
        (
            (craft-reward (/ (* amount (var-get craft-reward-factor)) ONE_6))
            (amount-lsw (* amount supply-weight-w))
            (amount-lsr (* amount supply-weight-r))
            (craft-fee (/ (* amount (var-get craft-fee-percent)) ONE_6))
            (craft-fee-lsw (* craft-fee supply-weight-w))
            (craft-fee-lsr (* craft-fee supply-weight-r))
            (amount-after-fee (- amount craft-fee))
            (sender tx-sender)
        )
        ;; if craft-fee is greater than 0 then send fees to the fee-targets
        (and (> craft-fee u0) 
            (begin
                (print {craft-fee: craft-fee, craft-fee-lsw: craft-fee-lsw, craft-fee-lsr: craft-fee-lsr})
                (try! (unstake-and-deposit craft-fee-lsw craft-fee-lsr))
            )
        )
        ;; if craft reward is greater than 0 then mint to the sender
        (and (> craft-reward u0)
            (begin
                (print {craft-reward: craft-reward})
                (try! (as-contract (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint craft-reward sender)))
            )
        )
        (join amount-after-fee recipient)
    )
    
)

(define-public (salvage (amount uint) (recipient principal))
    (let
        (
            (salvage-reward (/ (* amount (var-get salvage-reward-factor)) ONE_6))
            (amount-lsw (* amount supply-weight-w))
            (amount-lsr (* amount supply-weight-r))
            (salvage-fee (/ (* amount (var-get salvage-fee-percent)) ONE_6))
            (amount-after-fee (- amount salvage-fee))
            (sender tx-sender)
        )
        ;; if salvage-fee is greater than 0 then salvage LP and send fees to the fee-targets
        (and (> salvage-fee u0) 
            (begin
                (print {salvage-fee: salvage-fee})
                (try! (split-unstake-and-deposit salvage-fee))
            )
        )
        ;; if salvage reward is greater than 0 then mint to the sender
        (and (> salvage-reward u0)
            (begin
                (print {salvage-reward: salvage-reward})
                (try! (as-contract (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint salvage-reward sender)))
            )
        )
        (split amount-after-fee recipient recipient)
    )
)

(define-public (burn (amount uint))
  (ft-burn? wooo amount tx-sender)
)

(define-read-only (get-craft-reward-factor)
	(ok (var-get craft-reward-factor))
)

(define-read-only (get-salvage-reward-factor)
	(ok (var-get salvage-reward-factor))
)

(define-read-only (get-transfer-reward-factor)
	(ok (var-get transfer-reward-factor))
)

(define-read-only (get-craft-fee-percent)
	(ok (var-get craft-fee-percent))
)

(define-read-only (get-salvage-fee-percent)
	(ok (var-get salvage-fee-percent))
)

(define-read-only (get-transfer-fee-percent)
	(ok (var-get transfer-fee-percent))
)

;; sip010-ft-trait

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(let
        (
            (transfer-reward (/ (* amount (var-get transfer-reward-factor)) ONE_6))
            (transfer-fee (/ (* amount (var-get transfer-fee-percent)) ONE_6))
            (amount-after-fee (- amount transfer-fee))
        )
		(asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) err-not-token-owner)
        ;; if transfer-fee is greater than 0 then transfer LP and send fees to the fee-targets
        (and (> transfer-fee u0)
            (begin
                (print {tx-fee: transfer-fee})   
                (try! (split-unstake-and-deposit transfer-fee))
            )
        )
        ;; if transfer reward is greater than 0 then mint to the sender
        (and (> transfer-reward u0)
            (begin
                (print {transfer-reward: transfer-reward})
                (try! (as-contract (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint transfer-reward sender)))
            )
        )
		(ft-transfer? wooo amount-after-fee sender recipient)
	)
)

(define-read-only (get-name)
	(ok (var-get token-name))
)

(define-read-only (get-symbol)
	(ok (var-get token-symbol))
)

(define-read-only (get-decimals)
	(ok (var-get token-decimals))
)

(define-read-only (get-balance (who principal))
	(ok (ft-get-balance wooo who))
)

(define-read-only (get-total-supply)
	(ok (ft-get-supply wooo))
)

(define-read-only (get-token-uri)
	(ok (var-get token-uri))
)

;; --- Utility functions

(define-private (join (amount uint) (recipient principal))
    (let
        (
            (amount-lsw (* amount supply-weight-w))
            (amount-lsr (* amount supply-weight-r))
            (sender tx-sender)
        )
        (try! (contract-call? .liquid-staked-welsh transfer amount-lsw sender contract none))
        (try! (contract-call? .liquid-staked-roo transfer amount-lsr sender contract none))
        (try! (ft-mint? wooo amount recipient))
        (ok true)
    )
)

(define-private (split (amount uint) (recipient-a principal) (recipient-b principal))
    (let
        (
            (amount-lsw (* amount supply-weight-w))
            (amount-lsr (* amount supply-weight-r))
            (sender tx-sender)
        )
        (try! (ft-burn? wooo amount sender))
        (try! (contract-call? .liquid-staked-welsh transfer amount-lsw contract recipient-a none))
        (try! (contract-call? .liquid-staked-roo transfer amount-lsr contract recipient-b none))
        (ok true)
    )
)

(define-private (split-unstake-and-deposit (amount uint))
    (let
        (
            (amount-lsw (* amount supply-weight-w))
            (amount-lsr (* amount supply-weight-r))
            (sender tx-sender)
        )
        (try! (ft-burn? wooo amount sender))
        (try! (as-contract (unstake-and-deposit amount-lsw amount-lsr)))
        (ok true)
    )
)

(define-private (unstake-and-deposit (amount-lsw uint) (amount-lsr uint))
    (let
        (
            (exchange-rate-w (contract-call? .liquid-staked-welsh calculate-exchange-rate))
            (exchange-rate-r (contract-call? .liquid-staked-roo get-exchange-rate))
            (amount-welsh (/ (* amount-lsw exchange-rate-w) ONE_6))
            (amount-roo (/ (* amount-lsr exchange-rate-r) ONE_6))
        )
        (try! (contract-call? .liquid-staked-welsh unstake amount-lsw))
        (try! (contract-call? .liquid-staked-roo unstake amount-lsr))
        (try! (contract-call? .liquid-staked-welsh deposit amount-welsh))
        (try! (contract-call? .liquid-staked-roo deposit amount-roo))
        (ok true)
    )
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)
```
