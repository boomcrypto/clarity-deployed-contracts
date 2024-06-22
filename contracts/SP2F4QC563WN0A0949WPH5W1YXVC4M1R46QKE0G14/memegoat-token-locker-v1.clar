(use-trait ft-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait)

;; ERRS
(define-constant ERR-INVALID-BLOCK (err u5000))
(define-constant ERR-INSUFFICIENT_AMOUNT (err u5001))
(define-constant ERR-INVALID-TOKEN (err u5005))
(define-constant ERR-LOCK_MISMATCH (err u5008))
(define-constant ERR-NOT-AUTHORIZED (err u5009))
(define-constant ERR-INVALID-AMOUNT (err u6001))
(define-constant ERR-INVALID-LOCK (err u6003))
(define-constant ERR-FAILED (err u6004))
(define-constant ERR-OUT-OF-BOUNDS (err u6005))
(define-constant ERR-ONLY-SINGLE-LOCK (err u7001))
(define-constant ERR-INFO-NOT-FOUND (err u7006))
(define-constant ERR-REWARD-BLOCK-NOT-REACHED (err u7007))
(define-constant ERR-CANNOT-EXCEED-CLAIM-AMOUNT (err u7008))
(define-constant ERR-INVALID-PERCENTAGE (err u8000))
(define-constant ERR-ALREADY-UNLOCKED (err u8002))
(define-constant ERR-ALREADY-CLAIMED (err u8003))
(define-constant ERR-INVALID-CONFIG (err u8004))

;; DATA MAPS AND VARS

;; set caller as contract owner
(define-data-var contract-owner principal tx-sender)

;; maps pool id of token pairs to tokenlocks
(define-map token-lock-map
  { lock-id: uint }
  {
    lock-block: uint, ;; the date the token was locked
    total-amount: uint, ;; the total amount of tokens still locked
    lock-owner: principal, ;; the lock owner
    locked-token: principal, ;; the address of the token locked
    is-vested: bool,
    unlock-blocks: (list 200 {height: uint, percentage: uint}),
    total-addresses: uint,
  }
)

;; maps address to lock-ids
(define-map user-lock-ids-map
    { address: principal }
    (list 200 uint) 
)

;; maps address to user-locked-tokens-map
(define-map user-lock-info-map
    { address: principal, lock-id: uint }
    {
      last-claim-block: uint,
      claim-index: uint, 
      total-claimed: uint,
      total-amount: uint,
      withdrawal-address: principal,
    }
)

;; nonce of token locks
(define-data-var lock-nonce uint u0)

;; define the locker parameters
(define-data-var stx-fee uint u1000000) ;; small stacks fee to prevent spams
(define-data-var secondary-fee-token principal .memegoatstx) ;; in this case memegoat
(define-data-var secondary-token-fee uint u1000000000) ;; option memegoat ~ 10,000 memegoat

;; management calls

(define-public (set-contract-owner (owner principal))
  (begin
    (try! (check-is-owner)) 
    (ok (var-set contract-owner owner))
  )
)

;; read-only calls

(define-read-only (get-user-lock-ids (address principal)) 
  (default-to (list) (map-get? user-lock-ids-map {address: address}))
)

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

(define-read-only (get-token-lock-by-id (lock-id uint))
  (ok (unwrap! (map-get? token-lock-map {lock-id: lock-id}) ERR-INVALID-LOCK))
)

(define-read-only (get-user-lock-info (address principal) (lock-id uint))
  (ok (unwrap! (map-get? user-lock-info-map {address: address, lock-id: lock-id}) ERR-INFO-NOT-FOUND))
)

;; private calls

(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)

;; set secondary fee token
(define-public (set-secondary-fee-token (secondary-token-trait <ft-trait>)) 
  (begin 
    (try! (check-is-owner))
    (var-set secondary-fee-token (contract-of secondary-token-trait)) 
    (ok true)
  )
)

;; fees for locking tokens
(define-public (set-fees (stx-fee_ uint) (secondary-token-fee_ uint)) 
  (begin 
    (try! (check-is-owner))
    (var-set stx-fee stx-fee_)
    (var-set secondary-token-fee secondary-token-fee_)
    (ok true)
  )
)

(define-private (add-lock-id (lock-id uint) (address principal))
  (begin
    (and 
      (is-none (index-of (get-user-lock-ids address) lock-id))
      (map-set user-lock-ids-map {address: address} (unwrap! (as-max-len? (append (get-user-lock-ids address) lock-id) u200) ERR-FAILED))
    )
    (ok true)
  )
)

(define-private (remove-lock-id (index uint) (lock-id uint) (address principal))
  (begin
    (let (
          (lock-ids (get-user-lock-ids address))
          (length (len lock-ids))
          (last-item (unwrap! (element-at lock-ids (- length u1)) ERR-OUT-OF-BOUNDS))
          (item-to-remove (unwrap! (element-at lock-ids index) ERR-OUT-OF-BOUNDS))
          (updated-lists-v1 (unwrap! (replace-at? lock-ids (- length u1) item-to-remove) ERR-OUT-OF-BOUNDS)) 
          (updated-lists-v2 (unwrap! (replace-at? updated-lists-v1 index last-item) ERR-OUT-OF-BOUNDS)) 
        )
        (map-set user-lock-ids-map {address: address} (unwrap! (as-max-len? (unwrap-panic (slice? updated-lists-v2 u0 (- length u1))) u200) ERR-FAILED))
    )
    (ok true)
  )
)

(define-private (store-lock-info-iter (user-record {address: principal, amount: uint, withdrawal-address: principal}) (lock-id uint))
  (begin
    (unwrap-panic (add-lock-id lock-id (get address user-record)))
    (map-set user-lock-info-map 
      {address: (get address user-record), lock-id: lock-id} 
      {
        last-claim-block: u0, 
        claim-index: u0, 
        total-claimed: u0, 
        total-amount: (get amount user-record), 
        withdrawal-address: (get withdrawal-address user-record)
      }
    )
    lock-id
  )
)

(define-private (check-block-info-iter (unlock-blocks {height: uint, percentage: uint}))
  (not (and (> (get height unlock-blocks) block-height) (> (get percentage unlock-blocks) u0) (<= (get percentage unlock-blocks) u100)))
)

(define-private (check-lock-amount-iter (user-record {address: principal, amount: uint, withdrawal-address: principal}))
  (not (> (get amount user-record) u0))
)

(define-private (sum-lock-amount-iter (user-record {address: principal, amount: uint, withdrawal-address: principal}) (amount uint))
  (begin 
    (+ amount (get amount user-record))
  )
)

(define-private (sum-block-percentage-iter (unlock-blocks {height: uint, percentage: uint}) (total-percentage uint))
  (begin 
    (+ total-percentage (get percentage unlock-blocks))
  )
)

;; lockToken
(define-public 
  (lock-token 
    (total-amount uint)
    (fee-in-stx bool) 
    (locked-token <ft-trait>) 
    (secondary-token-trait <ft-trait>) 
    (is-vested bool)
    (unlock-blocks (list 200 {height: uint, percentage: uint}))
    (addresses-info (list 200 {address: principal, amount: uint, withdrawal-address: principal}))
  ) 
  (begin     
      (asserts! (is-eq (len (filter check-block-info-iter unlock-blocks)) u0) ERR-INVALID-BLOCK)
      (asserts! (is-eq (len (filter check-lock-amount-iter addresses-info)) u0) ERR-INVALID-AMOUNT)
      (asserts! (is-eq (fold sum-lock-amount-iter addresses-info u0) total-amount) ERR-INSUFFICIENT_AMOUNT)
      (asserts! (is-eq (fold sum-block-percentage-iter unlock-blocks u0) u100) ERR-INVALID-PERCENTAGE)

    (let 
      (
        (stxfee (var-get stx-fee))
        (secondarytokenfee (var-get secondary-token-fee))
        (sender tx-sender)
        (next-lock-id (+ (var-get lock-nonce) u1))
        (locked-token_ (contract-of locked-token))
      )

      (if fee-in-stx
        ;; Pay fee in STX
        (try! (stx-transfer? stxfee tx-sender .memegoat-locker-vault-v1))
        ;; Burn token
        (begin
          (asserts! (is-eq (var-get secondary-fee-token) (contract-of secondary-token-trait)) ERR-INVALID-TOKEN)
          (try! (contract-call? secondary-token-trait burn secondarytokenfee sender))
        )
      )

      (if is-vested
        (begin
          (asserts! (> (len unlock-blocks) u1) ERR-INVALID-CONFIG)
          (try! (add-lock-id next-lock-id sender)) 
        )
        (asserts! (and (is-eq (len unlock-blocks) u1) (is-eq (len addresses-info) u1)) ERR-INVALID-CONFIG)
      )

      (fold store-lock-info-iter addresses-info next-lock-id)

      ;; transfer token to vault
      (try! (contract-call? locked-token transfer total-amount sender .memegoat-locker-vault-v1 none))

      (map-set token-lock-map 
        {lock-id: next-lock-id} 
        { 
          lock-block: block-height,
          total-amount: total-amount, 
          lock-owner: sender, 
          locked-token: locked-token_, 
          is-vested: is-vested,
          unlock-blocks: unlock-blocks,
          total-addresses: (len addresses-info),
        }
      )

      (var-set lock-nonce next-lock-id)
    )
    (ok true)  
  )
)

;; relockToken
(define-public (relock-token (index uint) (new-unlock-block uint) (fee-in-stx bool) (secondary-token-trait <ft-trait>) ) 
  (begin 
    (let
      (
        (sender tx-sender)
        (stxfee (var-get stx-fee))
        (secondarytokenfee (var-get secondary-token-fee))
        (lock-id (unwrap! (element-at (get-user-lock-ids sender) index) ERR-OUT-OF-BOUNDS))
        (token-lock (try! (get-token-lock-by-id lock-id)))
        (is-vested (get is-vested token-lock))
        (user-lock-info (try! (get-user-lock-info sender lock-id)))
        (claim-index (get claim-index user-lock-info))
        (total-claimed (get total-claimed user-lock-info))
        (unlock-blocks (get unlock-blocks token-lock))
        (user-unlock-block (unwrap! (element-at? unlock-blocks claim-index) ERR-OUT-OF-BOUNDS))
        (updated-block-info (merge user-unlock-block {
          height: new-unlock-block
        }))
        (updated-unlock-blocks (unwrap! (replace-at? unlock-blocks claim-index updated-block-info) ERR-OUT-OF-BOUNDS)) 
        (updated-token-lock (merge token-lock {
          unlock-blocks: updated-unlock-blocks
        }))
      )
      (asserts! (is-eq (get lock-owner token-lock) sender) ERR-LOCK_MISMATCH)
      (asserts! (not is-vested) ERR-ONLY-SINGLE-LOCK)
      (asserts! (and (> new-unlock-block (get lock-block token-lock)) (> new-unlock-block block-height)) ERR-INVALID-BLOCK)
      (asserts! (is-eq total-claimed u0) ERR-ALREADY-CLAIMED)
      (asserts! (> (get height user-unlock-block) block-height) ERR-ALREADY-UNLOCKED)

      (if fee-in-stx
        ;; Pay fee in STX
        (try! (stx-transfer? stxfee tx-sender .memegoat-locker-vault-v1))
        ;; Burn token
        (begin
          (asserts! (is-eq (var-get secondary-fee-token) (contract-of secondary-token-trait)) ERR-INVALID-TOKEN)
          (try! (contract-call? secondary-token-trait burn secondarytokenfee sender))
        )
      )
      (map-set token-lock-map { lock-id: lock-id } updated-token-lock)
    )
    (ok true)
  )
)

;; withdraw
(define-public (withdraw-token (locked-token <ft-trait>) (index uint)) 
  (begin
    (let
      (
        (sender tx-sender)
        (lock-id (unwrap! (element-at (get-user-lock-ids sender) index) ERR-OUT-OF-BOUNDS))
        (token-lock (try! (get-token-lock-by-id lock-id)))
        (is-vested (get is-vested token-lock))
        (user-lock-info (try! (get-user-lock-info sender lock-id)))
        (unlock-blocks (get unlock-blocks token-lock))
        (claim-index (get claim-index user-lock-info))
        (total-amount (get total-amount user-lock-info))
        (total-claimed (get total-claimed user-lock-info))
        (withdrawal-address (get withdrawal-address user-lock-info))
        (user-unlock-block (unwrap! (element-at? unlock-blocks claim-index) ERR-OUT-OF-BOUNDS))
        (height (get height user-unlock-block))
        (percentage (get percentage user-unlock-block))
        (unlock-amount (/ (* total-amount percentage) u100))
        (user-lock-info-updated (merge user-lock-info {
            claim-index: (+ claim-index u1),
            last-claim-block: block-height,
            total-claimed: (+ total-claimed unlock-amount)
          })
        )
      )

      (asserts! (> block-height height) ERR-REWARD-BLOCK-NOT-REACHED)
      (asserts! (is-eq (get locked-token token-lock) (contract-of locked-token)) ERR-INVALID-TOKEN)
      (asserts! (< total-claimed total-amount) ERR-CANNOT-EXCEED-CLAIM-AMOUNT)

      ;; transfer token from vault
      (as-contract (try! (contract-call? .memegoat-locker-vault-v1 transfer-ft locked-token unlock-amount withdrawal-address)))

      (map-set user-lock-info-map {address: sender, lock-id: lock-id} user-lock-info-updated)
      
      (if (is-eq claim-index (- (len unlock-blocks) u1))
        (begin
          (try! (remove-lock-id index lock-id sender))
          (map-delete user-lock-info-map {address: sender, lock-id: lock-id})
          (map-delete token-lock-map {lock-id: lock-id})
        )
        true
      )
    )
    (ok true)
  )
)

;; incrementlock
(define-public (increment-lock (locked-token <ft-trait>) (index uint) (amount uint)) 
  (begin 
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)

    (let
      (
        (sender tx-sender)
        (lock-id (unwrap! (element-at (get-user-lock-ids sender) index) ERR-OUT-OF-BOUNDS))
        (token-lock (try! (get-token-lock-by-id lock-id)))
        (is-vested (get is-vested token-lock))
        (unlock-blocks (get unlock-blocks token-lock))
        (total-locked (get total-amount token-lock))
        (user-lock-info (try! (get-user-lock-info sender lock-id)))
        (claim-index (get claim-index user-lock-info))
        (total-amount (get total-amount user-lock-info))
        (user-unlock-block (unwrap! (element-at? unlock-blocks claim-index) ERR-OUT-OF-BOUNDS))
        (token-lock-updated (merge token-lock {
          total-amount: (+ total-locked amount)
        }))
        (user-lock-info-updated (merge user-lock-info {
          total-amount: (+ total-amount amount)
        }))
      )

      ;; check that caller is owner
      (asserts! (is-eq (get lock-owner token-lock) sender) ERR-LOCK_MISMATCH)  
      (asserts! (not is-vested) ERR-ONLY-SINGLE-LOCK)
      (asserts! (is-eq (get locked-token token-lock) (contract-of locked-token)) ERR-INVALID-TOKEN)
      (asserts! (> (get height user-unlock-block) block-height) ERR-ALREADY-UNLOCKED)

      ;; transfer token to vault
      (try! (contract-call? locked-token transfer amount sender .memegoat-locker-vault-v1 none))
      (map-set token-lock-map { lock-id: lock-id} token-lock-updated)
      (map-set user-lock-info-map {address: sender, lock-id: lock-id} user-lock-info-updated)
    )
    (ok true)
  )
)

;; splitlock
(define-public (split-lock (index uint) (amount uint)) 
  (begin 
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (let
      (
        (sender tx-sender)
        (lock-id (unwrap! (element-at (get-user-lock-ids sender) index) ERR-OUT-OF-BOUNDS))
        (token-lock (try! (get-token-lock-by-id lock-id)))
        (locked-balance (get total-amount token-lock))
        (unlock-blocks (get unlock-blocks token-lock))
        (lock-block (get lock-block token-lock))
        (locked-token (get locked-token token-lock))
        (is-vested (get is-vested token-lock))
        (total-addresses (get total-addresses token-lock))

        (user-lock-info (try! (get-user-lock-info sender lock-id)))
        (total-amount (get total-amount user-lock-info))
        (total-claimed (get total-claimed user-lock-info))
        (withdrawal-address (get withdrawal-address user-lock-info))

        (token-lock-updated (merge token-lock {
          total-amount: (- locked-balance amount)
        }))

        (user-lock-info-updated (merge user-lock-info {
          total-amount: (- total-amount amount)
        }))

        (next-lock-id (+ (var-get lock-nonce) u1))
      )

      (asserts! (is-eq (get lock-owner token-lock) sender) ERR-LOCK_MISMATCH)
      (asserts! (not is-vested) ERR-ONLY-SINGLE-LOCK)
      (asserts! (< amount locked-balance) ERR-INVALID-AMOUNT)
      (asserts! (is-eq total-claimed u0) ERR-ALREADY-CLAIMED)

      (map-set token-lock-map {lock-id: lock-id} token-lock-updated)

      (map-set user-lock-info-map {address: sender, lock-id: lock-id} user-lock-info-updated)

      ;; create new token lock record
      (map-set token-lock-map 
        {lock-id: next-lock-id} 
        { 
          lock-block: block-height, 
          total-amount: amount, 
          lock-owner: sender, 
          locked-token: locked-token, 
          is-vested: false,
          unlock-blocks: unlock-blocks,
          total-addresses: total-addresses,
        }
      )

      ;; add lock id
      (try! (add-lock-id next-lock-id sender))
      (map-set user-lock-info-map 
        {address: sender, lock-id: next-lock-id} 
        {
          last-claim-block: u0, 
          claim-index: u0, 
          total-claimed: u0, 
          total-amount: amount, 
          withdrawal-address: withdrawal-address
        }
      )

      ;; update lock nonce
      (var-set lock-nonce next-lock-id)
    )
    (ok true)
  )
)

;; transferlockownership
(define-public (transfer-lock-ownership (index uint) (new-owner principal) (withdrawal-address principal)) 
  (begin
    (let
      (
        (sender tx-sender)
        (lock-id (unwrap! (element-at (get-user-lock-ids sender) index) ERR-OUT-OF-BOUNDS))
        (token-lock (try! (get-token-lock-by-id lock-id)))
        (is-vested (get is-vested token-lock))
        (token-lock-updated (merge token-lock {
          lock-owner: new-owner
        }))
      )
      (asserts! (is-eq (get lock-owner token-lock) sender) ERR-LOCK_MISMATCH)

      (try! (add-lock-id lock-id new-owner))
      (try! (remove-lock-id index lock-id sender))

      (if (not is-vested)
        (let
          (
            (user-lock-info (try! (get-user-lock-info sender lock-id)))
            (total-amount (get total-amount user-lock-info))
            (total-claimed (get total-claimed user-lock-info))
            (claim-index (get claim-index user-lock-info))
            (last-claim-block (get last-claim-block user-lock-info))
          )
          (map-set user-lock-info-map 
            {address: sender, lock-id: lock-id} 
            {
              last-claim-block: last-claim-block, 
              claim-index: claim-index, 
              total-claimed: total-claimed, 
              total-amount: total-amount, 
              withdrawal-address: withdrawal-address
            }
          )
          (map-delete user-lock-info-map {address: sender, lock-id: lock-id})
        )
        true
      )
      (map-set token-lock-map {lock-id: lock-id} token-lock-updated)
    )
    (ok true)
  )
)
