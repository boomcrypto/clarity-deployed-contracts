;; Title: DME024 Liquid Staking Pools
;; Author: rozar.btc
;;
;; Synopsis:
;; This contract is a registry of liquid staking pools. 
;; It allows the DAO to set and get the liquid staking pool for a given token.

(impl-trait .dao-traits-v1.extension-trait)

(use-trait token-trait .dao-traits-v1.sip010-ft-trait)

(define-constant err-unauthorized (err u3000))

(define-map liquid-staking-pools (string-ascii 10) principal)

;; --- Authorization check

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) err-unauthorized))
)

;; --- Liquid Staking Pools

(define-read-only (get-liquid-staking-pool (token (string-ascii 10)))
    (map-get? liquid-staking-pools token)
)

(define-public (set-liquid-staking-pool (token (string-ascii 10)) (pool-principal <token-trait>))
	(begin
		(try! (is-dao-or-extension))
        (ok (map-set liquid-staking-pools token (contract-of pool-principal)))
    )
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)

;; --- Init

(map-set liquid-staking-pools "WELSH"       .liquid-staked-welsh-v2)
(map-set liquid-staking-pools "LEO"         .liquid-staked-leo)
(map-set liquid-staking-pools "NOT"         .liquid-staked-not)
(map-set liquid-staking-pools "PEPE"        .liquid-staked-pepe)
(map-set liquid-staking-pools "ODIN"        .liquid-staked-odin)
(map-set liquid-staking-pools "LONG"        .liquid-staked-long)
(map-set liquid-staking-pools "ROO"         .liquid-staked-roo-v2)
(map-set liquid-staking-pools "GUS"         .liquid-staked-gus)
(map-set liquid-staking-pools "PLAY"        .liquid-staked-play)
(map-set liquid-staking-pools "BABYWELSH"   .liquid-staked-babywelsh)
(map-set liquid-staking-pools "MAX"         .liquid-staked-max)
(map-set liquid-staking-pools "WIF"         .liquid-staked-wif)
(map-set liquid-staking-pools "GOAT"        .liquid-staked-goat)