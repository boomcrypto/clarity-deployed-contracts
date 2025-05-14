---
title: "Trait asset-deployment-150"
draft: true
---
```
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
  ststx: u490584757692,
  aeusdc: u136251186783,
  wstx: u1498909656327,
  diko: u351019976002,
  usdh: u8775471555087,
  susdt: u5304475297501,
  usda: u4804737341,
  sbtc: u38278,
  ststxbtc: u0})

(define-constant wstx-debt {
  ststx: u3859712959,
  aeusdc: u11518011250,
  wstx: u588992625324,
  diko: u2844600119,
  usdh: u1771361386636,
  susdt: u1414886941741,
  usda: u674404,
  sbtc: u500481891,
  ststxbtc: u0})

(define-constant ststxbtc-debt {
  ststx: u34453440787,
  aeusdc: u8926096432,
  wstx: u25102235473,
  diko: u3686775589,
  usdh: u3983393701825,
  susdt: u100221519099,
  usda: u0,
  sbtc: u0,
  ststxbtc: u0})

(define-constant sbtc-debt {
  ststx: u7655330524,
  aeusdc: u90847344104,
  wstx: u41209090544,
  diko: u32318794,
  usdh: u1347369952711,
  susdt: u7975135292453,
  usda: u51182416456,
  sbtc: u0,
  ststxbtc: u0})

(define-public (run-update)
  (let (
    (reserve-data-ststx (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read ststx-address)))
  )
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

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


    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt ststx-address sbtc-address (get sbtc ststx-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt ststx-address ststxbtc-address (get ststxbtc ststx-debt)))

    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt wstx-address sbtc-address (get sbtc wstx-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt wstx-address ststxbtc-address (get ststxbtc wstx-debt)))

    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt ststxbtc-address sbtc-address (get sbtc ststxbtc-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt ststxbtc-address ststxbtc-address (get ststxbtc ststxbtc-debt)))

    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt sbtc-address sbtc-address (get sbtc sbtc-debt)))
    (try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt sbtc-address ststxbtc-address (get ststxbtc sbtc-debt)))
  

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
```
