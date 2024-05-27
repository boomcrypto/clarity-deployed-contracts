;; Title: DME022 Wooo! Title Belt NFT
;; Author: rozar.btc
;;
;; Synopsis:
;; The "Wooo! Title Belt" is awarded to the highest balance holder of Wooo! tokens.
;; This contract automatically transfers the belt to the highest balance recordholder.

(impl-trait .dao-traits-v1.extension-trait)
(impl-trait .dao-traits-v1.nft-trait)

(define-constant err-unauthorized (err u3000))
(define-constant err-balance-not-found (err u404))

(define-constant ONE_6 (pow u10 u6)) ;; 6 decimal places

(define-non-fungible-token wooo-title-belt uint)

(define-data-var token-uri (optional (string-ascii 256)) (some "https://charisma.rocks/wooo-title-belt.json"))
(define-data-var current-title-holder principal tx-sender)
(define-data-var highest-balance-record uint u0)
(define-data-var reward-payout-multiplier uint u0)

;; --- Authorization check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) err-unauthorized))
)

;; --- Rewards

(define-public (set-reward-payout-multiplier (new-reward-payout-multiplier uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set reward-payout-multiplier new-reward-payout-multiplier))
	)
)

(define-read-only (get-reward-payout-multiplier)
	(ok (var-get reward-payout-multiplier))
)

;; --- NFT Traits

(define-public (set-token-uri (new-uri (optional (string-ascii 256))))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-uri new-uri))
	)
)

(define-public (get-last-token-id)
    (ok u0)
)

(define-public (get-token-uri (id uint))
   (ok (var-get token-uri))
)

(define-public (get-owner (id uint))
    (ok (some (var-get current-title-holder)))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal))
    err-unauthorized
)

(define-public (challenge-title-holder)
    (check-and-update-highest-balance tx-sender)
)

;; --- Utility

(define-private (check-and-update-highest-balance (challenger principal))
    (let (
        (current-balance (unwrap! (contract-call? .dme021-wooo-token get-balance challenger) err-balance-not-found))
        (record-balance (var-get highest-balance-record))
    )
    (asserts! (not (is-eq challenger (var-get current-title-holder))) err-unauthorized)
    (if (> current-balance record-balance)
        (let (
                (reward-amount (/ (* current-balance (var-get reward-payout-multiplier)) ONE_6))
            )
            (print {new-title-holder: challenger, new-record-balance: current-balance})
            (var-set highest-balance-record current-balance)
            (try! (nft-transfer? wooo-title-belt u0 (var-get current-title-holder) challenger))
            (and (> reward-amount u0)
                (begin
                    (print {reward-payout: reward-amount})
                    (try! (as-contract (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint reward-amount challenger)))
                )
            )
            (ok true)
        )
        (ok false))
    )
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)

;; --- Init

(nft-mint? wooo-title-belt u0 tx-sender)
