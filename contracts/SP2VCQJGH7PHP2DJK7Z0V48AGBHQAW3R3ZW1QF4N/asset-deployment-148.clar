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

(define-constant one-8 u100000000)

(define-constant ststx-debt {
  ststx: u490674803535,
  aeusdc: u136235011246,
  wstx: u1498796623816,
  diko: u351013565713,
  usdh: u6992880302707,
  susdt: u5303950481492,
  usda: u4804193963,
  sbtc: u38276,
  ststxbtc: u0,
})

(define-constant wstx-debt {
  ststx: u490674803535,
  aeusdc: u136235011246,
  wstx: u1498796623816,
  diko: u351013565713,
  usdh: u6992880302707,
  susdt: u5303950481492,
  usda: u4804193963,
  sbtc: u38276,
  ststxbtc: u0,
})

(define-constant ststxbtc-debt {
  ststx: u490674803535,
  aeusdc: u136235011246,
  wstx: u1498796623816,
  diko: u351013565713,
  usdh: u6992880302707,
  susdt: u5303950481492,
  usda: u4804193963,
  sbtc: u38276,
  ststxbtc: u0,
})

(define-constant sbtc-debt {
  ststx: u490674803535,
  aeusdc: u136235011246,
  wstx: u1498796623816,
  diko: u351013565713,
  usdh: u6992880302707,
  susdt: u5303950481492,
  usda: u4804193963,
  sbtc: u38276,
  ststxbtc: u0,
})

(define-public (run-update)
  (let (
    (reserve-data-ststx (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read ststx-address)))
  )
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (print reserve-data-ststx)

    (try!
      (contract-call? .pool-borrow-v2-1 set-reserve ststx-address
        (merge reserve-data-ststx { debt-ceiling: (* u2000000 one-8) })
      )
    )

    (print "ststx")
    (print {
      ststx: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststx-address ststx-address),
      aeusdc: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststx-address aeusdc-address),
      wstx: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststx-address wstx-address),
      diko: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststx-address diko-address),
      usdh: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststx-address usdh-address),
      susdt: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststx-address susdt-address),
      usda: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststx-address usda-address),
      sbtc: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststx-address sbtc-address),
      ststxbtc: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststx-address ststxbtc-address),
    })

    (print "wstx")
    (print {
      ststx: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read wstx-address ststx-address),
      aeusdc: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read wstx-address aeusdc-address),
      wstx: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read wstx-address wstx-address),
      diko: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read wstx-address diko-address),
      usdh: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read wstx-address usdh-address),
      susdt: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read wstx-address susdt-address),
      usda: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read wstx-address usda-address),
      sbtc: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read wstx-address sbtc-address),
      ststxbtc: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read wstx-address ststxbtc-address),
    })

    (print "ststxbtc")
    (print {
      ststx: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststxbtc-address ststx-address),
      aeusdc: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststxbtc-address aeusdc-address),
      wstx: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststxbtc-address wstx-address),
      diko: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststxbtc-address diko-address),
      usdh: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststxbtc-address usdh-address),
      susdt: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststxbtc-address susdt-address),
      usda: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststxbtc-address usda-address),
      sbtc: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststxbtc-address sbtc-address),
      ststxbtc: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststxbtc-address ststxbtc-address),
    })

    (print "sbtc")
    (print {
      ststx: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read sbtc-address ststx-address),
      aeusdc: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read sbtc-address aeusdc-address),
      wstx: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read sbtc-address wstx-address),
      diko: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read sbtc-address diko-address),
      usdh: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read sbtc-address usdh-address),
      susdt: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read sbtc-address susdt-address),
      usda: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read sbtc-address usda-address),
      sbtc: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read sbtc-address sbtc-address),
      ststxbtc: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read sbtc-address ststxbtc-address),
    })

    (try! (contract-call? .pool-reserve-data-3 set-approved-contract (as-contract tx-sender) true))


    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt ststx-address ststx-address (get ststx ststx-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt ststx-address aeusdc-address (get aeusdc ststx-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt ststx-address wstx-address (get wstx ststx-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt ststx-address diko-address (get diko ststx-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt ststx-address usdh-address (get usdh ststx-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt ststx-address susdt-address (get susdt ststx-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt ststx-address usda-address (get usda ststx-debt)))

    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt wstx-address ststx-address (get ststx wstx-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt wstx-address aeusdc-address (get aeusdc wstx-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt wstx-address wstx-address (get wstx wstx-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt wstx-address diko-address (get diko wstx-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt wstx-address usdh-address (get usdh wstx-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt wstx-address susdt-address (get susdt wstx-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt wstx-address usda-address (get usda wstx-debt)))

    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt ststxbtc-address ststx-address (get ststx ststxbtc-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt ststxbtc-address aeusdc-address (get aeusdc ststxbtc-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt ststxbtc-address wstx-address (get wstx ststxbtc-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt ststxbtc-address diko-address (get diko ststxbtc-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt ststxbtc-address usdh-address (get usdh ststxbtc-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt ststxbtc-address susdt-address (get susdt ststxbtc-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt ststxbtc-address usda-address (get usda ststxbtc-debt)))

    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt sbtc-address ststx-address (get ststx sbtc-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt sbtc-address aeusdc-address (get aeusdc sbtc-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt sbtc-address wstx-address (get wstx sbtc-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt sbtc-address diko-address (get diko sbtc-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt sbtc-address usdh-address (get usdh sbtc-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt sbtc-address susdt-address (get susdt sbtc-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt sbtc-address usda-address (get usda sbtc-debt)))
  

    (try! (contract-call? .pool-reserve-data-3 set-approved-contract (as-contract tx-sender) false))


    (print "ststx")
    (print {
      ststx: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststx-address ststx-address),
      aeusdc: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststx-address aeusdc-address),
      wstx: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststx-address wstx-address),
      diko: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststx-address diko-address),
      usdh: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststx-address usdh-address),
      susdt: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststx-address susdt-address),
      usda: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststx-address usda-address),
      sbtc: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststx-address sbtc-address),
      ststxbtc: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststx-address ststxbtc-address),
    })

    (print "wstx")
    (print {
      ststx: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read wstx-address ststx-address),
      aeusdc: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read wstx-address aeusdc-address),
      wstx: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read wstx-address wstx-address),
      diko: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read wstx-address diko-address),
      usdh: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read wstx-address usdh-address),
      susdt: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read wstx-address susdt-address),
      usda: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read wstx-address usda-address),
      sbtc: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read wstx-address sbtc-address),
      ststxbtc: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read wstx-address ststxbtc-address),
    })

    (print "ststxbtc")
    (print {
      ststx: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststxbtc-address ststx-address),
      aeusdc: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststxbtc-address aeusdc-address),
      wstx: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststxbtc-address wstx-address),
      diko: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststxbtc-address diko-address),
      usdh: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststxbtc-address usdh-address),
      susdt: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststxbtc-address susdt-address),
      usda: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststxbtc-address usda-address),
      sbtc: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststxbtc-address sbtc-address),
      ststxbtc: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststxbtc-address ststxbtc-address),
    })

    (print "sbtc")
    (print {
      ststx: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read sbtc-address ststx-address),
      aeusdc: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read sbtc-address aeusdc-address),
      wstx: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read sbtc-address wstx-address),
      diko: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read sbtc-address diko-address),
      usdh: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read sbtc-address usdh-address),
      susdt: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read sbtc-address susdt-address),
      usda: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read sbtc-address usda-address),
      sbtc: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read sbtc-address sbtc-address),
      ststxbtc: (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read sbtc-address ststxbtc-address),
    })

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