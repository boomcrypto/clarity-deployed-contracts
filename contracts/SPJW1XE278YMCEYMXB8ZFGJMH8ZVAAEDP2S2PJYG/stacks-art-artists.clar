;; Register on-chain as an artist with Stacks Art

(define-constant ERR-NOT-AUTHORIZED u401)

(define-map artists { address: principal } { id: uint, verified: bool })
(define-data-var last-artist-id uint u0)
(define-data-var contract-owner (optional principal) (some tx-sender))

(define-public (verify-artist (address principal))
  (let (
    (artist (get-artist address))
  )
    (asserts!
      (or
        (is-none (var-get contract-owner))
        (is-eq tx-sender (unwrap-panic (var-get contract-owner)))
      )
      (err ERR-NOT-AUTHORIZED)
    )

    (map-set artists { address: address } { id: (get id artist), verified: true })
    (ok true)
  )
)

(define-public (register)
  (let (
    (last-id (var-get last-artist-id))
    (verified (is-none (var-get contract-owner)))
  )
    (map-set artists { address: tx-sender } { id: last-id, verified: verified })
    (var-set last-artist-id (+ last-id u1))
    (ok true)
  )
)

(define-read-only (get-artist (artist principal))
  (default-to
    { id: u0, verified: false }
    (map-get? artists { address: artist })
  )
)

(define-read-only (is-verified-artist (address principal))
  (let (
    (artist (get-artist address))
  )
    (get verified artist)
  )
)

(define-public (set-contract-owner (address principal))
  (begin
    (asserts! (is-eq tx-sender (unwrap-panic (var-get contract-owner))) (err ERR-NOT-AUTHORIZED))

    (var-set contract-owner (some address))
    (ok true)
  )
)
