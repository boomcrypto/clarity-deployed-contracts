
(define-map vaults { id: uint } {
  id: uint,
  owner: principal,
  collateral: uint,
  collateral-type: (string-ascii 12), 
  collateral-token: (string-ascii 12), 
  stacked-tokens: uint,
  revoked-stacking: bool,
  debt: uint,
  stacker-name: (string-ascii 256),
  created-at-block-height: uint,
  updated-at-block-height: uint,
  toggled-at-block-height: uint,
  stability-fee-accrued: uint,
  stability-fee-last-accrued: uint, 
  is-liquidated: bool,
  liquidation-finished: bool,
})
(define-map vault-entries { user: principal } { ids: (list 20 uint) })
(define-map closing-vault
  { user: principal }
  { vault-id: uint }
)

(define-data-var last-vault-id uint u0)

(define-map liquidated-vaults { idx: uint } { id: uint })
(define-data-var last-liquidated-vault-idx uint u0)

(define-constant ERR-NOT-AUTHORIZED u7401)

(define-read-only (get-vault-by-id (id uint))
  (default-to
    {
      id: u0,
      owner: (contract-call? .stackswap-dao-v5k get-dao-owner),
      collateral: u0,
      collateral-type: "",
      collateral-token: "",
      stacked-tokens: u0,
      stacker-name: "",
      revoked-stacking: false,
      debt: u0,
      created-at-block-height: u0,
      updated-at-block-height: u0,
      toggled-at-block-height: u0,
      stability-fee-accrued: u0,
      stability-fee-last-accrued: u0,
      is-liquidated: false,
      liquidation-finished: false
    }
    (map-get? vaults { id: id })
  )
)

(define-read-only (get-vault-entries (user principal))
  (unwrap! (map-get? vault-entries { user: user }) (tuple (ids (list u0) )))
)

(define-read-only (get-last-vault-id)
  (var-get last-vault-id)
)

(define-read-only (get-last-liquidated-vault-idx)
  (var-get last-liquidated-vault-idx)
)

(define-read-only (get-liquidated-vault (idx uint))
  (unwrap! (map-get? liquidated-vaults { idx: idx }) {id: u0})
)

(define-public (set-last-vault-id (vault-id uint))
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "mortgager-l"))) (err ERR-NOT-AUTHORIZED))

    (ok (var-set last-vault-id vault-id))
  )
)

(define-read-only (get-vaults (user principal))
  (let ((entries (get ids (get-vault-entries user))))
    (ok (map get-vault-by-id entries))
  )
)

(define-public (update-vault (vault-id uint) (data (tuple (id uint) (owner principal) (collateral uint) (collateral-type (string-ascii 12)) (collateral-token (string-ascii 12)) (stacker-name (string-ascii 256)) (stacked-tokens uint) (revoked-stacking bool) (debt uint) (created-at-block-height uint) (updated-at-block-height uint) (toggled-at-block-height uint) (stability-fee-accrued uint) (stability-fee-last-accrued uint) (is-liquidated bool) (liquidation-finished bool) )))
  (let ((vault (get-vault-by-id vault-id)))
    (asserts!
      (or
        (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "mortgager-l")))
        (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stacker-l")))
        (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stacker-l-2")))
        (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stacker-l-3")))
        (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stacker-l-4")))
      )
      (err ERR-NOT-AUTHORIZED)
    )
  
    (map-set vaults (tuple (id vault-id)) data)
    (ok true)
  )
)

(define-public (update-vault-entries (user principal) (vault-id uint))
  (let ((entries (get ids (get-vault-entries user))))
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "mortgager-l"))) (err ERR-NOT-AUTHORIZED))

    (map-set vault-entries { user: user } { ids: (unwrap-panic (as-max-len? (append entries vault-id) u20)) })
    (ok true)
  )
)

(define-private (remove-burned-vault (vault-id uint))
  (let ((current-vault (unwrap-panic (map-get? closing-vault { user: tx-sender }))))
    (if (is-eq vault-id (get vault-id current-vault))
      false
      true
    )
  )
)

(define-public (close-vault (vault-id uint))
  (let (
    (vault (get-vault-by-id vault-id))
    (entries (get ids (get-vault-entries (get owner vault))))
  )
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "mortgager-l"))) (err ERR-NOT-AUTHORIZED))

    (map-set closing-vault { user: (get owner vault) } { vault-id: vault-id })
    (map-set vault-entries { user: tx-sender } { ids: (filter remove-burned-vault entries) })
    (ok (map-delete vaults { id: vault-id }))
  )
)

(define-public (close-vault-liquidated (vault-id uint))
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "mortgager-l"))) (err ERR-NOT-AUTHORIZED))
    (ok (map-delete vaults { id: vault-id }))
  )
)


(define-public (finalize-liquidate-vault (vault-id uint) (data (tuple (id uint) (owner principal) (collateral uint) (collateral-type (string-ascii 12)) (collateral-token (string-ascii 12)) (stacker-name (string-ascii 256)) (stacked-tokens uint) (revoked-stacking bool) (debt uint) (created-at-block-height uint) (updated-at-block-height uint) (toggled-at-block-height uint) (stability-fee-accrued uint) (stability-fee-last-accrued uint) (is-liquidated bool) (liquidation-finished bool) )))
  (let (
      (vault (get-vault-by-id vault-id))
      (entries (get ids (get-vault-entries (get owner vault))))
      (last-liquidated-idx (var-get last-liquidated-vault-idx))
    )
    (asserts!
      (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "mortgager-l")))
      (err ERR-NOT-AUTHORIZED)
    )
    (map-set closing-vault { user: tx-sender } { vault-id: vault-id })
    (map-set vault-entries { user: (get owner vault)} { ids: (filter remove-burned-vault entries) })

    (map-set vaults (tuple (id vault-id)) data)

    (var-set last-liquidated-vault-idx (+ last-liquidated-idx u1))
    (map-set liquidated-vaults {idx: last-liquidated-idx} {id: vault-id})
    (ok true)
  )
)
