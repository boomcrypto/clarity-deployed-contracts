;; Constats and Errors
(define-constant POOL-WALLET 'SP3PXSM14KR0TEW9A7EVK5RDMCX0VK1WM64TB0FJ)
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u101))
(define-constant ERR-BETTING-NOT-ACTIVE (err u102))

;; Variables
(define-data-var bet-price uint u1000000)
(define-data-var last-bet-id uint u1)
(define-data-var prize-pool uint u0)
(define-data-var last-price (string-ascii 20) "none")
(define-data-var bet-active bool false)

;; Storage
(define-map bets { bet-id: uint } { wallet: principal, price: (string-ascii 20) })

;; Functions
;; Set betting flag (only contract owner)
(define-public (flip-bet)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set bet-active (not (var-get bet-active)))
    (ok (var-get bet-active))))

;; Make bet in STX
(define-public (bet-stx (price (string-ascii 20)))
  (begin
    (asserts! (var-get bet-active) ERR-BETTING-NOT-ACTIVE)
    (try! (stx-transfer? (var-get bet-price) tx-sender POOL-WALLET))
    (var-set last-price price)
    (map-set bets { bet-id: (var-get last-bet-id) } { wallet: tx-sender, price: (var-get last-price) })
    (var-set last-bet-id (+ (var-get last-bet-id) u1))
    (ok true)))

;; Set price in STX (only contract owner)
(define-public (set-bet-price-in-ustx (price uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set bet-price price)
    (ok true)))

;; Pay a prize to the winner (only contract owner)
(define-public (pay-prize (winner principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set prize-pool (/ (* (- (var-get last-bet-id) u1) (var-get bet-price) u95) u100))
    (try! (stx-transfer? (var-get prize-pool) POOL-WALLET winner))
    (ok true)))

;; Check betting active
(define-read-only (betting-enabled)
  (ok (var-get bet-active)))

;; Price in STX
(define-read-only (get-price-in-ustx)
  (ok (var-get bet-price)))

;; Get bet info by ID
(define-read-only (get-bet-info (id uint))
  (ok (map-get? bets (tuple (bet-id id)))))

;; Prize pool in STX
;; Bet ID * Price = Prize Pool
(define-read-only (get-prize-pool-in-ustx)
  (ok (* (- (var-get last-bet-id) u1) (var-get bet-price))))