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

(impl-trait .dao-traits-v7.interaction-trait)

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_EXCEEDS_LIMIT (err u405))
(define-constant ERR_SWAP_FAILED (err u500))

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
            (let (
                ;; First swap: CHA -> STX 
                (swap1 (unwrap! (contract-call? .univ2-path2 do-swap (var-get amount-in) .charisma-token .wstx .univ2-share-fee-to) (ok "NO_PROFIT_OPPORTUNITY")))
                ;; Second swap: STX -> WELSH
                (swap2 (unwrap! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 do-swap (get amt-out swap1) 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to) (ok "NO_PROFIT_OPPORTUNITY")))
                ;; Third swap: WELSH -> CHA
                (swap3 (unwrap! (contract-call? .univ2-path2 do-swap (get amt-out swap2) 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token .charisma-token .univ2-share-fee-to) (ok "NO_PROFIT_OPPORTUNITY")))
            )
            (if (> (get amt-out swap3) (var-get amount-in))
                (begin
                    (print "The adventurer successfully arbitraged the mysterious marketplace!")
                    (update-profit (var-get amount-in))
                    (match (contract-call? .univ2-path2 do-swap u1000000 .wstx .charisma-token .univ2-share-fee-to)
                        s (print "With the profits, the adventurer swapped 1 STX to CHA.")
                        e (print "Swapping 1 STX to CHA after the successful arbitrage failed."))
                    (ok "ARBITRAGE_COMPLETE"))
                (begin
                    (print "The arbitrage attempt yielded no profit in these market conditions.")
                    (err "NO_PROFIT_OPPORTUNITY"))))
            (ok "NOT_ENOUGH_ENERGY"))))

;; Reverse Path (CHA -> WELSH -> STX -> CHA)
(define-private (try-reverse-path (sender principal))
    (begin
        (if (is-eq (unwrap-panic (contract-call? .fatigue-rc3 execute "BURN")) "ENERGY_BURNED")
            (let (
                ;; First swap: CHA -> WELSH
                (swap1 (unwrap! (contract-call? .univ2-path2 do-swap (var-get amount-in) .charisma-token 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token .univ2-share-fee-to) (ok "NO_PROFIT_OPPORTUNITY")))
                ;; Second swap: WELSH -> STX
                (swap2 (unwrap! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 do-swap (get amt-out swap1) 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to) (ok "NO_PROFIT_OPPORTUNITY")))
                ;; Third swap: STX -> CHA
                (swap3 (unwrap! (contract-call? .univ2-path2 do-swap (get amt-out swap2) .wstx .charisma-token .univ2-share-fee-to) (ok "NO_PROFIT_OPPORTUNITY")))
            )
            (if (> (get amt-out swap3) (var-get amount-in))
                (begin
                    (print "The adventurer successfully arbitraged the mysterious marketplace!")
                    (update-profit (var-get amount-in))
                    (match (contract-call? .univ2-path2 do-swap u1000000 .wstx .charisma-token .univ2-share-fee-to)
                        s (print "With the profits, the adventurer swapped 1 STX to CHA.")
                        e (print "Swapping 1 STX to CHA after the successful arbitrage failed."))
                    (ok "ARBITRAGE_COMPLETE"))
                (begin
                    (print "The arbitrage attempt yielded no profit in these market conditions.")
                    (err "NO_PROFIT_OPPORTUNITY"))))
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