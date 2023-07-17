(impl-trait .sft-trait.sft-trait)

(define-constant droplinked-public 0x031a5d135011eda489132db757fab241a1cf12f869a1dd7cc086429507116a2ba6)
(define-constant droplinked 'SPTYMZEAQ7CGTGF8Z7EP62CEP1WCFSBH6D1J0NRB)

(define-fungible-token product)
(define-non-fungible-token sku { id: uint, owner: principal })

(define-data-var last-sku-id uint u0)

(define-map creators uint principal)

(define-map prices uint uint)

(define-map commissions { id: uint, publisher: principal } uint)

(define-map uris uint (string-ascii 256))

(define-map balances { id: uint, owner: principal } uint)

(define-map supplies uint uint)

(define-map ids (string-ascii 256) uint)

(define-constant request-status-accepted u1)
(define-constant request-status-pending u0)
(define-map requests 
  { id: uint, publisher: principal } 
  { amount: uint, commission: uint, status: uint }  
)

(define-constant err-droplinked-only (err u100))
(define-constant err-creator-only (err u101))
(define-constant err-publisher-only (err u102))
(define-constant err-purchaser-only (err u103))

(define-constant err-invalid-sku (err u200))
(define-constant err-invalid-creator (err u201))
(define-constant err-invalid-publisher (err u202))
(define-constant err-invalid-request (err u203))
(define-constant err-invalid-height (err u204))
(define-constant err-invalid-droplinked-signature (err u205))

(define-constant err-insufficient-publisher-balance (err u206))
(define-constant err-insufficient-creator-balance (err u206))
(define-constant err-insufficient-sender-balance (err u207))

(define-constant err-request-pending (err u400))
(define-constant err-request-not-pending (err u401))

(define-constant err-invalid-amount (err u300))
(define-constant err-invalid-price (err u301))
(define-constant err-invalid-uri (err u302))
(define-constant err-invalid-commission (err u303))

(define-public (create (amount uint) (price uint) (commission uint) (uri (string-ascii 256)) (external-id (string-ascii 256)) (creator principal))
  (let 
    (
      (id (+ (var-get last-sku-id) u1))
    )
    (asserts! (is-eq contract-caller creator) err-creator-only)
    (asserts! (not (is-eq amount u0)) err-invalid-amount)
    (asserts! (not (is-eq price u0)) err-invalid-price)
    (asserts! (<= commission u100) err-invalid-commission)
    (asserts! (not (is-eq (len uri) u0)) err-invalid-uri)
    (try! (nft-mint? sku { id: id, owner: creator } creator))
    (try! (ft-mint? product amount creator))
    (map-insert commissions { id: id, publisher: creator } commission)
    (map-insert balances { id: id, owner: creator } amount)
    (map-insert creators id creator)
    (map-insert supplies id amount)
    (map-insert prices id price)
    (map-insert uris id uri)
    (map-insert ids external-id id)
    (print { type: "sft_mint", token-id: id, amount: amount, recipient: creator })
    (print {
      type: "droplinked:create",
      id: id,
      amount: amount,
      price: price,
      uri: uri,
      external-id: external-id,
      commission: commission,
      creator: creator
    })
    (var-set last-sku-id id)
    (ok id)
  )
)

(define-public (create-request (id uint) (amount uint) (commission uint) (publisher principal))
  (let 
    (
      (creator (unwrap! (map-get? creators id) err-invalid-sku))
      (creator-balance (unwrap-panic (map-get? balances { id: id, owner: creator })))
      (creator-commission (unwrap-panic (map-get? commissions { id: id, publisher: creator })))
    )
    (asserts! (is-eq contract-caller publisher) err-publisher-only)
    (asserts! (is-none (map-get? requests { id: id, publisher: publisher })) err-request-pending)
    (asserts! (not (is-eq publisher creator)) err-invalid-creator)
    (asserts! (<= amount creator-balance) err-invalid-amount)
    (asserts! (<= commission creator-commission) err-invalid-commission)
    (print {
      type: "droplinked:request",
      id: id,
      amount: amount, 
      commission: commission,
      publisher: publisher
    })
    (ok (map-insert requests 
        { id: id, publisher: publisher }
        { amount: amount, commission: commission, status: request-status-pending }
    ))
  )
)

(define-public (cancel-request (id uint) (publisher principal))
  (begin
    (asserts! (is-eq contract-caller publisher) err-publisher-only)
    (asserts! (is-none (map-get? requests { id: id, publisher: publisher })) err-request-pending)
    (print {
      type: "droplinked:cancel-request",
      id: id,
      publisher: publisher
    })
    (ok (map-delete requests { id: id,  publisher: publisher }))
  )
)

(define-public (accept-request (id uint) (publisher principal))
  (let 
    (
      (creator (unwrap! (map-get? creators id) err-invalid-sku))
      (creator-balance (unwrap! (map-get? balances { id: id, owner: creator }) err-insufficient-creator-balance))
      (request (unwrap! (map-get? requests { id: id, publisher: publisher }) err-invalid-request))
      (amount (get amount request))
      (commission (get commission request))
      (status (get status request))
    )
    (asserts! (is-eq contract-caller creator) err-creator-only)
    (asserts! (is-eq status request-status-pending) err-request-not-pending)
    (asserts! (>= creator-balance amount) err-invalid-amount)
    (try! (as-contract (transfer id amount creator publisher)))
    (map-set commissions { id: id, publisher: publisher } commission)
    (map-set requests { id: id, publisher: publisher } (merge request { status: request-status-accepted }))
    (print {
      type: "droplinked:accept-request",
      id: id,
      amount: amount,
      commission: commission,
      creator: creator,
      publisher: publisher,
    })
    (ok true)
  )
)

(define-public (reject-request (id uint) (publisher principal))
    (let 
    (
      (creator (unwrap! (map-get? creators id) err-invalid-sku))
      (creator-balance (unwrap! (map-get? balances { id: id, owner: creator }) err-insufficient-creator-balance))
      (request (unwrap! (map-get? requests { id: id, publisher: publisher }) err-invalid-request))
      (amount (get amount request))
      (commission (get commission request))
      (status (get status request))
    )
    (asserts! (is-eq contract-caller creator) err-creator-only)
    (asserts! (is-eq status request-status-pending) err-request-not-pending)
    (asserts! (>= creator-balance amount) err-invalid-amount)
    (map-delete requests { id: id, publisher: publisher })
    (print {
      type: "droplinked:reject-request",
      id: id,
      amount: amount,
      commission: commission,
      creator: creator,
      publisher: publisher,
    })
    (ok true)
  )
)

(define-public (purchase (id uint) (price uint) (shipping uint) (tax uint) (rate-buff (buff 8)) (height-buff (buff 8)) (signature (buff 65)) (publisher principal) (purchaser principal))
  (let 
    (
      (rate (buff-to-uint-be rate-buff))
      (height (buff-to-uint-be height-buff))
      (creator (unwrap! (map-get? creators id) err-invalid-sku))
      (creator-price (unwrap-panic (map-get? prices id)))
      (publisher-balance (unwrap! (map-get? balances { id: id, owner: publisher }) err-invalid-publisher))
      (publisher-commission (unwrap! (map-get? commissions { id: id, publisher: publisher }) err-invalid-publisher))
      (price-ustx (/ (* rate price) u100))
      (creator-price-ustx (/ (* rate creator-price) u100))
      (shipping-ustx (/ (* rate shipping) u100))
      (tax-ustx (/ (* rate tax) u100))
      (droplinked-ustx (/ creator-price-ustx u100))
    )
    (asserts! (is-eq contract-caller purchaser) err-purchaser-only)
    (asserts! (>= publisher-balance u1) err-insufficient-publisher-balance)
    (asserts! (>= price creator-price) err-invalid-price)
    (asserts! (and (<= height block-height) (> (+ height u5) block-height)) err-invalid-height)
    (asserts! (verify-droplinked-signature? (concat rate-buff height-buff) signature) err-invalid-droplinked-signature)
    (try! (if (> shipping-ustx u0)
      (stx-transfer? shipping-ustx purchaser creator)
      (ok true)
    ))
    (try! (if (> tax-ustx u0)
      (stx-transfer? tax-ustx purchaser creator)
      (ok true)
    ))
    (try! (if (> droplinked-ustx u0) 
      (stx-transfer? droplinked-ustx purchaser droplinked)
      (ok true)
    ))
    (if (is-eq publisher creator) 
      (try! (stx-transfer? (- price-ustx droplinked-ustx) purchaser publisher))
      (let 
        (
          (publisher-extra (- price-ustx creator-price-ustx))
          (publisher-profit  (/ (* publisher-commission creator-price-ustx) u100))
        )
        (try! (stx-transfer? (+ publisher-extra publisher-profit) purchaser publisher))
        (try! (stx-transfer? (- creator-price-ustx (+ publisher-profit droplinked-ustx)) purchaser creator))
      )
    )
    (try! (ft-transfer? product u1 publisher purchaser))
    (try! (as-contract (transfer id u1 publisher purchaser)))
    (print {
      type: "droplinked:purchase",
      purchaser: purchaser,
      publisher: publisher,
      rate-buff: rate-buff,
      height-buff: height-buff,
      price: price,
      shipping: shipping,
      tax: tax
    })
    (ok true)
  )
)

(define-public (transfer (id uint) (amount uint) (sender principal) (recipient principal))
  (let
    (
      (sender-balance (unwrap-panic (get-balance id sender)))
      (recipient-balance (unwrap-panic (get-balance id recipient)))
    )
    (asserts! (is-eq contract-caller (as-contract contract-caller)) err-droplinked-only)
    (asserts! (>= sender-balance amount) err-insufficient-sender-balance)
    (try! (ft-transfer? product amount sender recipient))
    (try! (burn-and-mint { id: id, owner: sender }))
    (try! (burn-and-mint { id: id, owner: recipient }))
    (map-set balances { id: id, owner: sender } (- sender-balance amount))
    (map-set balances { id: id, owner: recipient } amount)
    (print { type: "sft_transfer", token-id: id, amount: amount, sender: sender, recipient: recipient })
    (ok true)
  )
)

(define-public (transfer-memo (id uint) (amount uint) (sender principal) (recipient principal) (memo (buff 34))) 
  (begin 
    (try! (transfer id amount sender recipient))
    (print memo)
    (ok true)
  )
)

(define-read-only (get-balance (id uint) (owner principal))
  (ok (default-to u0 (map-get? balances { id: id, owner: owner })))
)

(define-read-only (get-overall-balance (owner principal)) 
  (ok (ft-get-balance product owner))
)

(define-read-only (get-overall-supply)
  (ok (ft-get-supply product))
)

(define-read-only (get-total-supply (id uint)) 
  (ok (default-to u0 (map-get? supplies id)))
)

(define-read-only (get-decimals (id uint))
  (ok u0)
)

(define-read-only (get-token-uri (id uint))
  (ok (map-get? uris id))
)

(define-read-only (get-commission (id uint) (publisher principal))
  (ok (map-get? commissions { id:id, publisher: publisher }))
)

(define-read-only (get-creator (id uint))
  (ok (map-get? creators id))
)

(define-read-only (get-price (id uint)) 
  (ok (map-get? prices id))
)

(define-read-only (get-last-sku-id) 
  (ok (var-get last-sku-id))
)

(define-read-only (get-id (external-id (string-ascii 256)))
  (map-get? ids external-id)
)

(define-read-only (verify-droplinked-signature? (message (buff 16)) (droplinked-signature (buff 65))) 
  (secp256k1-verify (sha256 message) droplinked-signature droplinked-public)
)

(define-private (burn-and-mint (sku-id { id: uint, owner: principal }))
  (begin 
    (and 
      (is-some (nft-get-owner? sku sku-id))
      (try! (nft-burn? sku sku-id (get owner sku-id)))
    )
    (nft-mint? sku sku-id (get owner sku-id))
  )
)