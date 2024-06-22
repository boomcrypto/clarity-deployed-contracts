;; Title: The Green Room
;; Author: rozar.btc
;;
;; A special list of guests can claim free tokens every block. The amount of tokens they can claim is set by the DAO.
;; Everyone on this list has contributed to the project in some substantial way and can now claim from a private faucet.

(impl-trait .dao-traits-v2.extension-trait)

(define-constant err-unauthorized (err u3100))
(define-constant err-insufficient-balance (err u3102))
(define-constant err-not-on-guestlist (err u4069))

(define-data-var drip-amount uint u0)
(define-data-var last-claim uint block-height)
(define-data-var total-issued uint u0)

(define-map guestlist principal bool)

;; --- Authorization check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) err-unauthorized))
)

;; --- Internal DAO functions

(define-public (set-drip-amount (amount uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set drip-amount amount))
	)
)

(define-public (set-guestlist (user principal) (status bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set guestlist user status))
	)
)

;; --- Public functions

(define-public (claim)
	(let
		(
			(sender tx-sender)
      (tokens-available (* (var-get drip-amount) (- block-height (var-get last-claim))))
			(guestlisted (check-guestlist sender))
		)
		(asserts! guestlisted err-not-on-guestlist)
    (asserts! (> tokens-available u0) err-insufficient-balance)
    (var-set last-claim block-height)
    (var-set total-issued (+ (var-get total-issued) tokens-available))		
    (as-contract (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint tokens-available sender))
	)
)

(define-read-only (check-guestlist (user principal))
	(default-to false (map-get? guestlist user))
)

(define-read-only (get-drip-amount)
	(ok (var-get drip-amount))
)

(define-read-only (get-last-claim)
	(ok (var-get last-claim))
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)

;; --- Init

(map-set guestlist 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS true)
(map-set guestlist 'SP3T1M18J3VX038KSYPP5G450WVWWG9F9G6GAZA4Q true)
(map-set guestlist 'SP18PPN7EFBEFG6C5N0JAGMZZ98CEHX8JA08Y7VVS true)
(map-set guestlist 'SP2T7NK63XRQ1K08EYFGFEYS2SV3A04ZJWRK0GY60 true)
(map-set guestlist 'SP1M76XXM6E1AC6JTN70S14EX9K9B2Y8ZTS04T9Q0 true)
(map-set guestlist 'SP11F09DT5HFYN7Z5HG15QXW0CMD40T2XJYY0G5AB true)
(map-set guestlist 'SP2FA1H3K9FMY2CQ80WWT2JYMHZ5Z2B810AT41APW true)
(map-set guestlist 'SPSTE5R54386QDCDNJJWH2EXQFST44QYZW3RPMD3 true)
(map-set guestlist 'SP1NQ0WG5PTB7M2N3PNNPG5XFD7N14VXKHZ9NQP08 true)
(map-set guestlist 'SP3NJ4BR35W8002J0PWZY0QNG9FTYZ32H38Z0PV17 true)
(map-set guestlist 'SP26YN47AQF3Y608RA3WXKMX8XQRBYQ63EP541THF true)
(map-set guestlist 'SP38WHM5S9G74DAS4CARSR0NDC27VZHTP4P9Q9AHK true)
(map-set guestlist 'SPB8H6K97YY2TEWP726SG652KSJVNB6GJQ6RTMYE true)
(map-set guestlist 'SP3SV6SSVHZVGTT5HWESXQZPDQ1VHM2FW6NBH11NN true)
(map-set guestlist 'SP1XQW0Q4A89HYVJYMVZ0BSPX4M8FD555KBV0W9CA true)
(map-set guestlist 'SP2MYS2F77WK4VGK22EX3GQ6155BW63AJ3RDX8Y30 true)
(map-set guestlist 'SPQVRXETS9PPXMRKMTD4K9D221CB1NWCG7J2H8RM true)
(map-set guestlist 'SP3J1ZV7W56PTRJV33HCQJB4GQHWJG3H0TV6WW9S0 true)
(map-set guestlist 'SP1PP386VVPRJHV7REMVMRZ2YH6ZJBNB1EAYB3ABC true)
(map-set guestlist 'SP1WSVH1QFM9DF1Z0JE58SKEX4WCRKDTYM6KYW6JT true)
(map-set guestlist 'SPQ8D2TV5QJWAQHFEZNJEMEKXAD4BV6ZQB21714E true)