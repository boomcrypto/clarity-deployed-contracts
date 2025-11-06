(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant ststx-address 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
(define-constant aeusdc-address 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)
(define-constant wstx-address 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.wstx)
(define-constant diko-address 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token)
(define-constant usdh-address 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1)
(define-constant susdt-address 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt)
(define-constant usda-address 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token)
(define-constant sbtc-address 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)
(define-constant ststxbtc-address 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token)
(define-constant alex-address 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex)

(define-public (run-update)
  (let (
    (reserve-data-alex (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read alex-address)))
  )
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (print reserve-data-alex)

    (try!
      (contract-call? .pool-borrow-v2-2 set-reserve alex-address
        (merge reserve-data-alex { debt-ceiling: u1 })
      )
    )

    (print {
      ststx: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read alex-address ststx-address),
      aeusdc: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read alex-address aeusdc-address),
      wstx: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read alex-address wstx-address),
      diko: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read alex-address diko-address),
      usdh: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read alex-address usdh-address),
      susdt: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read alex-address susdt-address),
      usda: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read alex-address usda-address),
      sbtc: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read alex-address sbtc-address),
      ststxbtc: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read alex-address ststxbtc-address),
    })

    (try! (contract-call? .pool-reserve-data-3 set-approved-contract (as-contract tx-sender) true))

    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt alex-address sbtc-address u0))
  
    (try! (contract-call? .pool-reserve-data-3 set-approved-contract (as-contract tx-sender) false))

    (var-set executed true)
    (ok true)
  )
)

(define-public (disable)
  (begin
    (asserts! (is-eq deployer tx-sender) (err u11))
    (ok (var-set executed true))
  )
)

(define-read-only (can-execute)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (ok (not (var-get executed)))
  )
)