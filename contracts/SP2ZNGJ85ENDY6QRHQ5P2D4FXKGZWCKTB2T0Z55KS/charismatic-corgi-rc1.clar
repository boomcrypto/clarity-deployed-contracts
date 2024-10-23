;; Charismatic Corgi Interaction
;;
;; This contract attempts to profit from price discrepancies in the Charisma token markets
;; by executing multi-step trades through the Welsh Corgi token path. It integrates with 
;; the Fatigue interaction to ensure proper energy costs for each attempt.
;;
;; Key Features:
;; 1. Dual Trading Paths: Offers both forward (CHA->STX->WELSH->CHA) and reverse 
;;    (CHA->WELSH->STX->CHA) arbitrage opportunities
;; 2. Energy Cost: Each attempt requires energy expenditure through the Fatigue interaction
;; 3. Profit Tracking: Maintains a record of successful arbitrage profits per user
;; 4. Auto-reinvestment: Automatically converts 1 STX to CHA after successful trades
;; 5. Configurable Input: Allows admin adjustment of trade amounts up to 100 CHA
;;
;; Actions:
;; - FORWARD: Attempts CHA -> STX -> WELSH -> CHA arbitrage path
;; - REVERSE: Attempts CHA -> WELSH -> STX -> CHA arbitrage path
;;
;; Responses:
;; - "ARBITRAGE_COMPLETE": Successfully executed profitable arbitrage
;; - "NO_PROFIT_OPPORTUNITY": Trade would not result in profit
;; - "NOT_ENOUGH_ENERGY": Insufficient energy to attempt arbitrage
;; - "INVALID_ACTION": Unrecognized action provided
;;
;; Integration with Charisma Protocol:
;; - Requires energy expenditure through Fatigue interaction
;; - Interacts with Charisma DEX for token swaps
;; - Tracks profits in protocol token (CHA)
;;
;; Security Features:
;; - Limits maximum trade size to 100 CHA
;; - Admin-only configuration functions
;; - Built-in profit tracking per user
;;
;; Usage:
;; This interaction allows adventurers to attempt arbitrage by discovering and exploiting
;; price differences in the dungeon's mysterious marketplace. Each attempt requires energy
;; and automatically reinvests successful arbitrage profits back into CHA tokens.

(impl-trait .dao-traits-v7.interaction-trait)

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_EXCEEDS_LIMIT (err u405))

;; Data Variables
(define-data-var contract-uri (optional (string-utf8 256)) 
  (some u"https://charisma.rocks/api/v0/interactions/charismatic-corgi"))

(define-data-var amount-in uint u10000000) ;; 10 CHA
(define-data-var total-profit uint u0)
(define-map profits principal uint)

;; URI Functions
(define-read-only (get-interaction-uri)
  (ok (var-get contract-uri)))

;; Action Execution
(define-public (execute (action (string-ascii 32)))
  (let ((sender tx-sender))
    (if (is-eq action "FORWARD") (try-forward-path sender)
    (if (is-eq action "REVERSE") (try-reverse-path sender)
    (err "INVALID_ACTION")))))

;; Profit Tracking
(define-private (update-profit (profit uint))
  (begin
    (map-set profits tx-sender (+ (default-to u0 (map-get? profits tx-sender)) profit))
    (var-set total-profit (+ (var-get total-profit) profit))))

;; Forward Path (CHA -> STX -> WELSH -> CHA)
(define-private (try-forward-path (sender principal))
    (begin
        (if (is-eq (unwrap-panic (contract-call? .fatigue-rc3 execute "BURN")) "ENERGY_BURNED")
            (match (contract-call? .univ2-path2 swap-4 (var-get amount-in) (var-get amount-in) .charisma-token .wstx 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token .charisma-token .univ2-share-fee-to)
                success (begin
                            (print "The adventurer successfully arbitraged the mysterious marketplace!")
                            (update-profit (var-get amount-in))
                            (match (contract-call? .univ2-path2 do-swap u1000000 .wstx .charisma-token .univ2-share-fee-to)
                                s (print "With the profits, the adventurer swapped 1 STX to CHA.")
                                e (print "Swapping 1 STX to CHA after the successful arbitrage failed."))
                            (ok "ARBITRAGE_COMPLETE"))
                error   (begin
                            (print "The arbitrage attempt yielded no profit in these market conditions.")
                            (ok "NO_PROFIT_OPPORTUNITY")))
            (ok "NOT_ENOUGH_ENERGY"))))

;; Reverse Path (CHA -> WELSH -> STX -> CHA)
(define-private (try-reverse-path (sender principal))
    (begin
        (if (is-eq (unwrap-panic (contract-call? .fatigue-rc3 execute "BURN")) "ENERGY_BURNED")
            (match (contract-call? .univ2-path2 swap-4 (var-get amount-in) (var-get amount-in) .charisma-token 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token .wstx .charisma-token .univ2-share-fee-to)
                success (begin
                            (print "The adventurer successfully arbitraged the mysterious marketplace!")
                            (update-profit (var-get amount-in))
                            (match (contract-call? .univ2-path2 do-swap u1000000 .wstx .charisma-token .univ2-share-fee-to)
                                s (print "With the profits, the adventurer swapped 1 STX to CHA.")
                                e (print "Swapping 1 STX to CHA after the successful arbitrage failed."))
                            (ok "ARBITRAGE_COMPLETE"))
                error   (begin
                            (print "The arbitrage attempt yielded no profit in these market conditions.")
                            (ok "NO_PROFIT_OPPORTUNITY")))
            (ok "NOT_ENOUGH_ENERGY"))))
       

;; Admin Functions
(define-public (set-contract-uri (new-uri (optional (string-utf8 256))))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (ok (var-set contract-uri new-uri))))

(define-public (set-amount-in (new-amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (<= new-amount u100000000) ERR_EXCEEDS_LIMIT)
    (ok (var-set amount-in new-amount))))

(define-read-only (get-total-profit)
    (ok (var-get total-profit)))

(define-read-only (get-profit (principal principal))
    (ok (default-to u0 (map-get? profits principal))))