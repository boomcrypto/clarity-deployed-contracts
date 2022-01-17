
(define-constant UPGRADE_FEE u60000000)

(define-read-only (get-owner-boom (id uint))
  (let ((boom-id (unwrap! (to-boom id) err-not-found)))
    (contract-call? 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts get-owner boom-id)))

;; upgrade btc rock
(define-public (upgrade (id uint))
  (let ((boom-id (unwrap! (to-boom id) err-not-found))
        (owner (unwrap! (unwrap! (contract-call? 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts get-owner boom-id) err-not-found) err-already-burnt)))
    (asserts! (or (is-eq tx-sender owner) (is-eq contract-caller owner)) err-not-authorized)
    (try! (stx-transfer? UPGRADE_FEE tx-sender 'SP2J56JG0SMAVW0DXXJ7W18W2CQHD1FE83FZCFV26))
    (try! (contract-call? 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts burn boom-id))
    (contract-call? .btc-rocks upgrade id)))

;; 1 <= id <= 50
(define-read-only (to-boom (id uint))
  (element-at rocks (- id u1)))

(define-constant rocks
  (list
    u5193 u5201 u5202 u5426 u5204 u5203 u5236 u5237 u5238 u5239
    u5240 u5241 u5242 u5243 u5244 u5351 u5352 u5439 u5329 u5330
    u5403 u5404 u5405 u5423 u5422 u5406 u5459 u5424 u5425 u5458
    u5460 u5461 u5462 u5463 u5464 u5536 u5537 u5538 u5539 u5540
    u5541 u5542 u5543 u5544 u5545 u5546 u5559 u5560 u5593 u5592))

(contract-call? .btc-rocks set-mint)

(define-constant err-not-authorized (err u803))
(define-constant err-not-found (err u804))
(define-constant err-already-burnt (err u900))
