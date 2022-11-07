(define-data-var counter uint u0)
(define-constant CONTRACT_OWNER tx-sender)

(define-read-only (get-index)
  (ok (var-get counter)))


(define-map coffees uint {
  name: (string-utf8 100),
  message: (string-utf8 500)
})


(define-read-only (get-coffee (id uint))
    (map-get? coffees id)
)

(define-private (increment-index)
  (begin
    (var-set counter (+ (var-get counter) u1))
    (ok (var-get counter))))



(define-public (buy-coffee (message (string-utf8 500))  (name (string-utf8 100)) (price uint))
  (let ((id (unwrap! (increment-index) (err u0))))

    (print { message: message, id: id, name: name, price: price })

    (try! (stx-transfer? price tx-sender CONTRACT_OWNER))
    (map-set coffees id { message: message, name: name } )

    (ok "Thank you for a coffee")
    )
)