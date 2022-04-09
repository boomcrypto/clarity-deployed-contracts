;; Constats and Errors
(define-constant WALLET 'SP1ZFBG19YV91M8BEMQWT680WY6EH5BWXMX17FWZY)
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u101))

;; Variables
(define-data-var bet-price-stx uint u4206900)
(define-data-var bet-price-ban uint u4206900)
(define-data-var last-id-stx uint u0)
(define-data-var last-id-ban uint u0)

;; Functions
;; Make bet in STX
(define-public (bet-stx (date (string-ascii 40)))
  (begin
    (try! (stx-transfer? (var-get bet-price-stx) tx-sender WALLET))
    (var-set last-id-stx (+ (var-get last-id-stx) u1))
    (print date)
    (ok true)))

;; Make bet in BANANA
(define-public (bet-banana (date (string-ascii 40)))
  (begin
    (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-bananas transfer (var-get bet-price-ban) tx-sender WALLET none))
    (var-set last-id-ban (+ (var-get last-id-ban) u1))
    (print date)
    (ok true)))

;; Set price in STX
(define-public (set-price-stx (price uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set bet-price-stx price)
    (ok true)))

;; Set price in BANANA
(define-public (set-price-ban (price uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set bet-price-ban price)
    (ok true)))

;; Price in STX
(define-read-only (get-price-in-stx)
  (ok (var-get bet-price-stx)))

;; Price in BANANA
(define-read-only (get-price-in-banana)
  (ok (var-get bet-price-ban)))

;; Prize pool in STX
(define-read-only (get-prize-pool-stx)
  (ok (* (var-get last-id-stx) (var-get bet-price-stx))))

;; Prize pool in BANANA
(define-read-only (get-prize-pool-banana)
  (ok (* (var-get last-id-ban) (var-get bet-price-ban))))