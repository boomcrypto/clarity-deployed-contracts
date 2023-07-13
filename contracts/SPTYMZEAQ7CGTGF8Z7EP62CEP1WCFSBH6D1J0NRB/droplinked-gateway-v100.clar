(define-constant droplinked-public 0x031a5d135011eda489132db757fab241a1cf12f869a1dd7cc086429507116a2ba6)
(define-constant droplinked 'SPTYMZEAQ7CGTGF8Z7EP62CEP1WCFSBH6D1J0NRB)

(define-constant err-sender-only (err u102))
(define-constant err-receiver-only (err u103))

(define-constant err-invalid-height (err u204))
(define-constant err-invalid-droplinked-signature (err u205))

(define-public (pay (amount uint) (shipping uint) (tax uint) (rate-buff (buff 8)) (height-buff (buff 8)) (signature (buff 65)) (sender principal) (receiver principal))
  (let 
    (
      (rate (buff-to-uint-be rate-buff))
      (height (buff-to-uint-be height-buff))
      (price-ustx (/ (* rate amount) u100))
      (shipping-ustx (/ (* rate shipping) u100))
      (tax-ustx (/ (* rate tax) u100))
      (droplinked-ustx (/ price-ustx u100))
    )
    (asserts! (is-eq contract-caller sender) err-sender-only)
    (asserts! (and (<= height block-height) (> (+ height u5) block-height)) err-invalid-height)
    (asserts! (verify-droplinked-signature? (concat rate-buff height-buff) signature) err-invalid-droplinked-signature)
    (try! (if (> shipping-ustx u0)
      (stx-transfer? shipping-ustx sender receiver)
      (ok true)
    ))
    (try! (if (> tax-ustx u0)
      (stx-transfer? tax-ustx sender receiver)
      (ok true)
    ))
    (try! (if (> droplinked-ustx u0) 
      (stx-transfer? droplinked-ustx sender droplinked)
      (ok true)
    ))
    (try! (stx-transfer? (- price-ustx droplinked-ustx) sender receiver))
    (print {
      type: "droplinked:pay",
      sender: sender,
      receiver: receiver,
      rate-buff: rate-buff,
      height-buff: height-buff,
      amount: amount,
      shipping: shipping,
      tax: tax
    })
    (ok true)
  )
)

(define-read-only (verify-droplinked-signature? (message (buff 16)) (droplinked-signature (buff 65))) 
  (secp256k1-verify (sha256 message) droplinked-signature droplinked-public)
)