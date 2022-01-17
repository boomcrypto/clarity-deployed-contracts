(impl-trait .stackswap-manager-trait-v1b.vault-manager-trait)
(use-trait vault-trait .stackswap-vault-trait-v1b.vault-trait)
(use-trait ft-trait .sip-010-v1a.sip-010-trait)
(use-trait vault-manager-trait .stackswap-manager-trait-v1b.vault-manager-trait)
(use-trait collateral-types-trait .stackswap-collateral-types-trait-v1b.collateral-types-trait)
(use-trait oracle-trait .stackwap-oracle-trait-v1b.oracle-trait)

(define-constant ERR-NOT-AUTHORIZED u4401)
(define-constant ERR-TRANSFER-FAILED u42)
(define-constant ERR-MINTER-FAILED u43)
(define-constant ERR-BURN-FAILED u44)
(define-constant ERR-DEPOSIT-FAILED u45)
(define-constant ERR-WITHDRAW-FAILED u46)
(define-constant ERR-MINT-FAILED u47)
(define-constant ERR-LIQUIDATION-FAILED u48)
(define-constant ERR-INSUFFICIENT-COLLATERAL u49)
(define-constant ERR-INSUFFICIENT-LBTC u50)
(define-constant ERR-NO-LIQUIDATION-REQUIRED u52)
(define-constant ERR-MAXIMUM-DEBT-REACHED u410)
(define-constant ERR-BURN-HEIGHT-NOT-REACHED u412)
(define-constant ERR-VAULT-LIQUIDATED u413)
(define-constant ERR-STACKING-IN-PROGRESS u414)
(define-constant ERR-WRONG-COLLATERAL-TOKEN u415)
(define-constant ERR-VAULT-NOT-LIQUIDATED u416)
(define-constant ERR-WRONG-DEBT u417)
(define-constant ERR-LIQUIDATION-NOT-ENDED u418)
(define-constant ERR-WRONG-COLLATERAL-TYPE u419)
(define-constant ERR-VAULT-ALREADY-LIQUIDATED u420)
(define-constant ERR-VAULT-LIQUIDATION-ENDED u421)
(define-constant ERR-VAULT-LIQUIDATION-NOT-ENDED u422)
(define-constant ERR-VAULT-UPDATE u423)
(define-constant ERR-FEE-CALC u424)

(define-constant BLOCKS-PER-DAY u144)

(define-map stacking-unlock-burn-height
  { stacker-name: (string-ascii 256) }
  {
    height: uint
  }
)

(define-read-only (get-stacking-unlock-burn-height (name (string-ascii 256)))
  (ok (get height (unwrap-panic (map-get? stacking-unlock-burn-height { stacker-name: name }))))
)

(define-private (get-stacking-unlock-burn-height-calc (name (string-ascii 256) ))
  (match (map-get? stacking-unlock-burn-height { stacker-name: name }) height-tuple
    (get height height-tuple)
    u0
  )
)

(define-public (set-stacking-unlock-burn-height (name (string-ascii 256)) (burn-height uint))
  (begin
    (asserts! 
      (or
        (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stacker-l")))
        (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stacker-l-2")))
        (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stacker-l-3")))
        (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stacker-l-4")))
        (is-eq contract-caller (contract-call? .stackswap-dao-v5k get-dao-owner))
      )
      (err ERR-NOT-AUTHORIZED)
    )

    (ok (map-set stacking-unlock-burn-height { stacker-name: name } { height: burn-height }))
  )
)

(define-read-only (get-vault-by-id (vault-id uint))
  (contract-call? .stackswap-vault-data-v1c get-vault-by-id vault-id)
)

(define-read-only (get-vault-entries (user principal))
  (contract-call? .stackswap-vault-data-v1c get-vault-entries user)
)

(define-read-only (get-collateral-type-for-vault (vault-id uint))
  (let ((vault (get-vault-by-id vault-id)))
    (ok (get collateral-type vault))
  )
)

(define-read-only (get-collateral-token-for-vault (vault-id uint))
  (let ((vault (get-vault-by-id vault-id)))
    (ok (get collateral-token vault))
  )
)

(define-public (calculate-current-collateral-to-debt-ratio
  (vault-id uint)
  (coll-type <collateral-types-trait>)
  (oracle <oracle-trait>)
  (include-stability-fees bool)
)
  (let ((vault (get-vault-by-id vault-id)))
    (asserts! (is-eq (contract-of oracle) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "oracle-l"))) (err ERR-NOT-AUTHORIZED))
      (begin
        (let (
          (price (unwrap-panic (contract-call? oracle fetch-price (get collateral-token vault))))
          (btc-price (unwrap-panic (contract-call? oracle fetch-price "lBTC")))
          )
          (ok
            (/
              (/
                (* (* (get collateral vault) (get last-price price)) u100000000)
                (*
                  (+
                    (get debt vault)
                    (if include-stability-fees
                      (unwrap-panic (stability-fee-helper (get stability-fee-last-accrued vault) (get debt vault) (get collateral-type vault) coll-type))
                      u0
                    )
                  )
                  (get last-price btc-price)
                )
              )
              (/ (get decimals price) u100)
            )
          )
        )
      
    )
  )
)


(define-private (resolve-stacking-amount (collateral-amount uint) (collateral-token (string-ascii 12)) (stack-pox bool))
  (if (and (is-eq collateral-token "STX") stack-pox)
    collateral-amount
    u0
  )
)

(define-public (toggle-stacking (vault-id uint))
  (let (
    (vault (get-vault-by-id vault-id))
    (stacking-height (get-stacking-unlock-burn-height-calc (get stacker-name vault))))

    (asserts! (is-eq tx-sender (get owner vault)) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq "STX" (get collateral-token vault)) (err ERR-WRONG-COLLATERAL-TOKEN))
    (asserts! (is-eq false (get is-liquidated vault)) (err ERR-VAULT-LIQUIDATED))
    (try! (contract-call? .stackswap-stx-reserve-v1c toggle-stacking (get stacker-name vault) (not (get revoked-stacking vault)) (get collateral vault)))

    (try!
      (contract-call? .stackswap-vault-data-v1c update-vault vault-id (merge vault {
        revoked-stacking: (not (get revoked-stacking vault)),
        updated-at-block-height: block-height,
        toggled-at-block-height: stacking-height
      }))
    )
    (ok true)
  )
)

;; can be called by the vault owner on a non-liquidated STX vault
;; called when collateral was unstacked & want to stack again
(define-public (stack-collateral (vault-id uint))
  (let (
    (vault (get-vault-by-id vault-id))
    (stacking-height (get-stacking-unlock-burn-height-calc (get stacker-name vault))))

    (asserts! (is-eq contract-caller (get owner vault)) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq "STX" (get collateral-token vault)) (err ERR-WRONG-COLLATERAL-TOKEN))
    (asserts! (is-eq false (get is-liquidated vault)) (err ERR-VAULT-LIQUIDATED))
    (asserts! (is-eq u0 (get stacked-tokens vault)) (err ERR-STACKING-IN-PROGRESS))

    (try! (contract-call? .stackswap-stx-reserve-v1c add-tokens-to-stack (get stacker-name vault) (get collateral vault)))
    (try!
      (contract-call? .stackswap-vault-data-v1c update-vault vault-id (merge vault {
        stacked-tokens: (get collateral vault),
        revoked-stacking: false,
        updated-at-block-height: block-height,
        toggled-at-block-height: stacking-height
      }))
    )
    (ok true)
  )
)

(define-private (min-of (i1 uint) (i2 uint))
  (if (< i1 i2)
      i1
      i2))

(define-public (collateralize-and-mint
    (collateral-amount uint)
    (debt uint)
    (stack-pox bool)
    (collateral-type (string-ascii 12))
    (reserve <vault-trait>)
    (ft <ft-trait>)
    (coll-type <collateral-types-trait>)
    (oracle <oracle-trait>)
  )
  (let (
    (sender tx-sender)
    (collateral-type-object (unwrap-panic (contract-call? coll-type get-collateral-type-by-name collateral-type)))
    (collateral-token (get token collateral-type-object))
    (check-wrong-col-type (asserts! (not (is-eq "" (get name collateral-type-object))) (err ERR-WRONG-COLLATERAL-TYPE)))
    (stacker-name (unwrap-panic (contract-call? reserve get-next-stacker-name)))
  )

    (asserts! (is-eq (contract-of coll-type) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "collateral-types-l"))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (contract-of oracle) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "oracle-l"))) (err ERR-NOT-AUTHORIZED))
    (asserts!
      (or
        (is-eq (contract-of reserve) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stx-reserve-l")))
        (is-eq (contract-of reserve) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "sip10-reserve-l")))
      )
      (err ERR-NOT-AUTHORIZED)
    )
    (asserts!
      (or
        (is-eq collateral-token "STX")
        (is-eq (get token-address collateral-type-object) (contract-of ft))
      )
      (err ERR-WRONG-COLLATERAL-TOKEN)
    )
    (asserts!
      (<=
        (+ debt (get total-debt collateral-type-object))
        (get maximum-debt collateral-type-object)
      )
      (err ERR-MAXIMUM-DEBT-REACHED)
    )

    (try! (contract-call? reserve collateralize-and-mint ft collateral-token collateral-amount debt sender stacker-name stack-pox))
    (try! (as-contract (contract-call? .lbtc-token-v1c mint-for-dao debt sender)))
    (let (
      (vault-id (+ (contract-call? .stackswap-vault-data-v1c get-last-vault-id) u1))
      (vault {
        id: vault-id,
        owner: sender,
        collateral: collateral-amount,
        collateral-type: collateral-type,
        collateral-token: collateral-token,
        stacked-tokens: (resolve-stacking-amount collateral-amount collateral-token stack-pox),
        stacker-name: stacker-name,
        revoked-stacking: (not stack-pox),
        debt: debt,
        created-at-block-height: block-height,
        updated-at-block-height: block-height,
        toggled-at-block-height: burn-block-height,
        stability-fee-accrued: u0,
        stability-fee-last-accrued: block-height,
        is-liquidated: false,
        liquidation-finished: false,
      })
    )
      (try! (contract-call? .stackswap-vault-data-v1c update-vault-entries sender vault-id))
      (try! (contract-call? .stackswap-vault-data-v1c update-vault vault-id vault))
      (asserts! (>= 
        (unwrap!
          (calculate-current-collateral-to-debt-ratio 
            vault-id
            coll-type
            oracle
            false
          )
          (err ERR-WRONG-DEBT)
        )
        (get collateral-to-debt-ratio collateral-type-object)) (err ERR-INSUFFICIENT-COLLATERAL))
      (try! (contract-call? .stackswap-vault-data-v1c set-last-vault-id vault-id))
      (try! (contract-call? coll-type add-debt-to-collateral-type collateral-type debt))
      (print { type: "vault", action: "created", data: vault })
      (ok debt)
    )
  )
)

(define-public (deposit
  (vault-id uint)
  (uamount uint)
  (reserve <vault-trait>)
  (ft <ft-trait>)
  (coll-type <collateral-types-trait>)
)
  (let (
    (vault (get-vault-by-id vault-id))
    (collateral-token (unwrap-panic (get-collateral-token-for-vault vault-id)))
    (new-collateral (+ uamount (get collateral vault)))
    (updated-vault (merge vault {
      collateral: new-collateral,
      updated-at-block-height: block-height
    }))
  )

    (asserts!
      (or
        (is-eq (contract-of reserve) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stx-reserve-l")))
        (is-eq (contract-of reserve) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "sip10-reserve-l")))
      )
      (err ERR-NOT-AUTHORIZED)
    )
    (asserts! (is-eq (contract-of coll-type) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "collateral-types-l"))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (get is-liquidated vault) false) (err ERR-VAULT-LIQUIDATED))
    (asserts! (is-eq tx-sender (get owner vault)) (err ERR-NOT-AUTHORIZED))
    (asserts!
      (or
        (is-eq collateral-token "STX")
        (is-eq (unwrap-panic (contract-call? coll-type get-token-address (get collateral-type vault))) (contract-of ft))
      )
      (err ERR-WRONG-COLLATERAL-TOKEN)
    )

    (unwrap! (contract-call? reserve deposit ft collateral-token uamount (get stacker-name vault)) (err ERR-DEPOSIT-FAILED))
    (try! (contract-call? .stackswap-vault-data-v1c update-vault vault-id updated-vault))
    (print { type: "vault", action: "deposit", data: updated-vault })
    (ok true)
  )
)

(define-public (withdraw
  (vault-id uint)
  (uamount uint)
  (reserve <vault-trait>)
  (ft <ft-trait>)
  (coll-type <collateral-types-trait>)
  (oracle <oracle-trait>)
)
  (let (
    (vault (get-vault-by-id vault-id))
    (collateral-token (unwrap-panic (get-collateral-token-for-vault vault-id)))
  )

    (asserts!
      (or
        (is-eq (contract-of reserve) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stx-reserve-l")))
        (is-eq (contract-of reserve) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "sip10-reserve-l")))
      )
      (err ERR-NOT-AUTHORIZED)
    )
    (asserts! (is-eq (contract-of coll-type) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "collateral-types-l"))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (contract-of oracle) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "oracle-l"))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (get is-liquidated vault) false) (err ERR-VAULT-LIQUIDATED))
    (asserts! (is-eq tx-sender (get owner vault)) (err ERR-NOT-AUTHORIZED))
    (asserts! (> uamount u0) (err ERR-INSUFFICIENT-COLLATERAL))
    (asserts! (<= uamount (get collateral vault)) (err ERR-INSUFFICIENT-COLLATERAL))
    (asserts! (is-eq u0 (get stacked-tokens vault)) (err ERR-STACKING-IN-PROGRESS))
    (asserts!
      (or
        (is-eq collateral-token "STX")
        (is-eq (unwrap-panic (contract-call? coll-type get-token-address (get collateral-type vault))) (contract-of ft))
      )
      (err ERR-WRONG-COLLATERAL-TOKEN)
    )
    (try! (accrue-stability-fee vault-id coll-type))
    (let (
      (new-collateral (- (get collateral vault) uamount))
      (updated-vault (merge vault {
        collateral: new-collateral,
        updated-at-block-height: block-height
      }))
      (update-result (unwrap! (contract-call? .stackswap-vault-data-v1c update-vault vault-id updated-vault) (err ERR-VAULT-UPDATE)))
      (ratio (unwrap-panic 
        (calculate-current-collateral-to-debt-ratio 
          vault-id
          coll-type
          oracle
          true
        )
      ))
      )
          
      (asserts! (>= ratio (unwrap-panic (contract-call? coll-type get-collateral-to-debt-ratio (get collateral-type vault)))) (err ERR-INSUFFICIENT-COLLATERAL))
      (unwrap! (contract-call? reserve withdraw ft collateral-token (get owner vault) uamount) (err ERR-WITHDRAW-FAILED))
      (try! (contract-call? .stackswap-vault-data-v1c update-vault vault-id updated-vault))
      (print { type: "vault", action: "withdraw", data: updated-vault })
      (ok true)
    )
  )
)


(define-public (mint
  (vault-id uint)
  (extra-debt uint)
  (reserve <vault-trait>)
  (coll-type <collateral-types-trait>)
  (oracle <oracle-trait>)
)
  (let (
    (vault (get-vault-by-id vault-id))
    (new-total-debt (+ extra-debt (get debt vault)))
    (updated-vault (merge vault {
      debt: new-total-debt,
      updated-at-block-height: block-height
    }))
    (collateral-type (unwrap-panic (contract-call? coll-type get-collateral-type-by-name (get collateral-type vault))))
  )
    (asserts!
      (or
        (is-eq (contract-of reserve) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stx-reserve-l")))
        (is-eq (contract-of reserve) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "sip10-reserve-l")))
      )
      (err ERR-NOT-AUTHORIZED)
    )
    (asserts! (is-eq (contract-of coll-type) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "collateral-types-l"))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (contract-of oracle) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "oracle-l"))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (get is-liquidated vault) false) (err ERR-VAULT-LIQUIDATED))
    (asserts! (is-eq tx-sender (get owner vault)) (err ERR-NOT-AUTHORIZED))
    (asserts!
      (<=
        (+ extra-debt (get total-debt collateral-type))
        (get maximum-debt collateral-type)
      )
      (err ERR-MAXIMUM-DEBT-REACHED)
    )

    (try! (accrue-stability-fee vault-id coll-type))
    (try! (contract-call? reserve mint
        (get collateral-token vault)
        (get owner vault)
        (get collateral vault)
        (get debt vault)
        extra-debt
        (get collateral-to-debt-ratio collateral-type)
        oracle
      )
    )
    (try! (contract-call? .stackswap-vault-data-v1c update-vault vault-id updated-vault))
    (asserts! (>= 
      (unwrap!
        (calculate-current-collateral-to-debt-ratio 
          vault-id
          coll-type
          oracle
          true
        )
        (err ERR-WRONG-DEBT)
      )
      (get collateral-to-debt-ratio collateral-type)) (err ERR-INSUFFICIENT-COLLATERAL))
    (try! (contract-call? coll-type add-debt-to-collateral-type (get collateral-type vault) extra-debt))
    (print { type: "vault", action: "mint", data: updated-vault })
    (ok true)
  )
)

(define-public (burn
  (vault-id uint)
  (debt uint)
  (reserve <vault-trait>)
  (ft <ft-trait>)
  (coll-type <collateral-types-trait>)
)
  (let ((vault (get-vault-by-id vault-id)))

    (asserts!
      (or
        (is-eq (contract-of reserve) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stx-reserve-l")))
        (is-eq (contract-of reserve) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "sip10-reserve-l")))
      )
      (err ERR-NOT-AUTHORIZED)
    )
    (asserts! (is-eq (contract-of coll-type) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "collateral-types-l"))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (get is-liquidated vault) false) (err ERR-VAULT-LIQUIDATED))
    (asserts!
      (or
        (is-eq (get collateral-token vault) "STX")
        (is-eq (unwrap-panic (contract-call? coll-type get-token-address (get collateral-type vault))) (contract-of ft))
      )
      (err ERR-WRONG-COLLATERAL-TOKEN)
    )
    (try! (pay-stability-fee vault-id coll-type))
    (print { type: "vault", action: "burn", data: vault })
    (burn-partial-debt vault-id (min-of debt (get debt vault)) coll-type)
  )
)

(define-public (close-vault
  (vault-id uint)
  (reserve <vault-trait>)
  (ft <ft-trait>)
  (coll-type <collateral-types-trait>)
)
  (let ((vault (get-vault-by-id vault-id))
       (updated-vault (merge vault {
          collateral: u0,
          debt: u0,
          updated-at-block-height: block-height
        })))
    (asserts! (is-eq u0 (get stacked-tokens vault)) (err ERR-STACKING-IN-PROGRESS))
    (asserts! (is-eq (contract-of coll-type) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "collateral-types-l"))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (get is-liquidated vault) false) (err ERR-VAULT-LIQUIDATED))
    (asserts!
      (or
        (is-eq (contract-of reserve) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stx-reserve-l")))
        (is-eq (contract-of reserve) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "sip10-reserve-l")))
      )
      (err ERR-NOT-AUTHORIZED)
    )
    (asserts!
      (or
        (is-eq (get collateral-token vault) "STX")
        (is-eq (unwrap-panic (contract-call? coll-type get-token-address (get collateral-type vault))) (contract-of ft))
      )
      (err ERR-WRONG-COLLATERAL-TOKEN)
    )

    (if (is-eq (get debt vault) u0)
      true
      (try! (contract-call? .lbtc-token-v1c burn-for-dao (get debt vault) (get owner vault)))
    )
    (try! (pay-stability-fee vault-id coll-type))
    (try! (contract-call? reserve burn ft (get owner vault) (get collateral vault)))
    (try! (contract-call? coll-type subtract-debt-from-collateral-type (get collateral-type vault) (get debt vault)))
    (print { type: "vault", action: "close", data: updated-vault })
    (try! (contract-call? .stackswap-vault-data-v1c close-vault vault-id))
    (ok true)
  )
)

(define-private (burn-partial-debt
  (vault-id uint)
  (debt uint)
  (coll-type <collateral-types-trait>)
)
  (let ((vault (get-vault-by-id vault-id)))
    (try! (contract-call? .lbtc-token-v1c burn-for-dao debt tx-sender))
    (try! (contract-call? .stackswap-vault-data-v1c update-vault vault-id (merge vault {
        debt: (- (get debt vault) debt),
        updated-at-block-height: block-height
      }))
    )
    (try! (contract-call? coll-type subtract-debt-from-collateral-type (get collateral-type vault) debt))
    (ok true)
  )
)


(define-public (get-stability-fee-for-vault
  (vault-id uint)
  (coll-type <collateral-types-trait>)
)
  (let (
    (vault (get-vault-by-id vault-id))
  )
    (stability-fee-helper (get stability-fee-last-accrued vault) (get debt vault) (get collateral-type vault) coll-type)
  )
)

(define-private (stability-fee-helper
  (stability-fee-last-accrued uint)
  (debt uint)
  (collateral-type-string (string-ascii 12))
  (coll-type <collateral-types-trait>)
)
  (let (
    (number-of-blocks (- block-height stability-fee-last-accrued))
    (collateral-type (unwrap-panic (contract-call? coll-type get-collateral-type-by-name collateral-type-string)))
    (fee (get stability-fee collateral-type))
    (decimals (get stability-fee-decimals collateral-type))
    (interest (/ (* number-of-blocks (* debt fee)) (pow u10 decimals)))
  )
    (asserts! (is-eq (contract-of coll-type) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "collateral-types-l"))) (err ERR-NOT-AUTHORIZED))
    (ok interest)
  )
)

(define-public (accrue-stability-fee
  (vault-id uint)
  (coll-type <collateral-types-trait>)
)
  (let (
    (vault (get-vault-by-id vault-id))
  )
    (asserts! (is-eq (contract-of coll-type) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "collateral-types-l"))) (err ERR-NOT-AUTHORIZED))
    (try! (contract-call? .stackswap-vault-data-v1c update-vault vault-id (merge vault {
        updated-at-block-height: block-height,
        stability-fee-accrued: (unwrap-panic (get-stability-fee-for-vault vault-id coll-type)),
        stability-fee-last-accrued: block-height
      }))
    )
    (ok true)
  )
)

(define-public (pay-stability-fee
  (vault-id uint)
  (coll-type <collateral-types-trait>)
)
  (let (
    (vault (get-vault-by-id vault-id))
    (fee (+ (get stability-fee-accrued vault) (unwrap-panic (get-stability-fee-for-vault vault-id coll-type))))
  )
    (asserts! (is-eq (contract-of coll-type) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "collateral-types-l"))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (get is-liquidated vault) false) (err ERR-VAULT-LIQUIDATED))
    (if (> fee u0)
      (begin
        (try! (contract-call? .lbtc-token-v1c transfer fee tx-sender (as-contract tx-sender) none))
        (try! (contract-call? .stackswap-vault-data-v1c update-vault vault-id (merge vault {
            updated-at-block-height: block-height,
            stability-fee-accrued: u0,
            stability-fee-last-accrued: block-height
          }))
        )
        (ok fee)
      )
      (ok fee)
    )
  )
)

(define-public (notify-risky-vault
  (vault-id uint)
  (coll-type <collateral-types-trait>)
  (oracle <oracle-trait>)
)
  (let (
    (collateral-type (unwrap-panic (get-collateral-type-for-vault vault-id)))
    (liquidation-ratio (unwrap-panic (contract-call? coll-type get-liquidation-ratio collateral-type)))
  )
    (asserts! (is-eq (contract-of coll-type) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "collateral-types-l"))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (contract-of oracle) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "oracle-l"))) (err ERR-NOT-AUTHORIZED))

    (asserts! (>= 
      liquidation-ratio
      (unwrap!
        (calculate-current-collateral-to-debt-ratio 
          vault-id
          coll-type
          oracle
          true
        )
        (err ERR-WRONG-DEBT)
      )
      ) (err ERR-NO-LIQUIDATION-REQUIRED))

    (print "Vault is in danger. Time to liquidate.")
    (liquidate vault-id coll-type)
  )
)


(define-private (liquidate
  (vault-id uint)
  (coll-type <collateral-types-trait>)
)
  (let ((vault (get-vault-by-id vault-id)))

    (let (
      (collateral (get collateral vault))
      (fee (unwrap-panic (get-stability-fee-for-vault vault-id coll-type)))
    )
      (print { type: "vault", action: "liquidated", data: vault })
      (begin
        (try! (contract-call? .stackswap-vault-data-v1c update-vault vault-id (merge vault {
            updated-at-block-height: block-height,
            is-liquidated: true,
            liquidation-finished: false,
          }))
        )
        (ok (tuple (ustx-amount collateral) (vault-debt (+ fee (get debt vault))) ))
      )
    )
  )
)

(define-public (burn-to-unliquidate
  (vault-id uint)
  (debt uint)
  (reserve <vault-trait>)
  (coll-type <collateral-types-trait>)
  (oracle <oracle-trait>)
)
  (let (
    (vault (get-vault-by-id vault-id))
    (new-total-debt (- (get debt vault) debt))
    (updated-vault (merge vault {
      is-liquidated: false,
      updated-at-block-height: block-height
    }))
    (collateral-type (unwrap-panic (contract-call? coll-type get-collateral-type-by-name (get collateral-type vault))))
  )

    (asserts!
      (or
        (is-eq (contract-of reserve) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stx-reserve-l")))
        (is-eq (contract-of reserve) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "sip10-reserve-l")))
      )
      (err ERR-NOT-AUTHORIZED)
    )
    (asserts! (is-eq (contract-of coll-type) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "collateral-types-l"))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (contract-of oracle) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "oracle-l"))) (err ERR-NOT-AUTHORIZED))

    (asserts! (is-eq (get is-liquidated vault) true) (err ERR-VAULT-LIQUIDATED))
    (asserts! (< block-height (+ (get updated-at-block-height vault) u144)) (err ERR-VAULT-LIQUIDATION-ENDED))
    (try! (contract-call? .stackswap-vault-data-v1c update-vault vault-id updated-vault))
    (try! (accrue-stability-fee vault-id coll-type))
    (try! (burn-partial-debt vault-id (min-of debt (get debt vault)) coll-type))
    (asserts! (>= 
      (unwrap!
        (calculate-current-collateral-to-debt-ratio 
          vault-id
          coll-type
          oracle
          true
        )
        (err ERR-WRONG-DEBT)
      )
      (get collateral-to-debt-ratio collateral-type)) (err ERR-INSUFFICIENT-LBTC))
    (print { type: "vault", action: "burn-to-unliquidate", data: updated-vault })
    (ok true)
  )
)


(define-public (deposit-to-unliquidate
  (vault-id uint)
  (uamount uint)
  (reserve <vault-trait>)
  (ft <ft-trait>)
  (coll-type <collateral-types-trait>)
  (oracle <oracle-trait>)
)
  (let (
      (vault (get-vault-by-id vault-id))
      (collateral-token (unwrap-panic (get-collateral-token-for-vault vault-id)))
      (new-collateral (+ uamount (get collateral vault)))
      (updated-vault (merge vault {
        collateral: new-collateral,
        is-liquidated: false,
        updated-at-block-height: block-height
      }))
      (collateral-type (unwrap-panic (contract-call? coll-type get-collateral-type-by-name (get collateral-type vault))))
    )

    (asserts!
      (or
        (is-eq (contract-of reserve) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stx-reserve-l")))
        (is-eq (contract-of reserve) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "sip10-reserve-l")))
      )
      (err ERR-NOT-AUTHORIZED)
    )

    (asserts! (is-eq (contract-of coll-type) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "collateral-types-l"))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (contract-of oracle) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "oracle-l"))) (err ERR-NOT-AUTHORIZED))

    (asserts! (is-eq (get is-liquidated vault) true) (err ERR-VAULT-LIQUIDATED))
    (asserts! (< block-height (+ (get updated-at-block-height vault) u144)) (err ERR-VAULT-LIQUIDATION-ENDED))

    (asserts! (is-eq tx-sender (get owner vault)) (err ERR-NOT-AUTHORIZED))
    (asserts!
      (or
        (is-eq collateral-token "STX")
        (is-eq (unwrap-panic (contract-call? coll-type get-token-address (get collateral-type vault))) (contract-of ft))
      )
      (err ERR-WRONG-COLLATERAL-TOKEN)
    )

    (unwrap! (contract-call? reserve deposit ft collateral-token uamount (get stacker-name vault)) (err ERR-DEPOSIT-FAILED))
    (try! (accrue-stability-fee vault-id coll-type))
    (try! (contract-call? .stackswap-vault-data-v1c update-vault vault-id updated-vault))
    (asserts! (>= 
      (unwrap!
        (calculate-current-collateral-to-debt-ratio 
          vault-id
          coll-type
          oracle
          true
        )
        (err ERR-WRONG-DEBT)
      )
      (get collateral-to-debt-ratio collateral-type)) (err ERR-INSUFFICIENT-COLLATERAL))
    (print { type: "vault", action: "deposit-to-unliquidate", data: updated-vault })
    (ok true)
  )
)

(define-public (finalize-liquidation
  (vault-id uint)
)
  (let (
    (vault (get-vault-by-id vault-id))
    (stacking-height (get-stacking-unlock-burn-height-calc (get stacker-name vault)))
    (payout-address (contract-call? .stackswap-dao-v5k get-payout-address))
    )

    (asserts! (is-eq (get is-liquidated vault) true) (err ERR-VAULT-NOT-LIQUIDATED))
    (asserts! (is-eq (get liquidation-finished vault) false) (err ERR-VAULT-ALREADY-LIQUIDATED))
    (asserts! (> block-height (+ (get updated-at-block-height vault) u144)) (err ERR-VAULT-LIQUIDATION-NOT-ENDED))
  
    (if (and (not (get revoked-stacking vault)) (is-eq "STX" (get collateral-token vault)))
      (try! (contract-call? .stackswap-stx-reserve-v1c toggle-stacking (get stacker-name vault) true (get collateral vault)))
      u0
    )
    (try! (contract-call? .stackswap-vault-data-v1c finalize-liquidate-vault vault-id (merge vault {
        owner: payout-address,
        updated-at-block-height: block-height,
        liquidation-finished: true,
        revoked-stacking: true,
        toggled-at-block-height: stacking-height
      }))
    )
    (ok true)
  )
)


(define-read-only (get-lbtc-balance)
  (contract-call? .lbtc-token-v1c get-balance (as-contract tx-sender))
)

(define-read-only (get-stsw-balance)
  (contract-call? .stsw-token-v4a get-balance (as-contract tx-sender))
)


(define-public (redeem-tokens (lbtc-amount uint) (stsw-amount uint))
  (begin

    (if (and (> lbtc-amount u0) (> stsw-amount u0))
      (begin
        (try! (as-contract (contract-call? .stsw-token-v4a transfer stsw-amount tx-sender (contract-call? .stackswap-dao-v5k get-payout-address) none)))
        (as-contract (contract-call? .lbtc-token-v1c transfer lbtc-amount tx-sender (contract-call? .stackswap-dao-v5k get-payout-address) none))
      )
      (if (> lbtc-amount u0)
        (as-contract (contract-call? .lbtc-token-v1c transfer lbtc-amount tx-sender (contract-call? .stackswap-dao-v5k get-payout-address) none))
        (as-contract (contract-call? .stsw-token-v4a transfer stsw-amount tx-sender (contract-call? .stackswap-dao-v5k get-payout-address) none))
      )
    )
  )
)


(define-public (withdraw-liquidated
  (vault-id uint)
  (uamount uint)
  (reserve <vault-trait>)
  (ft <ft-trait>)
  (coll-type <collateral-types-trait>)
)
  (let (
    (vault (get-vault-by-id vault-id))
    (collateral-token (unwrap-panic (get-collateral-token-for-vault vault-id)))
  )

    (asserts!
      (or
        (is-eq (contract-of reserve) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stx-reserve-l")))
        (is-eq (contract-of reserve) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "sip10-reserve-l")))
      )
      (err ERR-NOT-AUTHORIZED)
    )
    (asserts! (is-eq (contract-of coll-type) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "collateral-types-l"))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (get is-liquidated vault) true) (err ERR-VAULT-LIQUIDATED))
    (asserts! (is-eq (get liquidation-finished vault) true) (err ERR-LIQUIDATION-NOT-ENDED))

    (asserts! (is-eq tx-sender (get owner vault)) (err ERR-NOT-AUTHORIZED))
    (asserts! (> uamount u0) (err ERR-INSUFFICIENT-COLLATERAL))
    (asserts! (<= uamount (get collateral vault)) (err ERR-INSUFFICIENT-COLLATERAL))
    (asserts! (is-eq u0 (get stacked-tokens vault)) (err ERR-STACKING-IN-PROGRESS))
    (asserts!
      (or
        (is-eq collateral-token "STX")
        (is-eq (unwrap-panic (contract-call? coll-type get-token-address (get collateral-type vault))) (contract-of ft))
      )
      (err ERR-WRONG-COLLATERAL-TOKEN)
    )

    (let (
      (new-collateral (- (get collateral vault) uamount))
      (updated-vault (merge vault {
        collateral: new-collateral,
        updated-at-block-height: block-height
      })))
      (unwrap! (contract-call? reserve withdraw ft collateral-token (get owner vault) uamount) (err ERR-WITHDRAW-FAILED))
      (try! (contract-call? .stackswap-vault-data-v1c update-vault vault-id updated-vault))
      (print { type: "vault", action: "withdraw", data: updated-vault })
      (ok true)
    )
  )
)

(define-public (burn-liquidated
  (vault-id uint)
  (debt uint)
  (reserve <vault-trait>)
  (coll-type <collateral-types-trait>)
)
  (let ((vault (get-vault-by-id vault-id)))

    (asserts!
      (or
        (is-eq (contract-of reserve) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stx-reserve-l")))
        (is-eq (contract-of reserve) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "sip10-reserve-l")))
      )
      (err ERR-NOT-AUTHORIZED)
    )
    (asserts! (is-eq (contract-of coll-type) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "collateral-types-l"))) (err ERR-NOT-AUTHORIZED))

    (asserts! (is-eq (get is-liquidated vault) true) (err ERR-VAULT-LIQUIDATED))
    (asserts! (is-eq (get liquidation-finished vault) true) (err ERR-LIQUIDATION-NOT-ENDED))


    (print { type: "vault", action: "burn", data: vault })
    (burn-partial-debt vault-id (min-of debt (get debt vault)) coll-type)
  )
)


(define-public (close-vault-liquidated
  (vault-id uint)
  (reserve <vault-trait>)
  (ft <ft-trait>)
  (coll-type <collateral-types-trait>)
)
  (let ((vault (get-vault-by-id vault-id))
       (updated-vault (merge vault {
          collateral: u0,
          debt: u0,
          updated-at-block-height: block-height
        })))
    (asserts! (is-eq tx-sender (get owner vault)) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq u0 (get stacked-tokens vault)) (err ERR-STACKING-IN-PROGRESS))
    (asserts! (is-eq (contract-of coll-type) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "collateral-types-l"))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (get is-liquidated vault) true) (err ERR-VAULT-LIQUIDATED))
    (asserts! (is-eq (get liquidation-finished vault) true) (err ERR-LIQUIDATION-NOT-ENDED))
    (asserts!
      (or
        (is-eq (contract-of reserve) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stx-reserve-l")))
        (is-eq (contract-of reserve) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "sip10-reserve-l")))
      )
      (err ERR-NOT-AUTHORIZED)
    )
    (asserts!
      (or
        (is-eq (get collateral-token vault) "STX")
        (is-eq (unwrap-panic (contract-call? coll-type get-token-address (get collateral-type vault))) (contract-of ft))
      )
      (err ERR-WRONG-COLLATERAL-TOKEN)
    )

    (if (is-eq (get debt vault) u0)
      true
      (try! (contract-call? .lbtc-token-v1c burn-for-dao (get debt vault) (get owner vault)))
    )
    (if (is-eq (get collateral vault) u0)
      true
      (try! (contract-call? reserve burn ft (get owner vault) (get collateral vault)))
    )
    (try! (contract-call? coll-type subtract-debt-from-collateral-type (get collateral-type vault) (get debt vault)))
    ;; (try! (contract-call? .stackswap-vault-data-v1c update-vault vault-id updated-vault))
    (print { type: "vault", action: "close-liquidated", data: updated-vault })
    (try! (contract-call? .stackswap-vault-data-v1c close-vault-liquidated vault-id))
    (ok true)
  )
)


;; initialization
(map-set stacking-unlock-burn-height { stacker-name: "stacker-l" } { height: u0 })
(map-set stacking-unlock-burn-height { stacker-name: "stacker-l-2" } { height: u0 })
(map-set stacking-unlock-burn-height { stacker-name: "stacker-l-3" } { height: u0 })
(map-set stacking-unlock-burn-height { stacker-name: "stacker-l-4" } { height: u0 })
