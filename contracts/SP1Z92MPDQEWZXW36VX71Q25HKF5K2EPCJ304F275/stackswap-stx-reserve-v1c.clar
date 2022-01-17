(impl-trait .stackswap-vault-trait-v1b.vault-trait)
(use-trait ft-trait .sip-010-v1a.sip-010-trait)
(use-trait vault-trait .stackswap-vault-trait-v1b.vault-trait)
(use-trait oracle-trait .stackwap-oracle-trait-v1b.oracle-trait)

(define-constant ERR-NOT-AUTHORIZED u11401)
(define-constant ERR-TRANSFER-FAILED u112)
(define-constant ERR-MINTER-FAILED u113)
(define-constant ERR-BURN-FAILED u114)
(define-constant ERR-DEPOSIT-FAILED u115)
(define-constant ERR-WITHDRAW-FAILED u116)
(define-constant ERR-MINT-FAILED u117)
(define-constant ERR-WRONG-TOKEN u118)
(define-constant ERR-TOO-MUCH-DEBT u119)

(define-data-var next-stacker-name (string-ascii 256) "stacker-l")
(define-map tokens-to-stack
  { stacker-name: (string-ascii 256) }
  {
    amount: uint
  }
)


(define-read-only (get-tokens-to-stack (name (string-ascii 256)))
  (ok (get amount (unwrap-panic (map-get? tokens-to-stack { stacker-name: name }))))
)

(define-public (add-tokens-to-stack (name (string-ascii 256)) (token-amount uint))
  (let (
    (stacker (unwrap-panic (map-get? tokens-to-stack { stacker-name: name })))
  )
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

    (map-set tokens-to-stack { stacker-name: name } { amount: (+ (get amount stacker) token-amount) })
    (ok u200)
  )
)

(define-public (subtract-tokens-to-stack (name (string-ascii 256)) (token-amount uint))
  (let (
    (stacker (unwrap-panic (map-get? tokens-to-stack { stacker-name: name })))
  )
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

    (map-set tokens-to-stack { stacker-name: name } { amount: (- (get amount stacker) token-amount) })
    (ok u200)
  )
)

(define-public (toggle-stacking (stacker-name (string-ascii 256)) (revoked-stacking bool) (ustx-collateral uint))
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "mortgager-l"))) (err ERR-NOT-AUTHORIZED))

    (if revoked-stacking
      (ok (try! (subtract-tokens-to-stack stacker-name ustx-collateral)))
      (ok (try! (add-tokens-to-stack stacker-name ustx-collateral)))
    )
  )
)

(define-public (request-stx-to-stack (name (string-ascii 256)) (requested-ustx uint))
  (let (
    (stacker (unwrap-panic (map-get? tokens-to-stack { stacker-name: name })))
  )
    (asserts!
      (or
        (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stacker-l")))
        (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stacker-l-2")))
        (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stacker-l-3")))
        (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stacker-l-4")))
      )
      (err ERR-NOT-AUTHORIZED)
    )
    (asserts! (<= requested-ustx (get amount stacker)) (err ERR-NOT-AUTHORIZED))

    (as-contract
      (stx-transfer? requested-ustx tx-sender (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name name)))
    )
  )
)

(define-read-only (get-next-stacker-name)
  (ok (var-get next-stacker-name))
)

(define-public (set-next-stacker-name (stacker-name (string-ascii 256)))
  (begin
    (if
      (or
        (is-eq tx-sender (contract-call? .stackswap-dao-v5k get-dao-owner))
        (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stacker-l")))
        (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stacker-l-2")))
        (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stacker-l-3")))
        (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stacker-l-4")))
      )
      (ok (var-set next-stacker-name stacker-name))
      (err ERR-NOT-AUTHORIZED)
    )
  )
)


(define-public (calculate-lbtc-count
  (token (string-ascii 12))
  (ustx-amount uint)
  (collateralization-ratio uint)
  (oracle <oracle-trait>)
)
  (let (
    (stx-price (unwrap-panic (contract-call? oracle fetch-price token)))
    (btc-price (unwrap-panic (contract-call? oracle fetch-price "lBTC")))
    )
    (let ((amount
      (/
        (*
          (* ustx-amount (get last-price stx-price))
          u10000
        )
        collateralization-ratio
      ))
    )
      (ok amount)
    )
  )
)

(define-public (calculate-current-collateral-to-debt-ratio
  (token (string-ascii 12))
  (debt uint)
  (ustx uint)
  (oracle <oracle-trait>)
)
  (let (
    (stx-price (unwrap-panic (contract-call? oracle fetch-price token)))
    (btc-price (unwrap-panic (contract-call? oracle fetch-price "lBTC")))
    )
    (if (> debt u0)
      (ok (/ (* (* ustx (get last-price stx-price)) u10000) (* debt (get last-price btc-price))))
      (err u0)
    )
  )
)


(define-public (collateralize-and-mint
  (token <ft-trait>)
  (token-string (string-ascii 12))
  (ustx-amount uint)
  (debt uint)
  (sender principal)
  (stacker-name (string-ascii 256))
  (stack-pox bool)
)
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "mortgager-l"))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq token-string "STX") (err ERR-WRONG-TOKEN))

    (match (print (stx-transfer? ustx-amount sender (as-contract tx-sender)))
      success (begin
        (if (is-eq stack-pox true)
          (try! (add-tokens-to-stack stacker-name ustx-amount))
          u0
        )
        (ok debt)
      )
      error (err ERR-TRANSFER-FAILED)
    )
  )
)

(define-public (deposit (token <ft-trait>) (token-string (string-ascii 12)) (additional-ustx-amount uint) (stacker-name (string-ascii 256)))
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "mortgager-l"))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq token-string "STX") (err ERR-WRONG-TOKEN))

    (match (print (stx-transfer? additional-ustx-amount tx-sender (as-contract tx-sender)))
      success (begin
        (try! (add-tokens-to-stack stacker-name additional-ustx-amount))
        (ok true)
      )
      error (err ERR-DEPOSIT-FAILED)
    )
  )
)

(define-public (withdraw (token <ft-trait>) (token-string (string-ascii 12)) (vault-owner principal) (ustx-amount uint))
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "mortgager-l"))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq token-string "STX") (err ERR-WRONG-TOKEN))

    (match (print (as-contract (stx-transfer? ustx-amount tx-sender vault-owner)))
      success (ok true)
      error (err ERR-WITHDRAW-FAILED)
    )
  )
)

(define-public (mint
  (token-string (string-ascii 12))
  (vault-owner principal)
  (ustx-amount uint)
  (current-debt uint)
  (extra-debt uint)
  (collateralization-ratio uint)
  (oracle <oracle-trait>)
)
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "mortgager-l"))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq token-string "STX") (err ERR-WRONG-TOKEN))

    (let ((max-new-debt (- (unwrap-panic (calculate-lbtc-count token-string ustx-amount collateralization-ratio oracle)) current-debt)))
      (if (>= max-new-debt extra-debt)
        (match (print (as-contract (contract-call? .lbtc-token-v1c mint-for-dao extra-debt vault-owner)))
          success (ok true)
          error (err ERR-MINT-FAILED)
        )
        (err ERR-TOO-MUCH-DEBT)
      )
    )
  )
)


(define-public (burn (token <ft-trait>) (vault-owner principal) (collateral-to-return uint))
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "mortgager-l"))) (err ERR-NOT-AUTHORIZED))

    (match (print (as-contract (stx-transfer? collateral-to-return tx-sender vault-owner)))
      transferred (ok true)
      error (err ERR-TRANSFER-FAILED)
    )
  )
)


(define-read-only (get-stx-balance)
  (stx-get-balance (as-contract tx-sender))
)

(define-public (set-tokens-to-stack (name (string-ascii 256)) (new-tokens-to-stack uint))
  (begin
    (asserts! (is-eq contract-caller (contract-call? .stackswap-dao-v5k get-dao-owner)) (err ERR-NOT-AUTHORIZED))

    (map-set tokens-to-stack { stacker-name: name } { amount: new-tokens-to-stack })
    (ok true)
  )
)

(define-public (migrate-funds (new-vault <vault-trait>))
  (begin
    (asserts! (is-eq contract-caller (contract-call? .stackswap-dao-v5k get-dao-owner)) (err ERR-NOT-AUTHORIZED))

    (as-contract (stx-transfer? (stx-get-balance tx-sender) tx-sender (contract-of new-vault)))
  )
)

(map-set tokens-to-stack { stacker-name: "stacker-l" } { amount: u0 })
(map-set tokens-to-stack { stacker-name: "stacker-l-2" } { amount: u0 })
(map-set tokens-to-stack { stacker-name: "stacker-l-3" } { amount: u0 })
(map-set tokens-to-stack { stacker-name: "stacker-l-4" } { amount: u0 })
