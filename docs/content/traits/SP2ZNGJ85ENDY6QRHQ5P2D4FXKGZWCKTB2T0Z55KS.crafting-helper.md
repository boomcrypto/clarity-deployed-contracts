---
title: "Trait crafting-helper"
draft: true
---
```
;; Title: Crafting Helper
;; Author: rozar.btc

(impl-trait .dao-traits-v2.extension-trait)

(use-trait liquid-ft-trait .dao-traits-v2.liquid-ft-trait)
(use-trait craftable-trait .dao-traits-v2.craftable-trait)

(define-constant err-unauthorized (err u3000))
(define-constant err-messy-recipe (err u4024))
(define-constant err-unknown-recipe (err u3004))

(define-map crafting-recipes
    principal 
    {
        lsp-a: principal,
        lsp-b: principal
    }
)

;; --- Authorization check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) err-unauthorized))
)

;; --- Internal DAO functions

(define-public (set-crafting-recipe (craftable-token <craftable-trait>) (lsp-a <liquid-ft-trait>) (lsp-b <liquid-ft-trait>))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set crafting-recipes (contract-of craftable-token) {lsp-a: (contract-of lsp-a), lsp-b: (contract-of lsp-b)}))
	)
)

;; --- Public functions


(define-read-only (get-crafting-recipe (craftable-token <craftable-trait>))
	(map-get? crafting-recipes (contract-of craftable-token))
)

(define-public (craft (craftable-token <craftable-trait>) (amount uint) (lft-a <liquid-ft-trait>) (lft-b <liquid-ft-trait>))
    (let (
        (recipe (unwrap! (get-crafting-recipe craftable-token) err-unknown-recipe))
    )
        (asserts! (is-eq (contract-of lft-a) (get lsp-a recipe)) err-messy-recipe)
        (asserts! (is-eq (contract-of lft-b) (get lsp-b recipe)) err-messy-recipe)
        (try! (contract-call? craftable-token craft amount tx-sender lft-a lft-b))
        (ok true)
    )
)

(define-public (salvage (craftable-token <craftable-trait>) (amount uint) (lft-a <liquid-ft-trait>) (lft-b <liquid-ft-trait>))
    (let (
        (recipe (unwrap! (get-crafting-recipe craftable-token) err-unknown-recipe))
    )
        (asserts! (is-eq (contract-of lft-a) (get lsp-a recipe)) err-messy-recipe)
        (asserts! (is-eq (contract-of lft-b) (get lsp-b recipe)) err-messy-recipe)
        (try! (contract-call? craftable-token salvage amount tx-sender lft-a lft-b))
        (ok true)
    )
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)

;; --- Init

(map-set crafting-recipes .fenrir-corgi-of-ragnarok {
    lsp-a: .liquid-staked-welsh-v2,
    lsp-b: .liquid-staked-odin
})
```
