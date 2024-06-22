---
title: "Trait dme020-woooooo-token"
draft: true
---
```
;; Title: DME020 Woooooo! Token
;; Author: rozar.btc
;;
;; Synopsis:
;;  The Woooooo! Token contract implements a novel fungible token on Stacks, featuring strategic fee mechanisms for minting, burning, and transferring tokens. 
;;  Designed to empower decentralized finance (DeFi) applications, it employs a game-theoretic fee distribution model that benefits early participants 
;;  by increasing the intrinsic value of sWELSH and sROO, the tokens required for minting, through micro-transaction deposits to their liquid staking pools.
;;
;; Unique Creation Process:
;;  The WOO Token is uniquely "minted" through a specific process that involves combining a fixed supply two distinct tokens: sWELSH and sROO. 
;;  This method ensures that WOO Tokens can only be created by merging these predetermined components and cannot be produced by any other means. 
;;  This creation mechanism is intended to align both communities' incentives, while combining the liquidity of the two memecoins into one.
;;  Additionally, the WOO Token can be "burned" back into it's base tokens, sWELSH and sROO, whenever desired.
;;
;; Core Features:
;;
;; Game-Theory Fee Model:
;;  Token operations such as minting, burning, and transferring incorporate a royality fee, which is deposited into the base token's liquidity pools. 
;;  These fees not only enhance the value of the sWELSH, sROO and WOO tokens used in these processes but also provide direct rewards to the participants. 
;;  This setup creates a compelling economic incentive for early adoption and active engagement.
;;
;; Charisma Token Rewards:
;;  The Charisma Token is an integral part of the Dungeon Master DAO, functioning as the governance token within the Charisma app ecosystem. 
;;  This token empowers holders by allowing them to participate in decision-making processes that shape the platform's development and tokenomics. 
;;  As a governance tool, it ensures that the community has a vote on significant decisions, like the incentives defined within this contract.
;;
;; Incentive Mechanisms:
;;
;; - Minting Rewards and Fees:
;;   - Rewards: Minting tokens is highly incentivized with a reward factor of 100x, a subtaintial amount of Charisma tokens.
;;   - Fees: A fee of 0.01% is applied to the minted amount, which is very low but enough to drive a fly-wheel for early adoption.
;;
;; - Burning Rewards and Fees:
;;   - Rewards: The reward for burning tokens is set at 1x, a nominal amount of Charisma tokens.
;;   - Fees: A fee of 1% is applied, meant to deter frequent burning to keep sWELSH and sROO communities aligned.
;;
;; - Transfer Rewards and Fees:
;;   - Rewards: Transferring tokens yields a reward of 1x, a nominal amount of Charisma tokens.
;;   - Fees: A transfer fee of 0.1% is meant to prevent excessive on-chain jeeting without discouraging necessary transfers.
;;
;; Community Fly-Wheel:
;;  Fees collected from token operations are specifically directed to the liquidity pools of Liquid Staked Welsh and Liquid Staked Roo. 
;;  These allocations enhance the value of these pools, which in turn bolsters the value of Woooooo! tokens.
;;
;; Memecoin Consolidation:
;;  The Woooooo! Token smart contract consolidates liquidity between various memecoins, uniting fractured liquidity in the ecosystem. 
;;  This consolidation helps enhance market efficiency and provides a more stable trading environment for all participants.
;;
;; Decentralized Administration:
;;  The protocol's parameters, including the token's name, symbol, URI, and decimals, are managed via DAO or authorized extensions. 
;;  This ensures that changes to the token's properties are overseen by the community, aligning with decentralized governance practices.
;;
;; Final Thoughts:
;;  At the end of the day, Woooooo! is an experimental token designed to bring together the best of two great memecoin communities.
;;  Don't ape in with your life savings, but do have fun and enjoy the ride. Woooooo!

(impl-trait .dao-traits-v0.sip010-ft-trait)
(impl-trait .dao-traits-v0.extension-trait)

(define-constant err-unauthorized (err u3000))
(define-constant err-not-token-owner (err u4))

(define-constant supply-weight-w u10000) ;; WELSH 10B total supply
(define-constant supply-weight-r u42) ;; ROO 42M total supply
(define-constant ONE_6 (pow u10 u6)) ;; 6 decimal places

(define-constant contract (as-contract tx-sender))

(define-fungible-token woooooo)

(define-data-var token-name (string-ascii 32) "Woooooo!")
(define-data-var token-symbol (string-ascii 10) "WOO")
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://charisma.rocks/woooooo.json"))
(define-data-var token-decimals uint u4)

(define-data-var mint-reward-factor uint u100) ;; 100x
(define-data-var burn-reward-factor uint u1) ;; 1x
(define-data-var transfer-reward-factor uint u1) ;; 1x
(define-data-var mint-fee-percent uint u100) ;; 0.01%
(define-data-var burn-fee-percent uint u10000) ;; 1%
(define-data-var transfer-fee-percent uint u1000) ;; 0.1%
(define-data-var fee-target-a principal .liquid-staked-welsh)
(define-data-var fee-target-b principal .liquid-staked-roo)

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

(define-public (set-mint-reward-factor (new-mint-reward-factor uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set mint-reward-factor new-mint-reward-factor))
	)
)

(define-public (set-burn-reward-factor (new-burn-reward-factor uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set burn-reward-factor new-burn-reward-factor))
	)
)

(define-public (set-transfer-reward-factor (new-transfer-reward-factor uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set transfer-reward-factor new-transfer-reward-factor))
	)
)

(define-public (set-mint-fee-percent (new-mint-fee-percent uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set mint-fee-percent new-mint-fee-percent))
	)
)

(define-public (set-burn-fee-percent (new-burn-fee-percent uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set burn-fee-percent new-burn-fee-percent))
	)
)

(define-public (set-transfer-fee-percent (new-transfer-fee-percent uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set transfer-fee-percent new-transfer-fee-percent))
	)
)

(define-public (set-fee-target-a (new-fee-target-a principal))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set fee-target-a new-fee-target-a))
	)
)

(define-public (set-fee-target-b (new-fee-target-b principal))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set fee-target-b new-fee-target-b))
	)
)

;; --- Public functions

(define-public (mint (amount uint) (recipient principal))
    (let
        (
            (mint-reward (/ (* amount (var-get mint-reward-factor)) ONE_6))
            (amount-lsw (* amount supply-weight-w))
            (amount-lsr (* amount supply-weight-r))
            (mint-fee (/ (* amount (var-get mint-fee-percent)) ONE_6))
            (mint-fee-lsw (* mint-fee supply-weight-w))
            (mint-fee-lsr (* mint-fee supply-weight-r))
            (amount-after-fee (- amount mint-fee))
        )
        ;; if mint-fee is greater than 0 then send fees to the fee-targets
        (and (> mint-fee u0) 
            (begin
                (print {mint-fee: mint-fee})
                (try! (contract-call? .liquid-staked-welsh transfer mint-fee-lsw tx-sender (var-get fee-target-a) none))
                (try! (contract-call? .liquid-staked-roo transfer mint-fee-lsr tx-sender (var-get fee-target-b) none))
            )
        )
        ;; if mint reward is greater than 0 then mint to the sender
        (and (> mint-reward u0)
            (begin
                (print {mint-reward: mint-reward})
                (try! (as-contract (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint mint-reward tx-sender)))
            )
        )
        (join amount-after-fee recipient)
    )
    
)

(define-public (burn (amount uint) (recipient principal))
    (let
        (
            (burn-reward (/ (* amount (var-get burn-reward-factor)) ONE_6))
            (amount-lsw (* amount supply-weight-w))
            (amount-lsr (* amount supply-weight-r))
            (burn-fee (/ (* amount (var-get burn-fee-percent)) ONE_6))
            (amount-after-fee (- amount burn-fee))
        )
        ;; if burn-fee is greater than 0 then burn LP and send fees to the fee-targets
        (and (> burn-fee u0) 
            (begin
                (print {burn-fee: burn-fee})   
                (try! (split burn-fee (var-get fee-target-a) (var-get fee-target-b)))
            )
        )
        ;; if burn reward is greater than 0 then mint to the sender
        (and (> burn-reward u0)
            (begin
                (print {burn-reward: burn-reward})
                (try! (as-contract (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint burn-reward tx-sender)))
            )
        )
        (split amount-after-fee recipient recipient)
    )
)

(define-read-only (get-mint-reward-factor)
	(ok (var-get mint-reward-factor))
)

(define-read-only (get-burn-reward-factor)
	(ok (var-get burn-reward-factor))
)

(define-read-only (get-transfer-reward-factor)
	(ok (var-get transfer-reward-factor))
)

(define-read-only (get-mint-fee-percent)
	(ok (var-get mint-fee-percent))
)

(define-read-only (get-burn-fee-percent)
	(ok (var-get burn-fee-percent))
)

(define-read-only (get-transfer-fee-percent)
	(ok (var-get transfer-fee-percent))
)

(define-read-only (get-fee-target-a)
	(ok (var-get fee-target-a))
)

(define-read-only (get-fee-target-b)
	(ok (var-get fee-target-b))
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
                (try! (split transfer-fee (var-get fee-target-a) (var-get fee-target-b)))
            )
        )
        ;; if transfer reward is greater than 0 then mint to the sender
        (and (> transfer-reward u0)
            (begin
                (print {transfer-reward: transfer-reward})
                (try! (as-contract (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint transfer-reward tx-sender)))
            )
        )
		(ft-transfer? woooooo amount-after-fee sender recipient)
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
	(ok (ft-get-balance woooooo who))
)

(define-read-only (get-total-supply)
	(ok (ft-get-supply woooooo))
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
        (try! (ft-mint? woooooo amount recipient))
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
        (try! (ft-burn? woooooo amount sender))
        (try! (contract-call? .liquid-staked-welsh transfer amount-lsw contract recipient-a none))
        (try! (contract-call? .liquid-staked-roo transfer amount-lsr contract recipient-b none))
        (ok true)
    )
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)

```
