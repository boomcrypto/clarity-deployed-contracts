(define-constant MAX-MINT-PER-PRINCIPAL u2)

(define-constant err-unauthorized (err u403))
(define-constant err-not-launched (err u506))
(define-constant err-max-mint-reached (err u507))

(define-data-var mint-launched bool false)
(define-data-var price-in-ustx uint u1130000000)
(define-data-var public-mint bool false)
(define-data-var payment-recipient principal 'SP1YZSSPWJ5D3S1G48ZPW8NGXVG0K2TZJJXDM6N0Q)

(define-map allow-list principal bool)
(define-map mint-count principal uint)
(define-map admins principal bool)
(map-set admins tx-sender true)
(map-set admins 'SP3K44BG6E9PC7SE5VZG97P25EP99ZTSQRP923A3B true)
(map-set admins 'SPRYDH1HN9X5JWGXQ5B534XEM61X75JVDEVE0NYK true)
(map-set admins 'SP9CZCK08XMEP1PX4YEWZGJ71YGZF3C68BX72BJS true)

;;
;; mint and burn
;;
(define-public (mint)
  (let ((sender-mint-count (default-to u0 (map-get? mint-count tx-sender)))
        (public-mint-started (var-get public-mint)))
    (asserts! (var-get mint-launched) err-not-launched)
    (asserts! (or (is-allow-listed tx-sender) public-mint-started) err-unauthorized)
    (asserts! (or (< sender-mint-count MAX-MINT-PER-PRINCIPAL) public-mint-started) err-max-mint-reached)
    (map-set mint-count tx-sender (+ sender-mint-count u1))
    (try! (stx-transfer? (var-get price-in-ustx) tx-sender (var-get payment-recipient)))
    (contract-call? .ryder-nft mint tx-sender)))

(define-public (claim)
  (mint))

(define-public (claim-two)
  (begin
    (try! (mint))
    (mint)))

(define-public (claim-five)
  (begin
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (mint)))

(define-public (claim-twenty)
  (begin
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (mint)))

;; read-only functions

(define-read-only (is-allow-listed (who principal))
  (default-to false (map-get? allow-list who)))

(define-read-only (get-price-in-ustx)
  (var-get price-in-ustx))

(define-read-only (get-mint-launched)
  (var-get mint-launched))

(define-read-only (get-public-mint)
  (var-get public-mint))

(define-read-only (get-payment-recipient)
  (var-get payment-recipient))

(define-read-only (get-mint-count (who principal))
  (default-to u0 (map-get? mint-count who)))

(define-read-only (is-admin  (account principal))
  (default-to false (map-get? admins account)))


;; admin functions
(define-read-only (check-is-admin)
  (ok (asserts! (default-to false (map-get? admins contract-caller)) err-unauthorized)))

(define-public (set-launched (launched bool))
  (begin
    (try! (check-is-admin))
    (ok (var-set mint-launched launched))))

(define-public (set-public-mint (is-public-mint bool))
  (begin
    (try! (check-is-admin))
    (ok (var-set public-mint is-public-mint))))

(define-public (set-price-in-ustx (price uint))
  (begin
    (try! (check-is-admin))
    (ok (var-set price-in-ustx price))))

(define-private (set-allow-listed-iter (who principal))
  (map-set allow-list who true))

(define-public (set-allow-listed-many (entries (list 200 principal)))
  (begin
    (try! (check-is-admin))
    (ok (map set-allow-listed-iter entries))))

(define-public (set-payment-recipient (recipient principal))
  (begin
    (try! (check-is-admin))
    (ok (var-set payment-recipient recipient))))

(define-public (set-admin (new-admin principal) (value bool))
  (begin
    (try! (check-is-admin))
    (map-set admins new-admin value)
    (ok true)))