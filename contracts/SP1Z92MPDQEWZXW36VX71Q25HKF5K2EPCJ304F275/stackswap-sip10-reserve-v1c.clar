(impl-trait .stackswap-vault-trait-v1b.vault-trait)
(use-trait ft-trait .sip-010-v1a.sip-010-trait)
(use-trait vault-trait .stackswap-vault-trait-v1b.vault-trait)
(use-trait oracle-trait .stackwap-oracle-trait-v1b.oracle-trait)

(define-constant ERR-NOT-AUTHORIZED u9401)
(define-constant ERR-TRANSFER-FAILED u92)
(define-constant ERR-DEPOSIT-FAILED u95)
(define-constant ERR-WITHDRAW-FAILED u96)
(define-constant ERR-MINT-FAILED u97)
(define-constant ERR-WRONG-TOKEN u98)
(define-constant ERR-TOO-MUCH-DEBT u99)

(define-public (calculate-lbtc-count
  (token (string-ascii 12))
  (ucollateral-amount uint)
  (collateralization-ratio uint)
  (oracle <oracle-trait>)
)
  (let (
    (price (unwrap-panic (contract-call? oracle fetch-price token)))
    (btc-price (unwrap-panic (contract-call? oracle fetch-price "lBTC")))
    )
    (let ((amount
      (/
        (* (* ucollateral-amount (get last-price price)) u10000)
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
  (ucollateral uint)
  (oracle <oracle-trait>)
)
  (let (
    (price (unwrap-panic (contract-call? oracle fetch-price token)))
    (btc-price (unwrap-panic (contract-call? oracle fetch-price "lBTC")))   
    (temp (print {ucollateral: ucollateral, collateral-price: (get last-price price), debt: debt, btc-price: (get last-price btc-price)}))
    )
    (if (> debt u0)
      (ok
        (/
          (/
            (* (* ucollateral (get last-price price)) u100000000)
            (*
              debt
              (get last-price btc-price)
            )
          )
          (/ (get decimals price) u100)
        )
      )

      (err u0)
    )
  )
)


(define-data-var next-stacker-name (string-ascii 256) "staker")

(define-read-only (get-next-stacker-name)
  (ok (var-get next-stacker-name))
)


(define-public (collateralize-and-mint
  (token <ft-trait>)
  (token-string (string-ascii 12))
  (ucollateral-amount uint)
  (debt uint)
  (sender principal)
  (stacker-name (string-ascii 256))
  (stack-pox bool)
)
  (let (
    (token-symbol (unwrap-panic (contract-call? token get-symbol)))
  )
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "mortgager-l"))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq token-string token-symbol) (err ERR-WRONG-TOKEN))
    (asserts! (not (is-eq token-string "STX")) (err ERR-WRONG-TOKEN))

    (match (contract-call? token transfer ucollateral-amount sender (as-contract tx-sender) none)
      success (ok debt)
      error (err error)
    )
  )
)

(define-public (deposit (token <ft-trait>) (token-string (string-ascii 12)) (additional-ucollateral-amount uint) (stacker-name (string-ascii 256)))
  (let (
    (token-symbol (unwrap-panic (contract-call? token get-symbol)))
  )
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "mortgager-l"))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq token-string token-symbol) (err ERR-WRONG-TOKEN))
    (asserts! (not (is-eq token-string "STX")) (err ERR-WRONG-TOKEN))

    (match (contract-call? token transfer additional-ucollateral-amount tx-sender (as-contract tx-sender) none)
      success (ok true)
      error (err ERR-DEPOSIT-FAILED)
    )
  )
)

(define-public (withdraw (token <ft-trait>) (token-string (string-ascii 12)) (vault-owner principal) (ucollateral-amount uint))
  (let (
    (token-symbol (unwrap-panic (contract-call? token get-symbol)))
  )
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "mortgager-l"))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq token-string token-symbol) (err ERR-WRONG-TOKEN))
    (asserts! (not (is-eq token-symbol "STX")) (err ERR-WRONG-TOKEN))

    (if (> ucollateral-amount u0)
      (match (as-contract (contract-call? token transfer ucollateral-amount tx-sender vault-owner none))
        success (ok true)
        error (err ERR-WITHDRAW-FAILED)
      )
      (ok true)
    )
  )
)

(define-public (mint
  (token-string (string-ascii 12))
  (vault-owner principal)
  (ucollateral-amount uint)
  (current-debt uint)
  (extra-debt uint)
  (collateralization-ratio uint)
  (oracle <oracle-trait>)
)
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "mortgager-l"))) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (is-eq token-string "STX")) (err ERR-WRONG-TOKEN))

    (let ((max-new-debt (- (unwrap-panic (calculate-lbtc-count token-string ucollateral-amount collateralization-ratio oracle)) current-debt)))
      (if (>= max-new-debt extra-debt)
        (match (as-contract (contract-call? .lbtc-token-v1c mint-for-dao extra-debt vault-owner))
          success (ok true)
          error (err ERR-MINT-FAILED)
        )
        (err ERR-TOO-MUCH-DEBT)
      )
    )
  )
)

(define-public (burn (token <ft-trait>) (vault-owner principal) (collateral-to-return uint))
  (let (
    (token-symbol (unwrap-panic (contract-call? token get-symbol)))
  )
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "mortgager-l"))) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (is-eq token-symbol "STX")) (err ERR-WRONG-TOKEN))

    (match (as-contract (contract-call? token transfer collateral-to-return tx-sender vault-owner none))
      transferred (ok true)
      error (err ERR-TRANSFER-FAILED)
    )
  )
)


(define-public (migrate-funds (new-vault <vault-trait>) (token <ft-trait>))
  (begin
    (asserts! (is-eq contract-caller (contract-call? .stackswap-dao-v5k get-dao-owner)) (err ERR-NOT-AUTHORIZED))

    (let (
      (balance (unwrap-panic (contract-call? token get-balance (as-contract tx-sender))))
    )
      (as-contract (contract-call? token transfer balance tx-sender (contract-of new-vault) none))
    )
  )
)
