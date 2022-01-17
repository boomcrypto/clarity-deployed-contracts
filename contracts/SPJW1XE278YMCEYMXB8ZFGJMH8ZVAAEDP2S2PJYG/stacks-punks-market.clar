;; Buy and Sell StacksPunks
;; Takes 2.5% commission

(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-BID-NOT-HIGH-ENOUGH u100)
(define-constant ERR-PUNK-NOT-FOR-SALE u101)
(define-constant CONTRACT-OWNER tx-sender)

(define-map punks-for-sale { id: uint } { seller: (optional principal), price: uint })
(define-map punks-by-seller { seller: principal } { ids: (list 2500 uint) })
(define-map punk-bids { id: uint } { buyer: principal, offer: uint })
(define-data-var listed-punk-ids (list 4000 uint) (list ))
(define-data-var removing-punk-id uint u0)
(define-data-var sale-commission uint u250) ;; 250 basis points

(define-read-only (get-listed-punk-ids)
  (ok (var-get listed-punk-ids))
)

(define-read-only (get-punk-for-sale (punk-id uint))
  (default-to
    { seller: none, price: u99000000000000 }
    (map-get? punks-for-sale { id: punk-id })
  )
)

(define-public (list-punk (punk-id uint) (price uint))
  (let (
    (punk-owner (unwrap-panic (contract-call? .stacks-punks-v3 get-owner punk-id)))
    (punk-ids (unwrap-panic (get-punks-by-seller tx-sender)))
  )
    (asserts! (is-eq tx-sender (unwrap-panic punk-owner)) (err ERR-NOT-AUTHORIZED))

    (map-set punks-for-sale { id: punk-id } { seller: (some tx-sender), price: price })
    (map-set punks-by-seller { seller: tx-sender }
      { ids: (unwrap-panic (as-max-len? (append punk-ids punk-id) u2500)) }
    )
    (var-set listed-punk-ids (unwrap-panic (as-max-len? (append (var-get listed-punk-ids) punk-id) u4000)))

    (contract-call? .stacks-punks-v3 transfer punk-id tx-sender (as-contract tx-sender))
  )
)

(define-read-only (get-punks-entry-by-seller (seller principal))
  (default-to
    { ids: (list ) }
    (map-get? punks-by-seller { seller: seller })
  )
)

(define-public (get-punks-by-seller (seller principal))
  (ok (get ids (get-punks-entry-by-seller seller)))
)

(define-read-only (get-punk-bid (punk-id uint))
  (default-to
    { buyer: CONTRACT-OWNER, offer: u0 }
    (map-get? punk-bids { id: punk-id })
  )
)

(define-public (unlist-punk (punk-id uint))
  (let (
    (punk (get-punk-for-sale punk-id))
    (sender tx-sender)
    (bid (get-punk-bid punk-id))
  )
    (asserts! (is-some (get seller punk)) (err ERR-PUNK-NOT-FOR-SALE))
    (asserts! (is-eq sender (unwrap-panic (get seller punk))) (err ERR-NOT-AUTHORIZED))

    (try! (remove-punk-listing punk-id sender))
    (map-delete punks-for-sale { id: punk-id })

    (if (> (get offer bid) u0)
      (begin
        (try! (as-contract (stx-transfer? (get offer bid) (as-contract tx-sender) (get buyer bid))))
        (map-delete punk-bids { id: punk-id })
      )
      true
    )
    (as-contract (contract-call? .stacks-punks-v3 transfer punk-id (as-contract tx-sender) sender))
  )
)

(define-public (bid-punk (punk-id uint) (amount uint))
  (let (
    (punk (get-punk-for-sale punk-id))
    (bid (get-punk-bid punk-id))
  )
    (asserts! (is-some (get seller punk)) (err ERR-PUNK-NOT-FOR-SALE))
    (asserts! (> amount (get offer bid)) (err ERR-BID-NOT-HIGH-ENOUGH))

    (match (stx-transfer? amount tx-sender (as-contract tx-sender))
      success (begin
        (map-set punk-bids { id: punk-id } { buyer: tx-sender, offer: amount })
        (ok amount)
      )
      error (err error)
    )
  )
)

(define-public (withdraw-bid (punk-id uint))
  (let (
    (punk (get-punk-for-sale punk-id))
    (bid (get-punk-bid punk-id))
    (sender tx-sender)
  )
    (asserts! (is-some (get seller punk)) (err ERR-PUNK-NOT-FOR-SALE))
    (asserts! (is-eq tx-sender (get buyer bid)) (err ERR-NOT-AUTHORIZED))

    (match (as-contract (stx-transfer? (get offer bid) (as-contract tx-sender) sender))
      success (begin
        (map-delete punk-bids { id: punk-id })
        (ok (get offer bid))
      )
      error (err error)
    )
  )
)

(define-public (accept-bid (punk-id uint))
  (let (
    (punk (get-punk-for-sale punk-id))
    (bid (get-punk-bid punk-id))
    (commission (/ (* (get offer bid) (var-get sale-commission)) u10000))
  )
    (asserts! (is-some (get seller punk)) (err ERR-PUNK-NOT-FOR-SALE))
    (asserts! (is-eq tx-sender (unwrap-panic (get seller punk))) (err ERR-NOT-AUTHORIZED))

    (try! (as-contract (stx-transfer? commission (as-contract tx-sender) CONTRACT-OWNER)))
    (try! (as-contract (stx-transfer? (- (get offer bid) commission) (as-contract tx-sender) (unwrap-panic (get seller punk)))))
    (try! (remove-punk-listing punk-id (unwrap-panic (get seller punk))))
    (map-delete punks-for-sale { id: punk-id })

    (try! (as-contract (contract-call? .stacks-punks-v3 transfer punk-id (as-contract tx-sender) (get buyer bid))))
    (ok true)
  )
)

(define-public (buy-punk (punk-id uint))
  (let (
    (punk-owner (unwrap-panic (contract-call? .stacks-punks-v3 get-owner punk-id)))
    (punk (get-punk-for-sale punk-id))
    (sender tx-sender)
    (commission (/ (* (get price punk) (var-get sale-commission)) u10000))
    (bid (get-punk-bid punk-id))
  )
    (asserts! (not (is-eq tx-sender (unwrap-panic punk-owner))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (get seller punk)) (err ERR-PUNK-NOT-FOR-SALE))

    (try! (stx-transfer? commission sender CONTRACT-OWNER))
    (if (not (is-eq sender (unwrap-panic (get seller punk))))
      (try! (stx-transfer? (- (get price punk) commission) sender (unwrap-panic (get seller punk))))
      true
    )
    (if (> (get offer bid) u0)
      (begin
        (try! (as-contract (stx-transfer? (get offer bid) (as-contract tx-sender) (get buyer bid))))
        (map-delete punk-bids { id: punk-id })
      )
      true
    )

    (try! (remove-punk-listing punk-id (unwrap-panic (get seller punk))))
    (map-delete punks-for-sale { id: punk-id })

    (try! (as-contract (contract-call? .stacks-punks-v3 transfer punk-id (as-contract tx-sender) sender)))
    (ok true)
  )
)

(define-private (remove-punk-listing (punk-id uint) (sender principal))
  (if true
    (let (
      (punk-ids (unwrap-panic (get-punks-by-seller sender)))
    )
      (var-set removing-punk-id punk-id)
      (var-set listed-punk-ids (unwrap-panic (as-max-len? (filter remove-punk-id (var-get listed-punk-ids)) u4000)))
      (map-set punks-by-seller { seller: sender }
        { ids: (unwrap-panic (as-max-len? (filter remove-punk-id punk-ids) u2500)) }
      )
      (ok true)
    )
    (err u0)
  )
)

(define-private (remove-punk-id (punk-id uint))
  (if (is-eq punk-id (var-get removing-punk-id))
    false
    true
  )
)

(define-public (admin-unlist (punk-id uint))
  (let (
    (punk (get-punk-for-sale punk-id))
    (bid (get-punk-bid punk-id))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (get seller punk)) (err ERR-PUNK-NOT-FOR-SALE))

    (try! (remove-punk-listing punk-id (unwrap-panic (get seller punk))))
    (map-delete punks-for-sale { id: punk-id })
    (if (> (get offer bid) u0)
      (begin
        (try! (as-contract (stx-transfer? (get offer bid) (as-contract tx-sender) (get buyer bid))))
        (map-delete punk-bids { id: punk-id })
      )
      true
    )

    (as-contract (contract-call? .stacks-punks-v3 transfer punk-id (as-contract tx-sender) (unwrap-panic (get seller punk))))
  )
)

(define-public (set-sale-commission (commission uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
    (ok (var-set sale-commission commission))
  )
)
