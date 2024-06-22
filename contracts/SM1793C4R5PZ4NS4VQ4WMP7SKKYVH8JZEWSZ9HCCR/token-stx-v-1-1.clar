
;; token-stx-v-1-1

(impl-trait .sip-010-trait-ft-standard-v-1-1.sip-010-trait)

(define-constant ERR_NOT_AUTHORIZED (err u1001))
(define-constant ERR_INVALID_AMOUNT (err u1002))
(define-constant ERR_INVALID_PRINCIPAL (err u1003))
(define-constant ERR_INVALID_TOKEN_URI (err u3008))

(define-data-var token-uri (string-utf8 256) u"")

(define-data-var contract-owner principal tx-sender)

(define-read-only (get-name)
  (ok "Stacks")
)

(define-read-only (get-symbol)
  (ok "STX")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-total-supply)
  (ok stx-liquid-supply)
)

(define-read-only (get-balance (address principal))
  (ok (stx-get-balance address))
)

(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

(define-public (set-token-uri (uri (string-utf8 256)))
  (let (
    (caller tx-sender)
  )
    (begin
      (asserts! (is-eq caller (var-get contract-owner)) ERR_NOT_AUTHORIZED)
      (asserts! (> (len uri) u0) ERR_INVALID_TOKEN_URI)
      (var-set token-uri uri)
      (print {action: "set-token-uri", caller: caller, data: {uri: uri}})
      (ok true)
    )
  )
)

(define-public (set-contract-owner (address principal))
  (let (
    (caller tx-sender)
  )
    (begin
      (asserts! (is-eq caller (var-get contract-owner)) ERR_NOT_AUTHORIZED)
      (asserts! (is-standard address) ERR_INVALID_PRINCIPAL)
      (var-set contract-owner address)
      (print {action: "set-contract-owner", caller: caller, data: {address: address}})
      (ok true)
    )
  )
)

(define-public (transfer 
    (amount uint)
    (sender principal) (recipient principal)
    (memo (optional (buff 34)))
  )
  (let (
    (caller tx-sender)
  )
    (begin
      (asserts! (is-eq caller sender) ERR_NOT_AUTHORIZED)
      (asserts! (is-standard sender) ERR_INVALID_PRINCIPAL)
      (asserts! (is-standard recipient) ERR_INVALID_PRINCIPAL)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (try! (stx-transfer? amount sender recipient))
      (match memo to-print (print to-print) 0x)
      (print {
        action: "transfer",
        caller: caller,
        data: {
          sender: sender,
          recipient: recipient,
          amount: amount,
          memo: memo
        }
      })
      (ok true)
    )
  )
)
