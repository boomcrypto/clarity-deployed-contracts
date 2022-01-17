(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)
(define-map market uint {price: uint, commission: principal})

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))


(define-private (is-sender-owner (id uint))
  (let ((owner (unwrap! (unwrap! (contract-call? .btc-rocks get-owner id) false) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-public (list-in-ustx (id uint) (price uint) (comm <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm)}))
    (asserts! (is-sender-owner id) err-not-authorized)
    (map-set market id listing)
    (print (merge listing {action: "list-in-ustx", id: id}))
    (ok true)))

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) err-not-authorized)
    (map-delete market id)
    (print {action: "unlist-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-ustx (id uint) (comm <commission-trait>))
  (let ((owner (unwrap! (unwrap! (contract-call? .btc-rocks get-owner id) err-not-found) err-not-found))
      (listing (unwrap! (map-get? market id) err-listing))
      (floor (contract-call? .btc-rocks get-floor))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm) (get commission listing)) err-invalid-commission)
    (asserts! (> price floor) err-price-too-low)
    ;; Rule seller gets price minus contract floor
    (try! (stx-transfer? (- price floor) tx-sender owner))
    (try! (contract-call? comm pay id price))
    (try! (contract-call? .btc-rocks transfer id owner tx-sender))
    (map-delete market id)
    (print {action: "buy-in-ustx", id: id})
    (ok true)))

(contract-call? .btc-rocks set-marketplace)

(define-constant err-not-authorized (err u403))
(define-constant err-not-found (err u404))
(define-constant err-invalid-commission (err u500))
(define-constant err-listing (err u501))
(define-constant err-price-too-low (err u502))

